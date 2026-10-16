
function void initialize_{{module_name|lower}}_reg_info(bit[{{reg_data_size-1}}:0] base_addr,ref reg_collection regs_out,ref {{module_name}}_config_item mo_item);

    reg_info_cfg reg_item;
    
    regs_out.clear_reg();

    {% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
    {% if register.register_num != None -%}
    {%- set reg_list = [] -%}
    {%- set reg_addr_list = [] -%}
    {%- for i in range(register.register_num|int) -%}
        {%- set new_item = module_name|lower~"_"~register.reg_name|lower~"[%d]"|format(i) -%}
        {%- set addr_hex = "+'h"~(register.order_offset[2:])~ "*"~ i -%}
        {%- set addr_str = "`"~(module_name~"_"~register.reg_name)|trim|upper~"_OFFSET"~addr_hex ~"+ base_addr" -%}
        {%- set data_str = "mo_item."~(register.reg_name|lower~"[%d]"|format(i)) -%}
        {%- set _=reg_list.append((new_item,addr_str,data_str)) -%}
    {% endfor %}
    {% for new_item,addr,data in reg_list -%}
    reg_item = reg_info_cfg::type_id::create("{{new_item}}");
    reg_item.addr = {{addr}};
    reg_item.rst_val = `{{(module_name~"_"~register.reg_name)|trim|upper}}_RSTVAL;
    reg_item.reg_msk = `{{(module_name~"_"~register.reg_name)|trim|upper}}_MSK;
    reg_item.wr_data = {{data}};
    reg_item.name = "{{new_item}}";
{%if access_mode_en -%}   
    {{'\t'}}reg_item.read_mode = "{{register.read_mode}}";
    reg_item.write_mode = "{{register.write_mode}}";
{% endif -%}    
{%if reset_field_en -%}
    {{'\t'}}reg_item.domain = reg_info_cfg::{{register.reset_field|upper}};
{%- endif -%}
    {{'\t'}}regs_out.add_reg(reg_item);
    {{'\n\t'}}
    {% endfor %}
    {%- else -%}
    reg_item = reg_info_cfg::type_id::create("{{(module_name~"_"~register.reg_name)|trim|lower}}");
    reg_item.addr = `{{(module_name~"_"~register.reg_name)|trim|upper}}_OFFSET + base_addr;
    reg_item.rst_val = `{{(module_name~"_"~register.reg_name)|trim|upper}}_RSTVAL;
    reg_item.reg_msk = `{{(module_name~"_"~register.reg_name)|trim|upper}}_MSK;
    reg_item.wr_data = mo_item.{{(register.reg_name)|trim|lower}};
    reg_item.name = "{{(module_name~"_"~register.reg_name)|trim|lower}}";
{%if access_mode_en -%}   
    {{'\t'}}reg_item.read_mode = "{{register.read_mode}}";
    reg_item.write_mode = "{{register.write_mode}}";
{% endif -%}    
{%if reset_field_en -%}
    {{'\t'}}reg_item.domain = reg_info_cfg::{{register.reset_field|upper}};
{%- endif -%}
    {{'\t'}}regs_out.add_reg(reg_item);
    {{'\n\t'}}
    {%- endif %}
    {%- endfor -%}
    {{'\n'}}
endfunction : initialize_{{module_name|lower}}_reg_info

