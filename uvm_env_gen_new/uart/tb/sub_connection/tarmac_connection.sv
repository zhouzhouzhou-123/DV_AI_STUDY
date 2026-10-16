//------------------------------------------------------------------------
// FILE NAME      : tarmac_connection.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-15 15:20:25
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef TARMAC_CONNECTION__SV
`define TARMAC_CONNECTION__SV

`ifdef TARMAC
    `define CM0_INST    `DIG1P5.u_cm0ik_cortexm0_timing.u_imp.u_cortexm0

    `include "../vip/tarmac/cm0_tarmac_top.v"

`endif // TARMAC_ON

`endif // TARMAC_CONNECTION__SV
