#!/usr/bin/env python3

from tpl_engine import render_template
from file_gen import write_file, get_file_header


class SeqFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path

    def _gen_seq(self, tpl, fname):
        content = render_template(tpl, file_header=get_file_header('//', fname))
        write_file("%s/sequence/%s" % (self.project_path, fname), content)

    def gen_base_vir_seq(self):
        self._gen_seq('seq/base_vir_seq.sv.j2', 'base_vir_seq.sv')

    def gen_reg_seq(self):
        self._gen_seq('seq/reg_seq.sv.j2', 'reg_seq.sv')

    def gen_vir_seq(self):
        self._gen_seq('seq/vir_seq.sv.j2', 'vir_seq.sv')

    def gen_seq_top_file(self):
        self._gen_seq('seq/seq_top.svh.j2', 'seq_top.svh')

    def gen_files(self):
        self.gen_base_vir_seq()
        self.gen_reg_seq()
        self.gen_vir_seq()
        self.gen_seq_top_file()
