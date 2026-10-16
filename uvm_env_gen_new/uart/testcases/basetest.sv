
`ifndef BASETEST__SV
`define BASETEST__SV

class basetest extends uvm_test;

    env             mo_env;
    env_cfg         mo_env_cfg;
    uvm_status_e    status;

    `uvm_component_utils_begin(basetest)
        `uvm_field_object(mo_env, UVM_ALL_ON)
        `uvm_field_object(mo_env_cfg, UVM_ALL_ON)
    `uvm_component_utils_end

    extern          function            new                         (string name = "basetest", uvm_component parent = null);
    extern  virtual function    void    build_phase                 (uvm_phase phase);
    extern  virtual function    void    report_phase                (uvm_phase phase);
    extern  virtual function    void    end_of_elaboration_phase    (uvm_phase phase);
    extern  virtual task                configure_phase             (uvm_phase phase);
    extern  virtual task                main_phase                  (uvm_phase phase);
    extern  virtual task                run_phase                  (uvm_phase phase);

    extern  virtual function    void    set_default_vir_seq ();

    extern  virtual task                tc_proc             ();


    `include "../testcases/basetask/basetask_top.svh"
endclass : basetest


function basetest::new(string name = "basetest", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void basetest::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("", "This is build_phase", UVM_LOW)

    this.mo_env     = env::type_id::create("mo_env", this);
    this.mo_env_cfg = env_cfg::type_id::create("mo_env_cfg");

    // ----------- instance and update env_cfg ------------- //
    this.mo_env_cfg.create_env_cfg();
    this.mo_env_cfg.modify_env_cfg();
    uvm_config_db#(env_cfg)::set(this, "*", "mo_env_cfg", this.mo_env_cfg);

    this.set_default_vir_seq();
endfunction : build_phase

task basetest::configure_phase(uvm_phase phase);
    string file_name;
    integer fd;

    phase.raise_objection(this);

    // file_name = "../ccode/hex/hello_world.hex"
    // this.load_hex_file(file_name);

    phase.drop_objection(this);
endtask : configure_phase

function void basetest::set_default_vir_seq();
    uvm_config_db#(uvm_object_wrapper)::set(this,"mo_env.mo_vir_seqr.main_phase","default_sequence", vir_seq::type_id::get());
endfunction : set_default_vir_seq


function void basetest::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // uvm_top.print_topology();
endfunction : end_of_elaboration_phase

task basetest::run_phase(uvm_phase phase);
    `uvm_info("", "call run_phase", UVM_LOW)

    fork
        this.ccode_print_ok_error_monitor();
        this.ccode_print_string_monitor();
        this.ccode_print_info_monitor();
    join_none

endtask : run_phase

task basetest::main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("", "call main_phase", UVM_LOW)

    this.wait_global_reset_release();

    this.tc_proc();

    phase.drop_objection(this);
endtask : main_phase

task basetest::tc_proc();
    `uvm_info("", "tc proc start ....", UVM_LOW)
endtask : tc_proc

function void basetest::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;

    super.report_phase(phase);

    server = uvm_report_server::get_server();
    err_num = server.get_severity_count(UVM_ERROR) + server.get_severity_count(UVM_FATAL);
    `uvm_info("",$sformatf("the err_num is %0d", err_num), UVM_LOW)
    if(err_num == 0)
    begin
        $display("****Congratulation, case pass**********");

        $display("***************************************");
        $display("****  ####    #      #####  #####  ****");
        $display("****  #  #   # #     #      #      ****");
        $display("****  ###   #####    #####  #####  ****");
        $display("****  #    #     #       #      #  ****");
        $display("****  #   #       #  #####  #####  ****");
        $display("***************************************");
    end else begin
        $display("*****case run fail, please check*******");

        $display("***************************************");
        $display("****  ####    #      #####  #      ****");
        $display("****  #      # #       #    #      ****");
        $display("****  ####  #####      #    #      ****");
        $display("****  #    #     #     #    #      ****");
        $display("****  #   #       #  #####  #####  ****");
        $display("***************************************");
    end
endfunction : report_phase

`endif // BASETEST__SV

