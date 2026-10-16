// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: memory_map.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef MEMORY_MAP__SV
`define MEMORY_MAP__SV

`define LDROM_SADDR         'h0000_0000
`define LDROM_EADDR         'h0000_FFFF

`define APROM_SADDR         'h0008_0000
`define APROM_EADDR         'h000E_FFFF

`define SRAM1_SADDR         'h2000_0000
`define SRAM1_EADDR         'h2000_FFFF

`define SRAM2_SADDR         'h2001_0000
`define SRAM2_EADDR         'h2001_FFFF

`define SRAM3_SADDR         'h2002_0000
`define SRAM3_EADDR         'h2002_FFFF

`endif // MEMORY_MAP__SV
