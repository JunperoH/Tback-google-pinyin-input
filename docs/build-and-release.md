# 构建与发布指南

本文面向维护者，说明如何从原始 Google 拼音 APK 可复现地构建、签名和发布 T+ 自用版。普通使用者只需从 GitHub Releases 下载 APK，无需配置本页内容。

## 版本身份

| 项目 | 当前值 |
| --- | --- |
| Android `versionName` | `1.0.0` |
| Android `versionCode` | `4520403` |
| 应用包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| Release 标签 | `tplus-v1.0.0` |
| APK 文件名 | `ComebackGooglePinyinInput-TPlus-arm64-v8a-1.0.0.apk` |

`versionCode` 必须始终递增，即使重新整理了对外版本号，也不能降低该值，否则 Android 会拒绝覆盖安装。T+ Release 使用 `tplus-v*` 标签，避免与继承自上游的历史 `v1.0.0` 冲突。

## 本地构建

### 环境要求

- Java 11 或更高版本
- Python 3
- apktool 2.12.1
- uber-apk-signer 1.3.0，或 Android SDK Build Tools
- PKCS#12/JKS 签名证书

### 构建命令

```powershell
./scripts/build.ps1 `
  -ApkPath ./original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk `
  -ApktoolJar ./tools/apktool.jar `
  -SignerJar ./tools/uber-apk-signer.jar `
  -Keystore ./signing.p12 `
  -KeyAlias your-key-alias `
  -StorePassword 'your-store-password' `
  -KeyPassword 'your-key-password'
```

构建脚本依次执行：

1. 解码原始 APK。
2. 应用资源、Manifest 和 smali 补丁。
3. 修改独立包名和版本身份。
4. 重建、对齐并签名 APK。

### 静态验证

```powershell
python scripts/verify_tplus.py work/decoded
```

验证内容包括 26 字母覆盖、键位顺序、左右滑动、长按动作、IME 注册、T+/T9 解码分支以及双字母手势几何注入。

## 签名管理

Android 覆盖升级取决于签名证书身份，而不是 APK 文件名。后续所有正式版本必须继续使用第一次 T+ 构建所用的私钥。

> [!CAUTION]
> 不要把 `.p12`、`.jks`、密码、Base64 私钥内容或 `signing-info.txt` 提交到 Git。`work/` 已被忽略，但仍应在仓库之外保留至少一份加密备份。

建议将签名材料备份到以下任一位置：

- 加密密码管理器的文件附件；
- 加密移动硬盘或 U 盘；
- 启用端到端加密的私有云保险库。

备份应与开发目录分离，并记录证书指纹、alias 和恢复步骤。不要只保留在 `work/signing/`。

当前正式证书的 SHA-256 指纹：

```text
0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250
```

## GitHub Actions

工作流文件：[`build-release.yml`](../.github/workflows/build-release.yml)

| 触发方式 | 行为 |
| --- | --- |
| 推送到 `master` | 构建、签名、校验并保存 30 天 artifact |
| 手动运行 `workflow_dispatch` | 构建测试，不创建 Release |
| 推送 `tplus-v*` 标签 | 构建并创建或更新正式 GitHub Release |

### Actions Secrets

| 名称 | 内容 |
| --- | --- |
| `ANDROID_SIGNING_KEYSTORE_BASE64` | 正式 keystore 的完整 Base64 |
| `ANDROID_SIGNING_STORE_PASSWORD` | keystore 密码 |
| `ANDROID_SIGNING_KEY_PASSWORD` | 私钥密码 |

### Actions Variables

| 名称 | 值 |
| --- | --- |
| `ANDROID_SIGNING_KEY_ALIAS` | `google-pinyin-tplus` |
| `ANDROID_SIGNING_CERT_SHA256` | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |
| `ANDROID_APPLICATION_ID` | `com.google.android.inputmethod.pinyin.compat.tplus` |

工作流会在构建前校验原始 APK、apktool、签名工具和签名证书指纹；任何不一致都会终止发布。

## 使用 GitHub CLI 配置

先登录并进入仓库目录：

```powershell
gh auth login
```

将 keystore 直接转换并上传到 Secret，不在仓库生成 Base64 文件：

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("work/signing/tplus-local.p12")
) | gh secret set ANDROID_SIGNING_KEYSTORE_BASE64
```

密码使用交互式输入：

```powershell
gh secret set ANDROID_SIGNING_STORE_PASSWORD
gh secret set ANDROID_SIGNING_KEY_PASSWORD
```

设置非敏感变量：

```powershell
gh variable set ANDROID_SIGNING_KEY_ALIAS --body "google-pinyin-tplus"
gh variable set ANDROID_SIGNING_CERT_SHA256 --body "0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250"
gh variable set ANDROID_APPLICATION_ID --body "com.google.android.inputmethod.pinyin.compat.tplus"
```

## 正式发布流程

1. 更新 `scripts/apply_patches.py` 中的 `versionName` 和递增后的 `versionCode`。
2. 同步更新 README、CHANGELOG 和工作流中的 APK 文件名、期望版本及 Release 标题。
3. 在本地或 `workflow_dispatch` 中完成构建验证。
4. 使用相同证书覆盖安装上一版，确认用户数据和布局选择得到保留。
5. 合并准备发布的提交。
6. 创建并推送 T+ 专用标签：

```powershell
git tag -a tplus-v1.0.0 -m "Comeback Google Pinyin Input T+ 1.0.0"
git push origin tplus-v1.0.0
```

标签推送后，GitHub Actions 会创建 Release 并上传 APK 与 `.sha256`。无需在本地手动上传签名产物。

## 发布前检查清单

- [ ] T+ 静态验证通过。
- [ ] apktool 完整重建通过。
- [ ] 最终签名 APK 可反向解码。
- [ ] ZIP 对齐通过。
- [ ] APK v1、v2、v3 签名通过。
- [ ] 证书 SHA-256 与正式指纹一致。
- [ ] 包名、`versionName`、`versionCode` 和 ABI 正确。
- [ ] 可覆盖安装上一正式版。
- [ ] T+、全键盘和九键仍可切换。
- [ ] 长按、短滑、跨键滑动、候选选择和退格通过。
- [ ] README、CHANGELOG 和 Release Notes 已同步。
