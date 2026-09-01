#!/usr/bin/env python3
"""Verify the T+ stroke-filter data asset and its deterministic generator."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from generate_stroke_filter_data import (  # noqa: E402
    DEFAULT_OUTPUT,
    FLAGS,
    FORMAT_VERSION,
    HEADER,
    MAGIC,
    MAX_STROKES,
    SOURCE_SHA256,
    VARIANT,
    generate,
    to_sequence_set,
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def unpack_variant(length: int, packed: int) -> str:
    require(1 <= length <= MAX_STROKES, f"Invalid variant length: {length}")
    require(packed >> (length * 3) == 0, "Variant has non-zero unused bits")
    strokes: list[str] = []
    for index in range(length):
        stroke = (packed >> (index * 3)) & 0x7
        require(1 <= stroke <= 5, f"Invalid stroke value: {stroke}")
        strokes.append(str(stroke))
    return "".join(strokes)


def decode_binary(data: bytes) -> dict[int, tuple[str, ...]]:
    require(len(data) >= HEADER.size, "Truncated TSF1 header")
    magic, version, flags, codepoint_count, variant_count, digest = HEADER.unpack_from(data)
    require(magic == MAGIC, "Incorrect TSF1 magic")
    require(version == FORMAT_VERSION, "Unsupported TSF1 version")
    require(flags == FLAGS, "Unsupported TSF1 flags")
    require(digest == bytes.fromhex(SOURCE_SHA256), "Incorrect Conway source digest")
    require(codepoint_count > 0, "TSF1 has no code points")
    require(variant_count >= codepoint_count, "TSF1 has too few variants")

    codepoint_bytes = codepoint_count * 4
    offset_bytes = codepoint_count * 4
    count_bytes = codepoint_count * 2
    variant_bytes = variant_count * VARIANT.size
    expected_size = HEADER.size + codepoint_bytes + offset_bytes + count_bytes + variant_bytes
    require(len(data) == expected_size, "TSF1 section sizes do not match file length")

    cursor = HEADER.size
    codepoints = struct.unpack_from(f"<{codepoint_count}I", data, cursor)
    cursor += codepoint_bytes
    offsets = struct.unpack_from(f"<{codepoint_count}I", data, cursor)
    cursor += offset_bytes
    counts = struct.unpack_from(f"<{codepoint_count}H", data, cursor)
    cursor += count_bytes

    require(all(a < b for a, b in zip(codepoints, codepoints[1:])), "Code points are not sorted")
    require(offsets[0] == 0, "First variant offset is not zero")

    packed_variants = [VARIANT.unpack_from(data, cursor + index * VARIANT.size) for index in range(variant_count)]
    result: dict[int, tuple[str, ...]] = {}
    for index, codepoint in enumerate(codepoints):
        offset = offsets[index]
        count = counts[index]
        require(count > 0, f"U+{codepoint:04X} has no variants")
        require(offset + count <= variant_count, f"U+{codepoint:04X} variant range exceeds section")
        if index + 1 < codepoint_count:
            require(offset + count == offsets[index + 1], "Variant ranges are not contiguous")
        variants = tuple(
            unpack_variant(length, packed)
            for length, packed in packed_variants[offset : offset + count]
        )
        require(len(set(variants)) == len(variants), f"U+{codepoint:04X} has duplicate variants")
        result[codepoint] = variants
    require(offsets[-1] + counts[-1] == variant_count, "Final variant range is incomplete")
    return result


def matches(records: dict[int, tuple[str, ...]], character: str, prefix: str) -> bool:
    return any(sequence.startswith(prefix) for sequence in records.get(ord(character), ()))


def expect_rejected(data: bytes, label: str) -> None:
    try:
        decode_binary(data)
    except (AssertionError, struct.error):
        return
    raise AssertionError(f"Corrupt fixture was accepted: {label}")


def verify_expansion_logic() -> None:
    require(to_sequence_set("12345") == {"12345"}, "Plain sequence expansion failed")
    require(to_sequence_set("(135|153)") == {"135", "153"}, "Choice expansion failed")
    require(to_sequence_set("12(|3)45") == {"1245", "12345"}, "Empty branch expansion failed")
    require(to_sequence_set(r"(12|34)5\1") == {"12512", "34534"}, "Back reference expansion failed")
    require(
        to_sequence_set(r"1(2|3)(|4)5\1\2")
        == {"1252", "124524", "1353", "134534"},
        "Multiple capture group expansion failed",
    )


def verify_asset(asset: Path) -> None:
    require(asset.is_file(), f"Missing stroke-filter asset: {asset}")
    generated, report = generate()
    actual = asset.read_bytes()
    require(actual == generated, "stroke_filter_data.bin is not byte-for-byte reproducible")
    records = decode_binary(actual)
    require(len(records) == report["codepoints"], "Generated report code point count differs")
    require(sum(map(len, records.values())) == report["variants"], "Generated report variant count differs")

    require(matches(records, "偲", "3"), "偲 must match left-slash prefix 3")
    require(not matches(records, "偲", "4"), "偲 must not match dot prefix 4")
    require(matches(records, "灏", "4"), "灏 must match dot prefix 4")
    require(matches(records, "灝", "4"), "灝 must match dot prefix 4")
    require(not matches(records, "灏", "3"), "灏 must not match left-slash prefix 3")

    expect_rejected(actual[:-1], "truncated")
    wrong_magic = bytearray(actual)
    wrong_magic[0:4] = b"BAD!"
    expect_rejected(bytes(wrong_magic), "magic")
    wrong_version = bytearray(actual)
    struct.pack_into("<H", wrong_version, 4, FORMAT_VERSION + 1)
    expect_rejected(bytes(wrong_version), "version")
    wrong_digest = bytearray(actual)
    wrong_digest[16] ^= 0xFF
    expect_rejected(bytes(wrong_digest), "source digest")


def verify_modern_setting() -> None:
    source = ROOT / "modern-settings/compose-runtime/src/main"
    package = source / (
        "kotlin/com/google/android/inputmethod/pinyin/modernsettings/compose"
    )
    contracts = (package / "BooleanSettingContracts.kt").read_text(encoding="utf-8")
    repository = (package / "LegacySettingsRepository.kt").read_text(encoding="utf-8")
    screen = (package / "InputSettingsScreens.kt").read_text(encoding="utf-8")

    for token in (
        "val tplusStrokeFilter = BooleanSettingContract(",
        'key = "tplus_stroke_filter_enabled"',
        "defaultValue = false",
        "val tplusBatch = listOf(",
        "tplusStrokeFilter,",
        "thirdPlainBatch + tplusBatch +",
    ):
        require(token in contracts, f"Modern T+ Boolean contract is missing: {token}")
    for token in (
        "tplusStrokeFilter = readBoolean(BooleanSettingContracts.tplusStrokeFilter)",
        "val tplusStrokeFilter: BooleanSettingState",
    ):
        require(token in repository, f"Modern T+ preference repository is missing: {token}")
    for token in (
        '"stroke_filter_setting_title"',
        "R.string.modern_settings_tplus_stroke_filter_title",
        '"stroke_filter_setting_summary"',
        "R.string.modern_settings_tplus_stroke_filter_summary",
        "checked = snapshot.tplusStrokeFilter.value",
        "actions.onBooleanChange(BooleanSettingContracts.tplusStrokeFilter, it)",
    ):
        require(token in screen, f"Modern T+ setting row is missing: {token}")

    for qualifier in ("values", "values-zh", "values-zh-rTW", "values-zh-rHK"):
        strings = (source / "res" / qualifier / "strings.xml").read_text(encoding="utf-8")
        for name in (
            "modern_settings_tplus_stroke_filter_title",
            "modern_settings_tplus_stroke_filter_summary",
        ):
            require(
                f'name="{name}"' in strings,
                f"Modern T+ string is missing from {qualifier}: {name}",
            )


def verify_decoded(decoded: Path, allow_test_hook: bool) -> None:
    hmm = decoded / "smali/com/google/android/apps/inputmethod/libs/hmm"
    abstract_hmm = (hmm / "AbstractHmmDecodeProcessor.smali").read_text(encoding="utf-8")
    chinese = (decoded / (
        "smali/com/google/android/apps/inputmethod/libs/chinese/ime/hmm/"
        "AbstractHmmChineseDecodeProcessor.smali"
    )).read_text(encoding="utf-8")
    for helper in (
        "StrokeFilterData.smali",
        "StrokeFilterCompat.smali",
        "StrokeFilterCompat$1.smali",
        "StrokeFilterCandidateSession.smali",
        "StrokeFilterCandidateSession$1.smali",
        "StrokeFilterCandidateSession$ReplayIterator.smali",
        "StrokeFilterMotionEventHandler.smali",
        "StrokeFilterTrailView.smali",
    ):
        require((hmm / helper).is_file(), f"Decoded helper is missing: {helper}")

    hooks = {
        "initialize": "StrokeFilterCompat;->initialize(Landroid/content/Context;)V",
        "setTextCandidates": "StrokeFilterCompat;->onSetTextCandidates",
        "requestCandidates": "StrokeFilterCompat;->requestCandidates",
        "resetInternalStates": "StrokeFilterCompat;->onResetInternalStates",
    }
    for label, hook in hooks.items():
        require(abstract_hmm.count(hook) == 1, f"{label} hook is missing or duplicated")
    require(
        abstract_hmm.count("Ljava/util/Iterator;->next()Ljava/lang/Object;") == 1,
        "Original Candidate iterator next() path changed",
    )
    request_start = abstract_hmm.index(".method protected final onRequestCandidates(I)Z")
    request_end = abstract_hmm.index(".end method", request_start)
    request_method = abstract_hmm[request_start:request_end]
    require(
        request_method.index("StrokeFilterCompat;->requestCandidates")
        < request_method.index("->mTextCandidateIterator:Ljava/util/Iterator;"),
        "Filter hook must fail open into the original candidate request loop",
    )
    require(
        request_method.count("Ljava/util/Iterator;->next()Ljava/lang/Object;") == 1
        and "->doAppendTextCandidates" in request_method,
        "Original candidate request loop or append path is missing",
    )
    require(
        chinese.count("StrokeFilterCompat;->handleFilteredCommit") == 2,
        "SPACE/ENTER filtered commit hooks are missing or duplicated",
    )
    require(
        chinese.count("->onSelectTextCandidate") == 0,
        "Original candidate click chain must not be replaced at call sites",
    )

    session = (hmm / "StrokeFilterCandidateSession.smali").read_text(encoding="utf-8")
    compat = (hmm / "StrokeFilterCompat.smali").read_text(encoding="utf-8")
    for field in (
        "composingGeneration:I",
        "filterGeneration:I",
        "rawCandidateCache:Ljava/util/ArrayList;",
        "rawCursor:I",
        "sourceExhausted:Z",
        "firstMatchedCandidateForFilter:",
        "pendingRunnable:Ljava/lang/Runnable;",
    ):
        require(field in session, f"Candidate session field is missing: {field}")
    require("const/16 v" in session and "0x100" in session, "256-candidate scan budget is missing")
    require("removeCallbacks(Ljava/lang/Runnable;)V" in session, "Pending scan cancellation is missing")
    require("filterGeneration" in session and "composingGeneration" in session, "Dual generation checks are missing")
    require("createReplayIterator" in session, "Fail-open replay iterator is missing")
    require("tplus_stroke_filter_enabled" in compat, "Stable preference key is missing")
    require("const/4 v2, 0x0" in compat or "const/4 v1, 0x0" in compat, "Preference default false is missing")
    gesture_gate_start = compat.index(
        ".method public static declared-synchronized shouldDisableTPlusGesture()Z"
    )
    gesture_gate_end = compat.index(".end method", gesture_gate_start)
    gesture_gate = compat[gesture_gate_start:gesture_gate_end]
    require(
        "->tplusActive:Z" in gesture_gate
        and "StrokeFilterCompat;->isSettingEnabled()Z" in gesture_gate
        and "->captureActive:Z" not in gesture_gate,
        "T+ glide suppression must depend on the active T+ layout and enabled setting",
    )

    t9 = (decoded / (
        "smali/com/google/android/apps/inputmethod/pinyin/ime/hmm/"
        "HmmPinyinT9DecodeProcessor.smali"
    )).read_text(encoding="utf-8")
    require(t9.count("-0x9c45") == 2, "Stroke event lower bound must be guarded twice")
    require(t9.count("-0x9c41") == 2, "Stroke event upper bound must be guarded twice")
    require(
        t9.count("StrokeFilterCompat;->appendStroke(I)Z") == 1,
        "T9 stroke-event interception is missing or duplicated",
    )
    require(
        t9.count("StrokeFilterCompat;->deleteStroke()Z") == 1,
        "Stroke-prefix Backspace interception is missing or duplicated",
    )
    require(
        t9.count("StrokeFilterCompat;->handleFilteredCommit") == 1
        and "-0x2722" in t9,
        "Soft IME_ACTION filtered commit hook is missing",
    )

    motion = (hmm / "StrokeFilterMotionEventHandler.smali").read_text(encoding="utf-8")
    for invariant in (
        "IMotionEventHandler;",
        "ViewConfiguration;->getScaledTouchSlop()I",
        "StrokeFilterCompat;->isCaptureActive()Z",
        "IMotionEventHandlerDelegate;->declareTargetHandler()V",
        "IMotionEventHandlerDelegate;->fireEvent",
        "IMotionEventHandlerDelegate;->getPopupViewManager()",
        "IPopupViewManager;->showPopupView",
        "StrokeFilterTrailView;->startStroke(FF)V",
        "StrokeFilterTrailView;->addPoint(FF)V",
        "StrokeFilterTrailView;->finishStroke()V",
        "StrokeFilterCompat;->activateTPlus()V",
        "StrokeFilterCompat;->deactivateTPlus()V",
        "-0x9c40",
    ):
        require(invariant in motion, f"Motion handler invariant is missing: {invariant}")
    require("0x3fb9999a" in motion, "Fold path/direct-ratio threshold is missing")
    require(
        motion.count(".method public acceptInitialEvent") == 1
        and motion.count(".method public preHandleAsTargetHandler") == 1,
        "Motion target-claim methods are missing or duplicated",
    )
    handle_start = motion.index(".method public handle(Landroid/view/MotionEvent;)V")
    handle_end = motion.index(".end method", handle_start)
    handle = motion[handle_start:handle_end]
    require(
        "MotionEvent;->getActionMasked()I" in handle
        and "StrokeFilterCompat;->isCaptureActive()Z" in handle
        and "StrokeFilterCompat;->activateTPlus()V" in handle
        and "->begin(Landroid/view/MotionEvent;)V" in handle
        and "IMotionEventHandlerDelegate;->declareTargetHandler()V" in handle
        and "maxOffsetSquare:F" in handle
        and "touchSlop:I" in handle,
        "Automatic handler must track DOWN and claim only after crossing touch slop",
    )
    require(
        handle.index("StrokeFilterCompat;->activateTPlus()V")
        < handle.index("MotionEvent;->getActionMasked()I"),
        "T+ layout token must be refreshed before shared Pinyin handlers see the event",
    )

    keyboard = (decoded / "res/xml/keyboard_zh_cn_pinyin_tplus.xml").read_text(
        encoding="utf-8"
    )
    handler_class = (
        "com.google.android.apps.inputmethod.libs.hmm.StrokeFilterMotionEventHandler"
    )
    require(keyboard.count(handler_class) == 1, "T+ motion handler registration is missing")
    require(
        keyboard.index(handler_class) < keyboard.index("BasicMotionEventHandler"),
        "T+ motion handler must precede BasicMotionEventHandler",
    )
    all_keyboard_xml = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (decoded / "res").glob("xml*/keyboard*.xml")
    )
    require(
        all_keyboard_xml.count(handler_class) == 1,
        "Stroke motion handler must be isolated to the T+ keyboard",
    )

    basic_handler = (decoded / (
        "smali/com/google/android/apps/inputmethod/libs/framework/keyboard/handler/"
        "BasicMotionEventHandler.smali"
    )).read_text(encoding="utf-8")
    basic_start = basic_handler.index(".method public handle(Landroid/view/MotionEvent;)V")
    basic_end = basic_handler.index(".end method", basic_start)
    basic_handle = basic_handler[basic_start:basic_end]
    require(
        "StrokeFilterCompat;" not in basic_handle,
        "Basic handler must remain native so automatic mode preserves taps and long presses",
    )
    dispatcher = (decoded / "smali/atu.smali").read_text(encoding="utf-8")
    dispatcher_methods = []
    for signature in (
        ".method public final preHandleTouchEvent(Landroid/view/MotionEvent;)Z",
        ".method public final handleTouchEvent(Landroid/view/MotionEvent;)V",
    ):
        start = dispatcher.index(signature)
        end = dispatcher.index(".end method", start)
        dispatcher_methods.append(dispatcher[start:end])
    require(
        dispatcher.count("StrokeFilterCompat;->isCaptureActive()Z") == 2
        and all(
            method.count("StrokeFilterCompat;->isCaptureActive()Z") == 1
            and "MotionEvent;->getActionMasked()I" in method
            and "iput-object v0, p0, Latu;->a:Lcom/google/android/apps/inputmethod/"
            "libs/framework/keyboard/IMotionEventHandler;" in method
            for method in dispatcher_methods
        ),
        "Dispatcher must release a stale target only at automatic-capture DOWN",
    )

    trail = (hmm / "StrokeFilterTrailView.smali").read_text(encoding="utf-8")
    for invariant in (
        "Landroid/graphics/Path;",
        "Canvas;->drawPath",
        "Paint$Cap;->ROUND",
        "Paint$Join;->ROUND",
        "ColorGestureTrack",
        "View;->postDelayed(Ljava/lang/Runnable;J)Z",
    ):
        require(invariant in trail, f"Visible stroke trail invariant is missing: {invariant}")
    overlay = decoded / "res/layout/stroke_filter_overlay_view.xml"
    require(overlay.is_file(), "Stroke overlay layout is missing")
    overlay_text = overlay.read_text(encoding="utf-8")
    require(
        "StrokeFilterTrailView" in overlay_text
        and 'android:clickable="false"' in overlay_text,
        "Stroke overlay must be the non-interactive custom trail view",
    )

    for name, super_path, label in (
        (
            "PinyinGestureHandler.smali",
            "AbstractGestureMotionEventHandler;->handle(Landroid/view/MotionEvent;)V",
            "Pinyin gesture",
        ),
        (
            "PinyinKeyboardLayoutHandler.smali",
            "AbstractPinyinKeyboardLayoutHandler;->handle(Landroid/view/MotionEvent;)V",
            "Pinyin layout",
        ),
    ):
        handler = (decoded / (
            "smali/com/google/android/apps/inputmethod/pinyin/keyboard"
        ) / name).read_text(encoding="utf-8")
        require(
            handler.count("StrokeFilterCompat;->shouldDisableTPlusGesture()Z") == 1
            and "StrokeFilterCompat;->isCaptureActive()Z" not in handler,
            f"{label} must yield whenever T+ stroke filtering is enabled",
        )
        require(super_path in handler, f"{label} original glide path is not preserved")

    holder = (decoded / (
        "smali/com/google/android/apps/inputmethod/libs/framework/keyboard/widget/"
        "FixedSizeCandidatesHolderView.smali"
    )).read_text(encoding="utf-8")
    require(
        holder.count("StrokeFilterCompat;->updateToggle(Landroid/view/View;)V") == 1,
        "Candidate toggle refresh hook is missing or duplicated",
    )
    for layout_name in (
        "keyboard_candidates_header_inner.xml",
        "keyboard_candidates_header_inner_no_deletable_label.xml",
    ):
        layout = (decoded / "res/layout" / layout_name).read_text(encoding="utf-8")
        require(
            layout.count('android:tag="compat_stroke_filter_toggle"') == 1,
            f"Stroke toggle overlay is missing from {layout_name}",
        )
        require(
            layout.count('android:tag="compat_stroke_filter_holder"') == 1,
            f"Candidate holder tag is missing from {layout_name}",
        )

    settings = (decoded / "res/xml/setting_input.xml").read_text(encoding="utf-8")
    require(
        settings.count('android:key="tplus_stroke_filter_enabled"') == 1,
        "Stroke-filter setting key is missing or duplicated",
    )
    require('android:defaultValue="false"' in settings, "Stroke-filter setting is not default-off")
    values_text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (decoded / "res").glob("values*/*.xml")
    )
    for name in (
        "stroke_filter_setting_title",
        "stroke_filter_setting_summary",
        "stroke_filter_toggle_label",
        "stroke_filter_scanning",
        "stroke_filter_no_match",
    ):
        require(f'name="{name}"' in values_text, f"String resource is missing: {name}")

    has_test_hook = "enableTestMode" in abstract_hmm or "enableTestMode" in compat
    require(allow_test_hook or not has_test_hook, "Local enableTestMode hook found in production tree")
    verify_asset(decoded / "res/raw/stroke_filter_data.bin")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", nargs="?", type=Path, help="Optional post-patch apktool directory")
    parser.add_argument("--allow-test-hook", action="store_true")
    args = parser.parse_args()
    verify_expansion_logic()
    verify_asset(DEFAULT_OUTPUT)
    verify_modern_setting()
    if args.decoded is not None:
        verify_decoded(args.decoded.resolve(), args.allow_test_hook)
    print("Stroke-filter data verification passed")


if __name__ == "__main__":
    main()
