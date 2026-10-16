`ifndef REG_COLLECTION_SV
`define REG_COLLECTION_SV

class reg_collection extends uvm_object;

    `uvm_object_utils(reg_collection)
    reg_info_cfg regs[$];

    function new(string name = "reg_collection");
        super.new(name);
    endfunction

    extern virtual function void            add_reg(reg_info_cfg reg_item);
    extern virtual function void            clear_reg()  ;    
    extern virtual function reg_info_cfg    find_by_addr(bit[{{reg_data_size-1}}:0] addr);
{%- if reset_field_en %}    
    extern virtual function void            get_by_domain(reg_info_cfg::rst_domain_e domain, ref reg_info_cfg list[$]);
{%- endif %}   
    extern virtual function reg_info_cfg    find_by_name(string name);
    extern virtual function void            print_all();
    extern virtual function void            delete_by_name(string name);
endclass

function void reg_collection::add_reg(reg_info_cfg reg_item);
    regs.push_back(reg_item);
endfunction

function void reg_collection::clear_reg();
    regs.delete();
endfunction

function void reg_collection::delete_by_name(string name);
    foreach(regs[i]) begin
        if(regs[i].name == name) begin
            regs.delete(i);
        end
    end
endfunction

function reg_info_cfg reg_collection::find_by_addr(bit[{{reg_data_size-1}}:0] addr);
    foreach(regs[i]) begin
        if(regs[i].addr == addr) begin
            return regs[i];
        end
    end
    return null;
endfunction


function reg_info_cfg reg_collection::find_by_name(string name);
    foreach(regs[i]) begin
        if(regs[i].name == name) begin
            return regs[i];
        end
    end
    return null;
endfunction


{%if reset_field_en -%}    
function void reg_collection::get_by_domain(reg_info_cfg::rst_domain_e domain, ref reg_info_cfg list[$]);
    list.delete();
    foreach(regs[i]) begin
        if(regs[i].domain == domain) begin
            list.push_back(regs[i]);
        end
    end
endfunction
{%- endif %}   

function void reg_collection::print_all();
    $display("[REG_COLLECTION] TOTAL %d registers in collection",regs.size());
    foreach(regs[i]) begin
        regs[i].print_info();
    end
endfunction




`endif  //REG_COLLECTION_SV
