# TouchPal T+ dual-letter layout port

## Scope

This fork independently reconstructs the interaction model and key arrangement of TouchPal's T+ layout. It does not copy TouchPal code, artwork, dictionaries, native libraries, or packaged resources. The implementation uses new XML resources and a small smali interoperability helper on top of the existing Google Pinyin patch pipeline.

## Audited source APK

The locally supplied APK used for interoperability research was not added to Git:

| Field | Value |
| --- | --- |
| File | `TouchPal.apk` |
| Package | `com.cootek.smartinputv5` |
| Version | `5.7.9.0` (`versionCode` 5661) |
| min / target SDK | 15 / 23 |
| SHA-256 | `27b6a7eebab1f411f652ea0a9230bacc7758ee96ac10be93d2ac2732333d39a3` |

The decoded package names the third surface subtype `TPLUS(3)` and contains generated schemas such as `T_chs_soft_tplus_mainland`. Those schemas establish three five/five/four-key letter rows and the wider QWERTY-spatial arrangement, but their repeated placeholder title (`Q W`) is not used as the source of the individual labels.

The exact visible pairing was cross-checked against the public TouchPal T+ figure in the York University study [A Study of Variations of Qwerty Soft Keyboards for Mobile Phones](https://www.yorku.ca/mack/mhci2013g.html), whose Figure 4 shows:

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```

The same study describes T+ as a SureType/T9-like layout that keeps QWERTY spatial order and resolves one tap per two-letter key predictively. Contemporary TouchPal documentation also describes three switchable layouts: T+, full QWERTY and PhonePad.

## Google Pinyin integration

Google Pinyin's `HmmPinyinT9DecodeProcessor` already converts one numeric T9 key into an `Event` containing multiple equal-score `KeyData` alternatives before passing the event to the native HMM engine. The port preserves that path and adds `TPlusKeyMapping`:

1. A T+ softkey emits a one- or two-letter string such as `qw`.
2. `TPlusKeyMapping` validates one or two ASCII letters and creates the corresponding Android A-Z keycodes.
3. It returns one or two `KeyData(DECODE, letter)` items plus a same-length zero score array, matching the original T9 default-score behavior.
4. The patched T9 processor forwards the expanded event to the unchanged Google Pinyin HMM engine.

The existing candidate UI, composition lifecycle, mixed Chinese/English option, user dictionary and prediction components remain unchanged. Normal 9-key digit mapping continues through the original `T9KeyMapping` branch.

## Interaction

- Tap a two-letter key: submit both letters as equal candidates for contextual decoding.
- Slide left/right: submit only the left/right letter.
- Long-press: commit the small digit or symbol printed on the key.
- Slide right on `L -` or `M '`: input the punctuation shown beside the letter.
- Shift: use the uppercase pair definitions; behavior follows the existing mixed English input preference.
- With gesture input enabled, a longer cross-key path is handled by Google Pinyin's existing gesture UI and native HMM decoder. Each T+ key contributes both letters at the same geometry; short left/right key slides remain available below the original gesture threshold.

T+ is registered as `zh_cn_pinyin_tplus` in `framework_chinese_soft.xml`, so the existing keyboard dashboard can select it alongside QWERTY, 9-key, stroke and handwriting.

## Verification

- APKTool 2.12.1 SHA-256: `66cf4524a4a45a7f56567d08b2c9b6ec237bcdd78cee69fd4a59c8a0243aeafa`.
- Compatibility patch application: passed against the unmodified Google Pinyin 4.5.2.193126728 arm64-v8a APK.
- Full resource and smali rebuild with aapt2/apktool: passed.
- Static checks for all 26 letter positions, pair actions, visual order, IME registration and both T+/T9 decoder branches: passed.
- Final APK alignment, package/version/ABI identity, v1/v2/v3 signature verification and reverse-decode inspection: passed.
- Initial tap-based T+ input: reported working on device.
- Android 14 (API 34, 4 KB page size) emulator install, IME activation and T+ selection: passed. The dashboard kept QWERTY, 9-key and the other original layouts alongside T+.
- Long-press popup and commit: passed for both a digit (`QW / 1`) and punctuation (`ZX / @`), using the stock 9-key popup as the control case.
- Cross-key gesture input: passed with a continuous `BN -> UI -> GH -> AS -> OP` path. The native decoder produced `bu hao` with both `不好` and `你好` candidates; selecting `你好` committed it to the target field without a crash.

A real-device acceptance pass should still cover `nihao`, `zhongguo`, ambiguous pairs such as `ui/ty`, backspace while composing, shift/mixed English, every remaining digit/symbol long-press, short single-key slides, longer cross-key gesture paths, orientation changes and repeated switching between T+, QWERTY and 9-key. Gesture first-candidate quality is not expected to match a layout-native TouchPal model without further ranking work.

The gesture implementation is an extension built from Google Pinyin's bundled `PinyinGestureHandler`, `PinyinKeyboardLayoutHandler` and `hmm_gesture` runtime. It does not copy TouchPal Curve code or models. Public TouchPal manuals differ by version and commonly document Curve as a T26-only mode, so T+ gesture quality must be evaluated independently on device.
