#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class ScriptFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ ScriptFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ ScriptFiles End ------\n"
        return str_info

    def gen_vcs_vm_file(self):
        file_name = "vcs_vm.sh"
        os.system('cp %s/%s %s/scripts/' % (cur_scr_dir, file_name, self.project_path))
        os.chmod(("%s/scripts/%s" % (self.project_path, file_name)), 0o755)

    def gen_files(self):
        self.gen_vcs_vm_file()
