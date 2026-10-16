// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: device_expected_payload_callbacks.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef DEVICE_EXPECTED_PAYLOAD_CALLBACKS__SV
`define DEVICE_EXPECTED_PAYLOAD_CALLBACKS__SV

typedef class usb_env;

class device_expected_payload_callbacks extends svt_usb_protocol_callbacks;

    usb_env mo_env;

    extern          function        new                         (string name = "device_expected_payload_callbacks", usb_env temp_env);
    extern  virtual function void   pre_transfer_out_port_put   (svt_usb_protocol component, int chan_id, ref svt_usb_transfer transfer, ref bit drop);

endclass : device_expected_payload_callbacks

function device_expected_payload_callbacks::new(string name = "device_expected_payload_callbacks", usb_env temp_env);
    super.new(name);
    this.mo_env = temp_env;

endfunction : new

function void device_expected_payload_callbacks::pre_transfer_out_port_put(svt_usb_protocol component, int chan_id, ref svt_usb_transfer transfer, ref bit drop);
    // Setup a local handle so that we can send this off to a 'zero time' task and otherwise let
    // the transactor move forward and forget all about it...
    `SVT_XVM(object) xfer = null;
    svt_usb_transfer host_xfer;

    if(transfer.xfer_type == svt_usb_transfer::ISOCHRONOUS_OUT_TRANSFER)
    begin
        xfer = this.mo_env.mq_iso_out_xfer_q.pop_front();
    end else begin
        if(transfer.xfer_type == svt_usb_transfer::ISOCHRONOUS_IN_TRANSFER)
        begin
            xfer = this.mo_env.mq_iso_in_xfer_q.pop_front();
        end
        if(xfer != null && $cast(host_xfer,xfer)) begin
            transfer.payload_intended_byte_count = host_xfer.payload_intended_byte_count;
            transfer.aligned_transfer_ends_with_zero_length = host_xfer.aligned_transfer_ends_with_zero_length;
            transfer.first_isoc_transaction = host_xfer.first_isoc_transaction;
            transfer.last_isoc_transaction  = host_xfer.last_isoc_transaction;
        end
    end
endfunction : pre_transfer_out_port_put

`endif // HOST_EXPECTED_PAYLOAD_CALLBACKS__SV
