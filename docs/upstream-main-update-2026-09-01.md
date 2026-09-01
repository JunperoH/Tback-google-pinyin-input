# 上游 ComebackGooglePinyinInput 更新调查

调查日期：2026-09-01
上游仓库：<https://github.com/huaxianyan/ComebackGooglePinyinInput>
本地对比对象：当前工作区 `fix/tplus-l-long-press`（`8d4f8ca`），其上游共同基线为 `v1.0.3`（`664ccb7`）。

## 结论

- 上游默认分支仍是 `master`，截至调查时最新提交和最新 Release 都是 `v2.0.10`，提交 `1e8fb9276acd3ef666536222dd394170427ff033`，发布时间为 2026-08-19。GitHub 标签页和 Release 页给出的版本、日期与源提交一致。[标签](https://github.com/huaxianyan/ComebackGooglePinyinInput/tags)；[v2.0.10 Release](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases/tag/v2.0.10)；[源提交](https://github.com/huaxianyan/ComebackGooglePinyinInput/commit/1e8fb9276acd3ef666536222dd394170427ff033)
- `master` 在 `v2.0.10` 之后没有新提交；最新提交本身就是 `v2.0.10` 的发布合并提交。
- 当前 T+ 分支不是另一个无关项目，而是从同一历史的 `v1.0.3`（`664ccb7`）分叉。GitHub 的正式比较显示，上游 `v2.0.10` 相对 `v1.0.3` 已前进 **266 个提交、改动 360 个文件**。[v1.0.3...v2.0.10 比较](https://github.com/huaxianyan/ComebackGooglePinyinInput/compare/v1.0.3...v2.0.10)
- 仓库从旧的 `huaxianyan/comeback-google-pinyin-input` 重命名为 `huaxianyan/ComebackGooglePinyinInput`；`v2.0.9` 的更新日志明确记录了 README 和软件内入口迁移到新地址。[CHANGELOG 2.0.9](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#209---2026-08-17)

## 从 v1.0.3 到 v2.0.10 的实质更新

### 1. Android 16 / target SDK 36 兼容基线

`v2.0.0` 将 target SDK 提升到 36，并把 Android 10–16 的逐级兼容工作合并到正式基线，包括 covering-IME 底部几何、三按钮/手势导航主题延伸，以及 Android 12–16 的 `android:exported`、PendingIntent mutability、动态 Receiver 等安全门禁。Application ID 保持 `com.google.android.inputmethod.pinyin.compat`，官方说明可从 `v1.0.3` 覆盖升级。[v2.0.0 Release](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases/tag/v2.0.0)

### 2. 现代设置与引导

`v2.0.1` 起，API 35+ 使用源码构建的 Compose Material 3 设置，API 17–34 保持旧 Preference；现代设置覆盖原 Preference 键值、依赖、词典备份/导入、主题槽、动态配色、RTL、大字体、横屏/分屏与 TalkBack 语义。首次启用/选择输入法也整理为单页引导。[CHANGELOG 2.0.1](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#201---2026-08-10)；[项目 README](https://github.com/huaxianyan/ComebackGooglePinyinInput#设置与首次引导)

### 3. 统一 Header、Clipboard 与 Inline Autofill

`v2.0.2–2.0.4` 为密码、数字、电话、日期时间等键盘补齐独立原生 Header；系统敏感剪贴板和密码目标会脱敏显示但仍提交完整值；Android 11+ 接入标准 Inline Autofill，并由统一 Header Platform 仲裁 Candidate、Clipboard 与 Autofill。随后把 Inline 建议上限由 3 提到 6，兼容 Bitwarden 等 Provider。[CHANGELOG 2.0.2–2.0.4](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#204---2026-08-13)；[v2.0.3 Release](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases/tag/v2.0.3)

### 4. 简繁快捷切换

`v2.0.5` 在中文拼音 QWERTY、中文 9 键和中文笔画 Header 增加原生「简/繁」按钮，复用原键盘状态与 Candidate 刷新链路，并在新旧设置中提供默认开启的显示开关；空间不足或 Access Points 展开时会自动隐藏。[CHANGELOG 2.0.5](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#205---2026-08-13)；[v2.0.5 Release](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases/tag/v2.0.5)

### 5. 高刷新率与分页手感

`v2.0.6` 只在候选面板 80 ms 展开/收起动画期间请求 Android 16 高刷新率，结束后释放；`v2.0.7` 将同类机制扩展到 Emoji、颜文字和符号分页，并把明确短滑的非 fling settle 阈值改为 12.5%。[CHANGELOG 2.0.6–2.0.7](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#207---2026-08-14)

### 6. 近期稳定性修复（v2.0.8–v2.0.10）

- `v2.0.8`：修复 `DialKeyboard` 与 `PrimeKeyboard` 同签名 `final` 方法导致电话键盘首次加载时 ART `LinkageError` 崩溃。[CHANGELOG 2.0.8](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#208---2026-08-17)
- `v2.0.9`：修复部分选词后中英文混排的拼音组合文本高度轻微变化，并更新仓库地址。[CHANGELOG 2.0.9](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md#209---2026-08-17)
- `v2.0.10`：修复未测量手写键盘切换动画的 `Float.NaN` 崩溃、普通/密码输入框切换时窗口高度回弹，以及标点/符号/Emoji 手势移出分页区域后松手回弹。上游记录了 Pixel 10 Pro / Android 16 真机验收。[v2.0.10 Release](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases/tag/v2.0.10)

## 与当前 T+ 1.1.0 的关系

本地 Git 历史确认，T+ 工作从上游 `v1.0.3` 分叉；当前工作区在该基线上有 13 个提交（含合并提交），正式 `tplus-v1.1.0` 为 `d842ca0`，当前未发布的 L 长按修复为 `8d4f8ca`。

上游正式版与 T+ 不是互相覆盖关系：上游使用 `com.google.android.inputmethod.pinyin.compat` 和上游正式证书，T+ 使用 `com.google.android.inputmethod.pinyin.compat.tplus` 和独立证书，因此两者可以并存。把上游改动移植进 T+ 后，仍须沿用 T+ 的包名与证书，并将 T+ 的 `versionCode` 从当前 `4520406` 继续递增；不能直接采用上游 `v2.0.10` 的较低 `4520395`。

根据上游 `master` 完整 Git tree 的 blob SHA 与本地 `v1.0.3` tree 对比，上游 360 个改动路径中有 322 个新增、38 个修改、0 个删除。T+ 相对同一基线改了 62 个路径；两边同时变动的路径只有以下 6 个：

1. `.github/workflows/build-release.yml`
2. `CHANGELOG.md`
3. `README.md`
4. `docs/build-and-release.md`
5. `scripts/apply_patches.py`
6. `scripts/build.ps1`

这意味着 T+ 的专有布局、笔画数据、Stroke Filter Java/Smali、`TPlusKeyMapping.smali` 等路径与上游没有直接同路径冲突；但**行为层面仍有明显整合风险**：

- `scripts/apply_patches.py`、`scripts/build.ps1` 和 Release workflow 都被两边修改，不能直接取一边覆盖另一边，否则可能丢失 T+ 资源注入、Stroke Filter 生成/验证，或丢失上游 Compose/Header/API 36/签名门禁。
- 上游统一 Header Platform、简繁按钮与 T+ 自定义 Header/笔画按钮共享相同可视区域。即使文件不冲突，也需要重新做 Header 空间、Access Points、Candidate/Clipboard/Autofill 仲裁和触摸区域验收。
- 上游对分页触摸、按键取消与反馈链路有较大改造；T+ 当前又有自定义滑动笔画识别和 L/M 长按弹窗，合并后必须专项回归长按、滑动轨迹、候选提交、区域外松手和符号分页。
- 上游版本已经是 `2.0.10`。不宜把它直接塞进既有 `1.1.0` 发布线；更稳妥的是冻结 `tplus-v1.1.0`，从 `v2.0.10` 新建独立集成分支，再移植 T+ 功能并发布新的大/次版本。

## 建议的合并策略

1. 以不可变标签 `v2.0.10` 新建 T+ 集成分支，不在当前 `1.1.0` 分支上直接合并 266 个提交。
2. 先保留上游的 `scripts/apply_patches.py`、`scripts/build.ps1`、workflow 与版本单一来源，再逐段移植 T+ 的布局、资源、Smali、Stroke Filter 生成器和验证器。
3. 单独设计 T+ 在 Header Platform 中的位置与仲裁规则；决定是否把上游「简/繁」快捷键也加入 T+，不要仅靠资源叠加。
4. 完整构建后至少覆盖：T+ 点按/长按 L、M，自动笔画滑动与轨迹，Candidate/Clipboard/Inline Autofill，简繁切换，符号分页，手写键盘切换，普通/密码输入框切换，以及 Android 16 导航区与 120 Hz 动画。
5. 验证通过后再以新的版本号发布，保留 `tplus-v1.1.0` 标签和 APK 不动，便于回滚与对照。

## 主要一手资料

- [上游项目首页](https://github.com/huaxianyan/ComebackGooglePinyinInput)
- [完整 CHANGELOG](https://github.com/huaxianyan/ComebackGooglePinyinInput/blob/master/CHANGELOG.md)
- [Releases](https://github.com/huaxianyan/ComebackGooglePinyinInput/releases)
- [Tags](https://github.com/huaxianyan/ComebackGooglePinyinInput/tags)
- [v1.0.3...v2.0.10 官方比较](https://github.com/huaxianyan/ComebackGooglePinyinInput/compare/v1.0.3...v2.0.10)
