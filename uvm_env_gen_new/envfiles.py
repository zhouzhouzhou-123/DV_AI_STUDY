#!/usr/bin/env python3

import os
from tpl_engine import render_template
from file_gen import write_file, get_file_header

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../public")
import sys
sys.path.append(pubfunc_dir)
from pubfunc import PubFunc


class EnvFiles:
    def __init__(self, env_gen):
        self.project_name = env_gen.project_name
        self.project_path = env_gen.project_path
        self.mst_agent_list = env_gen.mst_agent_list
        self.slv_agent_list = env_gen.slv_agent_list
        self.refm_list = env_gen.refm_list
        self.scb_list = env_gen.scb_list
        self.cov_list = env_gen.cov_list

    def _build_members(self):
        member_type_list = []
        member_name_list = []

        member_type_list.append("vir_seqr")
        member_name_list.append("mo_vir_seqr")
        member_type_list.append("ral_regmodel")
        member_name_list.append("mo_regmodel")
        member_type_list.append("env_cfg")
        member_name_list.append("mo_env_cfg")

        for a in self.mst_agent_list:
            if a.is_vip:
                continue
            member_type_list.append("%s_agent" % a.name)
            if a.count == 1:
                member_name_list.append("mo_%s_master_agent" % a.name)
            else:
                member_name_list.append("moa_%s_master_agent[%s]" % (a.name, a.count))
        for a in self.slv_agent_list:
            if a.is_vip:
                continue
            member_type_list.append("%s_agent" % a.name)
            if a.count == 1:
                member_name_list.append("mo_%s_slaver_agent" % a.name)
            else:
                member_name_list.append("moa_%s_slaver_agent[%s]" % (a.name, a.count))
        for r in self.refm_list:
            member_type_list.append("%s_refm" % r.name)
            member_name_list.append("mo_%s_refm" % r.name)
        for s in self.scb_list:
            member_type_list.append("%s_scb" % s.name)
            member_name_list.append("mo_%s_scb" % s.name)

        aligned = PubFunc.align_list(member_type_list)
        return [{'type_aligned': aligned[i], 'name': member_name_list[i]}
                for i in range(len(aligned))]

    def _build_vir_seqr_members(self):
        member_type_list = []
        member_name_list = []

        for a in self.mst_agent_list:
            if a.is_vip:
                continue
            member_type_list.append("%s_seqr" % a.name)
            if a.count == 1:
                member_name_list.append("mo_%s_seqr" % a.name)
            else:
                member_name_list.append("moa_%s_seqr[%s]" % (a.name, a.count))

        aligned = PubFunc.align_list(member_type_list)
        return [{'type_aligned': aligned[i], 'name': member_name_list[i]}
                for i in range(len(aligned))]

    def gen_env(self):
        members = self._build_members()
        mst_non_vip = [a for a in self.mst_agent_list if not a.is_vip]
        slv_non_vip = [a for a in self.slv_agent_list if not a.is_vip]
        content = render_template('env/env.sv.j2',
                                  file_header=get_file_header('//', 'env.sv'),
                                  members=members,
                                  mst_agents_non_vip=mst_non_vip,
                                  slv_agents_non_vip=slv_non_vip,
                                  refm_list=self.refm_list,
                                  scb_list=self.scb_list)
        write_file("%s/env/env.sv" % self.project_path, content)

    def gen_vir_seqr(self):
        members = self._build_vir_seqr_members()
        mst_non_vip = [a for a in self.mst_agent_list if not a.is_vip]
        content = render_template('env/vir_seqr.sv.j2',
                                  file_header=get_file_header('//', 'vir_seqr.sv'),
                                  members=members,
                                  mst_agents_non_vip=mst_non_vip)
        write_file("%s/env/vir_seqr.sv" % self.project_path, content)

    def gen_files(self):
        self.gen_env()
        self.gen_vir_seqr()
