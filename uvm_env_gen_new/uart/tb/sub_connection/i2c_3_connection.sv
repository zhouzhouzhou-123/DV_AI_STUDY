//------------------------------------------------------------------------
// FILE NAME      : i2c_connection.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-17 15:50:40
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifdef I2C_TEST_ON

// ------------------ I2C_3 interface connect ---------------------- //
`ifdef I2C_3_ON
    reg     i2c_clk_3;
    reg     i2c_rst_3;
    // wand : this signal is 0, if any one input is 0
    wand    scl_3;
    wand    sda_3;
    wand    smbalrt_3;

    // i2c interface
    svt_i2c_if      mo_svt_i2c_if_3(i2c_clk_3);
    // intantiate I2C wrapper
    svt_i2c_master_wrapper  i2c_master_3(mo_svt_i2c_if_3);
    svt_i2c_slave_wrapper   i2c_slave_3(mo_svt_i2c_if_3);

    // pull up I2C signals
    pullup(scl_3);
    pullup(sda_3);
    pullup(smbalrt_3);

    // I2C CLOCK
    initial
    begin
        i2c_clk_3 = 0;
        while(1)
        begin
            // VIP need 1G:500
            #500ps;
            i2c_clk_3 = ~i2c_clk_3;
        end
    end

    // I2C reset to avoid X-status
    initial
    begin
        i2c_rst_3 = 1'b0;
        repeat(200) @(posedge i2c_clk_3);
        i2c_rst_3 = 1'b1;
        repeat(20) @(posedge i2c_clk_3);
        i2c_rst_3 = 1'b0;
    end
    assign mo_svt_i2c_if_3.RST    = i2c_rst_3;

    // tran gate : transfer in two direction
    tran tran_if_3_scl      (scl_3,     mo_svt_i2c_if_3.SCL);
    tran tran_if_3_sda      (sda_3,     mo_svt_i2c_if_3.SDA);
    tran tran_if_3_alert    (smbalrt_3, mo_svt_i2c_if_3.SMBALRT);

    initial
    begin
        uvm_config_db#(virtual svt_i2c_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_svt_i2c_system_env[3].*", "i2c_vif", mo_svt_i2c_if_3);
    end

    `ifdef I2C3_PA2_PA5
        tran i2c_3_pa2   (scl_3,   PA[2]);
        tran i2c_3_pa5   (sda_3,   PA[5]);
    `endif

`endif // I2C_3_ON

`endif // I2C_TEST_ON

