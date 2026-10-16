{% macro hex_const(v, width) -%}
{{ "%d'h%s"|format(width, (v * (width//8))[:width//2] | lower) }}
{%- endmacro %}
{% set reg_op = 'reg' if add_reg_name_to_bus_opt == 0 else ((module_name|lower)~'_reg')%}

{%- if add_reg_name_to_bus_opt == true -%}
`ifndef {{module_name|upper}}_COMMON_REGISTER_CHK_TASK_SV
`define {{module_name|upper}}_COMMON_REGISTER_CHK_TASK_SV
{%- else -%}
`ifndef COMMON_REGISTER_CHK_TASK_SV
`define COMMON_REGISTER_CHK_TASK_SV
{%- endif %}

task {{reg_op}}_write (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] wdata); 

    {{bus_write_opt}}(reg_addr,wdata);
    `uvm_info(get_full_name(),$sformatf("bus write register [0x%h]  wdata [0x%h] ok ! ",reg_addr,wdata),UVM_LOW)

endtask :{{reg_op}}_write

task {{reg_op}}_read (input bit [{{reg_data_size-1}}:0] reg_addr,output bit [{{reg_data_size-1}}:0] rdata); 

    {{bus_read_opt}}(reg_addr,rdata);

endtask :{{reg_op}}_read

task {{reg_op}}_check (input bit [{{reg_data_size-1}}:0] reg_addr,input bit [{{reg_data_size-1}}:0] data,input bit [{{reg_data_size-1}}:0] reg_mask = {{hex_const('ff',reg_data_size)}}); 

    bit [{{reg_data_size-1}}:0] act_data;
    bit [{{reg_data_size-1}}:0] exp_data;

    {{reg_op}}_read(reg_addr,act_data);
    exp_data = data & reg_mask;

    if(act_data != exp_data)begin
        `uvm_error(get_full_name(),$sformatf("check reg addr 0x%0h error !!!!!!!!!! wdata is 0x%0h ,expect_value is 0x%0h,but actual_value is 0x%0h",reg_addr,data,exp_data,act_data))
    end else begin
        `uvm_info(get_full_name(),$sformatf("check ok!  register 0x%h is 0x%h ",reg_addr,exp_data),UVM_LOW)
    end

endtask :{{reg_op}}_check

task check_initial_reset_state(reg_collection regs);

    bit[{{reg_data_size-1}}:0]  data;
    
    `uvm_info(get_type_name(), "Checking initial reset state", UVM_LOW)
    
    foreach(regs.regs[i]) begin
        {{reg_op}}_read(regs.regs[i].addr, data);
        if(data !== regs.regs[i].rst_val) begin
            `uvm_error(get_type_name(), $sformatf(
                      "Register %s (0x%0h) initial reset value mismatch: expected 0x%0h, got 0x%0h",
                      regs.regs[i].name, regs.regs[i].addr, regs.regs[i].rst_val, data))
        end
    end

endtask : check_initial_reset_state

{%if reset_field_en -%}
task verify_reset_domain_before_rst(reg_collection regs,output bit[{{reg_data_size-1}}:0] val_before[$]);
 
    foreach(regs.regs[i]) begin
        {{reg_op}}_read(regs.regs[i].addr, val_before[i]);
    end

endtask : verify_reset_domain_before_rst

task verify_reset_domain_after_rst(reg_collection regs,input bit[{{reg_data_size-1}}:0] val_before[$],reg_info_cfg::rst_domain_e rst_type);

    bit[{{reg_data_size-1}}:0] val_after[$];

    `uvm_info(get_type_name(), $sformatf("Verifying %s reset domain", rst_type.name()), UVM_LOW)    
    
    foreach(regs.regs[i]) begin
        {{reg_op}}_read(regs.regs[i].addr, val_after[i]);
    end
    
    check_reset_results(regs,rst_type, val_before, val_after);

endtask : verify_reset_domain_after_rst


function void check_reset_results(reg_collection regs,reg_info_cfg::rst_domain_e rst_type, 
                                         bit[{{reg_data_size-1}}:0] val_before[$], 
                                         bit[{{reg_data_size-1}}:0] val_after[$]);
    foreach(regs.regs[i]) begin
        bit is_affected;
       
        case(rst_type)
            {% for domain in module_rst_list %}
            reg_info_cfg::{{ domain.name|custom_ljust(25)}}         :is_affected = (regs.regs[i].domain {%- if domain.is_global %} <={%- else %} =={%- endif %} reg_info_cfg::{{ domain.name|custom_ljust(25)}});{% endfor %}
            default:   is_affected = 0;

        endcase

        if(is_affected) begin
            if(val_after[i] !== regs.regs[i].rst_val) begin
                `uvm_error(get_type_name(), $sformatf(
                          "Register %s (0x%0h) in %s domain: after %s reset, expected 0x%0h, got 0x%0h",
                          regs.regs[i].name, regs.regs[i].addr, regs.regs[i].domain.name(), rst_type.name(),
                          regs.regs[i].rst_val, val_after[i]))
            end
            else begin
                `uvm_info(get_type_name(), $sformatf(
                          "Register %s (0x%0h) in %s domain: correctly reset by %s reset",
                          regs.regs[i].name, regs.regs[i].addr, regs.regs[i].domain.name(), rst_type.name()), UVM_LOW)
            end
        end
        else begin
            if(val_after[i] !== val_before[i]) begin
                `uvm_error(get_type_name(), $sformatf(
                          "Register %s (0x%0h) in %s domain: unexpected change after %s reset (0x%0h -> 0x%0h)",
                          regs.regs[i].name, regs.regs[i].addr, regs.regs[i].domain.name(), rst_type.name(),
                          val_before[i], val_after[i]))
            end
        end
    end

endfunction : check_reset_results
{%- endif %}


`endif  //common_register_chk_task_SV
