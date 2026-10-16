// ----------------------------------------------------
// Copyright(C) 2026 Chipsea All rights reserved.
// File Name: vir_seq.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2026-09-15
// ----------------------------------------------------


`ifndef VIR_SEQ__SV
`define VIR_SEQ__SV

class vir_seq extends base_vir_seq;

    reg_seq mo_reg_seq;

    `uvm_object_utils_begin(vir_seq)
    `uvm_object_utils_end

    `uvm_declare_p_sequencer(vir_seqr)

    extern          function    new(string name = "vir_seq");
    extern  virtual task        body();

endclass : vir_seq

function vir_seq::new(string name = "vir_seq");
    super.new(name);
endfunction : new

task vir_seq::body();
    bit [31:0]  read_data;
    this.mo_reg_seq = reg_seq::type_id::create("mo_reg_seq");
    begin
        `uvm_info("body","reg_seq starting...",UVM_LOW)
        // this.mo_reg_seq.start(p_sequencer.mo_svt_apb_master_sequencer);

        // read & write by AHB VIP without RAL
        // this.mo_reg_seq.start(p_sequencer.mo_svt_ahb_master_transaction_sequencer_master);
        // this.mo_reg_seq.ahb_write(32'haaaa_0000, 32'hffff_ffff);
        // this.mo_reg_seq.ahb_read(32'haaaa_0000, read_data);

        // read & write by APB VIP without RAL
        // this.mo_reg_seq.start(p_sequencer.mo_svt_apb_master_sequencer_master);
        // this.mo_reg_seq.apb_write(32'haaaa_0000, 32'hffff_ffff);
        // this.mo_reg_seq.apb_read(32'haaaa_0000, read_data);
        `uvm_info("body","reg_seq ending...",UVM_LOW)
    end
    fork
        begin
            // this.mo_xxx_seq.start(p_sequencer.xxx_seqr);
        end
        begin
            // this.mo_xxx_seq.start(p_sequencer.xxx_seqr);
        end
    join
    `uvm_info("body","vir_seq ending...",UVM_LOW)
endtask : body

`endif // VIR_SEQ__SV
