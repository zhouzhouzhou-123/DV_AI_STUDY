#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file, get_file_header


class EnvScbFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.scb_list = env_gen.scb_list

    def gen_files(self):
        content = render_template('scb/scb_top.svh.j2',
                                  file_header=get_file_header('//', 'scb_top.svh'),
                                  scb_list=self.scb_list)
        write_file("%s/env/scb/scb_top.svh" % self.project_path, content)

        for cur_scb in self.scb_list:
            content = render_template('scb/scb.sv.j2',
                                      file_header=get_file_header('//', '%s_scb.sv' % cur_scb.name),
                                      name=cur_scb.name,
                                      name_upper=cur_scb.name.upper())
            write_file("%s/env/scb/%s_scb.sv" % (self.project_path, cur_scb.name), content)
