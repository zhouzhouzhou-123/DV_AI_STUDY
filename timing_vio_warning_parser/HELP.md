# Timing Violation & Warning Parser — 详细帮助文档

> **脚本**: `timing_warning_parser.py`
> **作者**: xiayu (xiayu@chipsea.com)
> **部门**: Digital Verification Department

---

## 目录

- [1. 工具概述](#1-工具概述)
- [2. 目录结构](#2-目录结构)
- [3. 快速开始](#3-快速开始)
- [4. 命令行参数详解](#4-命令行参数详解)
- [5. 脚本架构与核心类/函数](#5-脚本架构与核心类函数)
- [6. 执行流程](#6-执行流程)
- [7. JSON 配置文件完整说明](#7-json-配置文件完整说明)
- [8. 过滤规则详解](#8-过滤规则详解)
- [9. 输出文件说明](#9-输出文件说明)
- [10. 终端输出说明](#10-终端输出说明)
- [11. 日志信息提取机制](#11-日志信息提取机制)
- [12. 时间单位换算](#12-时间单位换算)
- [13. 正则匹配模式说明](#13-正则匹配模式说明)
- [14. 环境变量](#14-环境变量)
- [15. 依赖](#15-依赖)
- [16. 常见问题与排错](#16-常见问题与排错)
- [17. 最佳实践](#17-最佳实践)

---

## 1. 工具概述

`timing_warning_parser.py` 是一个用于 **自动解析数字仿真/编译日志** 中 Timing Violation（时序违例）和 Warning（告警）信息的 Python 脚本。

**核心能力**：

| 能力 | 说明 |
|---|---|
| Warning 解析 | 从编译/仿真日志中提取 `Warning-[TYPE]` 格式的告警信息 |
| Timing Violation 解析 | 从仿真日志中提取 `Timing violation in <signal>` 格式的时序违例信息 |
| 多维度规则过滤 | 根据 JSON 配置文件中的多种规则（信号名、文件路径、行号、时间门限、关键字等）过滤掉已知的、可忽略的告警和违例 |
| 汇总统计 | 按 warning type 和 violation signal 进行数量汇总，在终端高亮输出 |
| 结果持久化 | 将过滤后的结果写入文本文件，并生成汇总报告 |
| 日志溯源 | 自动从日志文件中提取 `UVM_TESTNAME`、`ntb_random_seed`、`+define+` 等仿真元信息，便于问题定位 |

---

## 2. 目录结构

```
timing_vio_warning_parser/
├── timing_warning_parser.py      # 主脚本（517 行）
├── warning_timing_vio_filter.json # JSON 过滤规则配置文件
├── README.md                      # 简要说明文档
├── HELP.md                        # 本帮助文档
├── __pycache__/                   # Python 字节码缓存（自动生成）
│
│  ── 以下为运行后生成的输出文件 ──
├── filtered_timing_violations.txt # 过滤后的 Timing Violation 详情
├── filtered_warnings_in_sim.txt   # 过滤后的仿真 Warning 详情
├── filtered_warnings.txt          # 过滤后的编译 Warning 详情
├── filtered_summary.txt           # 汇总统计报告
└── local_log.log                  # 本地运行日志（可选）
```

---

## 3. 快速开始

```bash
# 1. 同时解析编译和仿真日志（默认行为），使用默认 JSON 配置
python3 timing_warning_parser.py /path/to/result_dir

# 2. 仅解析仿真日志
python3 timing_warning_parser.py -s /path/to/result_dir

# 3. 仅解析编译日志
python3 timing_warning_parser.py -c /path/to/result_dir

# 4. 指定自定义 JSON 配置文件
python3 timing_warning_parser.py -f ./my_rule.json /path/to/result_dir

# 5. 组合使用：仅仿真 + 指定配置文件
python3 timing_warning_parser.py -s -f ./my_rule.json /path/to/result_dir

# 6. 查看帮助
python3 timing_warning_parser.py -h
```

**前提条件**：
- Python 3.x 已安装
- 环境变量 `WORK_DIR` 已设置（若不使用 `-f` 指定配置文件），或已通过 `-f` 指定了配置文件路径
- 日志目录存在且包含匹配的日志文件

---

## 4. 命令行参数详解

### 语法

```bash
python3 timing_warning_parser.py [OPTIONS] <log_dir>
```

### 位置参数

| 参数 | 必填 | 说明 |
|---|---|---|
| `log_dir` | **是** | 日志文件所在的根目录路径。脚本会递归遍历该目录下所有匹配 JSON 配置文件中 pattern 的日志文件。该目录必须存在，否则报错退出。 |

### 可选参数

| 短选项 | 长选项 | 说明 |
|---|---|---|
| `-c` | `--comp` | **仅解析编译日志**。只处理 `comp_log_pattern` 匹配的编译日志文件，提取 Warning 信息。 |
| `-s` | `--sim` | **仅解析仿真日志**。只处理 `sim_log_pattern` 匹配的仿真日志文件，提取 Warning 和 Timing Violation 信息。 |
| `-f <path>` | `--file <path>` | **指定 JSON 配置文件路径**。默认读取 `$WORK_DIR/setup/warning_timing_vio_filter.json`。 |
| `-h` | `--help` | 显示简要帮助信息并退出。 |

### 参数组合行为

| 参数组合 | action 值 | 行为 |
|---|---|---|
| 无 `-c` 无 `-s` | `both` | 同时解析编译日志和仿真日志 |
| 仅 `-c` | `comp` | 仅解析编译日志 |
| 仅 `-s` | `sim` | 仅解析仿真日志 |
| `-c` 和 `-s` 同时 | 最后指定的生效 | 注意：代码中 `-s` 会覆盖 `-c`（因为使用 `if` 而非 `elif`） |

### 默认行为

- 若 **不指定** `-c` 或 `-s`，默认行为为 `both`，即同时解析编译日志和仿真日志。
- 若 **不指定** `-f`，脚本从环境变量 `WORK_DIR` 读取路径，拼接为 `$WORK_DIR/setup/warning_timing_vio_filter.json`。若 `WORK_DIR` 未设置，会打印警告。

---

## 5. 脚本架构与核心类/函数

### 5.1 核心类

#### `Warning` 类

表示一条从日志中解析出的告警信息。

| 属性 | 类型 | 说明 |
|---|---|---|
| `warning_type` | `str` | Warning 类型（如 `TMPOAA`、`IWNF`），从 `[TYPE]` 中提取 |
| `warning_description` | `str` | Warning 的描述文本 |
| `file_path` | `str` | 关联的源文件路径 |
| `line_num` | `str` | 关联的源文件行号 |
| `input_file_name` | `str` | 输入日志文件路径 |
| `log_name` | `str` | 日志文件名（同 `input_file_name`） |
| `info` | `str` | Warning 的详细信息（正文内容） |

`__str__` 方法输出格式：
```
Input File: <input_file_name>,
 Warning Type: <warning_type>, Description: <warning_description>
 File Path: <file_path>, <line_num>
```

#### `TimingViolation` 类

表示一条从仿真日志中解析出的时序违例信息。

| 属性 | 类型 | 说明 |
|---|---|---|
| `file_path` | `str` | 违例所在的源文件路径 |
| `line_num` | `str` | 违例所在的源文件行号 |
| `timing_violation_signal` | `str` | 违例信号名（如 `top.saradc.u_sar_dig.bwd_ch_en_reg`） |
| `log_path` | `str` | 日志文件路径 |
| `violation_content` | `str` | 违例的完整内容（包含时间信息） |
| `violation_time` | `int` | 违例发生的时间（统一转换为皮秒 ps） |

### 5.2 核心函数一览

| 函数 | 输入 | 输出 | 说明 |
|---|---|---|---|
| `parse_arguments()` | 命令行参数 | `(status_code, action, json_path, log_dir)` | 解析命令行参数，返回状态码和处理模式 |
| `validate_json_file(json_path)` | JSON 文件路径 | `dict` 或 `None` | 加载并验证 JSON 配置文件 |
| `set_default_json_path()` | 无 | `str` 或 `None` | 从 `WORK_DIR` 环境变量构建默认 JSON 路径 |
| `get_matching_files(path, regex_pattern)` | 目录路径, 正则表达式 | `list[str]` | 递归遍历目录，返回匹配正则的文件路径列表 |
| `parse_warnings_from_file(file_name)` | 日志文件路径 | `list[Warning]` | 从单个日志文件中解析所有 Warning |
| `extract_timing_violations(file_name, config)` | 日志文件路径, 配置字典 | `list[TimingViolation]` | 从单个日志文件中提取 Timing Violation，支持 `first_ignore_line` 前置过滤 |
| `filter_timing_violations(violations, config)` | 违例列表, 配置字典 | `list[TimingViolation]` | 根据配置规则过滤 Timing Violation |
| `filter_warnings(warnings, config)` | Warning 列表, 配置字典 | `list[Warning]` | 根据配置规则过滤 Warning |
| `summarize_warning(warnings)` | Warning 列表 | `(dict, list[str])` | 按 warning_type 汇总统计，终端打印并返回汇总行 |
| `summarize_vio(vios)` | 违例列表 | `(dict, list[str])` | 按 signal 汇总统计，终端打印并返回汇总行 |
| `extract_log_info(log_path)` | 日志文件路径 | `(testname, seed, macros)` | 从日志中提取 UVM_TESTNAME、ntb_random_seed、+define+ 宏 |
| `save_info(info_list, output_file)` | 结果列表, 输出文件路径 | 无 | 按日志文件分组保存结果，附带日志溯源信息 |
| `find_first_line(filename, target)` | 文件名, 目标字符串 | `int` | 查找文件中首次包含目标字符串的行号 |
| `convert_to_ps(time_str)` | 时间字符串（如 `100ns`） | `int`（皮秒值） | 将带单位的时间字符串转换为皮秒 |
| `process_simulation_logs(action, log_dir, config)` | action, 日志目录, 配置 | `(sim_warnings, timing_violations)` | 处理仿真日志主流程 |
| `process_compilation_logs(action, log_dir, config)` | action, 日志目录, 配置 | `list[Warning]` | 处理编译日志主流程 |
| `do_warning_by_file(warning_log_path, config)` | 日志路径, 配置 | `list[Warning]` | 单文件 Warning 解析+过滤 |
| `do_timing_violation_by_file(sim_log, config)` | 日志路径, 配置 | `list[TimingViolation]` | 单文件 Timing Violation 提取+过滤 |
| `preprocess_file_with_re(file_name, regex_pattern)` | 文件名, 正则 | `list[str]` | 按正则过滤行（辅助函数，当前未在主流程中使用） |

---

## 6. 执行流程

```
┌──────────────────────────────────────────────┐
│  1. parse_arguments()                        │
│     解析命令行参数 → action, json_path, log_dir │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  2. validate_json_file(json_path)            │
│     加载并验证 JSON 配置文件                    │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  3. process_simulation_logs()                │
│  (当 action == "both" 或 "sim" 时)           │
│  ┌─────────────────────────────────────────┐ │
│  │ a. 遍历 sim_log_pattern，匹配日志文件    │ │
│  │ b. 对每个日志文件：                       │ │
│  │    - do_warning_by_file()               │ │
│  │      → parse_warnings_from_file()       │ │
│  │      → filter_warnings()                │ │
│  │    - do_timing_violation_by_file()      │ │
│  │      → extract_timing_violations()      │ │
│  │      → filter_timing_violations()       │ │
│  │ c. save_info() → 输出结果文件            │ │
│  └─────────────────────────────────────────┘ │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  4. process_compilation_logs()               │
│  (当 action == "both" 或 "comp" 时)          │
│  ┌─────────────────────────────────────────┐ │
│  │ a. 遍历 comp_log_pattern，匹配日志文件   │ │
│  │ b. 对每个日志文件：                       │ │
│  │    - do_warning_by_file()               │ │
│  │      → parse_warnings_from_file()       │ │
│  │      → filter_warnings()                │ │
│  │ c. save_info() → 输出结果文件            │ │
│  └─────────────────────────────────────────┘ │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│  5. 汇总统计 & 输出                           │
│  - summarize_warning() / summarize_vio()     │
│  - 写入 filtered_summary.txt                 │
│  - 打印生成的文件列表和耗时                    │
└──────────────────────────────────────────────┘
```

---

## 7. JSON 配置文件完整说明

配置文件为 JSON 格式，控制日志匹配规则和过滤规则。以下是所有字段的完整说明：

### 7.1 日志文件匹配

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `comp_log_pattern` | `string[]` | 是 | 正则表达式列表，用于匹配**编译日志**文件路径。脚本使用 `re.search()` 对完整文件路径进行匹配。例如 `"comp_result/comp_.*.log$"` 匹配 `comp_result/` 目录下以 `comp_` 开头、`.log` 结尾的文件。 |
| `sim_log_pattern` | `string[]` | 是 | 正则表达式列表，用于匹配**仿真日志**文件路径。例如 `".*.log$"` 匹配所有 `.log` 文件。支持多个 pattern，匹配结果会合并去重。 |

### 7.2 Timing Violation 过滤规则

#### `timing_violation_signal`

| 字段 | 类型 | 说明 |
|---|---|---|
| `timing_violation_signal` | `string[]` | 信号名正则列表。使用 `re.fullmatch()` 进行**完全匹配**。违例信号名匹配任一 pattern 时，该违例被过滤（忽略）。 |

**示例**：
```json
"timing_violation_signal": [
    "top.saradc.u_sar_dig.bwd_ch_en_reg",
    "top.saradc.u_sar_dig.t2a_sar_sample_neg_reg_\\d+"
]
```
- 第一条：精确匹配信号 `top.saradc.u_sar_dig.bwd_ch_en_reg`
- 第二条：匹配 `top.saradc.u_sar_dig.t2a_sar_sample_neg_reg_` 后跟一个或多个数字的信号

#### `file_and_line`

| 字段 | 类型 | 说明 |
|---|---|---|
| `file_and_line` | `object[]` | 按文件路径 + 行号过滤。每个对象包含 `path`（正则匹配文件路径）和 `line_num`（具体行号，`-1` 表示匹配该文件所有行）。两者同时满足时，该违例被过滤。 |

**示例**：
```json
"file_and_line": [
    { "path": "verilog/sc12mc_40nmLP_base_rvt_c51.v", "line_num": -1 },
    { "path": "verilog/sc12mc_40nmLP_base_rvt_c52.v", "line_num": 102 }
]
```
- 第一条：过滤 `sc12mc_40nmLP_base_rvt_c51.v` 文件中所有行的违例
- 第二条：仅过滤 `sc12mc_40nmLP_base_rvt_c52.v` 文件第 102 行的违例

#### `cross_match`

| 字段 | 类型 | 说明 |
|---|---|---|
| `cross_match` | `object[]` | **交叉匹配规则**，支持四个维度的组合过滤。 |

每个规则对象包含以下字段：

| 子字段 | 类型 | 说明 |
|---|---|---|
| `path` | `string` | 正则匹配文件路径。`"-1"` 或 `""` 表示不限制此维度。 |
| `line_num` | `int` | 行号。`-1` 表示不限制此维度。 |
| `timing_violation_signal` | `string` | 正则匹配信号名。`"-1"` 或 `""` 表示不限制此维度。 |
| `timing_violation_keyword` | `string` | 正则匹配违例内容关键字。`"-1"` 或 `""` 表示不限制此维度。（可选字段） |

**匹配逻辑**：
- 所有四个维度都为 `"-1"` / `""` / `-1` 时，该规则被跳过（不产生过滤效果）
- 所有非 `"-1"` 维度**都匹配**时，该违例被过滤
- 即：各维度之间是 **AND** 关系

**示例**：
```json
"cross_match": [
    {
        "path": "verilog/sc12mc_40nmLP_base_rvt_c53.v",
        "line_num": 103,
        "timing_violation_signal": "top.saradc.u_sar_dig.t2bac_sar_sample_neg_regd_2",
        "timing_violation_keyword": "EXAMP_CLK"
    }
]
```
此规则表示：仅当文件路径包含 `sc12mc_40nmLP_base_rvt_c53.v`、行号为 103、信号名为 `t2bac_sar_sample_neg_regd_2`、且内容包含 `EXAMP_CLK` 时，才过滤该违例。

#### `violation_start_limit_global`

| 字段 | 类型 | 说明 |
|---|---|---|
| `violation_start_limit_global` | `string` | **全局时间门限**。格式为 `"<数值><单位>"`（如 `"100ns"`），单位支持 `ps`/`ns`/`us`/`ms`。违例发生时间**早于或等于**该门限的被过滤。设为 `"-1"` 表示不做全局时间过滤。 |

**示例**：
```json
"violation_start_limit_global": "100ns"
```
表示过滤掉所有发生在 0~100ns 之间（含 100ns）的时序违例。

```json
"violation_start_limit_global": "-1"
```
表示不做全局时间过滤。

#### `first_ignore_line`

| 字段 | 类型 | 说明 |
|---|---|---|
| `first_ignore_line` | `object[]` | **起始行过滤**。在解析 timing violation 前，先找到日志中包含 `specific_character` 的行，忽略该行**之前**的所有内容。 |

每个规则对象包含：

| 子字段 | 类型 | 说明 |
|---|---|---|
| `specific_character` | `string` | 要在日志中搜索的特征字符串 |
| `enable_specific_character_filter` | `bool` | 是否启用此规则 |

**匹配逻辑**：
- 遍历所有启用的规则，找到每个特征字符串在日志中首次出现的行号
- 取所有规则中的**最大行号**
- 忽略该行号之前的所有内容（即只解析该行及之后的内容）
- 适用于跳过 reset 阶段等场景

**示例**：
```json
"first_ignore_line": [
    {
        "specific_character": "wait global reset release done ....",
        "enable_specific_character_filter": true
    }
]
```
表示在日志中找到包含 `wait global reset release done ....` 的行，忽略该行之前的所有内容。

### 7.3 Warning 过滤规则

#### `warning_type`

| 字段 | 类型 | 说明 |
|---|---|---|
| `warning_type` | `string[]` | Warning 类型正则列表。使用 `re.fullmatch()` 进行**完全匹配**。warning type 匹配任一 pattern 时，该 warning 被过滤。 |

**示例**：
```json
"warning_type": ["TMPOAA", "ABC", "EAANUMASSIGN"]
```
过滤掉类型为 `TMPOAA`、`ABC`、`EAANUMASSIGN` 的所有 warning。

#### `cross_match_warning`

| 字段 | 类型 | 说明 |
|---|---|---|
| `cross_match_warning` | `object[]` | **Warning 交叉匹配规则**，支持四个维度的组合过滤。 |

每个规则对象包含以下字段：

| 子字段 | 类型 | 说明 |
|---|---|---|
| `module_path` | `string` | 正则匹配文件路径。`"-1"` 表示不限制此维度。 |
| `line_num` | `int` | 行号。`-1` 表示不限制此维度。 |
| `warning_type` | `string` | Warning 类型精确匹配。`"-1"` 表示不限制此维度。 |
| `warning_info_keyword` | `string` | 正则匹配 warning 详细信息（`info` 字段）。`"-1"` 表示不限制此维度。 |

**匹配逻辑**：与 `cross_match` 相同，各维度之间是 **AND** 关系。

**示例**：
```json
"cross_match_warning": [
    {
        "module_path": "hsm_top/hsm_top",
        "line_num": -1,
        "warning_info_keyword": "SYNOPSYS_UNCONNECTED_\\d+",
        "warning_type": "IWNF"
    },
    {
        "module_path": "verilog/sc12mc_40nmLP_base_[hrl]vt_c50",
        "line_num": -1,
        "warning_info_keyword": "-1",
        "warning_type": "-1"
    }
]
```
- 第一条：过滤路径包含 `hsm_top/hsm_top`、类型为 `IWNF`、且 info 中包含 `SYNOPSYS_UNCONNECTED_<数字>` 的 warning
- 第二条：过滤路径匹配 `sc12mc_40nmLP_base_[hrl]vt_c50` 的所有 warning（不限类型和内容）

### 7.4 完整 JSON 配置示例

```json
{
    "comp_log_pattern": [
        "comp_result/comp_.*.log$"
    ],
    "sim_log_pattern": [
        ".*.log$"
    ],
    "timing_violation_signal": [
        "top.saradc.u_sar_dig.bwd_ch_en_reg",
        "top.saradc.u_sar_dig.t2a_sar_sample_neg_reg_\\d+",
        "top.saradc.u_sar_dig.t2a\\w+_sar_sample_neg_reg"
    ],
    "file_and_line": [
        { "path": "verilog/sc12mc_40nmLP_base_rvt_c51.v", "line_num": -1 },
        { "path": "verilog/sc12mc_40nmLP_base_rvt_c52.v", "line_num": 102 }
    ],
    "violation_start_limit_global": "-1",
    "cross_match": [
        {
            "path": "verilog/sc12mc_40nmLP_base_rvt_c53.v",
            "line_num": 103,
            "timing_violation_signal": "top.saradc.u_sar_dig.t2bac_sar_sample_neg_regd_2",
            "timing_violation_keyword": "EXAMP_CLK"
        },
        {
            "path": "verilog/sc12mc_40nmLP_base_rvt_c53.v",
            "line_num": -1,
            "timing_violation_signal": "top.saradc.u_sar_dig.t2bac_sar_sample_neg_regd_2"
        },
        {
            "path": "verilog/sc12mc_40nmLP_base_rvt_c53.v",
            "line_num": 200,
            "timing_violation_signal": "-1"
        }
    ],
    "warning_type": [
        "TMPOAA",
        "ABC",
        "EAANUMASSIGN"
    ],
    "cross_match_warning": [
        {
            "module_path": "hsm_top/hsm_top",
            "line_num": -1,
            "warning_info_keyword": "SYNOPSYS_UNCONNECTED_\\d+",
            "warning_type": "IWNF"
        },
        {
            "module_path": "force_con/adc_con.sv",
            "line_num": -1,
            "warning_info_keyword": "-1",
            "warning_type": "SIOB"
        },
        {
            "module_path": "verilog/sc12mc_40nmLP_base_[hrl]vt_c50",
            "line_num": -1,
            "warning_info_keyword": "-1",
            "warning_type": "-1"
        }
    ],
    "first_ignore_line": [
        {
            "specific_character": "wait global reset release done ....",
            "enable_specific_character_filter": true
        },
        {
            "specific_character": "this is example second key....",
            "enable_specific_character_filter": true
        }
    ]
}
```

---

## 8. 过滤规则详解

### 8.1 Timing Violation 过滤优先级

过滤规则按以下顺序依次检查，任一规则命中即标记为"应过滤"：

```
1. violation_start_limit_global  →  时间门限过滤
2. timing_violation_signal       →  信号名完全匹配过滤
3. file_and_line                 →  文件路径 + 行号过滤
4. cross_match                   →  多维度交叉匹配过滤
```

**注意**：这些规则之间是 **OR** 关系 — 任一规则命中，该违例即被过滤。

### 8.2 Warning 过滤优先级

```
1. warning_type                  →  Warning 类型完全匹配过滤
2. cross_match_warning           →  多维度交叉匹配过滤
```

同样，规则之间是 **OR** 关系。

### 8.3 匹配方式对照表

| 规则字段 | 匹配方式 | 说明 |
|---|---|---|
| `timing_violation_signal` | `re.fullmatch()` | 信号名必须**完全匹配**正则 |
| `file_and_line.path` | `re.search()` | 文件路径中**包含**匹配即可 |
| `cross_match.path` | `re.search()` | 文件路径中**包含**匹配即可 |
| `cross_match.timing_violation_signal` | `re.search()` | 信号名中**包含**匹配即可 |
| `cross_match.timing_violation_keyword` | `re.search()` | 违例内容中**包含**匹配即可 |
| `warning_type` | `re.fullmatch()` | Warning 类型必须**完全匹配**正则 |
| `cross_match_warning.module_path` | `re.search()` | 文件路径中**包含**匹配即可 |
| `cross_match_warning.warning_type` | 精确字符串比较 | Warning 类型必须**完全相等** |
| `cross_match_warning.warning_info_keyword` | `re.search()` | Warning 信息中**包含**匹配即可 |

**关键区别**：
- `timing_violation_signal` 和 `warning_type`（顶层）使用 `fullmatch`（完全匹配）
- `cross_match` 和 `cross_match_warning` 中的路径/信号/关键字使用 `search`（部分匹配）
- `cross_match_warning.warning_type` 使用精确字符串比较（非正则）

### 8.4 first_ignore_line 机制

`first_ignore_line` 仅作用于 **Timing Violation 的提取阶段**，不影响 Warning 的解析。

工作流程：
1. 遍历所有 `first_ignore_line` 规则
2. 对每个启用的规则，在日志文件中搜索首次出现 `specific_character` 的行号
3. 取所有规则中找到的**最大行号**
4. 将该行之前的所有内容替换为空行（保持行号对齐）
5. 然后在此基础上进行 Timing Violation 的正则提取

---

## 9. 输出文件说明

脚本在**当前工作目录**（执行脚本时所在的目录）下生成以下文件：

| 文件名 | 触发条件 | 内容说明 |
|---|---|---|
| `filtered_timing_violations.txt` | action 为 `both` 或 `sim` | 过滤后的 Timing Violation 详细信息，按日志文件分组，附带 UVM_TESTNAME、seed、defines 等溯源信息 |
| `filtered_warnings_in_sim.txt` | action 为 `both` 或 `sim` | 过滤后的仿真日志 Warning 详细信息，格式同上 |
| `filtered_warnings.txt` | action 为 `both` 或 `comp` | 过滤后的编译日志 Warning 详细信息 |
| `filtered_summary.txt` | 有任何结果时生成 | 汇总统计报告，包含各类 Warning 和 Violation 的数量统计 |

### 输出文件格式

每个结果文件按日志文件分组，每组包含：

```
================================================================================
=============== SOURCE LOG: /path/to/log_file.log ===============
  UVM_TESTNAME: my_test_class  |  ntb_random_seed: 12345
  DEFINES: MACRO_A, MACRO_B
================================================================================

Input File: /path/to/log_file.log,
 Warning Type: TMPOAA, Description: some description
 File Path: some_file.v, 42

```

---

## 10. 终端输出说明

脚本运行过程中会在终端输出以下信息（带颜色标记）：

| 输出内容 | 颜色 | 说明 |
|---|---|---|
| 匹配到的日志文件列表 | 默认 | 列出所有匹配到的日志文件路径 |
| `begin <file>` | 默认 | 开始处理某个日志文件 |
| `Success gen ...` | 默认 | 某个日志文件处理完成 |
| `Sim Violations Summary` | 青色背景 | 仿真 Timing Violation 汇总 |
| `Sim Warning Summary` | 青色背景 | 仿真 Warning 汇总 |
| `Comp Warning Summary` | 青色背景 | 编译 Warning 汇总 |
| 各 warning_type / signal 统计 | 红色/灰色 | 按类型或信号名汇总的数量 |
| `Simulation Analysis Time` | 绿色 | 仿真分析耗时（秒） |
| `Compile Analysis Time` | 绿色 | 编译分析耗时（秒） |
| `Generated files` | 绿色 | 列出生成的输出文件绝对路径 |

### 错误/警告输出

| 输出内容 | 颜色 | 说明 |
|---|---|---|
| `Error-[File not Found]` | 红色 | 文件未找到 |
| `Error-[Invalid JSON]` | 红色 | JSON 配置文件格式错误 |
| `Error-[Path not Found]` | 红色 | 日志目录不存在 |
| `Warning-[Env Variable Missing]` | 红色 | `WORK_DIR` 环境变量未设置 |
| `Warning-[Result Empty]` | 黄色 | 未找到任何结果 |
| `Warning-[Filelist Empty]` | 黄色 | 未匹配到任何日志文件 |

---

## 11. 日志信息提取机制

`extract_log_info()` 函数从每个日志文件中自动提取以下仿真元信息，用于输出文件中的溯源：

| 提取项 | 正则模式 | 示例值 |
|---|---|---|
| `UVM_TESTNAME` | `\+UVM_TESTNAME=(\S+)` | `my_test_class` |
| `ntb_random_seed` | `\+ntb_random_seed=(-?\d+)` | `12345` 或 `-1` |
| `+define+` 宏 | `\+define\+([\w+]+)\+?` | `MACRO_A`, `MACRO_B` |

- 若某项未找到，返回 `"N/A"`（宏列表返回空列表）
- 多个 `+define+` 宏以 `+` 分隔，会逐个提取
- 提取结果写入输出文件的分组头部

---

## 12. 时间单位换算

脚本内部将所有时间统一转换为**皮秒（ps）**进行比较。

| 单位 | 换算为 ps | 示例 |
|---|---|---|
| `ps` | ×1 | `100ps` → 100 |
| `ns` | ×1,000 | `100ns` → 100,000 |
| `us` | ×1,000,000 | `1us` → 1,000,000 |
| `ms` | ×1,000,000,000 | `1ms` → 1,000,000,000 |

`convert_to_ps()` 函数接受格式为 `<数值><单位>` 的字符串（如 `"100ns"`），返回对应的皮秒整数值。

---

## 13. 正则匹配模式说明

### Warning 解析正则

```python
pattern = r'Warning-(\[.*?\]) ([^\r\n]+)(?:\r?\n([^\r\n]*),\s*[\\\n]*(\d+))?\D?((.+\n)+)'
```

匹配格式示例：
```
Warning-[TMPOAA] Some warning description
    /path/to/file.v, 42
    additional info line 1
    additional info line 2
```

### Timing Violation 解析正则

```python
pattern = r'"([^"]+)",\s*(\d+):\s*Timing violation in (\S+)\n(.*)'
```

匹配格式示例：
```
"verilog/sc12mc_40nmLP_base_rvt_c53.v", 103: Timing violation in top.saradc.u_sar_dig.clk_reg
    :100ns check timing ...
```

### 日志文件路径匹配

脚本使用 `os.walk()` 递归遍历目录，对每个文件的完整路径使用 `re.search()` 匹配配置中的 pattern。因此 pattern 中的路径分隔符需要注意：
- 使用正斜杠 `/` 作为路径分隔符
- pattern 不需要从根目录开始，只需匹配路径中的某一段即可（因为是 `search` 而非 `fullmatch`）

---

## 14. 环境变量

| 变量 | 说明 |
|---|---|
| `WORK_DIR` | 工作目录根路径。未通过 `-f` 指定 JSON 配置文件时，默认从 `$WORK_DIR/setup/warning_timing_vio_filter.json` 读取配置。若未设置，脚本会打印警告但不会退出（此时必须通过 `-f` 指定配置文件）。 |

### 设置方式

```bash
# bash / zsh
export WORK_DIR=/path/to/your/work_dir

# 临时使用
WORK_DIR=/path/to/work_dir python3 timing_warning_parser.py /path/to/logs
```

---

## 15. 依赖

- **Python**: 3.x
- **标准库**: 仅使用 Python 标准库，无需额外安装第三方包
  - `os` — 文件路径操作和目录遍历
  - `getopt` — 命令行参数解析
  - `sys` — 系统接口
  - `json` — JSON 配置文件解析
  - `re` — 正则表达式匹配
  - `time` — 耗时统计
  - `collections.defaultdict` — 分组统计（在 `save_info` 中按需导入）

---

## 16. 常见问题与排错

### Q1: 报错 `Error-[Env Variable Missing] do not set WORK_DIR`

**原因**: 未设置 `WORK_DIR` 环境变量，且未通过 `-f` 指定 JSON 配置文件。

**解决**:
```bash
# 方案一：设置环境变量
export WORK_DIR=/path/to/work_dir

# 方案二：使用 -f 指定配置文件
python3 timing_warning_parser.py -f /path/to/config.json /path/to/logs
```

### Q2: 报错 `Error-[Path not Found] The specified log directory ... does not exist`

**原因**: 指定的日志目录不存在。

**解决**: 检查路径拼写，确认目录存在。

### Q3: 输出 `Warning-[Filelist Empty] No simulation log files found`

**原因**: JSON 配置中的 `sim_log_pattern` 或 `comp_log_pattern` 未能匹配到任何文件。

**解决**:
- 检查 JSON 配置中的 pattern 是否正确
- 确认日志目录结构是否符合预期
- 可以临时将 pattern 改为 `".*"` 来测试是否能匹配到文件

### Q4: 输出 `Warning-[Result Empty]`

**原因**: 所有解析到的 Warning / Timing Violation 都被过滤规则过滤掉了，或者日志中本身就没有相关内容。

**解决**:
- 检查 JSON 过滤规则是否过于宽松
- 临时移除部分过滤规则，确认是否有原始数据

### Q5: JSON 配置文件报错 `Error-[Invalid JSON]`

**原因**: JSON 文件格式错误（如缺少逗号、引号不匹配等）。

**解决**: 使用 JSON 校验工具检查配置文件语法。

### Q6: 同时指定 `-c` 和 `-s` 时行为不符合预期

**原因**: 代码中使用 `if` 而非 `elif` 处理 `-c` 和 `-s`，因此 `-s` 会覆盖 `-c`，最终 action 为 `sim`。

**解决**: 不要同时指定 `-c` 和 `-s`。若需同时解析，不指定任何选项即可（默认 `both`）。

### Q7: 输出文件为空或内容不完整

**可能原因**:
- 日志文件编码问题（脚本使用默认编码读取）
- 日志格式与正则不匹配
- `first_ignore_line` 设置不当，导致有效内容被跳过

**解决**:
- 检查日志文件格式是否符合预期的 Warning / Timing Violation 格式
- 检查 `first_ignore_line` 中的特征字符串是否在日志中存在

---

## 17. 最佳实践

### 17.1 配置文件管理

- 将 JSON 配置文件纳入版本管理，便于追溯规则变更
- 为不同项目/模块维护独立的配置文件
- 在添加新过滤规则前，先不加规则运行一次，查看完整的 Warning/Violation 列表

### 17.2 过滤规则编写

- **信号名过滤**（`timing_violation_signal`）使用 `fullmatch`，编写正则时注意写完整的信号路径
- **路径过滤**使用 `search`，只需写路径中的关键片段即可
- 使用 `cross_match` 进行精确过滤时，尽量多指定维度以避免误过滤
- `violation_start_limit_global` 适合过滤 reset 阶段的集中违例，但要注意不要设得太大

### 17.3 结果分析

- 优先查看 `filtered_summary.txt` 获取全局概览
- 根据汇总中的 warning_type / signal 分布，决定是否需要添加新的过滤规则
- 利用输出文件中的日志溯源信息（UVM_TESTNAME、seed）定位具体的仿真 case

### 17.4 集成到回归流程

```bash
# 典型的回归测试后处理脚本
#!/bin/bash
export WORK_DIR=/path/to/project
RESULT_DIR=/path/to/regression/results

python3 timing_warning_parser.py -s -f $WORK_DIR/setup/filter.json $RESULT_DIR

# 检查是否有未过滤的违例
if [ -s filtered_timing_violations.txt ]; then
    echo "FAIL: Timing violations detected!"
    cat filtered_timing_violations.txt
    exit 1
else
    echo "PASS: No timing violations."
fi
```

---

## 附录：完整字段速查表

| JSON 字段 | 作用对象 | 匹配方式 | 过滤条件 |
|---|---|---|---|
| `comp_log_pattern` | 编译日志文件 | `re.search()` | 匹配的文件被处理 |
| `sim_log_pattern` | 仿真日志文件 | `re.search()` | 匹配的文件被处理 |
| `timing_violation_signal` | Timing Violation | `re.fullmatch()` | 信号名完全匹配 → 过滤 |
| `file_and_line` | Timing Violation | path: `re.search()`, line: 精确 | 路径+行号匹配 → 过滤 |
| `cross_match` | Timing Violation | 多维度 AND | 所有非空维度匹配 → 过滤 |
| `violation_start_limit_global` | Timing Violation | 时间比较 | 违例时间 ≤ 门限 → 过滤 |
| `first_ignore_line` | Timing Violation | 字符串包含 | 指定行前的内容被跳过 |
| `warning_type` | Warning | `re.fullmatch()` | 类型完全匹配 → 过滤 |
| `cross_match_warning` | Warning | 多维度 AND | 所有非空维度匹配 → 过滤 |
