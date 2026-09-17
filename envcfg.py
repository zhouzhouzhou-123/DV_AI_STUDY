#!/usr/bin/env python3

import os
import re
import yaml

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))

from pubfunc import PubFunc

class EnvCfg:
    def __init__(self):
        self.work_dir = os.path.abspath(os.environ.get("WORK_DIR"))
        self.env_cfg_path = "%s/setup/envcfg.yml" % self.work_dir
        self.duv_cfg_path = "%s/setup/duvcfg.yml" % self.work_dir
        self.has_duv_cfg = False
        self.env_cfg_dict = dict()
        self.duv_cfg_dict = dict()
        self.regr_result_path = "%s/regression/result" % self.work_dir
        self.cov_result_path = "%s/coverage/coverage.vdb" % self.work_dir
        self.has_cm_hier_cfg = False
        self.cm_hier_cfg_path = "%s/cfg/cm_hier.cfg" % self.work_dir
        self.testcases_dirname = "testcases"
        self.scripts_dirname = "scripts"
        self.simv_test_pkg = "test_pkg"
        self.wave_dirname = "result"
        self.vmcomp_path = ""
        self.log_dirname = "result"
        self.xa_log_dirname = "xa_log"
        self.duv_top = ""
        self.tb_top = "top"
        self.testcases_dir_path = "%s/%s" % (self.work_dir, self.testcases_dirname)
        self.scripts_dir_path = "%s/%s" % (self.work_dir, self.scripts_dirname)
        self.use_vmanager = True
        self.use_vmcomp_path = False
        self.vmanager_local = True
        self.vmanager_server = "192.168.100.205:8080"
        self.pre_sim_duv_flist = ""
        self.pa_sim_duv_flist = ""
        self.pre_sim_duv_vhdl_flist = ""
        self.is_mixed = False
        self.post_sim_duv_flist = ""
        self.post_sim_dc_duv_flist = ""
        self.post_sim_pg_duv_flist = ""
        self.post_sim_pr_duv_flist = ""
        self.tb_flist = ""
        self.tb_xa_flist = ""
        self.tb_post_flist = ""
        self.vhdlan_default_comp_args = ""
        self.vlogan_default_comp_args = ""
        self.vlogan_only_pre_comp_args = ""
        self.vlogan_only_post_comp_args = ""
        self.vlogan_only_post_dc_comp_args = ""
        self.cov_default_args = "-cm line+cond+fsm+branch+tgl+assert"
        self.vcs_default_comp_args = ""
        self.vcs_pa_comp_args = ""
        self.vcs_only_pre_comp_args = ""
        self.vcs_only_post_comp_args = ""
        self.upf_file_path = ""
        self.upf_cfg_path = ""
        self.vcs_default_sim_args = ""
        self.vericom_default_args = ""
        self.vericom_work_lib = "verdi_work"
        # split-library (distributed) compile : RTL and TB compiled into two
        # separate vlogan libraries, in parallel. Off by default (legacy
        # single-library flow); enable in envcfg.yml with  split_lib: True
        self.split_lib = False
        self.vericom_use_wave_do = False
        self.bsub_default_args= "bsub -Ip"
        self.pre_script_path = ""
        self.post_script_path = ""
        self.xa_bsub_args = ""
        self.post_common_macro = ""
        self.vmnocomp_fsdb_dump_tcl_path = ""
        self.user_custom_vdb_delete_key_word = "reg_access"        
        # --- private ---
        self.unfold_flist_path = ""
        self.ori_fpath_list = []

    def __str__(self):
        str_info = ""
        str_info += "========= %s Start =========\n" % "EnvCfg"
        str_info += "work_dir(%s)\n" % self.work_dir
        str_info += "env_cfg_path(%s)\n" % self.env_cfg_path
        str_info += "duv_cfg_path(%s)\n" % self.duv_cfg_path
        str_info += "comp_result_path(%s)\n" % self.comp_result_path
        str_info += "sim_result_path(%s)\n" % self.sim_result_path
        str_info += "regr_result_path(%s)\n" % self.regr_result_path
        str_info += "testcases_dirname(%s)\n" % self.testcases_dirname
        str_info += "scripts_dirname(%s)\n" % self.scripts_dirname
        str_info += "wave_dirname(%s)\n" % self.wave_dirname
        str_info += "log_dirname(%s)\n" % self.log_dirname
        str_info += "xa_log_dirname(%s)\n" % self.xa_log_dirname
        str_info += "duv_top(%s)\n" % self.duv_top
        str_info += "tb_top(%s)\n" % self.tb_top
        str_info += "testcases_dir_path(%s)\n" % self.testcases_dir_path
        str_info += "scripts_dir_path(%s)\n" % self.scripts_dir_path
        str_info += "log_dir_path(%s)\n" % self.log_dir_path
        str_info += "use_vmanager(%s)\n" % self.use_vmanager
        str_info += "vmanager_local(%s)\n" % self.vmanager_local
        str_info += "vmanager_server(%s)\n" % self.vmanager_server
        str_info += "pre_sim_duv_flist(%s)\n" % self.pre_sim_duv_flist
        str_info += "pa_sim_duv_flist(%s)\n" % self.pa_sim_duv_flist
        str_info += "pre_sim_duv_vhdl_flist(%s)\n" % self.pre_sim_duv_vhdl_flist
        str_info += "post_sim_duv_flist(%s)\n" % self.post_sim_duv_flist
        str_info += "post_sim_dc_duv_flist(%s)\n" % self.post_sim_dc_duv_flist
        str_info += "post_sim_pg_duv_flist(%s)\n" % self.post_sim_pg_duv_flist
        str_info += "post_sim_pr_duv_flist(%s)\n" % self.post_sim_pr_duv_flist
        str_info += "tb_flist(%s)\n" % self.tb_flist
        str_info += "tb_xa_flist(%s)\n" % self.tb_xa_flist
        str_info += "tb_post_flist(%s)\n" % self.tb_post_flist
        str_info += "vhdlan_default_comp_args(%s)\n" % self.vhdlan_default_comp_args
        str_info += "vlogan_default_comp_args(%s)\n" % self.vlogan_default_comp_args
        str_info += "cov_default_args(%s)\n" % self.cov_default_args
        str_info += "vcs_default_comp_args(%s)\n" % self.vcs_default_comp_args
        str_info += "vcs_pa_comp_args(%s)\n" % self.vcs_pa_comp_args

        str_info += "vcs_only_pre_comp_args(%s)\n" % self.vcs_only_pre_comp_args
        str_info += "vcs_only_post_comp_args(%s)\n" % self.vcs_only_post_comp_args
        str_info += "vlogan_only_pre_comp_args(%s)\n" % self.vlogan_only_pre_comp_args
        str_info += "vlogan_only_post_comp_args(%s)\n" % self.vlogan_only_post_comp_args
        str_info += "vlogan_only_post_dc_comp_args(%s)\n" % self.vlogan_only_post_dc_comp_args
        str_info += "upf_file_path(%s)\n" % self.upf_file_path
        str_info += "upf_cfg_path(%s)\n" % self.upf_cfg_path
        str_info += "vcs_default_sim_args(%s)\n" % self.vcs_default_sim_args
        str_info += "vericom_default_args(%s)\n" % self.vericom_default_args
        str_info += "vericom_work_lib(%s)\n" % self.vericom_work_lib
        str_info += "vericom_use_wave_do(%s)\n" % self.vericom_use_wave_do
        str_info += "bsub_default_args(%s)\n" % self.bsub_default_args
        str_info += "pre_script_path(%s)\n" % self.pre_script_path
        str_info += "post_script_path(%s)\n" % self.post_script_path
        str_info += "xa_bsub_args(%s)\n" % self.xa_bsub_args
        str_info += "post_common_macro(%s)\n" % self.post_common_macro

        if hasattr(self, "add_macro_by_test_name_info"):
            str_info += "add_macro_by_test_name_info(%s)\n" % self.add_macro_by_test_name_info
        str_info += "========= %s End =========\n" % "EnvCfg"
        return str_info

    def parse_env_cfg(self):
        env_cfg_file = open(self.env_cfg_path, "r")
        env_cfg_info = env_cfg_file.read()
        #self.env_cfg_dict = yaml.load(env_cfg_info, Loader=yaml.FullLoader)
        try:
            self.env_cfg_dict = yaml.load(env_cfg_info, Loader=yaml.FullLoader)
        except AttributeError:
            self.env_cfg_dict = yaml.load(env_cfg_info)

        if self.env_cfg_dict.__contains__("testcases_dirname"):
            if self.env_cfg_dict["testcases_dirname"] != None:
                self.testcases_dirname = self.env_cfg_dict["testcases_dirname"]
                self.testcases_dir_path = "%s/%s" % (self.work_dir, self.testcases_dirname)
        if self.env_cfg_dict.__contains__("scripts_dirname"):
            if self.env_cfg_dict["scripts_dirname"] != None:
                self.scripts_dirname = self.env_cfg_dict["scripts_dirname"]
                self.scripts_dir_path = "%s/%s" % (self.work_dir, self.scripts_dirname)
        if self.env_cfg_dict.__contains__("wave_dirname"):
            if self.env_cfg_dict["wave_dirname"] != None:
                self.wave_dirname = self.env_cfg_dict["wave_dirname"]

        if self.env_cfg_dict.__contains__("vmcomp_path"):
            if self.env_cfg_dict["vmcomp_path"] != None:
                self.vmcomp_path = self.get_file_abspath(self.env_cfg_dict["vmcomp_path"])
                self.use_vmcomp_path = True

        if self.env_cfg_dict.__contains__("simv_test_pkg"):
            if self.env_cfg_dict["simv_test_pkg"] != None:
                self.simv_test_pkg = self.env_cfg_dict["simv_test_pkg"]

        if self.env_cfg_dict.__contains__("log_dirname"):
            if self.env_cfg_dict["log_dirname"] != None:
                self.log_dirname = self.env_cfg_dict["log_dirname"]
        if self.env_cfg_dict.__contains__("xa_log_dirname"):
            if self.env_cfg_dict["xa_log_dirname"] != None:
                self.xa_log_dirname = self.env_cfg_dict["xa_log_dirname"]
        if self.env_cfg_dict.__contains__("duv_top"):
            if self.env_cfg_dict["duv_top"] != None:
                self.duv_top = self.env_cfg_dict["duv_top"]
            else:
                PubFunc.exit_err("must provide duv_top(%s)!" % self.env_cfg_dict["duv_top"])
        if self.env_cfg_dict.__contains__("tb_top"):
            if self.env_cfg_dict["tb_top"] != None:
                self.tb_top = self.env_cfg_dict["tb_top"]
            else:
                PubFunc.exit_err("must provide tb_top(%s)!" % self.env_cfg_dict["tb_top"])
        if self.env_cfg_dict.__contains__("use_vmanager"):
            if self.env_cfg_dict["use_vmanager"]:
                self.use_vmanager = True
            else:
                self.use_vmanager = False
        if self.env_cfg_dict.__contains__("vmanager_local"):
            if self.env_cfg_dict["vmanager_local"]:
                self.vmanager_local = True
            else:
                self.vmanager_local = False
        if self.env_cfg_dict.__contains__("vmanager_server"):
            if self.env_cfg_dict["vmanager_server"] != None:
                self.vmanager_server = self.env_cfg_dict["vmanager_server"]
        if self.env_cfg_dict.__contains__("pre_sim_duv_flist"):
            if self.env_cfg_dict["pre_sim_duv_flist"] != None:
                self.pre_sim_duv_flist = self.env_cfg_dict["pre_sim_duv_flist"]
            else:
                PubFunc.print_warn("pre_sim_duv_flist(%s) needs provide!" % self.pre_sim_duv_flist)
        if self.env_cfg_dict.__contains__("pa_sim_duv_flist"):
            if self.env_cfg_dict["pa_sim_duv_flist"] != None:
                self.pa_sim_duv_flist = self.env_cfg_dict["pa_sim_duv_flist"]
            else:
                PubFunc.print_warn("pa_sim_duv_flist(%s) needs provide!" % self.pa_sim_duv_flist)
        if self.env_cfg_dict.__contains__("pre_sim_duv_vhdl_flist"):
            if self.env_cfg_dict["pre_sim_duv_vhdl_flist"] != None:
                self.pre_sim_duv_vhdl_flist = self.env_cfg_dict["pre_sim_duv_vhdl_flist"]
                self.is_mixed = True
            else:
                PubFunc.print_warn("pre_sim_duv_vhdl_flist(%s) needs provide!" % self.pre_sim_duv_vhdl_flist)
        if self.env_cfg_dict.__contains__("post_sim_duv_flist"):
            if self.env_cfg_dict["post_sim_duv_flist"] != None:
                self.post_sim_duv_flist = self.env_cfg_dict["post_sim_duv_flist"]
            else:
                PubFunc.print_warn("post_sim_duv_flist(%s) needs provide!" % self.post_sim_duv_flist)
        if self.env_cfg_dict.__contains__("post_sim_dc_duv_flist"):
            if self.env_cfg_dict["post_sim_dc_duv_flist"] != None:
                self.post_sim_dc_duv_flist = self.env_cfg_dict["post_sim_dc_duv_flist"]
            else:
                PubFunc.print_warn("post_sim_dc_duv_flist(%s) needs provide!" % self.post_sim_dc_duv_flist)

        if self.env_cfg_dict.__contains__("post_sim_pg_duv_flist"):
            if self.env_cfg_dict["post_sim_pg_duv_flist"] != None:
                self.post_sim_pg_duv_flist = self.env_cfg_dict["post_sim_pg_duv_flist"]
            else:
                PubFunc.print_warn("post_sim_pg_duv_flist(%s) needs provide!" % self.post_sim_pg_duv_flist)

        if self.env_cfg_dict.__contains__("post_sim_pr_duv_flist"):
            if self.env_cfg_dict["post_sim_pr_duv_flist"] != None:
                self.post_sim_pr_duv_flist = self.env_cfg_dict["post_sim_pr_duv_flist"]
            else:
                PubFunc.print_warn("post_sim_pr_duv_flist(%s) needs provide!" % self.post_sim_pr_duv_flist)

        if self.env_cfg_dict.__contains__("tb_flist"):
            if self.env_cfg_dict["tb_flist"] != None:
                self.tb_flist = self.env_cfg_dict["tb_flist"]
            else:
                PubFunc.exit_err("must provide tb_flist(%s)!" % self.env_cfg_dict["tb_flist"])
        if self.env_cfg_dict.__contains__("tb_xa_flist"):
            if self.env_cfg_dict["tb_xa_flist"] != None:
                self.tb_xa_flist = self.env_cfg_dict["tb_xa_flist"]
            else:
                self.tb_xa_flist = self.tb_flist
        else:
            self.tb_xa_flist = self.tb_flist
        if self.env_cfg_dict.__contains__("tb_post_flist"):
            if self.env_cfg_dict["tb_post_flist"] != None:
                self.tb_post_flist = self.env_cfg_dict["tb_post_flist"]
            else:
                self.tb_post_flist = self.tb_flist
        else:
            self.tb_post_flist = self.tb_flist
        if self.env_cfg_dict.__contains__("vhdlan_default_comp_args"):
            if self.env_cfg_dict["vhdlan_default_comp_args"] != None:
                self.vhdlan_default_comp_args = self.env_cfg_dict["vhdlan_default_comp_args"]
        if self.env_cfg_dict.__contains__("vlogan_default_comp_args"):
            if self.env_cfg_dict["vlogan_default_comp_args"] != None:
                self.vlogan_default_comp_args = self.env_cfg_dict["vlogan_default_comp_args"]
        if self.env_cfg_dict.__contains__("cov_default_args"):
            if self.env_cfg_dict["cov_default_args"] != None:
                self.cov_default_args = self.env_cfg_dict["cov_default_args"]
        if self.env_cfg_dict.__contains__("vcs_default_comp_args"):
            if self.env_cfg_dict["vcs_default_comp_args"] != None:
                self.vcs_default_comp_args = self.env_cfg_dict["vcs_default_comp_args"]
        if self.env_cfg_dict.__contains__("vcs_pa_comp_args"):
            if self.env_cfg_dict["vcs_pa_comp_args"] != None:
                self.vcs_pa_comp_args = self.env_cfg_dict["vcs_pa_comp_args"]
        if self.env_cfg_dict.__contains__("vcs_only_pre_comp_args"):
            if self.env_cfg_dict["vcs_only_pre_comp_args"] != None:
                self.vcs_only_pre_comp_args = self.env_cfg_dict["vcs_only_pre_comp_args"]
        if self.env_cfg_dict.__contains__("vcs_only_post_comp_args"):
            if self.env_cfg_dict["vcs_only_post_comp_args"] != None:
                self.vcs_only_post_comp_args = self.env_cfg_dict["vcs_only_post_comp_args"]
        if self.env_cfg_dict.__contains__("vlogan_only_pre_comp_args"):
            if self.env_cfg_dict["vlogan_only_pre_comp_args"] != None:
                self.vlogan_only_pre_comp_args = self.env_cfg_dict["vlogan_only_pre_comp_args"]
        if self.env_cfg_dict.__contains__("vlogan_only_post_comp_args"):
            if self.env_cfg_dict["vlogan_only_post_comp_args"] != None:
                self.vlogan_only_post_comp_args = self.env_cfg_dict["vlogan_only_post_comp_args"]
        if self.env_cfg_dict.__contains__("vlogan_only_post_dc_comp_args"):
            if self.env_cfg_dict["vlogan_only_post_dc_comp_args"] != None:
                self.vlogan_only_post_dc_comp_args = self.env_cfg_dict["vlogan_only_post_dc_comp_args"]
        if self.env_cfg_dict.__contains__("upf_file_path"):
            if self.env_cfg_dict["upf_file_path"] != None:
                self.upf_file_path = self.get_file_abspath(self.env_cfg_dict["upf_file_path"])
                if not os.path.isfile(self.upf_file_path):
                    PubFunc.exit_err("upf_file_path(%s) not exist!" % self.upf_file_path)
        if self.env_cfg_dict.__contains__("vmnocomp_fsdb_dump_tcl_path"):
            if self.env_cfg_dict["vmnocomp_fsdb_dump_tcl_path"] != None:
                self.vmnocomp_fsdb_dump_tcl_path = self.get_file_abspath(self.env_cfg_dict["vmnocomp_fsdb_dump_tcl_path"])
                if not os.path.isfile(self.vmnocomp_fsdb_dump_tcl_path):
                    PubFunc.exit_err("vmnocomp_fsdb_dump_tcl_path(%s) not exist!" % self.vmnocomp_fsdb_dump_tcl_path)
        if self.env_cfg_dict.__contains__("user_custom_vdb_delete_key_word"):
            if self.env_cfg_dict["user_custom_vdb_delete_key_word"] != None:
                self.user_custom_vdb_delete_key_word = self.env_cfg_dict["user_custom_vdb_delete_key_word"]
        if self.env_cfg_dict.__contains__("upf_cfg_path"):
            if self.env_cfg_dict["upf_cfg_path"] != None:
                self.upf_cfg_path = self.get_file_abspath(self.env_cfg_dict["upf_cfg_path"])
                if not os.path.isfile(self.upf_cfg_path):
                    PubFunc.exit_err("upf_cfg_path(%s) not exist!" % self.upf_cfg_path)
        if self.env_cfg_dict.__contains__("vcs_default_sim_args"):
            if self.env_cfg_dict["vcs_default_sim_args"] != None:
                self.vcs_default_sim_args = self.env_cfg_dict["vcs_default_sim_args"]
        if self.env_cfg_dict.__contains__("vericom_default_args"):
            if self.env_cfg_dict["vericom_default_args"] != None:
                self.vericom_default_args = self.env_cfg_dict["vericom_default_args"]
        if self.env_cfg_dict.__contains__("vericom_work_lib"):
            if self.env_cfg_dict["vericom_work_lib"] != None:
                self.vericom_work_lib = self.env_cfg_dict["vericom_work_lib"]

        if self.env_cfg_dict.__contains__("split_lib"):
            if self.env_cfg_dict["split_lib"] != None:
                self.split_lib = self.env_cfg_dict["split_lib"]
        if self.env_cfg_dict.__contains__("vericom_use_wave_do"):
            if self.env_cfg_dict["vericom_use_wave_do"] != None:
                self.vericom_use_wave_do = self.env_cfg_dict["vericom_use_wave_do"]
        if self.env_cfg_dict.__contains__("bsub_default_args"):
            if self.env_cfg_dict["bsub_default_args"] != None:
                self.bsub_default_args = self.env_cfg_dict["bsub_default_args"]
        if self.env_cfg_dict.__contains__("pre_script_path"):
            if self.env_cfg_dict["pre_script_path"] != None:
                self.pre_script_path = self.env_cfg_dict["pre_script_path"]
        if self.env_cfg_dict.__contains__("post_script_path"):
            if self.env_cfg_dict["post_script_path"] != None:
                self.post_script_path = self.env_cfg_dict["post_script_path"]
        if self.env_cfg_dict.__contains__("add_macro_by_test_name_info"):
            if self.env_cfg_dict["add_macro_by_test_name_info"] != None:
                self.add_macro_by_test_name_info = self.env_cfg_dict["add_macro_by_test_name_info"]
        if self.env_cfg_dict.__contains__("user_custom_vdb_delete_key_word"):
            if self.env_cfg_dict["user_custom_vdb_delete_key_word"] != None:
                self.user_custom_vdb_delete_key_word = self.env_cfg_dict["user_custom_vdb_delete_key_word"]
        if self.env_cfg_dict.__contains__("xa_bsub_args"):
            if self.env_cfg_dict["xa_bsub_args"] != None:
                self.xa_bsub_args = self.env_cfg_dict["xa_bsub_args"]
        if self.env_cfg_dict.__contains__("post_common_macro"):
            if self.env_cfg_dict["post_common_macro"] != None:
                self.post_common_macro = self.env_cfg_dict["post_common_macro"]

    def parse_duv_cfg(self):
        if os.path.isfile(self.duv_cfg_path):
            duv_cfg_file = open(self.duv_cfg_path, "r")
            duv_cfg_info = duv_cfg_file.read()
            self.duv_cfg_dict = yaml.load(duv_cfg_info, Loader=yaml.FullLoader)
            self.has_duv_cfg = True

    def check_dirs(self):
        if not os.path.isdir(self.testcases_dir_path):
            PubFunc.exit_err("testcases_dir_path(%s) not exist!" % self.testcases_dir_path)
        if not os.path.isdir(self.scripts_dir_path):
            PubFunc.exit_err("scripts_dir_path(%s) not exist!" % self.scripts_dir_path)
    
    def use_env_cfg(self):
        if not os.path.isdir(self.cov_result_path):
            os.mkdir(self.cov_result_path)

    def check_env_cfg(self):
        self.check_dirs()
        if os.path.isfile(self.cm_hier_cfg_path):
            self.has_cm_hier_cfg = True

    def gen_tmp_veri_info(self):
        pass

    def set_env(self):
        self.parse_env_cfg()
        self.parse_duv_cfg()
        self.check_env_cfg()
        self.use_env_cfg()
        self.gen_tmp_veri_info()

    def get_file_abspath(self, file_path):
        file_abspath = ""
        loop_replace = True
        while loop_replace:
            search_environ = re.search(r'\$\{*(\w+)\}*', file_path)
            if search_environ:
                cur_environ = search_environ.group(1)
                file_path = file_path.replace("{", "")
                file_path = file_path.replace("}", "")
                #print(f"file path is {file_path}")
                file_path = file_path.replace("$%s" % cur_environ, os.environ.get(cur_environ))
                #print("file_path(%s)" % file_path)
            else:
                loop_replace = False
        return os.path.abspath(file_path)

    def gen_unfold_flist(self, duv_flist):
        duv_flist_file = open(duv_flist, 'r')
        duv_flist_line = duv_flist_file.readline()
        while duv_flist_line:
            duv_flist_line = duv_flist_line.strip()
            match_flist = re.match(r'^\s*-f\s+(.+)$', duv_flist_line, re.I)
            if match_flist:
                folded_flist = match_flist.group(1)
                folded_flist = self.get_file_abspath(folded_flist)
                #print("folded_flist(%s)" % folded_flist)
                self.gen_unfold_flist(folded_flist)
            else:
                self.unfold_flist_file.write("%s\n" % duv_flist_line)
            duv_flist_line = duv_flist_file.readline()
        duv_flist_file.close()

    def gen_stub_flist(self):
        stub_flist_file = open(self.stub_flist_path, 'w')

        self.ori_fpath_list.clear()

        unfold_flist_file = open(self.unfold_flist_path, 'r')
        unfold_flist_line = unfold_flist_file.readline()
        while unfold_flist_line:
            unfold_flist_line = unfold_flist_line.strip()
            for cur_duv_cfg_value in self.duv_cfg_dict.values():
                search_duv_cfg_value = re.search(r"%s" % cur_duv_cfg_value, unfold_flist_line)
                if search_duv_cfg_value:
                    #print("cur_duv_cfg_value(%s), unfold_flist_line(%s)" % (cur_duv_cfg_value, unfold_flist_line))
                    self.ori_fpath_list.append(unfold_flist_line)
                    stub_file_path = "%s/%s" % (self.duvcfg_subdir, cur_duv_cfg_value)
                    stub_flist_file.write("%s\n" % stub_file_path)
                else:
                    stub_flist_file.write("%s\n" % unfold_flist_line)
            unfold_flist_line = unfold_flist_file.readline()
        unfold_flist_file.close()

        stub_flist_file.close()

    def gen_stub_files(self):
        #for cur_ori_fpath in self.ori_fpath_list:
        #    cur_stub_fpath = "%s/%s" % (self.duvcfg_subdir, os.path.basename(cur_ori_fpath))
        #    cur_stub_file = open(cur_stub_fpath, 'w')
        #    cur_ori_file = open(cur_stub_fpath, 'r')

        #    cur_ori_line = cur_ori_file.readline()
        #    while cur_ori_line:
        #        cur_ori_line = cur_ori_line.strip()
        #        cur_ori_line = cur_ori_file.readline()

        #    cur_ori_file.close()
        #    cur_stub_file.close()
        pass

    def init_duvcfg(self):
        if not self.has_duv_cfg:
            print("[INFO] no duvcfg.yml, don't need do init_duvcfg!")
            return True
        else:
            duvcfg_dir = "%s/tb/duvcfg" % self.work_dir
            if not os.path.isdir(duvcfg_dir):
                os.mkdir(duvcfg_dir)

        for duv_cfg_key in self.duv_cfg_dict:
            for i in range(2):
                if i == 0:
                    self.duvcfg_subdir = "%s/tb/duvcfg/pre_%s" % (self.work_dir, duv_cfg_key.lower())
                    duv_flist = self.pre_sim_duv_flist
                else:
                    self.duvcfg_subdir = "%s/tb/duvcfg/post_%s" % (self.work_dir, duv_cfg_key.lower())
                    duv_flist = self.post_sim_duv_flist

                if not os.path.isdir(self.duvcfg_subdir):
                    os.mkdir(self.duvcfg_subdir)
                duv_flist = self.get_file_abspath(duv_flist)
                if not os.path.isfile(duv_flist):
                    PubFunc.exit_err("duv_flist(%s) not exist!" % duv_flist)
                self.unfold_flist_path = "%s/unfold_%s" % (self.duvcfg_subdir, os.path.basename(duv_flist))
                self.stub_flist_path = "%s/%s" % (self.duvcfg_subdir, os.path.basename(duv_flist))
                #print("stub_flist_path(%s)" % self.stub_flist_path)

                self.unfold_flist_file = open(self.unfold_flist_path, 'w')
                self.gen_unfold_flist(duv_flist)
                self.unfold_flist_file.close()

                self.gen_stub_flist()
                self.gen_stub_files()

    def gen_doc_make(self):
        command_to_be_executed = "%s/../../docmakegen/docmakegen.py -doc ${WORK_DIR}/doc" % cur_scr_dir
        command_to_be_executed = command_to_be_executed.replace('  ', ' ')
        print("execute command :")
        print(command_to_be_executed)
        os.system(command_to_be_executed)

    def run_doc_make(self):
        command_to_be_executed = "make -f ${WORK_DIR}/doc/Makefile all"
        command_to_be_executed = command_to_be_executed.replace('  ', ' ')
        print("execute command :")
        print(command_to_be_executed)
        os.system(command_to_be_executed)

    def gen_exti_case(self):
        command_to_be_executed = "%s/../../extigen/extigen.py -e %s -p ${WORK_DIR}" % (cur_scr_dir, self.env_cfg_dict["exti_filename"])
        command_to_be_executed = command_to_be_executed.replace('  ', ' ')
        print("execute command :")
        print(command_to_be_executed)
        os.system(command_to_be_executed)

    def init_env(self, cmd_args):
        if cmd_args.is_init_all or cmd_args.is_docmake:
            self.gen_doc_make()
            self.run_doc_make()
        if cmd_args.is_init_all or cmd_args.is_duvcfg:
            self.init_duvcfg()
        if cmd_args.is_init_all or cmd_args.is_genexti:
            if self.env_cfg_dict.__contains__("exti_filename"):
                self.gen_exti_case()
