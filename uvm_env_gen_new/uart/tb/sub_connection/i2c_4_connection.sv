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

// ------------------ I2C_4 interface connect ---------------------- //
`ifdef I2C_4_ON
    reg     i2c_clk_4;
    reg     i2c_rst_4;
    // wand : this signal is 0, if any one input is 0
    wand    scl_4;
    wand    sda_4;
    wand    smbalrt_4;

    // i2c interface
    svt_i2c_if      mo_svt_i2c_if_4(i2c_clk_4);
    // intantiate I2C wrapper
    svt_i2c_master_wrapper  i2c_master_4(mo_svt_i2c_if_4);
    svt_i2c_slave_wrapper   i2c_slave_4(mo_svt_i2c_if_4);

    // pull up I2C signals
    pullup(scl_4);
    pullup(sda_4);
    pullup(smbalrt_4);

    // I2C CLOCK
    initial
    begin
        i2c_clk_4 = 0;
        while(1)
        begin
            // VIP need 1G:500
            #500ps;
            i2c_clk_4 = ~i2c_clk_4;
        end
    end

    // I2C reset to avoid X-status
    initial
    begin
        i2c_rst_4 = 1'b0;
        repeat(200) @(posedge i2c_clk_4);
        i2c_rst_4 = 1'b1;
        repeat(20) @(posedge i2c_clk_4);
        i2c_rst_4 = 1'b0;
    end
    assign mo_svt_i2c_if_4.RST    = i2c_rst_4;

    // tran gate : transfer in two direction
    tran tran_if_4_scl      (scl_4,     mo_svt_i2c_if_4.SCL);
    tran tran_if_4_sda      (sda_4,     mo_svt_i2c_if_4.SDA);
    tran tran_if_4_alert    (smbalrt_4, mo_svt_i2c_if_4.SMBALRT);

    initial
    begin
        uvm_config_db#(virtual svt_i2c_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_svt_i2c_system_env[4].*", "i2c_vif", mo_svt_i2c_if_4);
    end

    `ifdef I2C4_PA2_PA5
        tran i2c_4_pa2   (scl_4,   PA[2]);
        tran i2c_4_pa5   (sda_4,   PA[5]);
    `endif

`endif // I2C_4_ON

`endif // I2C_TEST_ON

