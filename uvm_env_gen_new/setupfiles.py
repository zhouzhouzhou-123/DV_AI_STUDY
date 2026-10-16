#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file


class SetupFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def _gen_setup(self, tpl, fname):
        content = render_template(tpl)
        write_file("%s/setup/%s" % (self.project_path, fname), content)

    def gen_tc_define_file(self):
        self._gen_setup('setup/tc_define.sv.j2', 'tc_define.sv')

    def gen_set_env_files(self):
        self._gen_setup('setup/set_env.csh.j2', 'set_env.csh')
        self._gen_setup('setup/set_env_post.csh.j2', 'set_env_post.csh')

    def gen_m_yaml(self):
        self._gen_setup('setup/m.yml.j2', 'm.yml')

    def gen_eda_cfg_file(self):
        self._gen_setup('setup/eda.csh.j2', 'eda.csh')

    def gen_power_config_file(self):
        content = render_template('setup/power_config.tcl.j2')
        write_file("%s/setup/power_config.tcl" % self.project_path, content)

    def gen_files(self):
        self.gen_m_yaml()
        self.gen_eda_cfg_file()
        self.gen_set_env_files()
        self.gen_power_config_file()
        self.gen_tc_define_file()
