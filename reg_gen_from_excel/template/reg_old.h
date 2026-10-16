{%- macro get_field_access(access) -%}
    {%- set normalized_access = access | upper if access else '' -%}
    {%- set access_map = {
        "RO": "__I",
        "RW": "__IO",
        "RC_R": "__I",
        "RC_W1": "__IO",
        "RC_W0": "__IO",
        "RS": "__I",
        "WO": "__O"
    } -%}
    {{ access_map.get(normalized_access, 'unknown') }}
{%- endmacro -%}

#ifndef __{{module_name|upper}}_REG_H__
#define __{{module_name|upper}}_REG_H__

{% for register in registers %}
//================================ {{register.reg_name|trim|upper}} 0x{{"{:0x}".format(register.get_register_address_offset_value_int())}} =================================
{% for field in register.fields%}{% if  field.field_name != "reserved"-%}
#define {{(register.reg_name~"_"~field.field_name~"_POS")|upper|trim|custom_ljust(60)}}{{field.start_bit}}
#define {{(register.reg_name~"_"~field.field_name~"_MSK")|upper|trim|custom_ljust(60)}}(0x{{"{:0x}".format(field.get_field_msk())|upper}}UL << {{register.reg_name|trim|upper}}_{{field.field_name|trim|upper}}_POS)
{% endif %}{% endfor %}{% endfor %}

{% for register in registers %}
//====== reg addr msk define start of {{module_name|upper}} ====== 
#define {{(module_name~"_"~register.reg_name~"_MSK")|upper|trim|custom_ljust(60)}}0x{{"{:0x}".format(register.calculate_reg_mask(reserved_attr))}}{% endfor %}

//====== reg reset value define start of {{module_name|upper}} ====== 
{% for register in registers %}
#define {{(module_name~"_"~register.reg_name~"_RSTVAL")|upper|trim|custom_ljust(60)}}0x{{"{:0x}".format(register.get_register_reset_value_int())}}{% endfor %}


typedef volatile struct {
{%- set ns = namespace(reserved_index = 0,address_offset_count = 0) -%}
{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{%- if register.address_offset_value_int != ns.address_offset_count %}
{{'\t'}}{{("     uint"~reg_data_size~"_t")|custom_ljust(30)}}RESERVED{{ns.reserved_index}}[{{((((register.address_offset_value_int-ns.address_offset_count)/reg_gap)|int)~"]")|custom_ljust(10)}};
{%- set ns.reserved_index = ns.reserved_index +1 -%}
{%- endif %}
{%- set access_data = namespace(str="") -%}
        {%- for field in register.fields|sort(attribute='start_bit',reverse=true) -%}
            {%- set access_data.str = "__I " if get_field_access(field.field_attribute) == "__I" else "__IO" -%}
        {%- endfor %}
{{'\t'}}{{(access_data.str~" uint"~reg_data_size~"_t")|custom_ljust(30)}}{{register.reg_name|custom_ljust(20)}};// Address Offset: 0x{{"{:08x}".format(register.get_register_address_offset_value_int())}}
{%- set ns.address_offset_count = register.address_offset_value_int + reg_gap -%}
{% endfor %}
} {{module_name|upper}}_TYPEDEF;

#endif //{{module_name|upper}}_REG_H 

