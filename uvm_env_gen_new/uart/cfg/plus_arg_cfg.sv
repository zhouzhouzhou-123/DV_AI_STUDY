// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: plus_arg_cfg.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef PLUS_ARG_CFG__SV
`define PLUS_ARG_CFG__SV

class plus_arg_cfg extends uvm_sequence_item;

    static local plus_arg_cfg m_inst;

    int sst_ahbs_en = 0;
    int sst_ahbs_en2 = 0;

    `uvm_object_utils_begin(plus_arg_cfg)
        `uvm_field_int(sst_ahbs_en, UVM_ALL_ON)
        `uvm_field_int(sst_ahbs_en2, UVM_ALL_ON)
    `uvm_object_utils_end

    extern protected    function                new             (string name = "plus_arg_cfg");
    extern              function void           update_cfg      ();
    extern static       function plus_arg_cfg   get_inst        ();

endclass : plus_arg_cfg

function plus_arg_cfg::new(string name = "plus_arg_cfg");
    super.new(name);
    this.update_cfg();
    m_inst = this;
endfunction : new

function plus_arg_cfg plus_arg_cfg::get_inst();
    if(m_inst == null)
    begin
        m_inst = new("mo_plus_arg_cfg");
    end
    return m_inst;
endfunction : get_inst

function void plus_arg_cfg::update_cfg();
    $value$plusargs("sst_ahbs_en=%0d",this.sst_ahbs_en);
    $value$plusargs("sst_ahbs_en2=%0d",this.sst_ahbs_en2);

    this.print();
endfunction : update_cfg

`endif // PLUS_ARG_CFG__SV
