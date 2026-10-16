// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: dut.v
// Description: Simple DUT with 20 I/O signals
// ----------------------------------------------------

module dut (
    input           clk         ,
    input           rst_n       ,
    input           uart_rx     ,
    input   [3:0]   gpio_in     ,
    input   [3:0]   data_in     ,
    output          uart_tx     ,
    output  [3:0]   gpio_out    ,
    output  [3:0]   data_out    ,
    output  [3:0]   led
);

assign uart_tx   = uart_rx;
assign gpio_out  = gpio_in;
assign data_out  = data_in;

reg [3:0] cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 4'b0;
    else
        cnt <= cnt + 1'b1; // RTL modified for test
end
assign led = cnt;

endmodule
