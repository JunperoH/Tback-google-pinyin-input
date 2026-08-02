# T+ 拼音笔画过滤具体执行计划

| 文档属性 | 值 |
| --- | --- |
| 上游方案 | [T+ 拼音笔画过滤研究与接力实现方案](tplus-stroke-filter-research.md) |
| 目标版本 | `1.1.0` 迭代试做（内部 `versionCode` 单调递增） |
| 计划日期 | 2026-08-02 |
| 状态 | M0–M7 已实现；正在试做自动捕获与可见轨迹并回归模拟器 |
| 默认范围 | T+ 长按多候选 + 自动笔画旁观 + 主题化轨迹 + Google 原候选过滤 |
| 明确不做 | Okinawa 移植、替换 Google 独立笔画输入法、稀有字补充候选 |

## 1. 执行原则与排期假设

本计划按“一名熟悉 APKTool、smali 和 Android 输入法事件链的开发者”估算。建议投入 **10–15 个工程日**，另留 **2 个真实设备回归日**。若从 2026-08-03 开始，可按以下节奏推进：

| 周期 | 目标 | 交付 |
| --- | --- | --- |
| 8 月 3–7 日 | 基线、长按菜单、Conway 数据流水线 | M0、M1、M2 |
| 8 月 10–14 日 | 候选链可行性验证和正式过滤会话 | M3、M4 |
| 8 月 17–21 日 | 候选栏入口、轨迹处理、整包回归 | M5、M6、M7 |

这不是必须遵守的发布日期；真正的关键路径是 `M2 数据 → M3 候选可行性 → M4 候选正确性 → M5 UI → M6 手势`。任何门槛失败都停在当前里程碑，不把未解决问题推到后续手势阶段。

建议每个里程碑独立提交。长按菜单没有 Conway 和候选链依赖，可以提前合并；是否单独发布 `1.0.1` 再由维护者决定，默认仍随 `1.1.0` 一起发布。

## 2. 总体里程碑

| ID | 工作包 | 估算 | 依赖 | 合并门槛 |
| --- | --- | ---: | --- | --- |
| M0 | 建立可重复基线 | 0.5–1 日 | 无 | 当前 `1.0.0` 可从干净 APK 重建、安装、静态验证 |
| M1 | T+ 长按大小写多候选 | 0.5–1.5 日 | M0 | 14 个组合键菜单、取消、边缘键和 composing 对照通过 |
| M2 | Conway 数据生成与验证 | 1.5–2 日 | M0 | 固定来源可重复生成、数据样例和损坏回退测试通过 |
| M3 | 候选链可行性 Spike | 1–2 日 | M2 | `si + 3` 可扫描到并正确提交“偲”，或形成明确 No-Go 证据 |
| M4 | 正式候选过滤会话 | 2–3 日 | M3 Go | 重放、分页、双世代取消、首选提交和 fail-open 通过 |
| M5 | 候选栏“笔”入口与设置 | 1–2 日 | M4 | 不遮挡候选/展开/剪贴板层，T+ 之外不可见 |
| M6 | 轨迹捕获与五类识别 | 2–3 日 | M5 | 激活态准确接管；未激活态所有原手势无回归 |
| M7 | 发布候选验证 | 1.5–2 日 | M1–M6 | 构建、反解、覆盖安装、完整矩阵和真机通过 |

## 3. M0：建立可重复基线

### 3.1 任务

- [ ] 保留当前工作树，不清理用户已有文件；记录 `git status --short`。
- [ ] 确认原始 APK SHA-256、apktool 2.12.1、签名工具和当前正式证书指纹符合 `docs/build-and-release.md`。
- [ ] 在未加入新功能前运行 `python scripts/verify_tplus.py`。
- [ ] 使用 `scripts/build.ps1` 从原始 APK 完整解码、打补丁、重建并签名。
- [ ] 运行 `python scripts/verify_tplus.py work/decoded`。
- [ ] 在模拟器或真机记录以下基线：T+ 普通 PRESS、左右短滑、跨键滑行、14 个现有长按项、Shift、退格、QWERTY/九键/独立笔画切换。
- [ ] 把受控测试证据放入忽略目录 `work/stroke-filter-evidence/baseline/`，不记录真实用户输入。

### 3.2 通过条件

当前 `1.0.0` 必须先全部为绿。若基线已失败，先修基线或更新研究结论，不能把原有故障计入本功能。

## 4. M1：T+ 长按大小写多候选

### 4.1 修改文件

```text
patches/res/xml/softkeys_input_zh_cn_pinyin_tplus.xml
scripts/verify_tplus.py
docs/tplus-stroke-filter-execution-plan.md
```

### 4.2 实现步骤

- [ ] 先在未修改 APK 的 Google 中文 QWERTY 上测试 `1 q Q` 类 popup，记录无 composing 和已有 composing 时的上屏文本、光标、候选和 composing 变化，作为产品行为 oracle。
- [ ] 将两个 T+ pair template 的 `LONG_PRESS` 从单值 `$alternate_data$` 改为 `$long_press_data$`，同时保留单独的 `$alternate_label$` 供右上角角标显示。
- [ ] popup layout 改用 `@attr/PopupBubbleRectangularLayout`，`keycode="PLAIN_TEXT"`、`intention="COMMIT"` 保持与 Google 中文 QWERTY 多候选一致。
- [ ] lower/upper 两套 pair list 写入完整候选，例如 `Q W → 1 q w Q W`、`E R → 2 e r E R`。
- [ ] 将 `L -` 和 `M '` 的长按也改为多值：`0 l L`、`, m M`；其右滑连字符/撇号动作不变。
- [ ] 扩展 `verify_tplus.py`：逐键断言 14 个菜单的完整顺序、第一项原数字/符号、大小写覆盖、矩形 popup 和 `PLAIN_TEXT/COMMIT`。

### 4.3 验收

- [ ] 14 个组合键每个条目都可选，松手取消不输出。
- [ ] lower/upper 模板菜单内容相同，Shift 不改变菜单完整性。
- [ ] 左右边缘键、横屏、密码和 URL InputType 不溢出或错误提交。
- [ ] 已有 composing 时的结果与 Google 中文 QWERTY oracle 一致。
- [ ] 普通 PRESS、左右短滑和跨键滑行不变。

### 4.4 提交建议

```text
feat(tplus): add letter-case choices to long-press popups
```

M1 可以单独回退，不能依赖任何笔画过滤类或资源。

## 5. M2：Conway 数据生成与验证

### 5.1 新增文件

```text
third_party/conway-stroke-data/codepoint-character-sequence.txt
third_party/conway-stroke-data/LICENSE-CC-BY-4.0.txt
docs/stroke-filter-data-attribution.md
scripts/generate_stroke_filter_data.py
scripts/verify_stroke_filter.py
patches/res/raw/stroke_filter_data.bin
```

固定来源：

```text
commit  a657f5b7554ace8d97a4d9a87aca391b24363458
source  codepoint-character-sequence.txt
sha256  2da408c8982613020bda7ad16b76a3b28e93843afcd207e8bb2c9c743727f123
license CC BY 4.0
```

### 5.2 生成器任务

- [ ] 校验原始文件 SHA-256 后才处理。
- [ ] 按上游 `to_sequence_set()` 语义展开选择分支、捕获组和 `\1..\5` 反向引用；禁止把源字段当作普通数字串。
- [ ] 每个 Unicode code point 的所有合法变体截取前五笔并去重。
- [ ] 五类编码固定为 `1=横、2=竖、3=撇、4=点/捺、5=折`。
- [ ] 输出按 code point 升序，固定小端格式，并输出生成报告：条目数、变体数、最大变体数、产物字节数和来源摘要。
- [ ] 同一输入重复生成必须逐字节一致；生成器不得访问网络。

建议第一版二进制格式：

```text
Header:
  magic[4] = "TSF1"
  formatVersion:u16
  flags:u16
  codePointCount:u32
  variantCount:u32
  sourceSha256[32]

Sections:
  codePoints:u32[]
  variantOffsets:u32[]
  variantCounts:u16[]
  variants[] = { length:u8, packedStrokes:u16 }  # 最多 5 × 3 bit
```

### 5.3 验证器任务

- [ ] 重新生成临时产物并与仓库中的 `.bin` 做 byte-for-byte 比较。
- [ ] 检查 magic、版本、段边界、排序、重复 code point、变体 offset/count 和笔画值范围。
- [ ] 覆盖普通序列、选择分支、空分支、反向引用和多变体。
- [ ] 固定断言：`偲` 匹配前缀 `3`，`灏/灝` 匹配前缀 `4`，错误首笔不匹配。
- [ ] 构造截断、错误 magic、错误版本和来源摘要不符的坏文件，断言 Python 参考解码器能稳定拒绝；Android smali 加载器的 fail-open 在 M3 实现后再验收。

### 5.4 通过条件与提交

```text
python scripts/generate_stroke_filter_data.py --check
python scripts/verify_stroke_filter.py
```

两个命令均通过，且仓库包含来源和 attribution 后再提交：

```text
build(stroke-filter): vendor and compile Conway stroke data
```

## 6. M3：候选链可行性 Spike

这是整个项目的第一道硬门槛。此阶段不接设置、不做按钮、不处理触摸，只用受控调试前缀证明 Google 原候选链能完成目标。

### 6.1 预期修改点

```text
patches/smali/StrokeFilterData.smali
patches/smali/StrokeFilterCompat.smali
patches/smali/StrokeFilterCandidateSession.smali
scripts/apply_patches.py
scripts/verify_stroke_filter.py
scripts/instrument_stroke_filter_spike.py

目标解码文件（只通过 apply_patches.py 修改，不直接提交）：
smali/com/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor.smali
smali/com/google/android/apps/inputmethod/pinyin/ime/hmm/HmmPinyinT9DecodeProcessor.smali
```

### 6.2 Spike 步骤

- [ ] `StrokeFilterData` 首次使用时通过 `Resources.getIdentifier("stroke_filter_data", "raw", packageName)` 解析新增资源 ID，再用 `openRawResource(id)` + `DataInputStream` 懒加载不可变索引；校验 header、边界、排序和来源摘要。smali 中不得硬编码易随 aapt2 重排的 `0x7f...` ID，`getIdentifier` 返回 0 时 fail-open。
- [ ] 二进制固定为小端；`DataInputStream` 只用于 `readUnsignedByte/readFully`。实现 `readU16LE()` 和 `readU32LE()` 逐字节组装，禁止直接使用默认大端的 `readShort/readInt`。Python verifier 用同一组跨语言 fixture 断言每个字段值。
- [x] 在实包 `AbstractHmmDecodeProcessor.initialize(Context, ImeDef, IImeDelegate)` 的单一稳定锚点把 application context 交给 `StrokeFilterCompat.initialize()`；只保存 application context，初始化时不立即读文件。
- [ ] 资源加载失败时只记录一次受控日志，本会话禁用过滤；不能让 IME 初始化失败。
- [ ] `scripts/instrument_stroke_filter_spike.py` 只对指定的干净解码副本注入临时 `enableTestMode(tplusToken=true, settingEnabled=true, prefix="3")` 方法及一次调用；正式 `patches/smali/StrokeFilterCompat.smali` 不包含该方法。测试注入必须同时提供 M4 守卫要求的生命周期 token、设置值和前缀，不能只改 prefix。
- [ ] Spike 使用单独的 `work/stroke-filter-spike-decoded/` 干净解码副本；测试调用只存在于该忽略目录，不写入 `patches/`，也不修改只读研究基线 `work/analysis/google-decoded/`。九键、QWERTY 和独立笔画路径保持关闭。
- [x] 在 `AbstractHmmDecodeProcessor.setTextCandidates(Iterator)` 新 iterator 到来时建立 composing session；在 `resetInternalStates()` 销毁 session。
- [x] 在 `AbstractHmmDecodeProcessor.onRequestCandidates(int)` 的原循环前扫描，而不是过滤已经显示的六个候选；每个原 Candidate 先入缓存，再匹配显示文字的首个 Han code point，未激活时原循环原样执行。
- [ ] 只保留原 Candidate 对象，不重新构造 payload。
- [ ] 日志只记录受控样例的扫描数量、是否耗尽、命中字和 Candidate 类型，不记录日常输入。
- [ ] 查明 `requestCandidates()` 中第二个 `appendTextCandidates` 参数的实际语义；分别验证视觉高亮、空格/回车默认目标和点击提交。
- [ ] 记录 `AbstractHmmChineseDecodeProcessor.onSelectTextCandidate(Candidate, boolean)` 的两条原生路径：`false` 为 highlight/update composing，`true` 为 `selectCandidate`/提交。M4 必须复用这条原生链，不能另造 payload 提交。

### 6.3 Go/No-Go 门槛

**Go：** 输入 `si` 后设置前缀 `3`，原 iterator 最终出现“偲”，候选点击和空格/回车提交都使用原 payload 且无异常。

**No-Go：** iterator 已明确耗尽仍没有“偲”，或者无法在不破坏 HMM composing 的情况下改变默认提交目标。此时：

1. 停止 M4–M6；
2. 保存 iterator 耗尽和提交路径证据；
3. 新建“稀有字补充候选设计”，单独定义拼音映射、排序、Candidate payload、提交和学习；
4. 不在当前过滤器中硬编码“偲”，也不以换一个更容易的示例掩盖门槛失败。

Spike 代码只有在达到 Go 后才整理为正式提交；临时强制前缀和调试日志不得进入发布分支。`verify_stroke_filter.py` 默认拒绝解码树中出现 `enableTestMode` 调用，只有显式 `--allow-test-hook` 才允许 M3/M4 的忽略目录测试。

Spike 必须可重复运行：

```powershell
java -jar tools/apktool.jar d -f `
  -o work/stroke-filter-spike-decoded `
  original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk
python scripts/apply_patches.py work/stroke-filter-spike-decoded
python scripts/instrument_stroke_filter_spike.py `
  work/stroke-filter-spike-decoded --prefix 3
python scripts/verify_stroke_filter.py `
  work/stroke-filter-spike-decoded --allow-test-hook
```

## 7. M4：正式候选过滤会话

### 7.1 会话模型

`StrokeFilterCandidateSession` 必须至少维护：

```text
composingGeneration
filterGeneration
sourceIterator
rawCandidateCache
rawCursor
sourceExhausted
firstMatchedCandidateForFilter
pendingRunnable
```

### 7.2 实现任务

- [ ] 新 composing iterator 到来：递增 `composingGeneration`，销毁旧缓存/任务，绑定新 source iterator。
- [ ] 追加、退格或清空笔画前缀：递增 `filterGeneration`，取消旧 runnable，`rawCursor=0`，清空全局首个匹配项，从缓存头重放。
- [ ] 展开/翻页同一过滤结果：不递增 `filterGeneration`，不改写 `firstMatchedCandidateForFilter`。
- [ ] 每批最多扫描 256 个原 Candidate；如果性能数据证明过于频繁，再在 256/512 之间调整，不在代码中散落多个常量。
- [ ] 每个 runnable 创建时捕获 `(composingGeneration, filterGeneration)`；在 runnable 入口、读取 `sourceIterator` 前、每次修改 cache/cursor/state/首选前、投递下一批前和写 UI 前都核对双 token。任一不符立即返回，不消费 iterator、不修改共享状态、不续投。
- [ ] 所有扫描和前缀变更固定在同一个主线程 Handler 上串行执行；若实现阶段改用后台线程，必须给 session 加锁并重新审查 iterator 线程安全，不能只依赖 token。
- [ ] 达到预算但未完成：把 session 状态设为 `SCANNING`，用主线程 Handler 投递下一批。M4 用日志/状态断言验证，M5 再把它渲染为“正在筛选…”。
- [ ] 只有 `sourceExhausted=true` 后才把状态设为 `NO_MATCH`；M5 再渲染“无匹配候选”。
- [ ] 清空过滤：从缓存头按 Google 原顺序恢复，再继续 source iterator。
- [ ] 缓存达到硬上限时不逐出头部对象；本 composing fail-open、取消过滤并恢复原顺序。
- [ ] `selectCandidate()` 只用于用户点击、空格或回车的明确提交，不用于刷新高亮。
- [ ] 退出“笔”但保留前缀：递增 `filterGeneration`、取消旧 runnable、重置 cursor/全局首项，并用同一前缀从缓存头重发请求。
- [ ] 资源 fail-open：先递增 `filterGeneration` 并取消旧 runnable，再关闭过滤、按原顺序重放缓存；不能让旧扫描继续写 UI。
- [ ] commit、abort、finish input 和布局切换递增 `composingGeneration`，取消 pending runnable 并销毁 session。

### 7.3 共享类保护

过滤挂点位于共享 `AbstractHmmDecodeProcessor`，每次进入分支前必须同时满足：

```text
T+ 生命周期 token 有效
AND 设置已开启
AND composingGeneration 有效
AND 笔画前缀非空
```

任一条件不满足都执行原方法路径。QWERTY、九键、英文、手写和 Google 独立笔画必须没有额外候选扫描。

M4 在 `StrokeFilterCompat` 内定义稳定 preference key `tplus_stroke_filter_enabled`，读取 SharedPreferences 时默认 `false`；M5 的 XML key 必须使用完全相同的字符串。M3/M4 的本地 `enableTestMode` 同时以内存覆盖方式提供 `token=true + setting=true + prefix`，不依赖尚未出现的设置页面。

M4 尚未注册正式 T+ 生命周期 handler，动态验收由 M3 的一次性本地测试挂点提供 token 和设置覆盖；提交到 `patches/` 的生产代码默认设置为 false、也没有有效 token，因此保持休眠。M5 注册 T+ 专用 handler 和设置 XML 后，才提供正式的 `activate/deactivate` 生命周期来源。这是先验证核心再启用入口的顺序，不构成 M4/M5 依赖环。

### 7.4 高亮、点击与空格/回车提交闭环

目标解码文件：

```text
smali/com/google/android/apps/inputmethod/libs/hmm/AbstractHmmDecodeProcessor.smali
smali/com/google/android/apps/inputmethod/libs/chinese/ime/hmm/AbstractHmmChineseDecodeProcessor.smali
```

- [ ] 候选列表：`appendTextCandidates` 的第二个参数传当前 `filterGeneration` 的 `firstMatchedCandidateForFilter`，翻页不得换成当前页首项。
- [ ] 视觉高亮：不调用 `selectCandidate()`。若 M3 证明第二参数会进入原生 highlight 路径，就只使用第二参数；否则仅在 UI 明确请求高亮时调用现有 `onSelectTextCandidate(firstMatched, false)`，不得在每批扫描时调用。
- [ ] 候选点击：不增加替换逻辑；候选栏把用户实际点击的原 Candidate 交给现有 `onSelectTextCandidate(clickedCandidate, true)`。
- [ ] 空格/回车：在 `AbstractHmmChineseDecodeProcessor` 现有 SPACE/ENTER 提交分支之前加严格 T+ 过滤守卫，从 session 取全局首项，调用同一实例的 `onSelectTextCandidate(firstMatched, true)`；返回 true 时消费本次键事件并跳过原默认提交，避免重复上屏。
- [ ] 若过滤激活但全局首项为空、generation 过期或 `onSelectTextCandidate(..., true)` 返回 false，本次空格/回车不允许提交被隐藏的原首选：消费当前事件、触发 fail-open 和原候选刷新，等待用户再次确认。
- [ ] 成功点击/空格/回车后由现有 commit 链递增 composing generation 并清理过滤 session。

### 7.5 自动验证

`scripts/verify_stroke_filter.py` 增加以下静态断言：

- [ ] 三个 helper smali 已复制到准确包路径，且不会覆盖原文件。
- [ ] `initialize`、`setTextCandidates`、`requestCandidates`、`resetInternalStates` 挂点各恰好一次。
- [ ] 原 `Iterator.next()` Candidate 仍原样进入输出列表。
- [ ] prefix inactive 路径直接保持原循环。
- [ ] 双 token 检查、256 扫描预算、fail-open 和取消 runnable 均存在。
- [ ] SPACE/ENTER 守卫和 `onSelectTextCandidate(firstMatched, true)` 挂点各恰好一次；候选点击原链未被替换。
- [ ] `scripts/apply_patches.py` 对两个独立的干净解码目录产生相同目标文件；不要求在已经打过补丁的同一目录上重复运行。

### 7.6 动态验收

- [ ] `si + 3 → 偲`、`hao + 4 → 灏`。
- [ ] 前缀 `3 → 31 → 3 → 空` 候选可重放，原顺序恢复。
- [ ] 深层扫描期间快速退格/改前缀，旧 runnable 不覆盖新 UI。
- [ ] 翻页后空格仍提交整个过滤结果的第一项，不变成下一页首项。
- [ ] 无匹配时 session 先保持 `SCANNING` 并自动续扫，iterator 耗尽后才变为 `NO_MATCH`；对应可见文案留到 M5 验证。
- [ ] 数据文件缺失/损坏时原拼音和独立笔画仍能输入。

建议提交：

```text
feat(stroke-filter): add replayable HMM candidate filtering
```

## 8. M5：候选栏“笔”入口与设置

### 8.1 修改文件

```text
patches/res/layout/keyboard_candidates_header_inner.xml
patches/res/layout/keyboard_candidates_header_inner_no_deletable_label.xml
patches/res/values/stroke_filter.xml
patches/res/values-zh-rCN/stroke_filter.xml
patches/res/values-zh-rTW/stroke_filter.xml
patches/res/xml/keyboard_zh_cn_pinyin_tplus.xml
patches/smali/StrokeFilterCompat.smali
patches/smali/StrokeFilterMotionEventHandler.smali
scripts/apply_patches.py
scripts/verify_stroke_filter.py

目标解码文件：
res/xml/setting_input.xml
smali/.../FixedSizeCandidatesHolderView.smali
```

### 8.2 UI 原型门槛

- [ ] 先建立 `StrokeFilterMotionEventHandler` 骨架并在 T+ XML 的 Basic handler 前注册：M5 中它只用 `activate/deactivate/close` 设置或清除 T+ 生命周期 token，`acceptInitialEvent` 始终返回 false，绝不接管触摸；M6 再补轨迹能力。
- [ ] 在两个候选 header layout 加入默认 `gone` 的 tag overlay：`compat_stroke_filter_toggle`。
- [ ] 第一方案把“笔”放在展开键左侧，并显式为 candidate holder 预留宽度；不能只盖在候选文字上。
- [ ] 复用 `ClipboardCandidateCompat` 的 `findViewWithTag + setOnClickListener` 思路，但“笔”与 `compat_clipboard_dismiss` 不得占用同一区域。
- [ ] 在 `FixedSizeCandidatesHolderView.appendCandidates()` 的稳定尾部挂一次 `StrokeFilterCompat.updateToggle(root)`，依据 T+ 生命周期、设置和 composing 显示/隐藏。
- [ ] 若共享 header 无法同时保证候选、展开键和剪贴板关闭层，停止继续修 margin，改建 T+ 专用 header/candidate-inner layout。

### 8.3 设置与状态

- [ ] 在 `setting_input.xml` 的中文输入分类中通过 `replace_once` 插入“拼音笔画过滤”复选项，key 的值必须精确为 M4 定义的 `tplus_stroke_filter_enabled`，并显式设置 `android:defaultValue="false"`；不要直接用补丁资源覆盖原 settings XML。
- [ ] T+ keyboard 的 handler 配置笔画过滤 preference key，运行时仍再次检查设置状态。
- [ ] “笔”只在 T+、有 composing、数据加载成功时显示。
- [ ] 候选 session 为 `SCANNING` 时显示“正在筛选…”，为 `NO_MATCH` 时显示“无匹配候选”；不得把单批扫描暂时为空显示成最终无匹配。
- [ ] 点击进入持续捕获态；再次点击退出捕获，但保留当前过滤前缀。退出动作必须递增 `filterGeneration`、取消旧 runnable、重置 cursor/全局首项，并从缓存头重发同前缀请求。
- [ ] 候选提交、取消、清空 composing、finish input、布局切换时退出并清空。
- [ ] 退格优先删除最后一笔；前缀为空后再走原拼音退格。

### 8.4 验收

- [ ] 功能默认关闭，升级后用户原手感不变。
- [ ] 非 T+、无 composing 和数据错误时按钮不可见。
- [ ] 候选 holder、展开页、剪贴板 dismiss 和“笔”均可独立点击，无覆盖。
- [ ] 横竖屏、字体缩放和不同候选数量下布局稳定。

建议提交：

```text
feat(stroke-filter): add explicit candidate-bar capture mode
```

## 9. M6：轨迹捕获与五类识别

### 9.1 修改文件

```text
patches/smali/StrokeFilterMotionEventHandler.smali  # 扩展 M5 生命周期骨架
patches/smali/StrokeFilterCompat.smali
patches/res/xml/keyboard_zh_cn_pinyin_tplus.xml
scripts/apply_patches.py
scripts/verify_stroke_filter.py

目标解码文件：
smali/com/google/android/apps/inputmethod/pinyin/ime/hmm/HmmPinyinT9DecodeProcessor.smali
```

### 9.2 Handler 协议

- [x] 保持 M5 中 handler 位于 `BasicMotionEventHandler` 之前的注册顺序。
- [x] composing 建立后若旧 Basic target 仍占用下一段触摸，只在自动捕获有效的新 `ACTION_DOWN` 于 `atu` 的 preHandle/handle 入口释放；Basic 保持原实现。两条 Pinyin 手势链按 `tplusActive && settingEnabled` 门控关闭跨键滑行。
- [x] `activate/deactivate/close` 建立和销毁 T+ 生命周期 token；T+ 专用 stroke handler 在每次触摸进入共享 Pinyin handlers 前刷新 token，离开键盘立即清理轨迹和 pending 状态。
- [x] composing 与数据有效时自动进入旁观；`DOWN` 开始采样但不立即认领。
- [x] 最大位移越过系统 touch slop 后才认领；Basic/其他 handler 此时被 reset。
- [x] 未越阈值的点按与静止长按不产出笔画，继续由 Basic 完成。
- [x] 较长键内左右滑会优先成为横笔；用户可通过候选栏“笔”暂停当前 composing 的自动捕获。
- [x] 轨迹由非交互式 `StrokeFilterTrailView` 使用主题手势色绘制，抬手后淡出；不复用或唤醒滑行解码器。
- [x] 通过 `IMotionEventHandlerDelegate.fireEvent(Event)` 发送专用内部事件；先扫描现有 keycode，选取无冲突值并在 verifier 中锁定。
- [x] `HmmPinyinT9DecodeProcessor` 在普通 T+/T9 映射之前拦截内部笔画事件，追加 `1..5` 前缀并触发候选刷新，不送入 HMM 拼音 decode。

### 9.3 几何分类

- [x] 使用 `ViewConfiguration.getScaledTouchSlop()`、键盘宽高归一化坐标和采样点抽稀，不硬编码 TouchPal 的 20 px。
- [x] 直线主方向区分横、竖、撇、点/捺；明显方向切换归折。
- [x] 最多保存五笔；第六笔给出轻提示但不修改前缀。
- [ ] 调试构建只记录轨迹长度、角度、转折数、分类和置信度；不记录候选文字或上传数据。

### 9.4 手势验收

- [ ] 设置关闭：T+ PRESS、左右短滑、长按 popup、跨键滑行与 `1.0.0` 一致。
- [ ] 设置开启且 composing 建立：普通点按继续输入、静止长按仍弹 popup、跨键滑行关闭、越阈值轨迹分类为笔画。
- [ ] 五类轨迹各连续测试 20 次，目标单类命中率至少 90%，且轨迹即时可见并在抬手后淡出。
- [ ] 小于 slop 的触摸不产出笔画，且原 Basic 点按正常完成。
- [ ] 不同密度、横竖屏和至少一台真实设备完成调参。

2026-08-02 模拟器回归记录：在 Android 14 / API 34 竖屏模拟器中，用正式包反解副本仅加入受控日志，先产生 composing，再按实际候选栏坐标点击“笔”。按钮返回捕获态 `true`；随后在键盘主体画横，完整收到 `ACTION_DOWN → ACTION_MOVE → ACTION_UP`，`atu` 的目标为 `StrokeFilterMotionEventHandler`，分类结果为 `1`（横）。测试后已覆盖恢复无日志正式 APK，设备 `base.apk` 与 `dist` APK 的 SHA-256 一致，且未出现崩溃或 `VerifyError`。该记录不替代上方五类各 20 次、横屏和真实设备矩阵。

2026-08-02 前一 `1.1.0` 试做（内部 code `4520405`）模拟器回归记录：在同一 API 34 模拟器中确认设置实际开启后，未点“笔”直接跨键长滑；两条 Pinyin handler 对 `DOWN/MOVE/UP` 的门控均为 `true` 并逐事件返回，未产生 `PinyinGestureHandler` target，输入框保持空白。随后普通单键仍由 `BasicMotionEventHandler` 处理，真实点击“笔”返回 `true`，画横由 `StrokeFilterMotionEventHandler` 接管并分类为 `1`。最后覆盖安装无日志正式试做包，设备 `base.apk` 与 `dist` APK 的 SHA-256 一致。

2026-08-02 自动捕获试做（`versionName=1.1.0`、`versionCode=4520406`）模拟器回归记录：先确认 16KB page-size 镜像会按已知限制拒绝 4KB 对齐的 `libhmm_gesture_hwr_zh.so`，随后在 `TPlus_API34_4K`（API 34、page size 4096、1080×2400、420dpi）覆盖安装。首次 T+ 点按建立 composing 后候选栏自动显示激活态；未点“笔”再普通点按，Basic 正常更新 composing。注入 1.6 秒横划时，中途截图可见主题色圆角轨迹；抬手后候选从普通拼音候选切换为“十分/三/事/所/死”等首笔横结果，轨迹随后清除。自动状态下对 OP 静止长按 1 秒，原 `P/O/p/o/5` popup 正常显示。全过程无 `FATAL EXCEPTION`、`VerifyError`、`NoSuchFieldError` 或 `NoSuchMethodError`；设备 `base.apk` 与 dist APK 的 SHA-256 同为 `BE5BBC69F572C1260250D8CB47DA60215E1750366F754256739430BA05D0CE1F`。测试后两台模拟器默认输入法均恢复为触宝。

2026-08-02 范围变更：根据试用反馈，在仍标记为 `1.1.0` 的迭代试做中加入自动旁观与可见轨迹；不创建 `1.1.2` 标签。Android `versionName` 保持 `1.1.0`，每个可覆盖安装的试验包只递增内部 `versionCode` 并使用独立文件名保留旧 APK。

建议提交：

```text
feat(stroke-filter): capture and classify explicit T+ strokes
```

## 10. M7：整包验证与发布候选

本阶段新增 `scripts/verify_reproducible_patch.py`，用于比较两个独立干净解码目录中的补丁目标、生成资源和 helper smali；忽略 apktool 临时文件和时间戳，但任何实际字节差异都失败。

### 10.1 自动检查顺序

```powershell
python scripts/verify_tplus.py
python scripts/generate_stroke_filter_data.py --check
python scripts/verify_stroke_filter.py

./scripts/build.ps1 `
  -ApkPath ./original/google-pinyin-input-4.5.2.193126728-arm64-v8a.apk `
  -ApktoolJar ./tools/apktool.jar `
  -SignerJar ./tools/uber-apk-signer.jar `
  -Keystore <正式签名文件> `
  -KeyAlias <alias> `
  -StorePassword $env:TPLUS_STORE_PASSWORD `
  -KeyPassword $env:TPLUS_KEY_PASSWORD

python scripts/verify_tplus.py work/decoded
python scripts/verify_stroke_filter.py work/decoded
```

不要把密码写入计划、脚本、日志或 PowerShell history。正式构建继续遵守 `docs/build-and-release.md` 的证书和 Actions 规则。

### 10.2 最终签名 APK 的可执行验证

先确认正式产物使用完整文件名 `ComebackGooglePinyinInput-TPlus-arm64-v8a-1.1.0.apk`，然后执行：

```powershell
$releaseApk = (Resolve-Path `
  '.\dist\ComebackGooglePinyinInput-TPlus-arm64-v8a-1.1.0.apk').Path
$verifyDir = Join-Path (Resolve-Path '.\work').Path `
  'verification-tplus-111-final'
$buildTools = '<Android SDK build-tools 目录>'

java -jar .\tools\apktool.jar d -f -o $verifyDir $releaseApk
python .\scripts\verify_tplus.py $verifyDir
python .\scripts\verify_stroke_filter.py $verifyDir

& (Join-Path $buildTools 'zipalign.exe') -c -P 16 -v 4 $releaseApk
& (Join-Path $buildTools 'apksigner.bat') `
  verify --verbose --print-certs $releaseApk
& (Join-Path $buildTools 'aapt2.exe') dump badging $releaseApk
jar tf $releaseApk | Select-String '^lib/'

adb install -r $releaseApk
adb shell ime list -s
```

命令输出必须确认：包名正确、`versionName=1.1.0`、`versionCode=4520406`、只有预期 ABI、zipalign 通过、v1/v2/v3 签名和证书 SHA-256 正确。`adb install -r` 后再执行 10.4 的设备矩阵。

可重复补丁验证：

```powershell
foreach ($name in @('stroke-repro-a', 'stroke-repro-b')) {
  $decoded = Join-Path '.\work' $name
  java -jar .\tools\apktool.jar d -f -o $decoded `
    .\original\google-pinyin-input-4.5.2.193126728-arm64-v8a.apk
  python .\scripts\apply_patches.py $decoded
}
python .\scripts\verify_reproducible_patch.py `
  .\work\stroke-repro-a .\work\stroke-repro-b
```

### 10.3 反向验证清单

- [x] 正式 `versionName` 为 `1.1.0`，`versionCode` 为 `4520406`；Release Assets 使用完整文件名且不设置显示别名，旧试做 APK 在本地保留。
- [x] 同步更新 `scripts/apply_patches.py`、`.github/workflows/build-release.yml`、README、CHANGELOG 和 Release APK 文件名中的版本身份。
- [x] 对最终签名 APK 再做一次独立 apktool decode。
- [x] 验证 `stroke_filter_data.bin`、设置字符串、handler XML、三个候选 helper 和 motion handler 实际进入 APK。
- [x] 验证包名、ABI、`versionName`、递增后的 `versionCode`、zipalign 和 v1/v2/v3 签名。
- [x] 运行两套 verifier 指向反向解码目录。
- [x] 对两个独立干净 decode 的补丁结果做哈希比较，证明构建可重复。

### 10.4 设备矩阵

至少覆盖：

| 维度 | 最低要求 |
| --- | --- |
| Android | 模拟器 API 34 + 一台真实设备；有条件再加 API 35/36 |
| 方向 | 竖屏、横屏 |
| 布局 | T+、QWERTY、九键、Google 独立笔画 |
| 输入类型 | 普通文本、密码、URL |
| 状态 | 无 composing、有 composing、过滤中、无匹配、数据 fail-open |
| 操作 | PRESS、短滑、滑行、长按、笔画、退格、空格、回车、候选点击、展开页 |

### 10.5 发布门槛

- [ ] `si + 丿 → 偲`、`hao + 丶 → 灏` 均通过。
- [ ] 候选点击、空格和回车提交同一全局首选。
- [ ] 长按 14 键矩阵全部通过。
- [ ] 功能默认关闭；关闭时与 `1.0.0` 无行为差异。
- [ ] 数据损坏只禁用过滤，不影响任何原输入法。
- [x] 覆盖安装上一正式版后，布局选择和用户数据保留。
- [x] README、CHANGELOG、版本号、Release Notes、许可证和 attribution 同步。

## 11. 分支、提交与回滚策略

建议分支：

```text
feat/tplus-longpress-candidates
feat/tplus-stroke-filter
```

建议提交顺序：

```text
docs(stroke-filter): add research and execution plan
feat(tplus): add letter-case choices to long-press popups
build(stroke-filter): vendor and compile Conway stroke data
feat(stroke-filter): add replayable HMM candidate filtering
feat(stroke-filter): add explicit candidate-bar capture mode
feat(stroke-filter): capture and classify explicit T+ strokes
test(stroke-filter): add build and device acceptance coverage
```

每个提交必须能单独构建。回滚优先级：

1. 设置默认关闭或运行时 fail-open；
2. 回滚 M6，保留候选调试入口用于诊断；
3. 回滚 M5–M4，仍保留无运行时代码的数据生成工具；
4. M1 可独立保留或独立回滚。

不得通过删除用户数据、改包名或换签名证书规避升级问题。

## 12. 开工顺序

开发者拿到计划后，严格按以下顺序开始：

1. 完成 M0，保留当前 `1.0.0` 基线证据。
2. 独立完成并验证 M1；不要顺手加入笔画代码。
3. 完成 M2，先让生成器与 verifier 全绿。
4. 做 M3 Spike；在 Go/No-Go 结论前不做按钮和轨迹。
5. Go 后完成 M4，优先关掉重放、双世代和默认提交三项风险。
6. 完成 M5 静态 UI 原型，先处理剪贴板 overlay 冲突。
7. 最后完成 M6 和真机阈值调参。
8. M7 只做整合、验证、版本与发布材料，不再引入新功能。

若任何任务需要改变上述范围，例如引入稀有字补充候选、替换 Google 独立笔画引擎或默认启用自动捕获，必须先更新研究方案和本计划，再开始编码。
