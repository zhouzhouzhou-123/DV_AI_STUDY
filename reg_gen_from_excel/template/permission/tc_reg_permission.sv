
`ifndef tc_{{module_name|lower}}_reg_access_permission_SV
`define tc_{{module_name|lower}}_reg_access_permission_SV
class tc_{{module_name|lower}}_reg_access_permission extends basetest;

    bit [31:0] accen_msk0   = `ACCEN0_DEFAULT_MSK;
    bit [31:0] accen_msk1   = `ACCEN1_DEFAULT_MSK;
    bit [31:0] accen_vm_msk = `ACCEN_VM_DEFAULT_MSK;
    bit [31:0] accen1,accen0,accen_vm,prot_e_addr;

    reg_collection      {{module_name|lower}}_regs;
    {{module_name|lower}}_config_item     mo_{{module_name|lower}}_item;
  
    `uvm_component_utils( tc_{{module_name|lower}}_reg_access_permission )
    function new(input string name="tc_{{module_name|lower}}_reg_access_permission", uvm_component parent);
        super.new(name, parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    extern task tc_proc();
    extern task invalid_permission_access_mode_chk();
    extern task invalid_clk_clc_access_chk();
    extern task invalid_se_e_permission_access_mode_chk();    
    extern task valid_permission_access_mode_chk();
    extern task endinit_{{module_name|lower}}_e_se_set(input bit endinit,input bit safety_endinit);
    extern task ocds_{{module_name|lower}}_set(input bit ocds_en);
    extern task write_{{module_name|lower}}_reg_with_access_permission(bit [31:0] addr,bit [31:0] data,bit is_valid=1,bit is_se_e = 0);
    extern task read_{{module_name|lower}}_reg_with_access_permission(bit [31:0] addr,output bit[31:0] data,input bit is_valid=1);

    extern function add_memory_access_mode(reg_collection regs);
endclass : tc_{{module_name|lower}}_reg_access_permission

function void tc_{{module_name|lower}}_reg_access_permission::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mo_{{module_name|lower}}_item = {{module_name|lower}}_config_item::type_id::create("mo_{{module_name|lower}}_item"); 
    {{module_name|lower}}_regs = reg_collection::type_id::create("{{module_name|lower}}_regs");

endfunction

task tc_{{module_name|lower}}_reg_access_permission::tc_proc();
    `uvm_info("",$sformatf("\033[1;36mtc_proc begin\033[0m"),UVM_LOW)
    repeat(20)begin
        `uvm_info("",$sformatf("\033[1;36m Start invalid se_e_permission  access chk \033[0m"),UVM_LOW)        
        invalid_se_e_permission_access_mode_chk();
    end    
    repeat(20)begin
        `uvm_info("",$sformatf("\033[1;36m Start invalid access chk \033[0m"),UVM_LOW)        
        invalid_permission_access_mode_chk();
    end
    repeat(20)begin
        `uvm_info("",$sformatf("\033[1;36m Start valid access chk \033[0m"),UVM_LOW)
        valid_permission_access_mode_chk();
    end
endtask:tc_proc

task tc_{{module_name|lower}}_reg_access_permission::invalid_clk_clc_access_chk();
    //TODO

endtask:invalid_clk_clc_access_chk

task tc_{{module_name|lower}}_reg_access_permission::invalid_se_e_permission_access_mode_chk();

    mo_{{module_name|lower}}_item.randomize()with{  
    };

    initialize_{{module_name|lower}}_reg_info(`{{module_name|upper}}_SADDR,{{module_name|lower}}_regs,mo_{{module_name|lower}}_item);
    //if modify se and e add as follows
    //ccu_regs.find_by_name("ccu_prot_e").rst_val = 'h1; //set 'h8000_0009
    //ccu_regs.find_by_name("ccu_prot_se").rst_val = 'h1;
    {{module_name|lower}}_regs.print_all();    
    add_memory_access_mode({{module_name|lower}}_regs);  
    //TODO 0. open clk
    //write_{{module_name|lower}}_reg_with_access_permission({{module_name|lower}}_regs.find_by_name("{{module_name|lower}}_clc").addr,0);  
    foreach({{module_name|lower}}_regs.regs[i])begin
        if({{module_name|lower}}_regs.regs[i].name inside {"{{module_name|lower}}_prot_se","{{module_name|lower}}_prot_e"})begin
        //TODO 1. prot_e_num > 1, modify the loop as follow
        //if({{module_name|lower}}_regs.regs[i].name inside {"{{module_name|lower}}_prot_se","{{module_name|lower}}_prot_e[0]","{{module_name|lower}}_prot_e[1]"})begin
            write_{{module_name|lower}}_reg_with_access_permission({{module_name|lower}}_regs.regs[i].addr,{{module_name|lower}}_regs.regs[i].wr_data,0,1);
            reg_chk_with_permission({{module_name|lower}}_regs.regs[i].addr,{{module_name|lower}}_regs.regs[i].rst_val);
        end
    end

endtask : invalid_se_e_permission_access_mode_chk

task tc_{{module_name|lower}}_reg_access_permission::invalid_permission_access_mode_chk();
    access_permission_cfg cfg;
    bit[31:0] val_before[$];    

    cfg = access_permission_cfg::get();

    mo_{{module_name|lower}}_item.randomize();
    initialize_{{module_name|lower}}_reg_info(`{{module_name|upper}}_SADDR,{{module_name|lower}}_regs,mo_{{module_name|lower}}_item);
    {{module_name|lower}}_regs.print_all();
    {{module_name|lower}}_regs.delete_by_name("{{module_name|lower}}_prot_se");
    {{module_name|lower}}_regs.delete_by_name("{{module_name|lower}}_prot_e");
    add_memory_access_mode({{module_name|lower}}_regs);   

    //Part Ⅰ :Gen Valid accen(can not all 0 after write to reg)
    void'(std::randomize(accen1,accen0,accen_vm) with{
        $countones(accen0  & accen_msk0)      !=0;
        $countones(accen1  & accen_msk1)      !=0;
        $countones(accen_vm& accen_vm_msk)    !=0;
    });

    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_M1,accen1,1);
    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_M0,accen0,1);
    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_VM,accen_vm,1);

    cfg.accen0      = accen0 ;
    cfg.accen1      = accen1 ;
    cfg.vmen_tmp    = accen_vm ;

    verify_invalid_permission_before_write({{module_name|lower}}_regs,val_before);

    foreach({{module_name|lower}}_regs.regs[i])begin
        //TODO 2 apu_num > 1 modify the accen cfg as follow. addr range [0:'h100] should be userdefined
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h0:'h100]})begin   
        //    cfg.accen0    = accen0[0];
        //    cfg.accen1    = accen1[0];
        //    cfg.vmen_tmp  = accen_vm[0];
        //end
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h104:'h200]})begin  
        //    cfg.accen0    = accen0[1];
        //    cfg.accen1    = accen1[1];
        //    cfg.vmen_tmp  = accen_vm[1];
        //end
        //TODO 1 prot_e_num > 1 modify the prot_e as follow
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h0:'h100]})begin
        //    prot_e_addr = `{{module_name|upper}}_PROT_E(0);
        //end 
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h104:'h200]})begin
        //    prot_e_addr = `{{module_name|upper}}_PROT_E(1);        
        //end
        write_{{module_name|lower}}_reg_with_access_permission({{module_name|lower}}_regs.regs[i].addr,{{module_name|lower}}_regs.regs[i].wr_data,0);
    end

    verify_invalid_permission_after_write({{module_name|lower}}_regs,val_before);


endtask:invalid_permission_access_mode_chk

task tc_{{module_name|lower}}_reg_access_permission::valid_permission_access_mode_chk();
    access_permission_cfg cfg;

    cfg = access_permission_cfg::get();

    mo_{{module_name|lower}}_item.randomize()with
    {   
        (accen_m0 & local::accen_msk0)   == local::accen_msk0;
        (accen_m1 & local::accen_msk1)   == local::accen_msk1;
        (accen_vm & local::accen_vm_msk) == local::accen_vm_msk;

        //TODO 0. open clk clc_disr constraint 0
        //clc_disr             == 0;

        //syspllcon0_syspll_en == 1;
        //perpllcon0_perpll_en == 1;
        //ccucon0_lpdiv        == 0;
    };
    initialize_{{module_name|lower}}_reg_info(`{{module_name|upper}}_SADDR,{{module_name|lower}}_regs,mo_{{module_name|lower}}_item);
    {{module_name|lower}}_regs.print_all();
    {{module_name|lower}}_regs.delete_by_name("{{module_name|lower}}_prot_se");
    {{module_name|lower}}_regs.delete_by_name("{{module_name|lower}}_prot_e");
    add_memory_access_mode({{module_name|lower}}_regs);   

    //Part Ⅰ :Gen Valid accen(can not all 0 after write to reg)
    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_M1,mo_{{module_name|lower}}_item.accen_m1,1);
    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_M0,mo_{{module_name|lower}}_item.accen_m0,1);
    write_{{module_name|lower}}_reg_with_access_permission(`{{module_name|upper}}_ACCEN_VM,mo_{{module_name|lower}}_item.accen_vm,1);

    cfg.accen0  = mo_{{module_name|lower}}_item.accen_m0&accen_msk0 ;
    cfg.accen1  = mo_{{module_name|lower}}_item.accen_m1&accen_msk1 ;
    cfg.vmen_tmp= mo_{{module_name|lower}}_item.accen_vm&accen_vm_msk;

    foreach({{module_name|lower}}_regs.regs[i])begin
        //TODO 2 apu_num > 1 modify the accen cfg as follow
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h0:'h100]})begin
        //    cfg.accen0    = accen0[0];
        //    cfg.accen1    = accen1[0];
        //    cfg.vmen_tmp  = accen_vm[0];
        //end
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h104:'h200]})begin
        //    cfg.accen0    = accen0[1];
        //    cfg.accen1    = accen1[1];
        //    cfg.vmen_tmp  = accen_vm[1];
        //end
        //TODO 1 prot_e_num > 1 modify the prot_e as follow        
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h0:'h100]})begin
        //    prot_e_addr = `{{module_name|upper}}_PROT_E(0);
        //end 
        //if({{module_name|lower}}_regs.regs[i].addr inside{['h104:'h200]})begin
        //    prot_e_addr = `{{module_name|upper}}_PROT_E(1);        
        //end
        if({{module_name|lower}}_regs.regs[i].write_mode == "BE") begin
            read_{{module_name|lower}}_reg_with_access_permission({{module_name|lower}}_regs.regs[i].addr,{{module_name|lower}}_regs.regs[i].wr_data,1);
            continue;
        end
        write_{{module_name|lower}}_reg_with_access_permission({{module_name|lower}}_regs.regs[i].addr,{{module_name|lower}}_regs.regs[i].wr_data,1);
    end

    //TODO 4 exp_date pre process
    //ccu_regs.find_by_name("ccu_syspllstat").wr_data[2] = 1;
    //ccu_regs.find_by_name("ccu_syspllstat").reg_msk[2] = 1;
    //ccu_regs.find_by_name("ccu_testctrl").wr_data = `CCU_TESTCTRL_RSTVAL;
    {{module_name|lower}}_regs.find_by_name("{{module_name|lower}}_accen_m0").reg_msk = accen_msk0;
    {{module_name|lower}}_regs.find_by_name("{{module_name|lower}}_accen_m1").reg_msk = accen_msk1;
    {{module_name|lower}}_regs.find_by_name("{{module_name|lower}}_accen_vm").reg_msk = accen_vm_msk;

    verify_valid_permission_after_write({{module_name|lower}}_regs);

endtask:valid_permission_access_mode_chk

function tc_{{module_name|lower}}_reg_access_permission::add_memory_access_mode(reg_collection regs); 
    access_permission_cfg cfg;
    cfg = access_permission_cfg::get();

    `uvm_info("",$sformatf("\033[1;36m get access mode \033[0m"),UVM_LOW)

    foreach(regs.regs[i])begin
        cfg.memory_access_mode[regs.regs[i].addr].wr_mode = regs.regs[i].write_mode;
        cfg.memory_access_mode[regs.regs[i].addr].rd_mode = regs.regs[i].read_mode;
        `uvm_info("",$sformatf("\033[1;36m Regsiter %s : ADDR[0x%0h] write_mode[%s] read_mode[%s]\033[0m",regs.regs[i].name,regs.regs[i].addr,regs.regs[i].write_mode,regs.regs[i].read_mode),UVM_LOW)
    end

endfunction

task tc_{{module_name|lower}}_reg_access_permission::ocds_{{module_name|lower}}_set(input bit ocds_en);

    //TODO 3. add ocds enable 

endtask : ocds_{{module_name|lower}}_set

task tc_{{module_name|lower}}_reg_access_permission::endinit_{{module_name|lower}}_e_se_set(input bit endinit,input bit safety_endinit);

    bit[31:0] rd_data;

    //SE
    se_e_permission_set(`{{module_name|upper}}_PROT_SE,safety_endinit);
    //E
    //TODO 1 prot_e_num > 1 modify the prot_e as follow
    //se_e_permission_set(prot_e_addr,endinit);
    se_e_permission_set(`{{module_name|upper}}_PROT_E,endinit);

endtask : endinit_{{module_name|lower}}_e_se_set


task tc_{{module_name|lower}}_reg_access_permission::write_{{module_name|lower}}_reg_with_access_permission(bit [31:0] addr,bit [31:0] data,bit is_valid=1,bit is_se_e = 0);

    access_permission_cfg cfg;
    cfg = access_permission_cfg::get();
    updata_accen_cfg(addr,is_valid,access_permission_cfg::WRITE);
    ocds_{{module_name|lower}}_set(cfg.ocds_en);  
    if(!is_se_e)
        endinit_{{module_name|lower}}_e_se_set(cfg.endinit,cfg.safe_endinit);

	//`uvm_info("",$sformatf("\033[1;36msafe_endinit[0x%0h] hprot[0x%0h]\033[0m",cfg.safe_endinit,cfg.hprot),UVM_LOW)

    if(is_valid==1)begin
        reg_write_with_permission(addr,data,cfg.hprot[1],cfg.master_id,cfg.vmid,0);
    end else begin
        reg_write_with_permission(addr,data,cfg.hprot[1],cfg.master_id,cfg.vmid,1);
        alm_reg_access_reg_chk_clr();
    end

endtask : write_{{module_name|lower}}_reg_with_access_permission

task tc_{{module_name|lower}}_reg_access_permission::read_{{module_name|lower}}_reg_with_access_permission(bit [31:0] addr,output bit[31:0] data,input bit is_valid=1);
    access_permission_cfg cfg; 
    cfg = access_permission_cfg::get();
    updata_accen_cfg(addr,is_valid,access_permission_cfg::READ);
    ocds_{{module_name|lower}}_set(cfg.ocds_en);    
    endinit_{{module_name|lower}}_e_se_set(cfg.endinit,cfg.safe_endinit);

    if(is_valid==1)begin
        reg_read_with_permission(addr,data,cfg.u_sv_mode,0);
    end else begin
        reg_read_with_permission(addr,data,cfg.u_sv_mode,1);
        alm_reg_access_reg_chk_clr();
    end

endtask : read_{{module_name|lower}}_reg_with_access_permission

`endif  //tc_{{module_name|lower}}_reg_access_permission_SV
