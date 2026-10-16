// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: hello_world.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-12-04
// ----------------------------------------------------

`ifndef HELLO_WORLD__SV
`define HELLO_WORLD__SV

class hello_world extends basetest;

    `uvm_component_utils(hello_world)

    extern function new(string name = "hello_world", uvm_component parent);
    extern task configure_phase(uvm_phase phase);

    extern task tc_proc();

endclass: hello_world

//Constructor
function hello_world::new(string name = "hello_world", uvm_component parent);
    super.new(name, parent);
endfunction : new

//Config
task hello_world::configure_phase(uvm_phase phase);
    phase.raise_objection(this);

    this.load_hex_file("../ccode/hex/hello_world.hex");
    this.load_hex_file("../ccode/hex/hello_world-BOOT=LDROM.hex");

    phase.drop_objection(this);
endtask : configure_phase

task hello_world::tc_proc();
    int data;

    $display("hello_world  start  ");

    sv_wait_label(100);

    sv_wait_label(101);
    data = sv_get_data(0);
    $display("data = 'h%0h", data);
    data = sv_get_data(18);
    $display("data = 'h%0h", data);

    sv_send_data(1, 'h234);
    sv_send_data(19, 'h334);
    sv_send_label(102);

    $display("hello_world  end  ");
endtask : tc_proc

`endif // HELLO_WORLD__SV


