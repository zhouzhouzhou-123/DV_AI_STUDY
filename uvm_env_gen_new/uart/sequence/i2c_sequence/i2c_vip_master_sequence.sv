//------------------------------------------------------------------------
// FILE NAME      : i2c_vip_master_sequence.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 14:59:34
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef I2C_VIP_MASTER_SEQUENCE__SV
`define I2C_VIP_MASTER_SEQUENCE__SV

class i2c_vip_master_sequence extends uvm_sequence #(svt_i2c_master_transaction);
    rand    bit [9:0]   slave_addr      = `SVT_I2C_SLAVE0_ADDRESS;
    rand    int         is_10bit        = 0;
    rand    int         i2c_command     = `SVT_I2C_WRITE;
    rand    int         data_size       = 8;
    rand    bit [7:0]   tx_data[$];
    rand    bit [7:0]   rx_data[$];

    // i2c configuration handler
    svt_i2c_configuration   mo_i2c_cfg;

    `uvm_object_utils_begin(i2c_vip_master_sequence)
        `uvm_field_int(slave_addr, UVM_ALL_ON)
        `uvm_field_int(is_10bit, UVM_ALL_ON)
        `uvm_field_int(i2c_command, UVM_ALL_ON)
        `uvm_field_int(data_size, UVM_ALL_ON)
        `uvm_field_queue_int(tx_data, UVM_ALL_ON)
        `uvm_field_object(mo_i2c_cfg, UVM_ALL_ON)
    `uvm_object_utils_end

    `uvm_declare_p_sequencer(svt_i2c_master_transaction_sequencer)

    extern  function    new             (string name = "i2c_vip_master_sequence");
    extern  function    config_sequence (bit [9:0] p_slaver_addr, bit p_is_10bit=0, int p_i2c_command, int p_data_size=8, bit[7:0] p_tx_data[$]);
    extern  task        body            ();

endclass : i2c_vip_master_sequence

function i2c_vip_master_sequence::new(string name="i2c_vip_master_sequence");
    super.new(name);
endfunction

function i2c_vip_master_sequence::config_sequence(bit [9:0] p_slaver_addr, bit p_is_10bit=0, int p_i2c_command, int p_data_size=8, bit[7:0] p_tx_data[$]);
    this.slave_addr     = p_slaver_addr;
    this.is_10bit       = p_is_10bit;
    this.i2c_command    = p_i2c_command;
    this.data_size      = p_data_size;
    this.tx_data        = p_tx_data;
endfunction : config_sequence

task i2c_vip_master_sequence::body();
    svt_configuration get_cfg;

    this.p_sequencer.get_cfg(get_cfg);
    if(!$cast(mo_i2c_cfg, get_cfg))
    begin
        `uvm_fatal("", "Unable to $cast the configuration to a svt_i2c_configuration class");
    end

    `uvm_create(req)
    req.reasonable_data.constraint_mode(0);
    req.reasonable_addr.constraint_mode(0);
    req.reasonable_sr_or_p_gen.constraint_mode(0);
    req.reasonable_addr_10bit.constraint_mode(0);

    // --------------------- i2c read ----------------------- //
    if(this.i2c_command == `SVT_I2C_READ)
    begin
        `uvm_rand_send_with (req,
        {
            req.addr                == slave_addr;
            req.cmd                 == `SVT_I2C_READ;
            req.data.size()         == data_size;
            req.sr_or_p_gen         == 0;
            req.send_start_byte     == 0;
            req.addr_10bit          == is_10bit;
        } )
        if(this.mo_i2c_cfg.enable_put_response == 0)
        begin
            return;
        end
        // Wait for the read transaction to complete
        get_response(rsp);
        foreach(rsp.data[index])
        begin
            this.rx_data.push_back(rsp.data[index]);
        end
        // this.rx_data=rsp.data;
        // `uvm_info("READ", $sformatf("addr:0x%x, data:0x%x", read_addr, rx_data), UVM_NONE);
        return;
    end

    // --------------------- i2c write ----------------------- //
    if(this.i2c_command == `SVT_I2C_WRITE)
    begin
        `uvm_rand_send_with(req,
        {
            req.addr                == slave_addr;
            req.cmd                 == `SVT_I2C_WRITE;
            req.data.size()         == data_size;
            req.sr_or_p_gen         == 0;
            req.send_start_byte     == 0;
            req.addr_10bit          == is_10bit;
            foreach(req.data[index])
            {
                req.data[index] == tx_data[index];
            }
        } )
        if(this.mo_i2c_cfg.enable_put_response == 1)
        begin
            get_response(rsp);
            // `uvm_info("WRITE", $sformatf("addr:0x%x, data:0x%x", write_addr, tx_data), UVM_NONE);
        end
        return;
    end
    // --------------------- i2c general call ----------------------- //
    if(this.i2c_command == `SVT_I2C_GEN_CALL)
    begin
        `uvm_rand_send_with(req,
        {
            req.cmd                 == `SVT_I2C_GEN_CALL;
            req.data.size()         == data_size;
            req.sr_or_p_gen         == 0;
            req.sec_byte_gen_call   == 8'h4;
        } )
        if(this.mo_i2c_cfg.enable_put_response == 1)
        begin
            get_response(rsp);
            // `uvm_info("WRITE", $sformatf("addr:0x%x, data:0x%x", write_addr, tx_data), UVM_NONE);
        end
        return;
    end

    `uvm_error("",$sformatf("Un-supported i2c command : 'h%0h", this.i2c_command))
endtask: body

`endif // I2C_VIP_MASTER_SEQUENCE__SV

