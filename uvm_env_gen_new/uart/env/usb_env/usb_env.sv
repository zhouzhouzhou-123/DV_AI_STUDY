// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_env.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_ENV__SV
`define USB_ENV__SV

class usb_env extends uvm_env;

    usb_vir_seqr            mo_vir_seqr;

    virtual svt_usb_if      mo_host_usb_if;
    virtual svt_usb_if      mo_dev_usb_if;

    svt_usb_agent           mo_host_agent;
    svt_usb_agent           mo_dev_agent;

    svt_usb_agent           mo_host_mon_agent;
    svt_usb_agent           mo_dev_mon_agent;

    usb_shared_cfg          mo_usb_cfg;
    usb_shared_cfg          mo_swap_cfg;
    usb_shared_cfg          mo_otg_cfg;

    /**
     * Used by the ENV to build up a tabular summary of USB sequence items as seen by all
     * agents.  This class uses the svt_sequence_item::psdisplay_short()
     * method to create this report.
    */
    svt_sequence_item_report    mo_seq_item_report;

    // transfer queue used to update iso transfer from host to device
    svt_usb_transfer            mq_iso_out_xfer_q[$];
    svt_usb_transfer            mq_iso_in_xfer_q[$];


    // Instance of Callback class used to decide when to raise/drop objection for Host VIP.
    usb_host_objection_management_callbacks mo_host_objection_mgmt_callback;

    // Instance of Callback class used to decide when to raise/drop objection for Device VIP.
    usb_device_objection_management_callbacks mo_dev_objection_mgmt_callback;


    `uvm_component_utils_begin(usb_env)
        `uvm_field_object(mo_vir_seqr, UVM_ALL_ON)
    `uvm_component_utils_end

    extern          function            new                     (string name = "usb_env", uvm_component parent = null);
    extern  virtual function    void    build_phase             (uvm_phase phase);
    extern  virtual function    void    create_agent            ();
    extern  virtual function    void    create_refm             ();
    extern  virtual function    void    create_scb              ();
    extern  virtual function    void    config_reg_model        ();
    extern  virtual function    void    config_env              ();
    extern  virtual function    void    connect_phase           (uvm_phase phase);
    extern  virtual function    void    report_phase            (uvm_phase phase);
    extern  virtual task                main_phase              (uvm_phase phase);
    extern  virtual task                objection_management    (uvm_phase phase);
    extern  virtual function    void    prepare_usb_cfg         ();
    extern  virtual function    void    prepare_usb_interface   ();
    extern  virtual function    void    prepare_seq_item_report ();
endclass : usb_env

function usb_env::new(string name = "usb_env", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void usb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("", "This is build_phase", UVM_LOW)

    this.prepare_usb_cfg();
    this.prepare_usb_interface();
    this.prepare_seq_item_report();

    // config reg model
    this.config_reg_model();

    // config_env
    this.config_env();

    // virtual sequencer
    this.mo_vir_seqr = usb_vir_seqr::type_id::create("mo_vir_seqr", this);

    // create agent
    this.create_agent();

    // create refm
    this.create_refm();

    // create scoreboard
    this.create_scb();
endfunction : build_phase

function void usb_env::prepare_seq_item_report();
    // Setup and register the system sequence item reporter with the host and device
    this.mo_seq_item_report = new(svt_usb_suite_spec_override::get_suite_spec());
    uvm_config_db#(svt_sequence_item_report)::set(this, "mo_host_agent", "sys_seq_item_report", this.mo_seq_item_report);
    uvm_config_db#(svt_sequence_item_report)::set(this, "mo_dev_agent", "sys_seq_item_report", this.mo_seq_item_report);

    if(this.mo_usb_cfg.enable_host_mon == 1)
    begin
//        uvm_config_db#(svt_sequence_item_report)::set(this, "mo_host_mon_agent", "sys_seq_item_report", this.mo_seq_item_report);
    end
    if(this.mo_usb_cfg.enable_dev_mon == 1)
    begin
//        uvm_config_db#(svt_sequence_item_report)::set(this, "mo_dev_mon_agent", "sys_seq_item_report", this.mo_seq_item_report);
    end
endfunction : prepare_seq_item_report

function void usb_env::prepare_usb_cfg();
    if(!uvm_config_db#(usb_shared_cfg)::get(this, "", "usb_cfg", this.mo_usb_cfg))
    begin
        `uvm_fatal("", "Unable to get usb_shared_cfg")
    end

    // enable host/device monitor
    this.mo_usb_cfg.enable_host_mon = 1;
    this.mo_usb_cfg.enable_dev_mon  = 1;

    // enable most of the protocol tracking choices, all but cov
    this.mo_usb_cfg.host_cfg.enable_prot_chk        = 0;
    this.mo_usb_cfg.host_cfg.enable_prot_reporting  = 0;
    this.mo_usb_cfg.host_cfg.enable_prot_tracing    = 0;
    this.mo_usb_cfg.dev_cfg.enable_prot_chk         = 0;
    this.mo_usb_cfg.dev_cfg.enable_prot_reporting   = 0;
    this.mo_usb_cfg.dev_cfg.enable_prot_tracing     = 0;

    // Enable the minimum link tracking choices
    this.mo_usb_cfg.host_cfg.enable_link_reporting  = 1;
    this.mo_usb_cfg.host_cfg.enable_link_tracing    = 1;
    this.mo_usb_cfg.dev_cfg.enable_link_reporting   = 1;
    this.mo_usb_cfg.dev_cfg.enable_link_tracing     = 1;

    // Double check that the configuration is valid before moving on
    if(this.mo_usb_cfg.is_valid(0))
    begin
//        `uvm_info("build_phase", $sformatf("cfg passed is_valid() check. Contents:\n%0s", this.mo_usb_cfg.sprint()), UVM_LOW)
    end else begin
        `uvm_fatal("build_phase", "cfg failed is_valid() check. Unable to continue.")
    end

    // If we made it this far, the cfg is good -- pull out and register the host and device cfgs
    uvm_config_db#(svt_usb_agent_configuration)::set(this, "mo_host_agent", "cfg", this.mo_usb_cfg.host_cfg);
    uvm_config_db#(svt_usb_agent_configuration)::set(this, "mo_dev_agent", "cfg", this.mo_usb_cfg.dev_cfg);
    uvm_config_db#(svt_usb_configuration)::set(this, "mo_vir_seqr.mo_host_xfer_sequencer", "cfg", this.mo_usb_cfg.host_cfg);

    if(this.mo_usb_cfg.enable_host_mon == 1)
    begin
//        uvm_config_db#(svt_usb_agent_configuration)::set(this, "mo_host_mon_agent", "cfg", this.mo_usb_cfg.host_cfg);
//        uvm_config_db#(bit)::set(this, "mo_host_mon_agent", "is_active", 0);
    end

    if(this.mo_usb_cfg.enable_dev_mon == 1)
    begin
//        uvm_config_db#(svt_usb_agent_configuration)::set(this, "mo_dev_mon_agent", "cfg", this.mo_usb_cfg.dev_cfg);
//        uvm_config_db#(bit)::set(this, "mo_dev_mon_agent", "is_active", 0);
    end

endfunction : prepare_usb_cfg

function void usb_env::prepare_usb_interface();
    if(!uvm_config_db#(virtual svt_usb_if)::get(null, get_full_name(), "host_usb_if", mo_host_usb_if))
    begin
        `uvm_fatal("","Unable to get host_usb_if")
    end

    if(!uvm_config_db#(virtual svt_usb_if)::get(null, get_full_name(), "dev_usb_if", mo_dev_usb_if))
    begin
        `uvm_fatal("", "Unable to get dev_usb_if")
    end

    // host interface
    if(this.mo_usb_cfg.host_cfg.usb_ss_signal_interface != svt_usb_configuration::NO_SS_IF)
    begin
        uvm_config_db#(virtual svt_usb_if)::set(this, "mo_host_agent", "usb_ss_if", this.mo_host_usb_if);
        if(this.mo_usb_cfg.enable_host_mon == 1)
        begin
//            uvm_config_db#(virtual svt_usb_if)::set(this, "mo_host_mon_agent", "usb_ss_if", this.mo_host_usb_if);
        end
    end
    if(this.mo_usb_cfg.host_cfg.usb_20_signal_interface != svt_usb_configuration::NO_20_IF)
    begin
        uvm_config_db#(virtual svt_usb_if)::set(this, "mo_host_agent", "usb_20_if", this.mo_host_usb_if);
        if(this.mo_usb_cfg.enable_host_mon == 1)
        begin
//            uvm_config_db#(virtual svt_usb_if)::set(this, "mo_host_mon_agent", "usb_20_if", this.mo_host_usb_if);
        end
    end

    // device interface
    if(this.mo_usb_cfg.dev_cfg.usb_ss_signal_interface != svt_usb_configuration::NO_SS_IF)
    begin
        uvm_config_db#(virtual svt_usb_if)::set(this, "mo_dev_agent", "usb_ss_if", this.mo_dev_usb_if);
        if(this.mo_usb_cfg.enable_dev_mon == 1)
        begin
//            uvm_config_db#(virtual svt_usb_if)::set(this, "mo_dev_mon_agent", "usb_ss_if", this.mo_dev_usb_if);
        end
    end
    if(this.mo_usb_cfg.dev_cfg.usb_20_signal_interface != svt_usb_configuration::NO_20_IF)
    begin
        uvm_config_db#(virtual svt_usb_if)::set(this, "mo_dev_agent", "usb_20_if", this.mo_dev_usb_if);
        if(this.mo_usb_cfg.enable_dev_mon == 1)
        begin
//            uvm_config_db#(virtual svt_usb_if)::set(this, "mo_dev_mon_agent", "usb_20_if", this.mo_dev_usb_if);
        end
    end

    // if(this.mo_usb_cfg.host_cfg.usb_20_signal_interface == svt_usb_configuration::USB_20_EUSB2_IF &&
    //     this.mo_usb_cfg.host_cfg.enable_eusb_20_repeater == 1'b1)
    // begin
    //     uvm_config_db#(virtual svt_usb_if)::get(this, "", "host_eusb2_repeater_if", this.mo_host_eusb2_repeater_if));
    //     uvm_config_db#(virtual svt_usb_if)::set(this, "eusb2_repeater", "usb_if", this.mo_host_eusb2_repeater_if);
    //     uvm_config_db#(svt_usb_agent_configuration)::set(this, "eusb2_repeater", "cfg", this.mo_usb_cfg.host_cfg);
    // end
    // if(this.mo_usb_cfg.dev_cfg.usb_20_signal_interface == svt_usb_configuration::USB_20_EUSB2_IF &&
    //     cfg.dev_cfg.enable_eusb_20_repeater == 1'b1)
    // begin
    //     this.mo_eusb2_repeater = svt_usb_physical_port_20_eusb2_repeater::type_id::create("mo_eusb2_repeater", this);
    //     uvm_config_db#(virtual svt_usb_if)::get(null,get_full_name(), "device_eusb2_repeater_if", this.mo_device_eusb2_repeater_if);
    //     uvm_config_db#(virtual svt_usb_if)::set(this, "eusb2_repeater", "usb_if", this.mo_device_eusb2_repeater_if);
    //     uvm_config_db#(svt_usb_agent_configuration)::set(this, "eusb2_repeater", "cfg", this.mo_usb_cfg.dev_cfg);
    // end
endfunction : prepare_usb_interface

function void usb_env::config_env();
    // get usb_env_cfg

endfunction : config_env

function void usb_env::create_agent();
    // slave agent
    // master agent

    this.mo_host_agent = svt_usb_agent::type_id::create("mo_host_agent", this);
    this.mo_dev_agent = svt_usb_agent::type_id::create("mo_dev_agent", this);

    if(this.mo_usb_cfg.enable_host_mon == 1)
    begin
//        this.mo_host_mon_agent = svt_usb_agent::type_id::create("mo_host_mon_agent", this);
    end
    if(this.mo_usb_cfg.enable_dev_mon == 1)
    begin
//        this.mo_dev_mon_agent = svt_usb_agent::type_id::create("mo_dev_mon_agent", this);
    end
endfunction : create_agent

function void usb_env::create_refm();
endfunction : create_refm

function void usb_env::create_scb();
endfunction : create_scb

function void usb_env::config_reg_model();
endfunction : config_reg_model

function void usb_env::connect_phase(uvm_phase phase);

    this.mo_vir_seqr.mo_host_xfer_sequencer = this.mo_host_agent.xfer_sequencer;
    // this.mo_vir_seqr.mo_host_xfer_sequencer = this.mo_host_agent.xfer_sequencer;

    this.mo_host_objection_mgmt_callback = new("host_obj_mgmt_cb");
    uvm_callbacks#(svt_usb_protocol)::add(this.mo_host_agent.prot, this.mo_host_objection_mgmt_callback);
    this.mo_dev_objection_mgmt_callback  = new("dev_obj_mgmt_cb");
    uvm_callbacks#(svt_usb_protocol)::add(this.mo_dev_agent.prot, this.mo_dev_objection_mgmt_callback);


endfunction : connect_phase

task usb_env::main_phase(uvm_phase phase);

    `uvm_info("", "This is main_phase", UVM_LOW)

    this.objection_management(phase);
endtask : main_phase

function void usb_env::report_phase(uvm_phase phase);
    `uvm_info("report", "Entered...", UVM_LOW)
    super.report_phase(phase);

    // Display the transaction and transfer summary
    if(this.mo_seq_item_report != null)
    begin
        string seq_item_summary = this.mo_seq_item_report.psdisplay_summary();
        if(seq_item_summary.len() > 0)
        begin
            `uvm_info("report_phase", {"\n", seq_item_summary}, UVM_LOW)
        end
    end
endfunction : report_phase

task usb_env::objection_management(uvm_phase phase);
    fork
        while(1)
        begin
            wait(this.mo_host_objection_mgmt_callback.objection_raise_ev.triggered)
            phase.raise_objection(this);
            #1; //To avoid deadlock as new host transfer can start immediately after the previous one is complete
            wait(this.mo_host_objection_mgmt_callback.objection_drop_ev.triggered)
            phase.drop_objection(this);
        end
        while (1) begin
            wait(this.mo_dev_objection_mgmt_callback.objection_raise_ev.triggered)
            phase.raise_objection(this);
            wait(this.mo_dev_objection_mgmt_callback.objection_drop_ev.triggered)
            phase.drop_objection(this);
        end
    join_none
endtask

`endif // ENV__SV

