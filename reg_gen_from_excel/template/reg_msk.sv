`ifndef {{module_name|upper}}_REG_MSK_SVH
`define {{module_name|upper}}_REG_MSK_SVH

`define {{module_name|upper}}_REG_ADDR_GAP               {{reg_data_size}}'h{{"{:0x}".format(reg_gap)}}
`define {{module_name|upper}}_SADDR                      {{reg_data_size}}'h{{"{:0x}".format(reg_saddr)}}
`define {{module_name|upper}}_EADDR                      {{reg_data_size}}'h{{"{:0x}".format(reg_eaddr)}}

`define REG_WRITE_BY_ASCENDING         1
`define REG_WRITE_BY_DESCENDING        0

//====== reg addr msk define start of {{module_name|upper}} ====== 
{% for register in registers %}
`define {{(module_name~"_"~register.reg_name~"_MSK")|upper|trim|custom_ljust(60)}}{{reg_data_size}}'h{{"{:0x}".format(register.calculate_reg_mask(reserved_attr))}}{% endfor %}

//====== reg reset value define start of {{module_name|upper}} ====== 
{% for register in registers %}
`define {{(module_name~"_"~register.reg_name~"_RSTVAL")|upper|trim|custom_ljust(60)}}{{reg_data_size}}'h{{"{:0x}".format(register.get_register_reset_value_int())}}{% endfor %}

{% for register in registers %}
//====== {{register.reg_name|trim|upper}} 'h{{"{:0x}".format(register.get_register_address_offset_value_int())}} ======
{% for field in register.fields%}{% if  field.field_name != "reserved"-%}
`define {{(module_name~"_"~register.reg_name~"_"~field.field_name~"_POS")|upper|trim|custom_ljust(60)}}{{field.start_bit}}
`define {{(module_name~"_"~register.reg_name~"_"~field.field_name~"_MSK")|upper|trim|custom_ljust(60)}}('h{{"{:0x}".format(field.get_field_msk())}} << `{{module_name|upper~"_"~register.reg_name|trim|upper}}_{{field.field_name|trim|upper}}_POS)
{% endif %}{% endfor %}{% endfor %}
`endif //{{module_name|upper}}_REG_MSK_SVH 
