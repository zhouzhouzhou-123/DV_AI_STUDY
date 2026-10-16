task axi_write_access_permission(bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0]addr,bit[32-1:0]wrdata,bit [1:0] resp_ack,bit sv0,bit [5:0] master_id,bit [8:0] vmid=0);
    axi_master_permission_sequence_ecc  temp_axi_seq;
    temp_axi_seq = axi_master_permission_sequence_ecc::type_id::create("temp_axi_seq");
    temp_axi_seq.wract = svt_axi_transaction::WRITE;
    temp_axi_seq.address = addr;
    temp_axi_seq.bst_len = 1;
    temp_axi_seq.bst_size = svt_axi_transaction::BURST_SIZE_32BIT;
    temp_axi_seq.bst_type = svt_axi_transaction::INCR;
    temp_axi_seq.prt0     = sv0;
    temp_axi_seq.resp_ack = resp_ack;
    //temp_axi_seq.u_gen_axi_id.rand_mode(0); //close rand
    temp_axi_seq.master_id_t = master_id;
    temp_axi_seq.vm_id_t = vmid;
	//`uvm_info("",$sformatf("\033[1;36mtemp_axi_seq.master_id_t is 0x%0h\033[0m",temp_axi_seq.master_id_t),UVM_LOW)
	//`uvm_info("",$sformatf("\033[1;36mtemp_axi_seq.vm_id_t is 0x%0h\033[0m",temp_axi_seq.vm_id_t),UVM_LOW)
	//`uvm_info("",$sformatf("\033[1;36mmaster_id is 0x%0h\033[0m",master_id),UVM_LOW)
	//`uvm_info("",$sformatf("\033[1;36mvmid is 0x%0h\033[0m",vmid),UVM_LOW)
    temp_axi_seq.wdata = new[1];
    temp_axi_seq.wdata[0] = wrdata;

    temp_axi_seq.llpp_or_ram = 0;//1-->NIC_RAM | 0-->NIC_SYS

    temp_axi_seq.start(mo_env.mo_vir_seqr.mo_svt_axi_master_sequencer_0[0]);
endtask


task axi_read_access_permission(bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0]addr,output bit [32-1:0] rddata,input bit [1:0] resp_ack,bit sv0,bit [5:0] master_id,bit [8:0] vmid=0);
    axi_master_permission_sequence_ecc  temp_axi_seq;
    temp_axi_seq = axi_master_permission_sequence_ecc::type_id::create("temp_axi_seq");
    
    temp_axi_seq.wract = svt_axi_transaction::READ;
    temp_axi_seq.address = addr;
    temp_axi_seq.bst_len = 1;
    temp_axi_seq.prt0     = sv0;
    temp_axi_seq.bst_size = svt_axi_transaction::BURST_SIZE_32BIT;
    temp_axi_seq.bst_type = svt_axi_transaction::INCR;
    temp_axi_seq.resp_ack = resp_ack;
    temp_axi_seq.master_id_t = master_id;
    temp_axi_seq.vm_id_t = vmid;

	`uvm_info("",$sformatf("\033[1;36mmaster_id is 0x%0h\033[0m",master_id),UVM_LOW)
	`uvm_info("",$sformatf("\033[1;36mvmid is 0x%0h\033[0m",vmid),UVM_LOW)

    temp_axi_seq.llpp_or_ram = 0;//1-->NIC_RAM | 0-->NIC_SYS

    temp_axi_seq.start(mo_env.mo_vir_seqr.mo_svt_axi_master_sequencer_0[0]);

    assert(temp_axi_seq.rdata.size == 1) else
        `uvm_error(get_full_name(),$sformatf("\033[1;31m return data nums >1\033[0m"))
    rddata = temp_axi_seq.rdata[0];
endtask

//add by zhouxk for permission 20260204
task reg_write_with_permission(bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0]addr,bit[32-1:0]wrdata,bit sv0=1,bit [5:0] master_id=0,bit [8:0] vmid=0,bit invalid=0);
    if(!invalid)begin
        axi_write_access_permission(addr,wrdata,svt_axi_transaction::OKAY,sv0,master_id,vmid);
    end else begin
        axi_write_access_permission(addr,wrdata,svt_axi_transaction::SLVERR,sv0,master_id,vmid);
    end
endtask : reg_write_with_permission

task reg_read_with_permission(bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0]addr,output bit[32-1:0] rddata,input bit sv_en = 1,bit invalid=0);
    bit sv0 ;
    bit[5:0] master_id;
    bit[8:0] vmid;
    sv0        = sv_en;
    vmid       = $urandom_range(0,'h1ff);
    master_id  = $urandom_range(0,6'h3f); 

    if(!invalid)begin
        axi_read_access_permission(addr,rddata,svt_axi_transaction::OKAY,sv0,master_id,vmid);
    end else begin
        axi_read_access_permission(addr,rddata,svt_axi_transaction::SLVERR,sv0,master_id,vmid);
    end

endtask : reg_read_with_permission

//**********************End Reg access according to mode*****************************************************
