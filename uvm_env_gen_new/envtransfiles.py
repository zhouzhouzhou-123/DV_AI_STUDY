#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file, get_file_header


class EnvTransFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def gen_files(self):
        content = render_template('env/trans_top.svh.j2',
                                  file_header=get_file_header('//', 'trans_top.svh'))
        write_file("%s/env/trans/trans_top.svh" % self.project_path, content)
