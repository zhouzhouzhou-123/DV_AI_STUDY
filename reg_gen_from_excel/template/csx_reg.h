#ifndef __CSX{{module_name|upper}}_REG_H__
#define __CSX{{module_name|upper}}_REG_H__
#include "Csx{{module_name|upper}}_RegDef.h"

#define MODULE_{{module_name|upper|custom_ljust(60-7)}}(*(Csx_{{module_name|upper}}*){{module_name|upper}}_SADDR)
{% for register in registers %}
//====== reg addr msk define start of {{module_name|upper}} ====== 
#define {{(module_name~"_"~register.reg_name~"_MSK")|upper|trim|custom_ljust(60)}}{{"0x{:0x}".format(register.calculate_reg_mask(reserved_attr))}}{% endfor %}
//====== reg reset value define start of {{module_name|upper}} ====== 
{% for register in registers %}
#define {{(module_name~"_"~register.reg_name~"_RSTVAL")|upper|trim|custom_ljust(60)}}{{"0x{:0x}".format(register.get_register_reset_value_int())}}{% endfor %}
{% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
#define {{(module_name~"_"~register.reg_name)|upper|trim|custom_ljust(60)}}(*(volatile Csx_{{(module_name~"_"~register.reg_name)|upper|trim|custom_ljust(30)}}*)({{module_name|upper}}_SADDR+0x{{"{:0x}".format(register.get_register_address_offset_value_int())}}))
{% endfor %}
#endif //CSX{{module_name|upper}}_REG_H
