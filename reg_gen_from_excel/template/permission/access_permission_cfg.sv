
`ifndef ACCESS_PERMISSION_CFG_SV
`define ACCESS_PERMISSION_CFG_SV

class access_permission_cfg extends uvm_object;
    typedef enum bit {READ,WRITE} bus_dir_type_e;
    typedef enum bit {ERROR,OKAY} response_return;
    typedef struct{
        string wr_mode,rd_mode;
    } access_mode_s;
    access_mode_s memory_access_mode[bit [31:0]];
    static access_permission_cfg me = get();
    rand bit u_sv_mode;
    rand bit endinit_mode;
    rand bit safe_endinit_mode;
    rand bit p_mode;
    rand bit oen_mode;

    bit [31:0] accen0 = `ACCEN0_DEFAULT_VALUE;
    bit [31:0] accen1 = `ACCEN1_DEFAULT_VALUE;
    bit [31:0] vmen_tmp = `ACCEN_VM_DEFAULT_VALUE;

    rand bit [63:0] accen;
    rand bit [5:0] master_id;
    rand bit [4:0] hprot;
    rand bit endinit,safe_endinit;
    rand bit ocds_en;
    rand bit is_valid;
    rand bit[8:0]   vmid;    
    rand bit        svmen;
    rand bit[7:0]   vm_en;

    `uvm_object_utils_begin( access_permission_cfg )
        `uvm_field_int(u_sv_mode, UVM_DEFAULT)
        `uvm_field_int(endinit_mode, UVM_DEFAULT)
        `uvm_field_int(safe_endinit_mode, UVM_DEFAULT)
        `uvm_field_int(p_mode, UVM_DEFAULT)
        `uvm_field_int(oen_mode, UVM_DEFAULT)
        `uvm_field_int(accen1, UVM_DEFAULT)
        `uvm_field_int(accen0, UVM_DEFAULT)
        `uvm_field_int(accen, UVM_DEFAULT)
        `uvm_field_int(master_id, UVM_DEFAULT)
        `uvm_field_int(vmid, UVM_DEFAULT)
        `uvm_field_int(vm_en, UVM_DEFAULT)
        `uvm_field_int(svmen, UVM_DEFAULT)
        `uvm_field_int(hprot, UVM_DEFAULT)
        `uvm_field_int(ocds_en, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint c_accen {
        accen == {accen1,accen0};
        vm_en == vmen_tmp[7:0];
        svmen == vmen_tmp[8];
    }
    constraint c_hprot {
        if(u_sv_mode == 1)
            {hprot[1] == 1;}
        else
            {hprot[1] == 0;}
    }
    constraint c_endinit {
        endinit ==  endinit_mode;
    }
    constraint c_safeendinit {
        safe_endinit ==  safe_endinit_mode;
    }
    constraint c_oen{
        ocds_en == oen_mode;
    }

    constraint c_id_match {
        if(p_mode == 1)
        {
            accen[master_id] == 1;
            if(svmen == 1){
                vmid[8] inside {0,1};
                if(vmid[8] == 0){
                    (vmid[3] == 1) -> (vm_en[vmid[2:0]] == 1);
                }
            }else{
                vmid[8] == 0;
                vm_en[vmid[2:0]] == 1;
            }
        }
        else
        {
            accen[master_id] inside{0,1};
            if(accen[master_id] == 1){
                if(svmen == 1){
                    vmid[8] == 0;
                    vmid[3] == 1 ;
                    (vm_en[vmid[2:0]] == 0);
                }else{
                    vmid[8] inside{ 0,1};
                     if(vmid[8] == 0){
                    vmid[3] == 1 ;
                    (vm_en[vmid[2:0]] == 0);
                }
            }
        }
    }
    }


    static function access_permission_cfg get();
        if(me == null)
            me = access_permission_cfg::type_id::create("me");
        return me;
    endfunction : get

    local function new();
     
    endfunction

    function gen_accen_cfg_by_mode(string access_mode,bit is_valid);
        access_permission_cfg cfg = access_permission_cfg::get();
        `uvm_info("",$sformatf("\033[1;36m begin to test %0s, reponse is %s\033[0m",access_mode, is_valid? "Valid":"Invalid"),UVM_LOW)
        if(is_valid)
            begin
                case(access_mode)
                    "SV_E_P"  : `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(endinit_mode==1)&&(p_mode==1);})
                    "SV_SE"   : `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(safe_endinit_mode==1);})
                    "SV_SE_32": `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(safe_endinit_mode==1);})
                    "SV_SE_P" : `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(safe_endinit_mode==1)&&(p_mode==1);})
                    "P"       : `ASSERT_REPORT(cfg.randomize() with {(p_mode==1);})
                    "U_SV"    : `ASSERT_REPORT(cfg.randomize())
                    "SV"      : `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1);})
                    "BE"      : `uvm_fatal(get_full_name(),$sformatf("\033[1;31m the BE valid may be out of range\033[0m"))
                    "SV_P_OEN": `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(p_mode==1)&&(oen_mode==1);})
                    "U_SV_P_OEN": `ASSERT_REPORT(cfg.randomize() with {(p_mode==1)&&(oen_mode==1);})
                    "SV_P"    : `ASSERT_REPORT(cfg.randomize() with {(u_sv_mode==1)&&(p_mode==1);})
                    "U_SV_P_M": `ASSERT_REPORT(cfg.randomize() with {p_mode==1;})
                    "U_SV_P"  : `ASSERT_REPORT(cfg.randomize() with {p_mode==1;})
                    default     : `uvm_fatal(get_full_name(),$sformatf("\033[1;31m the mode may be out of range\033[0m"))
                endcase
                //should modify zhouxk 1108  
                //cfg.is_valid = svt_ahb_transaction::OKAY;
            end
            else begin
                case(access_mode)
                    "SV_E_P"  : `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(endinit_mode==1)&&(p_mode==1));})
                    "SV_SE"   : `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(safe_endinit_mode==1));})
                    "SV_SE_32": `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(safe_endinit_mode==1));})
                    "SV_SE_P" : `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(safe_endinit_mode==1)&&(p_mode==1));})
                    "P"       : `ASSERT_REPORT(cfg.randomize() with {~(p_mode==1);})
                    "SV"      : `ASSERT_REPORT(cfg.randomize() with {~(u_sv_mode==1);})                    
                    "U_SV"    : `uvm_fatal(get_full_name(),$sformatf("\033[1;31m the U,SV may be out of range\033[0m"))
                    "BE"      : `ASSERT_REPORT(cfg.randomize())
                    "SV_P_OEN": `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(p_mode==1)&&(oen_mode==1));})
                    "U_SV_P_OEN": `ASSERT_REPORT(cfg.randomize() with {~((p_mode==1)&&(oen_mode==1));})
                    "SV_P"    : `ASSERT_REPORT(cfg.randomize() with {~((u_sv_mode==1)&&(p_mode==1));})
                    "U_SV_P_M": `ASSERT_REPORT(cfg.randomize() with {~(p_mode==1);})
                    "U_SV_P"  : `ASSERT_REPORT(cfg.randomize() with {~(p_mode==1);})
                    default     : `uvm_fatal(get_full_name(),$sformatf("\033[1;31m the mode may be out of range\033[0m"))
                endcase
                //should modify zhouxk 1108
                //cfg.is_valid = svt_ahb_transaction::ERROR;
            end
    endfunction

    function string gen_accen_mode(bit [31:0] addr,access_permission_cfg::bus_dir_type_e dir);
        string access_mode_result = "";
        if(me.memory_access_mode.exists(addr)==0) begin
            `uvm_error(get_full_name(),$sformatf("\033[1;31maddr0x[%0h] have not add\033[0m",addr))
            return access_mode_result;
        end

        if(dir==access_permission_cfg::WRITE)
            access_mode_result = me.memory_access_mode[addr].wr_mode;
        else
            access_mode_result = me.memory_access_mode[addr].rd_mode;
        `uvm_info("",$sformatf("\033[1;36maccess_mode_result is %0s\033[0m",access_mode_result),UVM_LOW)
        return access_mode_result;
    endfunction

endclass

`endif  //ACCESS_PERMISSION_CFG_SV
