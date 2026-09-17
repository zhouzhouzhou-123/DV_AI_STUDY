#!/usr/bin/env python3

import os
import sys
import re
import linecache
import shutil
import random
import argparse
import time
import pathlib
import subprocess
import hashlib
import json
import fcntl

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../pubfunc")
postgroup_dir = os.path.abspath(cur_scr_dir + "/../../vm_regr_script")

sys.path.append(pubfunc_dir)
sys.path.append(postgroup_dir)

from pubfunc import PubFunc
from envcfg import EnvCfg
from cmdargs import CmdArgs
from postgroupscript import PostGroupScript
from vm_regr_clean_by_postrun import PostRunScript
from log_scanner import LogScanner

class CSRun:
    def __init__(self):
        self.env_cfg = EnvCfg()
        self.env_cfg.set_env()
        #print(self.env_cfg)

        # testcase run-time config info
        self.violation_report_file_name = 'vio.rpt'
        self.violation_report_file_handler = ''

    def parse_cmdargs(self, argv):
        self.cmd_args = CmdArgs(sys.argv, self.env_cfg)
        self.cmd_args.parse_cmdargs()
        #print(self.cmd_args)
        self.cmd_args.post_process()
        #print(self.cmd_args)

    def execute_command_on_shell(self, command_to_be_executed):
        command_to_be_executed = command_to_be_executed.replace('  ', ' ')
        print("execute command :")
        print(command_to_be_executed)
        os.system(command_to_be_executed)

    def analysis_coverage(self):
        coverage_database_path = "%s/coverage/coverage.vdb" % self.env_cfg.work_dir
        if not os.path.exists(coverage_database_path):
            PubFunc.exit_err("%s not exists!\n" % coverage_database_path)

        # delete useless soft link file
        file_list = os.listdir(coverage_database_path)
        for index in range(0, len(file_list)):
            file_path = os.path.join(coverage_database_path, file_list[index])
            if not os.path.exists(os.path.realpath(file_path)):
                os.remove(file_path)

        # gen merged and verdi read cov
        cur_time = time.strftime("%Y_%m_%d_%H_%M_%S", time.localtime(time.time()))
        merged_vdb = "%s/coverage/merged_%s.vdb" % (self.env_cfg.work_dir, cur_time)
        merged_log = "%s/coverage/merged_%s.log" % (self.env_cfg.work_dir, cur_time)
        coverage_analysis_command = ""
        coverage_analysis_command += "urg -dir %s/*.vdb -dbname %s >& %s;" % (coverage_database_path, merged_vdb, merged_log)
        self.execute_command_on_shell(coverage_analysis_command)

    def open_coverage_data_by_verdi(self,merged_vdb_str):
        open_coverage_data_command = ""
        open_coverage_data_command += "verdi -cov -covdir %s &" % merged_vdb_str
        self.execute_command_on_shell(open_coverage_data_command)

    def merge_vdb_remerge(self):
        merged_vdb_remerge_command = ""
        merged_database_path = "%s/coverage" % self.env_cfg.work_dir
        cur_time = time.strftime("%Y_%m_%d_%H_%M_%S", time.localtime(time.time()))        
        merged_vdb = "%s/coverage/merged_%s.vdb" % (self.env_cfg.work_dir, cur_time)
        merged_log = "%s/coverage/merged_%s.log" % (self.env_cfg.work_dir, cur_time)
        merged_vdb_remerge_command += "urg -dir %s/merge*.vdb -dbname %s >& %s;" % (merged_database_path, merged_vdb, merged_log)
        self.execute_command_on_shell(merged_vdb_remerge_command)
        return merged_vdb

    def merge_vdb_and_open(self):
        merged_vdb = ""
        self.analysis_coverage()
        merged_vdb = self.merge_vdb_remerge()
        self.open_coverage_data_by_verdi(merged_vdb)

    def check_sw_compile_error(self, log_file_path):
        log_file = open(log_file_path, "r")
        log_line = log_file.readline()
        while log_line:
            log_line = log_line.strip()
            searchError = re.search(r'error:', log_line)
            if searchError:
                self.gen_comp_log_file()
                print("********************* Log Files ****************************************")
                print("c_comp_log : %s" % log_file_path)
                print("************************************************************************")
                PubFunc.exit_err("C Compile Error!\n")
            log_line = log_file.readline()

    def execute_c_compile_command(self):
        if len(self.cmd_args.test_c_files_path) == 0:
            return True

        if self.cmd_args.is_xa:
            c_compile_command = "%s " % self.env_cfg.xa_bsub_args
        elif self.cmd_args.is_bsub:
            c_compile_command = "%s " % self.env_cfg.bsub_default_args
        else:
            c_compile_command = ""

        c_compile_command += "make -f ${WORK_DIR}/ccode/Makefile all "
        c_compile_command += "COMP_RSLT_DIR=%s " % self.cmd_args.comp_result_path
        c_compile_command += "TC_NAME=%s " % self.cmd_args.test_name
        c_compile_command += "TC_CSRC=%s " % self.cmd_args.test_c_files_path[0]
        c_compile_command += "CACHE_OPT=%s " % self.cmd_args.cache_opt
        c_compile_command += "BOOT_OPT=%s " % self.cmd_args.boot_opt
        if self.cmd_args.c_usr_macros != "":
            c_compile_command += "USR_MACROS=%s " % self.cmd_args.c_usr_macros
        c_compile_log_file_path = "%s/c_compile_%s.log" % (self.cmd_args.comp_result_path, os.path.basename(self.cmd_args.comp_test_name))
        c_compile_command += " 2>&1 | tee %s" % c_compile_log_file_path
        self.execute_command_on_shell(c_compile_command)
        self.check_sw_compile_error(c_compile_log_file_path)
        #print("testcases ccode args : %s" % self.cmd_args.__str__())
        #if self.execute_command_on_shell(c_compile_command) != 0:
        #    PubFunc.exit_err("c compile fail! %s" % c_compile_command)

    def execute_vhdlan_command(self):
        if self.cmd_args.is_xa:
            vhdlan_command = "%s vhdlan " % (self.env_cfg.xa_bsub_args)
        elif self.cmd_args.is_bsub:
            vhdlan_command = "%s vhdlan " % (self.env_cfg.bsub_default_args)
        else:
            vhdlan_command = "vhdlan "

        vhdlan_command += "%s " % self.env_cfg.vhdlan_default_comp_args

        vhdlan_command += "-f %s " % self.env_cfg.pre_sim_duv_vhdl_flist
        vhdlan_command += "-sva -sv_opts \"%s\" " % self.cmd_args.define_usr_macros
        vhdlan_command += "-l %s " % self.cmd_args.vhdlan_log_file_path

        self.execute_command_on_shell(vhdlan_command)

    # ------------------------------------------------------------------
    # split-library (distributed) compile support :
    #   RTL_LIB <- DUT filelist (shared across testcases, keyed by macros)
    #   TB_LIB  <- tb filelist + testcase (UVM env / VIP / testcase)
    # libraries live in <comp_result>/libs/<macros>/ so unchanged RTL is not
    # recompiled when only the testcase changes. synopsys_sim.setup is
    # generated per comp dir with the shared lib mappings appended.
    # ------------------------------------------------------------------
    def get_split_lib_dirs(self):
        lib_macros = self.cmd_args.str_usr_macros
        if len(lib_macros) == 0:
            lib_macros = "nomacro"
        lib_root = "%s/libs/%s" % (self.cmd_args.comp_result_path, lib_macros)
        rtl_lib_dir = "%s/rtl_lib" % lib_root
        tb_lib_dir = "%s/tb_lib" % lib_root
        if not os.path.exists(rtl_lib_dir):
            os.makedirs(rtl_lib_dir)
        if not os.path.exists(tb_lib_dir):
            os.makedirs(tb_lib_dir)
        return rtl_lib_dir, tb_lib_dir

    # ------------------------------------------------------------------
    # skip-if-unchanged support : a library (or the elaboration) is skipped
    # when a signature of ALL its inputs (vlogan args + defines + filelist
    # content + per-file mtime/size) is unchanged since the last successful
    # build. Set env M_FORCE_COMPILE=1 to force a rebuild.
    # ------------------------------------------------------------------
    def m_force_compile(self):
        return os.environ.get("M_FORCE_COMPILE", "0") == "1"

    def collect_flist_entries(self, flist_path, entry_list):
        flist_path = os.path.expandvars(flist_path)
        if not os.path.isfile(flist_path):
            print("[m][warn] sig: filelist not found (%s)" % flist_path)
            return
        with open(flist_path) as f:
            for line in f:
                line = line.strip()
                if len(line) == 0 or line.startswith("//") or line.startswith("#"):
                    continue
                if line.startswith("+incdir+"):
                    continue
                if line.startswith("-"):
                    parts = line.split()
                    if len(parts) >= 2 and parts[0] in ("-f", "-F"):
                        self.collect_flist_entries(parts[1], entry_list)
                    continue
                entry_list.append(os.path.expandvars(line))

    # recursively add a file and every `include target it references
    # (depth-capped) - required because filelist entries are usually
    # top-level .svh pack files whose real content lives in includes
    def collect_include_tree(self, path, tree, depth=0):
        path = os.path.expandvars(path)
        if not os.path.isabs(path):
            for base in (os.getcwd(), self.env_cfg.work_dir):
                cand = os.path.join(base, path)
                if os.path.isfile(cand):
                    path = cand
                    break
        if not os.path.isfile(path) or depth > 8:
            return
        real = os.path.realpath(path)
        if real in tree:
            return
        tree[real] = True
        try:
            with open(path) as f:
                content = f.read()
        except Exception:
            return
        import re as _re
        for m in _re.finditer(r'`include\s+[<"]([^">]+)[>"]', content):
            inc = m.group(1)
            if not os.path.isabs(inc):
                # try relative to the including file first, then cwd/work_dir
                cand = os.path.join(os.path.dirname(path), inc)
                if os.path.isfile(cand):
                    self.collect_include_tree(cand, tree, depth + 1)
                    continue
                cand2 = os.path.join(os.getcwd(), inc)
                if os.path.isfile(cand2):
                    self.collect_include_tree(cand2, tree, depth + 1)
                    continue
                self.collect_include_tree(inc, tree, depth + 1)
            else:
                self.collect_include_tree(inc, tree, depth + 1)

    def m_lib_signature(self, flist_path, extra_files):
        import hashlib
        h = hashlib.md5()
        # compile-affecting arguments (library independent parts only)
        h.update(self.env_cfg.vlogan_default_comp_args.encode())
        if self.cmd_args.is_dc or self.cmd_args.is_pr:
            h.update(str(self.env_cfg.vlogan_only_post_dc_comp_args).encode())
        elif self.cmd_args.is_post:
            h.update(str(self.env_cfg.vlogan_only_post_comp_args).encode())
        else:
            h.update(str(self.env_cfg.vlogan_only_pre_comp_args).encode())
        h.update(self.cmd_args.define_usr_macros.encode())
        # filelist content + every file it names (mtime+size), expanded
        # through the `include tree so header changes invalidate the lib
        entries = []
        self.collect_flist_entries(flist_path, entries)
        tree = {}
        for path in entries + extra_files:
            self.collect_include_tree(path, tree)
        for norm in sorted(tree.keys()):
            st = os.stat(norm)
            h.update(("%s:%d:%d\n" % (norm, st.st_mtime_ns, st.st_size)).encode())
        return h.hexdigest()

    def m_rtl_signature(self):
        flist = self.env_cfg.pre_sim_duv_flist
        if self.cmd_args.is_dc:
            flist = self.env_cfg.post_sim_dc_duv_flist
        elif self.cmd_args.is_pr:
            flist = self.env_cfg.post_sim_pr_duv_flist
        elif self.cmd_args.is_pg:
            flist = self.env_cfg.post_sim_pg_duv_flist
        elif self.cmd_args.is_post:
            flist = self.env_cfg.post_sim_duv_flist
        elif self.cmd_args.is_pa:
            flist = self.env_cfg.pa_sim_duv_flist
        extra_files = []
        if self.env_cfg.pre_sim_duv_vhdl_flist:
            extra_files.append(self.env_cfg.pre_sim_duv_vhdl_flist)
        for lib_path in self.env_cfg.vendor_ip_precompiled_libs.values():
            extra_files.append(lib_path)
        return self.m_lib_signature(flist, extra_files)

    def m_tb_signature(self):
        flist = self.env_cfg.tb_flist
        if self.cmd_args.is_xa:
            flist = self.env_cfg.tb_xa_flist
        elif (self.cmd_args.is_post or self.cmd_args.is_dc or self.cmd_args.is_pr or self.cmd_args.is_pg):
            flist = self.env_cfg.tb_post_flist
        return self.m_lib_signature(flist, [self.cmd_args.test_file_path])

    def m_lib_signature_file(self, lib_dir):
        return "%s/.m_lib_signature" % lib_dir

    def m_lib_up_to_date(self, lib_dir, signature):
        if self.m_force_compile():
            return False
        sig_file = self.m_lib_signature_file(lib_dir)
        if not os.path.isfile(sig_file):
            return False
        with open(sig_file) as f:
            return f.read().strip() == signature

    def m_write_lib_signature(self, lib_dir, signature):
        with open(self.m_lib_signature_file(lib_dir), 'w') as f:
            f.write(signature)

    # elaboration skip : same libs + same vcs command + simv present
    def m_elab_signature(self, vcs_command, rtl_sig, tb_sig):
        import hashlib
        h = hashlib.md5()
        h.update(vcs_command.encode())
        h.update(rtl_sig.encode())
        h.update(tb_sig.encode())
        return h.hexdigest()

    def m_elab_up_to_date(self, elab_sig):
        if self.m_force_compile():
            return False
        sig_file = "%s/.m_elab_sig_%s" % (self.cmd_args.comp_result_path, self.cmd_args.comp_test_name)
        if not os.path.isfile(sig_file):
            return False
        if not os.path.isfile(self.cmd_args.simv_file_path):
            return False
        with open(sig_file) as f:
            return f.read().strip() == elab_sig

    def m_write_elab_signature(self, elab_sig):
        sig_file = "%s/.m_elab_sig_%s" % (self.cmd_args.comp_result_path, self.cmd_args.comp_test_name)
        with open(sig_file, 'w') as f:
            f.write(elab_sig)

    def setup_split_synopsys_sim_setup(self):
        setup_file_path = "%s/synopsys_sim.setup" % self.cmd_args.comp_result_path
        rtl_lib_dir, tb_lib_dir = self.get_split_lib_dirs()
        # rebuild from scratch every run : WORK/DEFAULT base + the two
        # shared-library mappings for THIS macro signature (avoids stale
        # and duplicated entries from previous invocations)
        with open(setup_file_path, 'w') as f:
            f.write("WORK > DEFAULT\n")
            f.write("DEFAULT: %s\n" % self.cmd_args.comp_result_path)
            f.write("RTL_LIB : %s\n" % os.path.abspath(rtl_lib_dir))
            f.write("TB_LIB : %s\n" % os.path.abspath(tb_lib_dir))
        os.environ["SYNOPSYS_SIM_SETUP"] = setup_file_path

    def build_vlogan_head(self):
        if self.cmd_args.is_xa:
            vlogan_command = "%s vlogan " % (self.env_cfg.xa_bsub_args)
        elif self.cmd_args.is_bsub:
            vlogan_command = "%s vlogan " % (self.env_cfg.bsub_default_args)
        else:
            vlogan_command = "vlogan "

        vlogan_command += "%s " % self.env_cfg.vlogan_default_comp_args

        if self.cmd_args.is_dc or self.cmd_args.is_pr:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_post_dc_comp_args
        elif self.cmd_args.is_post:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_post_comp_args
        else:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_pre_comp_args

        if self.cmd_args.is_post:
            vlogan_command += "+neg_tchk -negdelay +sdfverbose "
            vlogan_command += "+optconfigfile+%s/cfg/notimingcheck.cfg " % self.env_cfg.work_dir

        vlogan_command += "-Mdir=%s " % self.cmd_args.comp_result_path
        vlogan_command += "%s " % self.cmd_args.define_usr_macros
        return vlogan_command

    def build_vlogan_dut_flist(self, vlogan_command):
        if self.cmd_args.is_dc:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_dc_duv_flist
        elif self.cmd_args.is_pr:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_pr_duv_flist
        elif self.cmd_args.is_pg:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_pg_duv_flist
        elif self.cmd_args.is_post:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_duv_flist
        elif self.cmd_args.is_pa:
            vlogan_command += "-F %s " % self.env_cfg.pa_sim_duv_flist
        else:
            vlogan_command += "-F %s " % self.env_cfg.pre_sim_duv_flist
        return vlogan_command

    def build_vlogan_tb_flist(self, vlogan_command):
        if self.cmd_args.is_xa:
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_xa_flist, self.cmd_args.test_file_path)
        elif (self.cmd_args.is_post or self.cmd_args.is_dc or self.cmd_args.is_pr  or self.cmd_args.is_pg):
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_post_flist, self.cmd_args.test_file_path)
        else:
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_flist, self.cmd_args.test_file_path)
        return vlogan_command

    def execute_vlogan_split_command(self):
        # ensure synopsys_sim.setup carries RTL_LIB/TB_LIB mappings BEFORE
        # any -work compile runs
        self.setup_split_synopsys_sim_setup()
        rtl_lib_dir, tb_lib_dir = self.get_split_lib_dirs()

        rtl_sig = self.m_rtl_signature()
        tb_sig = self.m_tb_signature()
        rtl_skip = self.m_lib_up_to_date(rtl_lib_dir, rtl_sig)
        tb_skip = self.m_lib_up_to_date(tb_lib_dir, tb_sig)

        rtl_command = ""
        tb_command = ""
        if not rtl_skip:
            rtl_command = self.build_vlogan_head()
            rtl_command = rtl_command.replace("${UVM_HOME}/src/uvm_pkg.sv ", "")
            rtl_command += "-work RTL_LIB "
            rtl_command = self.build_vlogan_dut_flist(rtl_command)
            rtl_command += "-l %s " % self.cmd_args.vlogan_rtl_log_file_path

        if not tb_skip:
            tb_command = self.build_vlogan_head()
            tb_command += "-work TB_LIB "
            tb_command = self.build_vlogan_tb_flist(tb_command)
            tb_command += "-l %s " % self.cmd_args.vlogan_tb_log_file_path

        if rtl_skip and tb_skip:
            print("[m] RTL_LIB and TB_LIB up-to-date, skip vlogan (M_FORCE_COMPILE=1 to force)")
            self.cmd_args.m_split_rtl_skipped = True
            self.cmd_args.m_split_tb_skipped = True
            return True

        # distributed : the pending vlogan jobs run in PARALLEL
        rtl_process = None
        tb_process = None
        if not rtl_skip:
            print("run command (parallel rtl) : %s " % rtl_command)
            rtl_process = subprocess.Popen(rtl_command, shell=True)
        else:
            print("[m] RTL_LIB up-to-date, skip rtl vlogan")
            self.cmd_args.m_split_rtl_skipped = True
        if not tb_skip:
            print("run command (parallel tb)  : %s " % tb_command)
            tb_process = subprocess.Popen(tb_command, shell=True)
        else:
            print("[m] TB_LIB up-to-date, skip tb vlogan")
            self.cmd_args.m_split_tb_skipped = True

        rtl_rc = 0 if rtl_process is None else rtl_process.wait()
        tb_rc = 0 if tb_process is None else tb_process.wait()
        if rtl_rc != 0 or tb_rc != 0:
            print("vlogan parallel rc : rtl=%s tb=%s" % (rtl_rc, tb_rc))
            return False
        if not rtl_skip:
            self.m_write_lib_signature(rtl_lib_dir, rtl_sig)
        if not tb_skip:
            self.m_write_lib_signature(tb_lib_dir, tb_sig)
        return True

    def execute_vlogan_dut_only_command(self):
        self.setup_split_synopsys_sim_setup()
        rtl_command = self.build_vlogan_head()
        rtl_command = rtl_command.replace("${UVM_HOME}/src/uvm_pkg.sv ", "")
        rtl_command += "-work RTL_LIB "
        rtl_command = self.build_vlogan_dut_flist(rtl_command)
        rtl_command += "-l %s " % self.cmd_args.vlogan_rtl_log_file_path
        self.execute_command_on_shell(rtl_command)

    def execute_vlogan_tb_only_command(self):
        self.setup_split_synopsys_sim_setup()
        tb_command = self.build_vlogan_head()
        tb_command += "-work TB_LIB "
        tb_command = self.build_vlogan_tb_flist(tb_command)
        tb_command += "-l %s " % self.cmd_args.vlogan_tb_log_file_path
        self.execute_command_on_shell(tb_command)

    def execute_vlogan_command(self):
        if self.cmd_args.is_xa:
            vlogan_command = "%s vlogan " % (self.env_cfg.xa_bsub_args)
        elif self.cmd_args.is_bsub:
            vlogan_command = "%s vlogan " % (self.env_cfg.bsub_default_args)
        else:
            vlogan_command = "vlogan "
        
        vlogan_command += "%s " % self.env_cfg.vlogan_default_comp_args

        if self.cmd_args.is_dc or self.cmd_args.is_pr:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_post_dc_comp_args
        elif self.cmd_args.is_post:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_post_comp_args
        else:
            vlogan_command += "%s " % self.env_cfg.vlogan_only_pre_comp_args

        #--- is_pa ---
        #if self.cmd_args.is_pa:
        #    vlogan_command += "-upf %s -power=force_priority " % self.env_cfg.upf_file_path

        if self.cmd_args.is_post:
            vlogan_command += "+neg_tchk -negdelay +sdfverbose "
            vlogan_command += "+optconfigfile+%s/cfg/notimingcheck.cfg " % self.env_cfg.work_dir
       
        vlogan_command += "-Mdir=%s " % self.cmd_args.comp_result_path
        vlogan_command += "%s " % self.cmd_args.define_usr_macros
        
        # analysis uvm before analysis flist
        self.execute_command_on_shell(vlogan_command)

        if self.cmd_args.is_dc:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_dc_duv_flist
        elif self.cmd_args.is_pr:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_pr_duv_flist
        elif self.cmd_args.is_pg:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_pg_duv_flist
        elif self.cmd_args.is_post:
            vlogan_command += "-F %s " % self.env_cfg.post_sim_duv_flist
        elif self.cmd_args.is_pa:
            vlogan_command += "-F %s " % self.env_cfg.pa_sim_duv_flist
        else:
            vlogan_command += "-F %s " % self.env_cfg.pre_sim_duv_flist
        
        if self.cmd_args.is_xa:
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_xa_flist, self.cmd_args.test_file_path)
        elif (self.cmd_args.is_post or self.cmd_args.is_dc or self.cmd_args.is_pr  or self.cmd_args.is_pg):
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_post_flist, self.cmd_args.test_file_path)
        else:
            vlogan_command += " -F %s %s " % (self.env_cfg.tb_flist, self.cmd_args.test_file_path)
        
        vlogan_command += "-l %s " % self.cmd_args.vlogan_log_file_path
        self.execute_command_on_shell(vlogan_command)

    def set_coverage_args(self):
        self.coverage_args = ""
        self.coverage_args += " %s " % self.env_cfg.cov_default_args
        if  self.cmd_args.is_pkg:
            self.coverage_args += " -cm_dir %s/%s " % (self.cmd_args.vmcomp_dir_path, self.cmd_args.comp_test_name)
        else:
            self.coverage_args += " -cm_dir %s/%s " % (self.cmd_args.sim_dir, self.cmd_args.sim_test_name)
    
    def execute_vcs_compile_command(self):
        if self.env_cfg.split_lib:
            # elaboration skip : identical libs + identical vcs command and
            # the simv binary still present -> nothing to do
            dry_command = self.build_vcs_compile_command(dry_run=True)
            elab_sig = self.m_elab_signature(dry_command, self.m_rtl_signature(), self.m_tb_signature())
            if self.m_elab_up_to_date(elab_sig):
                print("[m] elaboration up-to-date, skip vcs (M_FORCE_COMPILE=1 to force)")
                return True
            self.execute_command_on_shell(self.build_vcs_compile_command())
            self.m_write_elab_signature(elab_sig)
            return True
        self.execute_command_on_shell(self.build_vcs_compile_command())
        return True

    def build_vcs_compile_command(self, dry_run=False):
        if self.cmd_args.is_xa:
            vcs_compile_command = "%s vcs " % (self.env_cfg.xa_bsub_args)
        elif self.cmd_args.is_bsub:
            vcs_compile_command = "%s vcs " % (self.env_cfg.bsub_default_args)
        else:
            vcs_compile_command = "vcs "

        vcs_compile_command += "%s " % self.env_cfg.vcs_default_comp_args
        
        if self.cmd_args.is_post:
            vcs_compile_command += "%s " % self.env_cfg.vcs_only_post_comp_args
        else:
            vcs_compile_command += "%s " % self.env_cfg.vcs_only_pre_comp_args

        if self.cmd_args.is_xprop:
            vcs_compile_command += "-xprop=%s/cfg/xprop.cfg " % self.env_cfg.work_dir

        #--- is_pa ---
        if self.cmd_args.is_pa:
            vcs_compile_command += "%s " %self.env_cfg.vcs_pa_comp_args
            vcs_compile_command += "-upf %s -power=force_priority " % self.env_cfg.upf_file_path

        vcs_compile_command += "-o %s " % self.cmd_args.simv_file_path
        
        if self.cmd_args.is_post:
            vcs_compile_command += "+neg_tchk -negdelay +sdfverbose "
            vcs_compile_command += "+optconfigfile+%s/cfg/notimingcheck.cfg " % self.env_cfg.work_dir

        if self.cmd_args.is_cov:
            self.set_coverage_args()
            vcs_compile_command += "%s " % self.coverage_args
            if self.env_cfg.has_cm_hier_cfg:
                vcs_compile_command += "-cm_hier %s " % self.env_cfg.cm_hier_cfg_path

        vcs_compile_command += "-top %s " % self.env_cfg.tb_top
        vcs_compile_command += "-l %s " % self.cmd_args.elab_log_file_path
        if self.cmd_args.is_incr_run:
            tb_pkg_dir = "%s/tb_pkg" % self.cmd_args.comp_result_path
            vcs_compile_command += "-Mdir=%s " % tb_pkg_dir
        else:
            vcs_compile_command += "-Mdir=%s " % self.cmd_args.comp_result_path


        if self.cmd_args.is_xa:
            #vcs_compile_command += " -Mdir=" + self.cmd_args.sim_result_path + " "            
            vcs_compile_command += "-ad=%s " % self.cmd_args.xa_init_file_path
            os.environ["SPICE_NAME"] = self.cmd_args.xa_spice_file_path
            os.environ["CFG_NAME"] = self.cmd_args.xa_cfg_file_path
            os.environ["LOG_NAME"] = "%s/xa_%s" % (self.cmd_args.log_dir_path, self.cmd_args.sim_test_name)

        if not dry_run:
            self.execute_command_on_shell(vcs_compile_command)
        return vcs_compile_command
    
    def check_hw_compile_error(self, log_file_path):
        log_file = open(log_file_path, "r")
        log_line = log_file.readline()
        while log_line:
            log_line = log_line.strip()
            matchError = re.match(r'Error-\[\w+\]', log_line)
            if matchError:
                self.gen_comp_log_file()
                print("********************* Log Files ****************************************")
                print("comp_log : %s" % self.cmd_args.comp_log_file_path)
                print("************************************************************************")
                PubFunc.exit_err("VCS Compile Error!\n")
            log_line = log_file.readline()


    def gen_comp_log_file(self):
        gen_comp_log_file_command = "cat "
        if os.path.isfile(self.cmd_args.vhdlan_log_file_path):
            gen_comp_log_file_command += "%s " % self.cmd_args.vhdlan_log_file_path
        if os.path.isfile(self.cmd_args.vlogan_rtl_log_file_path):
            gen_comp_log_file_command += "%s " % self.cmd_args.vlogan_rtl_log_file_path
        if os.path.isfile(self.cmd_args.vlogan_tb_log_file_path):
            gen_comp_log_file_command += "%s " % self.cmd_args.vlogan_tb_log_file_path
        if os.path.isfile(self.cmd_args.vlogan_log_file_path):
            gen_comp_log_file_command += "%s " % self.cmd_args.vlogan_log_file_path
        if os.path.isfile(self.cmd_args.elab_log_file_path):
            gen_comp_log_file_command += "%s " % self.cmd_args.elab_log_file_path
        gen_comp_log_file_command += "> %s" % self.cmd_args.comp_log_file_path
        self.execute_command_on_shell(gen_comp_log_file_command)

    def execute_compile_command(self):
        if self.cmd_args.is_vhdl_comp:
            self.execute_vhdlan_command()
            self.check_hw_compile_error(self.cmd_args.vhdlan_log_file_path)
        if self.env_cfg.split_lib:
            # split-library (distributed) : RTL_LIB + TB_LIB in parallel;
            # log files only exist for libraries that actually recompiled
            vlogan_ok = self.execute_vlogan_split_command()
            if vlogan_ok:
                if os.path.isfile(self.cmd_args.vlogan_rtl_log_file_path):
                    self.check_hw_compile_error(self.cmd_args.vlogan_rtl_log_file_path)
                if os.path.isfile(self.cmd_args.vlogan_tb_log_file_path):
                    self.check_hw_compile_error(self.cmd_args.vlogan_tb_log_file_path)
            else:
                if os.path.isfile(self.cmd_args.vlogan_rtl_log_file_path):
                    self.check_hw_compile_error(self.cmd_args.vlogan_rtl_log_file_path)
                if os.path.isfile(self.cmd_args.vlogan_tb_log_file_path):
                    self.check_hw_compile_error(self.cmd_args.vlogan_tb_log_file_path)
                PubFunc.exit_err("vlogan compile failed (see parallel logs)")
        else:
            self.execute_vlogan_command()
            self.check_hw_compile_error(self.cmd_args.vlogan_log_file_path)
        self.execute_vcs_compile_command()
        self.check_hw_compile_error(self.cmd_args.elab_log_file_path)
        self.gen_comp_log_file()

    # compile ONLY the shared RTL library : reused by every testcase built
    # with the same macros (incremental vlogan -work)
    def execute_compile_rtl_command(self):
        self.setup_split_synopsys_sim_setup()
        self.execute_vlogan_dut_only_command()
        self.check_hw_compile_error(self.cmd_args.vlogan_rtl_log_file_path)
        print("********************* Log Files ****************************************")
        print("vlogan_rtl_log : %s" % (self.cmd_args.vlogan_rtl_log_file_path))
        print("************************************************************************")

    # compile ONLY the TB library + testcase (RTL_LIB must exist once)
    def execute_compile_tb_command(self):
        self.setup_split_synopsys_sim_setup()
        self.execute_vlogan_tb_only_command()
        self.check_hw_compile_error(self.cmd_args.vlogan_tb_log_file_path)
        print("********************* Log Files ****************************************")
        print("vlogan_tb_log  : %s" % (self.cmd_args.vlogan_tb_log_file_path))
        print("************************************************************************")

    # ==================================================================
    # Incremental compile (incr_run) support
    # RTL compiled to rtl_pkg_shared/ (shared across all testcases),
    # TB compiled to tb_pkg/ (per-testcase, no concurrent conflict).
    # File locking (fcntl.flock) protects shared rtl_pkg from race conditions.
    # ==================================================================
    def get_shared_rtl_pkg_dir(self):
        # comp_result_path is $SIM_DIR/comp_result/$sim_type/comp_$test_name
        # shared rtl_pkg should be at $SIM_DIR/comp_result/$sim_type/rtl_pkg_shared
        return "%s/rtl_pkg_shared" % os.path.dirname(os.path.dirname(self.cmd_args.comp_result_path))

    def lock_rtl_pkg(self, lock_file_path):
        lock_file = open(lock_file_path, 'w')
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        return lock_file

    def unlock_rtl_pkg(self, lock_file):
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)
        lock_file.close()

    def setup_incremental_paths(self):
        self.rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        self.tb_pkg_dir = "%s/tb_pkg" % self.cmd_args.comp_result_path
        if not os.path.exists(self.rtl_pkg_dir):
            os.makedirs(self.rtl_pkg_dir)
        if not os.path.exists(self.tb_pkg_dir):
            os.makedirs(self.tb_pkg_dir)

    def setup_incremental_synopsys_sim_setup(self):
        setup_file_path = "%s/synopsys_sim.setup" % self.cmd_args.comp_result_path
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        tb_pkg_dir = self.tb_pkg_dir
        with open(setup_file_path, 'w') as f:
            f.write("WORK > DEFAULT\n")
            f.write("DEFAULT: %s\n" % self.cmd_args.comp_result_path)
            f.write("RTL_LIB : %s\n" % os.path.abspath(rtl_pkg_dir))
            f.write("TB_LIB : %s\n" % os.path.abspath(tb_pkg_dir))
            for lib_name in self.env_cfg.vendor_ip_precompiled_libs.keys():
                lib_path = os.path.join(rtl_pkg_dir, lib_name)
                f.write("%s : %s\n" % (lib_name, os.path.abspath(lib_path)))
        os.environ["SYNOPSYS_SIM_SETUP"] = setup_file_path

    def check_rtl_modified_incr(self):
        rtl_sig = self.m_rtl_signature()
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        lock_file_path = os.path.join(rtl_pkg_dir, '.rtl_lock')
        lock_file = self.lock_rtl_pkg(lock_file_path)
        try:
            if self.m_lib_up_to_date(rtl_pkg_dir, rtl_sig):
                print("[INCR] RTL files unchanged")
                return False
            print("[INCR] RTL files modified, need recompile RTL")
            return True
        finally:
            self.unlock_rtl_pkg(lock_file)

    def check_tb_modified_incr(self):
        tb_sig = self.m_tb_signature()
        tb_pkg_dir = self.tb_pkg_dir
        if self.m_lib_up_to_date(tb_pkg_dir, tb_sig):
            print("[INCR] TB files unchanged")
            return False
        print("[INCR] TB files modified, need recompile TB")
        return True

    def execute_vlogan_rtl_incr_command(self):
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        rtl_command = self.build_vlogan_head()
        rtl_command = rtl_command.replace("${UVM_HOME}/src/uvm_pkg.sv ", "")
        rtl_command = re.sub(r'-Mdir=\S+\s*', '', rtl_command)
        rtl_command += "-work RTL_LIB "
        rtl_command = self.build_vlogan_dut_flist(rtl_command)
        rtl_command += "-l %s " % self.cmd_args.vlogan_rtl_log_file_path
        print("[INCR] Step 2/3: Compiling Verilog RTL to shared dir: %s" % rtl_pkg_dir)
        ret = self.execute_command_on_shell_with_return(rtl_command)
        if ret != 0:
            print("[INCR] RTL compilation failed, removing rtl_pkg_shared directory...")
            shutil.rmtree(rtl_pkg_dir, ignore_errors=True)
            return False
        rtl_sig = self.m_rtl_signature()
        self.m_write_lib_signature(rtl_pkg_dir, rtl_sig)
        return True

    def execute_vhdlan_rtl_incr_command(self):
        if not self.env_cfg.pre_sim_duv_vhdl_flist:
            return True
        if not os.path.isfile(self.env_cfg.pre_sim_duv_vhdl_flist):
            print("[INCR] VHDL filelist not found, skipping VHDL compilation")
            return True
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        if self.cmd_args.is_xa:
            vhdlan_command = "%s vhdlan " % (self.env_cfg.xa_bsub_args)
        elif self.cmd_args.is_bsub:
            vhdlan_command = "%s vhdlan " % (self.env_cfg.bsub_default_args)
        else:
            vhdlan_command = "vhdlan "
        vhdlan_command += "%s " % self.env_cfg.vhdlan_default_comp_args
        vhdlan_command += "-work RTL_LIB "
        vhdlan_command += "-f %s " % self.env_cfg.pre_sim_duv_vhdl_flist
        vhdlan_command += "-l %s " % (self.cmd_args.comp_result_path + "vhdlan_rtl_incr.log")
        print("[INCR] Step 1/3: Compiling VHDL RTL to shared dir: %s" % rtl_pkg_dir)
        ret = self.execute_command_on_shell_with_return(vhdlan_command)
        if ret != 0:
            print("[INCR] VHDL RTL compilation failed, removing rtl_pkg_shared directory...")
            shutil.rmtree(rtl_pkg_dir, ignore_errors=True)
            return False
        return True

    def copy_precompiled_libs(self):
        if not self.env_cfg.vendor_ip_precompiled_libs:
            return True
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        if not os.path.exists(rtl_pkg_dir):
            os.makedirs(rtl_pkg_dir)
        for lib_name, lib_path in self.env_cfg.vendor_ip_precompiled_libs.items():
            dest_path = os.path.join(rtl_pkg_dir, lib_name)
            if os.path.exists(lib_path):
                if os.path.exists(dest_path):
                    shutil.rmtree(dest_path)
                shutil.copytree(lib_path, dest_path)
                print("[INCR] Copied precompiled lib: %s -> %s" % (lib_name, dest_path))
            else:
                print("[INCR] Warning: precompiled lib not found: %s" % lib_path)
                return False
        return True

    def get_uvm_pkg_path(self):
        for arg in self.env_cfg.vlogan_default_comp_args.split():
            if 'uvm_pkg.sv' in arg:
                path = os.path.expandvars(arg)
                if os.path.isfile(path):
                    return path
        uvm_home = os.environ.get('UVM_HOME', '')
        if uvm_home:
            path = os.path.join(uvm_home, 'src', 'uvm_pkg.sv')
            if os.path.isfile(path):
                return path
        return ''

    def execute_vlogan_tb_incr_command(self):
        tb_pkg_dir = self.tb_pkg_dir
        tb_command = self.build_vlogan_head()
        tb_command = re.sub(r'-Mdir=\S+\s*', '', tb_command)
        tb_command += "-work TB_LIB "
        if 'uvm_pkg.sv' not in tb_command:
            uvm_pkg_path = self.get_uvm_pkg_path()
            if uvm_pkg_path:
                tb_command += "%s " % uvm_pkg_path
        tb_command = self.build_vlogan_tb_flist(tb_command)
        tb_command += "-l %s " % self.cmd_args.vlogan_tb_log_file_path
        print("[INCR] Step 3/3: Compiling TB package...")
        ret = self.execute_command_on_shell_with_return(tb_command)
        if ret != 0:
            print("[INCR] TB compilation failed, removing tb_pkg directory...")
            shutil.rmtree(tb_pkg_dir, ignore_errors=True)
            return False
        tb_sig = self.m_tb_signature()
        self.m_write_lib_signature(tb_pkg_dir, tb_sig)
        return True

    def clear_all_tb_packages_incr(self):
        # comp_result_path is $SIM_DIR/comp_result/$sim_type/comp_$test_name
        # parent is $SIM_DIR/comp_result/$sim_type, which contains all comp_* directories
        comp_base_dir = os.path.dirname(self.cmd_args.comp_result_path)
        if not os.path.exists(comp_base_dir):
            return
        for item in os.listdir(comp_base_dir):
            item_path = os.path.join(comp_base_dir, item)
            if os.path.isdir(item_path) and item.startswith('comp_'):
                tb_pkg_path = os.path.join(item_path, 'tb_pkg')
                if os.path.exists(tb_pkg_path):
                    shutil.rmtree(tb_pkg_path)
                    print("[INCR] Cleared TB package: %s" % tb_pkg_path)

    def execute_incremental_compile_command(self):
        self.setup_incremental_paths()
        self.setup_incremental_synopsys_sim_setup()
        rtl_changed = self.check_rtl_modified_incr()
        tb_changed = self.check_tb_modified_incr()
        rtl_pkg_dir = self.get_shared_rtl_pkg_dir()
        tb_pkg_dir = self.tb_pkg_dir
        rtl_pkg_exists = os.path.exists(rtl_pkg_dir) and len(os.listdir(rtl_pkg_dir)) > 0
        tb_pkg_exists = os.path.exists(tb_pkg_dir) and len(os.listdir(tb_pkg_dir)) > 0
        need_full_compile = False
        rtl_compiled = False
        tb_compiled = False
        if not rtl_pkg_exists or not tb_pkg_exists:
            need_full_compile = True
            print("[INCR] Package not found, doing full compile...")
        if rtl_changed:
            print("[INCR] RTL modified, clearing all TB packages for full recompile...")
            self.clear_all_tb_packages_incr()
            need_full_compile = True
        if need_full_compile:
            rtl_lock_file = None
            try:
                rtl_lock_file = self.lock_rtl_pkg(os.path.join(rtl_pkg_dir, '.rtl_lock'))
                if not self.execute_vhdlan_rtl_incr_command():
                    PubFunc.exit_err("[INCR] VHDL RTL compilation failed, please check errors")
                if not self.copy_precompiled_libs():
                    PubFunc.exit_err("[INCR] Precompiled libs copy failed, please check errors")
                if not self.execute_vlogan_rtl_incr_command():
                    PubFunc.exit_err("[INCR] Verilog RTL compilation failed, please check errors")
            finally:
                if rtl_lock_file:
                    self.unlock_rtl_pkg(rtl_lock_file)
            rtl_compiled = True
            if not self.execute_vlogan_tb_incr_command():
                PubFunc.exit_err("[INCR] TB compilation failed, please check errors")
            tb_compiled = True
        else:
            if tb_changed:
                if not self.execute_vlogan_tb_incr_command():
                    PubFunc.exit_err("[INCR] TB compilation failed, please check errors")
                tb_compiled = True
            else:
                print("[INCR] No files modified, skip vlogan compile")
        self.execute_vcs_compile_command()
        self.check_hw_compile_error_with_cleanup(self.cmd_args.elab_log_file_path, tb_pkg_dir)
        self.gen_incr_comp_log_file(rtl_compiled, tb_compiled)
        return True

    def gen_incr_comp_log_file(self, rtl_compiled, tb_compiled):
        log_files = []
        vhdl_log = "%svhdlan_rtl_incr.log" % self.cmd_args.comp_result_path
        if rtl_compiled:
            if os.path.isfile(vhdl_log):
                log_files.append(vhdl_log)
            if os.path.isfile(self.cmd_args.vlogan_rtl_log_file_path):
                log_files.append(self.cmd_args.vlogan_rtl_log_file_path)
        if tb_compiled:
            if os.path.isfile(self.cmd_args.vlogan_tb_log_file_path):
                log_files.append(self.cmd_args.vlogan_tb_log_file_path)
        if os.path.isfile(self.cmd_args.elab_log_file_path):
            log_files.append(self.cmd_args.elab_log_file_path)
        with open(self.cmd_args.comp_log_file_path, 'w') as out:
            out.write("=" * 80 + "\n")
            out.write("  Incremental Compile Log\n")
            out.write("  RTL compiled: %s | TB compiled: %s\n" % (rtl_compiled, tb_compiled))
            out.write("=" * 80 + "\n\n")
            for lf in log_files:
                out.write("--- %s ---\n" % os.path.basename(lf))
                with open(lf, 'r') as f:
                    out.write(f.read())
                out.write("\n")

    def execute_command_on_shell_with_return(self, command):
        command = command.replace('  ', ' ')
        print("execute command :")
        print(command)
        result = subprocess.run(command, shell=True)
        return result.returncode

    def check_hw_compile_error_with_cleanup(self, log_file_path, cleanup_dir=None):
        if not os.path.exists(log_file_path):
            return
        with open(log_file_path, 'r') as f:
            log_content = f.read()
        if 'Error-[' in log_content:
            if cleanup_dir and os.path.exists(cleanup_dir):
                print("[INCR] Elaboration failed, removing tb_pkg for next full compile...")
                shutil.rmtree(cleanup_dir, ignore_errors=True)
            self.gen_comp_log_file()
            print("********************* Log Files ****************************************")
            print("comp_log : %s" % self.cmd_args.comp_log_file_path)
            print("************************************************************************")
            PubFunc.exit_err("VCS Compile Error!\n")

    def execute_simulation_command(self):
        if self.cmd_args.is_xa:
            vcs_sim_command = "%s " % self.env_cfg.xa_bsub_args
        elif self.cmd_args.is_bsub:
            vcs_sim_command = "%s " % self.env_cfg.bsub_default_args
        else:
            vcs_sim_command = ""

        vcs_sim_command += "%s " % self.cmd_args.simv_file_path
        vcs_sim_command += "%s " % self.env_cfg.vcs_default_sim_args
        vcs_sim_command += "+ntb_random_seed=%d " % self.cmd_args.rand_seed
        vcs_sim_command += "+UVM_TESTNAME=%s " % self.cmd_args.test_name
        #add plusargs 
        vcs_sim_command += "%s " % self.cmd_args.add_usr_plusargs

        vcs_sim_command += "-l %s " % self.cmd_args.sim_log_file_path


        if self.cmd_args.is_cov:
            self.coverage_args = ""
            self.coverage_args += " %s " % self.env_cfg.cov_default_args
            vcs_sim_command += "%s " % self.coverage_args
            vcs_sim_command += "-cm_name %s.vdb " % self.cmd_args.sim_test_name
            #coverage_name = self.cmd_args.sim_test_name
            #vcs_sim_command += " -cm line+cond+fsm+tgl+branch+assert "
            #vcs_sim_command += " -cm_dir " + os.path.join(self.cmd_args.coverage_result_path, coverage_name) + " "
            #vcs_sim_command += " -cm_name " + coverage_name + " "

        if self.cmd_args.is_xprop:
            vcs_sim_command += "-xprop=%s/cfg/xprop.cfg " % self.env_cfg.work_dir

        if len(self.cmd_args.test_c_files_path) > 0:
            vcs_sim_command += "+HEXFILE_PROC0=%s.hex " % self.cmd_args.test_name

        if "VCD_DUMP_ON" in self.cmd_args.usr_macros:
            vcs_sim_command += "+plusargs_save +vcd_file=%s " % self.cmd_args.sim_wave_file_path
        else:
            vcs_sim_command += "+plusargs_save +fsdb_file=%s " % self.cmd_args.sim_wave_file_path
        if not ("FSDB_DUMP_OFF" in self.cmd_args.usr_macros):
            if(self.env_cfg.vericom_use_wave_do):
                vcs_sim_command += " -ucli -i %s/scripts/wave.do " % self.env_cfg.work_dir
        vcs_sim_command += "%s " % self.cmd_args.define_usr_macros

        #vcs_sim_command += "+LOG_PATH=%s " % self.cmd_args.sim_log_file_path

        if self.cmd_args.is_pa:
            #vcs_sim_command += "%s " % self.env_cfg.vcs_pa_comp_args                        
            vcs_sim_command += "-power %s " % self.env_cfg.upf_cfg_path
        if self.cmd_args.is_vmnocomp:
            if self.cmd_args.is_vmnocomp_fsdb_dump:
                vcs_sim_command += " -ucli -i %s " % self.env_cfg.vmnocomp_fsdb_dump_tcl_path

        self.execute_command_on_shell(vcs_sim_command)
        self.execute_command_on_shell('rm -rf csrc simv* ucli.key vc_hdrs.h novas_dump.log')
        if not self.cmd_args.is_regr :
            self.log_scanner_error()

        print("********************* Log Files ****************************************")
        print("comp_log : %s" % self.cmd_args.comp_log_file_path)
        print("error_det_log  : %s" % self.cmd_args.sim_error_log_file_path)        
        print("sim_log  : %s" % self.cmd_args.sim_log_file_path)
        print("************************************************************************")

    def log_scanner_error(self):
        log_scanner         =   LogScanner(config_path = self.env_cfg.env_cfg_path)
        log_errors          =   log_scanner.scan_file(self.cmd_args.sim_log_file_path,self.cmd_args.sim_error_log_file_path)
        log_scanner.print_results(log_errors)

    def open_verdi_by_compile(self, owner_match):
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
        
        work_suffix = ""
        if self.cmd_args.is_dc:
            work_suffix += "_dc"
        if self.cmd_args.is_pr:
            work_suffix += "_pr"
        if self.cmd_args.is_pg:
            work_suffix += "_pg"
        if self.cmd_args.is_post:
            work_suffix += "_post"
        if self.cmd_args.is_pa:
            work_suffix += "_pa"
        if self.cmd_args.is_xa:
            work_suffix += "_xa"

        if owner_match:
            # ====== vhdlcom_command ======
            if self.cmd_args.is_vhdl_comp:
                vhdlcom_command = verdi_command_prefix + "vhdlcom "
                vhdlcom_command += "-nc -f %s " % self.env_cfg.pre_sim_duv_vhdl_flist
                vhdlcom_command += "%s " % self.cmd_args.define_usr_macros
                vhdlcom_command += "-logdir %s/vhdlcomLog%s " % (self.cmd_args.comp_result_path, work_suffix)
                vhdlcom_command += "-work %s/%s%s " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)

                self.execute_command_on_shell(vhdlcom_command)
            
            # ====== vericom_command ======
            vericom_command = verdi_command_prefix +  "vericom "
            vericom_command += "-sv -ssv -ssy -ssz +libext+.sv+.v -ntb_opts uvm-1.1 "

            if self.cmd_args.is_dc:
                vericom_command += "-F %s " % self.env_cfg.post_sim_dc_duv_flist
            elif self.cmd_args.is_pr:
                vericom_command += "-F %s " % self.env_cfg.post_sim_pr_duv_flist
            elif self.cmd_args.is_pg:
                vericom_command += "-F %s " % self.env_cfg.post_sim_pg_duv_flist
            elif self.cmd_args.is_post:
                vericom_command += "-F %s " % self.env_cfg.post_sim_duv_flist
            elif self.cmd_args.is_pa:
                vlogan_command += "-F %s " % self.env_cfg.pa_sim_duv_flist
            else:
                vericom_command += "-F %s " % self.env_cfg.pre_sim_duv_flist

            if self.cmd_args.is_xa:
                vericom_command += "-F %s %s " % (self.env_cfg.tb_xa_flist, self.cmd_args.test_file_path)
            elif (self.cmd_args.is_post or self.cmd_args.is_dc or self.cmd_args.is_pr or self.cmd_args.is_pg):
                vericom_command += "-F %s %s " % (self.env_cfg.tb_post_flist, self.cmd_args.test_file_path)
            elif not self.cmd_args.is_duv:
                vericom_command += "-F %s %s " % (self.env_cfg.tb_flist, self.cmd_args.test_file_path)
            vericom_command += "-logdir %s/vericomLog%s " % (self.cmd_args.comp_result_path, work_suffix)
            vericom_command += "%s " % self.cmd_args.define_usr_macros
            vericom_command += "-work %s/%s%s " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)
            vericom_command += "%s " % self.env_cfg.vericom_default_args
            self.execute_command_on_shell(vericom_command)

            # ====== elabcom_command ======
            elabcom_command = verdi_command_prefix +  "elabcom "
            if self.cmd_args.is_duv:
                elabcom_command += "-top %s " % self.env_cfg.duv_top
            else:
                elabcom_command += "-top %s " % self.env_cfg.tb_top
            elabcom_command += "-logdir %s/elabcomLog%s " % (self.cmd_args.comp_result_path, work_suffix)
            elabcom_command += "-lib %s/%s%s " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)
            elabcom_command += "-elab %s/%s_kdb%s " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)
            self.execute_command_on_shell(elabcom_command)

        # ====== verdi_command ======
        verdi_command = verdi_command_prefix +  "verdi "
        verdi_command += "-elab %s/%s_kdb%s.elab++ " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)
        if self.cmd_args.is_pa:
            verdi_command += "-upf %s " % self.env_cfg.upf_file_path

        if self.cmd_args.verdi_pretitle != "":
            verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle

        verdi_command += "-nologo &"
        self.execute_command_on_shell(verdi_command)

    def open_verdi_withvhdl_nocomp(self):
        elab_comp = False
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
                    
        work_suffix = ""
        if self.cmd_args.is_dc:
            work_suffix += "_dc"
        if self.cmd_args.is_pr:
            work_suffix += "_pr"
        if self.cmd_args.is_pg:
            work_suffix += "_pg"
        if self.cmd_args.is_post:
            work_suffix += "_post"
        if self.cmd_args.is_pa:
            work_suffix += "_pa"
        if self.cmd_args.is_xa:
            work_suffix += "_xa"

        elab_lib = "%s_kdb%s.elab++" % (self.env_cfg.vericom_work_lib, work_suffix)
        match_elab_lib = re.compile(re.escape(elab_lib))
        file_list = os.listdir(self.cmd_args.comp_result_path)  
        #print("file_list(%s) " % file_list)                    
        for item in file_list:
            if match_elab_lib.search(item):
                elab_comp = True
        if elab_comp:
            #print("elab_lib(%s) is  exists" % elab_lib)      
            # ====== verdi_command ======
            verdi_command = verdi_command_prefix +  "verdi "
            verdi_command += "-elab %s/%s_kdb%s.elab++ " % (self.cmd_args.comp_result_path,self.env_cfg.vericom_work_lib, work_suffix)
            if self.cmd_args.is_pa:
                verdi_command += "-upf %s " % self.env_cfg.upf_file_path
            if self.cmd_args.verdi_pretitle != "":
                verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle
            verdi_command += "-nologo &"
            self.execute_command_on_shell(verdi_command)
        else :
            owner_match = (pathlib.Path(self.cmd_args.sim_dir).owner() == self.cmd_args.cur_user)
            #print("elab_lib(%s) is not exists" % elab_lib)
            self.open_verdi_by_compile(owner_match)

    def open_verdi_with_vmncomp_path_kdb(self):
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
        verdi_command = verdi_command_prefix +  "verdi "
        verdi_command += "-top %s " % self.env_cfg.tb_top
        verdi_command += "-dbdir %s.daidir " % self.cmd_args.simv_file_path
        if self.cmd_args.verdi_pretitle != "":
            verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle
        else:
            verdi_command += "-preTitle vmnocomp_%s "  % self.cmd_args.corner
        verdi_command += "-nologo &"
        self.execute_command_on_shell(verdi_command)

    def open_verdi_by_test_name(self):
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
        
        verdi_command = verdi_command_prefix +  "verdi "
        verdi_command += "-top %s " % self.env_cfg.tb_top
        verdi_command += "-dbdir %s.daidir " % self.cmd_args.simv_file_path
        if self.cmd_args.verdi_pretitle != "":
            verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle
        else:
            verdi_command += "-preTitle %s " % self.cmd_args.test_name
        verdi_command += "-nologo &"
        self.execute_command_on_shell(verdi_command)

    def open_verdi_by_test_log_name(self):
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
        
        verdi_command = verdi_command_prefix +  "verdi "
        verdi_command += "-top %s " % self.env_cfg.tb_top
        verdi_command += "-ssf %s.fsdb " % self.cmd_args.test_log_name
        if self.cmd_args.verdi_pretitle != "":
            verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle
        verdi_command += "-nologo &"
        self.execute_command_on_shell(verdi_command)    #mod by gaojiang

    def open_verdi_by_filelist(self):
        if self.cmd_args.is_xa:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        elif self.cmd_args.is_bsub:
            verdi_command_prefix = "%s " % self.env_cfg.bsub_default_args
        else:
            verdi_command_prefix = ""
        
        verdi_command = verdi_command_prefix +  "verdi "
        verdi_command += "-sv -ssv -ssy -ssz +libext+.sv+.v -ntb_opts uvm-1.1 "
        verdi_command += "%s " % self.env_cfg.vericom_default_args
        if self.cmd_args.is_dc:
            verdi_command += "-F %s " % self.env_cfg.post_sim_dc_duv_flist
        elif self.cmd_args.is_pr:
            verdi_command += "-F %s " % self.env_cfg.post_sim_pr_duv_flist
        elif self.cmd_args.is_pg:
            verdi_command += "-F %s " % self.env_cfg.post_sim_pg_duv_flist
        elif self.cmd_args.is_post:
            verdi_command += "-F %s " % self.env_cfg.post_sim_duv_flist
        elif self.cmd_args.is_pa:
            vlogan_command += "-F %s " % self.env_cfg.pa_sim_duv_flist
        else:
            verdi_command += "-F %s " % self.env_cfg.pre_sim_duv_flist

        if self.cmd_args.is_xa:
            verdi_command += "-F %s %s" % (self.env_cfg.tb_xa_flist, self.cmd_args.test_file_path)
        elif (self.cmd_args.is_post or self.cmd_args.is_dc or self.cmd_args.is_pr or self.cmd_args.is_pg):
            verdi_command += "-F %s %s" % (self.env_cfg.tb_post_flist, self.cmd_args.test_file_path)
        elif not self.cmd_args.is_duv:
            verdi_command += "-F %s %s" % (self.env_cfg.tb_flist, self.cmd_args.test_file_path)

        verdi_command += "%s " % self.cmd_args.define_usr_macros

        if self.cmd_args.is_duv:
            verdi_command += "-top %s " % self.env_cfg.duv_top
        else:
            verdi_command += "-top %s " % self.env_cfg.tb_top

        if self.cmd_args.is_pa:
            verdi_command += "-upf %s " % self.env_cfg.upf_file_path

        if self.cmd_args.verdi_pretitle != "":
            verdi_command += "-preTitle %s " % self.cmd_args.verdi_pretitle

        verdi_command += "-nologo &"

        self.execute_command_on_shell(verdi_command)
        
    def open_verdi(self):
        if self.cmd_args.test_name != "":
            self.open_verdi_by_test_name()
        elif self.cmd_args.test_log_name != "":
            self.open_verdi_by_test_log_name()  #mod by gaojiang
        elif self.cmd_args.is_nocomp:
            self.open_verdi_withvhdl_nocomp()
        elif self.cmd_args.is_vmnocomp:
            self.open_verdi_with_vmncomp_path_kdb()
        elif not self.cmd_args.is_vhdl:
            self.open_verdi_by_filelist()
        else:
            owner_match = (pathlib.Path(self.cmd_args.sim_dir).owner() == self.cmd_args.cur_user)
            self.open_verdi_by_compile(owner_match)

    def open_vmanager(self):
        if self.env_cfg.vmanager_local:
            self.execute_command_on_shell("%s vmanager -local &" % self.env_cfg.bsub_default_args)
        else:
            self.execute_command_on_shell("%s vmanager -server %s &" % (self.env_cfg.bsub_default_args, self.env_cfg.vmanager_server))

    def collect_timing_violation(self):
        violation_case_count = 0
        violation_count = 0
        # delete old vio.rpt
        if os.path.exists('vio.rpt') != False:
            self.execute_command_on_shell('rm -i vio.rpt')
        self.violation_report_file_handler = open(self.violation_report_file_name, 'w')
        # find all *.log files in target path

        string_target_vio_path = ""
        regr_result_dir_list   = []
        post_vio_path          = self.cmd_args.vio_target_path + "/"   
        temp_regr_result_list     = os.listdir(post_vio_path)
        regr_result_list       = []
        for index in temp_regr_result_list:
            if not (os.path.isdir(post_vio_path+index)):
                temp_regr_result_list.remove(index)
        for index in temp_regr_result_list:
            if "corner" in str(index):
                regr_result_dir_list.append(post_vio_path+index)
        string_target_vio_path = ' '.join(regr_result_dir_list)
        self.execute_command_on_shell('find ' + string_target_vio_path + ' -name "*local_log.log" > temp_log_files.txt')

        #self.execute_command_on_shell('find ' + self.cmd_args.vio_target_path + ' -name "*.log" > temp_log_files.txt')
        temp_log_files_handler = open('temp_log_files.txt','r')
        # iterate all log files found
        log_files = temp_log_files_handler.readlines()
        for log_file_index in log_files:
            log_file_index = log_file_index.replace(' ','')
            log_file_index = log_file_index.replace('\n','')
            line_count = 0
            testcase_name = 'NULL'
            vio_list = []
            violation_count_in_current_log = 0
            for index,line in enumerate(open(log_file_index, 'r')):
                line_count += 1
            next_line_index = 0
            while next_line_index <= line_count:
                next_line_index += 1
                line = linecache.getline(log_file_index, next_line_index)
                if testcase_name == 'NULL':
                    testcase_match = re.findall(r'TESTNAME\s*=\s*\w+', line)
                    if len(testcase_match) != 0:
                        testcase_name = testcase_match[0]
                if len(vio_list) != 0:
                    line = re.sub(r'\s+', '', line)
                    self.violation_report_file_handler.write('\t' + line + '\n\n')
                    vio_list = []
                    continue
                vio_list = re.findall(r'^.*(Timing\s*violation.*$)', line)
                if len(vio_list) == 0:
                    continue
                violation_count_in_current_log += 1
                if violation_count_in_current_log == 1:
                    self.violation_report_file_handler.write('=======================================================\n')
                    self.violation_report_file_handler.write(log_file_index+ '\n' + testcase_name + '\n\n')
                self.violation_report_file_handler.write(vio_list[0] + '\n')
            violation_count += violation_count_in_current_log
            if violation_count_in_current_log != 0:
                violation_case_count += 1
        self.violation_report_file_handler.close()
        self.execute_command_on_shell('rm -rf temp_log_files.txt')
        print("******************************************************")
        print("testcases count : %s" % violation_case_count)
        print("violation count : %s" % violation_count)
        print("report file     : %s" % self.violation_report_file_name)
        print("******************************************************")

    def delete_useless_file(self):
        self.execute_command_on_shell('rm -rf csrc simv* ucli.key novas.* verdiLog 64 AN.DB work.lib++ vc_hdrs.h *.log map.rpt')
        self.execute_command_on_shell('rm -rf hwswDebugLog eSWdebugLog *.fsdb')
        self.execute_command_on_shell('rm -rf %s %s' % (self.cmd_args.wave_dir_path, self.cmd_args.log_dir_path))
        self.execute_command_on_shell('rm -rf %s %s' % (self.cmd_args.comp_result_path, self.cmd_args.sim_result_path))
        self.execute_command_on_shell('rm -rf *.fsdb *.log *.html *.report *.txt core.* eSWdebugLog vmgr_db vhdl* *.rpt *info hwswDebugLog *.h *.svh')        
        for root, dirs, files in os.walk(self.env_cfg.work_dir):
            for cur_file in files:
                match_obj_file = re.match(r'^.+\.o$', cur_file)
                if match_obj_file:
                    obj_file_path = os.path.join(root, cur_file)
                    os.remove(obj_file_path)
                match_obj_file = re.match(r'^.+\.dep$', cur_file)
                if match_obj_file:
                    obj_file_path = os.path.join(root, cur_file)
                    os.remove(obj_file_path)
    
    def link_coverage_vdb(self):
        regr_coverage_vdb_path = "%s/%s.vdb" % (self.cmd_args.sim_dir, self.cmd_args.sim_test_name)
        ln_coverage_vdb_path = "%s/%s.vdb" % (self.env_cfg.cov_result_path, self.cmd_args.sim_test_name)
        ln_coverage_command = "ln -s %s %s" % (regr_coverage_vdb_path, ln_coverage_vdb_path)
        self.execute_command_on_shell(ln_coverage_command)
   
    def link_vmcomp_path_coverage_vdb(self):
        vmcomp_vdb_path = self.env_cfg.vmcomp_path + "/"
        cur_time = time.strftime("%Y_%m_%d_%H_%M_%S", time.localtime(time.time()))        
        vdb_list = os.listdir(vmcomp_vdb_path)
        for index in vdb_list:
            match_vmcomp_vdb = re.match(r'\w*.vdb$',index)
            if match_vmcomp_vdb:
                vdb_path = os.path.join(vmcomp_vdb_path,index)
                ln_coverage_vdb_path = "%s/vmnocomp_%s" % (self.env_cfg.cov_result_path,index)        
                ln_coverage_command = "ln -s %s %s" % (vdb_path, ln_coverage_vdb_path)
                self.execute_command_on_shell(ln_coverage_command)

    def vmcomp_simv_link_vmcomp_path(self):

        brun_run_dir = os.environ.get("BRUN_RUN_DIR")
        vmcomp_comp_path = "%s/comp_result/%s/comp_%s" % (self.env_cfg.vmcomp_path, self.cmd_args.sim_type_prefix, self.cmd_args.test_name)
        #self.postgroupscript = PostGroupScript(self.cmd_args.brun_group_dir,vmcomp_comp_path)
        self.postgroupscript = PostGroupScript(brun_run_dir,vmcomp_comp_path)
        self.postgroupscript.run()
    def vm_postrun_dir_vdb_clean(self):
        postrunscript                       = PostRunScript()
        postrunscript.vdb_delete_keyword    = self.env_cfg.user_custom_vdb_delete_key_word
        postrunscript.brun_testname         = os.environ.get("BRUN_TEST_NAME")
        postrunscript.brun_seed             = os.environ.get("BRUN_SV_SEED")
        postrunscript.locallog_keep         = self.cmd_args.locallog_keep
        postrunscript.vmcomp_path           = "%s/comp_result/%s/comp_%s" % (self.env_cfg.vmcomp_path, self.cmd_args.sim_type_prefix, self.cmd_args.test_name)
        postrunscript.brun_run_dir          = os.environ.get("BRUN_RUN_DIR")
        postrunscript.simv_test_pkg         = self.env_cfg.simv_test_pkg
        postrunscript.run()

    def delete_vmcomp_vdb(self):
        postrunscript                       = PostRunScript()
        postrunscript.vmcomp_path           = "%s/comp_result/%s/comp_%s" % (self.env_cfg.vmcomp_path, self.cmd_args.sim_type_prefix, self.cmd_args.test_name)
        postrunscript.simv_test_pkg         = self.env_cfg.simv_test_pkg
        postrunscript.coverage_data_path    = "%s/coverage/coverage.vdb" % self.env_cfg.work_dir
        postrunscript.all_vdb_clean         = True
        postrunscript.clean_fail_and_na_vdb()

    def gen_vsif_from_testcases(self):
        import gen_file_from_testcases        
        render_file_path = "%s/template/pre_session.vsif" % postgroup_dir
        output_file_path = "./presim_session.vsif"
        testcases_dir    = self.env_cfg.testcases_dir_path
        gen_file_from_testcases.do_template_render(render_file_path,output_file_path,testcases_dir)

    def gen_testpkg_from_testcases(self):
        import gen_file_from_testcases        
        render_file_path = "%s/template/gen_testpkg.svh" % postgroup_dir
        output_file_path = "./testpkg.svh"        
        testcases_dir    = self.env_cfg.testcases_dir_path
        gen_file_from_testcases.do_template_render(render_file_path,output_file_path,testcases_dir)

    def delete_regr_comp_result(self):
        if not self.cmd_args.is_pkg:
            self.execute_command_on_shell('rm -rf %s ' % (self.cmd_args.comp_result_path))
        #self.execute_command_on_shell('rm -rf %s ' % (self.cmd_args.sim_result_path))        
        self.execute_command_on_shell('rm -rf csrc ucli.key verdiLog 64 AN.DB work.lib++ vc_hdrs.h map.rpt cm.log xa_log result')
        self.execute_command_on_shell('rm -rf *.fsdb *.log *.html *.report *.txt core.* eSWdebugLog vmgr_db vhdl* *.rpt *info hwswDebugLog *.h *.svh')

    def do_cmd(self):
        if self.cmd_args.is_run:
            #print(self.env_cfg)
            #print(self.cmd_args)
            self.execute_c_compile_command()
            if self.cmd_args.is_incr_run:
                # Incremental compile flow
                self.execute_incremental_compile_command()
            elif self.cmd_args.is_comp_rtl:
                # split-library flow : only the shared RTL library
                self.execute_compile_rtl_command()
                return True
            elif self.cmd_args.is_comp_tb:
                # split-library flow : only TB library + testcase
                self.execute_compile_tb_command()
                return True
            elif not (self.cmd_args.is_nocomp or self.cmd_args.is_vmnocomp):
                self.execute_compile_command()
            if self.cmd_args.is_comp or self.cmd_args.is_vmcomp:
                return True
            self.execute_simulation_command()
            if not self.cmd_args.is_vmnocomp and self.cmd_args.is_regr:
                self.link_coverage_vdb()
                #self.delete_regr_comp_result()
        elif self.cmd_args.is_verdi:
            self.open_verdi()
        elif self.cmd_args.is_make:
            if len(self.cmd_args.test_c_files_path) == 0:
                PubFunc.exit_err("The test_name(%s) dosen't have c case\n" % self.cmd_args.test_name)
            else:
                self.execute_c_compile_command()
        elif self.cmd_args.is_cov:
            if self.cmd_args.is_vmnocomp:
                self.link_vmcomp_path_coverage_vdb()
            self.merge_vdb_and_open()
        elif self.cmd_args.is_vm:
            self.open_vmanager()
        elif self.cmd_args.is_vio:
            self.collect_timing_violation()
        elif self.cmd_args.is_clean:
            self.delete_useless_file()
        elif self.cmd_args.is_init:
            self.env_cfg.init_env(self.cmd_args)
        elif self.cmd_args.is_vmcomplink:
            self.vmcomp_simv_link_vmcomp_path()
        elif self.cmd_args.is_vdbmerge:
            self.link_vmcomp_path_coverage_vdb()
            self.analysis_coverage()
            self.delete_vmcomp_vdb()
        elif self.cmd_args.is_vmsimclean:
            self.vm_postrun_dir_vdb_clean()
        elif self.cmd_args.is_vsif:
            self.gen_vsif_from_testcases()
            self.gen_testpkg_from_testcases()

        elif self.cmd_args.is_help:
            vmcomp_dir_path_t =os.environ.get("VMCOMP_PATH")
            self.cmd_args.print_help_info()

if __name__ == '__main__':
    cs_run = CSRun()
    cs_run.parse_cmdargs(sys.argv)
    cs_run.do_cmd()
