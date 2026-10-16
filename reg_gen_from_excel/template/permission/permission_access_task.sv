
`ifndef PERMISSION_ACCESS_TASK_SV
`define PERMISSION_ACCESS_TASK_SV

task se_e_permission_set(input bit[31:0] addr,input bit se_e);

    bit[31:0] rd_data;
  
    if(se_e)begin
        reg_read_with_permission(addr,rd_data);
        if(rd_data[2:0] == 'h0)begin
            reg_write_with_permission(addr,'h8000_000c);//NON_SE_e
            reg_write_with_permission(addr,'h8000_0009);//SE_e
        end else if(rd_data[2:0] == 'h4)begin
            reg_write_with_permission(addr,'h8000_0009);//SE_e
        end 
    end else begin
        reg_read_with_permission(addr,rd_data);
        if(rd_data[2:0] == 'h1 | rd_data[2:0] == 'h0)begin
            reg_write_with_permission(addr,'h8000_000c);//NON_SE_e
        end 
    end    

endtask

function updata_accen_cfg(bit [31:0] addr,bit is_valid,access_permission_cfg::bus_dir_type_e dir);
    string access_mode;
    access_permission_cfg cfg;
    cfg = access_permission_cfg::get();
    access_mode = cfg.gen_accen_mode(addr,dir);
    cfg.gen_accen_cfg_by_mode(access_mode,is_valid);
	`uvm_info("",$sformatf("\033[1;36maddr is 0x%0h\033[0m",addr),UVM_LOW)
	`uvm_info("",$sformatf("\033[1;36maccess_mode is %0s\033[0m",access_mode),UVM_LOW)
    cfg.print();
endfunction

task alm_reg_access_reg_chk_clr();
   
    //TODO 5. alm chk
    //`SIGNAL_VALUE_CHECKING(ccu_master_if.alm_ccu_access_req,1)
    //#($urandom_range(1,10));
    //ccu_master_if.alm_ccu_access_ack = 1;
    //wait(ccu_master_if.alm_ccu_access_req == 0);
    //ccu_master_if.alm_ccu_access_ack = 0;

endtask : alm_reg_access_reg_chk_clr

task reg_chk_with_permission(input bit [31:0] reg_addr,input bit [31:0] data,input bit [31:0] reg_mask=32'hffff_ffff);

    bit [31:0] act_data;
    bit [31:0] exp_data;

    reg_read_with_permission(reg_addr,act_data);
    exp_data = data & reg_mask;

    if(act_data != exp_data)begin
        `uvm_error(get_full_name(),$sformatf("check reg addr 0x%0h err wdata is 0x%0h ,expect_value is 0x%0h,but actual_value is 0x%0h",reg_addr,data,exp_data,act_data))
    end else begin
        `uvm_info(get_full_name(),$sformatf("check ok!  register 0x%h is 0x%h ",reg_addr,exp_data),UVM_LOW)
    end

endtask :reg_chk_with_permission

task verify_invalid_permission_before_write(reg_collection regs,output bit[31:0] val_before[$]);
 
    foreach(regs.regs[i]) begin
        reg_read_with_permission(regs.regs[i].addr, val_before[i]);
    end

endtask : verify_invalid_permission_before_write

task verify_invalid_permission_after_write(reg_collection regs,input bit[31:0] val_before[$]);

    bit[31:0] rd_data;

    `uvm_info(get_type_name(), $sformatf("Verifying after write"), UVM_LOW)    
    
    foreach(regs.regs[i]) begin
        reg_read_with_permission(regs.regs[i].addr, rd_data);
        if(rd_data != val_before[i])begin
            `uvm_error(get_full_name(),$sformatf("\033[1;31m Compare error !!! Details as follows \033[0m"))

                `uvm_error(get_type_name(), $sformatf(
                          "\033[1;31m Register %s (0x%0h) access_mode is %s : unexpected change after write invalid permission (0x%0h -> 0x%0h)  Details as follows \033[0m",
                          regs.regs[i].name, regs.regs[i].addr, regs.regs[i].write_mode, 
                          val_before[i], rd_data))
            regs.regs[i].print_info();
        end

    end

endtask : verify_invalid_permission_after_write

task verify_valid_permission_after_write (reg_collection regs); 

    bit[31:0] rd_data,exp_data;

    foreach(regs.regs[i])begin
        reg_read_with_permission(regs.regs[i].addr, rd_data);
        exp_data =  regs.regs[i].wr_data & regs.regs[i].reg_msk ;
        if(regs.regs[i].write_mode == "BE") continue;
        if(rd_data != exp_data)begin
                `uvm_error(get_type_name(), $sformatf(
                          "\033[1;31m  Compare error !!! Register %s (0x%0h) access_mode is %s : unexpected change after write valid permission (0x%0h -> 0x%0h)  Details as follows \033[0m",
                          regs.regs[i].name, regs.regs[i].addr, regs.regs[i].write_mode, 
                          exp_data , rd_data))
            regs.regs[i].print_info();
        end
    end

endtask : verify_valid_permission_after_write

`endif  //PERMISSION_ACCESS_TASK_SV
