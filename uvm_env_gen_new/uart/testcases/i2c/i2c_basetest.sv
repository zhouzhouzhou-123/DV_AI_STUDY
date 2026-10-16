//------------------------------------------------------------------------
// FILE NAME      : i2c_basetest.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 15:00:54
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef I2C_BASETEST__SV
`define I2C_BASETEST__SV

class i2c_basetest extends basetest;


    `uvm_component_utils(i2c_basetest)

    extern  function    new                 (string name = "i2c_basetest", uvm_component parent);
    extern  task        vip_rx_as_slave     (int agent_index, ref bit [7:0] rx_data[$]);
    extern  task        vip_tx_as_slave     (int agent_index, bit [7:0] tx_data[$]);
    extern  task        vip_rx_as_master    (int agent_index, ref bit [7:0] rx_data[$]);
    extern  task        vip_tx_as_master    (int agent_index, bit [7:0] tx_data[$]);

endclass : i2c_basetest

function i2c_basetest::new(string name = "i2c_basetest", uvm_component parent);
     super.new(name, parent);
endfunction

task i2c_basetest::vip_rx_as_slave(int agent_index, ref bit [7:0] rx_data[$]);
    i2c_vip_slave_sequence slave_seq = i2c_vip_slave_sequence::type_id::create("slave_seq");

    this.mo_env.mo_svt_i2c_system_env[agent_index].master[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].master_cfg[0]);
    this.mo_env.mo_svt_i2c_system_env[agent_index].slave[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0]);

    slave_seq.start(this.mo_env.mo_vir_seqr.mo_svt_i2c_seqr[agent_index].master_sequencer[agent_index]);

    rx_data = slave_seq.rx_data;
endtask : vip_rx_as_slave

task i2c_basetest::vip_tx_as_slave(int agent_index, bit [7:0] tx_data[$]);
    i2c_vip_slave_sequence slave_seq = i2c_vip_slave_sequence::type_id::create("slave_seq");

    this.mo_env.mo_svt_i2c_system_env[agent_index].master[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].master_cfg[0]);
    this.mo_env.mo_svt_i2c_system_env[agent_index].slave[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0]);

    slave_seq.config_sequence(tx_data);

    slave_seq.start(this.mo_env.mo_vir_seqr.mo_svt_i2c_seqr[agent_index].master_sequencer[agent_index]);

endtask : vip_tx_as_slave

task i2c_basetest::vip_rx_as_master(int agent_index, ref bit [7:0] rx_data[$]);
    i2c_vip_master_sequence master_seq = i2c_vip_master_sequence::type_id::create("master_seq");

    this.mo_env.mo_svt_i2c_system_env[agent_index].master[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].master_cfg[0]);
    this.mo_env.mo_svt_i2c_system_env[agent_index].slave[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0]);

    // config_seq(bit [9:0] slaver_addr, bit is_10bit=0, int i2c_command, int data_size=8, bit[7:0] write_data);
    master_seq.config_sequence(
        this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0].slave_address,
        this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0].enable_10bit_addr,
        `SVT_I2C_READ,
        ,
        {}
    );

    master_seq.start(this.mo_env.mo_vir_seqr.mo_svt_i2c_seqr[agent_index].master_sequencer[agent_index]);

    rx_data = master_seq.rx_data;
endtask : vip_rx_as_master

task i2c_basetest::vip_tx_as_master(int agent_index, bit [7:0] tx_data[$]);
    i2c_vip_master_sequence master_seq = i2c_vip_master_sequence::type_id::create("master_seq");

    this.mo_env.mo_svt_i2c_system_env[agent_index].master[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].master_cfg[0]);
    this.mo_env.mo_svt_i2c_system_env[agent_index].slave[0].reconfigure_via_task(this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0]);

    // config_seq(bit [9:0] slaver_addr, bit is_10bit=0, int i2c_command, int data_size=8, bit[7:0] write_data);
    master_seq.config_sequence(
        this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0].slave_address,
        this.mo_env.mo_env_cfg.mo_svt_i2c_system_env_cfg[agent_index].slave_cfg[0].enable_10bit_addr,
        `SVT_I2C_WRITE,
        tx_data.size(),
        tx_data
    );

    master_seq.start(this.mo_env.mo_vir_seqr.mo_svt_i2c_seqr[agent_index].master_sequencer[agent_index]);
endtask : vip_tx_as_master

`endif // I2C_BASETEST__SV

