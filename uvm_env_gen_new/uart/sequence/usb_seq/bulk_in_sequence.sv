// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: bulk_in_sequence.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef BULK_IN_SEQUENCE__SV
`define BULK_IN_SEQUENCE__SV

class bulk_in_sequence extends uvm_sequence;
    int     endpoint_index = 1;

    logic [7:0] data_temp[];

    /** Parameter that controls the number of transfers that will be generated */
    rand int unsigned sequence_length = 10;

    /** UVM Object Utility macro */
    `uvm_object_utils_begin(bulk_in_sequence)
        `uvm_field_int(sequence_length,UVM_ALL_ON|UVM_DEC)
    `uvm_object_utils_end

    // Required to allow new_item() to have access to the parent sequencer.

    `uvm_declare_p_sequencer(svt_usb_transfer_sequencer)

    /** Constrain the sequence length to a reasonable value */
    constraint reasonable_sequence_length {
        sequence_length <= 100;
    }

    extern          function    new     (string name = "bulk_in_sequence");
    extern  virtual task        body    ();
endclass: bulk_in_sequence

function bulk_in_sequence::new (string name = "bulk_in_sequence");
    super.new(name);
endfunction : new

task bulk_in_sequence::body();
    // Following variable is required to get the status of get method
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
       * Set next transfer ( BULK IN )
       */
      `uvm_create(usb_xfer)
      usb_xfer.cfg  = cfg;


    // To have faster randomization, set the indices of device, endpoint, and ustream index
    usb_xfer.fix_anchors(0,this.endpoint_index,0);
    status = usb_xfer.randomize();

    if(!status)
        `uvm_fatal("","usb_xfer Randomization failed!!!")

    usb_xfer.print();
    `uvm_send(usb_xfer)
    get_response(rsp);
    data_temp = new[usb_xfer.payload.data.size()];
    data_temp = usb_xfer.payload.data;
    `uvm_info("", "Exiting...", UVM_LOW)
endtask: body

`endif
