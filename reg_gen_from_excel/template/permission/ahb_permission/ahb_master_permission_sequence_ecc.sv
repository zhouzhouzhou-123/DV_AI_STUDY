`ifndef ahb_master_permission_sequence_ecc__SV
`define ahb_master_permission_sequence_ecc__SV
    
// burst_size:
/*  svt_ahb_transaction::BURST_SIZE_8BIT
    svt_ahb_transaction::BURST_SIZE_16BIT
    svt_ahb_transaction::BURST_SIZE_32BIT
*/
class gen_ahb_id;
    rand bit[5:0]   master_id;
    rand bit[8:0]   vmid;
    rand bit[9:0]   utid;
    constraint con_mid {
        //master_id inside{[6'd8:6'd10],[6'd16:6'd19]};
        //`ifndef NVM_CONNECTION
        //    master_id == 6'h1A;//flexray_id
        //`else
        //    master_id == 6'h34;//coresight_id, add for jinhui
        //`endif

        //utid == 10'b0;
        utid == 10'h240;//FIXME
        //vmid == 9'd0;
    };
endclass

class ahb_master_permission_sequence_ecc extends svt_ahb_master_transaction_base_sequence;
    rand bit [31:0]  haddr;
    rand bit [31:0]  rdata;
    rand bit [31:0]  wdata;
    rand bit [1:0]   wract;
    bit [3:0] hprot_t;
    bit [5:0] master_id_t = 0;
    bit [8:0] vmid_t = 0;

    rand bit [2:0]   hsize = svt_ahb_transaction::BURST_SIZE_32BIT;
    rand bit         resp_ack = svt_ahb_transaction::OKAY;
    gen_ahb_id       u_gen_ahb_id;

    `uvm_object_utils_begin(ahb_master_permission_sequence_ecc)
        `uvm_field_int(haddr, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(wract, UVM_ALL_ON)
        `uvm_field_int(hsize, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ahb_master_permission_sequence_ecc");
        super.new(name);
    endfunction

    extern task body();
    extern  virtual function bit[7:0] ecc64to8(input bit[63:0]idata); 
    extern  virtual function bit[6:0] ecc32to7(input bit[31:0]idata); 
    extern  virtual function bit[5:0] ecc16to6(input bit[15:0]idata); 
    extern  virtual function bit[4:0] ecc20to5(input bit[19:0]idata); 
    extern  virtual function bit[4:0] ecc16to5(input bit[15:0]idata); 
    extern  virtual function bit[4:0] ecc8to5(input bit[7:0]idata);
    extern  virtual function bit[2:0] ecc4to3(input bit[3:0]idata); 
    
endclass : ahb_master_permission_sequence_ecc
    
task ahb_master_permission_sequence_ecc::body();
    bit[6:0] hausercode;
    bit[6:0] haddrcode;
    bit[4:0] hctrlcode;
    bit[5:0] hwusercode;
    bit[6:0] hwdatacode;
    bit[5:0] hrusercode;
    bit[6:0] hrdatacode;
    bit[3:0] hprot;
    bit[31:0]cdata_huser;
    svt_ahb_master_transaction trans;
    super.body();
    u_gen_ahb_id = new();
    assert(u_gen_ahb_id.randomize()with{
        master_id == local::master_id_t; 
        vmid      == local::vmid_t;
    });

    // --------------------- AHB read ----------------------- //
    `uvm_create(trans)
    assert(trans.randomize() with{
        xact_type     == wract;
        addr          == haddr;
        burst_type    == svt_ahb_transaction::SINGLE;
        burst_size    == hsize;
        //prot0_type    == svt_ahb_transaction::DATA_ACCESS;
        //prot1_type    == svt_ahb_transaction::PRIVILEDGED_ACCESS;
        //prot2_type    == svt_ahb_transaction::NON_BUFFERABLE;
        //prot3_type    == svt_ahb_transaction::NON_CACHEABLE;
        prot0_type    == hprot_t[0];   
        prot1_type    == hprot_t[1]; 
        prot2_type    == hprot_t[2]; 
        prot3_type    == hprot_t[3]; 
        lock          == 0;
        data.size     == 1;
    });
    trans.cfg = cfg;

    hprot = {trans.prot3_type, trans.prot2_type, trans.prot1_type, trans.prot0_type};
    
    if(wract == svt_ahb_transaction::READ) begin
        // reserved[6:0], htrans[1:0], hwrite, hsize[2:0], hburst[2:0], hprot[3:0]
        //hctrlcode = ecc20to5({7'b0, trans.trans_type, 1'b0, trans.burst_size, trans.burst_type, hprot});
        hctrlcode = ecc20to5({7'b0, 2'b10, 1'b0, trans.burst_size, trans.burst_type, hprot});
    end
    else if(wract == svt_ahb_transaction::WRITE) begin
        trans.data[0]   = wdata;
        // reserved[6:0], htrans[1:0], hwrite, hsize[2:0], hburst[2:0], hprot[3:0]
        //hctrlcode       =  ecc20to5({7'b0, trans.trans_type, 1'b1, trans.burst_size, trans.burst_type, hprot});
        hctrlcode       =  ecc20to5({7'b0, 2'b10, 1'b1, trans.burst_size, trans.burst_type, hprot});
        hwusercode      =  ecc16to6({6'b0, u_gen_ahb_id.utid});
        hwdatacode      =  ecc32to7(wdata << 8*haddr[1:0]);

        // hwusercode[5:0], hwdatacode[6:0], 1'b0, wutid[9:0]
        trans.data_huser[0] = {hwusercode, hwdatacode, 1'b0, u_gen_ahb_id.utid};

    end
    else `uvm_fatal("",$sformatf("Unknown AHB command : 'h%0h", this.wract))

    // reserved[6:0], autid[9:0], avmid[8:0], master_id[5:0]
    hausercode      =   ecc32to7({7'b0, u_gen_ahb_id.utid, u_gen_ahb_id.vmid, u_gen_ahb_id.master_id});
    haddrcode       =   ecc32to7(trans.addr);

    trans.control_huser[45:0] = {hausercode, haddrcode, hctrlcode, 1'b0, 1'b0, u_gen_ahb_id.utid, u_gen_ahb_id.vmid, u_gen_ahb_id.master_id};
    
    `uvm_send(trans)
    get_response(rsp);
    //rsp.print();

    if(wract == svt_ahb_transaction::READ) begin
        if(resp_ack == svt_ahb_transaction::OKAY) begin
            this.rdata      =  rsp.data[0];
            hrusercode      =  ecc16to6({6'b0, u_gen_ahb_id.utid});
            hrdatacode      =  ecc32to7(rdata);
            // hrusercode[5:0], hrdatacode[6:0], hreadycode, hrespcode, 1'b0, rutid[9:0]
            cdata_huser = {hrusercode, hrdatacode, 1'b0, ~rsp.response_type[0], 1'b0, u_gen_ahb_id.utid};
            // `uvm_info("AHB_MST_ECC_OPT",$sformatf("rsp.data_huser:0x%0h, cdata_huser:0x%0h", 
            //                                 rsp.data_huser[0], cdata_huser),UVM_LOW)
            //assert(cdata_huser === rsp.data_huser[0]) //FIXME 
            //else begin `uvm_error("AHB_MASTER_WR_SEQ", $sformatf("addr:0x%0h >> hruser:0x%0h, exp_hruser:0x%0h", 
            //                trans.addr, rsp.data_huser[0], cdata_huser))
            //end
        end

        assert(rsp.response_type == resp_ack) begin
            if(resp_ack == svt_ahb_transaction::ERROR) begin
                assert(rsp.data[0] == 32'h0)
                else `uvm_error("", "rdata is not 0 when resp error")
            end
        end 
        else begin
            `uvm_error("",$sformatf("ahb read resp ERROR, exp %0d ACK, act %0d ACK", resp_ack, rsp.response_type))
        end

    end
    else begin
        assert(rsp.response_type == resp_ack)
        else begin
            `uvm_error("",$sformatf("ahb write addr[0x%0h] resp ERROR, exp %0d ACK, act %0d ACK", haddr,resp_ack, rsp.response_type))
        end

    end
    
endtask: body

function bit[7:0] ahb_master_permission_sequence_ecc::ecc64to8(input bit[63:0]idata); 
    bit[7:0] ecc;
    bit[7:0] odd_even = 8'h3;
    bit[63:0] cb[8] = '{64'h884bdde_092d1357, 64'h111275ef_125125ab, 64'h202b59b7_249a4a3d, 64'h424daeba_40e68cce, 64'h471cf3c_8703f0f0, 64'h8781f03f_f804ff00, 64'hf801ffc0_fff80000, 64'hfffe0000_00000000};
    for (int ii=0; ii<8; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
        ecc64to8 = ecc;
endfunction

function bit[6:0] ahb_master_permission_sequence_ecc::ecc32to7(input bit[31:0]idata); 
    bit[6:0] ecc;
    bit[6:0] odd_even = 7'h42;
    bit[31:0] cb[7] = '{32'h92d1357, 32'h125125ab, 32'h249a4a3d, 32'h40e68cce, 32'h8703f0f0, 32'hf804ff00, 32'hfff80000};
    for (int ii=0; ii<7; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc32to7 = ecc;
endfunction

function bit[5:0] ahb_master_permission_sequence_ecc::ecc16to6(input bit[15:0]idata); 
    bit[5:0] ecc;
    bit[5:0] odd_even = 6'h3;
    bit[15:0] cb[6] = '{16'h1357, 16'h25ab, 16'h4a3d, 16'h8cce, 16'hf0f0, 16'hff00};
    for (int ii=0; ii<6; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc16to6 = ecc;
endfunction

function bit[4:0] ahb_master_permission_sequence_ecc::ecc20to5(input bit[19:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 5'h1;
    bit[19:0] cb[5] = '{20'h2555b, 20'h49a6d, 20'h8e38e, 20'hf03f0, 20'hffc00};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc20to5 = ecc;
endfunction

function bit[4:0] ahb_master_permission_sequence_ecc::ecc16to5(input bit[15:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 5'h8;
    bit[15:0] cb[5] = '{16'h555b, 16'h9a6d, 16'he38e, 16'h03f0, 16'hfc00};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc16to5 = ecc;
endfunction

function bit[4:0] ahb_master_permission_sequence_ecc::ecc8to5(input bit[7:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 8'h3;
    bit[7:0] cb[5] = '{8'h57, 8'hab, 8'h3d, 8'hce, 8'hf0};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc8to5 = ecc;
endfunction

function bit[2:0] ahb_master_permission_sequence_ecc::ecc4to3(input bit[3:0]idata); 
    bit[2:0] ecc;
    bit[2:0] odd_even = 3'b001;
    bit[3:0] cb[3] = '{4'hb, 4'hd, 4'he};
    for (int ii=0; ii<3; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc4to3 = ecc;
endfunction


`endif // ahb_master_permission_sequence_ecc__SV
