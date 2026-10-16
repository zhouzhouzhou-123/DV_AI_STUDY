// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: tb_filelist.f
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------
// VIP Files
// usb_vip
+incdir+$COMMON_VIP_PATH/vip/external/synopsys/usb/src/sverilog/vcs
+incdir+$COMMON_VIP_PATH/vip/external/synopsys/usb/include/sverilog
+incdir+$COMMON_VIP_PATH/vip/external/synopsys/usb/src/verilog/vcs
+incdir+$COMMON_VIP_PATH/vip/external/synopsys/usb/include/verilog
+incdir+../env/usb_env
#ifdef I2C_TEST_ON
    +incdir+$COMMON_VIP_PATH/vip/external/synopsys/i2c_svt/include/sverilog
    +incdir+$COMMON_VIP_PATH/vip/external/synopsys/i2c_svt/src/sverilog/vcs
    +incdir+$COMMON_VIP_PATH/vip/external/synopsys/i2c_svt/include/verilog
    +incdir+$COMMON_VIP_PATH/vip/external/synopsys/i2c_svt/src/verilog/vcs
    +incdir+../sequence/i2c_sequence
#endif // I2C_TEST_ON
// --tarmac -- //
+incdir+../vip/tarmac
../vip/tarmac/cm0_tarmac.v



+incdir+../cfg

+incdir+../env
+incdir+../env/callback
+incdir+../env/trans

+incdir+../common

../common/common_define_top.sv

// vip
../vip/vip_top.svh

../tb/top.sv

// cfg

// callback
../env/callback/callback_top.svh

// trans
../env/trans/trans_top.svh

// RAL
../ral/ral_regmodel.sv

// coverage
../coverage/cov_top.svh

// assertion
../sva/sva_top.svh

// agent
../env/usb_env/usb_env_top.sv
../env/agent/agent_top.svh

// refm
../env/refm/refm_top.svh

// scb
../env/scb/scb_top.svh

// vir seqr
../env/vir_seqr.sv

// vir seq && seq
../sequence/seq_top.svh

../cfg/env_cfg.sv

../env/env.sv

// base test
../testcases/basetest_top.svh
