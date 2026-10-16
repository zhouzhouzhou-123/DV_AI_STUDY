#!/usr/bin/env python3
# FILE NAME      : ral_gen_parse_yaml.py
# DEPARTMENT     : Digital Verification Department
# AUTHOR         : zhouxk
# AUTHOR'S EMAIL : zhouxk@chipsea.com
# ABSTRACT       : YAML configuration parser for register generation.
#                  Defines RegXlsx (workbook-level) and RegSheet (sheet-level)
#                  configuration classes with output path management.
#
#-------------------------------------------------------------------------

import sys
import os
import re
import copy
import xlrd3 as xlrd
import argparse
import yaml

cur_scr_dir = os.path.dirname(os.path.abspath(__file__))
local_pubfunc_dir = os.path.join(cur_scr_dir, "pubfunc")
pubfunc_dir = os.path.abspath(
    "/project/dig_veri_ip/cs-digital-ip/common_script/script_for_verify/pubfunc")
if os.path.isdir(local_pubfunc_dir):
    sys.path.insert(0, local_pubfunc_dir)
elif os.path.isdir(pubfunc_dir):
    sys.path.append(pubfunc_dir)

from pubfunc import PubFunc

# ===========================================================================
# RegXlsx - Workbook-level configuration
# ===========================================================================

class RegXlsx:
    """Represents an Excel workbook containing one or more register sheets."""

    def __init__(self):
        self.cmd_line_args = []
        self.input_xlsx_path = ""
        self.reg_sheets = []

    def __str__(self):
        return f"RegXlsx(input_xlsx_path={self.input_xlsx_path})"

    def cfg(self, cmd_line_args):
        """Load the workbook and filter valid register sheets.
        Skips 'memory map' sheets and sheets with whitespace in names."""
        self.cmd_line_args = cmd_line_args
        self.reg_workbook = xlrd.open_workbook(self.cmd_line_args.input_xlsx_path)
        for cur_sheet in self.reg_workbook.sheets():
            matchObj = re.match(r'[a-zA-Z0-9_]+$', cur_sheet.name)
            matchMemoryMap = re.match(r'memory.+map', cur_sheet.name, re.I)
            matchObj_space = re.match(r'[a-zA-Z0-9_]+$', cur_sheet.name.strip())
            if matchObj_space and (not matchMemoryMap) and (not matchObj):
                PubFunc.exit_err(
                    f"Sheet name '{cur_sheet.name}' contains whitespace. "
                    f"Please rename to '{cur_sheet.name.strip()}'")
            if matchObj and (not matchMemoryMap):
                self.reg_sheets.append(cur_sheet)

    def parse_reg_sheets(self):
        """Iterate over valid sheets and create RegSheet instances."""
        for cur_sheet in self.reg_sheets:
            print(cur_sheet)
            reg_sheet = RegSheet()
            reg_sheet.cfg(cur_sheet, self.cmd_line_args)


# ===========================================================================
# RegSheet - Sheet-level configuration and output path management
# ===========================================================================

class RegSheet:
    """Holds all configuration for a single register sheet: column mapping,
    feature flags, output paths, and template rendering context."""

    def __init__(self):
        # File paths
        self.input_yaml_path = ""
        self.output_dir_path = ""
        self.ip_name = ""

        # Template test mode
        self.template_test_mode = False
        self.template_test_input_file_path = ""
        self.template_test_output_file_name = "template_test_file.sv"

        # Bus operation options
        self.add_reg_name_to_bus_opt = False
        self.ut_bus_write_opt = "apb_write"
        self.ut_bus_read_opt = "apb_read"

        # Feature flags
        self.ut_item_gen = False
        self.ut_reg_item_gen = False
        self.c_struct_reg_en = False
        self.access_mode_exist = False
        self.reset_field_exist = False
        self.rsv_ro_attr_chk = True
        self.register_array_en = False

        # Path config
        self.ut_path_cfg = ""
        self.ut_reg_item_dirname = "cfg"
        self.ut_reg_ralmodel_dirname = "ral"
        self.ut_define_dirname = "common"
        self.ut_testcase_dirname = "testcases"
        self.c_reg_addr_dirname = "ccode/register"

        # Column name mapping (must match Excel header row)
        self.reg_name = "Register Name"
        self.reg_desc = "Description"
        self.reg_addr = "Address Offset"
        self.reg_reset_value = "Reset_Value"
        self.field_name = "Field Name"
        self.field_bits = "Bits"
        self.field_access = "Field Attribute"
        self.field_reset_value = "Field Reset Value"
        self.wr_access_mode = ""
        self.rd_access_mode = ""
        self.reset_field = ""
        self.field_desc = "Field Comments"

        # Excel parsing config
        self.row_idx = 0
        self.skip_rows = 0
        self.usecols = "A,C:H,J:L"

        # Runtime state
        self.cur_indent = 0
        self.addr_gap = 0
        self.ut_reg_saddr = "0"
        self.ut_reg_eaddr = "h0000_1000"
        self.data_size = "8"
        self.register_obj_group = []
        self.module_rst_list = []
        self.sorted_rst_domains = []
        self.context_tc = {}

        # YAML config sub-dicts
        self.col_yaml_dict = dict()
        self.ut_cfg_dict = dict()
        self.regsheet_cfg_dict = dict()
        self.st_cfg_dict = dict()
        self.template_test_dict = dict()

    def __str__(self):
        return (f"RegSheet(yaml={self.input_yaml_path}, "
                f"ip={self.ip_name}, out={self.output_dir_path})")

    def cfg(self, cur_sheet, cmd_line_args):
        """Parse YAML config, set up paths, and create output directories."""
        self.input_yaml_path = cmd_line_args.input_yaml_path
        self.output_dir_path = cmd_line_args.output_dir_path

        print(cmd_line_args.output_dir_path)
        if not os.path.isdir(cmd_line_args.output_dir_path):
            os.mkdir(cmd_line_args.output_dir_path)

        # --- Parse YAML configuration ---
        self._parse_yaml_config()

        # --- Configure output paths ---
        self.ip_name = cur_sheet.name.lower()
        self._configure_output_paths()

        # --- Create output directory structure ---
        self._create_output_directories()

        self.reg_sheet = cur_sheet

    def _parse_yaml_config(self):
        """Load and parse the YAML configuration file.
        [FIX #5] Added YAML format validation with line-number reporting."""
        self.input_yaml_path = os.path.abspath(self.input_yaml_path)
        try:
            with open(self.input_yaml_path, "r") as yaml_file:
                yaml_info = yaml_file.read()
            yaml_dict = yaml.load(yaml_info, Loader=yaml.FullLoader)
        except yaml.YAMLError as e:
            err_msg = (f"\033[1;31m[YAML Format Error] Failed to parse "
                       f"'{self.input_yaml_path}':\033[0m\n")
            if hasattr(e, 'problem_mark'):
                mark = e.problem_mark
                err_msg += (f"  Line {mark.line + 1}, "
                            f"Column {mark.column + 1}: {e.problem}\n")
                err_msg += f"  Context: {mark.get_snippet()}\n"
            else:
                err_msg += f"  {e}\n"
            err_msg += "  Please check YAML indentation and syntax."
            PubFunc.exit_err(err_msg)
        except FileNotFoundError:
            PubFunc.exit_err(
                f"\033[1;31m[YAML Error] File not found: "
                f"{self.input_yaml_path}\033[0m")

        if yaml_dict is None:
            PubFunc.exit_err(
                f"\033[1;31m[YAML Error] File '{self.input_yaml_path}' "
                f"is empty or invalid\033[0m")
        if "regsheet_format" not in yaml_dict:
            PubFunc.exit_err(
                f"\033[1;31m[YAML Error] Missing top-level key "
                f"'regsheet_format' in '{self.input_yaml_path}'\033[0m")

        # Extract regsheet_format fields
        fmt = yaml_dict["regsheet_format"]
        self.skip_rows = fmt.pop("skip_rows")
        # [FIX #5] Validate skip_rows
        if not isinstance(self.skip_rows, int) or self.skip_rows < 0:
            PubFunc.exit_err(
                f"\033[1;31m[YAML Error] 'skip_rows' must be a "
                f"non-negative integer, got: {self.skip_rows}\033[0m")
        if self.skip_rows > 5:
            print(f"\033[1;33m[Warning] skip_rows={self.skip_rows} is "
                  f"unusually large, ensure the header row is not skipped\033[0m")

        self.usecols = fmt.pop("usecols")
        self.reg_name = fmt.pop("reg_name")
        self.reg_desc = fmt.pop("reg_desc")
        self.reg_addr = fmt.pop("reg_addr")
        self.reg_reset_value = fmt.pop("reg_reset_value")
        self.field_name = fmt.pop("field_name")
        self.field_bits = fmt.pop("field_bits")
        self.field_access = fmt.pop("field_access")
        self.field_desc = fmt.pop("field_desc")
        self.field_reset_value = fmt.pop("field_reset_value")
        self.col_yaml_dict = yaml_dict.copy()

        # Build regsheet_cfg_dict from remaining keys
        if "regsheet_format" in self.col_yaml_dict:
            for k, v in self.col_yaml_dict["regsheet_format"].items():
                self.regsheet_cfg_dict[k] = v

        # Access mode config
        if "reset_field_exist" in self.regsheet_cfg_dict:
            val = self.regsheet_cfg_dict["reset_field_exist"]
            if val is not None:
                self.reset_field_exist = val
            if "reset_field" in self.regsheet_cfg_dict:
                val = self.regsheet_cfg_dict["reset_field"]
                if val is not None:
                    self.reset_field = val

        if "access_mode_exist" in self.regsheet_cfg_dict:
            val = self.regsheet_cfg_dict["access_mode_exist"]
            if val is not None:
                self.access_mode_exist = val
            if "rd_access_mode" in self.regsheet_cfg_dict:
                val = self.regsheet_cfg_dict["rd_access_mode"]
                if val is not None:
                    self.rd_access_mode = val
            if "wr_access_mode" in self.regsheet_cfg_dict:
                val = self.regsheet_cfg_dict["wr_access_mode"]
                if val is not None:
                    self.wr_access_mode = val

        # C struct config
        if "st_cfg" in self.col_yaml_dict:
            for k, v in self.col_yaml_dict["st_cfg"].items():
                self.st_cfg_dict[k] = v
            self.c_struct_reg_en = bool(self.st_cfg_dict.get("c_struct_reg_en"))

        # Template test config
        if "template_test" in self.col_yaml_dict:
            for k, v in self.col_yaml_dict["template_test"].items():
                self.template_test_dict[k] = v
            if "template_test_mode" in self.template_test_dict:
                val = self.template_test_dict["template_test_mode"]
                if val is not None:
                    self.template_test_mode = val
            if "template_test_input_file_path" in self.template_test_dict:
                val = self.template_test_dict["template_test_input_file_path"]
                if val is not None:
                    self.template_test_input_file_path = self.get_file_abspath(val)
            if "template_test_output_file_name" in self.template_test_dict:
                val = self.template_test_dict["template_test_output_file_name"]
                if val is not None:
                    self.template_test_output_file_name = val

        # UT (unit test) config
        if "ut_cfg" in self.col_yaml_dict:
            for k, v in self.col_yaml_dict["ut_cfg"].items():
                self.ut_cfg_dict[k] = v

        if "ut_item_gen" in self.ut_cfg_dict:
            self.ut_item_gen = bool(self.ut_cfg_dict["ut_item_gen"])

        if "rsv_ro_attr_chk" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["rsv_ro_attr_chk"]
            if val is not None:
                self.rsv_ro_attr_chk = val

        if self.ut_item_gen:
            self._parse_ut_cfg()

    def _parse_ut_cfg(self):
        """Parse unit-test specific configuration from YAML."""
        if "ut_reg_item_gen" in self.ut_cfg_dict:
            self.ut_reg_item_gen = bool(self.ut_cfg_dict["ut_reg_item_gen"])

        if "register_array_en" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["register_array_en"]
            if val is not None:
                self.register_array_en = val

        if "add_reg_name_to_bus_opt" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["add_reg_name_to_bus_opt"]
            if val is not None:
                self.add_reg_name_to_bus_opt = val

        if "ut_bus_write_opt" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["ut_bus_write_opt"]
            if val is not None:
                self.ut_bus_write_opt = val

        if "ut_bus_read_opt" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["ut_bus_read_opt"]
            if val is not None:
                self.ut_bus_read_opt = val

        if "ut_path_cfg" in self.ut_cfg_dict:
            val = self.ut_cfg_dict["ut_path_cfg"]
            if val is not None:
                self.ut_path_cfg = val
                env_val = os.environ.get(self.ut_path_cfg)
                if env_val is None:
                    # [FIX #9] Handle unset environment variable gracefully
                    print(f"\033[1;33m[Warning] Environment variable "
                          f"'{self.ut_path_cfg}' is not set, "
                          f"using -o output path instead\033[0m")
                else:
                    self.output_dir_path = os.path.abspath(env_val)
                    print(self.output_dir_path)

        # Directory name overrides
        dir_keys = {
            "ut_reg_item_dirname": "ut_reg_item_dirname",
            "ut_define_dirname": "ut_define_dirname",
            "ut_testcase_dirname": "ut_testcase_dirname",
            "ut_reg_saddr": "ut_reg_saddr",
            "ut_reg_eaddr": "ut_reg_eaddr",
        }
        for yaml_key, attr in dir_keys.items():
            if yaml_key in self.ut_cfg_dict:
                val = self.ut_cfg_dict[yaml_key]
                if val is not None:
                    setattr(self, attr, val)

    def _configure_output_paths(self):
        """Set all output file paths based on configuration."""
        if self.template_test_mode:
            if not os.path.isfile(self.template_test_input_file_path):
                PubFunc.exit_err(
                    f"template_test_input_file_path "
                    f"({self.template_test_input_file_path}) not exist!")
            self.output_template_test_file_path = (
                f"{self.output_dir_path}/{self.template_test_output_file_name}")

        if self.ut_item_gen:
            self.output_item_dir = (
                f"{self.output_dir_path}/{self.ut_reg_item_dirname}")
            json_dir = f"{self.output_dir_path}/json"
            self.json_path = f"{json_dir}/{self.ip_name.lower()}.json"

            self.output_define_dir = (
                f"{self.output_dir_path}/{self.ut_define_dirname}")
            self.output_testcase_dir = (
                f"{self.output_dir_path}/{self.ut_testcase_dirname}")
            self.output_basetask_dir = f"{self.output_testcase_dir}/basetask"
            self.output_permission_dir = f"{self.output_basetask_dir}/permission"
            self.output_apb_permission_dir = f"{self.output_permission_dir}/apb_permission"
            self.output_ahb_permission_dir = f"{self.output_permission_dir}/ahb_permission"
            self.output_axi_permission_dir = f"{self.output_permission_dir}/axi_permission"
            self.output_c_file_dir = (
                f"{self.output_dir_path}/{self.c_reg_addr_dirname}")
            self.output_reg_ral_dir = (
                f"{self.output_dir_path}/{self.ut_reg_ralmodel_dirname}")

            # RAL and C output files
            self.output_ralf_file_path = (
                f"{self.output_reg_ral_dir}/{self.ip_name}_reg.ralf")
            self.output_old_c_file_path = (
                f"{self.output_c_file_dir}/{self.ip_name}_reg.h")
            self.output_c_file_path = (
                f"{self.output_c_file_dir}/Csx{self.ip_name.upper()}_Reg.h")
            self.output_c_regmacro_path = (
                f"{self.output_c_file_dir}/"
                f"Csx{self.ip_name.upper()}_RegDef.h")

            # Define files
            self.output_common_permission_define_path = (
                f"{self.output_define_dir}/common_permission_define.sv")
            self.output_reg_addr_path = (
                f"{self.output_define_dir}/{self.ip_name}_reg_addr.svh")
            self.output_reg_msk_path = (
                f"{self.output_define_dir}/{self.ip_name}_reg_msk.svh")
            self.output_common_define_top_path = (
                f"{self.output_define_dir}/common_define_top.sv")

            # Config item files
            self.output_reg_item_path = (
                f"{self.output_item_dir}/{self.ip_name}_config_item.sv")
            self.output_config_item_top_path = (
                f"{self.output_item_dir}/config_item_top.svh")
            self.output_access_permission_cfg_path = (
                f"{self.output_item_dir}/access_permission_cfg.sv")

            # Testcase files
            self.output_reg_chk_path = (
                f"{self.output_testcase_dir}/"
                f"tc_{self.ip_name}_reg_access_rsvfield_chk.sv")
            self.output_reg_permission_path = (
                f"{self.output_testcase_dir}/"
                f"tc_{self.ip_name}_reg_access_permission.sv")
            self.output_reg_rst_chk_path = (
                f"{self.output_testcase_dir}/"
                f"tc_{self.ip_name}_reg_access_rst_chk.sv")
            self.output_testcase_top_path = (
                f"{self.output_testcase_dir}/test_pkg_reg_access.svh")

            # Bas task files
            if self.add_reg_name_to_bus_opt:
                self.output_common_chk_task_path = (
                    f"{self.output_basetask_dir}/"
                    f"{self.ip_name}_common_register_chk_task.sv")
            else:
                self.output_common_chk_task_path = (
                    f"{self.output_basetask_dir}/"
                    f"common_register_chk_task.sv")
            self.output_reg_info_path = (
                f"{self.output_basetask_dir}/reg_info_cfg.sv")
            self.output_reg_collection_path = (
                f"{self.output_basetask_dir}/reg_collection.sv")
            self.output_initial_reg_info_path = (
                f"{self.output_basetask_dir}/"
                f"initialize_{self.ip_name}_reg_info.sv")
            self.output_common_task_top_path = (
                f"{self.output_basetask_dir}/common_task_top.svh")

            # Permission task files
            self.output_permission_access_task_path = (
                f"{self.output_permission_dir}/permission_access_task.sv")
            self.output_permission_permission_top_path = (
                f"{self.output_permission_dir}/permission_top.svh")

            # APB permission files
            self.output_apb_permission_apb_basetask_ecc_path = (
                f"{self.output_apb_permission_dir}/apb_basetask_ecc.sv")
            self.output_apb_permission_apb_master_ecc_wr_rd_sequence_path = (
                f"{self.output_apb_permission_dir}/"
                f"apb_master_ecc_wr_rd_sequence.sv")
            self.output_apb_permission_apb_safety_item_path = (
                f"{self.output_apb_permission_dir}/apb_safety_item.sv")
            self.output_apb_permission_apb_permission_access_top_path = (
                f"{self.output_apb_permission_dir}/"
                f"apb_permission_access_top.svh")

            # AHB permission files
            self.output_ahb_permission_ahb_permission_basetask_path = (
                f"{self.output_ahb_permission_dir}/"
                f"ahb_permission_basetask.sv")
            self.output_ahb_permission_ahb_master_permission_sequence_ecc_path = (
                f"{self.output_ahb_permission_dir}/"
                f"ahb_master_permission_sequence_ecc.sv")
            self.output_ahb_permission_ahb_permission_access_top_path = (
                f"{self.output_ahb_permission_dir}/"
                f"ahb_permission_access_top.svh")

            # AXI permission files
            self.output_axi_permission_axi_permission_basetask_path = (
                f"{self.output_axi_permission_dir}/"
                f"axi_permission_basetask.sv")
            self.output_axi_permission_axi_master_permission_sequence_ecc_path = (
                f"{self.output_axi_permission_dir}/"
                f"axi_master_permission_sequence_ecc.sv")
            self.output_axi_permission_axi_permission_access_top_path = (
                f"{self.output_axi_permission_dir}/"
                f"axi_permission_access_top.svh")
        else:
            # Minimal output mode (no UT files)
            self.output_reg_ral_dir = self.output_dir_path
            self.output_ralf_file_path = (
                f"{self.output_dir_path}/{self.ip_name}_reg.ralf")
            self.output_old_c_file_path = (
                f"{self.output_dir_path}/{self.ip_name}_reg.h")
            self.output_c_regmacro_path = (
                f"{self.output_dir_path}/"
                f"Csx{self.ip_name.upper()}_RegDef.h")
            self.output_c_file_path = (
                f"{self.output_dir_path}/"
                f"Csx{self.ip_name.upper()}_Reg.h")
            self.output_reg_addr_path = f"{self.output_dir_path}/reg_addr.svh"

        # Common paths (both modes)
        self.output_ral_top_path = f"{self.output_reg_ral_dir}/ral_top.svh"
        self.output_csx_regtypes_path = (
            f"{self.output_dir_path}/{self.c_reg_addr_dirname}/Csx_RegTypes.h")
        self.output_csx_reg_total_path = (
            f"{self.output_dir_path}/{self.c_reg_addr_dirname}/Csx_regtotal.h")

    def _create_output_directories(self):
        """Create all required output directories."""
        if self.template_test_mode:
            return  # Template test mode doesn't need directory structure

        if self.ut_item_gen:
            dirs_to_create = [
                f"{self.output_dir_path}/json",
                self.output_item_dir,
                self.output_define_dir,
                self.output_testcase_dir,
                self.output_basetask_dir,
                self.output_permission_dir,
                self.output_apb_permission_dir,
                self.output_ahb_permission_dir,
                self.output_axi_permission_dir,
                self.output_c_file_dir,
                self.output_reg_ral_dir,
            ]
            for d in dirs_to_create:
                if not os.path.isdir(d):
                    os.makedirs(d)

    def generate_rst_domain(self):
        """Validate and sort reset domains by priority.
        Ensures all reset fields in Excel match YAML reset_domains config."""
        error_domains = []
        module_resets = [line.strip().upper()
                         for line in self.module_rst_list if line.strip()]
        if "reset_domains" in self.ut_cfg_dict:
            all_domains = self.ut_cfg_dict["reset_domains"]
            if all_domains is not None:
                for domain in all_domains:
                    error_domains.append(domain["name"].upper())
                self.sorted_rst_domains = sorted(
                    all_domains, key=lambda x: x["priority"])
                for domain in self.sorted_rst_domains:
                    domain["name"] = domain["name"].upper()
                for reset_field in module_resets:
                    if reset_field not in error_domains:
                        PubFunc.exit_err(
                            f"reset_field ({reset_field}) not in YAML "
                            f"reset_domains! Expected one of: {error_domains}")

    def get_file_abspath(self, file_path):
        """Resolve environment variables in a file path and return absolute path.
        [FIX #9] Handles unset environment variables gracefully."""
        loop_replace = True
        while loop_replace:
            search_environ = re.search(r'\$\{*(\w+)\}*', file_path)
            if search_environ:
                cur_environ = search_environ.group(1)
                env_val = os.environ.get(cur_environ)
                if env_val is None:
                    print(f"\033[1;33m[Warning] Environment variable "
                          f"'{cur_environ}' is not set in path: "
                          f"{file_path}\033[0m")
                    loop_replace = False
                else:
                    file_path = file_path.replace("{", "").replace("}", "")
                    file_path = file_path.replace(
                        f"${cur_environ}", env_val)
            else:
                loop_replace = False
        return os.path.abspath(file_path)


# ---------------------------------------------------------------------------
# Standalone test entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    cmd_line_parser = argparse.ArgumentParser()
    cmd_line_parser.add_argument(
        "-i", "--input_xlsx_path", action="store",
        required=True, help="input CS-XXX_Register.xlsx")
    cmd_line_parser.add_argument(
        "-y", "--input_yaml_path", action="store",
        required=False, help="input regsheet_format.yml")
    cmd_line_parser.add_argument(
        "-o", "--output_dir_path", action="store",
        required=False, help="output dir path")
    cmd_line_args = cmd_line_parser.parse_args()

    if not os.path.isfile(cmd_line_args.input_xlsx_path):
        PubFunc.exit_err(
            f"{cmd_line_args.input_xlsx_path} input xlsx not exist!")

    if cmd_line_args.input_yaml_path is None:
        cmd_line_args.input_yaml_path = f"{cur_scr_dir}/regsheet_format.yml"
    elif not os.path.isfile(cmd_line_args.input_yaml_path):
        PubFunc.exit_err(
            f"{cmd_line_args.input_yaml_path} yaml path not exist!")

    if cmd_line_args.output_dir_path is None:
        cmd_line_args.output_dir_path = os.getcwd() + "/result"
    else:
        if not cmd_line_args.output_dir_path.startswith('/'):
            cmd_line_args.output_dir_path = (
                os.getcwd() + '/' + cmd_line_args.output_dir_path)

    reg_xlsx = RegXlsx()
    reg_xlsx.cfg(cmd_line_args)
    reg_xlsx.parse_reg_sheets()
