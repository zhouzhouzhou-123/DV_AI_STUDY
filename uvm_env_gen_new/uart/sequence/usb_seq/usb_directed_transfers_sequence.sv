// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_directed_transfers_sequence.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------



/**
 * Abstract:
 * This file defines a class that the testbench uses to provides default transfer
 * sequence which is initiated on via xfer sequencer.
 * This class defines a sequence in which it  generates directed transfer objects.
 */

`ifndef GUARD_USB_DIRECTED_TRANSFERS_SEQUENCE_SV
`define GUARD_USB_DIRECTED_TRANSFERS_SEQUENCE_SV

/**
 * This class extends #uvm_sequence class to create a
 * user defined sequence.
 */
class usb_directed_transfers_sequence extends uvm_sequence;

    /** Parameter that controls the number of transfers that will be generated */
    rand int unsigned sequence_length = 10;

    /** UVM Object Utility macro */
    `uvm_object_utils_begin(usb_directed_transfers_sequence)
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

    extern          function    new     (string name = "usb_directed_transfers_sequence");
    extern  virtual task        body    ();

endclass : usb_directed_transfers_sequence

function usb_directed_transfers_sequence::new(string name = "usb_directed_transfers_sequence");
    super.new(name);
endfunction : new

task usb_directed_transfers_sequence::body();
    /**
     * Following variable is required to get the status of get method
     */
    bit status;

    /**
     * Declare instance svt_usb_configuration and svt_configuration objects
     * to get the configuration.
     */
    svt_configuration get_cfg;
    svt_usb_configuration cfg;

    /**
     * Declare instances of svt_usb_transfer class to
     * create directed transactions.
     * This test performs one BULK_OUT,BULK_IN,CONTROL_OUT
     * CONTROL_IN and CONTROL_OUT without data stage transfer.
     */
    svt_usb_transfer usb_xfer[5];

	`uvm_info("", "Entered ...", UVM_LOW)

    status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"), UVM_LOW);
    /**
     * Get the configuration from parent sequencer.
     */
    p_sequencer.get_cfg(get_cfg);

    if(!$cast(cfg, get_cfg))
    begin
        `uvm_fatal("body", "Unable to $cast the configuration to a svt_usb_configuration class");
    end
    /**
     * Only an example subset of the svt_usb_transfer class members are
     * assigned values here. For full set of transfer class members and their complete
     * description refer "Synopsys VIP for USB 3.0 SystemVerilog/UVM User Manual"
     */
    for(int i = 0; i < sequence_length; i++)
    begin
        /**
         * Create instance of svt_usb_transfer class.
         */
        `uvm_create(usb_xfer[0])
        usb_xfer[0].cfg  = cfg;
        /**
         * 'user defined algorithm' ensures that payload.data[] array
         * is created, allocated and filled with random data upon
         * randomization of the transfer object.
         */
        usb_xfer[0].payload.USER_DEFINED_ALGORITHM_wt   = 1;
        usb_xfer[0].payload.TWO_SEED_BASED_ALGORITHM_wt = 0;
        /**
         * To have faster randomization, set the indices of device, endpoint, and ustream index
         */
        /**
         * NOTE:  fix_anchors takes indices, not address and ep_number values.
         * In this example, though bulk OUT endpoint number is 1, the endpoint array index is 2.
         */
        usb_xfer[0].fix_anchors(0,2,0);
        status = usb_xfer[0].randomize() with {
            /* Setting payload_inteded_byte_count is <= 2 times device endpoint's max_packet_size.*/
            payload_intended_byte_count   <= 2*cfg.remote_device_cfg[0].endpoint_cfg[1].max_packet_size;
        };

        if(!status)
        begin
            `uvm_fatal("body","usb_xfer[0] Randomization failed!!!")
        end

        /**
         * Set the second transfer ( BULK IN )
         */

        /**
         * Create instance of svt_usb_transfer class.
         */
        `uvm_create(usb_xfer[1])
        usb_xfer[1].cfg  = cfg;

        /**
         * To have faster randomization, set the indices of device, endpoint, and ustream index
         */
        usb_xfer[1].fix_anchors(0,1,0);
        status = usb_xfer[1].randomize();
        if(!status)
            `uvm_fatal("body","usb_xfer[1] Randomization failed!!!")
        /**
         * Set next transfer ( CONTROL OUT )
         */
        `uvm_create(usb_xfer[2])
        usb_xfer[2].cfg  = cfg;
        /**
         * 'user defined algorithm' ensures that payload.data[] array
         * is created, allocated and filled with random data upon
         * randomization of the transfer object.
         */
        usb_xfer[2].payload.USER_DEFINED_ALGORITHM_wt   = 1;
        usb_xfer[2].payload.TWO_SEED_BASED_ALGORITHM_wt = 0;

        /**
         * To have faster randomization, set the indices of device, endpoint, and ustream index
         */
        usb_xfer[2].fix_anchors(0,0,0);
        status = usb_xfer[2].randomize() with {
            setup_data_bmrequesttype_dir           == svt_usb_types::HOST_TO_DEVICE;
            setup_data_bmrequesttype_type          == svt_usb_types::STANDARD;
            setup_data_bmrequesttype_recipient     == svt_usb_types::BMREQ_DEVICE;
            setup_data_brequest                    == svt_usb_types::SET_DESCRIPTOR;
            if(!(setup_data_w_value[15:8] == 2 || setup_data_w_value[15:8] == 3))
              setup_data_w_value[7:0]              == 8'h00;
            else
              setup_data_w_value[7:0]              == 8'h78;
            setup_data_w_index                     == 0;
            setup_data_w_length                    == 4;
        };
        if(!status)
           `uvm_fatal("","usb_xfer[2] Randomization failed!!!")

        /**
         * Set Payload data bytes that will be sent by Host during Data Stage
         */
        usb_xfer[2].payload.data[0]    = 8'h11;
        usb_xfer[2].payload.data[1]    = 8'h22;
        usb_xfer[2].payload.data[2]    = 8'h33;
        usb_xfer[2].payload.data[3]    = 8'h44;

        /**
         * Set next transfer ( CONTROL IN )
         */
        `uvm_create(usb_xfer[3])
        usb_xfer[3].cfg  = cfg;

        /**
         * To have faster randomization, set the indices of device, endpoint, and ustream index
         */
        usb_xfer[3].fix_anchors(0,0,0);
        status = usb_xfer[3].randomize() with {
            setup_data_bmrequesttype_dir           == svt_usb_types::DEVICE_TO_HOST;
            setup_data_bmrequesttype_type          == svt_usb_types::STANDARD;
            setup_data_bmrequesttype_recipient     == svt_usb_types::BMREQ_DEVICE;
            setup_data_brequest                    == svt_usb_types::GET_DESCRIPTOR;
            if(!(setup_data_w_value[15:8] == 2 || setup_data_w_value[15:8] == 3))
              setup_data_w_value[7:0]              == 8'h00;
            else
              setup_data_w_value[7:0]              == 8'h85;
            setup_data_w_index                     == 0;
            if(usb_xfer[2].device_connected_bus_speed == svt_usb_types::LS)
              setup_data_w_length                    == 18;
            else
              setup_data_w_length                    == 160;
        };
        if(!status)
            `uvm_fatal("","usb_xfer[3] Randomization failed!!!")

        /**
         * Set next transfer ( No-Data CONTROL )
         * NOTE: Since Device VIP does not interpret control transfers,
         * this SET_ADDRESS does not change Device VIP's device address.
         */
        `uvm_create(usb_xfer[4])
        usb_xfer[4].cfg  = cfg;
        /**
         * To have faster randomization, set the indices of device, endpoint, and ustream index
         */
        usb_xfer[4].fix_anchors(0,0,0);
        status = usb_xfer[4].randomize() with {
            setup_data_bmrequesttype_dir           == svt_usb_types::HOST_TO_DEVICE;
            setup_data_bmrequesttype_type          == svt_usb_types::STANDARD;
            setup_data_bmrequesttype_recipient     == svt_usb_types::BMREQ_DEVICE;
            setup_data_brequest                    == svt_usb_types::SET_ADDRESS;
            setup_data_w_value                      == 11;
            setup_data_w_index                      == 0;
            setup_data_w_length                     == 0;
        };
        if(!status)
           `uvm_fatal("","usb_xfer[4] Randomization failed!!!")

        foreach (usb_xfer[i]) begin
         `uvm_send(usb_xfer[i])
        end
    end
    `uvm_info("", "Exiting...", UVM_LOW)
endtask: body

`endif // GUARD_USB_DIRECTED_TRANSFERS_SEQUENCE_SV
