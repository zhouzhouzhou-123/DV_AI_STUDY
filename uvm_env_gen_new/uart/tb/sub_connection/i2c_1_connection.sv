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

// ------------------ I2C_1 interface connect ---------------------- //
`ifdef I2C_1_ON
    reg     i2c_clk_1;
    reg     i2c_rst_1;
    // wand : this signal is 0, if any one input is 0
    wand    scl_1;
    wand    sda_1;
    wand    smbalrt_1;

    // i2c interface
    svt_i2c_if      mo_svt_i2c_if_1(i2c_clk_1);
    // intantiate I2C wrapper
    svt_i2c_master_wrapper  i2c_master_1(mo_svt_i2c_if_1);
    svt_i2c_slave_wrapper   i2c_slave_1(mo_svt_i2c_if_1);

    // pull up I2C signals
    pullup(scl_1);
    pullup(sda_1);
    pullup(smbalrt_1);

    // I2C CLOCK
    initial
    begin
        i2c_clk_1 = 0;
        while(1)
        begin
            // VIP need 1G:500
            #500ps;
            i2c_clk_1 = ~i2c_clk_1;
        end
    end

    // I2C reset to avoid X-status
    initial
    begin
        i2c_rst_1 = 1'b0;
        repeat(200) @(posedge i2c_clk_1);
        i2c_rst_1 = 1'b1;
        repeat(20) @(posedge i2c_clk_1);
        i2c_rst_1 = 1'b0;
    end
    assign mo_svt_i2c_if_1.RST    = i2c_rst_1;

    // tran gate : transfer in two direction
    tran tran_if_1_scl      (scl_1,     mo_svt_i2c_if_1.SCL);
    tran tran_if_1_sda      (sda_1,     mo_svt_i2c_if_1.SDA);
    tran tran_if_1_alert    (smbalrt_1, mo_svt_i2c_if_1.SMBALRT);

    initial
    begin
        uvm_config_db#(virtual svt_i2c_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_svt_i2c_system_env[1].*", "i2c_vif", mo_svt_i2c_if_1);
    end

    `ifdef I2C1_PA2_PA5
        tran i2c_1_pa2   (scl_1,   PA[2]);
        tran i2c_1_pa5   (sda_1,   PA[5]);
    `endif

`endif // I2C_1_ON

`endif // I2C_TEST_ON

