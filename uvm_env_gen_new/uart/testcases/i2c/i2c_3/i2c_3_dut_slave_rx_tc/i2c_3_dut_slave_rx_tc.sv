//------------------------------------------------------------------------
// FILE NAME      : i2c_3_dut_slave_rx_tc.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 15:00:54
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef I2C_3_DUT_SLAVE_RX_TC__SV
`define I2C_3_DUT_SLAVE_RX_TC__SV

class i2c_3_dut_slave_rx_tc extends i2c_basetest;

    `uvm_component_utils(i2c_3_dut_slave_rx_tc)

    extern  function    new             (string name = "i2c_3_dut_slave_rx_tc", uvm_component parent);
    extern  task        configure_phase (uvm_phase phase);

    extern  task        modify_i2c_cfg  ();
    extern  task        tc_proc         ();

endclass : i2c_3_dut_slave_rx_tc

function i2c_3_dut_slave_rx_tc::new(string name = "i2c_3_dut_slave_rx_tc", uvm_component parent);
     super.new(name, parent);
endfunction

task i2c_3_dut_slave_rx_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    this.load_hex_file("../ccode/hex/i2c_3_dut_slave_rx_tc.hex");
    phase.drop_objection(this);
endtask

task i2c_3_dut_slave_rx_tc::tc_proc();

    sv_wait_label(100);

    this.modify_i2c_cfg();

    this.vip_tx_as_master(3, {'h5a, 'h5b, 'h5c, 'h5d});

    // wait I2CS interrupt; RX data checked in interrupt handler
    fork : wait_enter_interrupt
        begin
            sv_wait_label(666);
            sv_wait_label(777);
            `uvm_info("","enter interupt handler",UVM_LOW)
        end
        begin
            #3ms;
            `uvm_error("","enter interrupt handler timeout...")
        end
    join_any
    disable wait_enter_interrupt;
endtask : tc_proc

task i2c_3_dut_slave_rx_tc::modify_i2c_cfg();
    randcase
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[3].set_bus_speed(`SVT_I2C_STANDARD_MODE);
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[3].set_bus_speed(`SVT_I2C_FAST_MODE);
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[3].set_bus_speed(`SVT_I2C_FAST_MODE_PLUS);
    endcase
endtask : modify_i2c_cfg

`endif // I2C_3_DUT_SLAVE_RX_TC__SV

