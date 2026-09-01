# Google 拼音输入法 T+ 自用版

[![构建状态](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml/badge.svg)](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml)
![版本](https://img.shields.io/badge/version-2.1.0-0969da)
![Android](https://img.shields.io/badge/target%20SDK-36-3DDC84?logo=android&logoColor=white)
![架构](https://img.shields.io/badge/ABI-arm64--v8a-555555)

这是基于 [ComebackGooglePinyinInput 2.0.10](https://github.com/huaxianyan/ComebackGooglePinyinInput) 的个人 T+ 分支，在 Google 拼音输入法 4.5.2 上独立重建触宝风格的 **T+ 双字母全键布局**，并保留上游对 Android 15/16、现代设置、统一 Header、Inline Autofill、剪贴板和分页触摸的兼容更新。

> Google 拼音输入法、原始程序、资源、词库、名称和相关商标的权利归 Google LLC、Google Inc. 或其各自权利人所有。本项目与 Google 或 TouchPal（CooTek）没有关联，也未获得其官方背书。

## 下载

正式 APK 从本 fork 的 [GitHub Releases](https://github.com/JunperoH/Tback-google-pinyin-input/releases) 下载，并校验同名 `.sha256` 文件：

```text
ComebackGooglePinyinInput-TPlus-arm64-v8a-2.1.0.apk
```

Release Assets 直接使用完整文件名，不设置显示别名。不需要 T+ 布局的用户可从 [上游 Releases](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases) 下载原版。

T+ 自用版使用独立包名和独立签名证书，可与 Google 原版及上游兼容版同时安装。覆盖升级 T+ 时必须继续使用相同证书，并保持 `versionCode` 单调递增。

## T+ 布局

键位保留 QWERTY 顺序，每个按键容纳两个相邻字母：

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```

| 操作 | 效果 |
| --- | --- |
| 点击双字母键 | 两个字母同时作为候选，由 Google 拼音引擎根据上下文消歧 |
| 向左或向右短滑 | 明确输入键上的第一个或第二个字母 |
| 长按字母键 | 弹出数字、标点及对应小写和大写字母的独立候选 |
| 跨越多个键连续滑动 | 仅在「拼音笔画过滤」关闭时使用 Google 拼音滑行输入 |
| 候选出现后在键盘主体书写 | 开启「拼音笔画过滤」后自动识别横、竖、撇、点/捺和折，并显示主题化轨迹。普通点按和静止长按保持原行为 |

详细实现见 [T+ 移植说明](docs/touchpal-tplus-port.md)、[笔画过滤研究](docs/tplus-stroke-filter-research.md) 和 [执行计划](docs/tplus-stroke-filter-execution-plan.md)。

## 2.1.0 基线更新

### Android 15/16 兼容

- target SDK 提升到 36，继承上游 Android 10–16 的逐级适配与静态门禁。
- 支持 Android 16 covering-IME、三按钮与手势导航区域、edge-to-edge 和动态高刷新率请求。
- 修复未测量手写键盘切换、电话键盘类链接、密码输入框切换高度、拼音组合文本高度和符号分页区域外松手等问题。

### 现代设置与统一 Header

- Android 15/API 35 及以上使用 Compose Material 3 设置。Android 14 及以下保持旧 Preference 设置。
- 原生 Candidate、Clipboard 和 Android 11+ Inline Autofill 由统一 Header Platform 仲裁。
- 系统标记敏感或密码目标中的剪贴板内容仅脱敏显示，点击仍提交原文。
- T+ 与中文 QWERTY、九键和笔画布局都接入原生「简/繁」快捷切换及显示开关。

### T+ 专有能力

- T+ 键盘与全键盘、九键、笔画和手写布局并列。
- Conway 笔顺数据固定为可复现资源，加载失败或会话失效时恢复原候选顺序。
- 开启笔画过滤时仅关闭 T+ 的 Google 拼音跨键滑行输入，不影响其他布局。
- L、M 和双字母键的长按候选采用原生 `softkey_list` 分隔结构，不会把候选标签整串提交。

## 安装与启用

1. 安装 `arm64-v8a` APK。
2. 按系统提示启用「Google 拼音输入法」，并将其设为当前输入法。
3. 在键盘布局选择页选择「拼音 T+ 双字母键盘」。
4. 如需滑行输入，请启用「滑行输入」并关闭「拼音笔画过滤」。
5. 如需笔画过滤，请在「设置 → 输入 → 中文输入」开启「拼音笔画过滤」。

## 兼容性

| 项目 | 值 |
| --- | --- |
| T+ 版本 | `2.1.0` |
| Android `versionCode` | `4520407` |
| 包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 最低 Android | Manifest API 17，ARM64 实际从 API 21 开始 |
| target SDK | 36 |
| CPU 架构 | `arm64-v8a` |
| 上游基线 | `v2.0.10` / `1e8fb927` |
| 原始 APK | Google 拼音 4.5.2.193126728 |
| 签名 SHA-256 | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |

已知边界：

- 只提供 `arm64-v8a` 构建。
- TalkBack touch exploration 下的 Inline Suggestions 尚未声明支持，系统使用自身回退路径。
- Android 17/API 37、Predictive Back 和强制 16 KiB native page-size 运行时验收仍是后续工作。
- 自动笔画模式下，较长的键内左右短滑会优先识别为横笔。

## 开发与验证

项目从固定原始 APK 可复现地应用资源和 Smali 补丁：

```text
original/        已校验的 Google 拼音 4.5.2 arm64-v8a 原始 APK
patches/         T+、Stroke Filter、Header 与兼容资源
modern-settings/ API 35+ Compose Material 3 设置运行时
scripts/         补丁、构建和静态验证脚本
docs/            设计、研究、验收和发布记录
```

- [构建与发布指南](docs/build-and-release.md)
- [变更日志](CHANGELOG.md)
- [Header Platform 架构](docs/header-platform-design.md)
- [现代设置运行时设计](docs/modern-settings-runtime-design.md)
- [上游 2.0.10 更新调查](docs/upstream-main-update-2026-09-01.md)

## 许可证与权利范围

项目维护者拥有或有权许可、且在 [`NOTICE`](NOTICE) 中明确列出的原创代码、脚本和文档，自许可证声明公开之日起采用 [Mozilla Public License 2.0](LICENSE)。

根目录许可证不适用于整个仓库的所有内容。Google 拼音输入法原 APK、Google 原始或派生代码、Smali、资源、词库、模型、图片、名称和商标，以及 AndroidX、Compose、Gradle、Conway 笔顺数据等第三方内容继续受各自权利和许可约束。Conway 数据的使用边界见 [数据来源说明](docs/stroke-filter-data-attribution.md)。
