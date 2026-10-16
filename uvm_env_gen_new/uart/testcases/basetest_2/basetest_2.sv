
`ifndef BASETEST_2__SV
`define BASETEST_2__SV

class basetest_2 extends basetest;

    `uvm_component_utils(basetest_2)

    extern function new(string name = "basetest_2", uvm_component parent);
    extern task tc_proc();

endclass: basetest_2

function basetest_2::new(string name = "basetest_2", uvm_component parent);
    super.new(name, parent);
endfunction : new

task basetest_2::tc_proc();
    `uvm_info("BASETEST_2", "basetest_2_modified", UVM_LOW)
endtask : tc_proc

`endif // BASETEST_2__SV
