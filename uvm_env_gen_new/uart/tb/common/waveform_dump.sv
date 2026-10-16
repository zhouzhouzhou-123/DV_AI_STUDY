// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: waveform_dump.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef WAVE_DUMP__SV
`define WAVE_DUMP__SV

task fsdb_dump();
    // fsdb dump
    string fsdb_file;
    if($value$plusargs("fsdb_file=%s",fsdb_file))
    begin
        // $fsdbDumpfile(fsdb_file);
        $fsdbAutoSwitchDumpfile(36000,fsdb_file,64);
    end else begin
        // $fsdbDumpfile("default.fsdb");
        $fsdbAutoSwitchDumpfile(36000,"default.fsdb",64);
    end
    //$fsdbDumpvars(0,top.QSPI,"+mda");

    $fsdbDumpvars(0,top,"+mda");
    `ifdef PA_SIM
        $fsdbDumpvars("+power");
    `endif
    $fsdbDumpSVA;

    $fsdbDumpon;

    fork
        `ifdef MIX_SIM
            forever
            begin
                #0.1ms;
                $fsdbDumpflush();
            end
        `endif
    join_none
endtask : fsdb_dump

reg vcd_dump_start = 0;
reg vcd_dump_finish = 0;
task vcd_dump();
    string vcd_file;

    `uvm_info("","waiting VCD dump started...", UVM_LOW)
    wait(vcd_dump_start == 1);
    `uvm_info("","VCD dump is started...", UVM_LOW)

    if($value$plusargs("vcd_file=%s",vcd_file)) begin
        $dumpfile(vcd_file);
    end else begin
        $dumpfile("default.vcd");
    end
    // $dumpvars(0,    top.u_chip_top.u_ec_wrapper.u_ahb1_ss.u_ahb1_decoder);
    // $dumpvars(0,    top.u_chip_top.u_ec_wrapper.u_ahb1_ss.u_ahb1_top.u_apb1_wrapper.u_apb1_bridge);

    $dumpon;
    wait(vcd_dump_finish == 1);
    $dumpoff;
    `uvm_info("","VCD dump is finished...", UVM_LOW)
endtask : vcd_dump

initial
begin
    `ifndef FSDB_DUMP_OFF
        `ifdef VCD_DUMP_ON
            vcd_dump();
        `else
            fsdb_dump();
        `endif
    `endif
end

`endif // WAVE_DUMP__SV
