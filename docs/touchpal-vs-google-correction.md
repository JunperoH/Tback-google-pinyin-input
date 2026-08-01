# TouchPal and Google Pinyin correction/prediction comparison

## Scope

This note compares the locally supplied TouchPal 5.7.9.0 APK with the Google Pinyin 4.5.2 engine used by this fork. It does not treat current Gboard as the same product or assume that a setting name proves the quality of the underlying model.

Public background material is useful but version-sensitive:

- [York University's T+ study](https://www.yorku.ca/mack/mhci2013g.html) describes the two-letter QWERTY-spatial layout and predictive disambiguation.
- [HTC's TouchPal guide](https://www.htc.com/us/support/htc-u11-sprint/howto/how-can-i-type-faster.html) documents contextual and next-word prediction in a contemporary TouchPal distribution.
- [Google Research's Gboard overview](https://research.google/blog/the-machine-intelligence-behind-gboard/?m=1) explains the combination of a spatial model, language model and beam search, but describes modern Gboard rather than this older Google Pinyin APK.

## What the APKs show

The TouchPal APK exposes settings for adaptive learning, automatic correction, dynamic spell checking, forward and next-word prediction, mistyping correction, touch correction, backward correction, contextual words and pronunciation-error correction. Its Chinese fuzzy-pinyin pairs include `c/ch`, `s/sh`, `z/zh`, `f/h`, `l/n`, `l/r`, `n/r`, `an/ang`, `en/eng`, `in/ing`, `ian/iang` and `uan/uang`.

The Google Pinyin APK contains a native HMM decoder, a gesture/HWR library, Chinese and English user dictionaries, local next-word prediction and fuzzy-pinyin support. Its fuzzy set is nearly the same, but includes `k/g` and does not expose TouchPal's extra `n/r` combination. The normal QWERTY layout also has an explicit touch spatial model.

TouchPal's resources and most of its input intelligence are packed into opaque/proprietary native or binary assets. The supplied build also carries an old 32-bit `armeabi` native library. Copying that engine into the fork would create licensing, security and modern-Android compatibility risks, so this project only reconstructs the interaction layout and keeps Google's local engine.

## Practical comparison

| Area | TouchPal 5.7.9 | This fork / Google Pinyin 4.5.2 |
| --- | --- | --- |
| T+ tap disambiguation | Designed around T+ and likely has layout-specific priors and touch correction. | Each two-letter key currently sends two equal-score alternatives into Google's T9 HMM. |
| T+ gesture input | TouchPal historically offered Curve-style input, although public manuals differ on which layouts supported it. | Cross-key T+ gestures now use Google's bundled gesture HMM; both letters share the same key geometry. |
| Tap typo correction | Exposes several explicit mistyping/touch/backward-correction controls. | Standard QWERTY has a spatial model; T+ pair taps currently do not have within-key coordinate weighting. |
| Context and next word | Local settings expose contextual, forward and next-word prediction plus adaptive learning. | Local HMM, user dictionaries and next-word prediction remain active in the fork. |
| Personalization | Historically exposed SMS, contacts, social and cloud learning/import features. | Maintains local user dictionaries; obsolete online dictionary updating is disabled in this fork. |
| Maintainability today | Old, opaque, delisted and dependent on proprietary native components/services. | Rebuildable, auditable and offline, with an independently implemented T+ adapter. |

## Emulator evidence

On Android 14, a continuous T+ path intended as `nihao` (`BN -> UI -> GH -> AS -> OP`) decoded to `bu hao`. The first two candidates were `不好` and `你好`; selecting `你好` committed correctly. This proves that the gesture pipeline works, while also demonstrating the main quality gap: the first key contributes both `b` and `n` at the same position, so the generic Google model can rank the wrong branch first.

The defensible current conclusion is therefore:

- TouchPal was probably better at first-candidate ranking on its own T+ layout because the engine and correction rules were designed for that ambiguity. This is an inference from the APK structure, settings and the observed T+ behavior, not a controlled accuracy score.
- Google Pinyin remains the better foundation for this fork because it is already integrated, works locally and can be rebuilt and tested. Its standard QWERTY spatial correction should not be used as evidence that the current T+ adapter has the same accuracy.
- Richer old TouchPal cloud/social options do not imply better usable prediction today; the services may be unavailable and should not be trusted without live testing.

## Recommended next step

Do not transplant TouchPal's native engine. Build a repeatable A/B corpus and improve the T+ adapter/ranker around Google's engine:

1. Record intended text and the exact T+ tap or gesture path for common phrases, names, fuzzy-pinyin cases and deliberate adjacent-key errors.
2. Measure top-1, top-3, correction rate and candidate-selection cost for both original TouchPal and this fork on the same device.
3. Add T+-specific priors only where measurements show a stable error pattern, starting with pair ambiguity at gesture start/end and phrase-boundary ranking.
4. Re-run the corpus after user-dictionary learning to separate cold-model accuracy from personalization.

A useful first corpus includes `nihao`, `zhongguo`, `shijian`, `xiexie`, `beijing`, `chongqing`, frequent personal names, `n/l` and `an/ang` fuzzy cases, plus two-phrase contexts where the next word is predictable.
