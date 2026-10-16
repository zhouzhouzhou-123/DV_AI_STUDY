#!/usr/bin/env python3

import sys
import os
import re

from operator import attrgetter

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

class EnvDirs:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def __str__(self):
        str_info = ""
        str_info += "------ EnvDirs Start ------\n" % ""
        str_info += "project_path(%s)\n" % self.project_path
        str_info += "------ EnvDirs End ------\n" % ""
        return str_info

    def make_dirs(self):
        if os.path.exists(self.project_path):
            PubFunc.exit_err("project_path(%s) already exists!" % self.project_path)

        project_path = self.project_path

        os.mkdir(project_path)
        os.mkdir(os.path.join(project_path, 'common'))
        os.mkdir(os.path.join(project_path, 'cfg'))
        os.mkdir(os.path.join(project_path, 'ral'))
        os.mkdir(os.path.join(project_path, 'regression'))
        os.mkdir(os.path.join(project_path, 'regression/presim'))
        os.mkdir(os.path.join(project_path, 'regression/postsim_ff_corner'))
        os.mkdir(os.path.join(project_path, 'regression/postsim_ss_corner'))
        os.mkdir(os.path.join(project_path, 'sequence'))
        os.mkdir(os.path.join(project_path, 'scripts'))
        os.mkdir(os.path.join(project_path, 'sva'))
        os.mkdir(os.path.join(project_path, 'tb'))
        os.mkdir(os.path.join(project_path, 'tb/xa'))
        os.mkdir(os.path.join(project_path, 'tb/common'))
        os.mkdir(os.path.join(project_path, 'tb/sub_connection'))
        os.mkdir(os.path.join(project_path, 'testcases'))
        os.mkdir(os.path.join(project_path, 'env'))
        os.mkdir(os.path.join(project_path, 'env/trans'))
        os.mkdir(os.path.join(project_path, 'env/callback'))
        os.mkdir(os.path.join(project_path, 'vip'))
        os.mkdir(os.path.join(project_path, 'vip/analog_vip'))
        os.mkdir(os.path.join(project_path, 'vip/digital_vip'))
        os.mkdir(os.path.join(project_path, 'sim'))
        os.mkdir(os.path.join(project_path, 'coverage'))
        os.mkdir(os.path.join(project_path, 'ccode'))
        os.mkdir(os.path.join(project_path, 'mixsim'))
        os.mkdir(os.path.join(project_path, 'mixsim/spice'))
        os.mkdir(os.path.join(project_path, 'mixsim/cfg'))
        os.mkdir(os.path.join(project_path, 'mixsim/init'))
        os.mkdir(os.path.join(project_path, 'setup'))
        os.mkdir(os.path.join(project_path, 'filelist'))
        os.mkdir(os.path.join(project_path, 'doc'))

        env_path = os.path.join(project_path, 'env')
        os.mkdir(os.path.join(env_path, 'agent'))
        os.mkdir(os.path.join(env_path, 'refm'))
        os.mkdir(os.path.join(env_path, 'scb'))

