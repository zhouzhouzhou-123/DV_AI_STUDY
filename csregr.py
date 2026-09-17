#!/usr/bin/env python3

import os
import sys
import re
import linecache
import shutil
import random
import argparse

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
pubfunc_dir = os.path.abspath(cur_scr_dir + "/../../pubfunc")
#print("cur_scr_dir:%s" % cur_scr_dir)
#print("pubfunc_dir:%s" % pubfunc_dir)
sys.path.append(pubfunc_dir)

from pubfunc import PubFunc
from envcfg import EnvCfg
from cmdargs import CmdArgs

class CSRegr:
    def __init__(self):
        self.env_cfg = EnvCfg()
        self.env_cfg.set_env()
        #print(env_cfg)

        self.command_type        = ''

        self.postsim_options     = ''

        # testcase run-time config info
        self.run_time_config_info = ''
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


    def analysis_command_from_user(self, argv1, argv2, argv3, argv4, argv5, argv6, argv7):
        # prepare postsim_options
        if 'POST_SIM_ON' in self.cmd_args.usr_macros:
            self.postsim_options += ' +neg_tchk '
            self.postsim_options += ' +timingcheck'
            self.postsim_options += ' +optconfigfile+%s/cfg/notimingcheck.cfg' % self.env_cfg.cur_work_dir
        # open verdi
        if 'verdi' in self.command_type and 'post' in self.command_type:
            self.cmd_args.usr_macros = 'POST_SIM_ON+'
        if 'verdi' in self.command_type and 'xa' in self.command_type:
            self.cmd_args.usr_macros += 'XA_SIM+'
        if 'verdi' in self.command_type:
            if len(argv4) != 0:
                print("[ERROR] : wrong command format!")
                exit()
            elif len(argv2) == 0:
                print("[ERROR] : testcase must be provided for verdi!")
                exit()

    def analysis_coverage(self):
        coverage_database_path = "%s/coverage/coverage.vdb" % self.env_cfg.cur_work_dir
        # check weather target path exists
        if os.path.exists(coverage_database_path) == False:
            print("Error : %s not exists" % coverage_database_path)
            exit()
        # delete useless soft link file
        file_list = os.listdir(coverage_database_path)
        for index in range(0, len(file_list)):
            file_path = os.path.join(coverage_database_path, file_list[index])
            if os.path.exists(os.path.realpath(file_path)) == False:
                os.remove(file_path)
        # delete old merged-coverage result
        if os.path.exists(os.path.join(coverage_database_path, 'merged.vdb')) == True:
            shutil.rmtree(os.path.join(coverage_database_path, 'merged.vdb'))
        coverage_analysis_command = ''' \
cd ../coverage/coverage.vdb
urg -dir *.vdb -dbname merged.vdb
verdi -cov -covdir merged.vdb &'''
        self.execute_command_on_shell(coverage_analysis_command)

    def prepare_for_xa_sim(self):
        temp_env_dict = dict()
        temp_env_dict["SPICE_NAME"] = self.cmd_args.xa_spice_file_path
        temp_env_dict["CFG_NAME"] = self.cmd_args.xa_cfg_file_path
        temp_env_dict["INIT_FILE_PATH"] = self.cmd_args.xa_init_file_path
        temp_env_dict["LOG_NAME"] = self.env_cfg.sim_result_path + self.cmd_args.test_name

        # set temporary environment variable for XA sim
        os.environ["SPICE_NAME"] = self.cmd_args.xa_spice_file_path
        os.environ["CFG_NAME"] = self.cmd_args.xa_cfg_file_path
        os.environ["LOG_NAME"] = "./wave_log/" + self.cmd_args.xa_init_file_path

        self.run_time_config_info += "\n\n spice_file	= " + temp_env_dict.get("SPICE_NAME")
        self.run_time_config_info += "\n cfg_file	= " + temp_env_dict.get("CFG_NAME")
        self.run_time_config_info += "\n init_file	= " + temp_env_dict.get("INIT_FILE_PATH")

    def execute_c_compile_command(self):
        if len(self.cmd_args.test_c_files_path) == 0:
            return True
        c_compile_command = "make -f ${WORK_DIR}/ccode/Makefile all "
        c_compile_command += "COMP_RSLT_DIR=%s " % self.cmd_args.comp_result_path
        c_compile_command += "TC_NAME=%s " % self.cmd_args.test_name
        c_compile_command += "TC_CSRC=%s " % self.cmd_args.test_c_files_path[0]
        c_compile_command += "CACHE_OPT=%s " % self.cmd_args.cache_opt
        c_compile_command += "USR_MACROS=%s " % self.cmd_args.c_usr_macros
        c_compile_command += "|tee %s/c_compile_%s.log " % (self.cmd_args.comp_result_path, os.path.basename(self.cmd_args.comp_test_name))
        self.execute_command_on_shell(c_compile_command)
        #if self.execute_command_on_shell(c_compile_command) != 0:
        #    PubFunc.exit_err("c compile fail! %s" % c_compile_command)

    def execute_compile_command(self):
        if self.cmd_args.is_bsub:
            vcs_compile_command = "bsub -Ip vcs "
        else:
            vcs_compile_command = "vcs "
        vcs_compile_command += "%s " % self.env_cfg.vcs_default_comp_args
        if self.cmd_args.is_pa:
            vcs_compile_command += "-upf %s -power=force_prioriy " % self.env_cfg.upf_file_path
        vcs_compile_command += "-o %s " % self.cmd_args.simv_file_path
        vcs_compile_command += "-f %s -f %s %s " % (self.env_cfg.pre_sim_duv_flist, self.env_cfg.tb_flist, self.cmd_args.test_file_path)
        vcs_compile_command += "-top %s " % self.env_cfg.tb_top
        vcs_compile_command += "%s " % self.cmd_args.define_usr_macros
        vcs_compile_command += "-l %s " % self.cmd_args.comp_log_file_path
        self.execute_command_on_shell(vcs_compile_command)

    def execute_simulation_command(self):
        if self.cmd_args.is_bsub:
            vcs_sim_command = "bsub -Ip"
        else:
            vcs_sim_command = ""
        vcs_sim_command += "%s " % self.cmd_args.simv_file_path
        vcs_sim_command += "%s " % self.env_cfg.vcs_default_sim_args
        vcs_sim_command += "+ntb_random_seed=%d " % self.cmd_args.rand_seed
        vcs_sim_command += "+UVM_TESTNAME=%s " % self.cmd_args.test_name
        vcs_sim_command += "-l %s " % self.cmd_args.sim_log_file_path
        vcs_sim_command += "%s " % self.postsim_options

        if len(self.cmd_args.test_c_files_path) > 0:
            vcs_sim_command += "+HEXFILE_PROC0=%s.hex " % self.cmd_args.test_name

        if "VCD_DUMP_ON" in self.cmd_args.usr_macros:
            vcs_sim_command += "+plusargs_save +vcd_file=%s " % self.cmd_args.sim_wave_file_path
        else:
            vcs_sim_command += "+plusargs_save +fsdb_file=%s " % self.cmd_args.sim_wave_file_path
        vcs_sim_command += "%s " % self.cmd_args.define_usr_macros

        if self.cmd_args.is_pa:
            vcs_sim_command += "-power %s " % self.env_cfg.upf_cfg_path

        self.execute_command_on_shell(vcs_sim_command)
        self.execute_command_on_shell('rm -rf csrc simv* ucli.key vc_hdrs.h novas_dump.log')

        #print(self.env_cfg)
        #print(self.cmd_args)
        print("********************* Log Files ****************************************")
        print("comp_log : %s" % self.cmd_args.comp_log_file_path)
        print("sim_log  : %s" % self.cmd_args.sim_log_file_path)
        print("************************************************************************")

    def open_verdi_by_test_name(self):
        if self.cmd_args.comp_test_name == "":
            simv_daidir = ""
            for root, dirs, files in os.walk(self.env_cfg.comp_result_path):
                for cur_dir in dirs:
                    match_simv_daidir = re.match(r'^simv_.+.daidir$', cur_dir)
                    if match_simv_daidir:
                        simv_daidir = os.path.join(root, cur_dir)
                        break
            if simv_daidir != "":
                verdi_command = "verdi -simflow -dbdir %s " % simv_daidir
            else:
                PubFunc.exit_err("Can't find any simv_daidir in comp_result_path(%s)\n" % os.path.abspath(self.env_cfg.comp_result_path))
        else:
            verdi_command = "verdi -simflow -dbdir %s/simv_%s.daidir " % (self.env_cfg.comp_result_path, self.cmd_args.comp_test_name)
            verdi_command += "-top %s -nologo &" % self.env_cfg.tb_top

        self.execute_command_on_shell(verdi_command)

    def open_verdi_duv(self):
        verdi_command = "verdi -sv -ssv -ssy -ssz +libext+.v+.sv+.vp "
        if self.cmd_args.is_post:
            verdi_command += "-f %s " % self.env_cfg.post_sim_duv_flist
        else:
            verdi_command += "-f %s " % self.env_cfg.pre_sim_duv_flist
        if self.env_cfg.duv_top != "":
            verdi_command += "-top %s " % self.env_cfg.duv_top
        verdi_command += "%s -nologo &" % self.cmd_args.define_usr_macros

        self.execute_command_on_shell(verdi_command)

    def open_verdi(self):
        if self.cmd_args.is_duv:
            self.open_verdi_duv()
        else:
            self.open_verdi_by_test_name()

    def open_vmanager(self):
        self.execute_command_on_shell("vmanager -server %s" % self.env_cfg.vmanager_server)

    def collect_timing_violation(self):
        violation_case_count = 0
        violation_count = 0
        # delete old vio.rpt
        if os.path.exists('vio.rpt') != False:
            self.execute_command_on_shell('rm -i vio.rpt')
        self.violation_report_file_handler = open(self.violation_report_file_name, 'w')
        # find all *.log files in target path
        self.execute_command_on_shell('find ' + self.cmd_args.vio_target_path + ' -name "*.log" > temp_log_files.txt')
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
        self.execute_command_on_shell('rm -rf csrc simv* ucli.key novas.* verdiLog vc_hdrs.h *.log')
        self.execute_command_on_shell('rm -rf %s %s' % (self.env_cfg.wave_dir_path, self.env_cfg.log_dir_path))
        self.execute_command_on_shell('rm -rf %s %s' % (self.env_cfg.comp_result_path, self.env_cfg.sim_result_path))
        for root, dirs, files in os.walk(self.env_cfg.work_dir):
            for cur_file in files:
                match_obj_file = re.match(r'^.+\.o$', cur_file)
                if match_obj_file:
                    obj_file_path = os.path.join(root, cur_file)
                    os.remove(obj_file_path)

    def do_cmd(self):
        if self.cmd_args.is_run:
            print("===============================================================================")
            print("============= DIR(run)(%0s) ================" % os.environ["DIR(run)"])
            print("===============================================================================")
            #print(self.env_cfg)
            #print(self.cmd_args)
            if self.cmd_args.is_xa:
                self.prepare_for_xa_sim()
            self.execute_c_compile_command()
            if not self.cmd_args.is_nocomp:
                self.execute_compile_command()
            self.execute_simulation_command()
        elif self.cmd_args.is_verdi:
            self.open_verdi()
        elif self.cmd_args.is_make:
            if len(self.cmd_args.test_c_files_path) == 0:
                PubFunc.exit_err("The test_name(%s) dosen't have c case\n" % self.cmd_args.test_name)
            else:
                self.execute_c_compile_command()
        elif self.cmd_args.is_cov:
            self.analysis_coverage()
        elif self.cmd_args.is_vm:
            self.open_vmanager()
        elif self.cmd_args.is_vio:
            self.collect_timing_violation()
        elif self.cmd_args.is_clean:
            self.delete_useless_file()
        elif self.cmd_args.is_init:
            self.env_cfg.init_env()
        elif self.cmd_args.is_help:
            self.cmd_args.print_help_info()

if __name__ == '__main__':
    cmd_line_parser = argparse.ArgumentParser()
    cmd_line_parser.add_argument("-v", "--vsif_file", action="store", required=True, help="vsif file name")
    cmd_line_args = cmd_line_parser.parse_args()

    cs_regr = CSRegr()
    #cs_regr.parse_cmdargs(sys.argv)
    #cs_regr.do_cmd()
