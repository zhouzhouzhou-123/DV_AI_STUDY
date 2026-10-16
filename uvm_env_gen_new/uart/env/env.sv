// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: env.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef ENV__SV
`define ENV__SV

class env extends uvm_env;
`ifdef USB_TEST_ON
// -------------------------------- USB env ----------------------------- //
    usb_env mo_usb_env[USB_MASTER_COUNT];

    // payload callback used to set the response data
    usb_device_response_payload_callbacks   mo_dev_resp_cb[USB_MASTER_COUNT];
    host_expected_payload_callbacks         mo_host_cb[USB_MASTER_COUNT];
    device_expected_payload_callbacks       mo_dev_cb[USB_MASTER_COUNT];
`endif // USB_TEST_ON

`ifdef I2C_TEST_ON
    svt_i2c_system_env      mo_svt_i2c_system_env[5];
    svt_i2c_vif             mo_svt_i2c_vif[5];
`endif // I2C_TEST_ON


    vir_seqr            mo_vir_seqr;

    ral_regmodel        mo_regmodel;

    env_cfg             mo_env_cfg;


    `uvm_component_utils_begin(env)
        `uvm_field_object(mo_vir_seqr, UVM_ALL_ON)
        `uvm_field_object(mo_regmodel, UVM_ALL_ON)
        `uvm_field_object(mo_env_cfg, UVM_ALL_ON)




    `uvm_component_utils_end

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void create_agent();
    extern virtual function void create_refm();
    extern virtual function void create_scb();
    extern virtual function void config_regmodel();
    extern virtual function void config_env();

    extern virtual function void connect_phase(uvm_phase phase);

endclass : env

function void env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // config reg model
    this.config_regmodel();

    // config_env
    this.config_env();

    // virtual sequencer
    this.mo_vir_seqr = vir_seqr::type_id::create("mo_vir_seqr", this);

    // create agent
    this.create_agent();

    // create refm
    this.create_refm();

    // create scoreboard
    this.create_scb();
endfunction : build_phase

function void env::config_env();
    // get env_cfg
    if(!uvm_config_db#(env_cfg)::get(this, "", "mo_env_cfg", this.mo_env_cfg))
    begin
        `uvm_fatal(get_type_name(), "fail get mo_env_cfg!")
    end



`ifdef I2C_TEST_ON
    foreach(this.mo_env_cfg.mo_svt_i2c_system_env_cfg[index])
    begin
        uvm_config_db#(svt_i2c_system_configuration)::set(this, $sformatf("mo_svt_i2c_system_env[%0d]",index), "cfg", this.mo_env_cfg.mo_svt_i2c_system_env_cfg[index]);
        uvm_config_db#(svt_i2c_system_configuration)::set(this, $sformatf("mo_vir_seqr.mo_svt_i2c_seqr[%0d]",index), "cfg", this.mo_env_cfg.mo_svt_i2c_system_env_cfg[index]);
    end
`endif // I2C_TEST_ON

endfunction : config_env

function void env::create_agent();


`ifdef I2C_TEST_ON
    foreach(this.mo_svt_i2c_system_env[index])
    begin
        this.mo_svt_i2c_system_env[index] = svt_i2c_system_env::type_id::create($sformatf("mo_svt_i2c_system_env[%0d]",index), this);
    end
    foreach(this.mo_svt_i2c_vif[index])
    begin
        if(uvm_config_db#(svt_i2c_vif)::get(this, $sformatf("mo_svt_i2c_system_env[%0d].*", index),  "i2c_vif", this.mo_svt_i2c_vif[index]))
        begin
            this.mo_env_cfg.mo_svt_i2c_system_env_cfg[index].set_if(this.mo_svt_i2c_vif[index]);
        end else begin
            `uvm_fatal("","I2C vip get vif failed....")
        end
    end
`endif // I2C_TEST_ON
`ifdef USB_TEST_ON
    foreach(this.mo_usb_env[index])
    begin
        this.mo_usb_env[index] = usb_env::type_id::create($sformatf("mo_usb_env[%0d]",index), this);
    end
`endif // USB_TEST_ON

endfunction : create_agent

function void env::create_refm();

endfunction : create_refm

function void env::create_scb();

endfunction : create_scb

function void env::config_regmodel();
    this.mo_regmodel= ral_regmodel::type_id::create("mo_regmodel", this);
    this.mo_regmodel.configure(null, "");
    this.mo_regmodel.build();
    this.mo_regmodel.lock_model();
    this.mo_regmodel.reset();

    uvm_config_db#(ral_regmodel)::set(this, "*", "mo_regmodel", this.mo_regmodel);
endfunction : config_regmodel

function void env::connect_phase(uvm_phase phase);
    this.mo_regmodel.default_map.set_auto_predict(1);

`ifdef I2C_TEST_ON
    foreach(this.mo_svt_i2c_system_env[index])
    begin
        this.mo_vir_seqr.mo_svt_i2c_seqr[index] = this.mo_svt_i2c_system_env[index].sequencer;
    end
`endif // I2C_TEST_ON
`ifdef USB_TEST_ON
// -------------------------------- USB env connection ----------------------------- //
    foreach(this.mo_usb_env[index])
    begin
        this.mo_vir_seqr.mo_svt_usb_seqr[index] = this.mo_usb_env[index].mo_vir_seqr;

        this.mo_dev_resp_cb[index] = new();
        uvm_callbacks#(svt_usb_protocol)::add(this.mo_usb_env[index].mo_dev_agent.prot, this.mo_dev_resp_cb[index]);

        this.mo_host_cb[index] = new($sformatf("mo_host_cb[%0d]",index), this.mo_usb_env[index]);
        uvm_callbacks#(svt_usb_protocol)::add(this.mo_usb_env[index].mo_host_agent.prot, this.mo_host_cb[index]);

        this.mo_dev_cb[index] = new($sformatf("mo_dev_cb[%0d]",index), this.mo_usb_env[index]);
        uvm_callbacks#(svt_usb_protocol)::add(this.mo_usb_env[index].mo_dev_agent.prot, this.mo_dev_cb[index]);
    end
`endif // USB_TEST_ON

endfunction : connect_phase

`endif // ENV__SV
