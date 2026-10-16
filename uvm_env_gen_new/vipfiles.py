#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class VipFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ VipFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ VipFiles End ------\n"
        return str_info

    def gen_vip_top_file(self):
        file_path = "%s/vip/vip_top.svh" % self.project_path
        file_handler = open(file_path, 'w')
        file_handler.write('''`include "../vip/analog_vip/analog_vip_top.sv"\n''')
        file_handler.write('''`include "../vip/digital_vip/digital_vip_top.sv"\n''')
        file_handler.close()

    def gen_analog_vip_files(self):
        file_name = "clock_model.sv"
        file_path = "%s/vip/analog_vip/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler_str = '''
// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: clock_model.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-12-04
// ----------------------------------------------------

module clock_model #(
    parameter   CLOCK_FREQ_IN_HZ    = 4_000_000,    // 4M by default
    parameter   FREQ_OFFSET         = 0.05          // period offset +- 3%
) (
    input                       clk_en,
    output                      clk_out
);

timeunit 1ps;
timeprecision 1ps;

reg  clk_out_tmp;
reg  clk_en_r1, clk_en_r2, clk_en_r3;

real ideal_period = 1_000_000_000_000.000 / CLOCK_FREQ_IN_HZ;
real period;
reg  [64:0] period_max;
reg  [64:0] period_min;

function real real_random_range(real min_value, real max_value);
    longint low;
    longint high;
    longint integer_result;
    real    real_result;

    $cast(low, min_value*10000);
    $cast(high, max_value*10000);
    integer_result = $urandom_range(low, high);
    integer_result += ($urandom_range(low>>32, high>>32))<<32;
    $cast(real_result, integer_result);
    real_result = real_result/10000;

    return real_result;
endfunction

initial
begin
    period_min = ideal_period * (1.0 - FREQ_OFFSET);
    period_max = ideal_period * (1.0 + FREQ_OFFSET);
    case($urandom_range(1,4))
        1 : period = period_min;
        2 : period = period_max;
        3 : period = ideal_period;
        4 : period = real_random_range(period_min,period_max);
    endcase
end

initial begin
    clk_out_tmp  = 0;
    #10ns;
    while(1)
    begin
        #(period/2);
        clk_out_tmp = ~clk_out_tmp ;
    end
end

always @(negedge clk_out_tmp)
begin
    clk_en_r1 <= clk_en;
    clk_en_r2 <= clk_en_r1;
    clk_en_r3 <= clk_en_r2;
end

assign clk_out = (clk_en_r2 === 1) ? clk_out_tmp : 0;


endmodule

'''
        file_handler.write(file_handler_str)
        file_handler.close()
        # top.sv
        file_path = "%s/vip/analog_vip/analog_vip_top.sv" % self.project_path
        file_handler = open(file_path, 'w')
        file_handler.write("`include \"../vip/analog_vip/clock_model.sv\"")
        file_handler.close()

    def gen_digital_vip_files(self):
        # digital_top.sv
        file_path = "%s/vip/digital_vip/digital_vip_top.sv" % self.project_path
        file_handler = open(file_path, 'w')
        file_handler.write("// `include \"../vip/digital_vip/xxx.sv\"")
        file_handler.close()

    def gen_files(self):
        self.gen_vip_top_file()
        self.gen_digital_vip_files()
        self.gen_analog_vip_files()
