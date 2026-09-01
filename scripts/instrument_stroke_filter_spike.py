#!/usr/bin/env python3
"""Inject a local-only T+ lifecycle/setting/prefix hook into a decoded Spike APK."""

from __future__ import annotations

import argparse
from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"Expected exactly one match in {path}, found {count}")
    path.write_text(text.replace(old, new), encoding="utf-8", newline="\n")


def instrument(decoded: Path, prefix: str) -> None:
    if not prefix or len(prefix) > 5 or any(stroke not in "12345" for stroke in prefix):
        raise ValueError("prefix must contain one to five strokes in the range 1..5")
    compat = decoded / (
        "smali/com/google/android/apps/inputmethod/libs/hmm/StrokeFilterCompat.smali"
    )
    abstract_hmm = decoded / (
        "smali/com/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor.smali"
    )
    session = decoded / (
        "smali/com/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCandidateSession.smali"
    )
    keyboard = decoded / "res/xml/keyboard_zh_cn_pinyin_tplus.xml"
    if not compat.is_file() or not abstract_hmm.is_file() or not session.is_file():
        raise RuntimeError("Apply production stroke-filter patches before instrumenting")

    replace_once(
        compat,
        ".field private static tplusActive:Z\n\n\n# direct methods",
        ".field private static tplusActive:Z\n\n"
        ".field private static testMode:Z\n\n\n# direct methods",
    )
    replace_once(
        compat,
        "# direct methods\n.method static constructor <clinit>()V",
        "# direct methods\n"
        ".method public static enableTestMode(Ljava/lang/String;)V\n"
        "    .locals 1\n\n"
        "    const/4 v0, 0x1\n\n"
        "    sput-boolean v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->testMode:Z\n\n"
        "    sput-boolean v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->tplusActive:Z\n\n"
        "    sput-boolean v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->captureActive:Z\n\n"
        "    sput-object p0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->prefix:Ljava/lang/String;\n\n"
        "    return-void\n"
        ".end method\n\n"
        ".method static constructor <clinit>()V",
    )
    replace_once(
        compat,
        ".method private static isSettingEnabled()Z\n"
        "    .locals 3\n\n"
        "    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->applicationContext:Landroid/content/Context;",
        ".method private static isSettingEnabled()Z\n"
        "    .locals 3\n\n"
        "    sget-boolean v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->testMode:Z\n\n"
        "    if-eqz v0, :stroke_filter_test_setting_done\n\n"
        "    const/4 v0, 0x1\n\n"
        "    return v0\n\n"
        "    :stroke_filter_test_setting_done\n"
        "    sget-object v0, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->applicationContext:Landroid/content/Context;",
    )
    replace_once(
        abstract_hmm,
        "    invoke-static {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->initialize(Landroid/content/Context;)V\n\n"
        "    .line 4",
        "    invoke-static {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->initialize(Landroid/content/Context;)V\n\n"
        f"    const-string v0, \"{prefix}\"\n\n"
        "    invoke-static {v0}, Lcom/google/android/apps/inputmethod/libs/hmm/"
        "StrokeFilterCompat;->enableTestMode(Ljava/lang/String;)V\n\n"
        "    .line 4",
    )
    # The production handler is preference-gated by the keyboard framework.
    # The local test override must instantiate it before SharedPreferences has
    # been configured, so remove only that gate in the ignored Spike tree.
    replace_once(
        keyboard,
        '<motion_event_handler class="com.google.android.apps.inputmethod.libs.hmm.StrokeFilterMotionEventHandler" '
        'reverse_preference="false" preference_key="@string/'
        'tplus_stroke_filter_preference_key" />',
        '<motion_event_handler class="com.google.android.apps.inputmethod.libs.hmm.StrokeFilterMotionEventHandler" />',
    )
    print(f"Injected local stroke-filter test prefix {prefix} into {decoded}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    parser.add_argument("--prefix", required=True)
    args = parser.parse_args()
    instrument(args.decoded.resolve(), args.prefix)


if __name__ == "__main__":
    main()
