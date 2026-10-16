#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class CovFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.file_path_name = "coverage"
        self.cov_list = env_gen.cov_list

    def __str__(self):
        str_info = ""
        str_info += "------ CovFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ CovFiles End ------\n"
        return str_info

    def gen_code_coverage_cfg_file(self):
        file_name = "code_coverage.cfg"
        file_path = "%s/%s/%s" % (self.project_path, self.file_path_name, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
// +tree top.chip_top

// -moduletree crs

// begin tgl(portsonly)
//     +module i2c
// end
'''
        file_handler.write(content)
        file_handler.close()

    def gen_cov_top_file(self):
        file_name = "cov_top.svh"
        file_path = "%s/%s/%s" % (self.project_path, self.file_path_name, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
// `include ../coverage/XXX_cov.sv\n
'''
        file_handler.write(content)
        file_handler.close()

    def gen_files(self):
        self.gen_cov_top_file()
        self.gen_code_coverage_cfg_file()
