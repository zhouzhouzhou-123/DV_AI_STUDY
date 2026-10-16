#!/usr/bin/env python3

import os
from tpl_engine import render_template
from file_gen import write_file, get_file_header

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))


class CommonFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def _gen_from_tpl(self, tpl, fname):
        content = render_template(tpl, file_header=get_file_header('//', fname))
        write_file("%s/common/%s" % (self.project_path, fname), content)

    def gen_common_checking_macro(self):
        os.system('cp -r %s/../uvm_env_gen/common_template/common_checking_macro.sv %s/common/' % (cur_scr_dir, self.project_path))

    def gen_common_define(self):
        self._gen_from_tpl('common/common_define.sv.j2', 'common_define.sv')

    def gen_hierarchy_define(self):
        self._gen_from_tpl('common/hierarchy_define.sv.j2', 'hierarchy_define.sv')

    def gen_memory_map(self):
        self._gen_from_tpl('common/memory_map.sv.j2', 'memory_map.sv')

    def gen_common_define_top(self):
        self._gen_from_tpl('common/common_define_top.sv.j2', 'common_define_top.sv')

    def gen_files(self):
        self.gen_common_define()
        self.gen_memory_map()
        self.gen_hierarchy_define()
        self.gen_common_define_top()
        self.gen_common_checking_macro()
