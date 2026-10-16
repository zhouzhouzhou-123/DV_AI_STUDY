// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: CHIP_TOP.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef CHIP_TOP__SV
`define CHIP_TOP__SV

module CHIP_TOP (
        input                   clk         ,
        input                   rst_n       ,
        input                   uart_rx     ,
        input   [3:0]           gpio_in     ,
        input   [3:0]           data_in     ,
        output                  uart_tx     ,
        output  [3:0]           gpio_out    ,
        output  [3:0]           data_out    ,
        output  [3:0]           led
    );

dut u_dut (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .uart_rx    (uart_rx    ),
    .gpio_in    (gpio_in    ),
    .data_in    (data_in    ),
    .uart_tx    (uart_tx    ),
    .gpio_out   (gpio_out   ),
    .data_out   (data_out   ),
    .led        (led        )
);

endmodule

`endif // CHIP_TOP__SV
