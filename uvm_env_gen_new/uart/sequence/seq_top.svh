// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: seq_top.svh
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------

`include "../sequence/base_vir_seq.sv"
`include "../sequence/reg_seq.sv"
`include "../sequence/vir_seq.sv"
`ifdef I2C_TEST_ON
    `include "../sequence/i2c_sequence/i2c_sequence_top.sv"
`endif // I2C_TEST_ON

`ifdef USB_TEST_ON
    `include "../sequence/usb_seq/seq_top.svh"
`endif
