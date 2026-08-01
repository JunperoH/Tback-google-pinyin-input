# Google 拼音输入法 T+ 自用版

**English project name: Comeback Google Pinyin Input**

这是 [`huaxianyan/comeback-google-pinyin-input`](https://github.com/huaxianyan/comeback-google-pinyin-input) 的个人 fork，在其 Google 拼音输入法 4.5.2 兼容补丁之上增加触宝式 T+ 双字母布局。目标是在保持原生候选逻辑、词库格式和主题行为的前提下，以可复现、可审计的方式恢复这一输入体验。

## T+ 自用分支

本 fork 在上游兼容维护版本之上新增“拼音 T+ 双字母键盘”，作为与原有全键盘、九键、笔画和手写并列的可选中文输入布局。键位保持 QWERTY 空间顺序：

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```

点击双字母键会把两个字母作为等权备选送入 Google 拼音原生 HMM 引擎，由拼音和词句上下文消歧；短距离向左或向右滑动可明确选择键上的第一个或第二个字母，长按会弹出并输入键面右上角的数字或符号。开启“滑行输入”后，还可跨越多个 T+ 键连续滑动，由 Google 拼音原生手势 HMM 根据轨迹与拼音上下文解码。实现、APK 来源校验和已知限制见 [`docs/touchpal-tplus-port.md`](docs/touchpal-tplus-port.md)。本仓库不包含触宝 APK、图片或其他触宝程序资源。

触宝 5.7.9 与本项目所用 Google 拼音 4.5.2 的纠错、联想和 T+ 排序差异，以及后续 A/B 测试方案，见 [`docs/touchpal-vs-google-correction.md`](docs/touchpal-vs-google-correction.md)。

## 下载

T+ 自用版构建请从本 fork 的 [Releases](https://github.com/JunperoH/comeback-google-pinyin-input/releases) 页面下载。Android 应用内、输入法选择器、设置页和 Launcher 中的显示名称仍保持为“Google 拼音输入法”。上游不带 T+ 的兼容版仍从[上游 Releases](https://github.com/huaxianyan/comeback-google-pinyin-input/releases) 获取。

仓库同时保存用于复现构建的原始官方 APK：

[`original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk`](original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk)

## 版本信息

### 原始版本

| 项目 | 内容 |
| --- | --- |
| 产品名称 | Google Pinyin Input / Google 拼音输入法 |
| 原始版本 | `4.5.2.193126728` |
| 原始包名 | `com.google.android.inputmethod.pinyin` |
| 架构 | `arm64-v8a` |
| 原始 target SDK | 26 |
| 原始 APK SHA-256 | `980fd0f4695f683648e6f7ab9a15a24732e8957b5b14b25d49af931176574bd7` |
| 签名主体 | `OU=Google, Inc, O=Google, Inc, L=Mountain View, ST=CA, C=US` |
| 签名证书 SHA-256 | `3D:7A:12:23:01:9A:A3:9D:9E:A0:E3:43:6A:B7:C0:89:6B:FB:4F:B6:79:F4:DE:5F:E7:C2:3F:32:6C:8F:99:4A` |

Google 拼音输入法最初由 Google 发布并通过 Google Play 等官方 Android 分发渠道提供。本仓库中的原始 APK 用于软件保存、兼容性研究和可复现构建，其文件哈希与签名信息列于上表，便于独立校验来源和完整性。

### 当前 T+ 版本

| 项目 | 内容 |
| --- | --- |
| 项目中文名称 | Google 拼音输入法 T+ 自用版 |
| English project name | Comeback Google Pinyin Input |
| 项目版本 | `1.0.0` |
| Android versionName | `1.0.0` |
| Android versionCode | `4520403`（保持递增，可覆盖安装测试版） |
| 包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 架构 | `arm64-v8a` |
| APK | `ComebackGooglePinyinInput-TPlus-arm64-v8a-1.0.0.apk` |
| target SDK | 28 |
| 验证状态 | apktool 2.12.1 完整重建通过；Android 14（API 34、4 KB 页）模拟器安装与输入闭环通过；待真机手感验收 |

`1.0.0` 是本 fork 重新整理版本线后的首个正式版本，继承上游 `v1.0.3` 的兼容、词典备份和失效服务清理，并包含 T+ 布局、长按气泡与连续滑行输入。此前的 `1.1.0-tplus.1/.2` 仅视为发布前测试版本。是否发布以本 fork 的 GitHub Release 和 `CHANGELOG.md` 为准。

T+ 自用版使用独立包名和独立签名证书，可以与 Google 原版及上游兼容版同时安装。以后升级时必须继续使用同一签名证书；它不能覆盖由 Google 或上游证书签名的应用。

## 主要兼容改进

- 修复 Android 16 手写首笔因旧 `Canvas.clipRect(..., Region.Op.REPLACE)` 导致的崩溃。
- 保持原有 `ALPHA_8` 离屏手写画布、压感宽度、路径平滑和原生识别流程。
- 修复候选、标点、符号和表情列表滚动后外层键盘错误触发点击的问题。
- 修复全键盘符号/表情分页中失效的滑动距离门槛，同时保留原有翻页、吸附和动画参数。
- 增加与原生候选管线融合的剪贴板候选、主题化剪贴板图标和原生关闭控制，点击后提交完整剪贴板文本。
- 根据实际键盘主题表面调整 Android 导航栏颜色和明暗图标。
- 移除持续固定 120 Hz 的旧兼容请求，由 Android 的 LTPO/ARR 调度刷新率。
- 将首次使用引导整理为“启用 → 选择输入法 → 完成”，使用明确的上一步/下一步导航。
- 加固用户词典持久化：滚动 `_bak`、中断 `_tmp` 恢复、失败主文件隔离、进程级保存锁和显式清理保护。
- 增加用户词典自动备份，可选择内部存储、SD 卡或支持读写的云端文档目录；备份与手动导入共用该位置。
- 支持 1/3/7/14/30 天备份间隔、3/5/10/20/30 个保留版本、立即备份和手动导入。
- 在进入词典设置页后按需显示中英文词条数、主文件、滚动副本、恢复旁路和最近落盘时间；应用及键盘启动时不扫描。
- 备份使用 Google 拼音原生 UTF-16LE 用户词典导出/导入格式；应用自身不实现云同步或自动恢复，云端 I/O 由用户选择的 DocumentsProvider 管理。
- 清理失效的 Clearcut/Primes、Firebase、反馈上传、在线词典更新及旧 Google 账户词典同步组件；Google Drive 备份只使用系统 SAF 目录授权。
- 补全现代 Android 要求的关键 `android:exported` 声明。

更完整的实现记录、Gboard 对照研究和测试结论位于 [`docs/`](docs/) 与 [`CHANGELOG.md`](CHANGELOG.md)。

## 用户词典灾难恢复

在“设置 → 字典”中选择“备份和导入位置”后，自动备份、立即备份、版本轮换和内置手动导入都会使用同一个用户授权目录。目录可位于内部存储、SD 卡或 Google Drive 等支持创建、读写、重命名和删除文档的云端位置。设备存储中的公共文件不会因清除应用数据或卸载创造性 AI 版而被删除；云端文件的同步、离线能力和保留规则由对应存储服务管理。

恢复步骤：

1. 安装创造性 AI 版并启用输入法。
2. 打开“设置 → 字典”。
3. 点击“导入用户词典备份”；新安装尚无目录授权时，重新选择原来的备份目录。
4. 从内置列表选择所需备份并确认导入。

导入采用原生合并/更新语义，不会自动覆盖或回滚当前词典。也可以在文件管理器中打开或分享备份 `.txt` 到 Google 拼音。

## 仓库结构

```text
original/
  google-pinyin-input-4.5.2.193126728-arm64-v8a.apk  原始官方安装包
patches/
  java/                                               兼容辅助代码源码
  smali/                                              构建时注入的 smali
  res/                                                兼容资源
scripts/
  apply_patches.py                                    可复现补丁流程
  build.ps1                                           Windows 构建脚本
  verify_tplus.py                                     T+ 键位与注入静态校验
docs/                                                 调查、设计与测试记录
CHANGELOG.md                                          版本变更记录
```

## 构建

所需工具：

- Java 11+
- Python 3
- apktool 2.12.1
- uber-apk-signer 1.3.0，或 Android SDK 的 `apksigner`/`zipalign`
- PKCS#12/JKS 签名证书

PowerShell 示例：

```powershell
./scripts/build.ps1 `
  -ApkPath ./original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk `
  -ApktoolJar ./tools/apktool.jar `
  -SignerJar ./tools/uber-apk-signer.jar `
  -Keystore ./signing.p12 `
  -KeyAlias google-pinyin-local `
  -StorePassword 'your-password' `
  -KeyPassword 'your-password'
```

补丁脚本会从原始 APK 解码、应用资源及 smali 改动、修改为独立包名，然后重建、对齐并签名。

可单独检查 T+ 的 26 字母覆盖、键位顺序、滑动映射和注入结果；传入已打补丁的 apktool 目录时还会检查 IME 注册和 smali 分支：

```powershell
python scripts/verify_tplus.py work/decoded
```

## GitHub Actions 自动构建与发布

工作流位于 [`.github/workflows/build-release.yml`](.github/workflows/build-release.yml)：

- 推送到 `master`：构建、签名、校验 APK，并保存 30 天的 Actions artifact；
- 推送 `tplus-v*` 标签：执行相同构建，然后创建正式 GitHub Release 并上传 APK 与 `.sha256`；T+ 专用前缀用于避开上游已存在的历史标签；
- `workflow_dispatch`：可从 Actions 页面手动构建，不自动发布 Release。

### 签名一致性

Android 是否允许覆盖升级取决于**签名证书身份**，而不是 APK 文件名。本 fork 的自动构建必须始终使用第一次 T+ 构建所用的 PKCS#12/JKS 私钥。私钥和密码不能写进仓库或普通 Actions Variables，应存入 GitHub Actions **Secrets**；本机副本位于 Git 忽略的 `work/signing/`，需要另外安全备份。

| GitHub Secret | 内容 |
| --- | --- |
| `ANDROID_SIGNING_KEYSTORE_BASE64` | 正式 `.p12` 文件的完整 Base64 |
| `ANDROID_SIGNING_STORE_PASSWORD` | keystore 密码 |
| `ANDROID_SIGNING_KEY_PASSWORD` | 私钥密码 |

以下非敏感配置写入 GitHub Actions **Variables**：

| GitHub Variable | 正式值 |
| --- | --- |
| `ANDROID_SIGNING_KEY_ALIAS` | `google-pinyin-tplus` |
| `ANDROID_SIGNING_CERT_SHA256` | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |
| `ANDROID_APPLICATION_ID` | `com.google.android.inputmethod.pinyin.compat.tplus` |

工作流在构建前使用 `keytool` 读取恢复出的证书指纹，并与 `ANDROID_SIGNING_CERT_SHA256` 比较。证书不一致、密码错误、alias 错误或任何配置缺失都会立即终止，因此不会误发一个无法覆盖升级的 APK。原始 APK、apktool 和签名工具也分别执行固定 SHA-256 校验。

### 使用 GitHub CLI 配置仓库

先登录并进入仓库目录：

```powershell
gh auth login
```

将 keystore 转为 Base64 后直接送入 Secret；Base64 不会写入仓库文件：

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("work/signing/tplus-local.p12")
) | gh secret set ANDROID_SIGNING_KEYSTORE_BASE64
```

密码使用交互式输入，避免出现在终端历史中：

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

配置后可在 GitHub 的 **Actions → Build and release APK → Run workflow** 手动验证一次。确认 artifact 能安装并覆盖上一版 T+ 自用版后，以新版本提交创建标签：

```powershell
git tag -a tplus-v1.0.0 -m "Comeback Google Pinyin Input T+ 1.0.0"
git push origin tplus-v1.0.0
```

标签推送后无需在本地构建或上传 APK。`GITHUB_TOKEN` 由 Actions 自动提供，只授予工作流创建 Release 所需的 `contents: write` 权限。

## 来源、版权与非商业声明

- **Google Pinyin Input、Google 拼音输入法、Google 名称、标志、原始程序、资源、词库和相关商标的版权及其他权利归 Google LLC、Google Inc. 或其各自权利人所有。**
- 本项目维护者不拥有 Google 原始软件及商标，也不代表、不隶属于且未获得 Google 官方背书。
- 本项目中的兼容补丁、研究记录和构建脚本由项目贡献者以个人、非商业的软件保存、互操作性研究和旧设备兼容维护为目的提供。
- 原始 APK 保持其原有版权状态；兼容构建不会改变原始作品的权利归属。使用者应遵守所在地法律、原软件条款及相关权利要求。
- 本项目不收费，不出售应用，不接入广告，也不以 Google 品牌或原始程序牟利。
- 如相关权利人认为仓库内容需要调整，可通过 GitHub Issues 或仓库所有者联系方式提出说明。
