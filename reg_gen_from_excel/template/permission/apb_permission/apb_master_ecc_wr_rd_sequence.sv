`ifndef APB_MASTER_ECC_WR_RD_SEQUENCE__SV
`define APB_MASTER_ECC_WR_RD_SEQUENCE__SV

class apb_master_ecc_wr_rd_sequence extends svt_apb_master_base_sequence;

    `uvm_object_utils_begin(apb_master_ecc_wr_rd_sequence)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(read_data, UVM_ALL_ON)
        `uvm_field_int(write_data, UVM_ALL_ON)
        `uvm_field_int(xact_type, UVM_ALL_ON)
        `uvm_field_int(byte_sel, UVM_ALL_ON)

    `uvm_object_utils_end
    

    bit [31:0]  addr;
    bit [31:0]  read_data;
    bit [31:0]  write_data;
    bit [1:0]   xact_type;
    bit [3:0]   byte_sel;

    apb_safety_item mo_apb_trans;

    extern  function    new    (string name = "apb_master_ecc_wr_rd_sequence");
    extern  task        body    ();

endclass : apb_master_ecc_wr_rd_sequence

function apb_master_ecc_wr_rd_sequence::new(string name="apb_master_ecc_wr_rd_sequence");
    super.new(name);
endfunction

task apb_master_ecc_wr_rd_sequence::body();
    svt_apb_master_transaction trans;
    svt_configuration get_cfg;

    this.p_sequencer.get_cfg(get_cfg);
    if(!$cast(cfg, get_cfg))
    begin
        `uvm_fatal("body", "Unable to $cast the configuration to a svt_ahb_port_configuration class");
    end

    // --------------------- APB read ----------------------- //
    if(mo_apb_trans.xact_type == svt_apb_transaction::READ)
    begin
        // Set up the read transaction
        `uvm_create(trans)

        trans.cfg = cfg;

        `uvm_rand_send_with (trans,
        {
            trans.xact_type             == mo_apb_trans.xact_type;
            trans.address               == mo_apb_trans.paddr;
            trans.pprot0                == mo_apb_trans.pprot[0];            
            trans.pprot1                == mo_apb_trans.pprot[1];
            trans.pprot2                == mo_apb_trans.pprot[2];
            trans.data                  == mo_apb_trans.write_data;
            trans.control_puser[5:0]    == mo_apb_trans.master_id;    
            trans.control_puser[14:6]   == mo_apb_trans.vmid;                    

        } )
        // Wait for the read transaction to complete
        //`uvm_info("",$sformatf(" control_puser is 0x%0h,trans control_puser is 0x%0h",mo_apb_trans.puser,trans.control_puser),UVM_LOW)        
        get_response(rsp);
        //rsp.print();
        mo_apb_trans.read_data=rsp.data[31:0];
        //mo_apb_trans.pruser=rsp.data[63:32];
        //`uvm_info("",$sformatf("rsp.control_puser[119:88]  is 0x%0h,trans control_puser is 0x%0h",rsp.control_puser[119:88],mo_apb_trans.pruser),UVM_LOW)     
        if(rsp.pslverr_enable != mo_apb_trans.pslverr)
            `uvm_error(get_full_name(),$sformatf(" Read pslverr is ERROR !!!!! "))
        //rsp.print();
        // `uvm_info("READ", $sformatf("addr:0x%x, data:0x%x", read_addr, read_data), UVM_NONE);
        return;
    end

    // --------------------- APB write ----------------------- //
    if(mo_apb_trans.xact_type == svt_apb_transaction::WRITE)
    begin

        /** Set up the write transaction */
        `uvm_create(trans)
        trans.cfg = cfg;
        //`uvm_info("",$sformatf("trans.data  is 0x%0h,mo_apb_trans.write_data is 0x%0h",trans.data,mo_apb_trans.write_data ),UVM_LOW)        
        `uvm_rand_send_with(trans,
        {
            trans.control_puser[5:0]  == mo_apb_trans.master_id;        
            trans.xact_type           == mo_apb_trans.xact_type;
            trans.address             == mo_apb_trans.paddr;
            trans.pstrb               == mo_apb_trans.byte_sel;
            trans.pprot0              == mo_apb_trans.pprot[0];            
            trans.pprot1              == mo_apb_trans.pprot[1];
            trans.pprot2              == mo_apb_trans.pprot[2];
            trans.data                == mo_apb_trans.write_data;
            trans.control_puser[14:6] == mo_apb_trans.vmid;                    

        } )
        //`uvm_info("",$sformatf("trans.control_puser  is 0x%0h,mo_apb_trans.master_id is 0x%0h",trans.control_puser,mo_apb_trans.master_id ),UVM_LOW)

        get_response(rsp);
        //rsp.print();
        if(rsp.pslverr_enable != mo_apb_trans.pslverr)
            `uvm_error(get_full_name(),$sformatf(" Write addr[0x%h] pslverr is ERROR !!!!!exp[0x%h] act[0x%h] ",mo_apb_trans.paddr,mo_apb_trans.pslverr,rsp.pslverr_enable))

        // `uvm_info("WRITE", $sformatf("addr:0x%x, data:0x%x", write_addr, write_data), UVM_NONE);
        //`uvm_info("",$sformatf(" control_puser is 0x%0h,trans control_puser is 0x%0h",mo_apb_trans.puser,trans.control_puser),UVM_LOW)
        return;
    end
    `uvm_error("",$sformatf("Unknown APB command : 'h%0h", this.xact_type))
endtask: body

`endif // APB_MASTER_ECC_WR_RD_SEQUENCE__SV
