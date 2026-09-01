# T+ 构建、验证与发布流程

本文说明如何从固定 Google 拼音 4.5.2 APK 可复现地构建和发布 T+ 自用版。普通使用者只需从 GitHub Releases 下载 APK。

## 版本身份

正式版本只在根目录 `version.properties` 中定义：

| 项目 | 当前值 |
| --- | --- |
| Android `versionName` | `2.1.0` |
| Android `versionCode` | `4520407` |
| target SDK | `36` |
| Application ID | `com.google.android.inputmethod.pinyin.compat.tplus` |
| Release 标签 | `tplus-v2.1.0` |
| APK 文件名 | `ComebackGooglePinyinInput-TPlus-arm64-v8a-2.1.0.apk` |
| 上游基线 | `v2.0.10` / `1e8fb927` |

`versionCode` 必须始终递增。T+ 标签固定使用 `tplus-v*`，避免与上游 `v*` 标签混淆。GitHub Release Assets 必须直接使用完整文件名及其 `.sha256` 文件名，禁止使用 `文件路径#显示别名`。

## 构建模型

```text
固定原始 APK
→ apktool decode
→ scripts/apply_patches.py
→ T+、Stroke Filter 与 Android 16 兼容补丁
→ patched legacy classes.dex
→ AAPT2 stable resource IDs
→ Compose Material 3 host
→ legacy classes.dex + Compose/AndroidX classes2.dex+
→ zipalign -P 16
→ T+ 正式签名
→ 最终 APK 门禁
```

关键不变量：

- 全部 6,633 个旧公开资源 ID 保持。
- patched legacy IME 保持在 `classes.dex`。
- Compose/AndroidX 只位于 `classes2.dex` 及以后。
- API 17–34 启动不解析现代设置类，API 35+ 才路由 Compose Material 3 设置。
- 正式包为 release-like、非 debuggable，且只允许 T+ 正式 Application ID。
- T+、Stroke Filter、统一 Header、Inline Autofill 与现代 Android 门禁全部通过。
- APK 通过 v1/v2/v3 签名与 16 KiB ZIP alignment。

## 本地环境

- Python 3.12 或兼容版本
- JDK 17
- Android SDK Platform 36
- Android Build Tools 36.0.0（本地可使用兼容的 36.x，正式 CI 固定 36.0.0）
- apktool 2.12.1
- 与 T+ 正式身份对应的 PKCS#12/JKS keystore

不要把密钥、密码或 Base64 私钥内容写入项目文件。签名材料应保存在仓库外，并至少保留一份加密备份。

当前 T+ 正式证书 SHA-256：

```text
0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250
```

## 完整 Compose Host 构建

```powershell
$env:MODERN_SETTINGS_KS_PASS = "<store password>"
$env:MODERN_SETTINGS_KEY_PASS = "<key password>"

python scripts/build_modern_settings_host.py `
  --original original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk `
  --work work/local-release-build `
  --output dist/ComebackGooglePinyinInput-TPlus-arm64-v8a-2.1.0.apk `
  --application-id com.google.android.inputmethod.pinyin.compat.tplus `
  --version-name 2.1.0 `
  --version-code 4520407 `
  --apktool work/tools/apktool.jar `
  --apktool-framework work/apktool-framework `
  --gradle modern-settings/gradlew.bat `
  --sdk <android-sdk> `
  --jdk <jdk-17> `
  --keystore <keystore> `
  --key-alias <alias>
```

用于快速验证 legacy 补丁的 `scripts/build.ps1` 仍然保留，但正式发布必须使用 Compose Host 构建管线。

## 验证门禁

T+ 专项：

```powershell
python scripts/generate_stroke_filter_data.py --check
python scripts/prepare_androidx_autofill_dependency.py
python scripts/verify_tplus.py work/local-release-build/decoded
python scripts/verify_stroke_filter.py work/local-release-build/decoded
```

上游与最终 APK 专项包括：

```text
verify_modern_settings_runtime.py
verify_md3.py
verify_target31.py / verify_target33.py / verify_target34.py
verify_target35.py / verify_target36.py
verify_universal_keyboard_header.py
verify_simplified_traditional_header_toggle.py
verify_candidate_frame_rate.py
verify_symbol_pager_frame_rate.py / verify_symbol_pager_settle.py
verify_scroll_touch_compat.py / verify_keyboard_switch_animation.py
verify_inline_autofill.py / test_header_platform.py
test_sensitive_clipboard_compat.py
verify_stable_resource_ids.py
```

代码变化后至少执行 `git diff --check`、对应专项门禁、Compose 单元测试、从原始 APK 开始的完整重建、最终签名 APK 反解码检查、`apksigner verify --verbose --print-certs` 与 `zipalign -c -P 16 4`。

## GitHub Actions

工作流：[`build-release.yml`](../.github/workflows/build-release.yml)

| 触发方式 | 行为 |
| --- | --- |
| 推送到 `master` | 构建、签名、验证并保存 30 天 Artifact |
| `workflow_dispatch` | 可使用隔离 Application ID 构建审计包，不创建 Release |
| 推送匹配 `version.properties` 的 `tplus-v*` 标签 | 执行全部门禁并创建不可覆盖的正式 Release |

必需 Secrets：

- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_PASSWORD`

必需 Variables：

| 名称 | T+ 正式值 |
| --- | --- |
| `ANDROID_SIGNING_KEY_ALIAS` | `google-pinyin-tplus` |
| `ANDROID_SIGNING_CERT_SHA256` | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |
| `ANDROID_APPLICATION_ID` | `com.google.android.inputmethod.pinyin.compat.tplus` |

## 正式发布步骤

1. 在独立功能/集成分支完成静态门禁、完整构建和模拟器/真机验收。
2. 更新 `version.properties`、`CHANGELOG.md`、README 和 `docs/releases/v$VERSION_NAME.md`。
3. 使用同一证书覆盖安装上一正式 T+，确认用户数据与布局选择保留。
4. 使用 `--no-ff` 合并到 `master`，推送并等待正式 Artifact 通过。
5. 复核包名、版本、target SDK、非 Debug、证书、SHA-256、v1/v2/v3 与 16 KiB ZIP alignment。
6. 创建并推送 annotated Tag：

   ```powershell
   git tag -a tplus-v2.1.0 -m "Comeback Google Pinyin Input T+ 2.1.0"
   git push origin tplus-v2.1.0
   ```

7. Tag workflow 创建新 Release 并上传完整原始文件名的 APK 与 `.sha256`。同名 Release 已存在时必须失败，不得覆盖或改写已发布资产。
8. 从 Release 页面重新下载资产，复核 SHA-256、签名与 alignment 后记录发布完成。

## 发布前检查清单

- [ ] T+ 与 Stroke Filter 静态验证通过。
- [ ] Compose、Header、Inline Autofill、Android 31–36 门禁通过。
- [ ] 最终 APK 可反向解码，稳定资源 ID 保持。
- [ ] v1/v2/v3 签名与 16 KiB ZIP alignment 通过。
- [ ] 证书、包名、版本、target SDK 和 ABI 正确。
- [ ] 可覆盖上一正式 T+，用户数据和布局选择保留。
- [ ] T+ 点按、左右短滑、L/M 长按和普通长按通过。
- [ ] 自动笔画捕获、轨迹、候选过滤和过滤后提交通过。
- [ ] QWERTY、九键、笔画、手写、简繁切换和符号分页通过。
- [ ] 普通/密码输入框切换、电话键盘和 Inline Autofill 通过。
- [ ] README、CHANGELOG 与版本化 Release Notes 同步。
