// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_env_top.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_ENV_TOP__SV
`define USB_ENV_TOP__SV

`ifdef USB_TEST_ON
    `include "usb_shared_cfg.sv"
    `include "usb_vir_seqr.sv"
    `include "usb_device_response_payload_callbacks.sv"
    `include "host_expected_payload_callbacks.sv"
    `include "device_expected_payload_callbacks.sv"
    `include "usb_device_objection_management_callbacks.sv"
    `include "usb_host_objection_management_callbacks.sv"
    `include "usb_env.sv"
`endif


`endif // ENV__SV

