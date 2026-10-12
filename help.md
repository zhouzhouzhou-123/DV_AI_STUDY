# M Script Help Manual

## 目录
1. [脚本介绍](#脚本介绍)
2. [快速开始](#快速开始)
3. [命令参考](#命令参考)
4. [配置说明](#配置说明)
5. [高级功能](#高级功能)
6. [故障排除](#故障排除)
7. [代码评价与改进建议](#代码评价与改进建议)

---

## 脚本介绍

### 概述
M 脚本是一个功能强大的 IC 验证仿真自动化脚本，用于简化 VCS 仿真流程。它提供了从编译到仿真的完整自动化解决方案，支持多种仿真模式和高级特性。

### 主要特性
- **多模式仿真**: 前仿真、后仿真、XA 混合仿真
- **智能编译**: 增量编译、签名检查、并行编译
- **自动化流程**: 自动环境配置、自动日志分析
- **覆盖率管理**: 自动收集、合并、分析覆盖率数据
- **回归测试**: vManager 集成、批量测试管理
- **调试支持**: 多种 Verdi 打开模式、KDB 调试

### 架构设计
```
m (主脚本)
├── CSRun          # 主执行类
│   ├── 编译流程
│   ├── 仿真流程
│   ├── 覆盖率分析
│   └── 调试功能
├── CmdArgs        # 命令行参数解析
│   ├── 参数验证
│   ├── 路径计算
│   └── 帮助信息
└── EnvCfg         # 环境配置
    ├── YAML 解析
    ├── 环境变量
    └── 目录管理
```

---

## 快速开始

### 环境准备
```bash
# 1. 设置环境变量
export WORK_DIR="/path/to/your/project"
export COMMON_VIP_PATH="/path/to/common_vip"
export VCS_HOME="/eda/synopsys/vcs/X-2025.06-SP2"
export UVM_HOME="$VCS_HOME/etc/uvm"

# 2. Source 环境脚本
source $WORK_DIR/sourceme.csh
```

### 基本使用
```bash
# 查看帮助
m h

# 运行测试用例
m run basetest 1

# 指定 seed
m run basetest seed=12345

# 添加 macro
m run basetest define=FSDB_DUMP_OFF

# 添加 plusargs
m run basetest plusargs=USER_PLUS=1
```

### 常用命令
```bash
# 编译
m run basetest 1              # 完整编译+仿真
m run_nocomp basetest 1       # 跳过编译
m run_incr basetest 1         # 增量编译

# 调试
m verdi                       # 打开 Verdi
m verdi tc_xxx                # 打开指定 testcase 的波形

# 覆盖率
m cov                         # 合并并查看覆盖率

# 清理
m clean                       # 清理临时文件
```

---

## 命令参考

### 基本语法
```
m OPERATION [TESTCASE_NAME] [OPTIONS]
```

### 操作类型

#### 仿真命令
| 命令 | 说明 | 示例 |
|------|------|------|
| `run` | 前仿真 (presim) | `m run basetest 1` |
| `run_nocomp` | 跳过编译 | `m run_nocomp basetest 1` |
| `run_incr` | 增量编译 | `m run_incr basetest 1` |
| `run_xprop` | Xprop 仿真 | `m run_xprop basetest 1` |
| `run_dc` | DC 后仿真 | `m run_dc basetest 1` |
| `run_pr` | PR 后仿真 | `m run_pr basetest 1` |
| `run_ss/ff/tt` | Corner 仿真 | `m run_ss basetest 1` |
| `run_xa` | XA 混合仿真 | `m run_xa basetest 1` |

#### 调试命令
| 命令 | 说明 | 示例 |
|------|------|------|
| `verdi` | 打开 Verdi | `m verdi` |
| `verdi tc_xxx` | 打开指定波形 | `m verdi basetest` |
| `verdi_duv` | 打开 DUT 波形 | `m verdi_duv` |
| `verdi_post` | 后仿真波形 | `m verdi_post` |
| `verdi_xa` | XA 仿真波形 | `m verdi_xa` |

#### 覆盖率命令
| 命令 | 说明 | 示例 |
|------|------|------|
| `cov` | 合并覆盖率 | `m cov` |
| `cov_vmnocomp` | VM 覆盖率 | `m cov_vmnocomp` |
| `vdbmerge` | 合并 VDB | `m vdbmerge` |

#### 管理命令
| 命令 | 说明 | 示例 |
|------|------|------|
| `vm` | 打开 vManager | `m vm` |
| `clean` | 清理文件 | `m clean` |
| `vio` | 收集 timing violation | `m vio` |
| `vsif` | 生成 VSIF | `m vsif` |
| `h` | 显示帮助 | `m h` |

### 选项参数

#### Seed 控制
```bash
m run basetest 123              # seed=123
m run basetest seed=123         # seed=123
m run basetest                  # 随机 seed
```

#### Define 选项
```bash
m run basetest define=FSDB_DUMP_OFF    # 关闭 FSDB
m run basetest define=VCD_DUMP_ON      # 开启 VCD
m run basetest define=USER_MACRO       # 自定义 macro
m run basetest define=M0+M1            # 多个 macro
```

#### Plusargs 选项
```bash
m run basetest plusargs=USER_PLUS=1              # 单个 plusarg
m run basetest plusargs=P0=1+P1=2                # 多个 plusargs
m run basetest define=M plusargs=P=1             # 组合使用
```

---

## 配置说明

### 配置文件结构

#### m.yml (主配置)
```yaml
# 环境选择
set_env:
    default: ../setup/set_env.csh
    POST_SIM: ../setup/set_env_post.csh

# RTL 文件列表
rtl_filelist:
    default: ../filelist/presim_rtl_filelist.f
    POST_SIM: ../filelist/postsim_rtl_filelist.f

# 编译参数
vlogan_default_comp_args:
    +define+SYNOPSYS_SV
    -sverilog
    -timescale=1ns/1ps
    -lca -kdb -full64

vcs_default_comp_args:
    -lca -kdb -full64
    -debug_acc+all

# 仿真参数
vcs_default_sim_args:
    +ntb_random_seed=1
    -lca -kdb
```

#### envcfg.yml (环境配置)
```yaml
# 顶层模块
duv_top: xcan_top
tb_top: top

# 编译选项
split_lib: True              # 启用 split-library
vericom_use_wave_do: False   # 使用 wave.do

# 覆盖率
cov_default_args: "-cm line+cond+fsm+branch+tgl+assert"
has_cm_hier_cfg: False

# vManager
use_vmanager: True
vmanager_server: "192.168.100.205:8080"
```

### 目录结构要求
```
project/
├── rtl/                    # RTL 源码
│   ├── *.v
│   ├── *.sv
│   └── *.vhd
├── testcases/              # 测试用例
│   ├── basetest.sv
│   └── *.sv
├── env/                    # 环境代码
│   ├── vir_seqr.sv
│   └── *.sv
├── sequence/               # 序列
│   ├── base_vir_seq.sv
│   └── *.sv
├── filelist/               # 文件列表
│   ├── presim_rtl_filelist.f
│   ├── tb_filelist.f
│   └── *.f
├── setup/                  # 配置文件
│   ├── m.yml
│   ├── envcfg.yml
│   └── set_env.csh
├── scripts/                # 脚本
│   └── m
└── sim_1/                  # 仿真目录
    ├── comp_result/        # 编译结果
    ├── result/             # 仿真结果
    └── wave_log/           # 波形日志
```

---

## 高级功能

### 增量编译
```bash
# 启用增量编译
m run_incr basetest 1

# 工作原理
1. 检查 RTL/TB 文件签名
2. 仅编译修改的文件
3. 链接未修改的库
```

### Split-Library 编译
```yaml
# envcfg.yml
split_lib: True
```
```bash
# 分别编译 RTL 和 TB
m run_rtl basetest          # 仅编译 RTL
m run_tb basetest           # 仅编译 TB
m run basetest              # 完整编译
```

### 签名机制
```python
# 自动检查文件修改
def m_rtl_signature(self):
    # 计算 RTL 文件哈希
    # 比较签名文件
    # 决定是否重新编译
```

### 覆盖率管理
```bash
# 收集覆盖率
m run basetest 1            # 自动收集

# 合并覆盖率
m cov                       # 合并所有 vdb

# 查看覆盖率
# 自动打开 Verdi 覆盖率视图
```

### vManager 集成
```bash
# 打开 vManager
m vm

# 生成 VSIF
m vsif

# 回归测试
# 自动提交到 vManager 服务器
```

---

## 故障排除

### 常见问题

#### 1. 编译失败
```
Error: Cannot find filelist
```
**解决**:
- 检查 `filelist/*.f` 路径
- 检查环境变量 `WORK_DIR`
- 确认文件存在

#### 2. License 错误
```
Cannot connect to the license server
```
**解决**:
```bash
# 检查 license 服务器
echo $SNPSLMD_LICENSE_FILE
ping lic07

# 设置正确的 license
export SNPSLMD_LICENSE_FILE=27020@lic07
```

#### 3. 仿真失败
```
simv_basetest is not exists
```
**解决**:
- 先执行编译: `m run basetest 1`
- 检查 `comp_result/` 目录
- 确认编译成功

#### 4. 波形无法打开
```
Cannot find FSDB file
```
**解决**:
- 检查是否开启 FSDB: 不要使用 `FSDB_DUMP_OFF`
- 检查 `result/` 目录
- 确认仿真完成

#### 5. 覆盖率合并失败
```
urg: command not found
```
**解决**:
```bash
# 检查 VCS 环境
which urg
echo $VCS_HOME

# 重新 source 环境
source $WORK_DIR/sourceme.csh
```

### 日志查看
```bash
# 编译日志
cat comp_result/presim/comp_basetest/comp_basetest.log

# 仿真日志
cat result/presim/basetest/basetest_1/basetest_1.log

# 错误检测日志
cat result/presim/basetest/basetest_1/basetest_1_error_detect.log
```

### 调试技巧
```bash
# 详细输出
m run basetest 1 2>&1 | tee debug.log

# 检查环境变量
env | grep -E "WORK_DIR|VCS_HOME|UVM_HOME"

# 检查配置文件
cat setup/m.yml
cat setup/envcfg.yml
```

---

## 代码评价与改进建议

### 优点

#### 1. 架构设计
- **模块化**: CSRun、CmdArgs、EnvCfg 职责清晰
- **可扩展**: 易于添加新的仿真模式
- **配置驱动**: YAML 配置灵活

#### 2. 功能完整
- **全流程覆盖**: 编译→仿真→覆盖率→调试
- **多场景支持**: presim、postsim、XA
- **自动化程度高**: 减少手动操作

#### 3. 性能优化
- **增量编译**: 节省编译时间
- **签名机制**: 避免重复编译
- **并行编译**: Split-library 支持

#### 4. 用户体验
- **帮助信息**: 详细的命令参考
- **时间统计**: 清晰的性能反馈
- **错误提示**: 友好的错误信息

### 待改进项

#### 1. 代码质量
**问题**: 部分函数过长 (>100行)
```python
# 当前: execute_simulation_command() 约 70 行
# 建议: 拆分为多个子函数
def build_sim_command_base(self): ...
def add_coverage_args(self): ...
def add_wave_args(self): ...
```

**问题**: 缺少类型注解
```python
# 当前
def execute_command_on_shell(self, command_to_be_executed):
    ...

# 建议
def execute_command_on_shell(self, command: str) -> int:
    ...
```

**问题**: 硬编码路径
```python
# 当前
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../pubfunc")

# 建议
PUBFUNC_DIR = os.environ.get("PUBFUNC_DIR", 
    os.path.abspath(cur_scr_dir + "/../../pubfunc"))
```

#### 2. 异常处理
**问题**: 异常处理不完善
```python
# 当前
log_file = open(log_file_path, "r")
log_line = log_file.readline()

# 建议
try:
    with open(log_file_path, "r") as log_file:
        log_line = log_file.readline()
except FileNotFoundError:
    logger.error(f"Log file not found: {log_file_path}")
    return False
except PermissionError:
    logger.error(f"Permission denied: {log_file_path}")
    return False
```

#### 3. 日志系统
**问题**: 日志不统一
```python
# 当前
print("execute command :")
print(command_to_be_executed)

# 建议
import logging
logger = logging.getLogger(__name__)
logger.info(f"Executing: {command}")
logger.debug(f"Command details: {details}")
```

#### 4. 测试覆盖
**问题**: 缺少单元测试
```python
# 建议添加
import unittest

class TestCmdArgs(unittest.TestCase):
    def test_parse_seed(self):
        cmd = CmdArgs(["m", "run", "test", "123"], env_cfg)
        cmd.parse_cmdargs()
        self.assertEqual(cmd.rand_seed, 123)
    
    def test_parse_define(self):
        cmd = CmdArgs(["m", "run", "test", "define=M0+M1"], env_cfg)
        cmd.parse_cmdargs()
        self.assertIn("M0", cmd.usr_macros)
        self.assertIn("M1", cmd.usr_macros)
```

#### 5. 文档完善
**问题**: 缺少 docstring
```python
# 建议
def execute_simulation_command(self):
    """
    Execute VCS simulation command.
    
    This method builds and executes the VCS simulation command
    with all necessary arguments including:
    - Random seed
    - Test name
    - Coverage options
    - Wave dump options
    
    Returns:
        int: Exit code from simulation
    
    Raises:
        FileNotFoundError: If simv file not found
        RuntimeError: If simulation fails
    """
    ...
```

#### 6. 配置验证
**问题**: 缺少配置验证
```python
# 建议
def validate_config(self):
    """Validate configuration before execution."""
    if not os.path.exists(self.work_dir):
        raise ConfigError(f"WORK_DIR not found: {self.work_dir}")
    
    if not self.duv_top:
        raise ConfigError("duv_top not set in envcfg.yml")
    
    if not os.path.exists(self.pre_sim_duv_flist):
        raise ConfigError(f"Filelist not found: {self.pre_sim_duv_flist}")
```

#### 7. 性能监控
**问题**: 缺少详细性能数据
```python
# 建议
import psutil
import time

class PerformanceMonitor:
    def __init__(self):
        self.start_time = None
        self.peak_memory = 0
    
    def start(self):
        self.start_time = time.time()
        self.process = psutil.Process()
    
    def report(self):
        elapsed = time.time() - self.start_time
        memory = self.process.memory_info().rss / 1024 / 1024
        print(f"Time: {elapsed:.2f}s, Peak Memory: {memory:.2f}MB")
```

### 改进优先级

#### 高优先级
1. **添加异常处理**: 提高脚本健壮性
2. **统一日志系统**: 便于问题诊断
3. **添加单元测试**: 保证代码质量

#### 中优先级
4. **重构长函数**: 提高可维护性
5. **添加类型注解**: 提高代码可读性
6. **配置验证**: 提前发现配置错误

#### 低优先级
7. **性能监控**: 详细性能分析
8. **文档完善**: 添加 docstring
9. **支持多工具**: Xcelium、Questa

### 重构建议

#### 1. 提取公共类
```python
# compiler.py
class Compiler:
    def compile_vhdl(self): ...
    def compile_vlog(self): ...
    def link(self): ...

# simulator.py
class Simulator:
    def run_presim(self): ...
    def run_postsim(self): ...
    def run_xa(self): ...

# coverage.py
class CoverageManager:
    def collect(self): ...
    def merge(self): ...
    def analyze(self): ...
```

#### 2. 使用配置类
```python
# config.py
class Config:
    def __init__(self, config_file):
        self.load(config_file)
        self.validate()
    
    def load(self, config_file):
        with open(config_file) as f:
            self.data = yaml.safe_load(f)
    
    def validate(self):
        # 验证配置完整性
        ...
```

#### 3. 使用命令模式
```python
# commands.py
class Command:
    def execute(self): ...

class RunCommand(Command):
    def execute(self): ...

class VerdiCommand(Command):
    def execute(self): ...

class CovCommand(Command):
    def execute(self): ...
```

---

## 附录

### 环境变量参考
| 变量 | 说明 | 示例 |
|------|------|------|
| `WORK_DIR` | 工作目录 | `/path/to/project` |
| `COMMON_VIP_PATH` | VIP 库路径 | `/path/to/common_vip` |
| `VCS_HOME` | VCS 安装路径 | `/eda/synopsys/vcs/X-2025.06-SP2` |
| `UVM_HOME` | UVM 库路径 | `$VCS_HOME/etc/uvm` |
| `VMANAGER_PATH` | vManager 路径 | `/path/to/vmanager` |
| `SNPSLMD_LICENSE_FILE` | License 服务器 | `27020@lic07` |

### 文件扩展名
| 扩展名 | 说明 |
|--------|------|
| `.v` | Verilog 源文件 |
| `.sv` | SystemVerilog 源文件 |
| `.vhd` | VHDL 源文件 |
| `.f` | Filelist 文件 |
| `.yml` | YAML 配置文件 |
| `.fsdb` | FSDB 波形文件 |
| `.vcd` | VCD 波形文件 |
| `.vdb` | 覆盖率数据库 |

### 相关资源
- VCS 用户指南: Synopsys 官方文档
- UVM 参考: IEEE 1800.2 标准
- vManager 用户指南: Synopsys 官方文档

---

**文档版本**: 1.0  
**最后更新**: 2026-10-12  
**维护者**: zhouxk@chipsea.com  
**反馈**: 如有问题或建议，请联系维护者
