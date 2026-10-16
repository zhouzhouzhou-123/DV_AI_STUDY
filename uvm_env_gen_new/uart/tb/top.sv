// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: top.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef TOP__SV
`define TOP__SV

`ifdef MIX_SIM
    `include "../tb/xa/CHIP_TOP_XA.sv"
`else
    `include "../tb/CHIP_TOP.sv"
`endif

module top();

    // Define Interface
    reg     clk;
    reg     rst_n;

    initial
    begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    initial
    begin
        rst_n = 0;
        #100ns;
        rst_n = 1;
    end

    initial
    begin
        // Set Interface



    end

    initial
    begin
        int ms_count = 0;
        $timeformat(-12, 0, "ps", 14);
        forever
        begin
            #1ms;
            ms_count++;
            $display("***********run times is %0d ms *********** ",ms_count);
        end
    end

    initial
    begin
        run_test();
    end

    `include "../tb/top_connection.sv"
    // ------------ load SDF ------------- //
    `ifdef POST_SIM_ON
        `include "../tb/common/sdf_annotation.sv"
    `endif
    // ------------ co-sim ------------- //
    `ifdef MIX_SIM
        `include "../tb/xa/xa_basetask.sv"
    `endif
    `include "../tb/common/waveform_dump.sv"

endmodule : top

`endif // TOP__SV
