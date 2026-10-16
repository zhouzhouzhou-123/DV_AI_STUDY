#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file, get_file_header


class EnvCallbackFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def gen_files(self):
        content = render_template('env/callback_top.svh.j2',
                                  file_header=get_file_header('//', 'callback_top.svh'))
        write_file("%s/env/callback/callback_top.svh" % self.project_path, content)
