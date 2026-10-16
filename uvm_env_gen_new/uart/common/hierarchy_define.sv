// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: hierarchy_define.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef HIERARCHY_DEFINE__SV
`define HIERARCHY_DEFINE__SV

`ifdef MIX_SIM
    // ANA_TOP mode, CHIP_TOP must match spice file: input.sp
    // `define ANA_TOP         top.u_ana
    // `define CHIP_TOP         top.u_ana.xi0.xdig_top
`else
    `define CHIP_TOP            top.u_chip_top
    // `define CHIP_RESETN         `CHIP_TOP.RST_N
`endif

// `define EMC_TOP             `CHIP_TOP.u_emc_dig_top
// `define IOMUX_TOP           `CHIP_TOP.u_iomux_top

// used for trans message between CCODE and sv
// `define TARGET_SRAM_TOP             `SRAM1_TOP
//
// `define TARGET_SRAM                 `TARGET_SRAM_TOP.mem
// `define TARGET_SRAM_CLK             `TARGET_SRAM_TOP.CLK
//
// `define BASE_MEM_INDEX_OF_PRINT     $size(`TARGET_SRAM) - 57
// `define INDEX_OF_END_SIM            `BASE_MEM_INDEX_OF_PRINT + 0
// `define INDEX_OF_OK_OR_ERROR        `BASE_MEM_INDEX_OF_PRINT + 1
// `define INDEX_OF_WAIT_LABEL         `BASE_MEM_INDEX_OF_PRINT + 2
// `define INDEX_OF_SEND_LABEL         `BASE_MEM_INDEX_OF_PRINT + 2
// `define INDEX_OF_INFO               `BASE_MEM_INDEX_OF_PRINT + 3
// `define INDEX_OF_FIRST_DATA         `BASE_MEM_INDEX_OF_PRINT + 4
// `define INDEX_OF_STRING_HEAD        `BASE_MEM_INDEX_OF_PRINT + 24
// `define INDEX_OF_STRING_INFO        `BASE_MEM_INDEX_OF_PRINT + 25



`endif // HIERARCHY_DEFINE__SV
