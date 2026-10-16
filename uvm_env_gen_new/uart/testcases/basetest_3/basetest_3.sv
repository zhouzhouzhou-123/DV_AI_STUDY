
`ifndef BASETEST_3__SV
`define BASETEST_3__SV

class basetest_3 extends basetest;

    `uvm_component_utils(basetest_3)

    extern function new(string name = "basetest_3", uvm_component parent);
    extern task tc_proc();

endclass: basetest_3

function basetest_3::new(string name = "basetest_3", uvm_component parent);
    super.new(name, parent);
endfunction : new

task basetest_3::tc_proc();
    `uvm_info("BASETEST_3", "basetest_3_modified", UVM_LOW)
endtask : tc_proc

`endif // BASETEST_3__SV
