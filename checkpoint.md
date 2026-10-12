# M Script Checkpoint

## 脚本概述
- **版本**: v1.0
- **位置**: `/home/zhouxk/work/cs32kx776/trunk/digital/Veri/common/script/m/v1.0/m`
- **用途**: IC 验证仿真自动化脚本
- **依赖**: Python 3.6+, VCS, Verdi, vManager

---

## 功能检查点

### 1. 编译流程
- [x] VHDL 编译 (vhdlan)
- [x] Verilog/SystemVerilog 编译 (vlogan)
- [x] VCS 链接 (vcs)
- [x] 增量编译支持 (is_incr_run)
- [x] Split-library 编译 (RTL/TB 分离)
- [x] 签名检查机制 (避免重复编译)

### 2. 仿真流程
- [x] 前仿真 (presim)
- [x] 后仿真 (postsim) - DC/PR/SS/FF/TT corner
- [x] XA 混合仿真 (co-simulation)
- [x] 随机种子控制
- [x] Plusargs 传递
- [x] SIM_LOG_FILE 自动传递
- [x] Timing violation 检查

### 3. 波形与调试
- [x] FSDB 波形dump (默认开启)
- [x] VCD 波形dump (可选)
- [x] Verdi 波形查看
- [x] KDB 调试支持
- [x] 多种 Verdi 打开模式

### 4. 覆盖率
- [x] 覆盖率收集 (line+cond+fsm+branch+tgl+assert)
- [x] VDB 合并 (urg)
- [x] 覆盖率分析
- [x] Verdi 覆盖率查看

### 5. 回归测试
- [x] vManager 集成
- [x] VSIF 生成
- [x] Test package 生成
- [x] 回归结果清理
- [x] 错误日志扫描

### 6. 环境配置
- [x] YAML 配置文件解析 (m.yml, envcfg.yml)
- [x] 环境变量自动设置
- [x] Filelist 解析与展开
- [x] Include 目录处理

---

## 代码质量检查点

### 优点
- [x] 模块化设计 (CSRun, CmdArgs, EnvCfg)
- [x] 支持多种仿真场景
- [x] 增量编译优化
- [x] 签名机制避免重复编译
- [x] 时间统计功能
- [x] 错误日志自动扫描

### 待改进项
- [ ] 缺少单元测试
- [ ] 部分函数过长 (>100行)
- [ ] 硬编码路径较多
- [ ] 异常处理不完善
- [ ] 日志系统不统一
- [ ] 缺少类型注解
- [ ] 部分变量命名不规范

---

## 使用检查点

### 环境变量
- [ ] WORK_DIR - 工作目录
- [ ] COMMON_VIP_PATH - VIP 库路径
- [ ] VCS_HOME - VCS 安装路径
- [ ] UVM_HOME - UVM 库路径
- [ ] VMANAGER_PATH - vManager 路径

### 配置文件
- [ ] `setup/m.yml` - 主配置
- [ ] `setup/envcfg.yml` - 环境配置
- [ ] `setup/set_env.csh` - 环境设置
- [ ] `filelist/*.f` - 文件列表

### 目录结构
```
project/
├── rtl/              # RTL 源码
├── testcases/        # 测试用例
├── env/              # 环境代码
├── sequence/         # 序列
├── filelist/         # 文件列表
├── setup/            # 配置文件
├── scripts/          # 脚本
├── sim_1/            # 仿真目录
│   ├── comp_result/  # 编译结果
│   ├── result/       # 仿真结果
│   └── wave_log/     # 波形日志
└── regression/       # 回归测试
```

---

## 常见问题检查

### 编译失败
- [ ] 检查 filelist 路径是否正确
- [ ] 检查环境变量是否设置
- [ ] 检查 license 服务器连接
- [ ] 检查 RTL 语法错误

### 仿真失败
- [ ] 检查 simv 文件是否存在
- [ ] 检查 testcase 路径
- [ ] 检查 plusargs 格式
- [ ] 检查 seed 值范围

### 覆盖率问题
- [ ] 检查 vdb 文件是否生成
- [ ] 检查 urg 命令是否可用
- [ ] 检查 cm_hier.cfg 配置

---

## 性能优化检查点

### 编译优化
- [x] 增量编译 (is_incr_run)
- [x] Split-library 并行编译
- [x] 签名机制跳过未修改文件
- [ ] 预编译库支持 (vendor IP)

### 仿真优化
- [x] nocomp 模式跳过编译
- [x] 覆盖率按需开启
- [ ] 分布式仿真支持

---

## 版本历史
- v1.0: 初始版本
- v1.1: 添加 coverage 和 testname 功能
- v1.2: 添加 post_group_script, vmcomplink, vmsimclean, vdbmerge
- v1.3: 添加 plusargs 支持

---

## 维护检查点

### 代码维护
- [ ] 定期代码审查
- [ ] 添加类型注解
- [ ] 重构长函数
- [ ] 统一日志格式
- [ ] 添加文档字符串

### 功能扩展
- [ ] 支持 Xcelium
- [ ] 支持 Questa
- [ ] 添加 Web UI
- [ ] 添加邮件通知
- [ ] 添加性能分析

---

**最后更新**: 2026-10-12
**维护者**: zhouxk@chipsea.com
