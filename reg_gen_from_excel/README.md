# reg_gen_from_excel

## 概述

从 Excel 寄存器规格表自动生成数字验证所需的完整寄存器文件集，包括 UVM RAL 模型、SystemVerilog 验证用例、C 语言头文件等。

## 处理流程

```
Excel (.xlsx)
    │
    ▼
xlsx2json.py  ─── 合并单元格拆分 / 空行过滤 / 列名校验
    │
    ▼
JSON (嵌套结构，按寄存器名分组)
    │
    ▼
reg_gen.py  ─── 数组寄存器展开 / 位域校验 / 复位值一致性检查
    │
    ▼
Jinja2 模板渲染 (template/)
    │
    ▼
输出文件集 (SV / SVH / RALF / H)
```

## 目录结构

```
reg_gen_from_excel/
├── reg_gen_from_excel.py   # 主入口，编排整个生成流程
├── xlsx2json.py            # Excel -> 嵌套 JSON 转换
├── reg_gen.py              # Field/Register 数据模型、校验、数组展开、Jinja2 渲染
├── ral_gen_parse_yaml.py   # YAML 配置解析 (RegXlsx / RegSheet)
├── regsheet_format.yml     # YAML 配置模板（无权限/复位域）
├── regsheet_format_78x.yml # YAML 配置模板（含权限/复位域）
├── pubfunc/                # 公共函数库
├── doc/                    # 示例 Excel 输入
├── template/               # Jinja2 模板文件
│   └── permission/         # 权限检查模板 (APB/AHB/AXI)
└── tmp_pcu/                # 临时文件
```

## 环境依赖

- Python 3
- pip 包：`pandas`, `openpyxl`, `xlrd3`, `jinja2`, `pyyaml`
- 外部工具：`ralgen`（Synopsys，用于从 RALF 生成 UVM RAL 模型）

安装依赖：
```bash
pip install pandas openpyxl xlrd3 jinja2 pyyaml
```

## 快速开始

### 1. 配置 alias

在 `~/.cshrc` 中添加：
```csh
alias reg_gen_from_excel '/project/dig_veri_ip/cs-digital-ip/common_script/script_for_verify/scripts/ral_gen/reg_gen_from_excel/reg_gen_from_excel.py'
```

### 2. 准备 YAML 配置

根据 Excel 格式选择配置模板：

| 场景 | 配置文件 |
|------|----------|
| Excel 无权限/复位域列 | `regsheet_format.yml` |
| Excel 含权限/复位域列 | `regsheet_format_78x.yml` |

将对应模板复制到工作目录并按需修改。

### 3. 运行生成

```bash
# 基本用法
reg_gen_from_excel -i ./doc/RCU_1.xlsx -y regsheet_format_78x.yml -o test/

# 或使用默认 YAML 和输出路径
reg_gen_from_excel -i doc/Airbag_register_map.xlsx
```

### 命令行参数

| 参数 | 必填 | 说明 |
|------|------|------|
| `-i`, `--input_xlsx_path` | 是 | 输入的 Excel 寄存器规格文件 |
| `-y`, `--input_yaml_path` | 否 | YAML 配置文件（默认 `regsheet_format.yml`）|
| `-o`, `--output_dir_path` | 否 | 输出目录（默认 `./result`）|

## YAML 配置说明

### regsheet_format（列映射）

```yaml
regsheet_format:
    skip_rows: 2              # Excel 跳过的行数（表头上方）
    usecols: "A,C:H,J:L"      # 读取的列范围
    reg_name: "Register Name"  # 寄存器名列名
    reg_addr: "Address Offset" # 地址偏移列名
    reg_reset_value: "Reset_Value"
    field_name: "Field Name"
    field_bits: "Bits"
    field_access: "Field Attribute"
    field_reset_value: "Field Reset Value"
    access_mode_exist: False   # 是否含读写权限列
    reset_field_exist: False   # 是否含复位域列
```

### ut_cfg（生成控制）

```yaml
ut_cfg:
    ut_item_gen: True          # 是否生成验证文件集
    ut_reg_item_gen: True      # 是否生成 config_item
    rsv_ro_attr_chk: True      # 检查 reserved 字段必须为 RO
    register_array_en: False   # 是否启用寄存器数组模式
    add_reg_name_to_bus_opt: False
    ut_bus_write_opt: apb_write
    ut_bus_read_opt: apb_read
    reset_domains:             # 多复位域配置（可选）
      - { name: POR, priority: 0 }
      - { name: SYS, priority: 1 }
```

### template_test（模板调试模式）

```yaml
template_test:
    template_test_mode: True
    template_test_input_file_path: ./template/initialize_reg_info.sv
    template_test_output_file_name: initialize_test_reg_info.sv
```

## 输出文件

| 文件 | 目录 | 用途 |
|------|------|------|
| `{ip}_reg_addr.svh` | `common/` | 寄存器地址宏定义 |
| `{ip}_reg_msk.svh` | `common/` | 寄存器/位域掩码定义 |
| `{ip}_reg.ralf` → `{ip}_reg.sv` | `ral/` | UVM RAL 模型（经 ralgen） |
| `reg_info_cfg.sv` | `testcases/basetask/` | 寄存器信息配置 |
| `reg_collection.sv` | `testcases/basetask/` | 寄存器集合 |
| `initialize_{ip}_reg_info.sv` | `testcases/basetask/` | 寄存器初始化任务 |
| `common_register_chk_task.sv` | `testcases/basetask/` | 通用读写检查基任务 |
| `tc_{ip}_reg_access_rsvfield_chk.sv` | `testcases/` | Reserved 字段检查用例 |
| `tc_{ip}_reg_access_rst_chk.sv` | `testcases/` | 复位值检查用例 |
| `tc_{ip}_reg_access_permission.sv` | `testcases/` | 权限检查用例 |
| `Csx{IP}_Reg.h` / `Csx{IP}_RegDef.h` | `ccode/register/` | C 语言寄存器头文件 |
| `{ip}_config_item.sv` | `cfg/` | 寄存器配置项 |

## 关键特性

1. **数组寄存器展开**：支持 `XXXn` 命名 + `0xP + 0xQ*(n:a..b)` 地址格式，自动展开为独立寄存器或保持数组描述
2. **索引位域展开**：支持 `PCLx(x=0-15)` 格式的位域命名，自动按索引拆分
3. **多总线权限验证**：APB / AHB / AXI 三种总线权限检查文件生成
4. **多复位域支持**：通过 `reset_domains` 配置优先级排序
5. **严格校验**：
   - 位域重叠 / 缺失检查
   - 复位值一致性（字段复位值组合 == 寄存器复位值）
   - 字段属性合法性（RW/RO/WO/RC_W1/RC_W0/RC_R/RS）
   - Reserved 字段必须为 RO
   - 十六进制格式校验

## Excel 格式要求

- Sheet 名称须为合法标识符（`[a-zA-Z0-9_]+`），不能包含空格
- `memory map` 命名的 Sheet 会被自动跳过
- 列名须与 YAML 配置中的列名完全匹配（注意空格和换行）
- 地址偏移和复位值须为 `0x` 前缀的十六进制格式
- 合并单元格会被自动拆分填充
