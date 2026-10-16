// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_device_response_payload_callbacks.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_DEVICE_RESPONSE_PAYLOAD_CALLBACKS__SV
`define USB_DEVICE_RESPONSE_PAYLOAD_CALLBACKS__SV

class usb_device_response_payload_callbacks extends svt_usb_protocol_callbacks;
    /**
     * This callback is used to override the default response of Device VIP to all types of
     * received transfers from Host. Response attributes include, but not limited to, payload
     * count, payload bytes, end with or without zero length etc.
     *
     * In this basic example, this callback is used in a limited and specific way. It
     * is used to override the default data size (payload count) response to Bulk IN
     * transfer only. Device VIP use this count in sending Data Packets to Host.
     * Note: This demonstrated usage may need to be updated for other
     * transfer types viz. ISOC_IN, INTR_IN. For CONTROL_IN host will set the
     * required payload to be received.
     *
     * In this illustration, a random value within valid range is picked for the sake of
     * convenience. In actual DUT tests, any value can be chosen as per DUT (Host) needs.
    */

    extern  virtual function    void    pre_transfer_out_port_put(svt_usb_protocol component, int chan_id, ref svt_usb_transfer transfer, ref bit drop);
    extern  virtual function    void    randomized_transfer_complete_response (svt_usb_protocol component, svt_usb_transfer transfer);

endclass : usb_device_response_payload_callbacks

function void usb_device_response_payload_callbacks::pre_transfer_out_port_put(svt_usb_protocol component, int chan_id, ref svt_usb_transfer transfer, ref bit drop);
    /**
     * Modifying payload count for Bulk IN transfers only
     * max xfer payload = Bulk IN EP cfg's max_burst_size * max_packet_size
     * Using a smaller value as Maximum, to reduce simulation time
     * NOTE: value used must be good for both SS and 20, since this
     * callback is used in both SS and 20 tests.
    */
    if(transfer.get_xfer_type_val() == svt_usb_transfer::BULK_IN_TRANSFER || transfer.get_xfer_type_val() == svt_usb_transfer::INTERRUPT_IN_TRANSFER)
    begin
        /**
         * To reduce simulation time, Payload byte count assigned between 0 to 1024 for Bulk IN transfer.
         */
         /* Setting payload_inteded_byte_count to be 0 to 2 times the device endpoint's max_packet_size.
        */
        transfer.payload_intended_byte_count = $urandom_range(0,2*transfer.cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size);
        /**
         * 'user defined algorithm' ensures that payload.data[] array is created, allocated and
         *  filled with random data upon randomization of the transfer object.
        */
        transfer.payload.TWO_SEED_BASED_ALGORITHM_wt = 0;
        transfer.payload.USER_DEFINED_ALGORITHM_wt   = 1;
    end

    if(transfer.get_xfer_type_val() == svt_usb_transfer::CONTROL_TRANSFER  && transfer.get_setup_data_bmrequesttype_dir_val()== svt_usb_types::DEVICE_TO_HOST )
    begin
        /**
         * payload count is provided by Host as a part of transfer request, hence any change to payload count for control IN must be done in Host
        */
        /**
         * 'user defined algorithm' ensures that payload.data[] array is created, allocated and
         *  filled with random data upon randomization of the transfer object.
        */
        transfer.payload.TWO_SEED_BASED_ALGORITHM_wt = 0;
        transfer.payload.USER_DEFINED_ALGORITHM_wt   = 1;
    end
endfunction

function void usb_device_response_payload_callbacks::randomized_transfer_complete_response(svt_usb_protocol component, svt_usb_transfer transfer);
    if(transfer.get_xfer_type_val() == svt_usb_transfer::BULK_IN_TRANSFER || transfer.get_xfer_type_val() == svt_usb_transfer::INTERRUPT_IN_TRANSFER)
    begin
        /**
         * Override the random values, payload array, with user-defined values
        */
        foreach(transfer.payload.data[i])
        begin
            transfer.payload.data[i] = i;
        end    // if transfer == bulk IN
    end

    if(transfer.get_xfer_type_val() == svt_usb_transfer::CONTROL_TRANSFER && transfer.get_setup_data_bmrequesttype_dir_val()== svt_usb_types::DEVICE_TO_HOST)
    begin
        // Set Payload data bytes that will be sent by Host during Data Stage of Control IN Transfer
        foreach(transfer.payload.data[i])
        begin
            transfer.payload.data[i] = i;
        end
    end
endfunction


`endif // USB_DEVICE_RESPONSE_PAYLOAD_CALLBACKS__SV
