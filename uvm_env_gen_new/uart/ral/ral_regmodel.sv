// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: ral_regmodel.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------

`ifndef RAL_REGMODEL__SV
`define RAL_REGMODEL__SV
class ral_regmodel extends uvm_reg_block;

    function new(string name = "ral_regmodel");
        super.new(name);
    endfunction: new

    function void build();
        this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
        // this.rtc = ral_block_regmodel_rtc::type_id::create("rtc",,get_full_name());
        // this.rtc.configure(this, "");
        // this.rtc.build();
        // this.default_map.add_submap(this.rtc.default_map, `UVM_REG_ADDR_WIDTH'h40002800);
    endfunction : build

    `uvm_object_utils(ral_regmodel)
endclass : ral_regmodel

`endif // RAL_REGMODEL__SV

