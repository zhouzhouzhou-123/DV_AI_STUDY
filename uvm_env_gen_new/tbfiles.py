#!/usr/bin/env python3

import os
from tpl_engine import render_template
from file_gen import write_file, get_file_header

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
import sys
sys.path.append(pubfunc_dir)
from pubfunc import PubFunc


class TbFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.mst_agent_list = env_gen.mst_agent_list
        self.slv_agent_list = env_gen.slv_agent_list
        self.env_gen = env_gen

    def _gen_static_tb(self, tpl, subdir, fname):
        content = render_template(tpl, file_header=get_file_header('//', fname))
        write_file("%s/tb/%s/%s" % (self.project_path, subdir, fname), content)

    def gen_dummy_file_for_post_sim(self):
        self._gen_static_tb('tb/dummy_module.sv.j2', '', 'dummy_module_for_netlist.sv')

    def gen_gpio_connection_file(self):
        self._gen_static_tb('tb/gpio_connection.sv.j2', 'sub_connection', 'gpio_connection.sv')

    def gen_power_control_connection_file(self):
        self._gen_static_tb('tb/power_control.sv.j2', 'sub_connection', 'power_control.sv')

    def gen_top_connection_file(self):
        self._gen_static_tb('tb/top_connection.sv.j2', '', 'top_connection.sv')

    def gen_chip_top_file(self):
        self._gen_static_tb('tb/chip_top.sv.j2', '', 'CHIP_TOP.sv')

    def gen_xa_files(self):
        self._gen_static_tb('tb/chip_top_xa.sv.j2', 'xa', 'CHIP_TOP_XA.sv')
        self._gen_static_tb('tb/xa_basetask.sv.j2', 'xa', 'xa_basetask.sv')

    def gen_waveform_dump_file(self):
        self._gen_static_tb('tb/waveform_dump.sv.j2', 'common', 'waveform_dump.sv')

    def gen_sdf_annotation_file(self):
        self._gen_static_tb('tb/sdf_annotation.sv.j2', 'common', 'sdf_annotation.sv')

    def gen_top_file(self):
        mst_non_vip = [a for a in self.mst_agent_list if not a.is_vip]
        slv_non_vip = [a for a in self.slv_agent_list if not a.is_vip]

        if_type_list = []
        if_name_list = []
        for a in mst_non_vip:
            if_type_list.append("%s_if" % a.name)
            if a.count == 1:
                if_name_list.append("%s_master_if" % a.name)
            else:
                if_name_list.append("%s_master_if[%s]" % (a.name, a.count))
        for a in slv_non_vip:
            if_type_list.append("%s_if" % a.name)
            if a.count == 1:
                if_name_list.append("%s_slaver_if" % a.name)
            else:
                if_name_list.append("%s_slaver_if[%s]" % (a.name, a.count))

        aligned = PubFunc.align_list(if_type_list)
        if_members = [{'type_aligned': aligned[i], 'name': if_name_list[i]}
                      for i in range(len(aligned))]

        content = render_template('tb/top.sv.j2',
                                  file_header=get_file_header('//', 'top.sv'),
                                  interface_define_flag=self.env_gen.interface_define_patch_flag,
                                  interface_set_flag=self.env_gen.interface_set_patch_flag,
                                  if_members=if_members,
                                  mst_agents_non_vip=mst_non_vip,
                                  slv_agents_non_vip=slv_non_vip)
        write_file("%s/tb/top.sv" % self.project_path, content)

    def gen_files(self):
        self.gen_dummy_file_for_post_sim()
        self.gen_top_connection_file()
        self.gen_gpio_connection_file()
        self.gen_power_control_connection_file()
        self.gen_top_file()
        self.gen_chip_top_file()
        self.gen_waveform_dump_file()
        self.gen_sdf_annotation_file()
        self.gen_xa_files()
