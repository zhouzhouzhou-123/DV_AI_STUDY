
`ifndef COMMON_TASK__SVH
`define COMMON_TASK__SVH

task wait_global_reset_release();
    // wait system power on & reset release
    `uvm_info("", "wait global reset release start....", UVM_LOW)
    fork : wait_reset_release
        // TODO
        // wait(`CHIP_RESETN === 1);
        // begin
        //     #50ms;
        //     `uvm_fatal("", "global reset not release in 50ms....")
        // end
    join_any
    disable wait_reset_release;

    `uvm_info("", "wait global reset release done ....", UVM_LOW)
endtask : wait_global_reset_release

`endif // COMMON_TASK__SVH

