//------------------------------------------------------------------------
// FILE NAME      : common_checking_macro.sv
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-03-29 10:06:04
// ABSTACT        :
//
//-------------------------------------------------------------------------

`ifndef COMMON_CHECKING_MACRO__SV
`define COMMON_CHECKING_MACRO__SV

`define SIGNAL_VALUE_CHECKING(ACTUAL_VALUE, EXPECTED_VALUE, ENABLE_PRINT=1) \
    if((``EXPECTED_VALUE) !== (``ACTUAL_VALUE)) \
    begin \
        `uvm_error("", $sformatf(`" ACTUAL_VALUE value should be 'h%0h, actual is 'h%0h`",``EXPECTED_VALUE, ``ACTUAL_VALUE)) \
    end else begin \
        if(``ENABLE_PRINT == 1) \
        begin \
            `uvm_info("", $sformatf(`" ``ACTUAL_VALUE value should be 'h%0h, actual is 'h%0h`",``EXPECTED_VALUE, ``ACTUAL_VALUE), UVM_LOW) \
        end \
    end
`define SIGNAL_VALUE_CHECKING_WITH_BREAK(ACTUAL_VALUE, EXPECTED_VALUE) \
    if((``EXPECTED_VALUE) !== (``ACTUAL_VALUE)) \
    begin \
        `uvm_error("", $sformatf(`" ACTUAL_VALUE value should be 'h%0h, actual is 'h%0h`",``EXPECTED_VALUE, ``ACTUAL_VALUE)) \
        break; \
    end else begin \
        // `uvm_info("", $sformatf(`" ``ACTUAL_VALUE value should be 'h%0h, actual is 'h%0h`",``EXPECTED_VALUE, ``ACTUAL_VALUE), UVM_LOW) \
    end

`define GLITCH_CHECKING(SIGNAL_NAME, ENABLE, WIDTH) \
    begin \
        real pre_time = 0.0; \
        real current_time = 0.0; \
        while(1) \
        begin \
            @(``SIGNAL_NAME) \
            if(current_time == 0.0) \
            begin \
                current_time = $realtime; \
                continue; \
            end \
            pre_time = current_time; \
            current_time = $realtime; \
            if(current_time - pre_time < ``WIDTH) \
            begin \
                if(``ENABLE == 1'b1) \
                begin \
                    `uvm_error("",$sformatf(`"[GLITCH] : SIGNAL_NAME glitch...`")) \
                end else begin \
                    `uvm_warning("",$sformatf(`"[GLITCH] : SIGNAL_NAME glitch...`")) \
                end \
                $display("glitch pulse interage: %f" , current_time - pre_time); \
                $display("rtime = %f ns" , $realtime); \
                break; \
            end \
        end \
    end

// added by liuchaofeng
`define CLOCK_ENABLE_DISABLE_CHECKING(CLOCK, CLOCK_NAME, STATUS, MIN_COUNTER) \
    begin \
        int pulse_counter = 0; \
        fork :``CLOCK_NAME``_pulse_counter \
            #2ms; \
            while(1) \
            begin \
                @(``CLOCK); \
                pulse_counter++; \
            end \
        join_any \
        disable ``CLOCK_NAME``_pulse_counter; \
        if(``STATUS == 1'b0 && pulse_counter != 0) \
        begin \
            `uvm_error("",$sformatf(`"``CLOCK_NAME`` is not disable correctly, pulse_counter=%0d..`",pulse_counter)) \
        end \
        if(``STATUS == 1'b1 && pulse_counter < ``MIN_COUNTER) \
        begin \
            `uvm_error("",$sformatf(`"``CLOCK_NAME`` is not enabled correctly, pulse_counter=%0d,expect %0d..`",pulse_counter,``MIN_COUNTER)) \
        end \
    end
`define CLK_FREQ_COMPARE_BY_TIME(SRC_CLK, DEST_CLK, FREQ_RATE, CHECKING_TIME) \
    begin \
        real src_clk_count = 0; \
        real dest_clk_count = 0; \
        fork : dest_clk_arrived \
            begin \
                #5ms; \
                `uvm_error("",`"TIMEOUT, posedge(DEST_CLK) not arrived in 5ms`") \
            end \
            begin \
                @(posedge ``DEST_CLK); \
            end \
        join_any \
        disable dest_clk_arrived; \
        \
        fork : clk_freq_checking \
            #``CHECKING_TIME; \
            while(1) \
            begin \
                @(posedge ``SRC_CLK); \
                src_clk_count++; \
            end \
            while(1) \
            begin \
                @(posedge ``DEST_CLK); \
                dest_clk_count++; \
            end \
        join_any \
        disable clk_freq_checking; \
        `ifndef POST_SIM_ON \
            if(src_clk_count >= (dest_clk_count * ``FREQ_RATE + ``FREQ_RATE) || \
                src_clk_count <= (dest_clk_count * ``FREQ_RATE - ``FREQ_RATE) || \
                src_clk_count == 0) \
            begin \
                `uvm_error("",$sformatf(`"\n----f(SRC_CLK)/f(DEST_CLK) != %0f;\n----count(DEST_CLK) = %0d; count(SRC_CLK) = %0d in CHECKING_TIME",``FREQ_RATE, dest_clk_count, src_clk_count)) \
            end else begin \
                `uvm_info("",$sformatf(`"\n----f(SRC_CLK)/f(DEST_CLK) == %0f;\n----count(DEST_CLK) = %0d; count(SRC_CLK) = %0d in CHECKING_TIME",``FREQ_RATE, dest_clk_count, src_clk_count),UVM_LOW) \
            end \
        `endif \
    end
`define CLK_FREQ_COMPARE_BY_ENABLE(SRC_CLK, DEST_CLK, FREQ_RATE, ENABLE) \
    begin \
        real src_clk_count = 0; \
        real dest_clk_count = 0; \
        fork : dest_clk_arrived \
            begin \
                #5ms; \
                `uvm_error("",`"TIMEOUT, ENABLE/posedge(DEST_CLK) not arrived in 5ms`") \
            end \
            begin \
                wait(``ENABLE === 1); \
                @(posedge ``DEST_CLK); \
            end \
        join_any \
        disable dest_clk_arrived; \
        \
        fork : clk_freq_checking \
            wait(``ENABLE !== 1); \
            while(1) \
            begin \
                @(posedge ``SRC_CLK); \
                src_clk_count++; \
            end \
            while(1) \
            begin \
                @(posedge ``DEST_CLK); \
                dest_clk_count++; \
            end \
        join_any \
        disable clk_freq_checking; \
        `ifndef POST_SIM_ON \
            if(src_clk_count >= (dest_clk_count * ``FREQ_RATE + ``FREQ_RATE) || \
                src_clk_count <= (dest_clk_count * ``FREQ_RATE - ``FREQ_RATE) || \
                src_clk_count == 0) \
            begin \
                `uvm_error("",$sformatf(`"\n----f(SRC_CLK)/f(DEST_CLK) != %0f;\n----count(DEST_CLK) = %0d; count(SRC_CLK) = %0d when ENABLE==1",``FREQ_RATE, dest_clk_count, src_clk_count)) \
            end else begin \
                `uvm_info("",$sformatf(`"\n----f(SRC_CLK)/f(DEST_CLK) == %0f;\n----count(DEST_CLK) = %0d; count(SRC_CLK) = %0d when ENABLE==1",``FREQ_RATE, dest_clk_count, src_clk_count),UVM_LOW) \
            end \
        `endif \
    end

`endif // COMMON_CHECKING_MACRO__SV
