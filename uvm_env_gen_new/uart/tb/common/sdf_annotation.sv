// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: sdf_annotation.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef SDF_ANNOTATION__SV
`define SDF_ANNOTATION__SV

initial
begin
    `ifdef SS_CORNER
        // $sdf_annotate(
        //     "../../../../../../branches/backend/handoff/To_DFV/func.wc_rcw.sdf",
        //     top.u_chip_top.u_dig_top,
        //     ,
        //     "sdf_ss.log",
        //     "MAXIMUM"
        //);
    `endif
    `ifdef FF_CORNER
        // $sdf_annotate(
        //     "../../../../../../branches/backend/handoff/To_DFV/func.bc_rcb.sdf",
        //     top.u_chip_top.u_dig_top,
        //     ,
        //     "sdf_ff.log",
        //     "MINIMUM"
        //);
    `endif
    `ifdef TT_CORNER
        // $sdf_annotate(
        //     "../../../../../../branches/backend/handoff/To_DFV/func.tt.sdf",
        //     top.u_chip_top.u_dig_top,
        //     ,
        //     "sdf_tt.log",
        //     "TYPICAL"
        //);
    `endif
end

`endif // SDF_ANNOTATION__SV
