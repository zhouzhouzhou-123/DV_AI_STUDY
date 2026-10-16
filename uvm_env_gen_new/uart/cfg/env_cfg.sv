// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: env_cfg.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef ENV_CFG__SV
`define ENV_CFG__SV

class env_cfg extends uvm_sequence_item;

`ifdef I2C_TEST_ON
    svt_i2c_system_configuration        mo_svt_i2c_system_env_cfg[5];
`endif // I2C_TEST_ON


    `uvm_object_utils_begin(env_cfg)


    `uvm_object_utils_end

    function new(string name = "env_cfg");
        super.new(name);
    endfunction : new

    extern function void create_env_cfg();
    extern function void modify_env_cfg();

endclass : env_cfg

function void env_cfg::create_env_cfg();
    // instance master agent cfg


    // instance slaver agent cfg

`ifdef I2C_TEST_ON
    foreach(this.mo_svt_i2c_system_env_cfg[index])
    begin
        this.mo_svt_i2c_system_env_cfg[index] = svt_i2c_system_configuration::type_id::create($sformatf("mo_svt_i2c_system_env_cfg[%0d]",index));
    end
`endif // I2C_TEST_ON

endfunction : create_env_cfg

function void env_cfg::modify_env_cfg();


`ifdef I2C_TEST_ON
    // ------------------- I2C_0 configuration ------------------------ //
    this.mo_svt_i2c_system_env_cfg[0].num_masters     = 1;
    this.mo_svt_i2c_system_env_cfg[0].num_slaves      = 1;
    this.mo_svt_i2c_system_env_cfg[0].create_sub_cfgs(1, 1);
    // `SVT_I2C_STANDARD_MODE   : 100K
    // `SVT_I2C_FAST_MODE       : 400K
    // `SVT_HIGHSPEED_MODE      : 1M
    // `SVT_I2C_FAST_MODE_PLUS  : 4M
    this.mo_svt_i2c_system_env_cfg[0].set_bus_speed(`SVT_I2C_STANDARD_MODE);
    this.mo_svt_i2c_system_env_cfg[0].slave_cfg[0].is_active         = 1;
    this.mo_svt_i2c_system_env_cfg[0].master_cfg[0].is_active        = 1;
    this.mo_svt_i2c_system_env_cfg[0].master_cfg[0].master_code      = 3'b101;   // Set Bus-Speed;
    this.mo_svt_i2c_system_env_cfg[0].slave_cfg[0].slave_address     = 10'h5a;
    this.mo_svt_i2c_system_env_cfg[0].slave_cfg[0].enable_10bit_addr = 1;
    this.mo_svt_i2c_system_env_cfg[0].slave_cfg[0].slave_type        = `SVT_I2C_GENERIC;

    // ------------------- I2C_1 configuration ------------------------ //
    this.mo_svt_i2c_system_env_cfg[1].num_masters     = 1;
    this.mo_svt_i2c_system_env_cfg[1].num_slaves      = 1;
    this.mo_svt_i2c_system_env_cfg[1].create_sub_cfgs(1, 1);
    // `SVT_I2C_STANDARD_MODE   : 100K
    // `SVT_I2C_FAST_MODE       : 400K
    // `SVT_HIGHSPEED_MODE      : 1M
    // `SVT_I2C_FAST_MODE_PLUS  : 4M
    this.mo_svt_i2c_system_env_cfg[1].set_bus_speed(`SVT_I2C_STANDARD_MODE);
    this.mo_svt_i2c_system_env_cfg[1].slave_cfg[0].is_active         = 1;
    this.mo_svt_i2c_system_env_cfg[1].master_cfg[0].is_active        = 1;
    this.mo_svt_i2c_system_env_cfg[1].master_cfg[0].master_code      = 3'b101;   // Set Bus-Speed;
    this.mo_svt_i2c_system_env_cfg[1].slave_cfg[0].slave_address     = 10'h5a;
    this.mo_svt_i2c_system_env_cfg[1].slave_cfg[0].enable_10bit_addr = 1;
    this.mo_svt_i2c_system_env_cfg[1].slave_cfg[0].slave_type        = `SVT_I2C_GENERIC;

    // ------------------- I2C_2 configuration ------------------------ //
    this.mo_svt_i2c_system_env_cfg[2].num_masters     = 1;
    this.mo_svt_i2c_system_env_cfg[2].num_slaves      = 1;
    this.mo_svt_i2c_system_env_cfg[2].create_sub_cfgs(1, 1);
    // `SVT_I2C_STANDARD_MODE   : 100K
    // `SVT_I2C_FAST_MODE       : 400K
    // `SVT_HIGHSPEED_MODE      : 1M
    // `SVT_I2C_FAST_MODE_PLUS  : 4M
    this.mo_svt_i2c_system_env_cfg[2].set_bus_speed(`SVT_I2C_STANDARD_MODE);
    this.mo_svt_i2c_system_env_cfg[2].slave_cfg[0].is_active         = 1;
    this.mo_svt_i2c_system_env_cfg[2].master_cfg[0].is_active        = 1;
    this.mo_svt_i2c_system_env_cfg[2].master_cfg[0].master_code      = 3'b101;   // Set Bus-Speed;
    this.mo_svt_i2c_system_env_cfg[2].slave_cfg[0].slave_address     = 10'h5a;
    this.mo_svt_i2c_system_env_cfg[2].slave_cfg[0].enable_10bit_addr = 1;
    this.mo_svt_i2c_system_env_cfg[2].slave_cfg[0].slave_type        = `SVT_I2C_GENERIC;

    // ------------------- I2C_3 configuration ------------------------ //
    this.mo_svt_i2c_system_env_cfg[3].num_masters     = 1;
    this.mo_svt_i2c_system_env_cfg[3].num_slaves      = 1;
    this.mo_svt_i2c_system_env_cfg[3].create_sub_cfgs(1, 1);
    // `SVT_I2C_STANDARD_MODE   : 100K
    // `SVT_I2C_FAST_MODE       : 400K
    // `SVT_HIGHSPEED_MODE      : 1M
    // `SVT_I2C_FAST_MODE_PLUS  : 4M
    this.mo_svt_i2c_system_env_cfg[3].set_bus_speed(`SVT_I2C_STANDARD_MODE);
    this.mo_svt_i2c_system_env_cfg[3].slave_cfg[0].is_active         = 1;
    this.mo_svt_i2c_system_env_cfg[3].master_cfg[0].is_active        = 1;
    this.mo_svt_i2c_system_env_cfg[3].master_cfg[0].master_code      = 3'b101;   // Set Bus-Speed;
    this.mo_svt_i2c_system_env_cfg[3].slave_cfg[0].slave_address     = 10'h5a;
    this.mo_svt_i2c_system_env_cfg[3].slave_cfg[0].enable_10bit_addr = 1;
    this.mo_svt_i2c_system_env_cfg[3].slave_cfg[0].slave_type        = `SVT_I2C_GENERIC;

    // ------------------- I2C_4 configuration ------------------------ //
    this.mo_svt_i2c_system_env_cfg[4].num_masters     = 1;
    this.mo_svt_i2c_system_env_cfg[4].num_slaves      = 1;
    this.mo_svt_i2c_system_env_cfg[4].create_sub_cfgs(1, 1);
    // `SVT_I2C_STANDARD_MODE   : 100K
    // `SVT_I2C_FAST_MODE       : 400K
    // `SVT_HIGHSPEED_MODE      : 1M
    // `SVT_I2C_FAST_MODE_PLUS  : 4M
    this.mo_svt_i2c_system_env_cfg[4].set_bus_speed(`SVT_I2C_STANDARD_MODE);
    this.mo_svt_i2c_system_env_cfg[4].slave_cfg[0].is_active         = 1;
    this.mo_svt_i2c_system_env_cfg[4].master_cfg[0].is_active        = 1;
    this.mo_svt_i2c_system_env_cfg[4].master_cfg[0].master_code      = 3'b101;   // Set Bus-Speed;
    this.mo_svt_i2c_system_env_cfg[4].slave_cfg[0].slave_address     = 10'h5a;
    this.mo_svt_i2c_system_env_cfg[4].slave_cfg[0].enable_10bit_addr = 1;
    this.mo_svt_i2c_system_env_cfg[4].slave_cfg[0].slave_type        = `SVT_I2C_GENERIC;

`endif // I2C_TEST_ON
endfunction : modify_env_cfg

`endif // ENV_CFG__SV
