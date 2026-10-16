
task apb_user_command(input bit [31:0] addr, input bit [1:0] command_type, ref bit [31:0] data,input bit  pprot='h1,input bit [5:0] master_id_t=0,input bit [8:0] vm_id,input bit pslverr_ack=0, bit [3:0] byte_sel = 'hf);
    apb_master_ecc_wr_rd_sequence   temp_seq;
    apb_safety_item                 mo_apb_ecc_item;

    mo_apb_ecc_item = new();
    assert(mo_apb_ecc_item.randomize());
    mo_apb_ecc_item.xact_type = command_type;
    mo_apb_ecc_item.paddr      = addr;
    //mo_apb_ecc_item.hburst_size= hsize;
    mo_apb_ecc_item.write_data = data;
    mo_apb_ecc_item.pslverr    = pslverr_ack;
    mo_apb_ecc_item.pprot      = pprot;
    mo_apb_ecc_item.byte_sel   = byte_sel;
    mo_apb_ecc_item.master_id  = master_id_t;
    mo_apb_ecc_item.vmid       = vm_id;
    //`uvm_info("",$sformatf("\033[1;36m pslverr_ack is 0x%0h\033[0m",pslverr_ack),UVM_LOW)

    temp_seq = apb_master_ecc_wr_rd_sequence::type_id::create();
    temp_seq.mo_apb_trans = mo_apb_ecc_item;
    temp_seq.start(this.mo_env.mo_vir_seqr.mo_svt_apb_master_sequencer_master_0);

    data   = temp_seq.mo_apb_trans.read_data;

endtask : apb_user_command

// ----------------------------- APB CCU-------------------------------- //

task reg_write_with_permission(bit [31:0] addr, bit [31:0] wrdata,bit sv_en = 1,bit[5:0] master_id=0,bit [8:0] vm_id=0,bit pslverr_ack = 0);

    apb_user_command(addr,svt_apb_transaction::WRITE,wrdata,sv_en,master_id,vm_id,pslverr_ack);

endtask : reg_write_with_permission

task reg_read_with_permission(bit [31:0] addr,output bit [31:0] rddata,input bit sv_en = 1,bit pslverr_ack = 0);

    bit pprot_t;
    bit[5:0] master_id;
    bit[8:0] vm_id;
    pprot_t     = sv_en;
    vm_id       = $urandom_range(0,'h1ff);
    master_id   = $urandom_range(0,6'h3f); 

    apb_user_command(addr,svt_apb_transaction::READ,rddata,sv_en,master_id,vm_id,pslverr_ack);

endtask : reg_read_with_permission

task apb_write_ecc(bit [31:0] addr, bit [31:0] pwdata,bit pslverr_ack = 0,input bit [3:0] bytesel = 'hf);

    bit[63:0]   accen_id_tmp ;   
    bit [31:0]  vmen_tmp = `ACCEN_VM_DEFAULT_VALUE;
    
    apb_safety_item                mo_apb_ecc_item;
    apb_master_ecc_wr_rd_sequence  temp_seq;
    accen_id_tmp = `ACCEN_DEFAULT_VALUE;

    temp_seq = apb_master_ecc_wr_rd_sequence::type_id::create();
    mo_apb_ecc_item = apb_safety_item::type_id::create("mo_apb_ecc_item");
    mo_apb_ecc_item.randomize()with{
        xact_type == `WRITE;
        paddr     == addr ;
        byte_sel  == bytesel;
        write_data== pwdata;
        pslverr   == pslverr_ack;
        accen_id_tmp[master_id] == 1'b1;
        pprot     == 7;
        vmid[8] inside {0,1};
        if(vmid[8] == 0){
            (vmid[3] == 1) -> (vmen_tmp[vmid[2:0]] == 1);
        }
    };

    temp_seq.mo_apb_trans = mo_apb_ecc_item;

    `uvm_info("",$sformatf("temp_seq.mo_apb_trans pslverr[0x%0h],mo_apb_ecc_item.pslverr[0x%0h],pslverr_ack [0x%0h]",temp_seq.mo_apb_trans.pslverr,mo_apb_ecc_item.pslverr,pslverr_ack),UVM_LOW)

    temp_seq.start(this.mo_env.mo_vir_seqr.mo_svt_apb_master_sequencer_master_0);

endtask : apb_write_ecc

task apb_read_ecc(bit [31:0] addr, output bit[31:0] read_data,input bit pslverr_ack = 0);

    apb_safety_item                mo_apb_ecc_item;
    apb_master_ecc_wr_rd_sequence  temp_seq;
    temp_seq = apb_master_ecc_wr_rd_sequence::type_id::create();
    mo_apb_ecc_item = apb_safety_item::type_id::create("mo_apb_ecc_item");
    mo_apb_ecc_item.randomize()with{
        xact_type == `READ;
        //paddr     == addr << 1;
        paddr     == addr;
        pslverr   == pslverr_ack;        
    };

    temp_seq.mo_apb_trans = mo_apb_ecc_item;

    temp_seq.start(this.mo_env.mo_vir_seqr.mo_svt_apb_master_sequencer_master_0);

    read_data = mo_apb_ecc_item.read_data;

    //pruser_chk(mo_apb_ecc_item);

endtask : apb_read_ecc

// ----------------------------- APB -------------------------------- //
task apb_write_accessmode(bit [31:0] addr, bit [31:0] write_data,bit pslverr_ack = 0,bit[6:0] puser = 'h0,bit[2:0] pprot_t = 'h7, bit [3:0] byte_sl = 'hf);

    apb_safety_item                mo_apb_ecc_item;
    apb_master_ecc_wr_rd_sequence    temp_seq;

    temp_seq = apb_master_ecc_wr_rd_sequence::type_id::create();
    mo_apb_ecc_item = apb_safety_item::type_id::create("mo_apb_ecc_item");

    mo_apb_ecc_item.randomize()with{
        xact_type == `WRITE;
        paddr     == addr;
        byte_sel  == byte_sl;
        pslverr   == pslverr_ack;
        master_id == puser;
        pprot     == pprot_t;
    };
    temp_seq.mo_apb_trans = mo_apb_ecc_item;
    `uvm_info("",$sformatf("addr[0x%0h] item_addr[0x%0h] temp_seq.mo_apb_trans pslverr[0x%0h],mo_apb_ecc_item.pslverr[0x%0h],pslverr_ack [0x%0h]",addr,mo_apb_ecc_item.paddr,temp_seq.mo_apb_trans.pslverr,mo_apb_ecc_item.pslverr,pslverr_ack),UVM_LOW)

    temp_seq.start(this.mo_env.mo_vir_seqr.mo_svt_apb_master_sequencer_master_0);

endtask : apb_write_accessmode

task reg_check_ecc(input bit [31:0] reg_addr,input bit [31:0] data,input bit [31:0] reg_mask=32'hffff_ffff);

    bit [31:0] act_data;
    bit [31:0] exp_data;

    apb_read_ecc(reg_addr,act_data);
    exp_data = data & reg_mask;

    if(act_data != exp_data)begin
        `uvm_error(get_full_name(),$sformatf("check reg ccu addr 0x%0h err wdata is 0x%0h ,expect_value is 0x%0h,but actual_value is 0x%0h",reg_addr,data,exp_data,act_data))
    end else begin
        `uvm_info(get_full_name(),$sformatf("check ok! ccu register 0x%h is 0x%h ",reg_addr,exp_data),UVM_LOW)
    end

endtask : reg_check_ecc

