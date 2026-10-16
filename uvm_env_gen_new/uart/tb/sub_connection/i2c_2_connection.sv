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

// ------------------ I2C_2 interface connect ---------------------- //
`ifdef I2C_2_ON
    reg     i2c_clk_2;
    reg     i2c_rst_2;
    // wand : this signal is 0, if any one input is 0
    wand    scl_2;
    wand    sda_2;
    wand    smbalrt_2;

    // i2c interface
    svt_i2c_if      mo_svt_i2c_if_2(i2c_clk_2);
    // intantiate I2C wrapper
    svt_i2c_master_wrapper  i2c_master_2(mo_svt_i2c_if_2);
    svt_i2c_slave_wrapper   i2c_slave_2(mo_svt_i2c_if_2);

    // pull up I2C signals
    pullup(scl_2);
    pullup(sda_2);
    pullup(smbalrt_2);

    // I2C CLOCK
    initial
    begin
        i2c_clk_2 = 0;
        while(1)
        begin
            // VIP need 1G:500
            #500ps;
            i2c_clk_2 = ~i2c_clk_2;
        end
    end

    // I2C reset to avoid X-status
    initial
    begin
        i2c_rst_2 = 1'b0;
        repeat(200) @(posedge i2c_clk_2);
        i2c_rst_2 = 1'b1;
        repeat(20) @(posedge i2c_clk_2);
        i2c_rst_2 = 1'b0;
    end
    assign mo_svt_i2c_if_2.RST    = i2c_rst_2;

    // tran gate : transfer in two direction
    tran tran_if_2_scl      (scl_2,     mo_svt_i2c_if_2.SCL);
    tran tran_if_2_sda      (sda_2,     mo_svt_i2c_if_2.SDA);
    tran tran_if_2_alert    (smbalrt_2, mo_svt_i2c_if_2.SMBALRT);

    initial
    begin
        uvm_config_db#(virtual svt_i2c_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_svt_i2c_system_env[2].*", "i2c_vif", mo_svt_i2c_if_2);
    end

    `ifdef I2C2_PA2_PA5
        tran i2c_2_pa2   (scl_2,   PA[2]);
        tran i2c_2_pa5   (sda_2,   PA[5]);
    `endif

`endif // I2C_2_ON

`endif // I2C_TEST_ON

