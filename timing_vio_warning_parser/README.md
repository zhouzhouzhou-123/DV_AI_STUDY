# Timing Violation & Warning Parser

## 概述

`timing_warning_parser.py` 是一个用于解析数字仿真/编译日志中 **Timing Violation（时序违例）** 和 **Warning（告警）** 信息的 Python 脚本。它能自动遍历指定日志目录，按规则提取并过滤结果，最终输出汇总报告和过滤后的详细结果文件。

**作者**: xiayu (xiayu@chipsea.com)
**部门**: Digital Verification Department

---

## 功能

| 功能模块 | 说明 |
|---|---|
| Warning 解析 | 从编译/仿真日志中提取 `Warning-[TYPE]` 格式的告警信息 |
| Timing Violation 解析 | 从仿真日志中提取 `Timing violation in <signal>` 格式的时序违例信息 |
| 规则过滤 | 根据 JSON 配置文件中的多种规则过滤掉已知的、可忽略的告警和违例 |
| 汇总统计 | 按 warning type 和 violation signal 进行数量汇总，在终端高亮输出 |
| 结果保存 | 将过滤后的结果写入文本文件 |

---

## 输入参数

脚本通过命令行参数运行，语法如下：

```bash
python3 timing_warning_parser.py [OPTIONS] <log_dir>
```

### 位置参数

| 参数 | 必填 | 说明 |
|---|---|---|
| `log_dir` | **是** | 日志文件所在的根目录路径。脚本会递归遍历该目录下所有匹配配置文件中 pattern 的日志文件。该目录必须存在，否则报错退出。 |

### 可选参数

| 短选项 | 长选项 | 说明 |
|---|---|---|
| `-c` | `--comp` | **仅解析编译日志**。只处理 `comp_log_pattern` 匹配的编译日志文件，提取 Warning 信息。 |
| `-s` | `--sim` | **仅解析仿真日志**。只处理 `sim_log_pattern` 匹配的仿真日志文件，提取 Warning 和 Timing Violation 信息。 |
| `-f <path>` | `--file <path>` | **指定 JSON 配置文件路径**。默认读取 `$WORK_DIR/setup/warning_timing_vio_filter.json`。 |
| `-h` | `--help` | 显示帮助信息并退出。 |

### 默认行为

- 若 **不指定** `-c` 或 `-s`，默认行为为 `both`，即 **同时解析编译日志和仿真日志**。
- 若 **不指定** `-f`，脚本从环境变量 `WORK_DIR` 读取路径，拼接为 `$WORK_DIR/setup/warning_timing_vio_filter.json`。若 `WORK_DIR` 未设置，会打印警告。

---

## 使用示例

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

---

## JSON 配置文件详解

配置文件为 JSON 格式，控制日志匹配规则和过滤规则。各字段说明如下：

### 日志文件匹配

| 字段 | 类型 | 说明 |
|---|---|---|
| `comp_log_pattern` | `string[]` | 正则表达式列表，用于匹配**编译日志**文件路径。例如 `"comp_result/comp_.*.log$"` 匹配 `comp_result/` 目录下以 `comp_` 开头、`.log` 结尾的文件。 |
| `sim_log_pattern` | `string[]` | 正则表达式列表，用于匹配**仿真日志**文件路径。例如 `".*.log$"` 匹配所有 `.log` 文件。 |

### Timing Violation 过滤规则

| 字段 | 类型 | 说明 |
|---|---|---|
| `timing_violation_signal` | `string[]` | 信号名正则列表。违例信号名**完全匹配**任一 pattern 时，该违例被过滤（忽略）。例如 `"top.saradc.u_sar_dig.bwd_ch_en_reg"` 精确匹配该信号，`"top.saradc.u_sar_dig.t2a_sar_sample_neg_reg_\\d+"` 匹配带数字后缀的信号。 |
| `file_and_line` | `object[]` | 按文件路径 + 行号过滤。`path` 为正则匹配文件路径，`line_num` 为具体行号（`-1` 表示匹配该文件所有行）。两者同时满足时，该违例被过滤。 |
| `cross_match` | `object[]` | **交叉匹配规则**，支持 path / line_num / timing_violation_signal / timing_violation_keyword 四个维度的组合过滤。任一维度为 `"-1"` 表示该维度不做限制。所有非 `"-1"` 维度都匹配时，该违例被过滤。 |
| `violation_start_limit_global` | `string` | **全局时间门限**。格式为 `"<数值><单位>"`（如 `"100ns"`），单位支持 `ps`/`ns`/`us`/`ms`。违例发生时间 **早于或等于** 该门限的被过滤。设为 `"-1"` 表示不做全局时间过滤。 |
| `first_ignore_line` | `object[]` | **起始行过滤**。在解析 timing violation 前，先找到日志中包含 `specific_character` 的行，忽略该行**之前**的所有内容。`enable_specific_character_filter` 为 `true` 时启用。多个规则取最大行号，即忽略所有规则指定行之前的内容。适用于跳过 reset 阶段等场景。 |

### Warning 过滤规则

| 字段 | 类型 | 说明 |
|---|---|---|
| `warning_type` | `string[]` | Warning 类型正则列表。warning type **完全匹配**任一 pattern 时，该 warning 被过滤。例如 `"TMPOAA"` 精确匹配，`"ABC"` 精确匹配。 |
| `cross_match_warning` | `object[]` | **Warning 交叉匹配规则**，支持 module_path / line_num / warning_type / warning_info_keyword 四个维度的组合过滤。任一维度为 `"-1"` 表示该维度不做限制。所有非 `"-1"` 维度都匹配时，该 warning 被过滤。 |

### JSON 配置示例

```json
{
    "comp_log_pattern": ["comp_result/comp_.*.log$"],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [
        "top.saradc.u_sar_dig.bwd_ch_en_reg",
        "top.saradc.u_sar_dig.t2a_sar_sample_neg_reg_\\d+"
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
        }
    ],
    "warning_type": ["TMPOAA", "ABC", "EAANUMASSIGN"],
    "cross_match_warning": [
        {
            "module_path": "hsm_top/hsm_top",
            "line_num": -1,
            "warning_info_keyword": "SYNOPSYS_UNCONNECTED_\\d+",
            "warning_type": "IWNF"
        }
    ],
    "first_ignore_line": [
        {
            "specific_character": "wait global reset release done ....",
            "enable_specific_character_filter": true
        }
    ]
}
```

---

## 输出文件

脚本在当前工作目录下生成以下文件：

| 文件名 | 触发条件 | 内容 |
|---|---|---|
| `filtered_timing_violations.txt` | action 为 `both` 或 `sim` | 过滤后的 Timing Violation 详细信息 |
| `filtered_warnings_in_sim.txt` | action 为 `both` 或 `sim` | 过滤后的仿真日志 Warning 详细信息 |
| `filtered_warnings.txt` | action 为 `both` 或 `comp` | 过滤后的编译日志 Warning 详细信息 |

---

## 终端输出

脚本运行过程中会在终端输出：

1. **匹配到的日志文件列表**
2. **处理进度信息**（`begin <file>` / `Success gen ...`）
3. **汇总统计**：
   - Sim Warning Summary — 按 warning type 汇总数量
   - Sim Violations Summary — 按 violation signal 汇总数量
   - Comp Warning Summary — 按 warning type 汇总数量
4. **耗时统计**：仿真分析耗时和编译分析耗时

---

## 依赖

- Python 3.x
- 仅使用标准库：`os`, `getopt`, `sys`, `json`, `re`, `time`

---

## 环境变量

| 变量 | 说明 |
|---|---|
| `WORK_DIR` | 工作目录根路径。未通过 `-f` 指定 JSON 配置文件时，默认从 `$WORK_DIR/setup/warning_timing_vio_filter.json` 读取配置。 |
