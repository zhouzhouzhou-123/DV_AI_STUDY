#!/usr/bin/env python3

import os
import sys
import re
import random
import getpass

from pubfunc import PubFunc

MAX_ARGV_NUM = 9

class CmdArgs:
    def __init__(self, argv, env_cfg):
        self.argv = argv
        self.env_cfg = env_cfg
        self.need_argv = []
        for i in range(MAX_ARGV_NUM):
            self.need_argv.append(False)
        self.need_argv[0] = True
        self.need_argv[1] = True
        
        self.is_help = False
        self.is_vsif = False
        self.is_make = False
        self.is_run = False
        self.is_incr_run = False
        self.is_verdi = False
        self.is_vio = False
        self.is_cov = False
        self.is_vm = False
        self.is_clean = False
        self.is_init = False
        self.is_regr = False
        self.is_cov = False
        self.is_bsub = False
        self.is_xprop = False
        self.is_nocomp = False
        self.is_comp = False
        self.is_comp_rtl = False
        self.is_comp_tb = False
        # split-library skip status (filled by csrun, informational)
        self.m_split_rtl_skipped = False
        self.m_split_tb_skipped = False
        self.is_vmcomp = False
        self.is_vmnocomp = False
        self.is_vmcomplink= False
        self.is_vdbmerge= False
        self.is_vmsimclean= False
        self.is_pkg = False
        self.is_pa = False
        self.is_xa = False
        self.is_post = False
        self.locallog_keep = True 
        self.is_dc = False
        self.is_pr = False
        self.is_pg = False
        self.is_xa_post = False
        self.is_duv = False
        self.is_vhdl = False
        self.is_init_all = False
        self.is_docmake = False
        self.is_duvcfg = False
        self.is_genexti = False
        self.is_vhdl_comp = False
        self.is_vmnocomp_fsdb_dump = True 
        self.is_timedelay = False
        self.timedelay_value = ""
        self.corner = ""
        self.test_name = ""
        self.str_plusargs = ""
        self.user_plusargs = ""
        self.test_log_name = ""
        self.test_file_path = ""
        self.test_dir_path = ""
        self.test_c_files_path = []
        self.test_sv_files_path = []
        self.comp_test_name = ""
        self.sim_test_name = ""
        self.sim_dir = ""
        self.sim_type_prefix = ""
        self.coverage_result_path = ""
        self.wave_dir_path = ""
        self.log_dir_path = ""
        self.vmcomp_dir_path = ""
        self.brun_group_dir  = ""
        self.xa_log_dir_path = ""
        self.simv_file_path = ""
        self.comp_result_path = ""
        self.vhdlan_log_file_path = ""
        self.vlogan_log_file_path = ""
        self.elab_log_file_path = ""
        self.comp_log_file_path = ""
        self.vm_local_log_file_path = ""
        self.sim_log_file_path = ""
        self.sim_error_log_file_path = ""
        self.sim_wave_file_path = ""
        self.is_random = True
        self.rand_seed = -1
        self.cache_opt = 1
        self.boot_opt = 1
        self.usr_macros = []
        self.str_usr_macros = ""
        self.define_usr_macros = ""
        self.add_usr_plusargs = ""
        self.c_usr_macros = ""
        self.xa_spice = "input.sp"
        self.verdi_pretitle = ""
        self.xa_cfg = "default_cfg"
        self.xa_init = "default_vcsAD.init"
        self.xa_spice_file_path = ""
        self.xa_cfg_file_path = ""
        self.xa_init_file_path = ""
        self.vio_target = "regression/result"
        self.vio_target_path = ""
        self.argv_idx = 1
        self.cur_user = getpass.getuser()

    def __str__(self):
        str_info = ""
        str_info += "------ %s Start ------\n" % "CmdArgs"
        str_info += "argv(%s)\n" % self.argv
        for i in range(len(self.need_argv)):
            str_info += "need_argv[%d](%s)\n" % (i, self.need_argv[i])
        str_info += "is_help(%s)\n" % self.is_help
        str_info += "is_make(%s)\n" % self.is_make
        str_info += "is_run(%s)\n" % self.is_run
        str_info += "is_verdi(%s)\n" % self.is_verdi
        str_info += "is_vio(%s)\n" % self.is_vio
        str_info += "is_cov(%s)\n" % self.is_vm
        str_info += "is_clean(%s)\n" % self.is_clean
        str_info += "is_init(%s)\n" % self.is_init
        str_info += "is_regr(%s)\n" % self.is_regr
        str_info += "is_cov(%s)\n" % self.is_cov
        str_info += "is_bsub(%s)\n" % self.is_bsub
        str_info += "is_xprop(%s)\n" % self.is_xprop
        str_info += "is_nocomp(%s)\n" % self.is_nocomp
        str_info += "is_pa(%s)\n" % self.is_pa
        str_info += "is_xa(%s)\n" % self.is_xa
        str_info += "is_post(%s)\n" % self.is_post
        str_info += "is_dc(%s)\n" % self.is_dc
        str_info += "is_pr(%s)\n" % self.is_pr
        str_info += "is_pg(%s)\n" % self.is_pg
        str_info += "is_xa_post(%s)\n" % self.is_xa_post
        str_info += "is_duv(%s)\n" % self.is_duv
        str_info += "is_vhdl(%s)\n" % self.is_vhdl
        str_info += "is_init_all(%s)\n" % self.is_init_all
        str_info += "is_docmake(%s)\n" % self.is_docmake
        str_info += "is_duvcfg(%s)\n" % self.is_duvcfg
        str_info += "is_genexti(%s)\n" % self.is_genexti
        str_info += "is_vhdl_comp(%s)\n" % self.is_vhdl_comp
        str_info += "corner(%s)\n" % self.corner
        str_info += "test_name(%s)\n" % self.test_name
        str_info += "test_file_path(%s)\n" % self.test_file_path
        str_info += "test_dir_path(%s)\n" % self.test_dir_path
        str_info += "test_c_files_path(%s)\n" % self.test_c_files_path
        str_info += "comp_test_name(%s)\n" % self.comp_test_name
        str_info += "sim_test_name(%s)\n" % self.sim_test_name
        str_info += "wave_dir_path(%s)\n" % self.wave_dir_path
        str_info += "log_dir_path(%s)\n" % self.log_dir_path
        str_info += "vmcomp_dir_path(%s)\n" % self.vmcomp_dir_path
        str_info += "xa_log_dir_path(%s)\n" % self.xa_log_dir_path
        str_info += "is_random(%s)\n" % self.is_random
        str_info += "rand_seed(%d)\n" % self.rand_seed
        str_info += "cache_opt(%d)\n" % self.cache_opt
        str_info += "boot_opt(%d)\n" % self.boot_opt
        for i in range(len(self.usr_macros)):
            str_info += "usr_macros[%d](%s)\n" % (i, self.usr_macros[i])
        str_info += "str_usr_macros(%s)\n" % self.str_usr_macros
        str_info += "define_usr_macros(%s)\n" % self.define_usr_macros
        str_info += "c_usr_macros(%s)\n" % self.c_usr_macros
        str_info += "xa_spice(%s)\n" % self.xa_spice
        str_info += "xa_spice_file_path(%s)\n" % self.xa_spice_file_path
        str_info += "xa_cfg(%s)\n" % self.xa_cfg
        str_info += "xa_cfg_file_path(%s)\n" % self.xa_cfg_file_path
        str_info += "xa_init(%s)\n" % self.xa_init
        str_info += "xa_init_file_path(%s)\n" % self.xa_init_file_path
        str_info += "vio_target(%s)\n" % self.vio_target
        str_info += "vio_target_path(%s)\n" % self.vio_target_path
        str_info += "argv_idx(%d)\n" % self.argv_idx
        str_info += "========= %s End =========\n" % "CmdArgs"
        return str_info

    def get_suffix(self, cur_argv, cur_cmd):
        cur_suffix_list = cur_argv.split("_")
        cur_suffix_list = PubFunc.rm_item_in_list(cur_suffix_list, cur_cmd)
        #print("cur_suffix_list(%s)" % cur_suffix_list)
        return cur_suffix_list


    def parse_argv1(self):
        if len(self.argv) == 1:
            return False 
        cur_argv = self.argv[self.argv_idx].lower()
        self.argv_idx += 1
        #print("parse_argv1-argv_idx=%0d" % self.argv_idx)
        #print("cur_argv(%s)" % cur_argv)

        # --- match calc ---
        match_help = re.match(r'^[-]*h(elp)*$', cur_argv)
        match_make = re.match(r'^[-]*make$', cur_argv)
        match_incr_run = re.match(r'^[-]*incr_run(_)*', cur_argv)
        match_run = re.match(r'^[-]*run(_)*', cur_argv)
        match_comp_rtl = re.match(r'^[-]*comp_rtl$', cur_argv)
        match_comp_tb = re.match(r'^[-]*comp_tb$', cur_argv)
        match_comp_only = re.match(r'^[-]*comp$', cur_argv)
        match_verdi = re.match(r'^[-]*verdi(_)*', cur_argv)
        match_vio = re.match(r'^[-]*vio$', cur_argv)
        match_cov = re.match(r'^[-]*cov(_)*', cur_argv)
        match_vm = re.match(r'^[-]*vm$', cur_argv)
        match_clean = re.match(r'^[-]*clean$', cur_argv)
        match_init = re.match(r'^[-]*init(_)*', cur_argv)
        match_vmcomplink = re.match(r'^[-]*vmcomplink(_)*', cur_argv)
        match_vmsimclean= re.match(r'^[-]*vmsimclean(_)*', cur_argv)
        match_vdbmerge  = re.match(r'^[-]*vdbmerge(_)*', cur_argv)
        match_vsif  = re.match(r'^[-]*vsif*$', cur_argv)
        match_timedelay = re.match(r'^[-]*timedelay$', cur_argv)

        # --- parse argv1 ---
        if match_help:
            self.is_help = True
        elif match_make:
            self.is_make = True
            self.need_argv[self.argv_idx] = True
        elif match_incr_run:
            self.is_run = True
            self.is_incr_run = True
            self.need_argv[self.argv_idx] = True
        elif match_run:
            self.is_run = True
            self.need_argv[self.argv_idx] = True
        elif match_comp_rtl:
            # compile ONLY the shared RTL library (split-library flow)
            self.is_run = True
            self.is_comp_rtl = True
            self.is_comp = True
            self.need_argv[self.argv_idx] = True
        elif match_comp_tb:
            # compile ONLY the TB library + testcase (split-library flow)
            self.is_run = True
            self.is_comp_tb = True
            self.is_comp = True
            self.need_argv[self.argv_idx] = True
        elif match_comp_only:
            # bare 'comp' : compile only (same as run_comp)
            self.is_run = True
            self.is_comp = True
            self.need_argv[self.argv_idx] = True
        elif match_verdi:
            self.is_verdi = True
            self.need_argv[self.argv_idx] = True
        elif match_vio:
            self.is_vio = True
            self.need_argv[self.argv_idx] = True
        elif match_cov:
            self.is_cov = True
        elif match_vmcomplink:
            self.is_vmcomplink = True
        elif match_vdbmerge:
            self.is_vdbmerge = True
        elif match_vmsimclean:
            self.is_vmsimclean = True
        elif match_vm:
            self.is_vm = True
        elif match_clean:
            self.is_clean = True
        elif match_init:
            self.is_init = True
        elif match_vsif:
            self.is_vsif = True
        elif match_timedelay:
            self.is_timedelay = True
            self.need_argv[self.argv_idx] = True
        else:
            PubFunc.print_err("not support 1st argv(%s)" % cur_argv)
            return False

        # --- parse argv1 suffix of run ---
        if self.is_run:
            if self.is_incr_run:
                suffix_list = self.get_suffix(cur_argv, "incr_run")
                # Remove "run" from suffix list since it's part of "incr_run"
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "run")
            else:
                suffix_list = self.get_suffix(cur_argv, "run")

            if "incr" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "incr")

            if "bsub" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "bsub")
                self.is_bsub = True

            if "pkg" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pkg")
                self.is_pkg = True

            if "xprop" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "xprop")
                self.is_xprop = True

            if "nocomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "nocomp")
                self.is_nocomp = True

            if "comp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "comp")
                self.is_comp = True

            if "vmcomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "vmcomp")
                self.is_vmcomp = True

            if "vmnocomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "vmnocomp")
                self.is_vmnocomp = True

            if "pa" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pa")
                self.is_pa = True

            if "dc" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "dc")
                self.is_dc = True

            if "pr" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pr")
                self.is_pr = True

            if "pg" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pg")
                self.is_pg = True

            if "xa" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "xa")
                self.is_xa = True
                self.is_xprop = False

            if len(suffix_list) == 1:
                self.corner = suffix_list[0]
                self.is_post = True
                self.is_xprop = False
            elif len(suffix_list) > 1:
                PubFunc.print_err("too many corner info(%s)! Only one corner is required!" % suffix_list)
                return False

        # --- parse argv1 suffix of run ---
        if self.is_verdi:
            suffix_list = self.get_suffix(cur_argv, "verdi")
            if "duv" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "duv")
                self.is_duv = True

            if "vhdl" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "vhdl")
                self.is_vhdl = True

            if "pkg" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pkg")
                self.is_pkg = True

            if "nocomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "nocomp")
                self.is_nocomp = True

            if "vmnocomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "vmnocomp")
                self.is_vmnocomp = True

            if "pa" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pa")
                self.is_pa = True

            if "dc" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "dc")
                self.is_dc = True

            if "pr" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pr")
                self.is_pr = True

            if "pg" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "pg")
                self.is_pg = True

            if "xa" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "xa")
                self.is_xa = True
                self.is_xprop = False

            if "post" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "post")
                self.is_post = True
                self.is_xprop = False
            
            if len(suffix_list) == 1:
                self.corner = suffix_list[0]
                self.is_post = True
            elif len(suffix_list) > 1:
                PubFunc.print_err("too many corner info(%s)! Only one corner is required!" % suffix_list)
                return False

        if self.is_cov:
            suffix_list = self.get_suffix(cur_argv, "verdi")
            if "vmnocomp" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "vmnocomp")
                self.is_vmnocomp = True


        # --- parse argv1 suffix common ---
        if self.is_xa and self.is_post:
            self.is_xa_post = True

        if all([self.is_regr,not self.is_post,not self.is_xa,not self.is_dc,not self.is_pr,not self.is_pg,not self.is_vmcomplink,not self.is_vmsimclean, not self.is_vdbmerge]):   
            self.is_cov = True
        
        # --- parse argv1 suffix of run ---
        if self.is_init:
            suffix_list = self.get_suffix(cur_argv, "init")
            if "all" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "all")
                self.is_init_all = True
            if "docmake" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "docmake")
                self.is_docmake = True
            elif "duvcfg" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "duvcfg")
                self.is_duvcfg = True
            elif "genexti" in suffix_list:
                suffix_list = PubFunc.rm_item_in_list(suffix_list, "genexti")
                self.is_genexti = True

        return True

    def parse_argv2(self):
        if not self.need_argv[self.argv_idx]:
            return True

        if len(self.argv) == self.argv_idx:
            if self.is_vio:
                self.need_argv[self.argv_idx] = False
                return True
            elif self.is_verdi:
                self.need_argv[self.argv_idx] = False
                return True
            else:
                PubFunc.print_err("run and verdi must have a test_name, but it's not in argv(%s) " % self.argv)
                return False

        cur_argv = self.argv[self.argv_idx].lower()
        self.argv_idx += 1

        #print("parse_argv2-argv_idx=%0d" % self.argv_idx)

        if self.is_run:
            self.test_name = cur_argv
            self.need_argv[self.argv_idx] = True
        elif self.is_verdi:
            match = re.search("\.log$",cur_argv)
            match_pretitle = re.match(r'^(pretitle=)(.+)$', cur_argv)
            if match:
                cur_argv=re.sub(re.escape(".log")+'$','',cur_argv)
                self.test_log_name = cur_argv
            elif match_pretitle:
                self.verdi_pretitle = match_pretitle.group(2)
            else:
                self.test_name = cur_argv  #mod by gaojiang
            self.need_argv[self.argv_idx] = True
        elif self.is_make:
            self.test_name = cur_argv
            #self.need_argv[self.argv_idx] = False
            self.need_argv[self.argv_idx] = True #mod by wangwei
        elif self.is_vio:
            self.vio_target = cur_argv
        elif self.is_timedelay:
            self.timedelay_value = cur_argv
            if len(self.argv) > self.argv_idx:
                next_argv = self.argv[self.argv_idx]
                if re.match(r'^\d{2}:\d{2}(:\d{2})?$', next_argv):
                    self.timedelay_value += " " + next_argv
                    self.argv_idx += 1

        return True

    def parse_argv_others(self):
        if not self.need_argv[self.argv_idx]:
            return True

        to_proc_argvs = self.argv[self.argv_idx:]
        #print("parse_argv_others-argv_idx=%0d" % self.argv_idx)
        for cur_argv in to_proc_argvs:
            #print("cur_argv(%s)" % self.argv)
            match_seed = re.match(r'^(seed=)*(-?\d+)$', cur_argv)
            match_cache = re.match(r'^(cache=)(\d+)$', cur_argv)
            match_boot = re.match(r'^(boot=)(\d+)$', cur_argv)
            match_define = re.match(r'^(define=)(.+)$', cur_argv)
            match_spice = re.match(r'^(spice=)(.+)$', cur_argv)
            match_cfg = re.match(r'^(cfg=)(.+)$', cur_argv)
            match_init = re.match(r'^(init=)(.+)$', cur_argv)
            match_pretitle = re.match(r'^(pretitle=)(.+)$', cur_argv)
            match_plusargs = re.match(r'^(plusargs=)(.+)$', cur_argv)

            if match_seed:
                self.rand_seed = int(match_seed.group(2))
                self.is_random = False
            elif match_cache:
                self.cache_opt = int(match_cache.group(2))
            elif match_boot:
                self.boot_opt = int(match_boot.group(2))
            elif match_define:
                macro_str = match_define.group(2)
                self.usr_macros = macro_str.split("+")
            elif match_spice:
                self.xa_spice = match_spice.group(2)
            elif match_cfg:
                self.xa_cfg = match_cfg.group(2)
            elif match_init:
                self.xa_init = match_init.group(2)
            elif match_pretitle:
                self.verdi_pretitle = match_pretitle.group(2)
            elif match_plusargs:
                args_str = match_plusargs.group(2)
                self.user_plusargs = args_str.split("+")
            else:
                if not (self.is_comp or self.is_vmcomp):
                    PubFunc.print_err("found args not support(%s) in argv(%s)" % (cur_argv, self.argv))
                    return False

        return True

    def parse_cmdargs(self):
        if self.env_cfg.use_vmanager:
            cur_vm_session_name = os.environ.get("BRUN_SESSION_NAME")
            if cur_vm_session_name != None:
                self.is_regr = True
                self.is_bsub = True
                self.is_vmnocomp_fsdb_dump = False
                self.argv.append("%s" % os.environ.get("BRUN_TEST_NAME"))
                self.brun_group_dir = os.environ.get("BRUN_GROUP_DIR")
                cur_sim_args = os.environ.get("BRUN_SIM_ARGS")
                if cur_sim_args is not None and cur_sim_args != "":
                    cur_sim_args_list = cur_sim_args.split()
                    for cur_sim_arg in cur_sim_args_list:
                        self.argv.append(cur_sim_arg)
                #print("argv_num(%0d), argv(%s)" % (len(self.argv), self.argv))

        if not self.parse_argv1():
            self.print_help_info()
            PubFunc.exit_err("argv(%s) not match format! Please get information from preview [ERROR]!" % self.argv)
        if not self.parse_argv2():
            self.print_help_info()
            PubFunc.exit_err("argv(%s) not match format! Please get information from preview [ERROR]!" % self.argv)
        if not self.parse_argv_others():
            self.print_help_info()
            PubFunc.exit_err("argv(%s) not match format! Please get information from preview [ERROR]!" % self.argv)

    def set_rand_seed(self):
        if self.is_random:
            if self.is_regr and self.env_cfg.use_vmanager:
                self.rand_seed = int(os.environ.get("BRUN_SV_SEED"))
            else:
                self.rand_seed = random.randint(0, 10000000)

    def add_macro_by_test_name(self):
        for test_name_key in self.env_cfg.add_macro_by_test_name_info:
            if test_name_key in self.test_name:
                macro_add_str = (self.env_cfg.add_macro_by_test_name_info[test_name_key]).split("+")
                self.usr_macros += macro_add_str

    def add_macro_by_post_common_macro(self):
        macro_add_str = self.env_cfg.post_common_macro.split("+")
        self.usr_macros += macro_add_str

    def add_vhdl_comp_cmd(self):
        if self.is_post or self.is_dc or self.is_pr or self.is_pg:
            self.is_vhdl_comp = False
            self.locallog_keep = True
        else:
            if self.env_cfg.is_mixed :
                self.is_vhdl_comp = True

    def add_macros(self):
        if self.corner != "":
            self.usr_macros.insert(0, "%s_CORNER" % self.corner.upper())

        if self.is_post or self.is_dc or self.is_pr or self.is_pg:
            self.usr_macros.insert(0, "POST_SIM_ON")
            if hasattr(self.env_cfg, "post_common_macro"):
                self.add_macro_by_post_common_macro()

        if self.is_xa:
            self.usr_macros.insert(0, "XA_SIM")

        if self.is_dc:
            self.usr_macros.insert(0, "DC_CORNER")            

        if self.is_pg:
            self.usr_macros.insert(0, "PG_CORNER")

        if self.is_pa:
            self.usr_macros.insert(0, "PA_SIM")

        if self.is_regr:
            self.usr_macros.insert(0, "FSDB_DUMP_OFF")

        if self.is_vmnocomp:
            if self.is_vmnocomp_fsdb_dump:
                self.usr_macros.insert(0, "FSDB_DUMP_OFF")

        if hasattr(self.env_cfg, "add_macro_by_test_name_info"):
            self.add_macro_by_test_name()

        if len(self.usr_macros) > 0:
            self.str_usr_macros = "_".join(self.usr_macros)
            self.str_usr_macros = self.str_usr_macros.lower()

            self.define_usr_macros = "+define"
            for cur_usr_macro in self.usr_macros:
                self.define_usr_macros += "+%s" % cur_usr_macro

            self.c_usr_macros = ""
            for i in range(len(self.usr_macros)):
                if i == 0:
                    self.c_usr_macros += "%s" % self.usr_macros[i]
                else:
                    self.c_usr_macros += "+%s" % self.usr_macros[i]

    def add_plusargs(self):
        if len(self.user_plusargs) > 0:
            #self.str_plusargs = "+".join(self.user_plusargs)
            self.str_plusargs = "_".join(self.user_plusargs)
            self.str_plusargs = self.str_plusargs.lower()

            for cur_user_plusargs in self.user_plusargs:
                self.add_usr_plusargs += " +%s"% cur_user_plusargs
                #self.str_plusargs += " +%s" % cur_user_plusargs

    def check_set_testcase(self):
        for root, dirs, files in os.walk(self.env_cfg.testcases_dir_path):
            for cur_file in files:
                sv_test_name = "%s.sv" % self.test_name
                if cur_file == sv_test_name:
                    self.test_file_path = os.path.join(root, cur_file)
                    break
        if not os.path.isfile(self.test_file_path):
            PubFunc.exit_err("Can't find test_name(%s) in testcases_dir_path(%s)\n" % (sv_test_name, os.path.abspath(self.env_cfg.testcases_dir_path)))

    def set_c_testcase(self):
        for root, dirs, files in os.walk(self.env_cfg.testcases_dir_path):
            for cur_dir in dirs:
                if cur_dir == self.test_name:
                    self.test_dir_path = os.path.join(root, cur_dir)
                    break
        if os.path.isdir(self.test_dir_path):
            for root, dirs, files in os.walk(self.test_dir_path):
                for cur_file in files:
                    match_c_case = re.match(r'^.+\.c$', cur_file)
                    if match_c_case:
                        cur_test_c_file_path = os.path.join(root, cur_file)
                        self.test_c_files_path.append(cur_test_c_file_path)
                        break

    def check_set_xa_file_path(self):
        self.xa_spice_file_path = os.path.abspath("%s/spice/spice/%s" % (self.env_cfg.work_dir, self.xa_spice))
        if not os.path.isfile(self.xa_spice_file_path):
            PubFunc.exit_err("xa_spice_file_path(%s) not exist!\n" % self.xa_spice_file_path)

        self.xa_cfg_file_path = os.path.abspath("%s/spice/cfg/%s" % (self.env_cfg.work_dir, self.xa_cfg))
        if not os.path.isfile(self.xa_cfg_file_path):
            PubFunc.exit_err("xa_cfg_file_path(%s) not exist!\n" % self.xa_cfg_file_path)

        self.xa_init_file_path = os.path.abspath("%s/spice/ini/%s" % (self.env_cfg.work_dir, self.xa_init))
        if not os.path.isfile(self.xa_init_file_path):
            PubFunc.exit_err("xa_init_file_path(%s) not exist!\n" % self.xa_init_file_path)

    def set_test_comp_sim_name(self):
        if self.str_usr_macros == "":
            if self.is_pkg or self.is_vmnocomp:
                self.comp_test_name = "%s" % (self.env_cfg.simv_test_pkg)
            else:
                self.comp_test_name = self.test_name
            self.sim_test_name = "%s_%s" % (self.test_name, self.rand_seed)
        else:
            if self.is_pkg or self.is_vmnocomp:
                self.comp_test_name = "%s_with_macros_%s" % (self.env_cfg.simv_test_pkg, self.str_usr_macros)
            else:
                self.comp_test_name = "%s_with_macros_%s" % (self.test_name, self.str_usr_macros)
            self.sim_test_name = "%s_%s_with_macros_%s" % (self.test_name, self.rand_seed, self.str_usr_macros)

    
    def set_test_dirs(self):
        # Determine simulation type prefix first (needed for path construction)
        self.sim_type_prefix = "presim"
        if self.is_post or self.is_dc or self.is_pr or self.is_pg:
            self.sim_type_prefix = "postsim"
        elif self.is_pa:
            self.sim_type_prefix = "pasim"
        elif self.is_xa:
            self.sim_type_prefix = "xasim"

        # Determine comp directory name based on pkg mode
        if self.is_pkg or self.is_vmcomp:
            comp_dir_name = self.env_cfg.simv_test_pkg
        else:
            comp_dir_name = self.test_name

        if self.is_regr:
            self.vmcomp_dir_path = "%s/comp_result/%s/comp_%s" % (self.env_cfg.vmcomp_path, self.sim_type_prefix, comp_dir_name)   
            if self.is_comp:
                self.sim_dir = self.vmcomp_dir_path
                #self.coverage_result_path = self.vmcomp_dir_path
            else:
                self.sim_dir = os.environ.get("BRUN_RUN_DIR")
                self.vm_local_log_file_path = "%s/local_log.log" %(self.sim_dir)
                #self.coverage_result_path = os.environ.get("BRUN_RUN_DIR")
        else:
            self.sim_dir = os.path.abspath(os.environ.get("SIM_DIR"))

        if not os.path.isdir(self.sim_dir):
            PubFunc.exit_err("sim_dir(%s) not exist!\n" % self.sim_dir)

        # Keep first half as $SIM_DIR/comp_result, add sim_type_prefix and comp_dir_name as subdirectories
        self.comp_result_path = "%s/comp_result/%s/comp_%s" % (self.sim_dir, self.sim_type_prefix, comp_dir_name)

        self.sim_result_path = "%s/result/%s" % (self.sim_dir, self.sim_type_prefix)

        if "XA_SIM" in self.usr_macros:
            self.wave_dir_path = "%s/%s/%s/%s" % (self.sim_dir, self.env_cfg.xa_log_dirname, self.sim_type_prefix, self.test_name)
        else:
            self.wave_dir_path = "%s/%s/%s/%s" % (self.sim_dir, self.env_cfg.wave_dirname, self.sim_type_prefix, self.test_name)
        self.log_dir_path = "%s/%s/%s/%s" % (self.sim_dir, self.env_cfg.log_dirname, self.sim_type_prefix, self.test_name)
        self.xa_log_dir_path = "%s/%s/%s/%s" % (self.sim_dir, self.env_cfg.xa_log_dirname, self.sim_type_prefix, self.test_name)

        if not os.path.isdir(self.comp_result_path):
            os.makedirs(self.comp_result_path)
        if not os.path.isdir(self.sim_result_path):
            os.makedirs(self.sim_result_path)

        if not os.path.exists(self.wave_dir_path):
            os.makedirs(self.wave_dir_path)
        if not os.path.exists(self.log_dir_path):
            os.makedirs(self.log_dir_path)
        if "XA_SIM" in self.usr_macros:
            if not os.path.exists(self.xa_log_dir_path):
                os.makedirs(self.xa_log_dir_path)
        if self.env_cfg.use_vmcomp_path:
            if not os.path.exists(self.env_cfg.vmcomp_path):
                os.makedirs(self.env_cfg.vmcomp_path)

    def set_test_comp_sim_path(self):
        self.set_test_comp_sim_name()
        self.set_test_dirs()
        if self.is_vmnocomp:
            if self.env_cfg.simv_test_pkg in self.comp_test_name:
                comp_dir_name = "comp_%s" % self.env_cfg.simv_test_pkg
            else:
                comp_dir_name = "comp_%s" % self.test_name
            self.simv_file_path = "%s/comp_result/%s/%s/simv_%s" % (self.env_cfg.vmcomp_path, self.sim_type_prefix, comp_dir_name, self.comp_test_name)
        else:
            self.simv_file_path = "%s/simv_%s" % (self.comp_result_path, self.comp_test_name)

        self.vhdlan_log_file_path = "%s/vhdlan_%s.log" % (self.comp_result_path, self.comp_test_name)
        self.vlogan_log_file_path = "%s/vlogan_%s.log" % (self.comp_result_path, self.comp_test_name)
        self.vlogan_rtl_log_file_path = "%s/vlogan_rtl_%s.log" % (self.comp_result_path, self.comp_test_name)
        self.vlogan_tb_log_file_path = "%s/vlogan_tb_%s.log" % (self.comp_result_path, self.comp_test_name)
        self.elab_log_file_path = "%s/elab_%s.log" % (self.comp_result_path, self.comp_test_name)
        self.comp_log_file_path = "%s/comp_%s.log" % (self.comp_result_path, self.comp_test_name)
        if "XA_SIM" in self.usr_macros:
            self.sim_log_file_path = "%s/%s.log" % (self.xa_log_dir_path, self.sim_test_name)
            self.sim_error_log_file_path = "%s/%s_error_detect.log" % (self.xa_log_dir_path, self.sim_test_name)
        else:
            if len(self.user_plusargs) > 0:
                self.sim_log_file_path = "%s/%s_%s.log" % (self.log_dir_path, self.sim_test_name,self.str_plusargs)
            else:
                self.sim_log_file_path = "%s/%s.log" % (self.log_dir_path, self.sim_test_name)
            self.sim_error_log_file_path = "%s/%s_error_detect.log" % (self.log_dir_path, self.sim_test_name)

        if "VCD_DUMP_ON" in self.usr_macros:
            self.sim_wave_file_path = "%s/%s.vcd" % (self.wave_dir_path, self.sim_test_name)
        else:
            self.sim_wave_file_path = "%s/%s.fsdb" % (self.wave_dir_path, self.sim_test_name)

    def check_set_vio_target_path(self):
        self.vio_target_path = os.path.abspath("%s/%s" % (self.env_cfg.work_dir, self.vio_target))
        if not os.path.isdir(self.vio_target_path):
            PubFunc.exit_err("vio_target_path(%s) not exist!" % self.vio_target_path)

    def chg_flist(self):
        if not os.path.isfile(self.test_file_path):
            return True

        test_file = open(self.test_file_path, 'r')

        test_line = test_file.readline()
        while test_line:
            test_line = test_line.strip()
            match_cpu_vip = re.match(r'\s*`define\s+CPU_VIP', test_line)
            if match_cpu_vip:
                if len(self.usr_macros) == 0:
                    self.define_usr_macros += "+define+CPU_VIP"
                elif len(self.usr_macros) > 0:
                    self.define_usr_macros += "+CPU_VIP"

                if self.is_dc:
                    duv_flist = os.path.basename(self.env_cfg.post_sim_dc_duv_flist)
                    self.env_cfg.post_sim_dc_duv_flist = "%s/tb/duvcfg/post_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                elif self.is_pr:
                    duv_flist = os.path.basename(self.env_cfg.post_sim_pr_duv_flist)
                    self.env_cfg.post_sim_pr_duv_flist = "%s/tb/duvcfg/post_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                elif self.is_pg:
                    duv_flist = os.path.basename(self.env_cfg.post_sim_pr_duv_flist)
                    self.env_cfg.post_sim_pg_duv_flist = "%s/tb/duvcfg/post_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                elif self.is_post:
                    duv_flist = os.path.basename(self.env_cfg.post_sim_duv_flist)
                    self.env_cfg.post_sim_duv_flist = "%s/tb/duvcfg/post_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                elif self.is_pa:
                    duv_flist = os.path.basename(self.env_cfg.pa_sim_duv_flist)
                    self.env_cfg.pa_sim_duv_flist = "%s/tb/duvcfg/post_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                else:
                    duv_flist = os.path.basename(self.env_cfg.pre_sim_duv_flist)
                    self.env_cfg.pre_sim_duv_flist = "%s/tb/duvcfg/pre_cpu_vip/%s" % (self.env_cfg.work_dir, duv_flist)
                break
            test_line = test_file.readline()
        test_file.close()

    def post_process(self):
        if self.is_run:
            self.set_rand_seed()
            self.add_macros()
            self.add_plusargs()
            self.check_set_testcase()
            self.set_c_testcase()
            self.set_test_comp_sim_path()
            self.add_vhdl_comp_cmd()
            if self.is_xa:
                self.check_set_xa_file_path()
            self.chg_flist()
        elif self.is_verdi:
            self.add_macros()
            self.add_plusargs()            
            self.set_test_comp_sim_path()
            self.add_vhdl_comp_cmd()            
            self.chg_flist()
        elif self.is_make:
            self.add_macros()
            self.add_plusargs()            
            self.check_set_testcase()
            self.set_c_testcase()
            self.set_test_comp_sim_path()
        elif self.is_vio:
            self.check_set_vio_target_path()
        elif self.is_clean:
            self.set_test_dirs()

    def print_help_info(self):
        help_info = '''\
-------------------------------------------------------------------------------------

| --------------------------Version number V1.1---------------------------------- |

| VERSION UPDATE: add func for cov and testname                                   |

| --------------------------Version number V1.2---------------------------------- |

|  VERSION UPDATE: add post_group_script   vmcomplink                             |

|  VERSION UPDATE: add post_run_script     vmsimclean                             |

|  VERSION UPDATE: add post_session_script vdbmerge                               |

| --------------------------Version number V1.3---------------------------------- |

|  VERSION UPDATE: add plusargs for simulation                                    |

| You can use this script like this:  m OPERATION [TESTCASE_NAME] [DEFINE] [SEED] |
-------------------------------------------------------------------------------------

[DEFINE]
FSDB_DUMP_OFF
    Disable FSDB dump. By default, FSDB dump is enabled.

VCD_DUMP_ON
    Enable VCD dump. By default, FSDB dump is enabled.

------------------------------------------------
For example:
  --------------------------------------------------------------------------------------------------------------------------------------------------------------
  |m |  Command Type  | Testcase Name |           User Defines/Seed/XA Options                 |                   Description                                 |
  --------------------------------------------------------------------------------------------------------------------------------------------------------------
   m     h                                                                                      ## show this help infomation

   m     make             tc_xxx                                                                ## only c compile

   m     run              tc_xxx                                                                ## pre_sim : random seed && FSDB enable

   m     run              tc_xxx       111                                                      ## pre_sim : seed=111
   m     run              tc_xxx       seed=111                                                 ## pre_sim : seed=111
   m     run              tc_xxx       plusargs=USER_PLUS=1                                     ## pre_sim : add plusargs USER_PLUS=1
   m     run              tc_xxx       plusargs=USER_PLUS0=1+USER_PLUS1=2                       ## pre_sim : add plusargs USER_PLUS0=1 USER_PLUS1 = 2

   m     run              tc_xxx       define=FSDB_DUMP_OFF                                     ## pre_sim : random seed && FSDB disable
   m     run              tc_xxx       define=VCD_DUMP_ON                                       ## pre_sim : random seed && VCD enable

   m     run              tc_xxx       define=USER_MACRO                                        ## pre_sim : define one marco
   m     run              tc_xxx       define=USER_MACRO_0+USER_MACRO_1                         ## pre_sim : define multi macro USER_MACRO_0, USER_MACRO_1
   m     run              tc_xxx       define=USER_MACRO plusargs=USER_PLUS=1                   ## pre_sim : define marco and plusargs
   
   m     run              tc_xxx       cache=1                                                  ## pre_sim : if cache_en 1
                                                                                                ## 0: cache disable
                                                                                                ## 1: cache enable
   
   m     run_nocomp       tc_xxx                                                                ## pre_sim : not re-compile duv & tb (VHDL/Verilog/SystemVerilog)

   m     run_nocomp       tc_xxx       plusargs=USER_PLUS=1                                     ## pre_sim : not re-compile duv & tb (VHDL/Verilog/SystemVerilog) and add plusargs USER_PLUS=1

   m     run_xprop        tc_xxx                                                                ## pre_sim : run with xprop, the xprop config file is $WORK_DIR/cfg/xprop.cfg
   m     run_dc           tc_xxx                                                                ## post_sim : NO_SDF dc netlist simulation
   m     run_pr           tc_xxx                                                                ## post_sim : NO_SDF pr netlist simulation
   m     run_ss           tc_xxx                                                                ## post_sim : SS_CORNER
   m     run_ff           tc_xxx                                                                ## post_sim : FF_CORNER
   m     run_tt           tc_xxx                                                                ## post_sim : TT_CORNER
   m     run_xx           tc_xxx                                                                ## post_sim : XX_CORNER

   m     run_dc_pkg       tc_xxx                                                                ## post_sim : comp gen simv name with test_pkg,NO_SDF dc netlist simulation
   m     run_pr_pkg       tc_xxx                                                                ## post_sim : comp gen simv name with test_pkg,NO_SDF pr netlist simulation
   m     run_ss_pkg       tc_xxx                                                                ## post_sim : comp gen simv name with test_pkg,SS_CORNER simulation 
   m     run_ff_pkg       tc_xxx                                                                ## post_sim : comp gen simv name with test_pkg,FF_CORNER simulation
   m     run_tt_pkg       tc_xxx                                                                ## post_sim : comp gen simv name with test_pkg,TT_CORNER simulation

   m     run_dc_pkg_nocomp tc_xxx                                                               ## post_sim : not re-compile run with simv_test_pkg NO_SDF dc netlist simulation
   m     run_pr_pkg_nocomp tc_xxx                                                               ## post_sim : not re-compile run with simv_test_pkg NO_SDF pr netlist simulation
   m     run_ss_pkg_nocomp tc_xxx                                                               ## post_sim : not re-compile run with simv_test_pkg SS_CORNER simulation 
   m     run_ff_pkg_nocomp tc_xxx                                                               ## post_sim : not re-compile run with simv_test_pkg FF_CORNER simulation
   m     run_tt_pkg_nocomp tc_xxx                                                               ## post_sim : not re-compile run with simv_test_pkg TT_CORNER simulation

   m     run_xa           tc_xxx                                                                ## co-pre-sim  : with default_vcsAD.init && default_cfg && input.sp
   m     run_xa_ff        tc_xxx                                                                ## co-post-sim : FF_CORNER
   m     run_xa_ss        tc_xxx                                                                ## co-post-sim : SS_CORNER
   m     run_xa_xx        tc_xxx                                                                ## co-post-sim : XX_CORNER
   m     run_xa           tc_xxx       spice=AA.sp cfg=BB_cfg init=CC.ini                       ## co-pre-sim  : with specified spcie && cfg && init
   m     run_xa_xx        tc_xxx       spice=AA.sp cfg=BB_cfg init=CC.ini                       ## co-post-sim : XX_CORNER with specified spcie && cfg && init

   m     run_pkg          tc_xxx       define=USER_MACRO                                        ## gen simv name with test_pkg,add pkg args in run_xxx,example:run_dc_pkg run_pr_pkg
   m     run_pkg_nocomp   tc_xxx       define=USER_MACRO                                        ## not re-compile run with simv_test_pkg

   m     run_comp         tc_xxx       define=USER_MACRO                                        ## compile RTL and testbench if is_regr compile result in vmcomp_path
   m     run_vmcomp       tc_xxx       define=USER_MACRO                                        ## compile RTL and testbench if is_regr compile result in brun_dir
   m     comp_rtl         tc_xxx       define=USER_MACRO                                        ## split-lib : compile ONLY the shared RTL library (needs split_lib in envcfg.yml)
   m     comp_tb          tc_xxx       define=USER_MACRO                                        ## split-lib : compile ONLY the TB library + testcase (reuses RTL_LIB)
   m     run_comp_pkg     tc_xxx       define=USER_MACRO                                        ## compile RTL and testbench in comp_path and gen simv name with test_pkg
   m     run_vmcomp_pkg   tc_xxx       define=USER_MACRO                                        ## compile RTL and testbench in comp_path and gen simv name with test_pkg
   m     run_vmnocomp     tc_xxx       define=USER_MACRO                                        ## vm simulation with simv_test_pkg in vmcomp_path
                                                                                                ## run_post_vmnocomp run_dc_vmnocomp .etc: vm simulation with simv_test_pkg in vmcomp_path
   m     run_vmnocomp     tc_xxx       define=USER_MACRO  plusargs=USER_PLUS=1                  ## vm simulation with simv_test_pkg in vmcomp_path add define and plusargs
   m     run_vmnocomp     tc_xxx       plusargs=USER_PLUS=1                                     ## vm simulation with simv_test_pkg in vmcomp_path add plusargs

   m     verdi                                                                                  ## verdi for RTL
   m     verdi_vhdl                                                                             ## verdi for RTL with VHDL
   m     verdi_pa                                                                               ## verdi for RTL with UPF      
   m     verdi_nocomp                                                                           ## verdi for RTL with VHDL nocomp
   m     verdi                            define=FPGA_SIM+GPIO_TEST                             ## verdi with multi-define
   m     verdi_dc                                                                               ## verdi for dc netlist without sdf
   m     verdi_pr                                                                               ## verdi for pr netlist without sdf
   m     verdi_ss                                                                               ## verdi for pr netlist with ss corner sdf
   m     verdi_post                                                                             ## verdi for NETLIST
   m     verdi_xa                                                                               ## verdi for co-simulation
   m     verdi_xa_post                                                                          ## verdi for POST co-simulation
   m     verdi            pretitle=AAA                                                          ## verdi add pretitle AAA 
   m     verdi_duv                                                                              ## verdi for RTL

   m     verdi_vmnocomp                                                                         ## open verdi by kdb from vmcomp_path simv_test_pkg.daidir 
   m     verdi_vmnocomp_ff                                                                      ## open verdi by kdb from vmcomp_path simv_test_pkg_with_post_sim_on_ff_corner.daidir 
   m     verdi_vmnocomp_ss                                                                      ## open verdi by kdb from vmcomp_path simv_test_pkg_with_post_sim_on_ss_corner.daidir
   m     verdi_vmnocomp_tt                                                                      ## open verdi by kdb from vmcomp_path simv_test_pkg_with_post_sim_on_tt_corner.daidir
   m     verdi_vmnocomp   tc_xxx       define=USER_MACRO                                        ## open verdi by kdb from vmcomp_path simv_test_pkg_with_user_macro.daidir 

   m     vio                                                                                    ## collect timing violation in regression/result/
   m     vio                              TARGET_PATH                                           ## collect timing violation in TARGET_PATH

   m     cov                                                                                    ## analysis coverage after regression ,merge all merged_*.vdb and open verdi 
   m     cov_vmnocomp                                                                           ## analysis coverage after regression with vmnocomp
   m     vm                                                                                     ## open vManager with bsub, local mode
   m     vmcomplink                                                                             ## link simv and daidir file of brun_dir to vmcomp_path,use by vsif post_group_script
   m     vmsimclean                                                                             ## clean fail vdb file and success dir in regr process,use by post_run_script
   m     vdbmerge                                                                               ## merge regr current session all success case vdb , clean coverage and vmcomp_path all vdb dir and file

   m     clean                                                                                  ## delete useless files
   m     vsif                                                                                   ## gen vsif and testpkg from testcases
   m     init_all                                                                               ## call all tools
   m     init_docmake                                                                           ## call docmake: memmapgen & reggen
   m     init_duvcfg                                                                            ## call duvcfg
   m     init_genexti                                                                           ## call genexti cases
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------'''
        print(help_info)
