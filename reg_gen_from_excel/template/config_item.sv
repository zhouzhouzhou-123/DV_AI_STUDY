{% set data_size = ("rand bit ["~(reg_data_size-1)~":0]") %}

`ifndef {{module_name|upper}}_CONFIG_ITEM_SV
`define {{module_name|upper}}_CONFIG_ITEM_SV

class {{module_name|lower}}_config_item extends uvm_sequence_item;

{{'\t'~("rand bit ["~(reg_data_size-1)~":0]")|custom_ljust(40)}}reserved;

{% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{{'\t'}}//===================== {{register.reg_name|upper|trim}} 0x{{"{:08x}".format(register.get_register_address_offset_value_int())}} =====================
{{'\t'}}{{(data_size|custom_ljust(40))}}{{register.reg_name|lower|trim|custom_ljust(40)}};{{'\n'}}
    {%- for field in register.fields|sort(attribute='start_bit',reverse=true) %}
        {%- if field.field_name != "reserved" -%}
        {%- if field.field_attribute in ["RW","WO"] -%}
            {%- set ns = namespace(is_rand = "rand ") -%}
        {%- else -%}
            {%- set ns = namespace(is_rand = "") -%}
        {%- endif -%}
        {%- if field.start_bit == field.end_bit -%}
            {{'\t'~(ns.is_rand~"bit")|lower|custom_ljust(40)}}{{((register.reg_name)~"_"~(field.field_name))|lower|trim|custom_ljust(40)}};{{'\n'}}
        {%- else -%}
            {{'\t'~(ns.is_rand~"bit ["~(field.get_field_size()-1)~":0]")|lower|custom_ljust(40)}}{{((register.reg_name)~"_"~(field.field_name))|lower|trim|custom_ljust(40)}};{{'\n'}}
        {%- endif -%}
        {% endif -%}
    {%- endfor -%}
{{'\n'}}
{%- endfor -%}

    `uvm_object_utils_begin({{module_name|lower}}_config_item)
        `uvm_field_int({{("reserved")|custom_ljust(40)}},UVM_ALL_ON){{'\n'}}
{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{{'\t\t'}}`uvm_field_int({{register.reg_name|lower|trim|custom_ljust(40)}},UVM_ALL_ON){{'\n'}}
    {%- for field in register.fields|sort(attribute='start_bit',reverse=true) -%}
        {%- if field.field_name != "reserved" -%}    
        {{'\t\t'}}`uvm_field_int({{(register.reg_name~"_"~field.field_name)|lower|trim|custom_ljust(40)}},UVM_ALL_ON){{'\n'}}
        {%- endif -%}
    {%- endfor -%}
{%- endfor -%}
{{'\t'}}`uvm_object_utils_end{{'\n'}}{{'\n'}}


{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{{'\t'}}constraint 	{{register.reg_name|lower|trim}}_c { 
{{'\t\t'}}{{register.reg_name|lower|trim}} == {
    {%- for field in register.fields|sort(attribute='start_bit',reverse=true) -%}
        {%- if field.field_name != "reserved" -%}
            {{(register.reg_name~"_"~field.field_name)|lower|trim}}
        {%- else -%}
            {%-if (field.get_field_size() == 1)-%}
                reserved[{{field.start_bit}}]
            {%- else -%}
                reserved[{{field.end_bit}}:{{field.start_bit}}]
            {%- endif -%}
        {%- endif -%}
        {%- if not loop.last -%}
            {{","}}
        {%- endif -%}
    {%- endfor -%}};
    {%- for field in register.fields|sort(attribute='start_bit',reverse=true) -%}
        {%- if field.field_attribute in ["WO"] -%}
            {{'\t\t'}}soft {{(register.reg_name~"_"~field.field_name)|lower|trim|custom_ljust(40)}} == 0;{{'\n'}}
        {%- endif -%}
    {%- endfor -%}
    }{{'\n'}}
{%- endfor %}
endclass:{{module_name|lower}}_config_item

`endif // {{module_name|upper}}_CONFIG_ITEM_SV
