
`ifndef REG_INFO_CFG_SV
`define REG_INFO_CFG_SV

class reg_info_cfg extends uvm_object;
{%if reset_field_en %}
    typedef enum {
    {% for domain in module_rst_list %}
        {{ domain.name }} = {{ domain.priority }}{% if not loop.last %},{% endif %}  // {{ domain.description }}
        {%- if domain.is_global %} (global_reset){%- else %} (partion_reset){%- endif %}
    {% endfor %}
} rst_domain_e;
{%- endif %}

    `uvm_object_utils(reg_info_cfg)

    bit[{{reg_data_size-1}}:0] addr      ;   //
    bit[{{reg_data_size-1}}:0] wr_data   ;   // 
    bit[{{reg_data_size-1}}:0] rst_val   ;   // 
    bit[{{reg_data_size-1}}:0] reg_msk   ;   // 
    string    name      ;   //
{%if access_mode_en %}
    string    write_mode;   //
    string    read_mode ;   //
{%- endif -%}
{%if reset_field_en %}
    rst_domain_e domain ;   // 
{%- endif %}

    function new(string name = "reg_info_cfg");
        super.new(name);
    endfunction
    
    virtual function void print_info();
        $display("[REG_INFO] Register: %s, Addr: 0x%0h,wr_data : 0x%0h, Reset Val: 0x%0h, reg_msk: 0x%0h{%-if access_mode_en -%},write_mode: %s,read_mode: %s{%- endif %}{%-if reset_field_en -%}, Domain: %s {%- endif %}",name, addr, wr_data, rst_val, reg_msk{%-if access_mode_en -%}, write_mode,read_mode  {%- endif %}{%-if reset_field_en -%} , domain.name(){%- endif %});
    endfunction

endclass


`endif  //REG_INFO_CFG_SV
