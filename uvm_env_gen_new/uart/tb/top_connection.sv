// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: top_connection.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef TOP_CONNECTION__SV
`define TOP_CONNECTION__SV

parameter   PA_NUM  = 16;
parameter   PB_NUM  = 16;
parameter   PC_NUM  = 16;
parameter   PD_NUM  = 16;

real    VDD, VPP, GND;
reg     TESTEN;
wire    [PA_NUM - 1 : 0]    PA;
wire    [PB_NUM - 1 : 0]    PB;
wire    [PC_NUM - 1 : 0]    PC;
wire    [PD_NUM - 1 : 0]    PD;

wire            uart_rx;
wire            uart_tx;
wire    [3:0]   gpio_in;
wire    [3:0]   gpio_out;
wire    [3:0]   data_in;
wire    [3:0]   data_out;
wire    [3:0]   led;

CHIP_TOP u_chip_top(
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

assign uart_rx  = 1'b1;
assign gpio_in  = 4'b0;
assign data_in  = 4'b0;

// include sub-connection
// --- USB0 connection --- //
`include "../tb/sub_connection/usb_0_connection.sv"
// --- USB1 connection --- //
`include "../tb/sub_connection/usb_1_connection.sv"
// --- I2C0 connection --- //
`include "../tb/sub_connection/i2c_0_connection.sv"
// --- I2C1 connection --- //
`include "../tb/sub_connection/i2c_1_connection.sv"
// --- I2C2 connection --- //
`include "../tb/sub_connection/i2c_2_connection.sv"
// --- I2C3 connection --- //
`include "../tb/sub_connection/i2c_3_connection.sv"
// --- I2C4 connection --- //
`include "../tb/sub_connection/i2c_4_connection.sv"
// tarmac connection
`include "../tb/sub_connection/tarmac_connection.sv"
// `include "../tb/sub_connection/power_control.sv"
// `include "../tb/sub_connection/gpio_connection.sv"


// --------------------- TESTEN (default : 0) ----------------- //
initial
begin
    TESTEN  = 0;
    `uvm_info("TOP_CONNECTION__SV", " add modify in top connect ", UVM_LOW)
end

`endif // TOP_CONNECTION__SV
