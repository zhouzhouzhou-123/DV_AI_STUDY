# DV_AI_STUDY

数字验证（Digital Verification）AI 辅助学习与工具优化仓库。

## 项目结构

```
DV_AI_STUDY/
├── README.md
└── timing_vio_warning_parser/     # 时序违例与告警解析工具
    ├── timing_warning_parser.py   # 优化后脚本 (v2.0)
    ├── timing_warning_parser.py.bak  # 原始版本备份 (v1.0)
    ├── warning_timing_vio_filter.json
    ├── README.md
    ├── HELP.md                    # 详细帮助文档
    ├── CHANGELOG.md               # 版本变更记录
    ├── CHECKPOINT.md              # 优化检查点记录
    └── test/
        ├── local_log.log          # 测试日志样本
        ├── test_filter.json       # 测试过滤配置
        └── run_tests.sh           # 自动化测试 (8 cases)
```

## 快速开始

```bash
# 运行自动化测试
cd timing_vio_warning_parser/test
./run_tests.sh

# 使用优化版脚本
python3 timing_vio_warning_parser/timing_warning_parser.py \
    -s -f timing_vio_warning_parser/test/test_filter.json \
    -o ./output \
    timing_vio_warning_parser/test/
```

## 工具说明

`timing_warning_parser.py` 用于解析数字仿真/编译日志中的 Timing Violation 和 Warning 信息，支持 JSON 配置驱动的多维度过滤规则。

详细文档见 `timing_vio_warning_parser/HELP.md`。

## 版本

- **v2.0.0** (2026-10-12) — 优化版本，修复 P0/P1 bug，增强健壮性
- **v1.0.0** — 原始版本（备份为 `.bak`）

## License

Internal use only — ChipSEA Digital Verification Department.
