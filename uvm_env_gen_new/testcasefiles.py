#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class TestcaseFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ TestcaseFiles Start ------\n"
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ TestcaseFiles End ------\n"
        return str_info

    def gen_files(self):
        tc_path = os.path.join(self.project_path, "testcases/")
        os.system('cp -r %s/testcases_template/* %s' % (cur_scr_dir, tc_path))
































