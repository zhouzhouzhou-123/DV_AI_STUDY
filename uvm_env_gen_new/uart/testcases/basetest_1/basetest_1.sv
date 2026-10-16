
`ifndef BASETEST_1__SV
`define BASETEST_1__SV

class basetest_1 extends basetest;

    `uvm_component_utils(basetest_1)

    extern function new(string name = "basetest_1", uvm_component parent);
    extern task tc_proc();

endclass: basetest_1

function basetest_1::new(string name = "basetest_1", uvm_component parent);
    super.new(name, parent);
endfunction : new

task basetest_1::tc_proc();
`ifdef MY_DEFINE_TEST
    `uvm_info("BASETEST_1", "my_define_test_basetest_1_v3", UVM_LOW)
`else
    `uvm_info("BASETEST_1", "basetest_1_v3", UVM_LOW)
`endif
endtask : tc_proc

`endif // BASETEST_1__SV
