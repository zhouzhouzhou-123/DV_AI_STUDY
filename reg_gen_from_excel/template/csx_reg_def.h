
#ifndef __CSX{{module_name|upper}}_REGDEF_H__
#define __CSX{{module_name|upper}}_REGDEF_H__
#include "Csx_RegTypes.h"

{% for register in registers %}
typedef struct  _Csx_{{module_name|upper}}_{{register.reg_name|upper}}_Bits{
{% set ns = namespace(reserved_count = 0) -%}
    {%- for field in register.fields|sort(attribute='start_bit',reverse=false) -%}
        {%- if field.field_name != "reserved" -%}
        {{'\t'}}Csx_Reg_U{{reg_data_size}}Bit {{(field.field_name)|upper|trim|custom_ljust(60)}}: {{ field.get_field_size()}};
        {%- else -%}
        {{'\t'}}Csx_Reg_U{{reg_data_size}}Bit {{("RESERVED"~ns.reserved_count)|upper|trim|custom_ljust(60)}}: {{ field.get_field_size()}};
            {%- set ns.reserved_count = ns.reserved_count +1 -%}
        {% endif %}
{% endfor -%}
} Csx_{{module_name|upper}}_{{register.reg_name|upper}}_Bits;
{% endfor %}

{% for register in registers %}
typedef union
{
    Csx_Reg_U{{reg_data_size}}Bit U;
    Csx_Reg_S{{reg_data_size}}Bit S;
    Csx_{{module_name|upper}}_{{register.reg_name|upper}}_Bits B;
} Csx_{{module_name|upper}}_{{register.reg_name|upper}};
{% endfor %}


typedef volatile struct {
{%- set ns = namespace(reserved_index = 0,address_offset_count = 0) -%}
{%- for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{%- if register.address_offset_value_int != ns.address_offset_count %}
{{'\t'}}Csx_{{("Reg_U"~reg_data_size~"Bit")|custom_ljust(30)}}RESERVED{{ns.reserved_index}}[{{((((register.address_offset_value_int-ns.address_offset_count)/reg_gap)|int)~"]")|custom_ljust(10)}};
{%- set ns.reserved_index = ns.reserved_index +1 -%}
{%- endif %}
{{'\t'}}Csx_{{(module_name|upper~"_"~register.reg_name)|upper|trim|custom_ljust(30)}}{{register.reg_name|custom_ljust(20)}};// Address Offset: 0x{{"{:08x}".format(register.get_register_address_offset_value_int())}}
{%- set ns.address_offset_count = register.address_offset_value_int + reg_gap -%}
{% endfor %}
} Csx_{{module_name|upper}};

#endif //CSX{{module_name|upper}}_REGDEF_H
