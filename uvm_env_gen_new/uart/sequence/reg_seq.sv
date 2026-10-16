// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: reg_seq.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef REG_SEQ__SV
`define REG_SEQ__SV

class reg_seq extends uvm_reg_sequence;

    ral_regmodel    mo_regmodel;

    `uvm_object_utils_begin(reg_seq)
    `uvm_object_utils_end

    extern          function    new         (string name = "reg_seq");
    extern  virtual task        pre_body    ();
    extern  virtual task        body        ();
    extern  virtual task        post_body   ();

endclass : reg_seq

function reg_seq::new(string name = "reg_seq");
    super.new(name);
endfunction : new

task reg_seq::pre_body();
    `uvm_info("pre_body", "This is pre_body...", UVM_LOW)

    if(!uvm_config_db#(ral_regmodel)::get(null, get_full_name(), "mo_regmodel", this.mo_regmodel))
    begin
        `uvm_fatal("pre_body", "Unable ot get regmodel from config_db::get");
    end
endtask : pre_body

task reg_seq::body();
    uvm_status_e status;
    `uvm_info("body", "This is body...", UVM_LOW)
endtask : body

task reg_seq::post_body();
    `uvm_info("post_body", "This is post_body...", UVM_LOW)
endtask : post_body

`endif // REG_SEQ__SV
