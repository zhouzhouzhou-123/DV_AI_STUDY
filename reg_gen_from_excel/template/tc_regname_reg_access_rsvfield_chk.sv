// ----------------------------------------------------
// Copyright(C) 2025 Chipsea All rights reserved.
// File Name: tc_{{module_name|lower}}_reg_access_rsvfield_chk.sv
// Author:    zhouxk
// Email:     zhouxk@chipsea.com
// Date:      2025-08-12
// ----------------------------------------------------
{% macro hex_const(v, width) -%}
{{ "%d'h%s"|format(width, (v * (width//8))[:width//2] | lower) }}
{%- endmacro %}
`ifndef TC_{{module_name|upper}}_REG_ACCESS_RSVFIELD_CHK_SV
`define TC_{{module_name|upper}}_REG_ACCESS_RSVFIELD_CHK_SV

`define {{module_name|upper}}_EADDR_T (`{{module_name|upper}}_EADDR  & (~('h3))) 

class tc_{{module_name|lower}}_reg_access_rsvfield_chk extends basetest;

    reg_info_t {{module_name|lower}}_regs[$];

    bit [{{reg_data_size-1}}:0] reg_addr_q[$]= '{
        {% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
        `{{(module_name~"_"~register.reg_name)|trim|upper}}{%if not loop.last %},{% endif %}  
        {%- endfor -%}
        {{'\n\t\t'}}};
        
    bit [{{reg_data_size-1}}:0] reg_mask_q[$]= '{
        {% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
        `{{(module_name~"_"~register.reg_name)|trim|upper}}_Msk{%if not loop.last %},{% endif %}  
        {%- endfor -%}
        {{'\n\t\t'}}};

    bit [{{reg_data_size-1}}:0] reg_rstval_q[$]= '{
        {% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
        `{{(module_name~"_"~register.reg_name)|trim|upper}}_RSTVAL{%if not loop.last %},{% endif %}  
        {%- endfor -%}
        {{'\n\t\t'}}};

    `uvm_component_utils(tc_{{module_name|lower}}_reg_access_rsvfield_chk)

    function new(string name = "tc_{{module_name|lower}}_reg_access_rsvfield_chk", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new 

    extern virtual task tc_proc();
    extern virtual function void build_phase(uvm_phase phase);    
    extern virtual task hw_reset_chk_proc(); 
    extern virtual task reg_chk_proc(); 
    extern virtual task reg_read_write_check (input bit [{{reg_data_size-1}}:0] reg_addr[$],input bit [{{reg_data_size-1}}:0] wdata[$],input bit [{{reg_data_size-1}}:0] reg_mask[$]); 
    extern virtual task reg_rstval_check (input bit [{{reg_data_size-1}}:0] reg_addr[$], reg_rstval[$]); 
    extern virtual task reg_write (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] wdata); 
    extern virtual task reg_read (input bit [{{reg_data_size-1}}:0] reg_addr,output bit [{{reg_data_size-1}}:0] rdata); 
    extern virtual task reg_check (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] data,input bit [{{reg_data_size-1}}:0] reg_mask = {{hex_const('ff',reg_data_size)}}); 

endclass : tc_{{module_name|lower}}_reg_access_rsvfield_chk 

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::tc_proc();

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

    reg_rstval_check(reg_addr_q,reg_rstval_q);

    reg_read_write_check(reg_addr_q,wdata_q,reg_mask_q);

endtask : reg_chk_proc

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_write (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] wdata); 

    {{bus_write_opt}}(reg_addr,wdata);
    `uvm_info(get_full_name(),$sformatf("bus write register [0x%h]  wdata [0x%h] ok ! ",reg_addr,wdata),UVM_LOW)

endtask :reg_write

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_read (input bit [{{reg_data_size-1}}:0] reg_addr,output bit [{{reg_data_size-1}}:0] rdata); 

    {{bus_read_opt}}(reg_addr,rdata);

endtask :reg_read

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_rstval_check (input bit [{{reg_data_size-1}}:0] reg_addr[$], reg_rstval[$]); 

    foreach(reg_addr[i])begin
        reg_check(reg_addr[i],reg_rstval[i]);
    end

endtask : reg_rstval_check

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_check (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] data,input bit [{{reg_data_size-1}}:0] reg_mask = {{hex_const('ff',reg_data_size)}}); 

    bit [{{reg_data_size-1}}:0] act_data;
    bit [{{reg_data_size-1}}:0] exp_data;

    reg_read(reg_addr,act_data);
    exp_data = data & reg_mask;

    if(act_data != exp_data)begin
        `uvm_error(get_full_name(),$sformatf("check reg addr 0x%0h error !!!!!!!!!! wdata is 0x%0h ,expect_value is 0x%0h,but actual_value is 0x%0h",reg_addr,data,exp_data,act_data))
    end else begin
        `uvm_info(get_full_name(),$sformatf("check ok!  register 0x%h is 0x%h ",reg_addr,exp_data),UVM_LOW)
    end

endtask :reg_check

task tc_{{module_name|lower}}_reg_access_rsvfield_chk::reg_read_write_check(input bit [{{reg_data_size-1}}:0] reg_addr[$],input bit [{{reg_data_size-1}}:0] wdata[$],input bit [{{reg_data_size-1}}:0] reg_mask[$]);

    bit seq;
    bit [{{reg_data_size-1}}:0] rdata;
    bit [{{reg_data_size-1}}:0] temp_q[$];
    bit [{{reg_data_size-1}}:0] random_wdata_q[$];

    int j,h,l;

    //TODO add skip reg message to queues
    //example
    //bit [31:0] skip_chk_addr_q[$]   = '{`CCU_DTSCLK,`CCU_OSCCON};    
    //bit [31:0] skip_chk_rstval_q[$] = '{`CCU_DTSCLK_RSTVAL,`CCU_OSCCON_RSTVAL};
    bit [{{reg_data_size-1}}:0] skip_chk_addr_q[$]   = '{};
    bit [{{reg_data_size-1}}:0] skip_chk_rstval_q[$] = '{};

    `uvm_info("","reg_read_write check",UVM_LOW)

    foreach(wdata[i])begin 
        if(i inside {[3:5],[9:10]})begin
        	seq = `REG_WRITE_BY_DESCENDING;
        	h   = `{{module_name|upper}}_EADDR_T;
        end else begin
        	seq = `REG_WRITE_BY_ASCENDING;
        	h   = `{{module_name|upper}}_SADDR;
        end

        if(i >= 6)begin
            foreach(reg_addr[q])begin
    	        random_wdata_q[q] = $urandom_range(0,{{hex_const('ff',reg_data_size)}});
            end
            `uvm_info("",$sformatf("random_wdata_q is %p",random_wdata_q),UVM_LOW)
        end

        l = 0;
        `uvm_info("",$sformatf("current wirte wdata is 0x%0h ",wdata[i]),UVM_LOW)

        while(1)begin
        	if(seq)
        		j = h + `{{module_name|upper}}_REG_ADDR_GAP * l;
        	else
        		j = h - `{{module_name|upper}}_REG_ADDR_GAP * l;
        	l++;

        	if(j > `{{module_name|upper}}_EADDR_T | j < `{{module_name|upper}}_SADDR)begin
        		l = 0;
        		break;
        	end

            if(skip_chk_addr_q.size() > 0)
                if(j inside skip_chk_addr_q) continue;

        	temp_q = reg_addr.find(x)with(x == j);
            if(temp_q.size() == 0)begin
        	    reg_write(j,wdata[i]);
            end else begin
        		foreach(reg_addr[k])begin
                    if(reg_addr[k]==j)begin
                        if(i<6)
        	                reg_write(j,wdata[i]);
                        else
        	                reg_write(j,random_wdata_q[k]);
                    end
                end
            end
        	if(temp_q.size() == 0)begin 
        		`uvm_info("","chk rsv field return 0",UVM_LOW) 
        		reg_check(j,0,0); 
        	end else begin 
        		foreach(reg_addr[k])begin
                    if(reg_addr[k]==j)begin
                        if(i<6)
        		    		reg_check(reg_addr[k],wdata[i],reg_mask[k]);
                        else
           		    		reg_check(reg_addr[k],random_wdata_q[k],reg_mask[k]);
                    end
        		end
        	end
        end

        foreach(reg_addr[k])begin
            if((skip_chk_addr_q.size() > 0) & (reg_addr[k] inside skip_chk_addr_q))begin
                continue;
            end else begin
                if(i<6)
            	    reg_check(reg_addr[k],wdata[i],reg_mask[k]);
                else
            		reg_check(reg_addr[k],random_wdata_q[k],reg_mask[k]);
            end
        end

        if(skip_chk_addr_q.size() > 0)begin
            foreach(skip_chk_addr_q[m])begin
                reg_check(skip_chk_addr_q[m],skip_chk_rstval_q[m]);
            end
        end

        random_wdata_q.delete();
    end

endtask : reg_read_write_check

`endif //TC_{{module_name|upper}}_reg_access_rsvfield_chk_sv 
