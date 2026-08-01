#!/usr/bin/env python3
"""Static consistency checks for the independently rebuilt T+ layout."""

from __future__ import annotations

import argparse
import string
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "patches" / "res"
ANDROID_ID = "{http://schemas.android.com/apk/res/android}id"

PAIR_ROWS = (
    ("qw", "er", "ty", "ui", "op"),
    ("as", "df", "gh", "jk"),
    ("zx", "cv", "bn"),
)
EXPECTED_PAIRS = tuple(pair for row in PAIR_ROWS for pair in row)
EXPECTED_NORMAL_IDS = tuple(f"@id/softkey_tplus_{pair}" for pair in EXPECTED_PAIRS)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def parse(path: Path) -> ET.Element:
    require(path.is_file(), f"Missing XML resource: {path}")
    return ET.parse(path).getroot()


def verify_xml_syntax() -> None:
    files = sorted((RES / "layout").glob("*tplus*.xml"))
    files += sorted((RES / "xml").glob("*tplus*.xml"))
    files += sorted(RES.glob("values*/tplus.xml"))
    require(len(files) == 10, f"Expected 10 T+ XML resources, found {len(files)}")
    for path in files:
        parse(path)


def verify_softkeys() -> None:
    root = parse(RES / "xml" / "softkeys_input_zh_cn_pinyin_tplus.xml")
    lists = root.findall("./softkeys/softkey_list")
    require(len(lists) == 2, "Expected lowercase and uppercase T+ pair lists")

    for index, expected_upper in enumerate((False, True)):
        keys = lists[index].findall("softkey")
        require(len(keys) == len(EXPECTED_PAIRS), "Unexpected T+ pair count")
        for key, expected_pair in zip(keys, EXPECTED_PAIRS, strict=True):
            pair = expected_pair.upper() if expected_upper else expected_pair
            prefix = "@id/softkey_tplus_up_" if expected_upper else "@id/softkey_tplus_"
            require(key.get("id") == prefix + expected_pair, f"Wrong key id for {pair}")
            require(key.get("press_data") == pair, f"Wrong press data for {pair}")
            require(key.get("left_data") == pair[0], f"Wrong left slide for {pair}")
            require(key.get("right_data") == pair[1], f"Wrong right slide for {pair}")
            require(key.get("keycode_left") == pair[0].upper(), f"Wrong left keycode for {pair}")
            require(key.get("keycode_right") == pair[1].upper(), f"Wrong right keycode for {pair}")

    single_keys = {
        key.get("id"): key
        for key in root.findall("./softkeys/softkey")
    }
    for suffix, letter, punctuation in (
        ("l", "l", "-"),
        ("m", "m", "'"),
        ("up_l", "L", "-"),
        ("up_m", "M", "'"),
    ):
        key = single_keys.get(f"@id/softkey_tplus_{suffix}")
        require(key is not None, f"Missing single-letter key {suffix}")
        press = key.find("action[@type='PRESS']")
        slide = key.find("action[@type='SLIDE_RIGHT']")
        require(press is not None and press.get("data") == letter, f"Wrong press for {suffix}")
        require(slide is not None and slide.get("data") == punctuation, f"Wrong slide for {suffix}")

    covered = "".join(EXPECTED_PAIRS) + "lm"
    require(len(covered) == 26, "T+ layout does not contain 26 letter positions")
    require(set(covered) == set(string.ascii_lowercase), "T+ layout does not cover A-Z exactly once")


def verify_layout_and_mapping() -> None:
    layout = parse(RES / "layout" / "keyboard_tplus_input_area.xml")
    rows = layout.findall("LinearLayout")
    require([len(list(row)) for row in rows] == [5, 5, 6], "Expected T+ row geometry 5/5/6")

    expected_views = (
        "qw", "er", "ty", "ui", "op",
        "as", "df", "gh", "jk", "l",
        "zx", "cv", "bn", "m",
    )
    actual_views = []
    for element in layout.iter():
        resource_id = element.get(ANDROID_ID, "")
        if resource_id.startswith("@id/key_pos_tplus_"):
            actual_views.append(resource_id.removeprefix("@id/key_pos_tplus_"))
    require(tuple(actual_views) == expected_views, "T+ visual key order changed")

    mapping = parse(RES / "xml" / "keymapping_body_zh_cn_pinyin_tplus.xml")
    # Framework XML represents NORMAL with the first state-less key_mapping.
    normal = mapping.find("key_mapping")
    require(normal is not None and normal.get("state") is None, "Missing default T+ key mapping")
    mapped = {
        item.get("key_id")
        for item in normal.findall("mapping")
        if item.get("view_id", "").startswith("@id/key_pos_tplus_")
    }
    require(mapped == set(EXPECTED_NORMAL_IDS) | {
        "@id/softkey_tplus_l",
        "@id/softkey_tplus_m",
    }, "NORMAL T+ key mapping is incomplete")


def verify_decoded(decoded: Path) -> None:
    framework = (decoded / "res" / "xml" / "framework_chinese_soft.xml").read_text(encoding="utf-8")
    require(framework.count('@xml/ime_zh_cn_pinyin_tplus') == 1, "Decoded IME list lacks one T+ entry")

    processor = decoded / (
        "smali/com/google/android/apps/inputmethod/pinyin/ime/hmm/"
        "HmmPinyinT9DecodeProcessor.smali"
    )
    processor_text = processor.read_text(encoding="utf-8")
    require(processor_text.count("TPlusKeyMapping;->containsKey") == 1, "T+ processor hook missing or duplicated")
    require(processor_text.count("T9KeyMapping;->containsKey") == 1, "Original T9 branch missing or duplicated")

    helper = decoded / "smali/com/google/android/apps/inputmethod/libs/hmm/TPlusKeyMapping.smali"
    require(helper.is_file(), "Decoded TPlusKeyMapping helper is missing")
    for relative in (
        "res/xml/ime_zh_cn_pinyin_tplus.xml",
        "res/xml/keyboard_zh_cn_pinyin_tplus.xml",
        "res/xml/softkeys_input_zh_cn_pinyin_tplus.xml",
        "res/layout/keyboard_tplus_input_area.xml",
    ):
        require((decoded / relative).is_file(), f"Decoded resource missing: {relative}")

    # A fresh patch keeps values/tplus.xml, while apktool merges value resources
    # into strings.xml and ids.xml when a rebuilt APK is decoded again.
    value_files = sorted((decoded / "res").glob("values*/*.xml"))
    values_text = "\n".join(path.read_text(encoding="utf-8") for path in value_files)
    require('name="pinyin_tplus_ime_label"' in values_text, "Decoded T+ label resource is missing")
    require('name="keyboard_zh_cn_pinyin_tplus"' in values_text, "Decoded T+ keyboard id is missing")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", nargs="?", type=Path, help="Optional post-patch apktool directory")
    args = parser.parse_args()

    verify_xml_syntax()
    verify_softkeys()
    verify_layout_and_mapping()
    if args.decoded is not None:
        verify_decoded(args.decoded.resolve())
    print("T+ static verification passed")


if __name__ == "__main__":
    main()
