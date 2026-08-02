# T+ 拼音笔画过滤研究与接力实现方案

| 文档属性 | 值 |
| --- | --- |
| 状态 | 方案研究完成，关键集成待验证 |
| 目标版本 | `1.1.0` |
| 最后更新 | 2026-08-02 |
| 适用范围 | T+ 双字母布局；后续可评估复用到拼音全键盘和九键 |

具体工程拆分、排期、文件级任务和 Go/No-Go 门槛见 [T+ 拼音笔画过滤具体执行计划](tplus-stroke-filter-execution-plan.md)。

## 1. 目标与结论

目标是在已经输入拼音、候选字出现后，允许用户直接在键盘表面写一笔或多笔，将候选按汉字起始笔画过滤。例如：

```text
si + 丿  →  优先显示“偲”等首笔为撇的候选
hao + 丶 →  优先显示“灏”等首笔为点/捺的候选
```

研究结论：**可以在下一小版本实现，但不能直接移植触宝的识别引擎。** 可行方案是独立重建触摸交互，使用开放笔顺数据匹配候选，同时保留 Google 拼音原始候选对象、排序和提交链路。

推荐方案由四部分组成：

1. 在 T+ 键盘手势处理器链中增加笔画轨迹处理器；仅在“拼音正在组词 + 功能已开启 + 已进入笔画捕获状态”时从主体 `DOWN` 起认领触摸。
2. 将轨迹分类为横、竖、撇、点/捺、折五类，保存当前笔画前缀。
3. 在 `AbstractHmmIme.requestCandidates(int)` 拉取原生候选时按笔画前缀过滤，继续向后迭代直到填满当前页或候选耗尽。
4. 将“长按 T+ 字母键显示原数字/符号 + 键内字母的大小写单字候选”作为独立 XML 小迭代，先于笔画功能交付和回归。

不采用以下方案：

- 不复制触宝 smali、资源、词库或 native 库；
- 不把 Google 拼音的独立笔画输入法处理器直接塞进 T+ 的拼音处理器配置；
- 不只过滤当前屏幕已经显示的六个候选；
- 不重新构造普通拼音 Candidate 后直接提交，避免丢失 HMM 原始索引。

本轮五个问题的直接答复：

| 问题 | 结论 |
| --- | --- |
| Okinawa 能否反编译 | Java 和 Lua 可读性较高，ARM native 可反汇编并生成伪代码；但不能恢复原始源码和模型生成过程，也不作为移植路线 |
| 左右短滑/滑行会否冲突 | 自动捕获时会，而且单靠阈值不能消除；第一版推荐点击候选栏“笔”后才把轨迹交给笔画处理器 |
| Conway 怎样接入 | 构建时把固定版本数据生成紧凑 asset，运行时只过滤 Google 拼音 Candidate；不替换 Google 原生笔画布局和 HMM |
| 两套笔画键盘是否相同 | 前五类及顺序相同，通配、分隔/词语、标点、数字入口和 TouchPal 下滑部件键均不同 |
| 长按大小写候选怎样做 | 复用 Google 已有多候选 popup XML；14 个 T+ 组合键均保留原数字/符号第一项，再列键内字母的小写和大写 |

本文术语约定：

- `composing`：尚未提交到应用、仍由拼音/HMM 引擎维护的输入状态；
- `PRESS`：T+ 组合键的普通按下动作，交给两字母等权解码；
- `touch slop`：系统用于区分点击与移动的最小位移阈值；“短滑”指键内左右滑，“滑行”指跨键连续轨迹；
- `DECODE`：把键值送入拼音解码；`COMMIT`：直接向应用提交文本；
- `Candidate`：Google 候选对象；`payload` 是其关联的 HMM 原始索引，过滤时必须原样保留。

## 2. 预期交互

### 2.1 开关与启用条件

新增设置项“拼音笔画过滤”，默认关闭。第一阶段只对 T+ 生效。为避免把正常的第二个、第三个拼音短滑误当作笔画，推荐增加候选栏“笔”按钮；满足以下条件才接管轨迹：

```text
功能已开启
AND 当前布局为 T+
AND 当前存在未提交的拼音 composing
AND 用户已点击“笔”进入笔画捕获状态
```

“笔”按钮采用持续模式：进入后可连续写一至五笔，再次点击退出；提交、取消、清空 composing 或切换布局时自动退出。显式进入“笔”状态后，键盘主体的下一次 `DOWN` 就由笔画处理器认领，后续点击、长按、键内短滑和跨键滑行均不再交给 T+；过短轨迹只被消费、不产生笔画，也不能回退成 `PRESS`。用户需要再次点击候选栏“笔”退出，才能恢复原 T+ 操作。没有 composing 或没有进入笔画状态时，T+ 当前的点击双字母、左右短滑选单字母、长按菜单和跨键滑行输入必须保持不变。

### 2.2 过滤状态

候选栏附近显示当前状态，例如：

```text
过滤：丿
过滤：丿一
```

推荐先实现最多五笔；继续书写时追加笔画并重新筛选。状态规则：

- 退格：先删最后一笔；没有过滤笔画后才删除拼音；
- 选中候选、空格提交、回车提交、取消 composing、切换布局或开始下一词：清空过滤状态；
- 没有匹配项：保留拼音和笔画状态，显示“无匹配候选”，允许退格撤销；
- 候选相对次序：保持 Google 原始排序，不自建第二套排名。

### 2.3 与 T+ 左右短滑的冲突

T+ 当前每个双字母键同时定义了：

```xml
PRESS       → 两个字母等权解码
SLIDE_LEFT  → 左侧字母
SLIDE_RIGHT → 右侧字母
```

所以若只用“当前有 composing + 位移超过阈值”自动接管，横、撇、点等笔画会与左右短滑发生实质冲突，而且会影响用户继续输入后续拼音。比如右短滑输入 `s` 后 composing 已经成立，紧接着再右短滑输入 `i` 时，第二段轨迹已经满足笔画处理器的启用条件。

Google 框架的实际阈值进一步说明，单靠距离不能给出可靠的无冲突边界：

- T+ 使用 `slide_sensitivity="LESS"`，对应 `slide_less_sensitivity = 32dp`；
- 长按默认延迟是 `300ms`，长按触发后 Basic handler 会立即 `declareTargetHandler()`；
- 触宝旧版只在最大位移小于约 `20px` 时把短触摸回退给下层；
- 横笔与左右短滑在方向上完全同形，短点/捺与点击或斜向短滑也可能同形。

因此距离、角度、速度只能降低误判，不能从语义上消除冲突。尤其不能把“32dp 以下归短滑、以上归笔画”当成稳定协议：用户完全可能写出超过 32dp 的横向短滑，也可能写出很短的点。

推荐第一版使用显式捕获状态：

| 状态 | 点击/长按 | 左右短滑 | 长跨键轨迹 |
| --- | --- | --- | --- |
| 无 composing | 原 T+ 行为 | 原 T+ 行为 | 原 Google 滑行输入 |
| 有 composing，未进入“笔”状态 | 原 T+ 行为 | 原 T+ 精确单字母 | 不由过滤器拦截，交给原 Google gesture handler |
| 有 composing，已进入“笔”状态 | 全部由笔画处理器消费；小于 slop 不产出 | 五类笔画 | 五类笔画 |

如果必须完全复刻触宝的“拼音后直接写”交互，可额外提供实验性“自动捕获”模式，但应明确告知：composing 期间明显左右短滑和滑行轨迹优先作为笔画，不能承诺继续精确输入单字母。此模式不应成为默认值。

长按菜单与笔画捕获的边界因此是确定的：未进入“笔”状态时，笔画 handler 绝不认领，Basic handler 可按原有约 300ms 语义弹出菜单；进入“笔”状态后，键盘主体触摸从 `DOWN` 起全部归笔画 handler，长按菜单有意不可用，必须先点击候选栏“笔”退出。只有将来另做实验性“自动捕获”时，才需要研究延迟认领与长按计时的竞争，该模式不能进入第一版默认路径。

## 3. 触宝 APK 逆向证据

### 3.1 样本与边界

本地研究样本：

| 字段 | 值 |
| --- | --- |
| APK | `TouchPal.apk` |
| 包名 | `com.cootek.smartinputv5` |
| 版本 | `5.7.9.0`（versionCode 5661） |
| 解码目录 | `work/analysis/touchpal-decoded` |
| JADX 目录 | `work/analysis/touchpal-jadx` |

该 APK 只用于互操作研究。公开到仓库的实现不得包含 APK、触宝代码、图片、词典、native 库或经复制改写的资源。

### 3.2 功能确实存在

`res/values/strings.xml` 包含：

```text
guide_intro_show_page_stroke_filter_title = Stroke filtering
optpage_stroke_filter                     = Stroke filtering
optpage_stroke_filter_summary             = Find expected word easily by stroke filtering
stroke_filter_prefix                      = |过滤:
wizard_tips_bihua_filter                  = Stroke一(Hen),丨(Shu) and so forth to filter candidates
paopao_teaching_pinyin_first              = Type ru for 入
paopao_tesching_bihua_then                = Write the stroke(s) on keyboard surface
```

设置入口位于 `res/layout/option_inte.xml`，键名是 `option_stroke_filter`。这说明它是可选功能，而不是单独的输入法布局。

公开资料也描述了相同交互：输入拼音后在键盘上写首笔，例如 `hao + 丶` 过滤出“灏”。参考 [PingWest 的 2014 年触宝输入法介绍](https://www.pingwest.com/a/40995)。

### 3.3 界面与调用链

触宝包含两组过滤界面：

- `res/layout/filter_bar.xml`：`FilterBar`，用于展示可选过滤项；
- `res/layout/filter_view.xml`：`FilterScroll` 内嵌 `SoftKeyboardView`，`bufferTag="filter"`。

Java/smali 层的主要链路：

```text
HandWriteMaskManager
  → 在拼音候选状态覆盖 HandWriteMaskView
  → 收集 MoveContrail 轨迹
  → Engine.fireHandwriteOperation(...)
  → Okinawa.fireHandwriteOperation(...) [native]
  → FilterManager / FilterProvider 读取过滤项
  → FilterBar 点击 fireSelectFilterOperation(index)
```

`FilterItem` 定义了四种类型：

```text
1 TYPE_PHONEPAD_RESOLVE
2 TYPE_PINYIN_FILTER
3 TYPE_MISTYPE_CORRECT
4 TYPE_HANDWRITE_FILTER
```

`Okinawa.smali` 声明了以下 native 方法：

```text
fireHandwriteOperation(MoveContrail)
fireSelectFilterOperation(int)
getActiveFilterItem(FilterItem)
getFilterItem(int, FilterItem)
getFilterSize()
getFilterType()
getWordFilter()
```

关键识别和候选过滤发生在触宝私有 native 引擎内，因此无法从 APK 得到原始、可维护的 Java 实现；直接搬用还存在许可与来源风险，也不符合本项目的独立实现边界。本项目只复刻可观察的交互概念并独立实现算法。

### 3.4 原版触摸判定

`HandWriteMaskView.smali` 的常量和分支表明，短触摸回退条件同时包含：

```text
持续时间 < 1500 ms
最大位移平方 < 0x190（400，即约 20 px）
```

满足条件时事件继续传给下层键盘；否则轨迹提交给 `fireHandwriteOperation`。这里的 `20 px` 只能作为还原行为的证据，不能直接作为现代高密度设备参数。新实现应使用 `ViewConfiguration.getScaledTouchSlop()`、键宽比例和真机采样共同确定阈值。

### 3.5 Okinawa 能否反编译

结论是：**能逆向分析到调用、数据流和相当一部分伪代码，但不能还原为原始、可维护、可直接移植的源码。** “可以反编译”需要按层次区分：

| 层次 | 本地样本证据 | 可恢复程度 |
| --- | --- | --- |
| Java/Dex | `Okinawa.java` 暴露数百个 native 方法，JADX 可读 | 高；能恢复 JNI 方法签名、对象字段和 Java 调用链 |
| 键盘/语言 Lua | `assets.zip` 内的 `TouchPalResources.tprc` 本身是 ZIP；`.sur.png`、`.trt.png` 实际以 `LuaQ` 开头，是 Lua 5.1 字节码 | 中到高；可反汇编常量、表结构和事件脚本，调试信息存在时可进一步反编译 |
| native 引擎 | `lib/armeabi/libsmartinputv5_ol.so`，2,616,128 字节，ELF32 little-endian ARM (`e_machine=0x28`) | 中；Ghidra/IDA 可生成伪代码，但类型、局部变量名、注释和源码结构不会回来 |
| 词典/模型 | `bihua.rom.png`、`pinyin*.rom` 等私有二进制 | 低；能做格式和访问行为研究，无法自然还原训练/生成过程 |

native 库不是完全“黑盒”，但也不是带完整调试符号的构建：样本含 `.dynsym`、`.dynstr`，没有发现 `.symtab` 或 DWARF debug 段；仍保留了大量 JNI 导出名和约 358 个可见的 C++ mangled name 字符串，例如：

```text
Java_com_cootek_smartinput5_engine_Okinawa_fireHandwriteOperation
Java_com_cootek_smartinput5_engine_Okinawa_getFilterItem
Java_com_cootek_smartinput5_engine_Okinawa_getFilterSize
_ZN6Engine24fire_handwrite_operationEv
_ZN6Engine23get_handwrite_operationEv
```

所以技术上可以从 JNI 入口追到 `Engine` 的手写操作，再结合 `MoveContrail`、`FilterItem` 和运行时观测还原协议；动态调试则还要处理 ARM-only ABI、旧 Android 运行环境和完整私有资源加载。它更适合回答“触宝的事件顺序和状态语义是什么”，不适合回答“怎样把算法复制进 Google 拼音”。

本项目的边界保持不变：只记录可观察的接口、键位和行为，用开放数据和独立算法重建；不复制 TouchPal 的伪代码、Lua 脚本、ROM 数据或 native 例程。即使投入更多逆向时间，这条边界也不会改变，因此 Okinawa 深挖不是 `1.1.0` 的前置任务。

## 4. Google 拼音现有能力与限制

### 4.1 已有独立笔画输入引擎

Google 拼音 APK 已经包含笔画输入相关组件：

```text
HmmStrokeDecodeProcessor
AbstractHmmChineseStrokeDecodeProcessor
libhmm_gesture_hwr_zh.so
libhwrword.so
libpinyin_data_bundle.so
```

`res/xml/softkeys_input_stroke.xml` 的编码为：

| 笔画 | 编码 |
| --- | --- |
| 横 | `h` |
| 竖 | `s` |
| 撇 | `p` |
| 点/捺 | `n` |
| 折 | `z` |
| 通配 | `*` |

`AbstractHmmChineseStrokeDecodeProcessor` 接收正则 `[hspnz\*]`，`HmmStrokeDecodeProcessor` 使用语言引擎 `zh-t-i0-stroke`。

但 `processors_zh_cn_stroke.xml` 和 `processors_zh_cn_pinyin_9key.xml` 都只注册一个相同 id 的 `ime_decode_processor`：前者是笔画处理器，后者是 `HmmPinyinT9DecodeProcessor`。T+ 当前复用九键拼音处理器。直接在 XML 里再加一个处理器不能让两套 HMM 自动共享 composing、候选索引和选择状态。

结论：Google 自带笔画引擎适合作为行为参考或后续实验项，不适合作为第一版的拼音候选过滤器。

### 4.2 T+ 手势处理器链

当前 `patches/res/xml/keyboard_zh_cn_pinyin_tplus.xml` 注册：

```text
BasicMotionEventHandler
PinyinGestureHandler
PinyinKeyboardLayoutHandler
ScrubMoveMotionEventHandler
```

框架 `IMotionEventHandlerDelegate` 提供 `declareTargetHandler()` 和 `fireEvent()`。`atu.smali` 会在尚无目标处理器时依次把同一个事件交给多个 handler；某个 handler 认领后，其余 handler 被 reset，后续事件只发送给目标 handler。

因此可在 `BasicMotionEventHandler` 之前插入新的 `StrokeFilterMotionEventHandler`。第一版的显式模式使用确定性归属：

1. 未进入“笔”状态时，handler 立即返回且永不认领；
2. composing 有效且已进入“笔”状态时，在键盘主体 `DOWN` 上立即调用 `declareTargetHandler()`；
3. 原 Basic/gesture handler 被 reset，当前整段轨迹只归笔画处理器；
4. `MOVE` 采样并绘制轨迹，`UP` 时分类笔画并通过自定义 Event 发给输入法；
5. 若总轨迹小于 touch slop，则只消费、不分类，也不回退为 T+ `PRESS`。

这避免了同一次触摸先被 Basic/gesture 解释、越阈值后又改判笔画的竞态。需要在模拟器验证 `DOWN` 立即认领是否按预期 reset 后续 handler；若框架不允许这一顺序，再在分发处增加严格受“当前布局为 T+ + composing 有效 + 已进入笔状态”约束的预处理，而不是覆盖整个键盘的普通 Android View。

实验性“自动捕获”是另一套仲裁：它必须在 `DOWN` 后旁观，到 `MOVE` 越阈值才认领，因而仍会与短滑、滑行和长按计时竞争。不要让实验分支改变第一版显式模式的事件语义。

### 4.3 候选对象必须原样保留

`HmmEngineCandidateIterator` 生成的 `Candidate` payload 是 HMM 原始候选索引。候选点击最终会调用：

```text
IHmmEngineWrapper.selectCandidate(Candidate)
```

若只提取文字再构造新 Candidate，容易丢失 payload，导致提交错误或 `IllegalArgumentException`。过滤应当只决定“保留或跳过”，并把原 Candidate 对象原样传给候选栏。

已有剪贴板候选功能在 `InputBundle.appendTextCandidates()` 上做列表装饰，证明原生候选栏可以安全接收经过处理的列表；但笔画过滤需要比装饰更早地介入迭代器，因为目标字可能尚未被当前页拉取。

### 4.4 必须扫描深层候选

`AbstractHmmIme.requestCandidates(int)` 从 `mTextCandidateIterator` 取 Candidate，直到满足请求数量，并把 iterator 的 `hasNext()` 传给候选 UI。

推荐把过滤放在这个循环内。下面的 `session.firstMatchedCandidateForFilter` 指当前过滤请求从 Google 原始顺序中遇到的第一个匹配 Candidate，不是重新构造的文字候选，也不是当前页首项：

```text
while output.size < requested AND session.hasUnreadRawCandidate:
    candidate = session.nextRawCandidate()  // cache 重放优先，其次 source iterator
    if strokeFilterInactive OR matches(candidate):
        output.add(candidate)    // 保留原对象与 payload
        if session.firstMatchedCandidateForFilter == null:
            session.firstMatchedCandidateForFilter = candidate
appendTextCandidates(output, session.firstMatchedCandidateForFilter,
                     session.mayHaveMoreRawCandidates)
```

不能采用“先让 Google 取六个，再从六个中删除不匹配项”的方案，否则当前页没有目标字时会显示空白，也永远到不了深层候选。

但原生 iterator 是前向消费的，笔画前缀从 `3` 变成 `31`、退格回到 `3` 或清空过滤时，不能从已经被跳过的位置继续。必须给每一轮 composing 建立 `StrokeFilterCandidateSession`：

```text
composingGeneration   // HMM composing 世代，隔离 Candidate payload 生命周期
filterGeneration      // 笔画前缀/UI 请求世代，丢弃过期分批扫描结果
sourceIterator        // Google 原始、只向前消费的 iterator
rawCandidateCache[]   // 已从 sourceIterator 读取的原 Candidate 对象
rawCursor             // 当前过滤前缀在 cache 中的重放位置
sourceExhausted
firstMatchedCandidateForFilter
```

- 首次扫描时，每从 `sourceIterator` 读取一个 Candidate，就先把原对象追加到 `rawCandidateCache`，再判断是否匹配；
- 追加、删除或清空笔画前缀时递增 `filterGeneration`，取消旧 runnable/旧 UI 请求，将 `rawCursor` 重置为 `0` 并清空 `firstMatchedCandidateForFilter`；随后先按 Google 原始顺序重放缓存，缓存耗尽后再继续消费同一个 source iterator；
- 清空过滤后同样从缓存开头恢复未过滤候选，不能丢掉此前被过滤器跳过的对象；
- 仅展开/分页同一个过滤结果时不递增 `filterGeneration`，也不改写 `firstMatchedCandidateForFilter`，保证空格/回车始终指向整个结果集的第一项；
- 退出“笔”捕获但保留当前过滤前缀时，也递增 `filterGeneration`、取消旧任务并从 cache 重新发起同前缀请求；fail-open 时递增它并改为无过滤重放；
- 拼音 composing 内容变化、候选被提交、abort、finish input 或布局切换时，递增 `composingGeneration` 并销毁整个 session；
- cache 只保存当前 composing 的原 Candidate 引用，不能跨 composing 复用 payload；实现应记录峰值并设硬上限，但不可逐出头部对象，否则无法重放。若即将超限，应停止更深过滤、本 composing 会话 fail-open：退出“笔”、从已缓存对象开头恢复原顺序并继续原 source iterator，直到下一轮 composing 才允许重新启用。

还要限制单次扫描工作量，例如每批检查 256 或 512 个原始候选。达到预算但尚未填满页面时，不能把暂时空白误报成“无匹配”，也不能被动等待用户翻页：UI 显示“正在筛选…”，在下一帧/主线程 handler 继续同一 `(composingGeneration, filterGeneration)` 的下一批；每次写 UI 前同时比对两个 token，直到找到首个/填满当前请求、iterator 耗尽或请求已过期。只有 `sourceExhausted=true` 且仍无结果时才能显示“无匹配候选”。

如果现有候选 UI 无法安全地增量替换同一请求的结果，阶段 B 必须先做专门原型，确定一次性后台扫描或安全刷新路径；不能用“扫描 512 个后返回空页”作为发布实现。

### 4.5 首选候选与空格提交

过滤后的首个可见候选不一定是 HMM 原始首选。若只改变列表，不同步选中状态，按空格可能提交一个已被隐藏的候选。

`IHmmEngineWrapper` 已提供以下看似相关的接口：

```text
highlightCandidate(Candidate)
selectCandidate(Candidate)
unselectCandidate()
```

但“视觉高亮”“空格/回车默认提交目标”和“用户点击后真正选择”是三个不同动作，不能因为方法名称相近就混用：

- 视觉高亮：优先验证 `highlightCandidate()` 是否只改变 UI/引擎高亮且不推进 composing；
- 默认提交：查明 Google 当前空格/回车读取的首选字段或调用路径，把默认目标切到 `session.firstMatchedCandidateForFilter`；
- 点击提交：只有用户明确点击候选或执行提交动作时，才沿用原链调用 `selectCandidate(candidate)`；绝不能为了刷新高亮提前调用它。

实现必须保存当前 `filterGeneration` 的 `session.firstMatchedCandidateForFilter`，并验证：

- 候选栏高亮的是第一个匹配项；
- 空格/回车提交第一个匹配项，而不是原始第一候选；
- 点击任意匹配项仍使用该对象自己的 HMM payload；
- 删除最后一笔后，原始首选和高亮状态能恢复。

若 `highlightCandidate()` 会改变 composing，或默认提交路径无法与过滤列表同步，阶段 B 不得以“看起来第一项高亮”判定完成；需要在 `AbstractHmmIme` 的首选字段/空格事件链上另设受过滤状态保护的挂点。

### 4.6 Google 内置笔画键盘与触宝笔画键盘的细节差异

两者都采用“横、竖、撇、点/捺、折”的五类规则，前五个输入码语义一致，但 3×3 主键区并不相同。

| 位置 | Google 拼音内置笔画 | TouchPal 5.7.9 笔画 |
| --- | --- | --- |
| 第一行 | 横 `h` / 长按 `1`；竖 `s` / `2`；撇 `p` / `3` | 横 `㇐`；竖 `㇑`；撇 `㇓` |
| 第二行 | 点/捺 `n` / `4`；折 `z` / `5`；通配 `*` / `6` | 点/捺 `㇏`；折 `㇕`；“词语”内部码 `` ` `` |
| 第三行 | 分隔符 `'` / `7`；全角 `！` / `8`；全角 `？` / `9` | 通配 `*`；全角冒号 `：`；省略号 `…` |
| 数字入口 | 每个主键长按输入 `1–9`；空格长按 `0`；Shift 可把整块切到数字 1–9 | 本地 Lua 为九键显式定义 `on_click`、`on_slide_down`，并提供独立 `sk_num` 入口；未在脚本层发现九键长按数字映射 |
| 附加快捷输入 | 左侧独立标点面板；右侧 Shift/光标/删除；第三行保留分隔符和问叹号 | 九个主键均有下滑部件快捷项：`足 疒 纟 / 钅 宀 月 / 衤 雨 走` |
| 折的视觉 | Google 使用主题图标 `IconStrokeZhe` | TouchPal 主标题使用“乙”，实际输入 glyph 为 `㇕` |

TouchPal 的布局是从 `chsstroke_soft.sur.png` 的 Lua 5.1 字节码常量和指令恢复出来的。它按顺序创建九个 softkey：

```text
主标题：一  丨  丿  丶  乙  词语  通配  ：  …
输入码：㇐  ㇑  ㇓  ㇏  ㇕  `     *     ：  …
下滑项：足  疒  纟  钅  宀  月    衤    雨  走
```

Lua 指令可以确认冒号和省略号调用文本提交；“词语”键的标题、keyname 和内部码表明它是 TouchPal 笔画引擎的序列/词语控制项，这是高可信静态推断，但实际动态效果仍需实机确认，不能把它直接等同于 Google 的撇号分隔键。Google 的通配键在第六格、TouchPal 在第七格，因此通配位置变化必须列为迁移回归点。

TouchPal 的 `chsstroke_soft_mainland` surface 模板由 native 层提供，本轮只确认了 Lua 显式赋予的 click/slide-down 行为。模板层是否还隐含未写在 Lua 中的长按默认动作，需实机操作后才能彻底排除；因此上表对数字入口使用“未发现”，不把它升级成已证明不存在。

本项目不需要把 TouchPal 的独立笔画键盘覆盖到 Google 上。拼音笔画过滤只借用五类语义；用户真正切换到 Google 的“笔画”布局时，仍保留 Google 原生 3×3 键位、数字长按、分隔符和 HMM 解码行为。

## 5. 模拟器验证记录

### 5.1 环境

| 字段 | 值 |
| --- | --- |
| Android SDK | `E:\Android\Sdk` |
| 设备 | `emulator-5554` / `sdk_gphone64_x86_64` |
| 测试包 | `com.google.android.inputmethod.pinyin.compat.tplus` |
| 默认 IME | `com.google.android.inputmethod.pinyin.PinyinIME` |
| 测试输入框 | Android 设置搜索框 |

### 5.2 `si` 候选深度

在 T+ 上通过右短滑精确输入 `s`、`i`。首屏候选为：

```text
四、死、斯、思、丝、司
```

展开后继续观察了四页，出现了以下候选：

```text
似、寺、私、撕、肆、巳
厮、食、嗣、嘶、饲、洒
祀、伺、俟……
```

四个展开页内仍未看到“偲”。这不证明 Google 词库完全没有“偲”，但足以证明只过滤首屏或当前已加载页不能满足目标用例。

因此 `si + 丿 → 偲` 必须作为集成验收门槛：

1. 先实现原生 iterator 深度扫描；
2. 若 iterator 最终能返回“偲”，直接保留 Google Candidate；
3. 若 iterator 耗尽仍没有“偲”，再进入第二阶段，增加“开放笔顺数据 + 补充拼音映射”的稀有字候选注入。

第一阶段不要预先引入补充候选，以免同时承担候选过滤和拼音词典扩展两类风险。

## 6. 笔顺数据源评估

### 6.1 推荐：Conway Stroke Data

推荐使用 [stroke-input/stroke-input-data](https://github.com/stroke-input/stroke-input-data)：

- 约 2.8 万以上汉字条目；
- 使用五类编码：`1` 横、`2` 竖、`3` 撇、`4` 点/捺、`5` 折；
- `codepoint-character-sequence.txt` 提供 Unicode code point、字符和“笔顺序列正则”；
- 笔顺序列采用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)，排名数据为 Public Domain，工具脚本为 MIT-0。

本研究固定到 2026-07-30 的 commit [`a657f5b7554ace8d97a4d9a87aca391b24363458`](https://github.com/stroke-input/stroke-input-data/commit/a657f5b7554ace8d97a4d9a87aca391b24363458)。该版本原始文件为 935,781 字节、29,942 行：

```text
SHA-256  2da408c8982613020bda7ad16b76a3b28e93843afcd207e8bb2c9c743727f123
```

目标字记录为：

```text
U+5072  偲   32251214544
U+704F  灏*  441251141251234132534
U+705D  灝^  441251141251234132511134
```

由此可验证：

- “偲”的首笔编码为 `3`，即撇；
- “灏/灝”的首笔编码为 `4`，即点/捺。

字符列可能带来源注记符号，生成器应以 `U+XXXX` code point 构造字符，并把字符列只用于校验，不应把 `*`、`^` 一并打包进运行时键值。

数据并不保证每个字只有一条纯数字序列。例如 `万` 是 `(135|153)`，`丑` 是 `(5121|5211)`；更复杂条目包含不超过五个捕获组和反向引用。上游 `generate.py` 的 `to_sequence_set()` 会枚举捕获组选项并实现反向引用，生成器不能用“删除括号和竖线”这样的简化解析，否则会漏掉合法笔顺或制造错误前缀。

该数据由人工整理，上游也明确提示可能存在错误。因此它是过滤辅助数据，不应被描述成 Google 词库或国家标准的替代品；遇到高频字明显不匹配时，应能通过固定 commit、code point 和原始正则快速追溯并加本地测试。

### 6.2 不推荐作为第一选择的数据源

| 数据源 | 优点 | 不作为首选的原因 |
| --- | --- | --- |
| Google 自带 `zh-t-i0-stroke` | 已在 APK 内、无需新增外部数据 | API 面向独立笔画解码，不提供“给定汉字查询完整五类笔顺”的稳定 Java 接口 |
| [Make Me a Hanzi](https://github.com/skishore/makemeahanzi) | 约 9,000 字并带矢量笔画 | 覆盖较少，图形数据体积大，许可和数据加工链更复杂 |
| [Unicode UAX #38 / Unihan](https://unicode.org/reports/tr38/) | 权威 Unicode 属性 | 提供总笔画、部首等信息，不提供本功能需要的完整五类笔顺序列 |

### 6.3 打包格式

不要把约 1 MB 的文本文件放进 APK 后在运行时逐行解析。推荐把固定版本的原始文件和许可留在仓库 `third_party/`，在构建补丁时离线生成紧凑 asset：

```text
sortedCodePoints[]       // 升序 Unicode code point
variantOffsets[]         // 每个 code point 的变体起始位置
variantCounts[]          // 每个 code point 的笔顺变体数
packedPrefixVariants[]   // 每个变体：长度 + 最多五笔，每笔 3 bit
```

构建时流程：

1. 读取固定 commit 的 `codepoint-character-sequence.txt`，校验文件 SHA-256；
2. 按上游 `to_sequence_set()` 的规则展开 `(...)`、`|` 和 `\1..\5` 反向引用；
3. 每个完整变体只保留前五笔并去重；
4. 以 code point 排序后写入带 magic、格式版本、条目数和来源摘要的二进制 asset；
5. 对 `偲`、`灏/灝`、纯数字序列、可选空分支、多个变体和反向引用分别做生成器测试。

运行时流程：

1. 对候选文字的目标汉字取 code point；
2. 二分查找 `sortedCodePoints`；
3. 读取该字符的一到多个前缀变体，只要任一变体匹配当前用户笔画前缀就保留 Candidate；
4. 数据只加载一次，不在每个 Candidate 上做文件 I/O。

Android 侧建议把产物注册为 `res/raw/stroke_filter_data.bin`，由进程内懒加载单例读取。Java 源码可用 `Resources.openRawResource(R.raw.stroke_filter_data)`；本项目手写 smali 时应先用 `Resources.getIdentifier("stroke_filter_data", "raw", packageName)` 解析 ID，再调用 `openRawResource(id)`，避免硬编码可能被 aapt2 重排的 `0x7f...` 常量。加载器先校验 magic、格式版本、条目数、各段边界、code point 排序和嵌入的上游来源摘要，再发布不可变索引；不能在半解析状态下被其他请求看到。

失败策略必须是 fail-open：资源缺失、版本不支持、边界/摘要校验失败或内存不足时只记一次诊断日志，本输入会话禁用笔画过滤并隐藏/退出“笔”状态，原 T+ 拼音候选和 Google 独立笔画输入法继续工作。不要因附加数据损坏让整个 IME 初始化失败。

第一版只比较前五笔，不需要把完整序列或运行时正则引擎打进 APK。具体体积应由生成器产物报告和 APK 实测决定，不在实现前承诺固定区间；目标是保持在数百 KB 量级，并以低于候选扫描开销为准。

仓库必须同时加入数据来源、固定 commit、原始文件 SHA-256、生成方式和 CC BY 4.0 attribution，确保离线可复现构建。

### 6.4 与 Google 原生笔画输入法的接入关系

**Conway 数据是新增的只读“汉字 → 可接受笔顺前缀”索引，不替换、不修改 Google 原生笔画输入法。** 两条路径的职责如下：

```text
T+ 拼音笔画过滤
  Google 拼音 HMM 产生 Candidate
    → Conway 索引判断 Candidate 首字是否匹配
    → 保留原 Candidate/payload 并显示、提交

Google 独立笔画布局
  h/s/p/n/z/* 按键
    → HmmStrokeDecodeProcessor
    → zh-t-i0-stroke 原生引擎产生和提交 Candidate
```

因此接入时不动 `processors_zh_cn_stroke.xml`、`HmmStrokeDecodeProcessor`、`softkeys_input_stroke.xml` 或 Google 的 native 数据包。Conway asset 只由 `StrokeFilterCompat` 在 T+ 过滤状态下读取；功能关闭或切换到独立笔画布局时完全不参与。即使过滤挂点位于共享的 `AbstractHmmIme`，也必须同时满足“当前布局是 T+、功能开启、`composingGeneration` 有效、笔画前缀非空”才进入过滤分支，其他拼音布局和独立笔画布局直接走原路径。

如果未来要用 Conway 自建一套完整笔画输入法，那是另一项产品和排序工程：需要字符/词组候选生成、频率排序、分页、学习和提交链，不应与当前“过滤 Google 拼音候选”的轻量旁路混在一起。

## 7. 推荐实现架构

### 7.1 新增组件

| 组件 | 职责 |
| --- | --- |
| `StrokeFilterMotionEventHandler` | 未激活时绝不认领；显式“笔”状态下从键盘主体 `DOWN` 起独占、绘制/清理轨迹并分类五种笔画 |
| `StrokeFilterCompat` | 保存开关、捕获状态、composing 和笔画前缀；查询数据；匹配 Candidate；处理退格与清理 |
| `StrokeFilterCandidateSession` | 按 composing 世代缓存并重放原 Candidate；用独立 filter 世代管理前缀请求、全局首个匹配项、分批续扫与过期 UI |
| 候选栏“笔”入口 | composing 有效时进入/退出持续笔画捕获；显示激活态和当前前缀 |
| `StrokeFilterData` 或二进制 asset | code point 到五类笔顺前缀的紧凑映射 |
| 数据生成脚本 | 从固定版本的 Conway 数据生成 asset，并校验目标样例 |
| 静态验证脚本 | 检查资源注册、handler 顺序、smali 挂点、数据样例和补丁幂等性 |

建议沿用当前项目“补丁源文件 + `scripts/apply_patches.py` 写入解码目录 + verifier”的模式，不直接把临时反编译目录作为源代码提交。

### 7.2 接入点

优先顺序如下：

1. `patches/res/xml/keyboard_zh_cn_pinyin_tplus.xml`
   - 在 Basic handler 前注册 `StrokeFilterMotionEventHandler`；
   - handler 内同时检查 preference、composing 与显式“笔”状态，未激活时绝不认领。
2. `HmmPinyinT9DecodeProcessor`
   - 接收自定义笔画 Event；
   - composing 存在时追加笔画并请求候选刷新；
   - 过滤前缀存在时优先消费退格。
3. `AbstractHmmIme.requestCandidates(int)`
   - 在 iterator 循环中跳过不匹配 Candidate；
   - 通过 `StrokeFilterCandidateSession` 缓存原 Candidate，前缀变化时从缓存开头重放；
   - 继续拉取直到填满、达到本批扫描上限或 iterator 耗尽；未完成时携带 composing/filter 双 token 安排下一批；
   - 将第一个匹配 Candidate 作为可见高亮和空格/回车默认目标；`selectCandidate()` 只在明确提交时调用。
4. composing 提交/重置路径
   - 候选选中、commit、abort、finish input、布局切换时调用 `StrokeFilterCompat.clear()`。
5. 设置与字符串
   - 新增“拼音笔画过滤”开关、候选栏“笔”入口和实验性自动捕获说明；
   - 默认关闭，升级不改变既有 T+ 手感。

候选栏当前没有空闲 softkey 槽位：`keyboard_candidates_header_inner.xml` 中只有填满宽度的 `FixedSizeCandidatesHolderView` 和右侧 `key_pos_show_more_candidates`。推荐先做一个静态 UI 原型，再选以下两种实现之一：

1. 复用仓库已有 `compat_clipboard_dismiss` 的 tag-overlay 模式，新增默认 `gone` 的 `compat_stroke_filter_toggle`，由 `StrokeFilterCompat` 安装 click listener；按钮位于“展开候选”左侧，显示“笔”及激活态；
2. 若共享候选栏 overlay 无法正确预留宽度，则为 T+ 建专用 header/candidate-inner layout，不影响 QWERTY、九键、笔画和手写布局。

无论采用哪种，都必须保证：候选 holder 不被按钮遮住；“笔”与展开候选可同时点击；展开页、剪贴板关闭层和“笔”按钮不会重叠；非 T+、功能关闭和无 composing 时按钮完全隐藏。这里仍是待原型验证的 UI 接入点，不应在实现前假定共享布局加一个 View 就足够。

### 7.3 候选匹配规则

第一版应限制语义，避免多字短语出现无法解释的结果：

- 只在单音节、尚未部分选词时启用；
- 只匹配 Candidate 显示文本的第一个汉字；
- 非汉字、emoji、Latin 文本和无笔顺数据的字符视为不匹配；
- 原 Candidate 对象和原始相对顺序不变。

完成单字路径后，再评估多音节和部分选词。推荐的扩展语义是“过滤当前尚未确认部分的第一个汉字”，而不是要求短语中每个字都匹配同一笔画前缀。

### 7.4 轨迹分类

第一版不需要训练模型。对采样折线做去抖和归一化后，可使用几何规则：

| 类别 | 基本特征 |
| --- | --- |
| 横 | 主方向近水平，整体由左向右 |
| 竖 | 主方向近垂直，整体由上向下 |
| 撇 | 整体由右上向左下 |
| 点/捺 | 整体由左上向右下；短点也归入此类 |
| 折 | 存在超过阈值的明显转角或主方向切换 |

实现注意：

- 使用低通/抽稀后的点列，避免手指抖动把直线误判为折；
- 使用键盘宽高归一化坐标，不依赖绝对像素；
- 轨迹长度低于 touch slop 时不分类；
- “折”必须依据形状转折，不应简单等同于向上滑；
- 记录分类置信度和轨迹摘要到可关闭的调试日志，便于真机调参；
- 不记录或上传用户输入内容。

### 7.5 T+ 字母键长按多候选

这项需求不需要新 popup View。Google 中文拼音全键盘已经使用同一框架表达多候选长按，例如：

```xml
long_press_data="1 q Q"
keycode="PLAIN_TEXT"
intention="COMMIT"
popup_layout="@attr/PopupBubbleRectangularLayout"
```

T+ 只需把当前单值 `alternate_data` 拆成“主替代字符 + 两个单字母的小写 + 两个单字母的大写”，并把小气泡布局换成能容纳数组的矩形布局。推荐菜单顺序始终把现有数字/符号放第一位，保留用户原来的长按肌肉记忆：

| T+ 键 | 长按候选 |
| --- | --- |
| `Q W` | `1 q w Q W` |
| `E R` | `2 e r E R` |
| `T Y` | `3 t y T Y` |
| `U I` | `4 u i U I` |
| `O P` | `5 o p O P` |
| `A S` | `6 a s A S` |
| `D F` | `7 d f D F` |
| `G H` | `8 g h G H` |
| `J K` | `9 j k J K` |
| `Z X` | `@ z x Z X` |
| `C V` | `! c v C V` |
| `B N` | `? b n B N` |
| `L -` | `0 l L`；连字符仍保留右滑输入 |
| `M '` | `, m M`；撇号仍保留右滑输入 |

大小写 T+ 模板使用同一组候选，避免 Shift 状态下缺少当前大小写。所有条目先沿用 Google 中文全键盘的 `COMMIT`，目标语义是直接输出 Latin 字母/数字/符号，而不是把所选字母送入拼音 `DECODE`。但在已有 composing 时，不能自行规定它是“保留拼音”“先提交拼音”还是“清空拼音”：产品判定基准是 Google 原生中文 QWERTY 对等长按序列的实际行为，T+ 必须与它的上屏文本、光标位置和 composing 状态逐项一致。

实现范围预计只有：

- `patches/res/xml/softkeys_input_zh_cn_pinyin_tplus.xml` 增加 `long_press_data` 参数并切换 popup layout；
- `scripts/verify_tplus.py` 断言 14 个菜单的顺序、大小写和原数字/符号均存在；
- 构建后反向解码和模拟器/真机选择测试。

菜单展开后需要滑动手指选择。未激活“笔”时笔画 handler 不参与，屏幕左右边缘、横屏和 5 项菜单宽度仍要实测，不能只验证 XML 能编译；激活“笔”时键盘主体被刻意独占，不提供长按菜单，测试应确认触摸被消费且不会误上屏。实验性自动捕获若以后开放，必须另做 Basic 长按计时竞争测试。

## 8. 分阶段实施计划

### 阶段 0：长按字母候选小迭代

- 按 7.5 的矩阵修改 lower/upper T+ softkey；
- 保持每个菜单第一项仍为原数字或符号；
- 验证 14 个 T+ 组合键的每个候选都能被选中，取消 popup 不产生输出；
- 以 Google 原生中文 QWERTY 为行为基准，比较“无 composing / 已有 composing”时的上屏文本、光标与 composing 变化；
- 验证普通点击、左右短滑、长按延迟、Shift、中文/英文、密码和 URL 等 InputType 无回归。

完成条件：这项 XML 级功能可以独立构建和发布，不等待 Conway 数据、候选过滤或笔画手势完成。

### 阶段 A：数据与纯逻辑

- 使用已固定的 Conway commit 与 SHA-256；
- 编写生成器，产出紧凑 asset；
- 对 `偲`、`灏`、常用字、繁体字和正则变体做静态校验；
- 实现 code point 查找和笔画前缀比较；
- 补充 attribution/NOTICE。

完成条件：无需启动 APK，即可证明 `偲` 匹配 `3`、`灏` 匹配 `4`，错误前缀不匹配。

### 阶段 B：候选过滤

- 先通过调试入口人工设置过滤前缀，不接触手势；
- 修改 iterator 拉取循环并加入按 composing/filter 双世代隔离的缓存/重放 session；
- 验证前缀追加、退格、清空后的缓存重放，深层候选、分批续扫、分页、`hasMore`、首选高亮和空格提交；
- 验证退格和所有清理路径。

完成条件：人工设置 `3` 后，`si` 能在原生候选中找到并正确提交“偲”；若原生 iterator 没有该字，形成明确日志证据再进入候选补充设计。

### 阶段 C：触摸与界面

- 加入 handler 和轨迹可视化；
- 接入五类几何分类；
- 调整 handler 顺序、touch slop、最短轨迹和转角阈值；
- 加入过滤状态文案、候选栏“笔”入口和设置项；
- 自动捕获如要保留，只作为非默认实验模式。

完成条件：实际书写五种笔画均能稳定分类，普通点击、长按数字和无 composing 的滑行输入无回归。

### 阶段 D：发布验证

- 运行补丁、幂等性、构建、签名和反向解码检查；
- 在模拟器完成自动/半自动回归；
- 在真实设备调整触摸阈值；
- 通过全部强制验收用例后发布 `1.1.0` 测试版。

## 9. 风险与缓解

| 风险 | 影响 | 缓解措施 |
| --- | --- | --- |
| 笔画与 T+ 左右短滑冲突 | composing 时误把后续精确字母当笔画 | 第一版必须显式点击“笔”后才接管；自动捕获只做非默认实验模式 |
| 与 Google 滑行 handler 竞争 | 轨迹被错误送入拼音滑行模型 | 未进入“笔”状态时笔画 handler 不认领；进入后放在 Basic/gesture 前并在主体 `DOWN` 立即认领，过短轨迹也只消费不回退 |
| 激活“笔”后误触字母长按 | 用户期待 popup 却只得到笔画轨迹 | 激活态明确禁用键盘主体 PRESS/短滑/滑行/长按；候选栏持续显示退出入口，退出后原菜单恢复 |
| 候选栏“笔”入口遮挡候选或展开键 | 候选少一项、按钮重叠或扩展页不可用 | 先做静态 UI 原型；与剪贴板 overlay 互斥；必要时使用 T+ 专用 header/candidate-inner layout |
| 目标字位于深层候选 | 首屏过滤为空 | 在 iterator 循环内过滤并继续拉取，不只装饰可见列表 |
| 空格提交隐藏的原首选 | 上屏字与视觉不一致 | 分别验证视觉高亮和默认提交挂点；只在明确提交时调用 `selectCandidate()` |
| 前缀变化后 iterator 无法回退 | 退格/清空后候选永久丢失 | 按 composing 世代缓存原 Candidate；每次前缀变化递增 filter 世代、清空全局首项并从 cache 游标 0 重放 |
| 无匹配时扫描过多 | 主线程卡顿或暂时空页被误报“无匹配” | 每批限制 256/512 个候选，携带 composing/filter 双 token 续扫；仅 iterator 耗尽后报告无匹配 |
| 翻页改写默认候选 | 空格从全局首项跳到下一页首项 | `firstMatchedCandidateForFilter` 只在新 filter 世代首次命中时设置；分页沿用，不重算 |
| Conway 资源缺失或损坏 | IME 初始化或候选请求失败 | `openRawResource` 懒加载并校验 header/边界/摘要；失败时本会话关闭过滤、隐藏按钮，原输入路径 fail-open |
| Google 原生候选没有稀有字 | `si + 丿` 仍找不到“偲” | 先留存 iterator 耗尽证据，再做带拼音映射的补充 Candidate 第二阶段 |
| 多字短语语义不清 | 过滤结果不可预测 | 第一版限制单音节/未部分选词；后续定义为未确认部分首字 |
| 数据许可遗漏 | 发布合规风险 | 固定上游版本，提交 attribution、许可证链接、生成脚本和校验值 |
| Conway 正则变体被简化 | 合法字形/笔顺前缀误判 | 构建时按上游规则展开捕获组、选择和反向引用，前五笔去重后打包 |
| 直接套用触宝像素阈值 | 高密度设备误触 | 使用系统 touch slop、键宽比例和真机采样，不硬编码 20 px |

## 10. 验收测试矩阵

### 10.1 强制功能用例

- [ ] 开启功能后，输入 `si`、点击“笔”再写 `丿`，候选出现并可提交“偲”；
- [ ] 输入 `hao`、点击“笔”再写 `丶`，候选出现并可提交“灏”；
- [ ] 未点击“笔”时，在已有 composing 后继续左右短滑输入拼音，不会触发过滤；
- [ ] “笔”激活态可以再次点击退出，并在提交、取消、清空 composing、切换布局时自动退出；
- [ ] 连续写一、二、三笔时，候选按完整前缀逐步缩小；
- [ ] 退格先逐笔删除过滤前缀，再删除拼音；
- [ ] 空格提交当前第一个可见匹配候选；
- [ ] 点击任意匹配候选提交正确，不发生 payload 类型异常；
- [ ] 追加、删除或清空笔画前缀后，候选从原始顺序重放，不因 iterator 已消费而永久丢失；
- [ ] 深层扫描达到单批预算时自动显示“正在筛选…”并续扫，页面不会永久空白或过早显示“无匹配”；
- [ ] 无匹配仅在原 iterator 耗尽后出现，且不丢失 composing，可退格恢复；
- [ ] 拼音变化和笔画前缀追加/退格/清空分别使旧 composing/filter token 失效，延迟结果不会覆盖新 UI；
- [ ] 展开/翻页不改变 `firstMatchedCandidateForFilter`，空格/回车始终提交整个过滤结果的第一项；
- [ ] 提交、取消、回车、切换布局、结束输入视图后过滤状态清空。

### 10.2 手势回归

- [ ] 无 composing 时，T+ PRESS 双字母行为不变；
- [ ] 无 composing 时，左右短滑选单字母不变；
- [ ] 无 composing 时，跨键滑行输入不变；
- [ ] 14 个 T+ 组合键长按菜单均保留原数字/符号第一项，并显示对应单字母大小写；
- [ ] 长按菜单的每个条目均能选中，取消 popup 不输出，lower/upper 两套模板一致；
- [ ] 无 composing 和已有 composing 两种情况下，上屏文本、光标与 composing 变化均与 Google 原生中文 QWERTY 的对等长按一致；
- [ ] 密码、URL、英文输入以及屏幕左右边缘键的 popup 行为正确；
- [ ] 未激活“笔”时菜单滑选不被过滤器拦截；激活后主体长按被消费且不弹菜单，退出“笔”后恢复；
- [ ] 有 composing 但未激活“笔”时，任何轨迹都不被误判成笔画；
- [ ] 激活“笔”后，小于阈值的点击不产出笔画，明显横、竖、撇、点/捺、折均可识别；
- [ ] 功能关闭时所有行为与 `1.0.0` 一致；
- [ ] 横竖屏、不同显示密度和触摸采样率下无明显误触。

### 10.3 构建与静态检查

- [ ] `scripts/apply_patches.py` 对干净 APK 可重复运行且结果幂等；
- [ ] 新增 verifier 检查 handler 顺序、设置项、smali 挂点和数据文件；
- [ ] 数据生成器校验条目数量、排序、重复 code point、笔画值范围、固定 SHA-256、选择分支和反向引用；
- [ ] 缺失、截断、magic/版本错误和来源摘要不符的数据文件均触发 fail-open，T+ 拼音与 Google 独立笔画仍可用；
- [ ] APKTool/aapt2 重建成功；
- [ ] 签名、zipalign、包名、版本号和 ABI 检查通过；
- [ ] 反向解码确认新资源与 smali 实际进入 APK；
- [ ] `git diff --check` 通过，仓库不包含触宝 APK 或反编译产物。

## 11. 发布门槛

`1.1.0` 测试版必须同时满足：

1. `si + 丿 → 偲` 与 `hao + 丶 → 灏` 两个目标用例均通过；
2. 过滤后首选候选的点击、空格和回车提交一致；
3. 功能默认关闭，关闭时与 `1.0.0` 的 T+ 行为无差异；
4. 14 个长按菜单的数字/符号与大小写单字母均可用，左右短滑和未激活“笔”时的滑行输入无回归；
5. 数据许可和 attribution 已进入仓库及发布说明；
6. 至少完成一次真实设备验证。模拟器可验证逻辑和事件链，但最终触摸阈值不能只靠模拟器决定。

## 12. 建议新增文件

实际文件名可随 smali 包结构调整，建议保持职责边界：

```text
patches/smali/StrokeFilterCompat.smali
patches/smali/StrokeFilterMotionEventHandler.smali
patches/smali/StrokeFilterCandidateSession.smali
patches/res/raw/stroke_filter_data.bin
patches/res/layout/keyboard_candidates_header_inner.xml     # 若复用共享 overlay
patches/res/layout/keyboard_candidates_header_inner_no_deletable_label.xml
third_party/conway-stroke-data/codepoint-character-sequence.txt
third_party/conway-stroke-data/LICENSE-CC-BY-4.0.txt
scripts/generate_stroke_filter_data.py
scripts/verify_stroke_filter.py
docs/stroke-filter-data-attribution.md
```

需要修改的既有文件预计包括：

```text
patches/res/xml/keyboard_zh_cn_pinyin_tplus.xml
patches/res/xml/softkeys_input_zh_cn_pinyin_tplus.xml
scripts/apply_patches.py
scripts/verify_tplus.py                # 或由新的 verifier 调用
工作解码树中的 HmmPinyinT9DecodeProcessor.smali
工作解码树中的 AbstractHmmIme.smali
设置页 XML 与 strings.xml 补丁生成逻辑
```

不要直接编辑并提交 `work/analysis/*`。这些目录是研究证据和构建中间产物，正式实现应回到 `patches/` 与 `scripts/` 的可重放补丁链。

## 13. 接力开发起点

后续开发者建议按以下顺序开始：

1. 阅读本文和 `docs/touchpal-tplus-port.md`，确认现有 T+ 手势与候选架构；
2. 先完成 7.5 的 T+ 长按多候选 XML 小迭代、verifier、构建和实机菜单测试；
3. 按本文已固定的 Conway commit/SHA-256，完成正则变体展开、紧凑数据生成和样例断言；
4. 不接手势，给 `StrokeFilterCompat` 临时设置前缀 `3`，验证 `AbstractHmmIme` 深度候选过滤；
5. 优先解决候选 session 的缓存重放/分批续扫、“第一个匹配项视觉高亮/空格提交”与“iterator 耗尽后是否存在偲”；
6. 候选链验证稳定后，先做候选栏“笔”入口，再实现只在激活态认领的触摸轨迹处理器；
7. 最后做设置项、轨迹视觉、阈值调优和可选的自动捕获实验模式。

如果第 4 步确认 Google iterator 中没有“偲”，应另写一份“稀有字补充候选设计”，明确拼音数据来源、Candidate payload、提交/学习行为和词频排序；不要在过滤器里临时硬编码 `偲`。

## 14. 参考资料

- [触宝输入法功能介绍：拼音后书写首笔过滤候选](https://www.pingwest.com/a/40995)
- [Conway Stroke Data](https://github.com/stroke-input/stroke-input-data)
- [本研究固定的 Conway commit](https://github.com/stroke-input/stroke-input-data/commit/a657f5b7554ace8d97a4d9a87aca391b24363458)
- [Conway `generate.py`：正则变体展开规则](https://github.com/stroke-input/stroke-input-data/blob/a657f5b7554ace8d97a4d9a87aca391b24363458/generate.py)
- [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/)
- [Google 拼音帮助：笔画输入的 h/s/p/n/z/d 规则](https://support.google.com/pinyin/answer/62646?hl=zh-Hans)
- [Unicode UAX #38：Unicode Han Database](https://unicode.org/reports/tr38/)
- [Make Me a Hanzi](https://github.com/skishore/makemeahanzi)
- [仓库内现有 T+ 移植说明](touchpal-tplus-port.md)
- [Google 拼音候选链研究](google-pinyin-candidate-research.md)

## 15. 已知事实、推断与待验证项

为避免接力时混淆，最终按证据等级归档：

| 类型 | 内容 |
| --- | --- |
| 已确认 | 触宝 APK 有独立“Stroke filtering”设置、轨迹遮罩、过滤模型和 native 调用 |
| 已确认 | Okinawa Java/JNI、Lua 资源和 ARM native 库都能做静态逆向；native 只有动态符号而无完整调试符号，不能还原成原始可维护源码 |
| 已确认 | TouchPal 笔画九键为“一丨丿 / 丶乙词语 / 通配：…”并带九个下滑部件；Google 为“横竖撇 / 点折通配 / 分隔符！？”，键位细节不同 |
| 已确认 | Google 拼音有独立笔画 HMM，但拼音和笔画 XML 各自只注册一个 decode processor |
| 已确认 | Google 候选通过 iterator 分页，原 Candidate 携带 HMM payload，不能随意重建 |
| 已确认 | 模拟器中 `si` 首屏及四个展开页内未看到“偲” |
| 已确认 | 固定 Conway commit/SHA-256 后，“偲”首笔为撇、“灏”首笔为点/捺；源字段是可含选择和反向引用的正则，不总是单序列 |
| 已确认 | Google 现有中文 QWERTY 已支持 `1 q Q` 这类多候选长按，T+ 长按大小写菜单可复用同一 XML 机制 |
| 推断 | 通过新增 motion handler 且只在显式“笔”状态下从主体 `DOWN` 立即认领，可以在不覆盖键盘 View 的情况下捕获笔画 |
| 待验证 | `DOWN` 立即认领能否稳定 reset Basic/gesture handler，且短轨迹被消费后不会回退触发 T+ `PRESS` |
| 待验证 | Google 的 `si` 原生 iterator 最终是否包含“偲” |
| 待验证 | `highlightCandidate()` 是否无 composing 副作用，以及空格/回车实际读取哪条默认候选路径；`selectCandidate()` 不得仅用于刷新 |
| 待验证 | 256/512 的单批扫描上限、跨帧续扫和 composing/filter 双世代取消在真实设备上的延迟与命中率是否合适 |
| 待验证 | T+ 的五候选长按菜单在边缘键、横屏和中文 composing 状态下能否与 Google 原生中文 QWERTY 保持一致 |
| 待验证 | 候选栏“笔”入口采用共享 overlay 还是 T+ 专用 header，才能不遮挡候选、展开键和剪贴板关闭层 |

以上“待验证”项是实现阶段应最先保留日志和最先关闭的技术风险。
