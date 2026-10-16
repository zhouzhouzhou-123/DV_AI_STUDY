
`ifndef PERMISSION_TOP_SVH
`define PERMISSION_TOP_SVH

{% if "apb" in bus_write_opt |lower %}
    `include "../testcases/basetask/permission/apb_permission/apb_permission_access_top.svh" 
{%- endif -%}
{% if "ahb" in bus_write_opt |lower %}
    `include "../testcases/basetask/permission/ahb_permission/ahb_permission_access_top.svh" 
{%- endif -%}
{% if "axi" in bus_write_opt |lower %}
    `include "../testcases/basetask/permission/axi_permission/axi_permission_access_top.svh"    
{%- endif %}
    `include "../testcases/basetask/permission/permission_access_task.sv"


`endif  //PERMISSION_TOP_SVH
