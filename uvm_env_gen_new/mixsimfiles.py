#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class CoSimFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ XaFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ XaFiles End ------\n"
        return str_info

    def gen_files(self):
        # default_cfg
        default_cfg_file = open("%s/mixsim/cfg/default_cfg" % self.project_path, 'w')
        default_cfg_file.write("\n")
        default_cfg_file.write("set_sim_level 5\n")
        default_cfg_file.write("set_waveform_option -format fsdb -file merge\n")
        default_cfg_file.write("set_multi_core -core 8\n")
        default_cfg_file.write("# probe_waveform_voltage top.u_chip_top* -level 3\n")
        default_cfg_file.write("# probe_waveform_voltage top.u_chip_top.xi60.xi7* -level 5\n")
        default_cfg_file.write("\n")
        default_cfg_file.close()

        # default_vcsAD.init
        default_vcsad_file = open("%s/mixsim/init/default_vcsAD.init" % self.project_path, 'w')
        default_vcsad_file.write("\n")
        default_vcsad_file.write("//spice_top ;\n")
        default_vcsad_file.write("// by default, we use ../mixsim/init/default.sp && ../mixsim/cfg/default_cfg\n")
        default_vcsad_file.write("choose xa -n $SPICE_NAME -c $CFG_NAME -o $LOG_NAME;\n")
        default_vcsad_file.write("// use_spice -cell CS32FX032AA_TOP_schematic;\n")
        default_vcsad_file.write("// use_verilog -module cs32fx032_dig_all;\n")
        default_vcsad_file.write("bus_format <%d>;\n")
        default_vcsad_file.write("// PA\n")
        default_vcsad_file.write("// d2a hiv=3.3v lov=0v node=top.u_chip_top.pa0;\n")
        default_vcsad_file.write("// a2d hith=1.65v loth=1.65v node=top.u_chip_top.pa0;\n")
        default_vcsad_file.write("\n")
        default_vcsad_file.close()

        # default.sp
        default_spice_file = open("%s/mixsim/spice/default.sp" % self.project_path, 'w')
        default_spice_file.close()

