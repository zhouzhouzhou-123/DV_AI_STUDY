// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_random_transfer_sequence.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------


/**
 * Abstract:
 * This file defines a class that the testbench uses to provides default transfer
 * sequence which is initiated on xfer_sequencer.
 * This class defines a sequence in which it  generates the request object randomly.
 */

`ifndef GUARD_USB_RANDOM_TRANSFER_SEQUENCE_SV
`define GUARD_USB_RANDOM_TRANSFER_SEQUENCE_SV

class usb_random_transfer_sequence extends uvm_sequence;

   /** Parameter that controls the number of transfers that will be generated */
   rand int unsigned sequence_length = 10;

  /** UVM Object Utility macro */
  `uvm_object_utils(usb_random_transfer_sequence)

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 100;
  }

  /**
   * Registering this user defined sequence with the svt_usb_transfer_sequencer.
   */   
  `uvm_declare_p_sequencer(svt_usb_transfer_sequencer)

  /** Class Constructor */
  function new (string name = "usb_random_transfer_sequence");
     super.new(name);
  endfunction : new

  `ifdef UVM_MAJOR_VERSION_1_0  
    virtual task pre_body(); 

      `uvm_info("pre_body","Entered...", UVM_LOW)
      super.pre_body();
      /**
       * Raise the objection before starting the sequence
       */
      if(starting_phase!=null) begin
        starting_phase.raise_objection(this);
      end
      `uvm_info("pre_body","Exiting...", UVM_LOW)
    endtask
    
    virtual task post_body(); 

      `uvm_info("post_body","Entered...", UVM_LOW)
      /**
       * Drop the objection after the sequence is completed
       */
      if(starting_phase!=null) begin
        starting_phase.drop_objection(this);
      end
      `uvm_info("post_body","Exiting...", UVM_LOW)
    endtask
  `else 
    virtual task pre_start(); 
 
`ifdef SVT_UVM_12_OR_HIGHER
      uvm_phase phase_=get_starting_phase();
`endif
      `uvm_info("pre_start","Entered...", UVM_LOW)
      super.pre_start(); 
      /**
       * Raise the objection before starting the sequence
       */ 
`ifdef SVT_UVM_12_OR_HIGHER
      if (get_parent_sequence() == null && get_starting_phase()!=null) begin 
    	phase_.raise_objection(this); 
`else
      if (get_parent_sequence() == null && starting_phase!=null) begin 
    	starting_phase.raise_objection(this); 
`endif
      end
      `uvm_info("pre_start","Exiting...", UVM_LOW)
    endtask: pre_start 
    
    virtual task post_start(); 
 
`ifdef SVT_UVM_12_OR_HIGHER
      uvm_phase phase_=get_starting_phase();
`endif
      `uvm_info("post_start","Entered...", UVM_LOW)
      /**
       * Drop the objection after the sequence is completed
       */
`ifdef SVT_UVM_12_OR_HIGHER
      if (get_parent_sequence() == null && get_starting_phase()!=null) begin
        phase_.drop_objection(this); 
`else
      if (get_parent_sequence() == null && starting_phase!=null) begin
        starting_phase.drop_objection(this); 
`endif
      end 
      `uvm_info("post_start","Exiting...", UVM_LOW)
    endtask: post_start
  `endif

  virtual task body();
    bit status;
    svt_usb_transfer_random_sequence   rand_seq;
	`uvm_info("body", "Entered ...", UVM_LOW)

    status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"), UVM_LOW);

    //repeat(sequence_length) begin
      `uvm_do(rand_seq)
    //end

    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

  
endclass: usb_random_transfer_sequence

`endif // GUARD_USB_RANDOM_TRANSFER_SEQUENCE_SV
