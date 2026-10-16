// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: vir_seqr.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef VIR_SEQR__SV
`define VIR_SEQR__SV

`ifdef USB_TEST_ON
    `include "usb_vir_seqr.sv"
`endif
class vir_seqr extends uvm_sequencer;
`ifdef USB_TEST_ON
    usb_vir_seqr    mo_svt_usb_seqr[USB_MASTER_COUNT];
`endif // USB_TEST_ON
`ifdef I2C_TEST_ON
    svt_i2c_system_sequencer    mo_svt_i2c_seqr[5];
`endif // I2C_TEST_ON


    `uvm_component_utils_begin(vir_seqr)

    `uvm_component_utils_end

    extern          function            new         (string name = "vir_seqr", uvm_component parent = null);
    extern  virtual function    void    build_phase (uvm_phase phase);

endclass : vir_seqr

function vir_seqr::new(string name = "vir_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void vir_seqr::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("", "This is build_phase", UVM_LOW)

endfunction : build_phase

`endif // VIR_SEQR__SV
