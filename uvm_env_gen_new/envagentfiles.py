#!/usr/bin/env python3

import os
from tpl_engine import render_template
from file_gen import write_file, get_file_header


class EnvAgentFiles:
    def __init__(self, env_gen):
        self.project_name = env_gen.project_name
        self.project_path = env_gen.project_path
        self.file_path_name = "%s/env/agent" % self.project_path
        self.mst_agent_list = env_gen.mst_agent_list
        self.slv_agent_list = env_gen.slv_agent_list

    def _agent_ctx(self, agent_name):
        return {
            'name': agent_name,
            'name_upper': agent_name.upper(),
        }

    def gen_agent_files(self, agent_name):
        ctx = self._agent_ctx(agent_name)
        agent_dir = "%s/%s_agent" % (self.file_path_name, agent_name)

        _agent_templates = [
            ('agent/single_agent_top.svh.j2', '%s_agent_top.svh' % agent_name),
            ('agent/agent_cfg.sv.j2',  '%s_agent_cfg.sv'  % agent_name),
            ('agent/agent.sv.j2',      '%s_agent.sv'      % agent_name),
            ('agent/item.sv.j2',       '%s_item.sv'       % agent_name),
            ('agent/driver.sv.j2',     '%s_driver.sv'     % agent_name),
            ('agent/monitor.sv.j2',    '%s_monitor.sv'    % agent_name),
            ('agent/seqr.sv.j2',       '%s_seqr.sv'       % agent_name),
            ('agent/seq.sv.j2',        '%s_seq.sv'        % agent_name),
            ('agent/if.sv.j2',         '%s_if.sv'         % agent_name),
        ]
        for tpl, fname in _agent_templates:
            ctx['file_header'] = get_file_header('//', fname)
            content = render_template(tpl, **ctx)
            write_file("%s/%s" % (agent_dir, fname), content)

    def gen_files(self):
        file_header = get_file_header('//', 'agent_top.svh')
        all_non_vip = [a for a in self.mst_agent_list if not a.is_vip] + \
                      [a for a in self.slv_agent_list if not a.is_vip]
        content = render_template('agent/agent_top.svh.j2',
                                  file_header=file_header,
                                  all_agents_non_vip=all_non_vip)
        write_file("%s/agent_top.svh" % self.file_path_name, content)

        for cur_agent in self.mst_agent_list:
            if not cur_agent.is_vip:
                os.mkdir("%s/%s_agent" % (self.file_path_name, cur_agent.name))
                self.gen_agent_files(cur_agent.name)

        for cur_agent in self.slv_agent_list:
            if not cur_agent.is_vip:
                os.mkdir("%s/%s_agent" % (self.file_path_name, cur_agent.name))
                self.gen_agent_files(cur_agent.name)
