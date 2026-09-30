# m - VCS/UVM 验证自动化脚本

## 概述

`m` 是一个 Python 脚本，封装了 VCS 编译、仿真、Verdi 调试和 VManager 回归的完整流程。支持增量编译、混合语言编译、split-library 分布式编译、VManager 回归等高级特性。

## 文件结构

```
m/v1.0/
├── m              # 主脚本（与 csrun.py 内容相同）
├── csrun.py       # 核心逻辑实现（CSRun 类）
├── csregr.py      # 回归分析脚本（CSRegr 类）
├── cmdargs.py     # 命令行参数解析（CmdArgs 类）
├── envcfg.py      # 环境配置加载（EnvCfg 类，读取 envcfg.yml）
└── pubfunc/       # 公共函数库（上级目录 ../../pubfunc）
    └── pubfunc.py

依赖的 vm_regr_script 模块：
├── postgroupscript.py          # vmcomplink 链接逻辑
├── vm_regr_clean_by_postrun.py # vmsimclean 清理逻辑
├── log_scanner.py              # 仿真日志扫描
├── lsf_fail.flt                # VManager 日志过滤器
└── gen_file_from_testcases.py  # VSIF/testpkg 生成
```

## 环境要求

- Python 3.8+
- Synopsys VCS X-2025.06-SP2 或更高版本
- VManager 23.09（回归模式）
- `setup/envcfg.yml` 配置文件（项目级）
- `setup/synopsys_sim.setup`（VCS 库映射，由脚本自动生成）

## 快速开始

```bash
# 1. 设置环境
source sourceme.csh

# 2. 单用例仿真（前仿，随机 seed，FSDB 开启）
m run basetest

# 3. 指定 seed 和 macro
m run basetest define=USER_MACRO seed=12345

# 4. 增量编译仿真
m incr_run basetest

# 5. 不重新编译
m run_nocomp basetest

# 6. 打开 Verdi
m verdi basetest
```

## 命令参考

### 基础命令

| 命令 | 说明 |
|------|------|
| `m h` | 显示帮助信息 |
| `m make tc_xxx` | 仅编译 C 代码 |
| `m clean` | 清理编译产物 |

### 仿真命令

| 命令 | 说明 |
|------|------|
| `m run tc_xxx` | 前仿：随机 seed，FSDB 开启 |
| `m run_nocomp tc_xxx` | 前仿：不重新编译 |
| `m run_xprop tc_xxx` | 前仿：启用 XPROP（配置文件 `$WORK_DIR/cfg/xprop.cfg`） |
| `m run_incr_run tc_xxx` | 前仿：增量编译 |
| `m run_ss tc_xxx` | 后仿：SS_CORNER |
| `m run_ff tc_xxx` | 后仿：FF_CORNER |
| `m run_tt tc_xxx` | 后仿：TT_CORNER |
| `m run_dc tc_xxx` | 后仿：DC 网表，无 SDF |
| `m run_pr tc_xxx` | 后仿：PR 网表，无 SDF |

### 编译命令

| 命令 | 说明 |
|------|------|
| `m run_comp tc_xxx` | 编译 RTL + TB（结果在当前 sim_dir） |
| `m run_vmcomp tc_xxx` | 编译到 `$BRUN_RUN_DIR`（回归 comp_group 用） |
| `m comp_rtl tc_xxx` | 仅编译 RTL（split-lib 模式） |
| `m comp_tb tc_xxx` | 仅编译 TB（split-lib 模式） |

### PKG 模式命令

PKG 模式使用 `simv_test_pkg`（在 `envcfg.yml` 中声明，默认 `test_pkg`）作为统一的 simv 名称，适用于 VManager 回归。

| 命令 | 说明 |
|------|------|
| `m run_pkg tc_xxx` | 编译，simv 命名为 `simv_test_pkg` |
| `m run_pkg_nocomp tc_xxx` | 不重编译，使用 `simv_test_pkg` |
| `m run_vmcomp_pkg tc_xxx` | 编译到 `$BRUN_RUN_DIR`，`test_pkg` 命名 |
| `m run_vmnocomp tc_xxx` | 使用 `$VMCOMP_PATH` 下的 `simv_test_pkg` 仿真 |
| `m run_dc_pkg tc_xxx` | DC 网表，`test_pkg` 命名 |
| `m run_ss_pkg tc_xxx` | SS_CORNER，`test_pkg` 命名 |

### Verdi 命令

| 命令 | 说明 |
|------|------|
| `m verdi` | 打开 RTL 视图 |
| `m verdi_duv` | 打开 DUT 视图 |
| `m verdi_dc` | 打开 DC 网表视图（无 SDF） |
| `m verdi_post` | 打开后仿网表视图 |
| `m verdi_xa` | 打开 XA 协同仿真视图 |
| `m verdi_vmnocomp` | 从 `$VMCOMP_PATH` 打开 KDB |
| `m verdi_vmnocomp_ss` | 打开 SS corner 的 KDB |

### VManager 回归命令

| 命令 | 说明 | VSIF 阶段 |
|------|------|-----------|
| `m vm` | 打开 VManager | - |
| `m vmcomplink` | 链接 simv/simv.daidir 到 `$VMCOMP_PATH` | post_group_script |
| `m vmsimclean` | 清理失败用例的 vdb，保留 local_log.log | post_run_script |
| `m vdbmerge` | 合并 coverage 数据，打开 Verdi | post_session_script |

### 其他命令

| 命令 | 说明 |
|------|------|
| `m vio` | 收集时序违规（默认路径 `regression/result/`） |
| `m vio TARGET_PATH` | 指定路径收集时序违规 |
| `m cov` | 合并 coverage 并打开 Verdi |
| `m cov_vmnocomp` | vmnocomp 模式的 coverage 分析 |
| `m vsif` | 从 testcases 生成 VSIF 和 testpkg |
| `m init_all` | 初始化所有工具（docmake + duvcfg + exti） |
| `m init_duvcfg` | 初始化 DUT 配置 |
| `m init_genexti` | 生成 EXTI 用例 |

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `define=MACRO` | 定义宏 | `define=FSDB_DUMP_OFF` |
| `define=M0+M1` | 定义多个宏 | `define=POST_SIM_ON+FSDB_DUMP_OFF` |
| `seed=N` | 指定随机种子 | `seed=12345` |
| `plusargs=ARG` | 添加 plusargs | `plusargs=USER_PLUS=1` |
| `plusargs=A=1+B=2` | 多个 plusargs | `plusargs=USER_PLUS0=1+USER_PLUS1=2` |
| `cache=N` | 缓存选项（0: 禁用, 1: 启用） | `cache=1` |
| `spice=FILE` | XA spice 文件 | `spice=input.sp` |
| `cfg=NAME` | XA 配置名 | `cfg=default_cfg` |
| `init=FILE` | XA init 文件 | `init=default_vcsAD.init` |
| `pretitle=TEXT` | Verdi 标题 | `pretitle=AAA` |

### 内置自动宏

| 宏 | 触发条件 |
|-----|----------|
| `FSDB_DUMP_OFF` | 用户手动指定，关闭 FSDB 波形 |
| `VCD_DUMP_ON` | 用户手动指定，启用 VCD 波形 |
| `POST_SIM_ON` | `run_ss/ff/tt/dc/pr` 自动添加 |
| `XA_SIM` | `run_xa` 自动添加 |
| `DC_CORNER` | `run_dc` 自动添加 |
| `PG_CORNER` | `run_pg` 自动添加 |
| `PA_SIM` | `run_pa` 自动添加 |
| `<CORNER>_CORNER` | `run_ss/ff/tt` 自动添加 |
| `DUT_ERROR_SCANNER_ON` | `dut_error_scanner_on: true` 时自动添加 |

## 配置文件

### envcfg.yml

```yaml
# ---- 目录配置 ----
testcases_dirname: testcases
wave_dirname: wave_log
log_dirname: wave_log

# ---- DUT 配置 ----
duv_top: top
tb_top: top

# ---- VManager 配置 ----
use_vmanager: true
vmanager_local: false
vmanager_server: 192.168.21.172:8088

# ---- 文件列表 ----
pre_sim_duv_flist: $WORK_DIR/filelist/presim_rtl_filelist.f
pre_sim_duv_vhdl_flist: $WORK_DIR/filelist/presim_rtl_vhdl_filelist.f
post_sim_duv_flist: $WORK_DIR/filelist/postsim_rtl_filelist.f
tb_flist: $WORK_DIR/filelist/tb_filelist.f
tb_xa_flist: $WORK_DIR/filelist/tb_xa.f
tb_post_flist: $WORK_DIR/filelist/tb_post.f
sva_bind_flist: $WORK_DIR/filelist/sva_bind_filelist.f

# ---- 编译选项 ----
vlogan_default_comp_args:
    +define+SYNOPSYS_SV
    -sverilog +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm_pkg.sv
    -timescale=1ns/1ps
    -lca -kdb -full64 +v2k +libext+.sv+.v
    -debug_acc+all -debug_region=cell+encrypt

vcs_default_comp_args:
    ${UVM_HOME}/src/dpi/uvm_dpi.cc -CFLAGS -DVCS
    -timescale=1ns/1ps
    -debug_acc+all -debug_region=cell+encrypt -kdb -lca -full64 +vpi

# ---- split-library 编译 ----
split_lib: false

# ---- PKG 模式 ----
simv_test_pkg: test_pkg
vmcomp_path: $VMCOMP_PATH

# ---- 外购 IP ----
vendor_ip:
    vhdl_libs:
        linflex3_lib: $FLEXLIN_PATH/flexlin
        xcans_lib: $CANFD_PATH/canfd
        ae_notech_lib: $GTM_PATH

# ---- 特性开关 ----
dut_error_scanner_on: true     # DUT $display("Error:") 转 uvm_error
csa_model_on: true             # CSA 模拟模型
timing_violation_limit: 10000  # 时序违规上限（0 = 无限）

# ---- 按用例名自动添加宏 ----
add_macro_by_test_name_info:
    scenario:
        SCENARIO_TEST_ON
```

## 路径结构

### 单用例模式

```
$SIM_DIR/
├── comp_result/
│   └── presim/
│       └── comp_basetest/
│           ├── simv_basetest
│           ├── simv_basetest.daidir/
│           ├── synopsys_sim.setup    (自动生成)
│           └── *.log
├── wave_log/
│   └── presim/
│       └── basetest/
│           └── basetest_<seed>.fsdb
└── result/
    └── presim/
```

### 增量编译模式 (incr_run)

```
$SIM_DIR/
├── comp_result/
│   └── presim/
│       ├── rtl_pkg_shared/           # 共享 RTL（所有 testcase 复用）
│       │   ├── .m_lib_signature      # RTL 签名文件
│       │   ├── .rtl_lock             # 文件锁
│       │   ├── linflex3_lib/         # 外购 IP（按路径前缀分组）
│       │   ├── xcans_lib/
│       │   └── ae_notech_lib/
│       ├── comp_basetest/            # testcase 独立目录
│       │   ├── tb_pkg/               # TB 编译产物
│       │   │   └── .m_lib_signature  # TB 签名文件
│       │   ├── synopsys_sim.setup    # 库映射（自动生成）
│       │   ├── simv_basetest
│       │   └── *.log
│       └── comp_basetest_one/        # 另一个 testcase
│           ├── tb_pkg/
│           └── ...
```

### VManager 回归模式（PKG）

```
$VMCOMP_PATH/
└── comp_result/
    └── presim/
        └── comp_test_pkg/            # pkg 模式统一目录
            ├── simv_test_pkg*         (符号链接 → $BRUN_RUN_DIR)
            ├── simv_test_pkg*.daidir/ (符号链接)
            └── *.vdb/                 (coverage 数据)

$BRUN_RUN_DIR/
├── comp_group/run_N/
│   └── comp_result/presim/comp_test_pkg/
│       ├── simv_test_pkg*
│       └── simv_test_pkg*.daidir/
└── run_group/run_N/
    ├── local_log.log
    └── wave_log/presim/basetest/
```

## 增量编译

### 基本用法

```bash
# 首次编译（全量）
m incr_run basetest

# 修改 TB 后增量编译（仅重编译 TB）
m incr_run basetest

# 修改 RTL 后增量编译（清除所有 TB，全量重编译）
m incr_run basetest

# 不同 define 配置
m incr_run basetest define=MY_DEFINE_TEST

# 仅编译 RTL
m comp_rtl basetest

# 仅编译 TB
m comp_tb basetest

# 强制全量编译（跳过签名检查）
M_FORCE_COMPILE=1 m incr_run basetest
```

### 编译流程

```
incr_run 四步编译流程：
  Step 1/3:   vhdlan -work RTL_LIB  → rtl_pkg_shared/  (VHDL RTL)
  Step 1.5:   copy_precompiled_libs → rtl_pkg_shared/  (外购 IP)
  Step 2/3:   vlogan -work RTL_LIB  → rtl_pkg_shared/  (Verilog RTL)
  Step 2.5/3: vlogan -work RTL_LIB  → rtl_pkg_shared/  (SVA bind)
  Step 3/3:   vlogan -work TB_LIB   → tb_pkg/          (TB + testcase)
  VCS elab:   -Mdir=tb_pkg                            (elaboration)
```

### 签名检测机制

- 基于 filelist 内容 + `` `include `` 树 + 文件 mtime/size 计算 MD5 签名
- RTL 签名存储在 `rtl_pkg_shared/.m_lib_signature`
- TB 签名存储在 `tb_pkg/.m_lib_signature`
- 签名匹配时跳过编译，直接 elab

### 增量编译性能

| 场景 | 传统编译 | 增量编译 | 加速比 |
|------|----------|----------|--------|
| 首次编译 | 100% | 100% | 1.0x |
| 修改 TB 后重编译 | 100% | ~30% | 3.3x |
| 修改 RTL 后重编译 | 100% | 100% | 1.0x |
| 无修改重编译 | 100% | ~10% | 10x |
| 切换 testcase（RTL 不变） | 100% | ~30% | 3.3x |

### 输出说明

```
[INCR] RTL files unchanged          # RTL 未修改
[INCR] RTL files modified           # RTL 已修改
[INCR] TB files unchanged           # TB 未修改
[INCR] TB files modified            # TB 已修改
[INCR] No files modified            # 无修改，跳过编译
[INCR] Package not found            # 首次编译或包被删除
[INCR] RTL modified, clearing...    # RTL 修改，清除所有 TB
[INCR] Step 1/3: Compiling VHDL RTL...
[INCR] Step 2/3: Compiling Verilog RTL...
[INCR] Step 3/3: Compiling TB package...
```

### 时间统计

```
============================================================
Time Summary:
============================================================
  VHDL Compile : 0.04 seconds
  RTL Compile  : 1.04 seconds
  TB Compile   : 0.89 seconds
  Elaboration  : 3.62 seconds
  Simulation   : 0.25 seconds
  Total Time   : 15.22 seconds
============================================================
```

## VManager 回归流程

### 执行步骤

```bash
cd sim_1
source ../sourceme.csh
vmanager -server 192.168.21.172:8088 -batch -launch ../regression/presim/presim_session_batch.vsif &
```

### VSIF 配置示例

```
session presim_batch_test {
    top_dir:$ENV(SIM_DIR)/regression/result;
    drm     : PARALLEL_LOCAL;
    max_runs_in_parallel : 25;
}

group comp_group {
    scan_script:"vm_scan.pl $ENV(WORK_DIR)/../../common/script/vm_regr_script/lsf_fail.flt";
    run_script:"m run_pkg_vmcomp";
    count   : 1;
    post_run_script:"m vmcomplink";
    test basetest {}
}

group run_group {
    scan_script:"vm_scan.pl $ENV(WORK_DIR)/../../common/script/vm_regr_script/lsf_fail.flt";
    run_script:"m run_vmnocomp";
    depends_on : ../comp_group;
    count   : 10;
    post_run_script:"m vmsimclean";
    test basetest {}
}
```

### 回归流程详解

```
1. comp_group: m run_pkg_vmcomp
   → 编译到 $BRUN_RUN_DIR/comp_result/presim/comp_test_pkg/
   → 生成 simv_test_pkg* 和 simv_test_pkg*.daidir

2. post_group_script: m vmcomplink
   → PostGroupScript 遍历 $BRUN_RUN_DIR 查找 simv*
   → 链接 simv 和 daidir 到 $VMCOMP_PATH/comp_result/presim/comp_test_pkg/

3. run_group: m run_vmnocomp
   → 使用 $VMCOMP_PATH 下的 simv_test_pkg* 仿真
   → 输出 TEST Detail: m run_xx basetest 1234567890 define=FSDB_DUMP_OFF

4. post_run_script: m vmsimclean
   → PostRunScript 清理失败用例的 vdb
   → 保留 local_log.log
```

### 验证检查点

1. comp_group 编译成功，生成 `simv_test_pkg*` 和 `simv_test_pkg*.daidir`
2. vmcomplink 正确链接到 `$VMCOMP_PATH/comp_result/presim/comp_test_pkg/`
3. run_group 仿真成功，local_log.log 包含 `TEST Detail:m run_xx ...`
4. vmsimclean 清理成功，无 FileNotFoundError
5. 用例 PASS 时包含 `Whitebox verification PASSED` 和 `UVM_ERROR : 0`

## 过滤器配置

### lsf_fail.flt

VManager 日志过滤器文件（`vm_regr_script/lsf_fail.flt`），用于识别错误和提取信息：

| 过滤器 | 匹配内容 | 严重级别 |
|--------|----------|----------|
| `simv_not_found` | `simv_xxx: No such file or directory` | error |
| `user_error_filter0` | `^Error:(.*)` | error |
| `user_error_filter1` | `\[Error\](.*)` | error |
| `user_error_filter2` | `^Error-(.*)` | error |
| `uvm_critical` | `UVM_FATAL` | critical |
| `uvm_error` | `UVM_ERROR` | error |
| `uvm_warning_error` | `UVM_WARNING` | warning |
| `uvm_svcb_dut_critical` | `*** UVM: DUT fatal` | critical |
| `uvm_svcb_dut_error` | `*** UVM: DUT error` | error |
| `vcs_error` | `Error-[XXX]` | error |
| `vcs_internal_error` | `VCS runtime internal error` | error |
| `vcs_sv_fatal` | `Fatal: "file", line:` | critical |
| `SV-Seed` | `SVSEED.*?(-?\d+)` | 提取 seed |

### 三层错误扫描机制

| 层级 | 机制 | 时机 | 文件 |
|------|------|------|------|
| SV 层 | `scan_dut_error_log()` | report_phase | basetest.sv |
| Python 层 | LogScanner | 仿真退出后 | log_scanner.py |
| vmanager 层 | vm_scan.pl + lsf_fail.flt | 回归分析时 | lsf_fail.flt |

## 外购 IP 支持

### VHDL 源码编译（按路径前缀分组）

```yaml
# envcfg.yml
vendor_ip:
    vhdl_libs:
        linflex3_lib: $FLEXLIN_PATH/flexlin
        xcans_lib: $CANFD_PATH/canfd
        ae_notech_lib: $GTM_PATH
```

脚本按文件路径前缀自动将 VHDL 文件分组到对应库：
- 文件路径以 `$FLEXLIN_PATH/flexlin` 开头 → 编译到 `linflex3_lib`
- 文件路径以 `$CANFD_PATH/canfd` 开头 → 编译到 `xcans_lib`
- 不匹配任何前缀 → 编译到 `RTL_LIB`

### synopsys_sim.setup 自动生成

```
WORK > DEFAULT
DEFAULT: .../comp_result/presim/comp_basetest
RTL_LIB : .../comp_result/presim/rtl_pkg_shared
TB_LIB  : .../comp_result/presim/comp_basetest/tb_pkg
linflex3_lib : .../comp_result/presim/rtl_pkg_shared/linflex3_lib
xcans_lib    : .../comp_result/presim/rtl_pkg_shared/xcans_lib
ae_notech_lib: .../comp_result/presim/rtl_pkg_shared/ae_notech_lib
```

## 已知限制

1. **RTL 修改时必须重编译所有 TB**：无法做到文件级增量，因为 testcase 依赖 TB base 中的类
2. **TB/Testcase 分块编译不可行**：testcase 与 TB base 存在强依赖关系（继承、类型引用），vlogan 无法跨库引用类定义
3. **partcomp 仅适用于 presim**：postsim 的 gate_sim netlist 包含 Wire XMR 等 partcomp 不支持的特性
4. **缓存文件存储在本地**：不支持跨机器共享
5. **标记文件机制依赖文件系统**：NFS 环境下可能有延迟

## 常见问题

### simv 找不到

检查 `m vmcomplink` 是否正确执行，确认 `$VMCOMP_PATH/comp_result/presim/comp_test_pkg/simv_test_pkg*` 存在。

### dve.sdb 损坏

```bash
rm -rf comp_result/presim/AN.DB
```

### 增量编译未生效

1. 检查 `rtl_pkg_shared/.m_lib_signature` 是否存在
2. 检查 `tb_pkg/` 目录是否存在
3. 检查文件权限是否正确
4. 强制重编译：`M_FORCE_COMPILE=1 m incr_run basetest`

### RTL 修改后仿真结果未更新

1. 检查是否触发 `[INCR] RTL modified, clearing all TB packages`
2. 检查所有 `tb_pkg/` 是否被清除
3. 检查 RTL 和 TB 是否都重新编译

### Python 输出不显示（local_log.log 开头无内容）

设置无缓冲模式（不影响仿真速度）：
```bash
setenv PYTHONUNBUFFERED 1
```

### presim/postsim 编译产物冲突

rtl_pkg_shared 已按 sim_type 隔离：
- `comp_result/presim/rtl_pkg_shared/`
- `comp_result/postsim/rtl_pkg_shared/`

### synopsys_sim.setup 指向错误路径

确保 `sourceme.csh` 中**不要**设置 `SYNOPSYS_SIM_SETUP` 环境变量，由脚本自动生成。

## 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.31 | 2026-09-20 | 修复 presim/postsim 共享 rtl_pkg_shared 冲突 |
| v1.30 | 2026-09-20 | DUT $display("Error:") 转 uvm_error |
| v1.29 | 2026-09-20 | RTL filelist 宏定义自动传递到 TB 编译 |
| v1.28 | 2026-09-20 | VCS partcomp 加速（presim 5x），分块编译探索 |
| v1.27 | 2026-09-20 | 各阶段编译时间统计 |
| v1.24 | 2026-09-18 | 外购 IP VHDL 源码编译，按路径前缀分组 |
| v1.23 | 2026-09-18 | VHDL 编译使用绝对路径 |
| v1.21 | 2026-09-17 | 递归解析嵌套 filelist 中的 +incdir+ |
| v1.20 | 2026-09-17 | TB 编译自动提取 RTL filelist 的 +incdir+ |
| v1.19 | 2026-09-17 | SVA bind 编译到 RTL_LIB |
| v1.18 | 2026-09-17 | RTL 编译移除 -ntb_opts，添加 UVM_NO_RECORDING |
| v1.17 | 2026-09-17 | TB 编译移除 -ntb_opts，修复 UVM 1.2 依赖 |
| v1.16 | 2026-09-17 | 自动检测并注入 uvm_pkg.sv |
| v1.15 | 2026-09-17 | 并发 incr_run 资源冲突修复（文件锁） |
| v1.14 | 2026-09-17 | vmcomp 路径结构修复 |
| v1.13 | 2026-09-17 | vmnocomp simv 路径添加 sim_type_prefix |
| v1.12 | 2026-09-17 | xa_log 目录条件创建 |
| v1.11 | 2026-09-17 | coverage 逻辑优化，多用例/宏定义验证 |
| v1.10 | 2026-09-17 | synopsys_sim.setup 格式修复 |
| v1.9  | 2026-09-17 | 适配用户自定义 SYNOPSYS_SIM_SETUP |
| v1.8  | 2026-09-17 | 外购 IP 预编译库支持 |
| v1.7  | 2026-09-17 | VHDL 三步编译完善 |
| v1.6  | 2026-09-17 | 移除 +libpath+，改用 synopsys_sim.setup |
| v1.5  | 2026-09-17 | incr_run 适配通用 m 脚本架构 |
| v1.4  | 2026-09-16 | elaboration 找不到 top 模块修复 |
| v1.3  | 2026-09-16 | 编译缓存结构优化 |
| v1.2  | 2026-09-16 | 编译失败自动清理 |
| v1.1  | 2026-09-16 | 配置外部化（envcfg.yml） |
| v1.0  | 2026-09-16 | 初始版本 |

## 时间控制脚本

### time_control.py

用于在 VManager 回归中控制执行时间，支持两种模式：

#### 模式 1：等待到指定时间

```bash
# 等待到 2026-10-01 08:00
python3 time_control.py --until "2026-10-01 08:00"

# 等待到指定时间（带秒）
python3 time_control.py --until "2026-10-01 08:00:00"
```

#### 模式 2：延迟指定时长

```bash
# 延迟 30 秒
python3 time_control.py --delay 30s

# 延迟 5 分钟
python3 time_control.py --delay 5m

# 延迟 1 小时
python3 time_control.py --delay 1h

# 延迟 1 天
python3 time_control.py --delay 1d
```

#### VSIF 配置示例

```
group comp_group {
    pre_group_script: "python3 $ENV(WORK_DIR)/../../common/script/vm_regr_script/time_control.py --until '2026-10-01 08:00'";
    run_script: "m run_pkg_vmcomp";
    ...
}

group run_group {
    pre_group_script: "python3 $ENV(WORK_DIR)/../../common/script/vm_regr_script/time_control.py --delay 1h";
    run_script: "m run_vmnocomp";
    ...
}
```

#### 输出示例

```
[TimeControl] Waiting until: 2026-10-01 08:00:00
[TimeControl] Remaining: 2h 30m 15s
[TimeControl] Remaining: 2h 29m 15s
...
[TimeControl] Target time reached: 2026-10-01 08:00:00
[TimeControl] Done
```

## 维护者

zhouxk <zhouxk@chipsea.com>

## 相关文档

- `vmanager调试.txt` - VManager 过滤器、回归路径、pkg 模式调试记录
- `k78x 脚本调试记录.txt` - 增量编译、混合语言、外购 IP 开发记录
