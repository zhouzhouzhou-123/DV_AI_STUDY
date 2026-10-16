#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class RegressionFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ RegressionFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ RegressionFiles End ------\n"
        return str_info

    def gen_post_vsif_file(self, corner):
        file_name = "postsim_%s_corner_session.vsif" % corner
        file_path = "%s/regression/postsim_%s_corner/%s" % (self.project_path, corner, file_name)
        file_handler = open(file_path, 'w')

        content = '''
session postsim_session {
    top_dir:${XXX_VERI_PATH}/regression/result;
}
group comp_group {
    scan_script:"vm_scan.pl uvm.flt vcs.flt";
    run_script:"${XXX_VERI_PATH}/scripts/vcs_vm.sh comp POST_SIM_ON+''' + corner.upper() + '''_CORNER";
    count   : 1;

    #define POST_SIM_ON

    #include "${XXX_VERI_PATH}/testcases/wdt/wdt.vsif"

}

group run_group {
    scan_script:"vm_scan.pl uvm.flt vcs.flt";
    run_script:"${XXX_VERI_PATH}/scripts/vcs_vm.sh nocomp_run POST_SIM_ON+''' + corner.upper() + '''_CORNER";
    depends_on : ../comp_group;
    sv_seed : gen_random;
    timeout : 9200;
    count   : 10;

    #define POST_SIM_ON

    #include "${M1026_VERI_PATH}/testcases/wdt/wdt.vsif"

}
'''

        file_handler.write(content)
        file_handler.close()

    def gen_files(self):
        file_name = "presim_session.vsif"
        file_path = "%s/regression/presim/%s" % (self.project_path, file_name)
        file_handler = open(file_path, 'w')
        content = '''
session presim_session {
    top_dir:${XXX_VERI_PATH}/regression/result;
}
group comp_group {
    scan_script:"vm_scan.pl uvm.flt vcs.flt";
    run_script:"${XXX_VERI_PATH}/scripts/vcs_vm.sh comp";
    count   : 1;

    #include "${XXX_VERI_PATH}/testcases/wdt/wdt.vsif"

}

group run_group {
    scan_script:"vm_scan.pl uvm.flt vcs.flt";
    run_script:"${XXX_VERI_PATH}/scripts/vcs_vm.sh nocomp_run";
    depends_on : ../comp_group;
    sv_seed : gen_random;
    timeout : 9200;
    count   : 10;

    #include "${M1026_VERI_PATH}/testcases/wdt/wdt.vsif"

}

'''
        file_handler.write(content)
        file_handler.close()

        self.gen_post_vsif_file("ff")
        self.gen_post_vsif_file("ss")

