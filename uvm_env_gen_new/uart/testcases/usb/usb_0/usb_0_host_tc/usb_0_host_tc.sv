// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_host_tc.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_HOST_TC__SV
`define USB_0_HOST_TC__SV

// `define USB_TOP          `USB_0_TOP
// `define USB_COUNT        `USB_0_COUNT
// `define USB_COUNT_CLK    `USB_0_COUNT_CLK

class usb_0_host_tc extends usb_basetest;

    svt_usb_transfer_control_in_data_stage_sequence cntrl_xfer_seq;

    `uvm_component_utils(usb_0_host_tc)

    extern function new(string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);

    extern task configure_phase(uvm_phase phase);
    extern task tc_proc();
endclass : usb_0_host_tc

function usb_0_host_tc::new(string name, uvm_component parent);
    super.new(name, parent);
    this.freq_random_enable = 0;
endfunction : new

function void usb_0_host_tc::build_phase(uvm_phase phase);
    super.build_phase(phase);

    this.cntrl_xfer_seq = new();
    uvm_config_db#(uvm_sequence_base)::set(this,
        "mo_env.mo_usb_env[0].mo_dev_agent.xfer_sequencer.main_phase","default_sequence", cntrl_xfer_seq);
endfunction : build_phase

task usb_0_host_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    this.load_hex_file("../ccode/hex/usb_0_host_tc.hex");
    phase.drop_objection(this);
endtask : configure_phase

task usb_0_host_tc::tc_proc();

`ifdef POST_SIM_ON
    // ---------- deposit count for speedup --------------- //
    `uvm_info("","wait USB COUNT != 'h2_bf20...",UVM_LOW)
    while(1)
    begin
        @(negedge `USB_COUNT_CLK);
        if(`USB_COUNT == 'h2_bf20)
        begin
            `uvm_info("","USB COUNT == 'h2_bf20", UVM_LOW)
            break;
        end
    end
    while(1)
    begin
        @(negedge `USB_COUNT_CLK);
        if(`USB_COUNT != 'h2_bf20)
        begin
            `uvm_info("","USB COUNT != 'h2_bf20", UVM_LOW)
            break;
        end
    end

    repeat(5) @(negedge `USB_COUNT_CLK);

    `uvm_info("","force USB COUNT to 'hf ...",UVM_LOW)
    force `USB_COUNT = 'hf;
    @(negedge `USB_COUNT_CLK);
    `uvm_info("","release USB COUNT ...",UVM_LOW)
    release `USB_COUNT;

    // ---------- deposit count for speedup --------------- //
    `uvm_info("","wait USB COUNT != 'h6d_dd00...",UVM_LOW)
    while(1)
    begin
        @(negedge `USB_COUNT_CLK);
        if(`USB_COUNT == 'h6d_dd00)
        begin
            `uvm_info("","USB COUNT == 'h6f_dd00", UVM_LOW)
            break;
        end
    end
    while(1)
    begin
        @(negedge `USB_COUNT_CLK);
        if(`USB_COUNT != 'h6d_dd00)
        begin
            `uvm_info("","USB COUNT != 'h6f_dd00", UVM_LOW)
            break;
        end
    end

    repeat(5) @(negedge `USB_COUNT_CLK);

    `uvm_info("","force USB COUNT to 'hf ...",UVM_LOW)
    force `USB_COUNT = 'hf;
    @(negedge `USB_COUNT_CLK);
    `uvm_info("","release USB COUNT ...",UVM_LOW)
    release `USB_COUNT;
`endif

    sv_wait_label(100);
    repeat(10)
    begin
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF4.d2hd_px_oe, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF4.d2hd_px_ie, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF4.d2hd_px_pd, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF4.d2hd_px_pu, 0)

        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF5.d2hd_px_oe, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF5.d2hd_px_ie, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF5.d2hd_px_pd, 0)
        `SIGNAL_VALUE_CHECKING(`IO_RING.u_GPF5.d2hd_px_pu, 0)
        #1us;
    end
    sv_send_label(101);

    sv_wait_label(102);

endtask : tc_proc

`endif // USB_0_HOST_TC__SV

