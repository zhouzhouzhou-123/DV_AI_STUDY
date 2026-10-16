#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class CcodeFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.cpu_type     = env_gen.cpu_type

    def gen_files(self):
        os.system('cp -r %s/ccode_template/* %s/ccode/' % (cur_scr_dir, self.project_path))
        os.system('rm -rf %s/ccode/makefile*' % (self.project_path))
        os.system('rm -rf %s/ccode/system/startup*' % (self.project_path))
        os.system('rm -rf %s/ccode/link/link*' % (self.project_path))
        os.system('rm -rf %s/ccode/cpu_type_file' % (self.project_path))
        if os.path.isdir("%s/ccode_template/cpu_type_file/%s" % (cur_scr_dir, self.cpu_type)) == False:
            PubFunc.print_err("cpu_type : %0s not supported yes, use M0 instead!\n" % self.cpu_type)
            return

        os.system('cp -r %s/ccode_template/cpu_type_file/%s/makefile        %s/ccode/'          % (cur_scr_dir, self.cpu_type, self.project_path))
        os.system('cp -r %s/ccode_template/cpu_type_file/%s/startup.s       %s/ccode/system/'   % (cur_scr_dir, self.cpu_type, self.project_path))
        os.system('cp -r %s/ccode_template/cpu_type_file/%s/link*           %s/ccode/link/'     % (cur_scr_dir, self.cpu_type, self.project_path))
        os.system('cp -r %s/ccode_template/cpu_type_file/%s/core/*          %s/ccode/core/'     % (cur_scr_dir, self.cpu_type, self.project_path))
        return

        # if self.cpu_type == "M0":
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M0/makefile        %s/ccode/'          % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M0/startup.s       %s/ccode/system/'   % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M0/link_FLASH.ld   %s/ccode/link/'     % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M0/core/*          %s/ccode/core/'     % (cur_scr_dir, self.project_path))
        # elif self.cpu_type == "M3":
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M3/makefile        %s/ccode/'          % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M3/startup.s       %s/ccode/system/'   % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M3/link_APROM.ld   %s/ccode/link/'     % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M3/link_LDROM.ld   %s/ccode/link/'     % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/M3/core/*          %s/ccode/core/'     % (cur_scr_dir, self.project_path))
        # elif self.cpu_type == "STAR":
        #     os.system('cp -r %s/ccode_template/cpu_type_file/STAR/makefile      %s/ccode/'          % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/STAR/startup.s     %s/ccode/system/'   % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/STAR/link_APROM.ld %s/ccode/link/'     % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/STAR/core/*        %s/ccode/core/'     % (cur_scr_dir, self.project_path))
        # elif self.cpu_type == "R52":
        #     os.system('cp -r %s/ccode_template/cpu_type_file/R52/makefile       %s/ccode/'          % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/R52/startup.s      %s/ccode/system/'   % (cur_scr_dir, self.project_path))
        #     os.system('cp -r %s/ccode_template/cpu_type_file/STAR/core/*        %s/ccode/core/'     % (cur_scr_dir, self.project_path))
        # else:
        #     PubFunc.print_err("cpu_type : %0s not supported yes, use M0 instead!\n" % self.cpu_type)

