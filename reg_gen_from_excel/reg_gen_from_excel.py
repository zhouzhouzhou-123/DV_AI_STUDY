#!/usr/bin/env python3
# FILE NAME      : reg_gen_from_excel.py
# DEPARTMENT     : Digital Verification Department
# AUTHOR         : zhouxk
# AUTHOR'S EMAIL : zhouxk@chipsea.com
# ABSTRACT       : Main entry point for register file generation from Excel.
#                  Orchestrates: Excel parsing -> JSON conversion -> validation
#                  -> Jinja2 template rendering -> output file generation.
#
#-------------------------------------------------------------------------

import json
import sys
import os
import re
import subprocess
import argparse
import time
from datetime import datetime, time as time_type

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
local_pubfunc_dir = os.path.join(cur_scr_dir, "pubfunc")
pubfunc_dir = os.path.abspath(
    "/project/dig_veri_ip/cs-digital-ip/common_script/script_for_verify/pubfunc")
if os.path.isdir(local_pubfunc_dir):
    sys.path.insert(0, local_pubfunc_dir)
elif os.path.isdir(pubfunc_dir):
    sys.path.append(pubfunc_dir)
sys.path.append(cur_scr_dir)

import xlsx2json
import reg_gen
from pubfunc import PubFunc
from ral_gen_parse_yaml import RegXlsx, RegSheet


# ===========================================================================
# Main class: Reg_gen_from_excel
# ===========================================================================

class Reg_gen_from_excel:
    """Orchestrates the entire register file generation pipeline."""

    def __init__(self, cmd_line_args):
        self.cmd_line_args = cmd_line_args
        self.reg_xlsx = RegXlsx()

    def run(self):
        """Entry point: analyze all sheets in the Excel workbook."""
        self.analysis_reg_xlsx()

    def analysis_reg_xlsx(self):
        """Iterate over all register sheets and generate output files."""
        global_file_gen = False
        self.reg_xlsx.cfg(self.cmd_line_args)
        for cur_sheet in self.reg_xlsx.reg_sheets:
            self.reg_sheet = RegSheet()
            self.reg_sheet.cfg(cur_sheet, self.cmd_line_args)
            self.reg_file_gen(self.reg_sheet)
            if self.reg_sheet.template_test_mode:
                self._gen_file(
                    self.reg_sheet.template_test_input_file_path,
                    self.reg_sheet.output_template_test_file_path,
                    self.reg_sheet.context_tc)
            else:
                if self.reg_sheet.ut_item_gen:
                    # Generate global files only once
                    if not global_file_gen:
                        self._gen_global_files(self.reg_sheet)
                        global_file_gen = True
                    # Generate per-sheet files
                    self._gen_per_sheet_files(self.reg_sheet)

    def _gen_global_files(self, rs):
        """Generate files that are shared across all sheets (generated once)."""
        # reg_info_cfg.sv
        self._gen_file_with_include(
            "reg_info_cfg.sv", rs.output_reg_info_path, rs.context_tc,
            '\n`include "../testcases/basetask/reg_info_cfg.sv"',
            rs.output_common_task_top_path)
        # reg_collection.sv
        self._gen_file_with_include(
            "reg_collection.sv", rs.output_reg_collection_path, rs.context_tc,
            '\n`include "../testcases/basetask/reg_collection.sv"',
            rs.output_common_task_top_path)
        # common_register_chk_task.sv (if not using per-module bus ops)
        if not rs.add_reg_name_to_bus_opt:
            self._gen_file_with_include(
                "common_register_chk_task.sv",
                rs.output_common_chk_task_path, rs.context_tc,
                '\n`include "../testcases/basetask/common_register_chk_task.sv"',
                rs.output_common_task_top_path)
        # Csx_RegTypes.h
        self._gen_file_with_include(
            "Csx_RegTypes.h", rs.output_csx_regtypes_path, rs.context_tc,
            '\n#include "Csx_RegTypes.h"',
            rs.output_csx_reg_total_path)
        # Permission common files
        if rs.access_mode_exist:
            self._gen_permission_common_files(rs)

    def _gen_per_sheet_files(self, rs):
        """Generate files specific to each register sheet."""
        # Per-module common_register_chk_task (if using per-module bus ops)
        if rs.add_reg_name_to_bus_opt:
            self._gen_file_with_include(
                "common_register_chk_task.sv",
                rs.output_common_chk_task_path, rs.context_tc,
                f'\n`include "../testcases/basetask/{rs.ip_name}_common_register_chk_task.sv"',
                rs.output_common_task_top_path)
        # Reserved field check testcase
        self._gen_file_with_include(
            "tc_regname_reg_access_rsvfield_chk_tmp.sv",
            rs.output_reg_chk_path, rs.context_tc,
            f'\n`include "../testcases/tc_{rs.ip_name}_reg_access_rsvfield_chk.sv"',
            rs.output_testcase_top_path)
        # Reset check testcase
        if rs.reset_field_exist:
            self._gen_file_with_include(
                "tc_reg_rst_chk.sv", rs.output_reg_rst_chk_path, rs.context_tc,
                f'\n`include "../testcases/tc_{rs.ip_name}_reg_access_rst_chk.sv"',
                rs.output_testcase_top_path)
        # Permission check testcase
        if rs.access_mode_exist:
            self._gen_file_with_include(
                "permission/tc_reg_permission.sv",
                rs.output_reg_permission_path, rs.context_tc,
                f'\n`include "../testcases/tc_{rs.ip_name}_reg_access_permission.sv"',
                rs.output_testcase_top_path)
        # Address and mask defines
        self._gen_file_with_include(
            "reg_addr.sv", rs.output_reg_addr_path, rs.context_tc,
            f'\n`include "../common/{rs.ip_name}_reg_addr.svh"',
            rs.output_common_define_top_path)
        self._gen_file_with_include(
            "reg_msk.sv", rs.output_reg_msk_path, rs.context_tc,
            f'\n`include "../common/{rs.ip_name}_reg_msk.svh"',
            rs.output_common_define_top_path)
        # Initialize reg info
        self._gen_file_with_include(
            "initialize_reg_info.sv",
            rs.output_initial_reg_info_path, rs.context_tc,
            f'\n`include "../testcases/basetask/initialize_{rs.ip_name.lower()}_reg_info.sv"',
            rs.output_common_task_top_path)
        # RAL model
        self._gen_ral_model_file(rs)
        # Config item
        if rs.ut_reg_item_gen:
            self._gen_file_with_include(
                "config_array_register_item.sv",
                rs.output_reg_item_path, rs.context_tc,
                f'\n`include "../cfg/{rs.ip_name}_config_item.sv"',
                rs.output_config_item_top_path)
        # C header files
        self._gen_file(
            "csx_reg_def.h", rs.output_c_regmacro_path, rs.context_tc)
        self._gen_file_with_include(
            "csx_reg.h", rs.output_c_file_path, rs.context_tc,
            f'\n#include "Csx{rs.ip_name.upper()}_Reg.h"',
            rs.output_csx_reg_total_path)
        self._gen_file_with_include(
            "reg_old.h", rs.output_old_c_file_path, rs.context_tc,
            f'\n#include "{rs.ip_name.lower()}_reg.h"',
            rs.output_csx_reg_total_path)

    def _gen_permission_common_files(self, rs):
        """Generate permission-related common files."""
        # access_permission_cfg.sv
        self._gen_file_with_include(
            "permission/access_permission_cfg.sv",
            rs.output_access_permission_cfg_path, rs.context_tc,
            '\n`include "../cfg/access_permission_cfg.sv"',
            rs.output_config_item_top_path)
        # common_permission_define.sv
        self._gen_file_with_include(
            "permission/common_permission_define.sv",
            rs.output_common_permission_define_path, rs.context_tc,
            '\n`include "../common/common_permission_define.sv"',
            rs.output_common_define_top_path)
        # permission_access_task.sv
        self._gen_file(
            "permission/permission_access_task.sv",
            rs.output_permission_access_task_path, rs.context_tc)
        # permission_top.svh
        self._gen_file_with_include(
            "permission/permission_top.svh",
            rs.output_permission_permission_top_path, rs.context_tc,
            '\n`include "../testcases/basetask/permission/permission_top.svh"',
            rs.output_common_task_top_path)
        # APB/AHB/AXI permission files
        self._gen_apb_permission_files(rs)
        self._gen_ahb_permission_files(rs)
        self._gen_axi_permission_files(rs)

    def _gen_apb_permission_files(self, rs):
        """Generate APB bus permission files."""
        apb_files = [
            ("permission/apb_permission/apb_basetask_ecc.sv",
             rs.output_apb_permission_apb_basetask_ecc_path),
            ("permission/apb_permission/apb_master_ecc_wr_rd_sequence.sv",
             rs.output_apb_permission_apb_master_ecc_wr_rd_sequence_path),
            ("permission/apb_permission/apb_safety_item.sv",
             rs.output_apb_permission_apb_safety_item_path),
            ("permission/apb_permission/apb_permission_access_top.svh",
             rs.output_apb_permission_apb_permission_access_top_path),
        ]
        for template, output in apb_files:
            self._gen_file(template, output, rs.context_tc)

    def _gen_ahb_permission_files(self, rs):
        """Generate AHB bus permission files."""
        ahb_files = [
            ("permission/ahb_permission/ahb_permission_basetask.sv",
             rs.output_ahb_permission_ahb_permission_basetask_path),
            ("permission/ahb_permission/ahb_master_permission_sequence_ecc.sv",
             rs.output_ahb_permission_ahb_master_permission_sequence_ecc_path),
            ("permission/ahb_permission/ahb_permission_access_top.svh",
             rs.output_ahb_permission_ahb_permission_access_top_path),
        ]
        for template, output in ahb_files:
            self._gen_file(template, output, rs.context_tc)

    def _gen_axi_permission_files(self, rs):
        """Generate AXI bus permission files."""
        axi_files = [
            ("permission/axi_permission/axi_permission_basetask.sv",
             rs.output_axi_permission_axi_permission_basetask_path),
            ("permission/axi_permission/axi_master_permission_sequence_ecc.sv",
             rs.output_axi_permission_axi_master_permission_sequence_ecc_path),
            ("permission/axi_permission/axi_permission_access_top.svh",
             rs.output_axi_permission_axi_permission_access_top_path),
        ]
        for template, output in axi_files:
            self._gen_file(template, output, rs.context_tc)

    # -----------------------------------------------------------------------
    # Core: parse Excel and build rendering context
    # -----------------------------------------------------------------------

    def reg_file_gen(self, reg_sheet):
        """Parse Excel sheet, validate data, and build template context."""
        # Reset warning counter
        reg_gen.count_warnings.counter = 0
        reg_gen.warnings.showwarning = reg_gen.count_warnings
        reg_gen.warnings.filterwarnings('always', category=UserWarning)
        print(reg_sheet.ip_name.upper())

        config = {
            "excel_file_path": self.cmd_line_args.input_xlsx_path,
            "sheet_name": reg_sheet.ip_name.upper(),
            "skip_rows": reg_sheet.skip_rows,
            "usecols": reg_sheet.usecols,
            "nrows": None
        }
        primary_key = reg_sheet.reg_name
        common_columns = [reg_sheet.reg_addr, reg_sheet.reg_reset_value]
        if reg_sheet.reset_field_exist:
            common_columns.append(reg_sheet.reset_field)
        if reg_sheet.access_mode_exist:
            common_columns.append(reg_sheet.rd_access_mode)
            common_columns.append(reg_sheet.wr_access_mode)

        group_name = "field_group"

        parse_obj_config = {
            "ip_name": reg_sheet.ip_name.upper(),
            "reg_name": reg_sheet.reg_name,
            "reg_addr": reg_sheet.reg_addr,
            "reg_reset_value": reg_sheet.reg_reset_value,
            "field_name": reg_sheet.field_name,
            "field_bits": reg_sheet.field_bits,
            "field_access": reg_sheet.field_access,
            "field_reset_value": reg_sheet.field_reset_value,
            "rd_access_mode": reg_sheet.rd_access_mode,
            "wr_access_mode": reg_sheet.wr_access_mode,
            "register_num": "Register num",
            "order_offset": "Order offset",
            "reset_field": reg_sheet.reset_field
        }

        # Build expected column list for validation
        expected_columns = [
            reg_sheet.reg_name, reg_sheet.reg_addr, reg_sheet.reg_reset_value,
            reg_sheet.field_name, reg_sheet.field_bits, reg_sheet.field_access,
            reg_sheet.field_reset_value
        ]
        if reg_sheet.reset_field_exist:
            expected_columns.append(reg_sheet.reset_field)
        if reg_sheet.access_mode_exist:
            expected_columns.append(reg_sheet.rd_access_mode)
            expected_columns.append(reg_sheet.wr_access_mode)

        # Excel -> JSON
        json_obj_parse = xlsx2json.excel_to_nested_json(
            **config,
            expected_columns=expected_columns,
            key_columns=[reg_sheet.reg_name, reg_sheet.reg_addr,
                         reg_sheet.field_name])
        json_obj_merge = xlsx2json.merge_json_by_key(
            json_obj_parse, primary_key, common_columns, group_name)
        json_obj = reg_gen.expand_registers(
            json_obj_merge, parse_obj_config, reg_sheet.register_array_en)

        # Write intermediate JSON
        with open(reg_sheet.json_path, 'w', encoding='utf-8') as f:
            json.dump(json_obj, f, ensure_ascii=False, indent=2,
                      default=json_serial)

        # Validate and build register objects
        reg_sheet.register_obj_group = reg_gen.parse_obj_from_json(
            json_obj, parse_obj_config)
        for register in reg_sheet.register_obj_group:
            register.validate_register_wrapper(reg_sheet.rsv_ro_attr_chk)
            reg_sheet.data_size = register.bus_size
            reg_sheet.addr_gap = int(reg_sheet.data_size / 8)

        # Abort if validation errors found
        if reg_gen.count_warnings.counter > 0:
            print(f"\033[1;36mThere are "
                  f"{reg_gen.count_warnings.counter} error(s) in Excel, "
                  f"aborting.\033[0m")
            sys.exit(1)

        # Build reset domain list
        if reg_sheet.reset_field_exist:
            reg_sheet.module_rst_list = reg_gen.get_reset_type_list(
                reg_sheet.register_obj_group)
            reg_sheet.generate_rst_domain()

        # Build template rendering context
        reg_sheet.context_tc = {
            "module_name": reg_sheet.ip_name,
            "registers": reg_sheet.register_obj_group,
            "access_mode_en": reg_sheet.access_mode_exist,
            "reset_field_en": reg_sheet.reset_field_exist,
            "module_rst_list": reg_sheet.sorted_rst_domains,
            "bus_write_opt": reg_sheet.ut_bus_write_opt,
            "bus_read_opt": reg_sheet.ut_bus_read_opt,
            "reg_gap": reg_sheet.addr_gap,
            "reg_saddr": reg_sheet.ut_reg_saddr,
            "reg_eaddr": reg_sheet.ut_reg_eaddr,
            "reserved_attr": reg_sheet.rsv_ro_attr_chk,
            "add_reg_name_to_bus_opt": reg_sheet.add_reg_name_to_bus_opt,
            "reg_data_size": reg_sheet.data_size
        }

    # -----------------------------------------------------------------------
    # RAL model generation (calls external ralgen)
    # -----------------------------------------------------------------------

    def _gen_ral_model_file(self, rs):
        """Generate RALF file and invoke ralgen to produce UVM RAL model.
        [FIX #6] Uses subprocess instead of os.system for return code check."""
        render_file_path = f"{cur_scr_dir}/template/reg_ralf_merage_array.sv"
        self._gen_file(
            "reg_ralf_merage_array.sv", rs.output_ralf_file_path,
            rs.context_tc, header_en=False)

        ralgen_cmd = (f"ralgen {rs.output_ralf_file_path} "
                      f"-t {rs.ip_name}_regmodel -uvm "
                      f"-o {rs.output_reg_ral_dir}/{rs.ip_name}_reg")
        include_str = f'\n`include "../ral/{rs.ip_name}_reg.sv"'
        add_file_to_file_top_svh(rs.output_ral_top_path, include_str)

        print(ralgen_cmd)
        # [FIX #6] Use subprocess for proper error handling
        result = subprocess.run(
            ralgen_cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"\033[1;31m[ralgen Error] returncode={result.returncode}")
            if result.stderr:
                print(f"  stderr: {result.stderr.strip()}\033[0m")

    # -----------------------------------------------------------------------
    # Generic file generation helpers
    # -----------------------------------------------------------------------

    def _gen_file(self, template_name, output_path, context_tc, header_en=True):
        """Render a template and write to output file.
        [FIX #4] Uses 'with' statement to ensure file handle is closed."""
        render_file_path = f"{cur_scr_dir}/template/{template_name}"
        rendered = gen_render_item(render_file_path, context_tc)
        with open(output_path, "w") as cur_file:
            if header_en:
                cur_file_name = os.path.basename(output_path)
                cur_file.write(PubFunc.get_file_header('//', cur_file_name))
            cur_file.write(rendered)

    def _gen_file_with_include(self, template_name, output_path, context_tc,
                               include_str, include_top_path):
        """Render template, write file, and append include to top file."""
        self._gen_file(template_name, output_path, context_tc)
        add_file_to_file_top_svh(include_top_path, include_str)


# ===========================================================================
# Utility functions
# ===========================================================================

def add_file_to_file_top_svh(file_top_path, add_file_str):
    """Append an include line to a .svh file if not already present.
    [FIX #5] Fixed dedup logic and added proper file handle management."""
    include_stripped = add_file_str.strip()
    with open(file_top_path, "a+") as current_file:
        current_file.seek(0)
        existing = current_file.read()
        if include_stripped not in existing:
            current_file.write(add_file_str)

def json_serial(obj):
    """JSON serializer for datetime/time objects."""
    if isinstance(obj, datetime):
        return obj.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(obj, time_type):
        return obj.strftime("%H:%M:%S")
    raise TypeError(f"Type {type(obj)} not serializable")

def gen_render_item(render_file_path, context_tc):
    """Load a Jinja2 template and render it with the given context."""
    template = reg_gen.get_template_inst(render_file_path)
    return template.render(context_tc)


# ===========================================================================
# Entry point
# ===========================================================================

if __name__ == "__main__":
    cmd_line_parser = argparse.ArgumentParser(
        description="Generate register files from Excel specification.")
    cmd_line_parser.add_argument(
        "-i", "--input_xlsx_path", action="store", required=True,
        help="Input Excel register specification file")
    cmd_line_parser.add_argument(
        "-y", "--input_yaml_path", action="store", required=False,
        help="Input YAML configuration file (default: regsheet_format.yml)")
    cmd_line_parser.add_argument(
        "-o", "--output_dir_path", action="store", required=False,
        help="Output directory path (default: ./result)")
    cmd_line_args = cmd_line_parser.parse_args()

    # Validate input file
    if not os.path.isfile(cmd_line_args.input_xlsx_path):
        PubFunc.exit_err(
            f"Input xlsx not found: {cmd_line_args.input_xlsx_path}")

    # Default YAML path
    if cmd_line_args.input_yaml_path is None:
        cmd_line_args.input_yaml_path = f"{cur_scr_dir}/regsheet_format.yml"
    elif not os.path.isfile(cmd_line_args.input_yaml_path):
        PubFunc.exit_err(
            f"YAML file not found: {cmd_line_args.input_yaml_path}")

    # Resolve output directory path
    if cmd_line_args.output_dir_path is None:
        cmd_line_args.output_dir_path = os.getcwd() + "/result"
    else:
        if not cmd_line_args.output_dir_path.startswith('/'):
            cmd_line_args.output_dir_path = (
                os.getcwd() + '/' + cmd_line_args.output_dir_path)

    # Run the generator
    script = Reg_gen_from_excel(cmd_line_args)
    script.run()
