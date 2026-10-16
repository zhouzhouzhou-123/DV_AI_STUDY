
`ifndef COMMON_PERMISSION_DEFINE_SV
`define COMMON_PERMISSION_DEFINE_SV

`define     ACCEN_DEFAULT_VALUE     64'hEF10_1F01_F4FF_0F0F
`define     ACCEN0_DEFAULT_VALUE    32'hF4FF_0F0F
`define     ACCEN1_DEFAULT_VALUE    32'hEF10_1F01
`define     ACCEN0_DEFAULT_MSK      32'hF4FF_0F0F
`define     ACCEN1_DEFAULT_MSK      32'hEF10_1F01

`define     ACCEN_VM_DEFAULT_VALUE  9'h1ff
`define     ACCEN_VM_DEFAULT_MSK    9'h1ff

//`define     CONN_ENDINIT            top.mo_rcu_if.endinit
//`define     CONN_SAFETY_ENDINIT     top.mo_rcu_if.safety_endinit


//Function: used for assert report
// Author: xiayu
`define ASSERT_REPORT(INFO,MSG="assert failed") \
    assert(INFO) \
        else `uvm_error(get_full_name(),MSG)

`endif  //COMMON_PERMISSION_DEFINE_SV
