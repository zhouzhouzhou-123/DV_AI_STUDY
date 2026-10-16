//------------------------------------------------------------------------
// FILE NAME      : apb_safety_item.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : zhouxk
// AUTHOR'S EMAIL : zhouxk@chipsea.com
// ABSTACT        :
//
//-------------------------------------------------------------------------
`ifndef APB_SAFETY_ITEM_SV
`define APB_SAFETY_ITEM_SV

`define WRITE       1
`define READ        0
`define IDLE        2

class apb_safety_item extends uvm_sequence_item;

    typedef enum bit {
    OKAY  = 0,
    ERROR = 1
  } slverror_ack;

    rand bit [31:0]                                             paddr;
    rand bit [1:0]                                              xact_type;
    rand bit [31:0]                                             read_data;
    rand bit [31:0]                                             write_data;

    rand bit [3:0]                                              byte_sel;
    rand bit                                                    pslverr;
    rand bit                                                    pready;

    rand bit [87:0]                                             puser;
    rand bit [55:0]                                             pauser;
    bit      [6:0]                                              pausercode;
    rand bit [15:0]                                             pctrl;
    rand bit [2:0]                                              pprot;
    rand bit                                                    psel;
    rand bit                                                    penable;
    bit      [6:0]                                              paddrcode;
    bit      [4:0]                                              pctrlcode;
    rand bit                                                    pselredu;
    bit      [9:0]                                              autid;
    rand bit [7:0]                                              awvmid;
    rand bit [5:0]                                              master_id;

    rand bit [31:0]                                             pwuser;
    bit      [5:0]                                              pwusercode;
    bit      [6:0]                                              pwdatacode;
    rand bit [9:0]                                              wutid;

    rand bit [31:0]                                             pruser;  
    rand bit [5:0]                                              prusercode;
    rand bit [6:0]                                              prdatacode;
    rand bit                                                    pslverrcode;
    rand bit                                                    preadycode;
    rand bit [9:0]                                              rutid;
    rand bit [8:0]                                              vmid;

    `uvm_object_utils_begin(apb_safety_item)
        `uvm_field_int(paddr        ,UVM_ALL_ON) 
        `uvm_field_int(xact_type    ,UVM_ALL_ON) 
        `uvm_field_int(read_data    ,UVM_ALL_ON) 
        `uvm_field_int(write_data   ,UVM_ALL_ON) 
        `uvm_field_int(xact_type    ,UVM_ALL_ON) 
        `uvm_field_int(byte_sel     ,UVM_ALL_ON) 
        `uvm_field_int(puser        ,UVM_ALL_ON)
        `uvm_field_int(pauser       ,UVM_ALL_ON)
        `uvm_field_int(pctrl        ,UVM_ALL_ON)
        `uvm_field_int(pprot        ,UVM_ALL_ON)
        `uvm_field_int(psel         ,UVM_ALL_ON)
        `uvm_field_int(penable      ,UVM_ALL_ON)
        `uvm_field_int(pslverr      ,UVM_ALL_ON)
        `uvm_field_int(pwuser       ,UVM_ALL_ON)
        `uvm_field_int(pruser       ,UVM_ALL_ON)
        `uvm_field_int(pselredu     ,UVM_ALL_ON)
        `uvm_field_int(awvmid       ,UVM_ALL_ON)
        `uvm_field_int(vmid         ,UVM_ALL_ON)        
        `uvm_field_int(master_id    ,UVM_ALL_ON)
        `uvm_field_int(wutid        ,UVM_ALL_ON)
        `uvm_field_int(pruser       ,UVM_ALL_ON)
        `uvm_field_int(prusercode   ,UVM_ALL_ON)
        `uvm_field_int(prdatacode   ,UVM_ALL_ON)
        `uvm_field_int(pslverrcode  ,UVM_ALL_ON)
        `uvm_field_int(preadycode   ,UVM_ALL_ON)
        `uvm_field_int(rutid        ,UVM_ALL_ON)
    `uvm_object_utils_end

    constraint  puser_c {
        puser == {pwuser,pauser};
        if(xact_type == `WRITE)  autid  == wutid;
        if(xact_type == `READ)   rutid  == autid;
        if(xact_type == `READ)   write_data  == 0;
        soft pprot   == 7;
        soft byte_sel== 0;
        psel         == 1;
        penable      == 1;
        pselredu     == ~psel;        
        pctrl        == {7'b0,xact_type[0],pprot,byte_sel,penable};
    }

    constraint  pauser_c {
        pauser == {4'b0,pausercode,paddrcode,pctrlcode,pselredu,6'b0,autid,awvmid,2'b0,master_id};
    }

    constraint  pwuser_c {
        pwuser == {3'b0,pwusercode,pwdatacode,6'b0,wutid};
    }

    constraint 	master_id_c {
       master_id inside {[0:63]};
    }

    constraint 	pselredu_c {
       soft pselredu == 0;
    }
    constraint 	prusercode_c {
       soft  pslverr == 0;
       soft  pready  == 1;

    }

    
endclass:apb_safety_item
    
`endif  //APB_SAFETY_ITEM_SV
