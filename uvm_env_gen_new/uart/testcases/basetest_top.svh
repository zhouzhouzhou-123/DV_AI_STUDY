//------------------------------------------------------------------------
// FILE NAME      : basetest_top.svh
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-07-15 10:40:02
// ABSTACT        :
//
//-------------------------------------------------------------------------
`include "../testcases/basetest.sv"
// `include "../testcases/iomux/iomux_basetest.sv"

// `ifdef ESPI_TEST
//     `include "../testcases/host_sys/espi/sdvt_espi_base_test.sv"
// `endif
`ifdef I2C_TEST_ON
    `include "../testcases/i2c/i2c_basetest.sv"
`endif // I2C_TEST_ON
`ifdef USB_TEST_ON
    `include "../testcases/usb/usb_basetest.sv"
`endif // USB_TEST_ON
