// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: xa_basetask.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef XA_BASETASK__SV
`define XA_BASETASK__SV

// task vbus_step_power_up(real power_up_voltage, realtime power_up_time, int step_num);
//     `uvm_info("", $sformatf("[%m] vbus power up start!"), UVM_LOW);
//     for(int i = 1; i <= step_num; i++) begin
//         #(power_up_time / step_num);
//         $snps_force_volt(top.u_chip_top.vbus, (power_up_voltage * i) / step_num);
//     end
//     `uvm_info("", $sformatf("[%m] vbus power up done!"), UVM_LOW);
// endtask

// task vbus_release();
//     $snps_release_volt(top.u_chip_top.vbus);
//     `uvm_info("", $sformatf("[%m] vbus release done!"), UVM_LOW);
// endtask

`endif // XA_BASETASK__SV
