# reg_gen_from_excel 项目说明

## 项目概述
从 Excel 寄存器规格表自动生成 UVM RAL 模型、验证测试用例、C 头文件等。

## 核心流程
```
Excel (.xlsx) → xlsx2json.py → JSON → reg_gen.py (展开/校验) → Jinja2 渲染 → 输出文件
```

## 文件职责

### 主脚本
- **reg_gen_from_excel.py**: 主入口，编排整个流程
- **xlsx2json.py**: Excel 转嵌套 JSON
- **reg_gen.py**: 寄存器数据模型（Field/Register 类）、校验逻辑
- **ral_gen_parse_yaml.py**: YAML 配置解析、RegSheet/RegXlsx 类

### 配置文件
- **regsheet_format.yml**: 无 access_mode/reset_field 的配置
- **regsheet_format_78x.yml**: 含 access_mode/reset_field + reset_domains

### 目录结构
- **doc/**: 示例 Excel 输入文件
- **template/**: Jinja2 模板文件（SV/H/RALF）
- **template/permission/**: 权限检查模板（APB/AHB/AXI）

## 技术栈
- Python 3
- 依赖库：`xlrd3`, `pandas`, `openpyxl`, `jinja2`, `pyyaml`
- Jinja2 模板引擎

## 使用方式
```bash
reg_gen_from_excel -i ./doc/RCU_1.xlsx -y regsheet_format_78x.yml -o test/
```

## 关键特性
1. **数组寄存器**：支持 `XXXn` 命名 + `0xP + 0xQ*(n:a..b)` 地址格式
2. **多总线权限**：APB/AHB/AXI 权限验证
3. **多复位域**：通过 `reset_domains` 配置优先级
4. **严格校验**：位域冲突、复位值一致性、字段属性合法性

## 输出文件类型
| 文件 | 用途 |
|------|------|
| `*_reg_addr.svh` | 寄存器地址宏定义 |
| `*_reg_msk.svh` | 寄存器/位域掩码 |
| `*_reg.ralf` → `*_reg.sv` | UVM RAL 模型 |
| `initialize_*_reg_info.sv` | 寄存器初始化任务 |
| `common_register_chk_task.sv` | 通用读写检查基任务 |
| `tc_*_reg_access_*.sv` | 各类检查用例 |
| `Csx*_Reg.h` / `Csx*_RegDef.h` | C 语言头文件 |

## 代码约定
- 类命名：大驼峰（RegSheet, Field, Register）
- 变量命名：小写下划线（reg_name, field_bits）
- 模板文件：`.sv`, `.ralf`, `.h`, `.svh`
- 输出目录自动创建，include 文件自动维护
