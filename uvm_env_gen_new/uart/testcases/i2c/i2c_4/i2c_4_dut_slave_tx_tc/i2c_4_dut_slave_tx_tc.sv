//------------------------------------------------------------------------
// FILE NAME      : i2c_4_dut_slave_tx_tc.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 15:00:54
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef I2C_4_DUT_SLAVE_TX_TC__SV
`define I2C_4_DUT_SLAVE_TX_TC__SV

class i2c_4_dut_slave_tx_tc extends i2c_basetest;

    `uvm_component_utils(i2c_4_dut_slave_tx_tc)

    extern  function    new             (string name = "i2c_4_dut_slave_tx_tc", uvm_component parent);
    extern  task        configure_phase (uvm_phase phase);

    extern  task        modify_i2c_cfg  ();
    extern  task        tc_proc         ();

endclass : i2c_4_dut_slave_tx_tc

function i2c_4_dut_slave_tx_tc::new(string name = "i2c_4_dut_slave_tx_tc", uvm_component parent);
     super.new(name, parent);
endfunction

task i2c_4_dut_slave_tx_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    this.load_hex_file("../ccode/hex/i2c_4_dut_slave_tx_tc.hex");
    phase.drop_objection(this);
endtask

task i2c_4_dut_slave_tx_tc::tc_proc();
    bit [7:0]   rx_data[$];

    sv_wait_label(100);

    this.modify_i2c_cfg();
    this.vip_rx_as_master(4, rx_data);

    if(rx_data[0] != 'h5d)
    begin
        `uvm_error("",$sformatf("VIP rx_data[0] 'h%0h != 'h5d", rx_data[0]))
    end else begin
        `uvm_info("",$sformatf("VIP rx_data[0] 'h%0h == 'h5d", rx_data[0]), UVM_LOW)
    end
    if(rx_data[1] != 'h5c)
    begin
        `uvm_error("",$sformatf("VIP rx_data[1] 'h%0h != 'h5c", rx_data[1]))
    end else begin
        `uvm_info("",$sformatf("VIP rx_data[1] 'h%0h == 'h5c", rx_data[1]), UVM_LOW)
    end
    if(rx_data[2] != 'h5b)
    begin
        `uvm_error("",$sformatf("VIP rx_data[2] 'h%0h != 'h5b", rx_data[2]))
    end else begin
        `uvm_info("",$sformatf("VIP rx_data[2] 'h%0h == 'h5b", rx_data[2]), UVM_LOW)
    end
    if(rx_data[3] != 'h5a)
    begin
        `uvm_error("",$sformatf("VIP rx_data[3] 'h%0h != 'h5a", rx_data[3]))
    end else begin
        `uvm_info("",$sformatf("VIP rx_data[3] 'h%0h == 'h5a", rx_data[3]), UVM_LOW)
    end
endtask : tc_proc

task i2c_4_dut_slave_tx_tc::modify_i2c_cfg();
    randcase
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[4].set_bus_speed(`SVT_I2C_STANDARD_MODE);
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[4].set_bus_speed(`SVT_I2C_FAST_MODE);
        1   :   this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[4].set_bus_speed(`SVT_I2C_FAST_MODE_PLUS);
    endcase
endtask : modify_i2c_cfg

`endif // I2C_4_DUT_SLAVE_TX_TC__SV

