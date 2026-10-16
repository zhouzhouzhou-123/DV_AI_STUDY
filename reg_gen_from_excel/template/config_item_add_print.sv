
{% set data_size = ("rand bit ["~(reg_data_size-1)~":0]") %}

`ifndef {{module_name|upper}}_CONFIG_ITEM_SV 
`define {{module_name|upper}}_CONFIG_ITEM_SV

class {{module_name|lower}}_config_item extends uvm_sequence_item;

// 1. Add: Define constraint field description types (enum + struct)
typedef enum {SINGLE_VAR, BIT_RANGE} FieldType;
typedef struct {
    FieldType  f_type;        // Field type (single variable / bit range variable)
    string     var_name;    // Variable name (e.g., "reserved", "rststat_stbyr")
    int        msb;         // MSB of bit range (valid only for BIT_RANGE)
    int        lsb;         // LSB of bit range (valid only for BIT_RANGE)
    string     disp_name;   // Display name for printing
} FieldDesc;


// 2. Original: Variable declaration section

{{'\t'~("rand bit ["~(reg_data_size-1)~":0]")|custom_ljust(40)}}reserved;

{% for register in registers|sort(attribute='address_offset_value_int',reverse=false) -%}
{{'\t'}}//===================== {{register.reg_name|upper|trim}} 0x{{"{:08x}".format(register.get_register_address_offset_value_int())}} =====================
{{'\t'}}{{(data_size|custom_ljust(40))}}{{register.reg_name|lower|trim|custom_ljust(40)}};{{'\n'}}
    {%- for field in register.fields|sort(attribute='start_bit',reverse=true) %}
        {%- if field.field_name != "reserved" -%}
        {%- if field.field_attribute in ["RW"] -%}
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


// 3. Add: Automatically generate constraint field description arrays for each register
{% for register in registers|sort(attribute='address_offset_value_int', reverse=false) %}
    FieldDesc {{register.reg_name|lower}}_fields[] = '{
        {%- for field in register.fields|sort(attribute='start_bit', reverse=true) %}
            {%- if field.field_name == "reserved" -%}
                // reserved bit range field
                '{BIT_RANGE, "{{field.field_name}}", {{field.end_bit}}, {{field.start_bit}}, "{{field.field_name}}[{{field.start_bit}}:{{field.end_bit}}]"}
            {%- else -%}
                // normal single variable field
                '{SINGLE_VAR, "{{(register.reg_name~"_"~field.field_name)|lower}}", {{field.end_bit}},{{field.start_bit}}, "{{(register.reg_name~"_"~field.field_name)|lower}}"}
            {%- endif -%}
            {%- if not loop.last %},{% endif -%}
        {%- endfor -%}
    };
{%- endfor -%}


// 4. Original: UVM field registration
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


// 5. Original: Constraint section
{{'\n'}}
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
    }{{'\n'}}
{%- endfor %}


// 6. Add: Generic constraint field printing function
function void print_constraint_fields(FieldDesc fields[]);
    $display("==================== Constraint Fields ====================");
    foreach (fields[i]) begin
        logic [{{(reg_data_size-1)}}:0] field_val;  // Temporary storage for field value
        int          field_width = fields[i].msb - fields[i].lsb + 1;  // Field bit width

        // Extract value based on field type
        case (fields[i].f_type)
            SINGLE_VAR: begin
                case (fields[i].var_name)
                    {% for reg in registers|sort(attribute='address_offset_value_int', reverse=false) -%}
                        {% for f in reg.fields|sort(attribute='start_bit', reverse=true) -%}
                            {% if f.field_name != "reserved" -%}
                                {{('"'~reg.reg_name~"_"~f.field_name~'"')|lower|custom_ljust(40)}}: field_val = this.{{(reg.reg_name~"_"~f.field_name)|lower|custom_ljust(40)}};
                            {% endif %}
                        {%- endfor %}
                    {%- endfor %}
                endcase
            end
            BIT_RANGE: begin
                bit[{{(reg_data_size-1)}}:0] tmp_val;
                for(int j=fields[i].lsb;j<=fields[i].msb;j++)begin
                    tmp_val[j] = reserved[j];
                end
                field_val = tmp_val >> fields[i].lsb;
            end
        endcase

        // Formatted printing (name + hex + binary)
        `uvm_info("",$sformatf("\033[1;36m %s [%0d:%0d] is [0x%0h]\033[0m",fields[i].disp_name,fields[i].msb,fields[i].lsb,field_val),UVM_LOW)
    end
    $display("===========================================================\n");
endfunction


// 7. Add: Individual printing function for each register (easy to call)
{% for register in registers|sort(attribute='address_offset_value_int', reverse=false) %}
    function void print_{{register.reg_name|lower}}_fields();
        $display("\n--- {{register.reg_name|upper}} Constraint Fields ---");
        this.print_constraint_fields({{register.reg_name|lower}}_fields);
    endfunction
{% endfor %}


// 8. Add: Demo function to print all register constraint fields with one click
function void demo_print_all_constraint_fields();
    //this.randomize();  // Randomize variables first
    {% for register in registers|sort(attribute='address_offset_value_int', reverse=false) -%}
        this.print_{{register.reg_name|lower}}_fields();
    {% endfor %}
endfunction

endclass :{{module_name|lower}}_config_item

`endif // {{module_name|upper}}_CONFIG_ITEM_SV


