
`ifndef ST_TASK__SVH
`define ST_TASK__SVH

// TODO
function [31:0] swizzle(bit [31:0] source_data);
    bit [31 : 0]   result;

    for (int i=0; i<4; i=i+1)
    begin
        result[i*8 +:8] = source_data[(3-i)*8 +:8];
    end
    return result;
endfunction

function bit [3:0] char_to_hex(bit [7:0] char);
    bit [3:0]   hex;
    case(char)
        "A" : hex = 4'ha;
        "B" : hex = 4'hb;
        "C" : hex = 4'hc;
        "D" : hex = 4'hd;
        "E" : hex = 4'he;
        "F" : hex = 4'hf;
        default : hex = char[3:0];
    endcase
    return hex;
endfunction : char_to_hex

function void load_hex_file(string file_name);
    integer         fd;
    integer         hex_data;
    bit     [7:0]   temp_char;

    bit     [7:0]   byte_num;
    bit     [7:0]   data_type;
    bit     [15:0]  address_low;
    bit     [15:0]  address_high;
    bit     [31:0]  address;
    bit     [127:0] data;

    int             mem_index;

    fd = $fopen(file_name, "r");
    if(fd == 0)
    begin
        `uvm_fatal("",$sformatf("file : %0s not exists", file_name))
    end

    while(!$feof(fd))
    begin
        hex_data = $fgetc(fd);
        if(hex_data != ":")
        begin
            continue;
        end
        // get the number of data in this line
        temp_char = $fgetc(fd);
        byte_num[7:4] = this.char_to_hex(temp_char);
        temp_char = $fgetc(fd);
        byte_num[3:0] = this.char_to_hex(temp_char);

        // get the start address
        temp_char = $fgetc(fd);
        address_low[15:12] = this.char_to_hex(temp_char);
        temp_char = $fgetc(fd);
        address_low[11:8] = this.char_to_hex(temp_char);
        temp_char = $fgetc(fd);
        address_low[7:4] = this.char_to_hex(temp_char);
        temp_char = $fgetc(fd);
        address_low[3:0] = this.char_to_hex(temp_char);

        // get data type
        temp_char = $fgetc(fd);
        data_type[7:4] = this.char_to_hex(temp_char);
        temp_char = $fgetc(fd);
        data_type[3:0] = this.char_to_hex(temp_char);

        if(data_type == 8'h01)
        begin
            // file end
            break;
        end

        if(data_type == 8'h04)
        begin
            // reload address
            temp_char = $fgetc(fd);
            address_high[15:12] = this.char_to_hex(temp_char);
            temp_char = $fgetc(fd);
            address_high[11:8] = this.char_to_hex(temp_char);
            temp_char = $fgetc(fd);
            address_high[7:4] = this.char_to_hex(temp_char);
            temp_char = $fgetc(fd);
            address_high[3:0] = this.char_to_hex(temp_char);

            address[31:16] = address_high;
            continue;
        end

        if(data_type == 8'h00)
        begin
            // actual data
            address[15:0] = address_low[15:0];
            for(int word_index=0; word_index<(byte_num/4); word_index++)
            begin
                temp_char = $fgetc(fd);
                data[31:28] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[27:24] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[23:20] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[19:16] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[15:12] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[11:8] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[7:4] = this.char_to_hex(temp_char);
                temp_char = $fgetc(fd);
                data[3:0] = this.char_to_hex(temp_char);

                // ----------------- LDROM------------------- //
                // if((address[31:0] >= `LDROM_SADDR) && (address[31:0] <= `LDROM_EADDR))
                // begin
                //     bit [31:0]  address_offset;
                //     address_offset = address - `LDROM_SADDR;
                //     mem_index = address_offset>>4;
                //     data = swizzle(data);
                //     case(word_index)
                //         'h0 : `MAIN_FLASH[mem_index][31:0] = data;
                //         'h1 : `MAIN_FLASH[mem_index][63:32] = data;
                //         'h2 : `MAIN_FLASH[mem_index][95:64] = data;
                //         'h3 : `MAIN_FLASH[mem_index][127:96] = data;
                //     endcase
                //     $display("LDROM[%0d][%d]=%0h",mem_index, word_index,data);
                //     continue;
                // end
                // ----------------- APROM------------------- //
                // if((address[31:0] >= `APROM_SADDR) && (address[31:0] <= `APROM_EADDR))
                // begin
                //     int         aprom_index_offset = 4096;
                //     bit [31:0]  address_offset;
                //     address_offset = address - `APROM_SADDR;
                //     mem_index = address_offset>>4;
                //     data = swizzle(data);
                //     case(word_index)
                //         'h0 : `MAIN_FLASH[mem_index + aprom_index_offset][31:0] = data;
                //         'h1 : `MAIN_FLASH[mem_index + aprom_index_offset][63:32] = data;
                //         'h2 : `MAIN_FLASH[mem_index + aprom_index_offset][95:64] = data;
                //         'h3 : `MAIN_FLASH[mem_index + aprom_index_offset][127:96] = data;
                //     endcase
                //     $display("APROM[%0d][%d]=%h",mem_index, word_index,data);
                //     continue;
                // end

                // ----------------- SRAM0 ------------------- //
                // if((address[31:0] >= `SRAM_B0_SADDR) && (address[31:0] <= `SRAM_B0_EADDR))
                // begin
                //     bit [31:0]  address_offset;
                //     mem_index = address_offset>>3;
                //     data = swizzle(data);
                //     case(word_index%2)
                //         'h0 : `SRAM0[mem_index][31:0]   = data;
                //         'h1 : `SRAM0[mem_index][63:32]  = data;
                //     endcase
                //     $display("SRAM0[%0d][%0d]=%0h",mem_index, word_index,data);
                //     address += 'h4;
                //     continue;
                // end
            end
        end
    end
    $fclose(fd);
endfunction : load_hex_file

function bit [31:0] sv_read_sram(int index, int flag = 0);
/*
    bit [31:0]  data;
    int         target_index;

    if(flag == 0)
    begin
        target_index = `INDEX_OF_FIRST_DATA + index;
    end else begin
        target_index = index;
    end

`ifdef SRAM_PARITY
    data[31:24] = `TARGET_SRAM[target_index][34:27];
    data[23:16] = `TARGET_SRAM[target_index][25:18];
    data[15: 8] = `TARGET_SRAM[target_index][16: 9];
    data[ 7: 0] = `TARGET_SRAM[target_index][ 7: 0];
`else
    data = `TARGET_SRAM[target_index];
`endif
    `uvm_info("",$sformatf("sv_read_sram[%0d] rdata is 'h%0h  \n",index, data),UVM_HIGH)
    return data;
*/
endfunction : sv_read_sram

task sv_write_sram(int index, bit [31:0] data, int flag = 0, int uvm_info_enable = 1);
/*
    int target_index;

    if(flag == 0)
    begin
        target_index = `INDEX_OF_FIRST_DATA + index;
    end else begin
        target_index = index;
    end

`ifdef SRAM_PARITY
    logic [35:0] temp_data;
    temp_data[35]   = ^data[31:24];
    temp_data[26]   = ^data[23:16];
    temp_data[17]   = ^data[15: 8];
    temp_data[ 8]   = ^data[ 7: 0];

    temp_data[34:27] = data[31:24];
    temp_data[25:18] = data[23:16];
    temp_data[16: 9] = data[15: 8];
    temp_data[ 7: 0] = data[ 7: 0];
    `TARGET_SRAM[target_index] = temp_data;
`else
    `TARGET_SRAM[target_index] = data;
`endif
    if(uvm_info_enable == 0)
    begin
        return;
    end
    `uvm_info("",$sformatf("sv_wr_sram[%0d] wdata is %0h ",index, data),UVM_LOW)
*/
endtask : sv_write_sram

function bit [31:0] sv_get_data(int index);
    return sv_read_sram(index);
endfunction : sv_get_data

task sv_send_data(int index, bit [31:0] data);
    sv_write_sram(index, data);
endtask: sv_send_data

task sv_send_label(bit [31:0] label);
/*
    this.sv_write_sram(`INDEX_OF_SEND_LABEL, label, 1, 0);
    $display("%t  sv_send_label\t\t: 0x%0h(%0d) ",$realtime, label, label);
*/
endtask: sv_send_label

task sv_wait_label(bit [31:0] label);
/*
    bit [31:0] data;

    $display("%t  sv_wait_label start\t: 0x%0h(%0d)", $realtime, label, label);
    while(1)
    begin
        wait(`TARGET_SRAM_TOP.A === `INDEX_OF_WAIT_LABEL && `TARGET_SRAM_TOP.WENB === 'h0);

        @(posedge `TARGET_SRAM_CLK);
        @(negedge `TARGET_SRAM_CLK);
        #1ns;

        data = this.sv_read_sram(`INDEX_OF_WAIT_LABEL, 1);
        if(data == label)
        begin
            break;
        end
    end
    $display("%t  sv_wait_label done\t: 0x%0h(%0d)", $realtime, label, label);
*/
endtask: sv_wait_label

task ccode_print_ok_error_monitor();
/*
    bit [31:0]  data;
    while(1)
    begin
        wait(`TARGET_SRAM_TOP.A === `INDEX_OF_OK_OR_ERROR && `TARGET_SRAM_TOP.WENB === 'h0);

        @(posedge `TARGET_SRAM_CLK);
        @(negedge `TARGET_SRAM_CLK);
        #1ns;

        data = this.sv_read_sram(`INDEX_OF_OK_OR_ERROR, 1);
        if(data[31:16] == 'h5555)
        begin
            $display("%t  ccode print_ok   \t: 0x%0h(%0d)", $realtime, data[15:0], data[15:0]);
        end
        if(data[31:16] == 'hAAAA)
        begin
            `uvm_error("",$sformatf("label:%d[0x%h]  check Error****",data[15:0],data[15:0]));
        end
    end
*/
endtask : ccode_print_ok_error_monitor

task ccode_print_info_monitor();
/*    bit [31:0]  data;
    while(1)
    begin
        wait(`TARGET_SRAM_TOP.A === `INDEX_OF_INFO && `TARGET_SRAM_TOP.WENB === 'h0);

        @(posedge `TARGET_SRAM_CLK);
        @(negedge `TARGET_SRAM_CLK);
        #1ns;

        data = this.sv_read_sram(`INDEX_OF_INFO, 1);
        $display("%t  ccode print_info   \t: 0x%0h(%0d)", $realtime, data, data);
    end
*/
endtask : ccode_print_info_monitor


task wait_core_sim_end();
/*
    bit [31:0] data;
    while(1)
    begin
        wait(`TARGET_SRAM_TOP.A === `INDEX_OF_END_SIM && `TARGET_SRAM_TOP.WENB === 'h0);

        @(posedge `TARGET_SRAM_CLK);
        @(negedge `TARGET_SRAM_CLK);
        #1ns;

        data = this.sv_read_sram(`INDEX_OF_END_SIM, 1);
        if(data == 'h363000aa)
        begin
            break;
        end
    end
    $display("%t  core_sim_end done", $realtime);
*/
endtask : wait_core_sim_end

task ccode_print_string_monitor();
/*
    bit     [31:0]  data;
    int             string_num, word_num;
    logic   [7:0]   string_info[129];
    string          print_str;

    while(1)
    begin
        wait(`TARGET_SRAM_TOP.A === `INDEX_OF_STRING_HEAD && `TARGET_SRAM_TOP.WE === 'h1);

        @(posedge `TARGET_SRAM_CLK);
        @(negedge `TARGET_SRAM_CLK);
        #1ns;

        data = this.sv_read_sram(`INDEX_OF_STRING_HEAD, 1);
        if(data[31:16] != 'h5aa5)
        begin
            continue;
        end

        string_num = data[15:0];
        word_num = string_num / 4;
        if(string_num % 4 != 0)
        begin
            word_num++;
        end
        foreach(string_info[index])
        begin
            string_info[index] = 0;
        end
        for(int index=0; index<word_num; index++)
        begin
            wait(`TARGET_SRAM_TOP.WE === 'h1 && `TARGET_SRAM_TOP.A === (`INDEX_OF_STRING_INFO + index));

            @(negedge `TARGET_SRAM_CLK);
            @(posedge `TARGET_SRAM_CLK);
            #1ns;
            data = this.sv_read_sram(`INDEX_OF_STRING_INFO + index, 1);

            string_info[index*4]        = data[7:0];
            string_info[index*4 + 1]    = data[15:8];
            string_info[index*4 + 2]    = data[23:16];
            string_info[index*4 + 3]    = data[31:24];
        end
        foreach(string_info[index])
        begin
            if(index >= string_num)
            begin
                string_info[index] = 0;
            end
        end
        print_str = {>>{string_info}};
        $display("%t  ccode print_string   \t: %0s", $realtime, print_str);
    end
*/
endtask : ccode_print_string_monitor

`endif // ST_TASK__SVH

