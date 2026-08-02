# Google 拼音输入法 T+ 自用版

[![构建状态](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml/badge.svg)](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml)
![版本](https://img.shields.io/badge/version-1.1.0-0969da)
![Android](https://img.shields.io/badge/Android-17%2B-3DDC84?logo=android&logoColor=white)
![架构](https://img.shields.io/badge/ABI-arm64--v8a-555555)

基于 [`huaxianyan/comeback-google-pinyin-input`](https://github.com/huaxianyan/comeback-google-pinyin-input) 的个人 fork，在 Google 拼音输入法 4.5.2 兼容版本之上，独立重建触宝风格的 **T+ 全键双字母布局**。

T+ 是新增的可选中文键盘，不会覆盖原有的全键盘、九键、笔画和手写布局。本项目不包含触宝代码、词库、图片、原生库或其他程序资源。

> [!IMPORTANT]
> 当前 T+ 版本为 `1.1.0`，发布标签使用 `tplus-v1.1.0`。仓库继承的历史标签 `v1.0.0` 属于上游兼容版，不是 T+ 自用版。

## 目录

- [下载](#下载)
- [T+ 布局与操作](#t-布局与操作)
- [主要功能](#主要功能)
- [安装与启用](#安装与启用)
- [版本与兼容性](#版本与兼容性)
- [用户词典备份](#用户词典备份)
- [从源码构建](#从源码构建)
- [项目文档](#项目文档)
- [来源与法律声明](#来源与法律声明)

## 下载

请从本 fork 的 [GitHub Releases](https://github.com/JunperoH/Tback-google-pinyin-input/releases) 下载文件名如下的 APK：

```text
ComebackGooglePinyinInput-TPlus-arm64-v8a-1.1.0.apk
```

下载后请同时校验 Release 附带的 `.sha256` 文件。Assets 直接使用完整文件名，不设置额外显示别名；不要将历史 `v1.0.0` 误认为 T+ 版本。

不需要 T+ 布局时，可从[上游 Releases](https://github.com/huaxianyan/comeback-google-pinyin-input/releases) 获取原兼容版。

## T+ 布局与操作

键位保持 QWERTY 的空间顺序，每个主键容纳两个相邻字母：

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```

| 操作 | 行为 |
| --- | --- |
| 点击双字母键 | 将两个字母作为等权备选送入 Google 拼音 HMM，由拼音和上下文消歧 |
| 短距离向左或向右滑动 | 明确选择键上的第一个或第二个字母 |
| 长按字母键 | 弹出数字/标点及对应小写、大写字母的有序多候选菜单 |
| 跨越多个键连续滑动 | 仅当“拼音笔画过滤”关闭时使用 Google 拼音滑行输入；在 T+ 中开启笔画过滤会关闭滑行输入 |
| 候选出现后在键盘主体书写 | 开启“拼音笔画过滤”后自动识别越过触摸阈值的横、竖、撇、点/捺、折；普通点按和静止长按仍走原 Basic handler，“笔”用于暂停/恢复 |

实现原理、APK 审计和独立重建边界见 [T+ 移植说明](docs/touchpal-tplus-port.md)。

## 主要功能

### T+ 输入

- 与全键盘、九键、笔画和手写并列显示，可随时切换。
- 覆盖 26 个英文字母，并保留左右滑动单字母输入。
- 支持数字、常用标点长按气泡和松手提交。
- 复用 Google 拼音原生候选栏、用户词典、上下文预测与手势解码管线。
- 可在设置中开启默认关闭的“拼音笔画过滤”；当前布局为 T+ 且已有候选时自动旁观轨迹，越过系统触摸阈值后识别笔画并显示主题化痕迹。普通点按和静止长按保留；较长左右短滑会优先成为横笔。
- Conway 笔顺数据固定到可复现版本；加载失败、缓存保护或世代失效时 fail-open，恢复原拼音候选顺序。

### 现代 Android 兼容

- 修复 Android 16 手写首笔崩溃，保留原有压感宽度、路径平滑和识别流程。
- 修复候选、标点、符号及表情列表滚动后的误点击和分页手势问题。
- 增加剪贴板候选，并保持原生主题、关闭按钮和完整文本提交行为。
- 交由 Android 的 LTPO/ARR 机制调度刷新率，不再持续请求固定 120 Hz。
- 补全现代 Android 所需的关键 `android:exported` 声明。

### 本地数据与隐私

- 加固用户词典落盘、滚动备份、中断恢复和并发保存。
- 支持内部存储、SD 卡及兼容 DocumentsProvider 的云端目录备份。
- 支持可配置备份周期、保留版本、立即备份和手动导入。
- 移除失效的 Clearcut/Primes、Firebase、反馈上传、在线词典更新及旧 Google 账户词典同步链路。
- 云端文件操作仅通过用户主动授权的 Android Storage Access Framework 完成。

完整兼容改动见 [兼容性说明](docs/compatibility-notes.md) 和 [变更日志](CHANGELOG.md)。

## 安装与启用

1. 下载并安装 `arm64-v8a` APK。
2. 打开应用，按照系统提示启用“Google 拼音输入法”。
3. 将其设为当前输入法。
4. 在键盘布局选择页面选择“拼音 T+ 双字母键盘”。
5. 如需连续滑动，在输入法设置中启用“滑行输入”，并保持“拼音笔画过滤”关闭。
6. 如需拼音笔画过滤，在“设置 → 输入 → 中文输入”开启“拼音笔画过滤”；T+ 滑行输入会随即关闭。输入拼音出现候选后，直接在键盘主体书写。

T+ 自用版使用独立包名和独立签名证书，可与 Google 原版及上游兼容版同时安装。覆盖升级必须继续使用相同证书；它不能覆盖由 Google 或上游证书签名的应用。

## 版本与兼容性

| 项目 | 当前值 |
| --- | --- |
| T+ 版本 | `1.1.0` |
| Android `versionCode` | `4520406` |
| 应用包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 最低 Android API | 17 |
| 目标 Android API | 28 |
| CPU 架构 | `arm64-v8a` |
| 原始基础版本 | Google 拼音输入法 `4.5.2.193126728` |
| 签名证书 SHA-256 | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |

### 已验证

- apktool 2.12.1 完整解码、补丁、重建和签名 APK 反向解码校验通过。
- ZIP 对齐以及 APK v1、v2、v3 签名校验通过。
- Android 14 / API 34 / 4 KB 页大小模拟器覆盖安装通过。
- `1.1.0 / code 4520406` 在 4KB/API34 模拟器确认：自动状态下普通点按与静止长按保留；不点“笔”横划时轨迹即时可见、抬手后候选按横笔过滤，且无 ART/Verify 错误。
- `si + 笔画前缀 3` 的原生候选迭代器可扫描到“偲”；候选点击与空格复用原 payload 提交路径。
- T+ 数字/标点与大小写长按菜单、候选筛选数据、会话世代保护和整包 apktool 重建通过自动验证。

### 已知限制

- 当前仅提供 `arm64-v8a` 构建。
- Google 拼音 4.5.2 的旧原生库按 4 KB 页对齐，无法在强制 16 KB 页大小的 Android 系统镜像中加载。
- T+ 双字母在手势模型中共享同一几何区域，首选排序不一定达到触宝原生引擎的水平。例如测试轨迹可能先给出 `bu hao`，再给出 `ni hao`。
- API 34 模拟器上的旧首启 Activity 存在布局兼容问题；核心输入法可在预先完成启用/布局选择后正常运行。用户已报告真机基本输入可用，但仍建议保留可回滚版本。
- 本项目不移植触宝的云服务、社交学习、专有纠错模型或原生库。

触宝与 Google 拼音的纠错、联想和 T+ 排序对比见 [纠错与联想分析](docs/touchpal-vs-google-correction.md)。

## 用户词典备份

在“设置 → 字典”中选择“备份和导入位置”后，自动备份、立即备份、版本轮换和内置导入将共用该目录。目录可以位于内部存储、SD 卡，或支持创建、读写、重命名和删除的云端 DocumentsProvider。

恢复步骤：

1. 安装并启用输入法。
2. 打开“设置 → 字典”。
3. 重新选择原备份目录。
4. 点击“导入用户词典备份”，选择所需版本并确认。

导入沿用 Google 拼音原生合并/更新语义，不会自动覆盖或回滚当前词典。详细设计见 [用户词典自动备份](docs/dictionary-auto-backup-design.md) 和 [词典健康状态](docs/dictionary-health-status-design.md)。

## 从源码构建

### 环境要求

- Java 11 或更高版本
- Python 3
- apktool 2.12.1
- uber-apk-signer 1.3.0，或 Android SDK 的 `apksigner`、`zipalign`
- PKCS#12/JKS 签名证书

PowerShell 示例：

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

静态验证：

```powershell
python scripts/verify_tplus.py work/decoded
```

签名、GitHub Actions 和正式发布流程见 [构建与发布指南](docs/build-and-release.md)。

## 仓库结构

```text
original/     用于可复现构建的原始官方 APK
patches/      资源、Java 辅助代码和 smali 补丁
scripts/      补丁、构建与 T+ 静态验证脚本
docs/         设计、研究、兼容与测试记录
```

## 项目文档

- [T+ 布局移植说明](docs/touchpal-tplus-port.md)
- [触宝与 Google 拼音纠错/联想对比](docs/touchpal-vs-google-correction.md)
- [兼容性说明](docs/compatibility-notes.md)
- [用户词典自动备份设计](docs/dictionary-auto-backup-design.md)
- [用户词典健康状态设计](docs/dictionary-health-status-design.md)
- [构建与发布指南](docs/build-and-release.md)
- [变更日志](CHANGELOG.md)

## 来源与法律声明

- Google Pinyin Input、Google 拼音输入法、Google 名称、标志、原始程序、资源、词库及相关商标的权利归 Google LLC、Google Inc. 或其各自权利人所有。
- 本项目维护者不代表、不隶属于且未获得 Google 或 TouchPal/CooTek 的官方背书。
- 原始 APK 仅用于软件保存、兼容性研究和可复现构建；其 SHA-256 为 `980fd0f4695f683648e6f7ab9a15a24732e8957b5b14b25d49af931176574bd7`。
- 本项目中的 T+ 实现是对公开交互方式的独立重建，不复制触宝代码、图片、词库、原生库或打包资源。
- 本项目以个人、非商业的软件保存和互操作性研究为目的提供，不收费、不接入广告，也不以相关品牌或原始程序牟利。
- 使用者应自行确认并遵守所在地法律、原软件许可及相关权利要求。

如发现构建、兼容或权利归属问题，请通过 [GitHub Issues](https://github.com/JunperoH/Tback-google-pinyin-input/issues) 提交说明。
