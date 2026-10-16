//------------------------------------------------------------------------
// FILE NAME      : i2c_vip_slave_sequence.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 14:59:34
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef I2C_VIP_SLAVE_SEQUENCE__SV
`define I2C_VIP_SLAVE_SEQUENCE__SV

class i2c_vip_slave_sequence extends uvm_sequence #(svt_i2c_slave_transaction);

    rand int unsigned sequence_length =1;

    bit [7:0]   rx_data[$];
    bit [7:0]   tx_data[$];

    `uvm_object_utils(i2c_vip_slave_sequence)
    `uvm_declare_p_sequencer(svt_i2c_slave_transaction_sequencer)

    /** I2C configuration handle */
    svt_i2c_configuration i2c_cfg;

    extern  function    new             (string name = "i2c_vip_slave_sequence");
    extern  function    config_sequence (bit[7:0] p_tx_data[$]);
    extern  task        body            ();

endclass : i2c_vip_slave_sequence

function i2c_vip_slave_sequence::new(string name="i2c_vip_slave_sequence");
    super.new(name);
endfunction

function i2c_vip_slave_sequence::config_sequence(bit[7:0] p_tx_data[$]);
    this.tx_data = p_tx_data;
endfunction : config_sequence

task i2c_vip_slave_sequence::body();
    svt_configuration cfg;

    /** Get the SVT configuration */
    p_sequencer.get_cfg(cfg);

    /** Cast the SVT configuration handle on the local I2C configuration handle */
    if(!$cast(i2c_cfg, cfg))
    begin
        `uvm_fatal("", "Unable to cast the configuration to a svt_i2c_configuration class");
    end

    `uvm_create(req);
    `uvm_rand_send_with(req,
    {
        foreach(tx_data[index])
        {
            req.data[index] == tx_data[index];
        }
    })
    /**
     * Call get_response only if configuration attribute,
     * enable_put_response is set 1.
     */
    if(i2c_cfg.enable_put_response == 1)
    begin
        get_response(rsp);
        foreach(rsp.data[index])
        begin
            rx_data.push_back(rsp.data[index]);
        end
    end

endtask : body

`endif // I2C_VIP_SLAVE_SEQUENCE__SV
