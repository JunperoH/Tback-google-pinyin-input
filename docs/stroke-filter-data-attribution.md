# 拼音笔画过滤数据来源与署名

T+ 拼音笔画过滤使用 **Conway Stroke Data** 的“Unicode 汉字到五类笔顺序列”数据：

| 字段 | 固定值 |
| --- | --- |
| 项目 | [stroke-input/stroke-input-data](https://github.com/stroke-input/stroke-input-data) |
| 作者 | Conway（[@yawnoc](https://github.com/yawnoc)） |
| 固定提交 | `a657f5b7554ace8d97a4d9a87aca391b24363458` |
| 原始文件 | `codepoint-character-sequence.txt` |
| SHA-256 | `2da408c8982613020bda7ad16b76a3b28e93843afcd207e8bb2c9c743727f123` |
| 数据许可 | [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) |

仓库保留未经修改的固定版本源文件和许可证全文：

- `third_party/conway-stroke-data/codepoint-character-sequence.txt`
- `third_party/conway-stroke-data/LICENSE-CC-BY-4.0.txt`

`scripts/generate_stroke_filter_data.py` 在构建前验证原文件 SHA-256，并离线生成
`patches/res/raw/stroke_filter_data.bin`。运行时产物只保存每个 Unicode code point
可接受笔顺变体的前五笔，不包含排名数据，也没有改变 Conway 原始数据的含义。

本项目对数据所作的转换包括：按照上游 `generate.py` 的语义展开选择分支、捕获组和
反向引用；将每个合法序列截取到五笔；去重；按 Unicode code point 排序；编码为
`TSF1` 小端二进制索引。由本项目编写的生成器代码沿用本仓库自身许可证；转换后的
笔顺数据继续按 CC BY 4.0 使用和分发。

Conway Stroke Data 是人工整理的辅助数据，不代表 Google 拼音词库，也不作为国家或
Unicode 笔顺标准的替代品。若发现数据问题，应连同固定提交、Unicode code point 和
原始笔顺正则向上游追溯。
