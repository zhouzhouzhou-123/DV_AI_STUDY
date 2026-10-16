{% set max_priority_item = module_rst_list|sort(attribute='priority',reverse=true)|first %}
{% set reg_op = 'reg' if add_reg_name_to_bus_opt == 0 else ((module_name|lower)~'_reg')%}
`ifndef TC_{{module_name|upper}}_REG_ACCESS_RST_CHK_SV
`define TC_{{module_name|upper}}_REG_ACCESS_RST_CHK_SV

class tc_{{module_name|lower}}_reg_access_rst_chk extends basetest;

    `uvm_component_utils(tc_{{module_name|lower}}_reg_access_rst_chk)

    reg_collection {{module_name|lower}}_regs;
    {{module_name|lower}}_config_item   mo_{{module_name|lower}}_item;
     
    function new(string name = "tc_{{module_name|lower}}_reg_access_rst_chk", uvm_component parent = null);
        super.new(name, parent);
        this.mo_{{module_name|lower}}_item = {{module_name|lower}}_config_item::type_id::create("mo_{{module_name|lower}}_item");                 
    endfunction

    extern  virtual function void   build_phase(uvm_phase phase);
    extern  virtual task            perform_reg_rw_ops(reg_collection regs);
    extern  virtual task            trigger_rst(reg_info_cfg::rst_domain_e rst_type);
    extern  virtual task            verify_reset_domain(reg_collection regs,reg_info_cfg::rst_domain_e rst_type);
    extern  virtual task            tc_proc();

endclass

function void tc_{{module_name|lower}}_reg_access_rst_chk::build_phase(uvm_phase phase);

    super.build_phase(phase);
            
    {{module_name|lower}}_regs = reg_collection::type_id::create("{{module_name|lower}}_regs");

    mo_{{module_name|lower}}_item.randomize();
    initialize_{{module_name|lower}}_reg_info(`{{module_name|upper}}_SADDR,{{module_name|lower}}_regs,mo_{{module_name|lower}}_item);

    {{module_name|lower}}_regs.print_all();

endfunction : build_phase

task tc_{{module_name|lower}}_reg_access_rst_chk::tc_proc( );
    
    reg_info_cfg::rst_domain_e rst_type_q[$] = '{
        {%- for domain in module_rst_list -%}
        {%- if domain.is_global %} reg_info_cfg::{{domain.name}}{%- endif -%}
            {%- if not domain.is_global -%}{%- else -%}{%- if not loop.last -%},{%- endif -%}{%- endif -%}
        {%- endfor -%}
            };

    `uvm_info(get_type_name(), "Starting reset domain verification test", UVM_LOW)
    
    trigger_rst(reg_info_cfg::{{max_priority_item.name}});
 
    check_initial_reset_state({{module_name|lower}}_regs);
    perform_reg_rw_ops({{module_name|lower}}_regs);

    foreach(rst_type_q[i])begin
        verify_reset_domain({{module_name|lower}}_regs,rst_type_q[i]);
    end
    
    `uvm_info(get_type_name(), "Reset domain verification test completed", UVM_LOW)

endtask : tc_proc

task tc_{{module_name|lower}}_reg_access_rst_chk::verify_reset_domain(reg_collection regs,reg_info_cfg::rst_domain_e rst_type);

    bit[{{reg_data_size-1}}:0] val_before[$];
    bit[{{reg_data_size-1}}:0] val_after[$];
    
    `uvm_info(get_type_name(), $sformatf("Verifying %s reset domain", rst_type.name()), UVM_LOW)
    
    verify_reset_domain_before_rst(regs,val_before);
    
    trigger_rst(rst_type);

    verify_reset_domain_after_rst(regs,val_before,rst_type);
    
endtask : verify_reset_domain

task tc_{{module_name|lower}}_reg_access_rst_chk::trigger_rst(reg_info_cfg::rst_domain_e rst_type);

    `uvm_info(get_type_name(), $sformatf("Triggering %s reset", rst_type.name()), UVM_LOW)
    case(rst_type)
        {% for domain in module_rst_list %}
        reg_info_cfg::{{domain.name}}: begin
            //TODO
        end
        {% endfor %} 
    endcase

endtask : trigger_rst

task tc_{{module_name|lower}}_reg_access_rst_chk::perform_reg_rw_ops(reg_collection regs);
    
    bit[{{reg_data_size-1}}:0]  data;
    bit [{{reg_data_size-1}}:0] exp_data;

    `uvm_info(get_type_name(), "Performing register read/write operations", UVM_LOW)
    
    foreach(regs.regs[i]) begin
        {%if access_mode_en -%}
        if(regs.regs[i].write_mode == "BE")
            continue;
        {%- endif %}
        {{reg_op}}_write(regs.regs[i].addr, regs.regs[i].wr_data);
        `uvm_info(get_type_name(), $sformatf(
                  "Wrote 0x%0h to register %s (0x%0h)",
                  regs.regs[i].wr_data, regs.regs[i].name, regs.regs[i].addr), UVM_HIGH)
        {{reg_op}}_read(regs.regs[i].addr, data);
        exp_data = regs.regs[i].wr_data & regs.regs[i].reg_msk;
        if(data !== exp_data) begin
            `uvm_error(get_type_name(), $sformatf(
                      "Register %s (0x%0h) write verification failed: expected 0x%0h, got 0x%0h",
                      regs.regs[i].name, regs.regs[i].addr, exp_data, data))
        end
    end

endtask : perform_reg_rw_ops

`endif //TC_{{module_name|lower}}_reg_access_rst_chk
