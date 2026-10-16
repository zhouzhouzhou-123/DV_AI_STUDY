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

// ------------------ I2C_0 interface connect ---------------------- //
`ifdef I2C_0_ON
    reg     i2c_clk_0;
    reg     i2c_rst_0;
    // wand : this signal is 0, if any one input is 0
    wand    scl_0;
    wand    sda_0;
    wand    smbalrt_0;

    // i2c interface
    svt_i2c_if      mo_svt_i2c_if_0(i2c_clk_0);
    // intantiate I2C wrapper
    svt_i2c_master_wrapper  i2c_master_0(mo_svt_i2c_if_0);
    svt_i2c_slave_wrapper   i2c_slave_0(mo_svt_i2c_if_0);

    // pull up I2C signals
    pullup(scl_0);
    pullup(sda_0);
    pullup(smbalrt_0);

    // I2C CLOCK
    initial
    begin
        i2c_clk_0 = 0;
        while(1)
        begin
            // VIP need 1G:500
            #500ps;
            i2c_clk_0 = ~i2c_clk_0;
        end
    end

    // I2C reset to avoid X-status
    initial
    begin
        i2c_rst_0 = 1'b0;
        repeat(200) @(posedge i2c_clk_0);
        i2c_rst_0 = 1'b1;
        repeat(20) @(posedge i2c_clk_0);
        i2c_rst_0 = 1'b0;
    end
    assign mo_svt_i2c_if_0.RST    = i2c_rst_0;

    // tran gate : transfer in two direction
    tran tran_if_0_scl      (scl_0,     mo_svt_i2c_if_0.SCL);
    tran tran_if_0_sda      (sda_0,     mo_svt_i2c_if_0.SDA);
    tran tran_if_0_alert    (smbalrt_0, mo_svt_i2c_if_0.SMBALRT);

    initial
    begin
        uvm_config_db#(virtual svt_i2c_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_svt_i2c_system_env[0].*", "i2c_vif", mo_svt_i2c_if_0);
    end

    `ifdef I2C0_PA2_PA5
        tran i2c_0_pa2   (scl_0,   PA[2]);
        tran i2c_0_pa5   (sda_0,   PA[5]);
    `endif

`endif // I2C_0_ON

`endif // I2C_TEST_ON

