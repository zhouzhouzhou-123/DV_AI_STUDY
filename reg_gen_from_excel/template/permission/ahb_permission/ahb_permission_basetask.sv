task ahb_user_permission_command(input bit [31:0] addr, input bit [1:0] command_type, input bit [2:0] hsize, ref bit [31:0] data,input bit [3:0] hprot=4'h3,input bit [5:0] master_id=0,input bit [8:0] vm_id = 0,input bit[1:0]hresp=svt_ahb_transaction::OKAY);
    ahb_master_permission_sequence_ecc temp_seq;

    temp_seq = ahb_master_permission_sequence_ecc::type_id::create();
    temp_seq.wract = command_type;
    temp_seq.haddr = addr;
    temp_seq.hsize = hsize;
    temp_seq.wdata= data;
    temp_seq.resp_ack = hresp;
    temp_seq.hprot_t = hprot;
    temp_seq.master_id_t = master_id;
    temp_seq.vmid_t = vm_id;

    //temp_seq.hauser= hauser;
    //temp_seq.hwuser= hwuser;

    temp_seq.start(this.mo_env.mo_vir_seqr.mo_svt_ahb_master_sequencer_0);

    data   = temp_seq.rdata;
    //hruser = temp_seq.mo_ahb_trans_arr.hruser;
endtask : ahb_user_permission_command


task reg_write_with_permission(bit [31:0] addr, bit [31:0] wrdata,bit sv_en = 1,bit[5:0] master_id=0,bit [8:0] vm_id=0,bit[1:0] hresp = 0);

    bit [3:0]  hprot_t;
    hprot_t[0]    = svt_ahb_transaction::DATA_ACCESS;
    hprot_t[1]    = sv_en;  //svt_ahb_transaction::PRIVILEDGED_ACCESS
    hprot_t[2]    = svt_ahb_transaction::NON_BUFFERABLE;
    hprot_t[3]    = svt_ahb_transaction::NON_CACHEABLE;

    ahb_user_permission_command(addr,svt_ahb_transaction::WRITE,svt_ahb_transaction::BURST_SIZE_32BIT,wrdata,hprot_t,master_id,vm_id,hresp);

endtask : reg_write_with_permission

task reg_read_with_permission(bit [31:0] addr,output bit [31:0] rddata,input bit sv_en = 1,bit [1:0]  hresp = 0);

    bit [3:0]  hprot_t;
    bit[5:0] master_id;

    bit[8:0] vm_id;
    hprot_t = $urandom_range(0,4'hf);
    hprot_t[1]  = sv_en;  //svt_ahb_transaction::PRIVILEDGED_ACCESS
    vm_id       = $urandom_range(0,'h1ff);
    master_id   = $urandom_range(0,6'h3f); 

    ahb_user_permission_command(addr,svt_ahb_transaction::READ,svt_ahb_transaction::BURST_SIZE_32BIT,rddata,hprot_t,master_id,vm_id,hresp);

endtask : reg_read_with_permission
