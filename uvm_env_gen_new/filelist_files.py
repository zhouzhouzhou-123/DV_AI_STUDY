#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class Filelist_Files:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.env_gen = env_gen

    def __str__(self):
        str_info = ""
        str_info += "------ TbFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ TbFiles End ------\n"
        return str_info

    def gen_postsim_rtl_filelist(self):
        file_name = "postsim_rtl_filelist.f"
        file_path = "%s/filelist/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
# library
# /vendor/GSMC/HHG55nm/library/OWSCLCLS/HHG_FL55NLPU0_OWSCL7CLSV02K/VERILOG/OWSCL7CLSV0.v

# dummy module define
../tb/dummy_module_for_netlist.sv

# netlist
# ../../../backend/handoff/To_VF/20201229/timing_ctrl.v
'''
        file_handler.write(content)
        file_handler.close()

    def gen_presim_rtl_filelist(self):
        file_name = "presim_rtl_filelist.f"
        file_path = "%s/filelist/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
// TODO
//-F ${XXX_PROJ_PATH}/RTL/filelist/rtl.f
'''
        file_handler.write(content)
        file_handler.close()

    def gen_presim_rtl_vhdl_filelist(self):
        file_name = "presim_rtl_vhdl_filelist.f"
        file_path = "%s/filelist/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = '''
// TODO
//-F ${XXX_PROJ_PATH}/RTL/filelist/rtl.f
'''
        file_handler.write(content)
        file_handler.close()
    def gen_tb_filelist(self):
        file_name = "tb_filelist.f"
        file_path = "%s/filelist/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        file_handler.write(PubFunc.get_file_header('//', file_name))
        content = self.env_gen.filelist_patch_flag + '\n'
        content += '''
+incdir+../cfg

+incdir+../env
+incdir+../env/callback
+incdir+../env/trans

+incdir+../common

../common/common_define_top.sv

// vip
../vip/vip_top.svh

../tb/top.sv

// cfg

// callback
../env/callback/callback_top.svh

// trans
../env/trans/trans_top.svh

// RAL
../ral/ral_regmodel.sv

// coverage
../coverage/cov_top.svh

// assertion
../sva/sva_top.svh

// agent
../env/agent/agent_top.svh

// refm
../env/refm/refm_top.svh

// scb
../env/scb/scb_top.svh

// vir seqr
../env/vir_seqr.sv

// vir seq && seq
../sequence/seq_top.svh

../cfg/env_cfg.sv

../env/env.sv

// base test
../testcases/basetest_top.svh
'''
        file_handler.write(content)
        file_handler.close()

    def gen_files(self):
        self.gen_postsim_rtl_filelist()
        self.gen_presim_rtl_filelist()
        self.gen_presim_rtl_vhdl_filelist()
        self.gen_tb_filelist()

