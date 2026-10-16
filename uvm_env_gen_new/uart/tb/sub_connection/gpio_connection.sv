// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: gpio_connection.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef GPIO_CONNECTION__SV
`define GPIO_CONNECTION__SV

reg     [PA_NUM - 1 : 0]    pa_out;
reg     [PB_NUM - 1 : 0]    pb_out;
reg     [PC_NUM - 1 : 0]    pc_out;
reg     [PD_NUM - 1 : 0]    pd_out;

reg     [PA_NUM - 1 : 0]    pa_out_en;
reg     [PB_NUM - 1 : 0]    pb_out_en;
reg     [PC_NUM - 1 : 0]    pc_out_en;
reg     [PD_NUM - 1 : 0]    pd_out_en;


pullup(PA[0]);
pullup(PA[1]);
pullup(PA[2]);
pullup(PA[3]);

pullup(PB[0]);
pullup(PB[1]);
pullup(PB[2]);
pullup(PB[3]);
pullup(PB[4]);
pullup(PB[5]);
pullup(PB[6]);
pullup(PB[7]);

pullup(PC[0]);

pullup(PD[0]);

// use assign to complete the value action
genvar i;
generate begin
    for(i=0; i<PA_NUM; i++)
    begin
        assign PA[i] = pa_out_en[i] ? pa_out[i] : 1'bz;
    end
end
endgenerate

generate begin
    for(i=0; i<PB_NUM; i++)
    begin
        assign PB[i] = pb_out_en[i] ? pb_out[i] : 1'bz;
    end
end
endgenerate

generate begin
    for(i=0; i<PC_NUM; i++)
    begin
        assign PC[i] = pc_out_en[i] ? pc_out[i] : 1'bz;
    end
end
endgenerate

generate begin
    for(i=0; i<PD_NUM; i++)
    begin
        assign PD[i] = pd_out_en[i] ? pd_out[i] : 1'bz;
    end
end
endgenerate

`endif
