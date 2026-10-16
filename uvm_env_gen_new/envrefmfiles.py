#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file, get_file_header


class EnvRefmFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.refm_list = env_gen.refm_list

    def gen_files(self):
        content = render_template('refm/refm_top.svh.j2',
                                  file_header=get_file_header('//', 'refm_top.svh'),
                                  refm_list=self.refm_list)
        write_file("%s/env/refm/refm_top.svh" % self.project_path, content)

        for cur_refm in self.refm_list:
            content = render_template('refm/refm.sv.j2',
                                      file_header=get_file_header('//', '%s_refm.sv' % cur_refm.name),
                                      name=cur_refm.name,
                                      name_upper=cur_refm.name.upper())
            write_file("%s/env/refm/%s_refm.sv" % (self.project_path, cur_refm.name), content)
