#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class RalFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ RalFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ RalFiles End ------\n"
        return str_info

    def gen_files(self):
        file_name = "ral_regmodel.sv"
        file_path = "%s/ral/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
`ifndef RAL_REGMODEL__SV
`define RAL_REGMODEL__SV
class ral_regmodel extends uvm_reg_block;

    function new(string name = "ral_regmodel");
        super.new(name);
    endfunction: new

    function void build();
        this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
        // this.rtc = ral_block_regmodel_rtc::type_id::create("rtc",,get_full_name());
        // this.rtc.configure(this, "");
        // this.rtc.build();
        // this.default_map.add_submap(this.rtc.default_map, `UVM_REG_ADDR_WIDTH'h40002800);
    endfunction : build

    `uvm_object_utils(ral_regmodel)
endclass : ral_regmodel

`endif // RAL_REGMODEL__SV

'''
        file_handler.write(content)
        file_handler.close()

