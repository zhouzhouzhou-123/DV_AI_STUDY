// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_fifo_tc.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_FIFO_TC__SV
`define USB_0_FIFO_TC__SV

// `define USB_TOP          `USB_0_TOP
// `define USB_COUNT        `USB_0_COUNT
// `define USB_COUNT_CLK    `USB_0_COUNT_CLK

class usb_0_fifo_tc extends usb_basetest;

    svt_usb_transfer_control_in_data_stage_sequence cntrl_xfer_seq;

    `uvm_component_utils(usb_0_fifo_tc)

    extern function new(string name, uvm_component parent);

    extern virtual function void build_phase(uvm_phase phase);

    extern task configure_phase(uvm_phase phase);

    extern task tc_proc();
endclass : usb_0_fifo_tc

function usb_0_fifo_tc::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void usb_0_fifo_tc::build_phase(uvm_phase phase);
    super.build_phase(phase);
    cntrl_xfer_seq = new();
    uvm_config_db#(uvm_sequence_base)::set(this,"mo_env.mo_usb_env[0].mo_dev_agent.xfer_sequencer.main_phase","default_sequence", cntrl_xfer_seq);
endfunction

task usb_0_fifo_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    this.load_hex_file("../ccode/hex/usb_0_fifo_tc.hex");
    phase.drop_objection(this);
endtask

task usb_0_fifo_tc::tc_proc();
    int data_count;
    int endpoint_count = 4;

`ifndef POST_SIM_ON
    data_count = 128;
`else
    data_count = 2;
`endif

    sv_wait_label(100);

    sv_send_data(0, data_count);
    sv_send_data(1, endpoint_count);
    sv_send_label(101);

    sv_wait_label(102);
endtask : tc_proc

`endif // USB_0_FIFO_TC__SV

