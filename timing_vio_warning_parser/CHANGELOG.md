# Changelog

## [v2.0.0] - 2026-10-12 — 优化版本

### Bug 修复 (P0)

- **`violation_time` 未定义崩溃**: `extract_timing_violations()` 中当日志无时间信息时，`violation_time` 未赋值导致 `UnboundLocalError`。修复为默认值 `0`。
- **`line_num` 类型不匹配**: `Warning` 类的 `line_num` 可能是字符串 `"unknown"`，与 `cross_match_warning` 中的 int 比较永远不匹配。修复为在 `Warning.__init__` 中统一转换为 int（`-1` 表示未知）。

### Bug 修复 (P1)

- **`-c` 和 `-s` 参数冲突**: 原代码使用 `if` 而非 `elif`，导致 `-s` 静默覆盖 `-c`。修复为 `elif`。
- **输出目录不可配置**: 输出文件硬编码写入 CWD，并行回归时会冲突。新增 `-o`/`--output` 参数指定输出目录。
- **异常处理过于宽泛**: 多处 `except Exception` 改为区分 `FileNotFoundError`/`PermissionError`/`UnicodeDecodeError` 分别处理。

### 增强 (P2)

- **日志框架**: 引入 `logging` 模块替代 `print`，区分 INFO/WARNING/ERROR 级别。
- **正则预编译**: 所有常用正则表达式预编译为模块级常量，减少重复编译开销。
- **类型提示**: 核心函数添加 type hints。
- **常量提取**: 魔法字符串 `"-1"` 和 `-1` 提取为 `RULE_SKIP_STR`/`RULE_SKIP_INT` 常量。
- **文件去重增强**: 使用 `os.path.realpath()` 规范化路径后再去重，避免符号链接导致的重复。
- **有意义的退出码**: `0`=无违例无告警, `1`=存在违例, `2`=存在告警, `3`=参数/配置错误。

### 新增

- `-o`/`--output` 参数：指定输出文件目录
- `test/` 目录：自动化测试套件（8 个测试用例）
- `HELP.md`：详细帮助文档
- `CHANGELOG.md`：本文件

---

## [v1.0.0] — 原始版本

- 初始版本，由 xiayu 编写
- 支持编译/仿真日志的 Warning 和 Timing Violation 解析
- JSON 配置驱动的过滤规则
- 源码备份为 `timing_warning_parser.py.bak`
