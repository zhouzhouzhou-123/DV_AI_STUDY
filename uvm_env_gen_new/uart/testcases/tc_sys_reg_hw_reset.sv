
`ifndef TC_SYS_REG_HW_RESET__SV
`define TC_SYS_REG_HW_RESET__SV

class tc_sys_reg_hw_reset extends basetest;

    `uvm_component_utils(tc_sys_reg_hw_reset)

    function new(string name = "tc_sys_reg_hw_reset", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    extern virtual task tc_proc();

endclass : tc_sys_reg_hw_reset

task tc_sys_reg_hw_reset::tc_proc();
    uvm_reg_hw_reset_seq   o_reg_hw_reset_seq;
    
    o_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("o_reg_hw_reset_seq", this);
    
    //uvm_resource_db#(bit)::set({"REG::", mo_env.mo_regmodel.mo_xxx_regmodel.reg_name.get_full_name()}, "NO_REG_TESTS", 1, this);
    
    o_reg_hw_reset_seq.model = mo_env.mo_regmodel;
    o_reg_hw_reset_seq.start(null);
    
endtask : tc_proc

`endif // TC_SYS_REG_HW_RESET__SV

