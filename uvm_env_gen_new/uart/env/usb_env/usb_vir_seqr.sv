// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_vir_seqr.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_VIR_SEQR__SV
`define USB_VIR_SEQR__SV

class usb_vir_seqr extends uvm_sequencer;


    svt_usb_transfer_sequencer  mo_host_xfer_sequencer;

    `uvm_component_utils_begin(usb_vir_seqr)
    `uvm_component_utils_end

    extern          function            new         (string name = "usb_vir_seqr", uvm_component parent = null);
    extern  virtual function    void    build_phase (uvm_phase phase);

endclass : usb_vir_seqr

function usb_vir_seqr::new(string name = "usb_vir_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void usb_vir_seqr::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("", "This is build_phase", UVM_LOW)

    this.mo_host_xfer_sequencer = svt_usb_transfer_sequencer::type_id::create("mo_host_xfer_sequencer", this);
endfunction : build_phase

`endif // VIR_SEQR__SV

