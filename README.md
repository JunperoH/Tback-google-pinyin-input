# Google 拼音输入法 T+ 自用版

[![构建状态](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml/badge.svg)](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml)
![版本](https://img.shields.io/badge/version-1.1.0-0969da)
![Android](https://img.shields.io/badge/Android-17%2B-3DDC84?logo=android&logoColor=white)
![架构](https://img.shields.io/badge/ABI-arm64--v8a-555555)

本项目是基于 [huaxianyan/comeback-google-pinyin-input](https://github.com/huaxianyan/comeback-google-pinyin-input) 的个人分支，在 Google 拼音输入法 4.5.2 上独立重建了触宝风格的 **T+ 双字母全键布局**。T+ 是可选中文键盘，不影响原有的全键盘、九键、笔画和手写输入。

> **重要**：当前 T+ 版本为 `1.1.0`，发布标签为 `tplus-v1.1.0`。请勿与历史 `v1.0.0` 混淆，后者属于上游兼容版，不含 T+。

---

## 下载

从本 fork 的 [Releases](https://github.com/JunperoH/Tback-google-pinyin-input/releases) 下载以下 APK，并校验同名 `.sha256` 文件：

```text
ComebackGooglePinyinInput-TPlus-arm64-v8a-1.1.0.apk
```

Release Assets 直接使用完整文件名，不设置额外显示别名。不需要 T+ 布局的用户可前往[上游 Releases](https://github.com/huaxianyan/comeback-google-pinyin-input/releases) 获取原版。

---

## T+ 布局简介

键位保留 QWERTY 顺序，每个按键容纳两个相邻字母：

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```

| 操作 | 效果 |
| --- | --- |
| 点击双字母键 | 两个字母同时作为候选，由 Google 拼音引擎根据上下文消歧 |
| 向左/右短滑 | 明确输入键上的第一个或第二个字母 |
| 长按字母键 | 弹出数字/标点及对应小写、大写字母的有序多候选菜单 |
| 跨越多个键连续滑动 | 仅在“拼音笔画过滤”关闭时使用 Google 拼音滑行输入 |
| 候选出现后在键盘主体书写 | 开启“拼音笔画过滤”后自动识别越过触摸阈值的横、竖、撇、点/捺、折；普通点按和静止长按不受影响，“笔”按钮用于暂停或恢复 |

> 详细技术实现见 [T+ 移植说明](docs/touchpal-tplus-port.md)和[笔画过滤研究](docs/tplus-stroke-filter-research.md)。

---

## 主要功能

- **T+ 键盘**：与系统原生键盘并列，覆盖 26 个英文字母并保留左右短滑。
- **拼音笔画过滤**：候选出现后可直接在键盘主体书写笔画，显示主题化轨迹；开启时只对 T+ 关闭滑行输入。
- **可复现候选过滤**：Conway 笔顺数据固定到可复现版本；加载失败或状态失效时恢复原拼音候选顺序。
- **现代 Android 兼容**：修复 Android 16 手写崩溃、候选列表误触、刷新率调度等问题。
- **隐私保护**：移除 Google 分析、在线词库同步、反馈上传等网络链路；备份仅通过用户授权的 Storage Access Framework 进行。
- **本地词典备份**：支持自动备份、手动导入/导出到内部存储、SD 卡或云盘（需 DocumentsProvider 支持）。

完整改动可查看[兼容性说明](docs/compatibility-notes.md)和[变更日志](CHANGELOG.md)。

---

## 安装与启用

1. 下载并安装 `arm64-v8a` APK。
2. 按系统提示启用“Google 拼音输入法”，并将其设为当前输入法。
3. 在键盘布局选择页面选择“拼音 T+ 双字母键盘”。
4. 如需滑行输入，请启用“滑行输入”并保持“拼音笔画过滤”关闭。
5. 如需笔画过滤，请在“设置 → 输入 → 中文输入”开启“拼音笔画过滤”；输入拼音出现候选后即可直接书写笔画。

T+ 自用版使用独立包名和独立签名证书，可与 Google 原版及上游兼容版同时安装。覆盖升级必须使用相同证书。

---

## 兼容性

| 项目 | 值 |
| --- | --- |
| T+ 版本 | `1.1.0` |
| Android `versionCode` | `4520406` |
| 包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 最低 Android | 17（Android 4.2） |
| 目标 SDK | 28（Android 9） |
| CPU 架构 | `arm64-v8a` |
| 基础版本 | Google 拼音 4.5.2.193126728 |
| 签名 SHA-256 | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |

**已验证**：

- apktool 2.12.1 完整解码、补丁、重建及签名 APK 反向解码检查通过。
- ZIP 对齐及 APK v1、v2、v3 签名校验通过。
- Android 14 / API 34 / 4 KB 页大小模拟器覆盖安装通过。
- `1.1.0 / code 4520406` 已验证普通点按、静止长按、自动笔画捕获、主题化轨迹和候选过滤，无 ART/Verify 错误。
- T+ 多候选长按、候选筛选数据、会话状态保护和整包可复现重建通过自动检查。

**已知限制**：

- 仅提供 `arm64-v8a` 构建。
- 旧原生库无法在强制 16 KB 页大小的系统上加载。
- 自动笔画模式下，较长的键内左右短滑会优先识别为横笔。
- T+ 双字母在手势模型中共享几何区域，滑行输入的候选排序可能不完美。

---

## 文档与构建

- [T+ 移植说明](docs/touchpal-tplus-port.md)
- [笔画过滤研究方案](docs/tplus-stroke-filter-research.md)
- [笔画过滤执行计划](docs/tplus-stroke-filter-execution-plan.md)
- [兼容性说明](docs/compatibility-notes.md)
- [用户词典备份设计](docs/dictionary-auto-backup-design.md)
- [构建与发布指南](docs/build-and-release.md)
- [变更日志](CHANGELOG.md)

---

## 法律声明

- Google 拼音输入法及其相关资源归属 Google LLC。
- 本项目与 Google 或 TouchPal（CooTek）无任何关联或背书。
- 原始 APK 仅用于软件保存与研究，其 SHA-256 为 `980fd0f4695f683648e6f7ab9a15a24732e8957b5b14b25d49af931176574bd7`。
- T+ 实现为独立重建，不复制触宝代码、词库或原生库。
- Conway 笔顺数据依照 CC BY 4.0 使用，详见[数据来源说明](docs/stroke-filter-data-attribution.md)。
- 本项目为个人非商业用途，不收费、无广告。使用者应遵守当地法律及原软件许可。
