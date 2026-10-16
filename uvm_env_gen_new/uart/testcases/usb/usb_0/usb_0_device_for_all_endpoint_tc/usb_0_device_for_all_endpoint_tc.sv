// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_device_for_all_endpoint_tc.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_DEVICE_FOR_ALL_ENDPOINT_TC__SV
`define USB_0_DEVICE_FOR_ALL_ENDPOINT_TC__SV

// `define USB_TOP          `USB_0_TOP
// `define USB_COUNT        `USB_0_COUNT
// `define USB_COUNT_CLK    `USB_0_COUNT_CLK

class usb_0_device_for_all_endpoint_tc extends usb_basetest;
    int endpoint_index;

    control_in_sequence     control_in_seq;
    control_out_sequence    control_out_seq;
    bulk_in_sequence        bulk_in_seq;
    bulk_out_sequence       bulk_out_seq;

    `uvm_component_utils(usb_0_device_for_all_endpoint_tc)

    extern function new(string name, uvm_component parent);

    extern task configure_phase(uvm_phase phase);
    extern task tc_proc();

    extern task control_in_check    ();
    extern task control_out_check   ();
    extern task bulk_in_check       ();
    extern task bulk_out_check      ();
endclass : usb_0_device_for_all_endpoint_tc

function usb_0_device_for_all_endpoint_tc::new(string name, uvm_component parent);
    super.new(name, parent);
    this.freq_random_enable = 0;
endfunction

task usb_0_device_for_all_endpoint_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    this.load_hex_file("../ccode/hex/usb_0_device_for_all_endpoint_tc.hex");
    phase.drop_objection(this);
endtask

task usb_0_device_for_all_endpoint_tc::tc_proc();
    sv_wait_label(100);
    randcase
        1   :   this.endpoint_index = 1;
        1   :   this.endpoint_index = 2;
        1   :   this.endpoint_index = 3;
        1   :   this.endpoint_index = 4;
    endcase
    sv_send_data(0, this.endpoint_index);
    `uvm_info("",$sformatf("endpoint %0d is selected...",this.endpoint_index), UVM_LOW)
    sv_send_label(101);

`ifdef POST_SIM_ON
    // ---------- deposit count for speedup --------------- //
    `uvm_info("","wait USB COUNT != 'h2_bf20...",UVM_LOW)
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

    `uvm_info("","force USB COUNT to 'h12c ...",UVM_LOW)
    force `USB_COUNT = 'h12c;
    @(negedge `USB_COUNT_CLK);
    `uvm_info("","release USB COUNT ...",UVM_LOW)
    release `USB_COUNT;
`endif

    this.control_in_check();
    this.control_out_check();
    this.bulk_in_check();
    this.bulk_out_check();

endtask : tc_proc

task usb_0_device_for_all_endpoint_tc::control_in_check();
    `uvm_info("","control_in_seq",UVM_LOW);

    sv_wait_label(200);
    this.control_in_seq = new();
    control_in_seq.start(mo_env.mo_usb_env[0].mo_host_agent.xfer_sequencer);
    sv_wait_label(201);
endtask : control_in_check

task usb_0_device_for_all_endpoint_tc::control_out_check();
    `uvm_info("","control_out_seq",UVM_LOW);

    sv_wait_label(300);
    this.control_out_seq = new();
    this.control_out_seq.start(mo_env.mo_usb_env[0].mo_host_agent.xfer_sequencer);
    sv_wait_label(301);
endtask : control_out_check

task usb_0_device_for_all_endpoint_tc::bulk_in_check();
    bit     [31:0]  expected_data;
    logic   [31:0]  trans_data[];

    `uvm_info("","bulk_in_seq",UVM_LOW)

    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].ep_number   = this.endpoint_index;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].direction   = svt_usb_types::IN;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].ep_type     = svt_usb_types::BULK;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].allow_aligned_transfer_without_zero_length = 0;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].interval    =0;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].max_packet_size    = `SVT_USB_FS_BULK_MAX_PACKET_SIZE;

    this.mo_env.mo_usb_env[0].mo_host_agent.refresh_cfg();

    sv_wait_label(400);
    this.bulk_in_seq = new();
    this.bulk_in_seq.endpoint_index = this.endpoint_index;
    this.bulk_in_seq.start(mo_env.mo_usb_env[0].mo_host_agent.xfer_sequencer);
    if((bulk_in_seq.data_temp.size()%4) != 0)
    begin
        trans_data = new[(bulk_in_seq.data_temp.size()/4) + 1];
        trans_data = {>>{bulk_in_seq.data_temp}};
        foreach(trans_data[index])
        begin
            trans_data[index] = {<<4 {trans_data[index]}};
        end

    end else begin
        trans_data = new[bulk_in_seq.data_temp.size()/4];
        trans_data = {>>{bulk_in_seq.data_temp}};
        foreach(trans_data[index])
        begin
            trans_data[index] = {<<4 {trans_data[index]}};
        end
    end

    foreach(trans_data[index])
    begin
        expected_data = (index+1) | (index+1)<<4 | (index+1)<<8 | (index+1)<<12;
        if(trans_data[index] != expected_data)
        begin
            `uvm_error("",$sformatf("recive data is %h, expect data is %h",trans_data[index],expected_data))
        end else begin
            `uvm_info("",$sformatf("recive data is %h, expect data is %h",trans_data[index],expected_data),UVM_LOW)
            `uvm_info("","recive data check success",UVM_LOW)
        end
    end

    sv_send_label(401);
endtask : bulk_in_check

task usb_0_device_for_all_endpoint_tc::bulk_out_check();
    `uvm_info("","bulk_out_seq",UVM_LOW)

    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].ep_number   = this.endpoint_index;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].direction   = svt_usb_types::OUT;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].ep_type     = svt_usb_types::BULK;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].allow_aligned_transfer_without_zero_length = 0;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].interval    =0;
    this.mo_usb_cfg[0].dev_cfg.local_device_cfg[0].endpoint_cfg[this.endpoint_index].max_packet_size    = `SVT_USB_FS_BULK_MAX_PACKET_SIZE;

    this.mo_env.mo_usb_env[0].mo_host_agent.refresh_cfg();

    sv_wait_label(500);
    this.bulk_out_seq = new();
    this.bulk_out_seq.endpoint_index = this.endpoint_index;
    this.bulk_out_seq.start(mo_env.mo_usb_env[0].mo_host_agent.xfer_sequencer);
    sv_wait_label(501);
endtask : bulk_out_check

`endif // USB_0_DEVICE_FOR_ALL_ENDPOINT_TC__SV

