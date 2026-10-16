
//====== reg addr offset define start of {{module_name|upper|trim}} ======{{'\n'}}
{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
`define {{(module_name~"_"~register.reg_name~"_OFFSET")|upper|trim|custom_ljust(60)}}'h{{"{:0x}".format(register.get_register_address_offset_value_int())}}{{'\n'}}
{%- endfor -%}
{{'\n'}}
//====== reg addr define start of {{module_name|upper|trim}} ======{{'\n'}}
{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{% if register.register_num != None -%}
`define {{(module_name~"_"~register.reg_name~"(i)")|upper|trim|custom_ljust(60)}}`{{module_name|upper}}_SADDR+`{{(module_name~"_"~register.reg_name)|upper|trim}}{{"_OFFSET+I*'h"~(register.order_offset[2:])}}{{'\n'}}    
{%- else -%}
`define {{(module_name~"_"~register.reg_name)|upper|trim|custom_ljust(60)}}`{{module_name|upper}}_SADDR+`{{(module_name~"_"~register.reg_name~"_OFFSET")|upper|trim}}{{'\n'}}
{%- endif -%}
{%- endfor -%}
