// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: power_control.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef POWER_CONTROL__SV
`define POWER_CONTROL__SV

// --------------------- power control ----------------- //
event   power_on_event;
event   power_off_event;

initial
begin
    VDD     = 0.0;
    GND     = 0.0;
    #2us;
    ->power_on_event;
end
initial
begin
    fork
        while(1)
        begin
            @power_on_event;
            VDD     = 5.0;
            `uvm_info("","POWER on ....",UVM_LOW)
        end
        while(1)
        begin
            @power_off_event;
            VDD     = 0.0;
            `uvm_info("","POWER off ....",UVM_LOW)
        end
    join
end

`endif // POWER_CONTROL__SV
