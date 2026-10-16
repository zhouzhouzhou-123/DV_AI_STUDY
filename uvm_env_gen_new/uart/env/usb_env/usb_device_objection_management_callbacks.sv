// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_device_objection_management_callbacks.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_DEVICE_OBJECTION_MANAGEMENT_CALLBACKS__SV
`define USB_DEVICE_OBJECTION_MANAGEMENT_CALLBACKS__SV

class usb_device_objection_management_callbacks extends svt_usb_protocol_callbacks;

    int unsigned input_req_cnt = 0;

    // Indicates when to raise objection;
    event objection_raise_ev;

    // Indicates when to drop objection;
    event objection_drop_ev;

    function new(string name = "usb_device_objection_management_callbacks");
        super.new(name);
    endfunction

    virtual function void new_20_response_transfer(svt_usb_protocol component, ref svt_usb_transfer transfer);
        if(input_req_cnt == 0)
        begin
            ->objection_raise_ev;
        end
        input_req_cnt++;
    endfunction

    virtual function void new_SS_response_transfer(svt_usb_protocol component, ref svt_usb_transfer transfer);
        if(input_req_cnt == 0)
        begin
            ->objection_raise_ev;
        end
        input_req_cnt++;
    endfunction

    virtual function void transfer_ended(svt_usb_protocol component, svt_usb_transfer transfer);
        input_req_cnt--;
        if (input_req_cnt == 0)
        begin
            ->objection_drop_ev;
        end
    endfunction

endclass

`endif // USB_DEVICE_OBJECTION_MANAGEMENT_CALLBACKS__SV
