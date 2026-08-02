# Google 拼音输入法 T+ 自用版

[![构建状态](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml/badge.svg)](https://github.com/JunperoH/Tback-google-pinyin-input/actions/workflows/build-release.yml)
![版本](https://img.shields.io/badge/version-1.0.0-0969da)
![Android](https://img.shields.io/badge/Android-17%2B-3DDC84?logo=android&logoColor=white)
![架构](https://img.shields.io/badge/ABI-arm64--v8a-555555)

本项目是基于 [huaxianyan/comeback-google-pinyin-input](https://github.com/huaxianyan/comeback-google-pinyin-input) 的个人分支，在 Google 拼音输入法 4.5.2 上**独立重建了触宝风格的 T+ 双字母全键布局**。T+ 作为可选的中文键盘，不影响原有的全键盘、九键、笔画和手写输入。

> **重要**：T+ 版本标签为 `tplus-v1.0.0`，请勿与历史 `v1.0.0` 混淆（后者为上游兼容版，不含 T+）。

---

## 下载

从 [Releases](https://github.com/JunperoH/Tback-google-pinyin-input/releases) 下载 `ComebackGooglePinyinInput-TPlus-arm64-v8a-1.0.0.apk`，并校验附带的 `.sha256` 文件。若尚未发布 `tplus-v1.0.0`，请等待，不要下载历史 `v1.0.0`。

不需要 T+ 布局的用户可前往[上游 Releases](https://github.com/huaxianyan/comeback-google-pinyin-input/releases) 获取原版。

---

## T+ 布局简介

键位保留 QWERTY 顺序，每个按键容纳**两个相邻字母**：

```text
QW  ER  TY  UI  OP
AS  DF  GH  JK  L-
    ZX  CV  BN  M'
```


| 操作 | 效果 |
|------|------|
| 点击双字母键 | 两个字母同时作为候选，由 Google 拼音引擎根据上下文消歧 |
| 向左/右短滑 | 明确输入键上的第一个或第二个字母 |
| 长按 | 输入数字或标点（右上角标识） |
| 连续滑动（启用“滑行输入”） | 手势识别生成候选词 |

> 详细技术实现见 [T+ 移植说明](docs/touchpal-tplus-port.md)。

---

## 主要功能

- **T+ 键盘**：与系统原生键盘并列，随时切换。
- **现代 Android 兼容**：修复 Android 16 手写崩溃、候选列表误触、刷新率调度等问题。
- **隐私保护**：移除 Google 分析、在线词库同步、反馈上传等网络链路；备份仅通过用户授权的 Storage Access Framework 进行。
- **本地词典备份**：支持自动备份、手动导入/导出到内部存储、SD 卡或云盘（需 DocumentsProvider 支持）。

完整改动可查看 [兼容性说明](docs/compatibility-notes.md) 和 [变更日志](CHANGELOG.md)。

---

## 兼容性

| 项目 | 值 |
|------|-----|
| 包名 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 最低 Android | 17 (4.2) |
| 目标 SDK | 28 (Android 9) |
| CPU 架构 | `arm64-v8a` |
| 基础版本 | Google 拼音 4.5.2.193126728 |
| 签名 SHA-256 | `0FA3AD8C58A98FD550D37D787FEACC573F2E8A7AC71207667BDFBF0D9124D250` |

**已验证**：Android 14 / API 34 覆盖安装、T+ 布局切换、长按与滑动输入均通过。  
**已知限制**：
- 仅提供 `arm64-v8a` 构建。
- 旧原生库无法在强制 16KB 页大小的系统上加载（未来 Android 版本可能影响）。
- T+ 在手势模型中与普通键共享区域，候选排序可能不完美（例如 `bu hao` 优先于 `ni hao`）。

---

## 文档与构建

- [T+ 移植说明](docs/touchpal-tplus-port.md)
- [兼容性说明](docs/compatibility-notes.md)
- [用户词典备份设计](docs/dictionary-auto-backup-design.md)
- [构建与发布指南](docs/build-and-release.md)（含从源码构建步骤）

---

## 法律声明

- Google 拼音输入法及其相关资源归属 Google LLC。
- 本项目与 Google 或 TouchPal（CooTek）无任何关联或背书。
- 原始 APK 仅用于软件保存与研究，其 SHA-256 为 `980fd0f4695f683648e6f7ab9a15a24732e8957b5b14b25d49af931176574bd7`。
- T+ 实现为独立重建，不复制触宝代码、词库或原生库。
- 本项目为个人非商业用途，不收费、无广告。使用者应遵守当地法律及原软件许可。
