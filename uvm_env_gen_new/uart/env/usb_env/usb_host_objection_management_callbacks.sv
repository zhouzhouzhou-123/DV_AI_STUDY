`ifndef USB_HOST_OBJECTION_MANAGEMENT_CALLBACKS__SV
`define USB_HOST_OBJECTION_MANAGEMENT_CALLBACKS__SV

class usb_host_objection_management_callbacks extends svt_usb_protocol_callbacks;

    int unsigned input_req_cnt = 0;

    // Indicates when to raise objection;
    event objection_raise_ev;

    // Indicates when to drop objection;
    event objection_drop_ev;

    function new(string name = "usb_host_objection_management_callbacks");
        super.new(name);
    endfunction

    virtual function void post_transfer_in_port_get(svt_usb_protocol component, int chan_id, svt_usb_transfer transfer, ref bit drop);
        if (input_req_cnt == 0)
        begin
            ->objection_raise_ev;
        end
        input_req_cnt++;
    endfunction

    virtual function void transfer_ended(svt_usb_protocol component, svt_usb_transfer transfer);
        input_req_cnt--;
        if(input_req_cnt == 0)
        begin
            ->objection_drop_ev;
        end
    endfunction
endclass

`endif // USB_HOST_OBJECTION_MANAGEMENT_CALLBACKS__SV
