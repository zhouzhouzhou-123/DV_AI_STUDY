{% macro hex_const(v, width) -%}
{{ "%d'h%s"|format(width, (v * (width//8))[:width//2] | lower) }}
{%- endmacro %}

{% set reg_op = 'reg' if add_reg_name_to_bus_opt == 0 else ((module_name|lower)~'_reg')%}

`ifndef TC_{{module_name|upper}}_REG_ACCESS_RSVFIELD_CHK_SV
`define TC_{{module_name|upper}}_REG_ACCESS_RSVFIELD_CHK_SV

`define {{module_name|upper}}_EADDR_T (`{{module_name|upper}}_EADDR  & (~('h3))) 

class tc_{{module_name|lower}}_reg_access_rsvfield_chk extends basetest;

    reg_collection {{module_name|lower}}_regs;
    {{module_name|lower}}_config_item   mo_{{module_name|lower}}_item;

    `uvm_component_utils(tc_{{module_name|lower}}_reg_access_rsvfield_chk)

    function new(string name = "tc_{{module_name|lower}}_reg_access_rsvfield_chk", uvm_component parent = null);
        super.new(name, parent);
        this.mo_{{module_name|lower}}_item = {{module_name|lower}}_config_item::type_id::create("mo_{{module_name|lower}}_item");         

    endfunction : new 

    extern virtual task tc_proc();
    extern virtual task hw_reset_chk_proc(); 
    extern virtual task reg_chk_proc(); 
    extern virtual task reg_read_write_check (reg_collection regs,input bit [{{reg_data_size-1}}:0] wdata[$],module_saddr,module_eaddr); 

endclass : tc_{{module_name|lower}}_reg_access_rsvfield_chk 

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::tc_proc();

    {{module_name|lower}}_regs = reg_collection::type_id::create("{{module_name|lower}}_regs");
    
    initialize_{{module_name|lower}}_reg_info(`{{module_name|upper}}_SADDR,{{module_name|lower}}_regs,mo_{{module_name|lower}}_item);
   
    //example to use the reg_collection func find_by_name \ find_by_addr
    //rcu_regs.find_by_name("rcu_cpu0bootcfg").rst_val = `RCU_CPU0BOOTCFG_RSTVAL;
    //rcu_regs.find_by_addr(`RCU_CPU0BOOTCFG).rst_val = `RCU_CPU0BOOTCFG_RSTVAL;

    {{module_name|lower}}_regs.print_all();

    hw_reset_chk_proc();
    reg_chk_proc();

endtask : tc_proc

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::hw_reset_chk_proc();
    uvm_reg_hw_reset_seq   o_reg_hw_reset_seq;

    o_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("o_reg_hw_reset_seq", this);
    //uvm_resource_db#(bit)::set({"REG::", mo_env.mo_regmodel.xxx.get_full_name()}, "NO_REG_TESTS", 1, this);
    o_reg_hw_reset_seq.model = mo_env.mo_regmodel;
    o_reg_hw_reset_seq.start(null);

endtask : hw_reset_chk_proc

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_chk_proc();

    bit [{{reg_data_size-1}}:0] temp_data;
    bit [{{reg_data_size-1}}:0] wdata_q[$]= '{
        {{hex_const('aa',reg_data_size)}},{{hex_const('55',reg_data_size)}},
        {{hex_const('ff',reg_data_size)}},{{hex_const('0',reg_data_size)}},
        {{hex_const('5a',reg_data_size)}},{{hex_const('a5',reg_data_size)}}
        };

    for(int i=6;i<=10;i=i+1)begin
    	temp_data = $urandom_range(0,{{hex_const('ff',reg_data_size)}});
    	wdata_q = {wdata_q[0:i-1],temp_data,wdata_q[i:$]};
    end

    check_initial_reset_state({{module_name|lower}}_regs);

    reg_read_write_check({{module_name|lower}}_regs,wdata_q,`{{module_name|upper}}_SADDR,`{{module_name|upper}}_EADDR_T);

endtask : reg_chk_proc

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_read_write_check(reg_collection regs,input bit [{{reg_data_size-1}}:0] wdata[$],module_saddr,module_eaddr);

    bit seq;
    reg_info_cfg addr_found;

    int j,h,l;

    //TODO add skip reg addr offset message to queues
    //example
    //bit [31:0] skip_chk_addr_q[$]   = '{`CCU_DTSCLK_OFFSET,`CCU_OSCCON_OFFSET};    
    bit [{{reg_data_size-1}}:0] skip_chk_addr_q[$]   = '{};

    `uvm_info("","reg_read_write check",UVM_LOW)

    foreach(skip_chk_addr_q[i])begin
        skip_chk_addr_q[i] = skip_chk_addr_q[i]+module_saddr;
        `uvm_info("",$sformatf("skip_chk_addr_q is %p",skip_chk_addr_q),UVM_LOW)
    end

    foreach(wdata[i])begin 
        if(i inside {[3:5],[9:10]})begin
        	seq = `REG_WRITE_BY_DESCENDING;
        	h   = module_eaddr;
        end else begin
        	seq = `REG_WRITE_BY_ASCENDING;
        	h   = module_saddr;
        end

        if(i >= 6)begin
            //mo_{{module_name|lower}}_item.randomize();
            //initialize_{{module_name|lower}}_reg_info(module_saddr,regs,mo_{{module_name|lower}}_item);
            //regs.print_all();
            foreach(regs.regs[q])begin
                regs.regs[q].wr_data = $urandom_range(0,{{hex_const('ff',reg_data_size)}});
            end
        end else begin
            foreach(regs.regs[q])begin
                regs.regs[q].wr_data = wdata[i];
                regs.regs[q].print_info();
            end
        end

        l = 0;
        `uvm_info("",$sformatf("current wirte wdata is 0x%0h ",wdata[i]),UVM_LOW)

        while(1)begin
        	if(seq)
        		j = h + `{{module_name|upper}}_REG_ADDR_GAP * l;
        	else
        		j = h - `{{module_name|upper}}_REG_ADDR_GAP * l;
        	l++;

        	if(j > module_eaddr | j < module_saddr)begin
        		l = 0;
        		break;
        	end

            addr_found = regs.find_by_addr(j);
            if(addr_found == null)begin
        	    {{reg_op}}_write(j,wdata[i]);
        		`uvm_info("","chk rsv field return 0",UVM_LOW) 
        		{{reg_op}}_check(j,0,0); 
            end else begin
        		foreach(regs.regs[k])begin
                    if(regs.regs[k].addr == j)begin
                        if((skip_chk_addr_q.size() > 0) & (regs.regs[k].addr inside skip_chk_addr_q))begin
                            {{reg_op}}_check(regs.regs[k].addr,regs.regs[k].rst_val);
                            continue;
                        end
                        {{reg_op}}_write(regs.regs[k].addr,regs.regs[k].wr_data);    
                        {{reg_op}}_check(regs.regs[k].addr,regs.regs[k].wr_data,regs.regs[k].reg_msk);                          
                    end
                end
            end
        end

        foreach(regs.regs[k])begin
            if((skip_chk_addr_q.size() > 0) & (regs.regs[k].addr inside skip_chk_addr_q))begin
                {{reg_op}}_check(regs.regs[k].addr,regs.regs[k].rst_val);                
            end else begin
                {{reg_op}}_check(regs.regs[k].addr,regs.regs[k].wr_data,regs.regs[k].reg_msk);                          
            end
        end
    end

endtask : reg_read_write_check

`endif //TC_{{module_name|upper}}_reg_access_rsvfield_chk_sv 
