// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: common_define.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef COMMON_DEFINE__SV
`define COMMON_DEFINE__SV

import uvm_pkg::*;
// ------------ USB VIP -------------- //
`ifdef USB_TEST_ON
    `define UVM_PACKER_MAX_BYTES=24000
    `define SVT_USB_USER_DEFINES
    `define UVM_DISABLE_AUTO_ITEM_RECORDING

    `include "svt_usb.uvm.pkg"
    `include "svt_usb_defines.svi"
    `include "svt_usb_if.uvm.svi"

    import svt_uvm_pkg::*;
    import svt_usb_uvm_pkg::*;
    parameter USB_MASTER_COUNT = 2;
`endif

// i2c VIP
`ifdef I2C_TEST_ON
    `include "svt_i2c.uvm.pkg"
    `include "svt_i2c_if.svi"
    import svt_uvm_pkg::*;
    import svt_i2c_uvm_pkg::*;
    import svt_i2c_enum_pkg::*;
`endif // I2C_TEST_ON

`endif // COMMON_DEFINE__SV
