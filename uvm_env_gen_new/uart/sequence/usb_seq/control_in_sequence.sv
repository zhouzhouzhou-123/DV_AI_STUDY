// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: control_in_sequence.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef CONTROL_IN_SEQUENCE__SV
`define CONTROL_IN_SEQUENCE__SV

class control_in_sequence extends uvm_sequence;

    /** Parameter that controls the number of transfers that will be generated */
    rand int unsigned sequence_length = 10;

    /** UVM Object Utility macro */
    `uvm_object_utils_begin(control_in_sequence)
       `uvm_field_int(sequence_length,UVM_ALL_ON|UVM_DEC)
    `uvm_object_utils_end

    /**
     * Required to allow new_item() to have access to the parent sequencer.
     */

    `uvm_declare_p_sequencer(svt_usb_transfer_sequencer)

    /** Constrain the sequence length to a reasonable value */
    constraint reasonable_sequence_length {
      sequence_length <= 100;
    }

    extern          function    new     (string name = "control_in_sequence");
    extern  virtual task        body    ();
endclass: control_in_sequence

function control_in_sequence::new (string name = "control_in_sequence");
    super.new(name);
endfunction : new

task control_in_sequence::body();
    /**
     * Following variable is required to get the status of get method
     */
    bit status;

    /**
     * Declare instance svt_usb_configuration and svt_configuration objects
     * to get the configuration.
     */
    svt_configuration get_cfg;
    svt_usb_configuration cfg;

    /**
     * Declare instances of svt_usb_transfer class to
     * create directed transactions.
     * This test performs one BULK_OUT,BULK_IN,CONTROL_OUT
     * CONTROL_IN and CONTROL_OUT without data stage transfer.
     */
    svt_usb_transfer usb_xfer;

	`uvm_info("", "Entered ...", UVM_LOW)

    status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"), UVM_LOW);
    /**
     * Get the configuration from parent sequencer.
     */
    p_sequencer.get_cfg(get_cfg);

    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("", "Unable to $cast the configuration to a svt_usb_configuration class");
    end
    /**
     * Only an example subset of the svt_usb_transfer class members are
     * assigned values here. For full set of transfer class members and their complete
     * description refer "Synopsys VIP for USB 3.0 SystemVerilog/UVM User Manual"
     */

    /**
     * Create instance of svt_usb_transfer class.
     */

     /**
      * Set next transfer ( CONTROL IN )
      */
    `uvm_create(usb_xfer)
    usb_xfer.cfg  = cfg;

    /**
     * To have faster randomization, set the indices of device, endpoint, and ustream index
     */
    usb_xfer.fix_anchors(0,0,0);
    status = usb_xfer.randomize() with {
        setup_data_bmrequesttype_dir            == svt_usb_types::DEVICE_TO_HOST;
        setup_data_bmrequesttype_type           == svt_usb_types::STANDARD;
        setup_data_bmrequesttype_recipient      == svt_usb_types::BMREQ_DEVICE;
        setup_data_brequest                     == svt_usb_types::GET_DESCRIPTOR;
        if(!(setup_data_w_value[15:8] == 2 || setup_data_w_value[15:8] == 3))
            setup_data_w_value[7:0]             == 8'h00;
        else
            setup_data_w_value[7:0]             == 8'h85;
        setup_data_w_index                      == 0;
        if(usb_xfer.device_connected_bus_speed == svt_usb_types::LS)
            setup_data_w_length                 == 18;
        else
            setup_data_w_length                 == 160;
    };

    if(!status)
    begin
        `uvm_fatal("","usb_xfer Randomization failed!!!")
    end

    `uvm_send(usb_xfer)

    get_response(rsp);

    `uvm_info("", "Exiting...", UVM_LOW)
endtask: body


`endif
