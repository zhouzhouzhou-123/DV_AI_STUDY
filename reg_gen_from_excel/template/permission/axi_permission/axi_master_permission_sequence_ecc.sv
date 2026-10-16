`ifndef axi_master_permission_sequence_ecc__SV
`define axi_master_permission_sequence_ecc__SV
class gen_axi_id;
    rand bit[5:0]   mid;
    rand bit[9:0]   utid;
    rand bit[8:0]   vmid;
endclass

class axi_master_permission_sequence_ecc extends svt_axi_master_base_sequence;

    rand bit [31:0]     address;
    rand bit [7:0]      bst_len;
    rand bit [2:0]      bst_size;
    rand bit [1:0]      bst_type;
    rand bit [1:0]      wract;
    rand bit [3:0]      cache_tp;
    rand bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]    wdata[]; 
    rand bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]    rdata[];
    rand bit            prt0;
    bit [1:0]           resp_ack;
    gen_axi_id          u_gen_axi_id;
    bit                 llpp_or_ram; //0-->llpp , 1-->ram
    bit[5:0]            master_id_t;
    bit[8:0]            vm_id_t;

    /** UVM Object Utility macro */
    `uvm_object_utils_begin(axi_master_permission_sequence_ecc)
        `uvm_field_int(address,UVM_ALL_ON)
        `uvm_field_int(bst_len ,UVM_ALL_ON)
        `uvm_field_int(bst_size ,UVM_ALL_ON)
        `uvm_field_int(wract ,UVM_ALL_ON)
        `uvm_field_int(bst_type ,UVM_ALL_ON)
        `uvm_field_array_int(wdata,UVM_ALL_ON)
        `uvm_field_array_int(rdata ,UVM_ALL_ON)
    `uvm_object_utils_end
    
    extern  function    new     (string name="axi_master_permission_sequence_ecc");
    extern  task        body    (); 
    extern  virtual function bit[7:0] ecc64to8(input bit[63:0]idata); 
    extern  virtual function bit[6:0] ecc32to7(input bit[31:0]idata); 
    extern  virtual function bit[5:0] ecc16to6(input bit[15:0]idata); 
    extern  virtual function bit[4:0] ecc20to5(input bit[19:0]idata); 
    extern  virtual function bit[4:0] ecc16to5(input bit[15:0]idata); 
    extern  virtual function bit[4:0] ecc8to5(input bit[7:0]idata);
    extern  virtual function bit[2:0] ecc4to3(input bit[3:0]idata); 

endclass :axi_master_permission_sequence_ecc

function axi_master_permission_sequence_ecc::new(string name="axi_master_permission_sequence_ecc");
    super.new(name);
    u_gen_axi_id = new();
endfunction : new

task axi_master_permission_sequence_ecc::body();
    bit[6:0] awusercode;
    bit[4:0] awvmidcode;
    bit[4:0] awidcode;
    bit[4:0] awctrl0code;
    bit[4:0] awctrl1code;
    bit[6:0] awaddrcode;

    bit[5:0] wusercode;
    bit[4:0] wctrlcode;
    bit[15:0] wdatacode;
    bit      eobi;

    bit[5:0] busercode;
    bit[4:0] bidcode;
    bit[2:0] bctrlcode;

    bit[6:0] arusercode;
    bit[4:0] arvmidcode;
    bit[4:0] aridcode;
    bit[4:0] arctrl0code;
    bit[4:0] arctrl1code;
    bit[6:0] araddrcode;

    bit[5:0] rusercode;
    bit[4:0] ridcode;
    bit[2:0] rctrlcode;
    bit[15:0] rdatacode;

    bit[127:0] wtmp;
    bit[15:0]  stmp;

    svt_configuration get_cfg;
    svt_axi_master_transaction trans;

    p_sequencer.get_cfg(get_cfg);
    if(!$cast(cfg, get_cfg))
    begin
        `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

    assert(u_gen_axi_id.randomize()with{
        mid  == local::master_id_t;
        vmid == local::vm_id_t;
    }) else
        `uvm_error("",$sformatf("\033[1;31m gen id failed\033[0m"))

    //------------------- AXI read --------------------------
    `uvm_create(trans)
    assert(trans.randomize() with{
            
            trans.xact_type         == wract;
            trans.addr              == address;
            trans.burst_length      == bst_len;
            trans.burst_size        == bst_size;
            trans.burst_type        == bst_type;
            trans.atomic_type       == svt_axi_transaction::NORMAL;
            trans.data.size()       ==  bst_len;
            trans.cache_type        ==  0;
            if(wract == svt_axi_transaction::WRITE) {
                trans.id            <=  7; // awid[2:0]
                trans.prot_type[0]  ==  prt0;
                `ifdef POST_SIM_ON      
                    trans.prot_type[2:1]  ==  2'b00;
                `endif
                if(address >= `LRAM0_START_BASE_ADDR && address <= `LRAM2_END_BASE_ADDR){ //TODO
                    trans.prot_type[1:1] == 1'b1;
                }
                trans.wstrb.size()  ==  bst_len;
                foreach(trans.wstrb[i]) {
                    bst_size == 0 ->  trans.wstrb[i]  ==  'h1;
                    bst_size == 1 ->  trans.wstrb[i]  ==  'h3;
                    bst_size == 2 ->  trans.wstrb[i]  ==  'hf;
                    bst_size == 3 ->  trans.wstrb[i]  ==  'hff;
                    bst_size == 4 ->  trans.wstrb[i]  ==  'hffff;
                    
                }
                foreach(trans.data[i]){
                    trans.data[i]   ==  wdata[i];
                }
                trans.wvalid_delay.size()   ==  bst_len;
            }
            else if(wract == svt_axi_transaction::READ){
                trans.rresp.size()  ==  bst_len;
                trans.prot_type[0]  ==  prt0;
                `ifdef POST_SIM_ON
                    trans.prot_type[1]  ==  1'b0;
                `endif
                if(address >= `LRAM0_START_BASE_ADDR && address <= `LRAM2_END_BASE_ADDR){ //TODO
                    trans.prot_type[1:1] == 1'b1;
                }
                trans.rready_delay.size()   ==  bst_len;
            }
    });
    
    if(wract == svt_axi_transaction::WRITE) begin
        //awusercode  =   ecc32to7({7'b0, u_gen_axi_id.utid, 9'b0, u_gen_axi_id.mid});
        awusercode  =   ecc32to7({26'b0, u_gen_axi_id.mid});
        awvmidcode  =   ecc20to5({11'b0, u_gen_axi_id.vmid});
        awidcode    =   ecc20to5({17'b0, trans.id[2:0]});
        awctrl0code =   ecc16to5({1'b0, trans.qos, 4'b0, trans.cache_type, trans.prot_type});
        awctrl1code =   ecc16to5({2'b0, trans.atomic_type[0], trans.burst_type[1:0], 
                                    trans.burst_size[2:0], trans.burst_length[7:0]-8'b1});
        awaddrcode  =   ecc32to7(trans.addr);
        // `uvm_info("ECC_FUNC", $sformatf("32to7:0x%0h, 20to5:0x%0h, 20to5:0x%0h, 16to5:0x%0h, 16to5:0x%0h, 32to7:0x%0h", 
        //                                 awusercode, awvmidcode, awidcode, 
        //                                 awctrl0code, awctrl1code, awaddrcode), UVM_LOW)

        foreach(trans.data[i]) begin
            eobi = i[0];
            //wusercode    =   ecc16to5({5'b0, eobi, u_gen_axi_id.utid});
            //wusercode    =   ecc16to5({16'b0});//error
            wusercode    =   ecc16to6({16'b0});//modify 2024/11/20
            //wlast, wstrb
            if(llpp_or_ram == 0)begin//LLPP
                if(i==0) begin
                    stmp = trans.wstrb[i] << (trans.addr[1:0]);
                    wtmp = trans.data[i] << (trans.addr[1:0]*8);
                    wdatacode[6:0]   = ecc32to7(wtmp[31:0]);
                end
                else begin
                    wdatacode[6:0]   = ecc32to7({trans.data[i][31:0]});
                end

                if (i < (trans.data.size() - 1)) begin
                    if(i==0) wctrlcode    = ecc20to5({3'b0, 1'b0, stmp});
                    else wctrlcode    = ecc20to5({3'b0, 1'b0, trans.wstrb[i]});
                end
                else begin
                    if(i==0) wctrlcode  = ecc20to5({3'b0, 1'b1, stmp});
                    else wctrlcode      = ecc20to5({3'b0, 1'b1, trans.wstrb[i]});
                end
                
                // `uvm_info("ECC_FUNC", $sformatf("16to5:0x%0h, 20to5:0x%0h, 64to8:0x%0h", 
                //                             wusercode[i],wctrlcode[i], wdatacode[i]), UVM_LOW)

                //trans.data_user[i] = {wusercode, wctrlcode, 1'b0, wdatacode, eobi, u_gen_axi_id.utid};
                trans.data_user[i] = {wusercode, wctrlcode, 1'b0, wdatacode[6:0], 11'b0};
            end 
            else begin//RAM
                if(i==0) begin
                    stmp = trans.wstrb[i] << (trans.addr[3:0]);
                    wtmp = trans.data[i] << (trans.addr[3:0]*8);
                    wdatacode[15:8]  = ecc64to8(wtmp[127:64]);
                    wdatacode[7:0]   = ecc64to8(wtmp[63:0]);
                end
                else begin
                    wdatacode[15:8]  = ecc64to8({trans.data[i][127:64]});
                    wdatacode[7:0]   = ecc64to8({trans.data[i][63:0]});
                end

                if (i < (trans.data.size() - 1)) begin
                    if(i==0) wctrlcode    = ecc20to5({3'b0, 1'b0, stmp});
                    else wctrlcode    = ecc20to5({3'b0, 1'b0, trans.wstrb[i]});
                end
                else begin
                    if(i==0) wctrlcode  = ecc20to5({3'b0, 1'b1, stmp});
                    else wctrlcode      = ecc20to5({3'b0, 1'b1, trans.wstrb[i]});
                end
                
                // `uvm_info("ECC_FUNC", $sformatf("16to5:0x%0h, 20to5:0x%0h, 64to8:0x%0h", 
                //                             wusercode[i],wctrlcode[i], wdatacode[i]), UVM_LOW)

                //trans.data_user[i] = {wusercode, wctrlcode, 1'b0, wdatacode, eobi, u_gen_axi_id.utid};
                trans.data_user[i] = {wusercode, wctrlcode, 1'b0, wdatacode, 11'b0};
            end
        end

        //trans.addr_user = {awusercode, awvmidcode, awidcode, awctrl0code, 
        //                awctrl1code, awaddrcode, 1'b0, u_gen_axi_id.utid, 
        //                u_gen_axi_id.vmid, u_gen_axi_id.mid};
        trans.addr_user = {awusercode, awvmidcode, awidcode, awctrl0code, 
                        awctrl1code, awaddrcode, 1'b0, 10'b0, 
                        u_gen_axi_id.vmid, u_gen_axi_id.mid};
        
    end
    else if(wract == svt_axi_transaction::READ) begin
        //arusercode      = ecc32to7({7'b0, u_gen_axi_id.utid, 9'b0, u_gen_axi_id.mid});
        arusercode      = ecc32to7({7'b0, 10'b0, 9'b0, u_gen_axi_id.mid});
        arvmidcode      = ecc20to5({11'b0, u_gen_axi_id.vmid});
        aridcode        = ecc20to5({16'b0, trans.id});
        arctrl0code     = ecc16to5({1'b0, trans.qos, 4'b0, trans.cache_type, trans.prot_type});
        arctrl1code     = ecc16to5({2'b0, trans.atomic_type[0], trans.burst_type[1:0], 
                                    trans.burst_size[2:0], trans.burst_length[7:0]-8'b1});
        araddrcode      = ecc32to7(trans.addr);

        // `uvm_info("ECC_FUNC", $sformatf("32to7:0x%0h, 20to5:0x%0h, 20to5:0x%0h, 16to5:0x%0h, 16to5:0x%0h, 32to7:0x%0h", 
        //                                 arusercode, arvmidcode, aridcode,
        //                                 arctrl0code, arctrl1code, araddrcode), UVM_LOW)

        //trans.addr_user = {arusercode, arvmidcode, aridcode, arctrl0code, 
        //                arctrl1code, araddrcode, 1'b0, u_gen_axi_id.utid, 
        //                u_gen_axi_id.vmid, u_gen_axi_id.mid};
        trans.addr_user = {arusercode, arvmidcode, aridcode, arctrl0code, 
                        arctrl1code, araddrcode, 1'b0, 10'b0, 
                        u_gen_axi_id.vmid, u_gen_axi_id.mid};

    end
    else
        `uvm_fatal("",$sformatf("Unknown AXI command : 'h%0h", this.wract))


    `uvm_send(trans)
    get_response(rsp);

    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("log_base_2_max_data_width:%d", cfg.log_base_2_max_data_width), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("log_base_2_data_width:%d"    , cfg.log_base_2_data_width    ), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("data_user_width:%d", cfg.data_user_width), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("resp_user_width:%d", cfg.resp_user_width), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("addr_user_width:%d", cfg.addr_user_width), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("addr_width:%d", cfg.addr_width), UVM_LOW)
    // `uvm_info("AXI_SEQ_ECC.cfg", $sformatf("id_width:%d", cfg.id_width), UVM_LOW)

    if(wract == svt_axi_transaction::READ) begin
        rdata   =   rsp.data;

        foreach(rdata[i]) begin
            eobi = i[0];
            //rusercode           =   ecc16to6({5'b0, eobi, u_gen_axi_id.utid});
            rusercode           =   ecc16to6({16'b0});
            ridcode             =   ecc20to5({16'b0, trans.id});
            if (i < (rdata.size() - 1)) begin
                rctrlcode       =   ecc4to3({1'b0, 1'b0, trans.rresp[i]});
            end
            else begin
                rctrlcode       =   ecc4to3({1'b0, 1'b1, trans.rresp[i]});
            end
            rdatacode[15:8]     =   ecc64to8({rdata[i][127:64]});
            rdatacode[7:0]      =   ecc64to8({rdata[i][63:0]});
            //trans.data_user[i]  =   {rusercode, ridcode, rctrlcode, 1'b0, rdatacode,    //4+42=46
            //                        eobi, u_gen_axi_id.utid};
            trans.data_user[i]  =   {rusercode, ridcode, rctrlcode, 1'b0, rdatacode,    //4+42=46
                                    1'b0, 10'b0};

            
            // `uvm_info("ECC_FUNC", $sformatf("16to6:0x%0h, 20to5:0x%0h, 4to3:0x%0h, 64to8:0x%0h", 
            //                             rusercode, ridcode, rctrlcode, rdatacode), UVM_LOW)

            assert(trans.data_user[i] == rsp.data_user[i])
            else    `uvm_error("AXI_READ_ECC", $sformatf("%0d data_user Error. Actual:0x%0h, Exp:0x%0h", 
                            i, trans.data_user[i], rsp.data_user[i]))
        end
        foreach(rsp.rresp[j])begin
            assert(rsp.rresp[j] == resp_ack) begin
                //notice that do not required to support this feature any more, alm 98462
                //if(rsp.rresp[j]==svt_axi_transaction::SLVERR || rsp.rresp[j]==svt_axi_transaction::DECERR) begin
                //    assert (rsp.data[j] == 0) else
                //    `uvm_error("AXI_READ_ECC",$sformatf("axi read data ERROR, exp 0, act is addr:0x%0h->0x%0h,",rsp.addr, rsp.data[j]))
                //end
            end
            else begin
                svt_axi_transaction::resp_type_enum resp_act,resp_exp;
                if($cast(resp_act,rsp.rresp[j]) == 0) `uvm_error(get_full_name(),$sformatf("\033[1;31mcast fail\033[0m"))
                if($cast(resp_exp,resp_ack  ) == 0) `uvm_error(get_full_name(),$sformatf("\033[1;31mcast fail\033[0m"))
                `uvm_info("",$sformatf("\033[1;36m test addr is 0x%0h\033[0m",trans.addr),UVM_LOW)
                `uvm_error(get_full_name(),$sformatf("\033[1;31m Error, Act resp is %0s, but Exp resp is %0s\033[0m",resp_act.name,resp_exp.name))
            end
        end
    end 
    else begin
        //busercode       =   ecc16to6({6'b0, u_gen_axi_id.utid});
        busercode       =   ecc16to6({6'b0, 10'b0});
        bidcode         =   ecc20to5({17'b0, trans.id});
        bctrlcode       =   ecc4to3({2'b0, trans.bresp});
        //trans.resp_user = {busercode, bidcode, bctrlcode, 1'b0, u_gen_axi_id.utid};
        trans.resp_user = {busercode, bidcode, bctrlcode, 1'b0, 10'b0};
        
        // `uvm_info("ECC_FUNC", $sformatf("16to6:0x%0h, 20to5:0x%0h, 4to3:0x%0h", 
        //                                 busercode, bidcode, bctrlcode), UVM_LOW)

        assert(trans.resp_user == rsp.resp_user)
            else    `uvm_error("AXI_READ_ECC", $sformatf("resp_user Error. Actual:0x%0h, Exp:0x%0h", 
                                trans.resp_user, rsp.resp_user))

        if(rsp.bresp != resp_ack) begin
            svt_axi_transaction::resp_type_enum resp_act,resp_exp;
            if($cast(resp_act,rsp.bresp) == 0) `uvm_error(get_full_name(),$sformatf("\033[1;31mcast fail\033[0m"))
            if($cast(resp_exp,resp_ack  ) == 0) `uvm_error(get_full_name(),$sformatf("\033[1;31mcast fail\033[0m"))
            `uvm_info("",$sformatf("\033[1;36m test addr is 0x%0h\033[0m",trans.addr),UVM_LOW)
            `uvm_error(get_full_name(),$sformatf("\033[1;31m Error, Act resp is %0s, but Exp resp is %0s\033[0m",resp_act.name,resp_exp.name))

        end
    end
    // rsp.print();
    
  endtask: body

function bit[7:0] axi_master_permission_sequence_ecc::ecc64to8(input bit[63:0]idata); 
    bit[7:0] ecc;
    bit[7:0] odd_even = 8'h3;
    bit[63:0] cb[8] = '{64'h884bdde_092d1357, 64'h111275ef_125125ab, 64'h202b59b7_249a4a3d, 64'h424daeba_40e68cce, 64'h471cf3c_8703f0f0, 64'h8781f03f_f804ff00, 64'hf801ffc0_fff80000, 64'hfffe0000_00000000};
    for (int ii=0; ii<8; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
        ecc64to8 = ecc;
endfunction

function bit[6:0] axi_master_permission_sequence_ecc::ecc32to7(input bit[31:0]idata); 
    bit[6:0] ecc;
    bit[6:0] odd_even = 7'h42;
    bit[31:0] cb[7] = '{32'h92d1357, 32'h125125ab, 32'h249a4a3d, 32'h40e68cce, 32'h8703f0f0, 32'hf804ff00, 32'hfff80000};
    for (int ii=0; ii<7; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc32to7 = ecc;
endfunction

function bit[5:0] axi_master_permission_sequence_ecc::ecc16to6(input bit[15:0]idata); 
    bit[5:0] ecc;
    bit[5:0] odd_even = 6'h3;
    bit[15:0] cb[6] = '{16'h1357, 16'h25ab, 16'h4a3d, 16'h8cce, 16'hf0f0, 16'hff00};
    for (int ii=0; ii<6; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc16to6 = ecc;
endfunction

function bit[4:0] axi_master_permission_sequence_ecc::ecc20to5(input bit[19:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 5'h1;
    bit[19:0] cb[5] = '{20'h2555b, 20'h49a6d, 20'h8e38e, 20'hf03f0, 20'hffc00};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc20to5 = ecc;
endfunction

function bit[4:0] axi_master_permission_sequence_ecc::ecc16to5(input bit[15:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 5'h8;
    bit[15:0] cb[5] = '{16'h555b, 16'h9a6d, 16'he38e, 16'h03f0, 16'hfc00};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc16to5 = ecc;
endfunction

function bit[4:0] axi_master_permission_sequence_ecc::ecc8to5(input bit[7:0]idata); 
    bit[4:0] ecc;
    bit[4:0] odd_even = 8'h3;
    bit[7:0] cb[5] = '{8'h57, 8'hab, 8'h3d, 8'hce, 8'hf0};
    for (int ii=0; ii<5; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc8to5 = ecc;
endfunction

function bit[2:0] axi_master_permission_sequence_ecc::ecc4to3(input bit[3:0]idata); 
    bit[2:0] ecc;
    bit[2:0] odd_even = 3'b001;
    bit[3:0] cb[3] = '{4'hb, 4'hd, 4'he};
    for (int ii=0; ii<3; ii++) begin
        ecc[ii] = odd_even[ii] ^ (^(idata & cb[ii]));
    end
    ecc4to3 = ecc;
endfunction




`endif // axi_master_permission_sequence_ecc__SV
