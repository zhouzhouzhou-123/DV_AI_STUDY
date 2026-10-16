// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: host_expected_payload_callbacks.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef HOST_EXPECTED_PAYLOAD_CALLBACKS__SV
`define HOST_EXPECTED_PAYLOAD_CALLBACKS__SV

typedef class usb_env;

class host_expected_payload_callbacks extends svt_usb_protocol_callbacks;

    usb_env mo_env;

    extern          function        new                         (string name = "host_expected_payload_callbacks", usb_env temp_env);
    extern  virtual function void   post_transfer_in_port_get   (svt_usb_protocol component, int chan_id, svt_usb_transfer transfer, ref bit drop);

endclass : host_expected_payload_callbacks

function host_expected_payload_callbacks::new(string name = "host_expected_payload_callbacks", usb_env temp_env);
    super.new(name);
    this.mo_env = temp_env;

endfunction : new

function void host_expected_payload_callbacks::post_transfer_in_port_get(svt_usb_protocol component, int chan_id, svt_usb_transfer transfer, ref bit drop);
    if(transfer.xfer_type == svt_usb_transfer::ISOCHRONOUS_OUT_TRANSFER)
    begin
        this.mo_env.mq_iso_out_xfer_q.push_back(transfer);
    end else begin
        if(transfer.xfer_type == svt_usb_transfer::ISOCHRONOUS_IN_TRANSFER)
        begin
            this.mo_env.mq_iso_in_xfer_q.push_back(transfer);
        end
    end

endfunction : post_transfer_in_port_get

`endif // HOST_EXPECTED_PAYLOAD_CALLBACKS__SV
