#!/usr/bin/env python3

import os
from tpl_engine import render_template
from file_gen import write_file, get_file_header

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
import sys
sys.path.append(pubfunc_dir)
from pubfunc import PubFunc


class CfgFiles:
    def __init__(self, env_gen):
        self.project_path = env_gen.project_path
        self.file_path_name = 'cfg'
        self.mst_agent_list = env_gen.mst_agent_list
        self.slv_agent_list = env_gen.slv_agent_list

    def _build_env_cfg_members(self):
        member_type_list = []
        member_name_list = []

        for a in self.mst_agent_list:
            if a.is_vip:
                continue
            member_type_list.append("%s_agent_cfg" % a.name)
            if a.count == 1:
                member_name_list.append("mo_%s_master_agent_cfg" % a.name)
            else:
                member_name_list.append("moa_%s_master_agent_cfg[%s]" % (a.name, a.count))
        for a in self.slv_agent_list:
            if a.is_vip:
                continue
            member_type_list.append("%s_agent_cfg" % a.name)
            if a.count == 1:
                member_name_list.append("mo_%s_slaver_agent_cfg" % a.name)
            else:
                member_name_list.append("moa_%s_slaver_agent_cfg[%s]" % (a.name, a.count))

        aligned = PubFunc.align_list(member_type_list)
        return [{'type_aligned': aligned[i], 'name': member_name_list[i]}
                for i in range(len(aligned))]

    def _gen_static_cfg(self, tpl, fname):
        content = render_template(tpl, file_header=get_file_header('//', fname))
        write_file("%s/%s/%s" % (self.project_path, self.file_path_name, fname), content)

    def gen_xprop_file(self):
        self._gen_static_cfg('cfg/xprop.cfg.j2', 'xprop.cfg')

    def gen_partcomp_file(self):
        self._gen_static_cfg('cfg/partcomp.v.j2', 'partcomp.v')

    def gen_plus_arg_cfg_file(self):
        self._gen_static_cfg('cfg/plus_arg_cfg.sv.j2', 'plus_arg_cfg.sv')

    def gen_notimingcheck_file(self):
        fp = "%s/%s/notimingcheck.cfg" % (self.project_path, self.file_path_name)
        content = render_template('cfg/notimingcheck.cfg.j2')
        write_file(fp, content)

    def gen_cmhier_file(self):
        fp = "%s/%s/cm_hier.cfg" % (self.project_path, self.file_path_name)
        content = render_template('cfg/cm_hier.cfg.j2')
        write_file(fp, content)

    def gen_env_cfg(self):
        members = self._build_env_cfg_members()
        mst_non_vip = [a for a in self.mst_agent_list if not a.is_vip]
        slv_non_vip = [a for a in self.slv_agent_list if not a.is_vip]
        content = render_template('cfg/env_cfg.sv.j2',
                                  file_header=get_file_header('//', 'env_cfg.sv'),
                                  members=members,
                                  mst_agents_non_vip=mst_non_vip,
                                  slv_agents_non_vip=slv_non_vip)
        write_file("%s/%s/env_cfg.sv" % (self.project_path, self.file_path_name), content)

    def gen_files(self):
        self.gen_xprop_file()
        self.gen_notimingcheck_file()
        self.gen_plus_arg_cfg_file()
        self.gen_env_cfg()
        self.gen_partcomp_file()
        self.gen_cmhier_file()
