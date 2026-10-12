#!/usr/bin/env python3
# FILE NAME      : timing_warning_parser.py
# DEPARTMENT     : Digital Verification Department
# AUTHOR         : xiayu
# AUTHOR'S EMAIL : xiayu@chipsea.com
# ABSTRACT       : Parse timing violations and warnings from simulation/compilation logs.
#                  Optimized version with bug fixes and enhanced features.
#-------------------------------------------------------------------------

import os
import getopt
import sys
import json
import re
import time
import logging
from collections import defaultdict

# === Constants ===============================================================
RULE_SKIP_STR = "-1"
RULE_SKIP_INT = -1
LINE_UNKNOWN = "unknown"
DEFAULT_OUTPUT_DIR = "."

UNIT_MULTIPLIERS = {
    'ps': 1,
    'ns': 1000,
    'us': 1000000,
    'ms': 1000000000
}

# === Pre-compiled regex patterns ============================================
RE_WARNING = re.compile(
    r'Warning-(\[.*?\]) ([^\r\n]+)(?:\r?\n([^\r\n]*),\s*[\\\n]*(\d+))?\D?((.+\n)+)'
)
RE_TIMING_VIO = re.compile(
    r'"([^"]+)",\s*(\d+):\s*Timing violation in (\S+)\n(.*)'
)
RE_TIME_VALUE = re.compile(r':\d+(ns|ms|us|ps)')
RE_TIME_CONVERT = re.compile(r'(\d+)(ps|ns|ms|us)')
RE_UVM_TESTNAME = re.compile(r'\+UVM_TESTNAME=(\S+)')
RE_SEED = re.compile(r'\+ntb_random_seed=(-?\d+)')
RE_DEFINE = re.compile(r'\+define\+([\w+]+)\+?')

# === Logging setup ==========================================================
logger = logging.getLogger("timing_parser")


def setup_logging():
    """Configure logging with both console and file handlers."""
    logger.setLevel(logging.DEBUG)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    console_fmt = logging.Formatter('%(message)s')
    console.setFormatter(console_fmt)
    logger.addHandler(console)


setup_logging()


# === Data classes ============================================================

class Warning:
    """Represents a parsed warning from a log file."""

    def __init__(self, warning_type: str, warning_description: str,
                 file_path: str, line_num: str, input_file_name: str,
                 log_name: str, info: str):
        self.warning_type = warning_type
        self.warning_description = warning_description
        self.file_path = file_path
        self.line_num = self._normalize_line_num(line_num)
        self.input_file_name = input_file_name
        self.log_name = log_name
        self.info = info

    @staticmethod
    def _normalize_line_num(line_num: str) -> int:
        """Convert line_num to int, returning -1 for unknown values."""
        if line_num == LINE_UNKNOWN or not line_num:
            return RULE_SKIP_INT
        try:
            return int(line_num)
        except (ValueError, TypeError):
            return RULE_SKIP_INT

    def __str__(self):
        return (f"Input File: {self.input_file_name},\n"
                f" Warning Type: {self.warning_type},"
                f" Description: {self.warning_description}\n"
                f" File Path: {self.file_path}, {self.line_num}\n\n")


class TimingViolation:
    """Represents a parsed timing violation from a simulation log."""

    def __init__(self, file_path: str, line_num: str,
                 timing_violation_signal: str, log_path: str,
                 violation_content: str, violation_time: int):
        self.file_path = file_path
        self.line_num = line_num
        self.timing_violation_signal = timing_violation_signal
        self.log_path = log_path
        self.violation_content = violation_content
        self.violation_time = violation_time

    def __repr__(self):
        return (f"Log Path: {self.log_path}\n"
                f"Timing Violation - File: {self.file_path}, Line: {self.line_num},"
                f"\nSignal: {self.timing_violation_signal}, Log: {self.log_path}\n"
                f" {self.violation_content}\n")


# === Utility functions ======================================================

def convert_to_ps(time_str: str) -> int:
    """Convert a time string (e.g. '100ns') to picoseconds."""
    match = RE_TIME_CONVERT.search(time_str)
    if match:
        value = int(match.group(1))
        unit = match.group(2)
        return value * UNIT_MULTIPLIERS[unit]
    else:
        logger.error(f"Error-[Invalid Time String] '{time_str}' is not a valid time string.")
        return 0


def find_first_line(filename: str, target: str) -> int:
    """Find the first line number containing the target string."""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            for line_num, line in enumerate(file, 1):
                if target in line:
                    return line_num
            return 0
    except FileNotFoundError:
        logger.error(f"Error: File '{filename}' not found")
        return 0
    except PermissionError:
        logger.error(f"Error: Permission denied reading '{filename}'")
        return 0
    except Exception as e:
        logger.error(f"Error reading file '{filename}': {e}")
        return 0


# === Parsing functions ======================================================

def parse_warnings_from_file(file_name: str) -> list:
    """Parse all warnings from a single log file."""
    warnings = []
    try:
        with open(file_name, 'r', encoding='utf-8') as file:
            content = file.read()
        matches = RE_WARNING.findall(content)
        for match in matches:
            warning_type = match[0].strip('[]')
            warning_description = match[1]
            file_path = match[2] if match[2] else LINE_UNKNOWN
            line_num = match[3] if match[3] else LINE_UNKNOWN
            info = match[4] if match[4] else LINE_UNKNOWN
            warning = Warning(warning_type, warning_description, file_path,
                              line_num, file_name, file_name, info)
            warnings.append(warning)
    except FileNotFoundError:
        logger.error(f"Error-[File not Found] The file {file_name} was not found.")
    except PermissionError:
        logger.error(f"Error-[Permission Denied] Cannot read {file_name}.")
    except UnicodeDecodeError:
        logger.error(f"Error-[Encoding] Failed to decode {file_name} as UTF-8.")
    except Exception as e:
        logger.error(f"Error-[Read Error] An error occurred while reading {file_name}: {e}")
    return warnings


def extract_timing_violations(file_name: str, config: dict) -> list:
    """Extract timing violations from a single log file with first_ignore_line support."""
    violations = []
    line_num_max = 0

    # Determine the starting line to ignore (for reset phase filtering)
    for ignore_rule in config.get("first_ignore_line", []):
        enable_filter = ignore_rule.get("enable_specific_character_filter", False)
        specific_character = ignore_rule.get("specific_character", "")
        if enable_filter and specific_character:
            specific_line_num = find_first_line(file_name, specific_character)
            line_num_max = max(line_num_max, specific_line_num)

    try:
        with open(file_name, 'r', encoding='utf-8') as file:
            lines = file.readlines()
    except FileNotFoundError:
        logger.error(f"Error-[File not Found] The file {file_name} was not found.")
        return violations
    except PermissionError:
        logger.error(f"Error-[Permission Denied] Cannot read {file_name}.")
        return violations
    except UnicodeDecodeError:
        logger.error(f"Error-[Encoding] Failed to decode {file_name} as UTF-8.")
        return violations
    except Exception as e:
        logger.error(f"Error-[Read Error] An error occurred while reading {file_name}: {e}")
        return violations

    # Apply first_ignore_line: replace lines before the marker with empty lines
    if line_num_max > 0:
        new_lines = ["\n"] * line_num_max
        new_lines.extend(lines[line_num_max - 1:])
        content = "".join(new_lines)
    else:
        content = "".join(lines)

    matches = RE_TIMING_VIO.findall(content)
    for match in matches:
        file_path = match[0]
        line_num = match[1]
        timing_violation_signal = match[2]
        violation_content = match[3]

        match_time = RE_TIME_VALUE.search(violation_content)
        if match_time:
            violation_time = convert_to_ps(match_time.group().lstrip(':'))
        else:
            logger.warning(f"Warning-[No Time Info] No time info found in violation: {timing_violation_signal}")
            violation_time = 0  # FIX P0: default value instead of undefined

        violation = TimingViolation(file_path, line_num, timing_violation_signal,
                                    file_name, violation_content, violation_time)
        violations.append(violation)

    return violations


# === Filter functions =======================================================

def _is_skip_value(value) -> bool:
    """Check if a value means 'skip this dimension' in cross-match rules."""
    return value in (RULE_SKIP_STR, "", None)


def filter_timing_violations(violations: list, config: dict) -> list:
    """Filter timing violations based on config rules. Rules are OR-combined."""
    filtered = []
    for violation in violations:
        should_keep = True

        # Rule 1: Global time gate
        vio_start_time_global = config.get("violation_start_limit_global")
        if vio_start_time_global is not None and not _is_skip_value(vio_start_time_global):
            converted_time = convert_to_ps(vio_start_time_global)
            if converted_time > 0 and converted_time >= violation.violation_time:
                should_keep = False

        # Rule 2: Signal name fullmatch
        if should_keep:
            for signal_pattern in config.get("timing_violation_signal", []):
                if re.fullmatch(signal_pattern, violation.timing_violation_signal):
                    should_keep = False
                    break

        # Rule 3: File path + line number
        if should_keep:
            for file_line_rule in config.get("file_and_line", []):
                path = file_line_rule.get("path", RULE_SKIP_STR)
                line_num = file_line_rule.get("line_num", RULE_SKIP_INT)
                if _is_skip_value(path):
                    continue
                if re.search(path, violation.file_path):
                    if line_num == RULE_SKIP_INT or line_num == int(violation.line_num):
                        should_keep = False
                        break

        # Rule 4: Cross-match (AND of dimensions, OR across rules)
        if should_keep:
            for cross_rule in config.get("cross_match", []):
                path = cross_rule.get("path", RULE_SKIP_STR)
                line_num = cross_rule.get("line_num", RULE_SKIP_INT)
                signal = cross_rule.get("timing_violation_signal", RULE_SKIP_STR)
                keyword = cross_rule.get("timing_violation_keyword", RULE_SKIP_STR)

                # Skip rule if all dimensions are skip values
                if (_is_skip_value(path) and (line_num == RULE_SKIP_INT)
                        and _is_skip_value(signal) and _is_skip_value(keyword)):
                    continue

                path_match = _is_skip_value(path) or bool(re.search(path, violation.file_path))
                line_match = (line_num == RULE_SKIP_INT) or (line_num == int(violation.line_num))
                signal_match = _is_skip_value(signal) or bool(re.search(signal, violation.timing_violation_signal))
                keyword_match = _is_skip_value(keyword) or bool(re.search(keyword, violation.violation_content))

                if path_match and line_match and signal_match and keyword_match:
                    should_keep = False
                    break

        if should_keep:
            filtered.append(violation)

    return filtered


def filter_warnings(warnings: list, config: dict) -> list:
    """Filter warnings based on config rules. Rules are OR-combined."""
    filtered = []
    for warning in warnings:
        should_keep = True

        # Rule 1: Warning type fullmatch
        for warning_type_pattern in config.get("warning_type", []):
            if re.fullmatch(warning_type_pattern, warning.warning_type):
                should_keep = False
                break

        # Rule 2: Cross-match warning (AND of dimensions, OR across rules)
        if should_keep:
            for cross_rule in config.get("cross_match_warning", []):
                path = cross_rule.get("module_path", RULE_SKIP_STR)
                line_num = cross_rule.get("line_num", RULE_SKIP_INT)
                warning_type = cross_rule.get("warning_type", RULE_SKIP_STR)
                keyword = cross_rule.get("warning_info_keyword", RULE_SKIP_STR)

                path_match = _is_skip_value(path) or bool(re.search(path, warning.file_path))
                # FIX P0: normalize line_num comparison (both are now int)
                line_match = (line_num == RULE_SKIP_INT) or (line_num == warning.line_num)
                type_match = _is_skip_value(warning_type) or (warning_type == warning.warning_type)
                keyword_match = _is_skip_value(keyword) or bool(re.search(keyword, warning.info))

                if path_match and line_match and type_match and keyword_match:
                    should_keep = False
                    break

        if should_keep:
            filtered.append(warning)

    return filtered


# === Summary functions ======================================================

def summarize_warning(warnings: list) -> tuple:
    """Summarize warnings by type, print to terminal, return summary lines."""
    warning_summary = defaultdict(int)
    for warning in warnings:
        warning_summary[warning.warning_type] += 1

    logger.info("warning summary")
    lines = ["warning summary"]
    for warning_type, count in sorted(warning_summary.items(), key=lambda x: x[1], reverse=True):
        logger.info(f"warning_type:\033[1;31m{warning_type}\033[0m,\t\tcount: \033[1;30m{count}\033[0m")
        lines.append(f"warning_type: {warning_type},\t\tcount: {count}")
    return dict(warning_summary), lines


def summarize_vio(vios: list) -> tuple:
    """Summarize violations by signal, print to terminal, return summary lines."""
    vios_summary = defaultdict(int)
    for vio in vios:
        vios_summary[vio.timing_violation_signal] += 1

    logger.info("vio summary by signal")
    lines = ["vio summary by signal"]
    for signal, count in sorted(vios_summary.items()):
        logger.info(f"signal: \033[1;31m{signal}\033[0m,\t\tcount: \033[1;30m{count}\033[0m")
        lines.append(f"signal: {signal},\t\tcount: {count}")
    return dict(vios_summary), lines


# === Output functions =======================================================

def extract_log_info(log_path: str) -> tuple:
    """Extract UVM test info from a log file for traceability."""
    try:
        with open(log_path, 'r', encoding='utf-8') as f:
            content = f.read()
        testname_match = RE_UVM_TESTNAME.search(content)
        seed_match = RE_SEED.search(content)
        define_match = RE_DEFINE.search(content)

        testname = testname_match.group(1) if testname_match else "N/A"
        seed = seed_match.group(1) if seed_match else "N/A"
        if define_match:
            macros = [m for m in define_match.group(1).split('+') if m]
        else:
            macros = []
        return testname, seed, macros
    except Exception:
        return "N/A", "N/A", []


def save_info(info_list: list, output_file: str):
    """Save results grouped by log file with source traceability info."""
    grouped = defaultdict(list)
    for item in info_list:
        key = getattr(item, 'log_path', None) or getattr(item, 'log_name', 'unknown')
        grouped[key].append(item)

    with open(output_file, 'w', encoding='utf-8') as f:
        for log_path, items in grouped.items():
            testname, seed, macros = extract_log_info(log_path)
            f.write('\n' + '=' * 80 + '\n')
            f.write(f'\033[1;35m{"=" * 15} SOURCE LOG: {log_path} {"=" * 15}\033[0m\n')
            f.write(f'\033[1;33m  UVM_TESTNAME: {testname}  |  ntb_random_seed: {seed}\033[0m\n')
            if macros:
                f.write(f'\033[1;36m  DEFINES: {", ".join(macros)}\033[0m\n')
            f.write('=' * 80 + '\n\n')
            for item in items:
                f.write(str(item) + '\n')


# === File matching ==========================================================

def get_matching_files(path: str, regex_pattern: str) -> list:
    """Recursively find files matching a regex pattern under a directory."""
    file_list = []
    try:
        pattern = re.compile(regex_pattern)
    except re.error:
        raise ValueError(f"Error-[Pattern Invalid] Invalid regex: {regex_pattern}")

    if not os.path.exists(path):
        logger.error(f"Error-[Path not Found] The path {path} does not exist.")
        return file_list

    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            if pattern.search(file_path):
                file_list.append(file_path)
    return file_list


def get_dedup_files(path: str, regex_patterns: list) -> list:
    """Get deduplicated file list from multiple patterns using realpath."""
    seen = set()
    result = []
    for pattern in regex_patterns:
        for fp in get_matching_files(path, pattern):
            real_fp = os.path.realpath(fp)
            if real_fp not in seen:
                seen.add(real_fp)
                result.append(fp)
    return result


# === Single-file processing ================================================

def do_warning_by_file(warning_log_path: str, config: dict) -> list:
    """Parse and filter warnings from a single file."""
    warnings = parse_warnings_from_file(warning_log_path)
    return filter_warnings(warnings, config)


def do_timing_violation_by_file(sim_log: str, config: dict) -> list:
    """Extract and filter timing violations from a single file."""
    violations = extract_timing_violations(sim_log, config)
    return filter_timing_violations(violations, config)


# === Main processing pipelines =============================================

def process_simulation_logs(action: str, log_dir: str, config: dict,
                            output_dir: str) -> tuple:
    """Process simulation logs: extract warnings and timing violations."""
    sim_warning_result = []
    timing_violation_result = []

    if action not in ("both", "sim"):
        return sim_warning_result, timing_violation_result

    sim_file_list = get_dedup_files(log_dir, config.get("sim_log_pattern", []))
    if not sim_file_list:
        logger.warning("\033[1;33mWarning-[Filelist Empty] No simulation log files found\033[0m")
        return sim_warning_result, timing_violation_result

    for file in sim_file_list:
        logger.info(file)

    for sim_log_path in sim_file_list:
        sim_log_path = sim_log_path.strip()
        logger.info(f"begin {sim_log_path}")
        sim_warning_result.extend(do_warning_by_file(sim_log_path, config))
        timing_violation_result.extend(do_timing_violation_by_file(sim_log_path, config))
        logger.info('Success gen sim timing violation result')

    save_info(timing_violation_result, os.path.join(output_dir, "filtered_timing_violations.txt"))
    save_info(sim_warning_result, os.path.join(output_dir, "filtered_warnings_in_sim.txt"))

    return sim_warning_result, timing_violation_result


def process_compilation_logs(action: str, log_dir: str, config: dict,
                             output_dir: str) -> list:
    """Process compilation logs: extract warnings."""
    warning_result = []

    if action not in ("both", "comp"):
        return warning_result

    comp_file_list = get_dedup_files(log_dir, config.get("comp_log_pattern", []))
    if not comp_file_list:
        logger.warning("\033[1;31mWarning: No compilation log files found.\033[0m")
        return warning_result

    for file in comp_file_list:
        logger.info(file)

    for comp_file_path in comp_file_list:
        comp_file_path = comp_file_path.strip()
        logger.info(f"begin {comp_file_path}")
        warning_result.extend(do_warning_by_file(comp_file_path, config))
        logger.info("Success gen comp warning log")

    save_info(warning_result, os.path.join(output_dir, "filtered_warnings.txt"))

    return warning_result


# === Argument parsing =======================================================

def set_default_json_path() -> str:
    """Build default JSON config path from WORK_DIR environment variable."""
    work_dir = os.environ.get('WORK_DIR')
    if work_dir is None:
        logger.warning("\033[1;31mWarning-[Env Variable Missing] WORK_DIR is not set\033[0m")
        return None
    return os.path.join(work_dir, "setup", "warning_timing_vio_filter.json")


def parse_arguments() -> tuple:
    """Parse command line arguments. Returns (status_code, action, json_path, log_dir, output_dir)."""
    action = "both"
    json_path = set_default_json_path()
    log_dir = None
    output_dir = DEFAULT_OUTPUT_DIR

    try:
        opts, args = getopt.getopt(sys.argv[1:], "cshf:o:", ["comp", "sim", "help", "file=", "output="])
        for opt, arg in opts:
            if opt in ("-c", "--comp"):
                action = "comp"
            elif opt in ("-s", "--sim"):          # FIX P1: elif instead of if
                action = "sim"
            elif opt in ("-f", "--file"):
                json_path = arg
            elif opt in ("-o", "--output"):        # NEW: configurable output dir
                output_dir = arg
            elif opt in ("-h", "--help"):
                print_usage()
                return -1, action, json_path, log_dir, output_dir

        if len(args) == 0:
            logger.error("\033[1;31mError-[Log Dir Missing] log directory is required\033[0m")
            return -1, action, json_path, log_dir, output_dir

        log_dir = args[0]
        if not os.path.exists(log_dir):
            logger.error(f"\033[1;31mError-[Path not Found] Directory '{log_dir}' does not exist.\033[0m")
            return -1, action, json_path, log_dir, output_dir

        # FIX P1: validate output directory
        if not os.path.exists(output_dir):
            os.makedirs(output_dir, exist_ok=True)

        logger.info("please wait for it to complete...")
        return 0, action, json_path, log_dir, output_dir

    except getopt.GetoptError as e:
        logger.error(f"\033[1;31mError-[Getopt Error] {e}\033[0m")
        return -1, action, json_path, log_dir, output_dir


def print_usage():
    """Print usage information."""
    print("\033[36mUsage:\033[0m")
    print("\033[36m  timing_warning_parser.py <log_dir>                  # both comp & sim\033[0m")
    print("\033[36m  timing_warning_parser.py -s <log_dir>               # sim only\033[0m")
    print("\033[36m  timing_warning_parser.py -c <log_dir>               # comp only\033[0m")
    print("\033[36m  timing_warning_parser.py -f <config.json> <log_dir> # specify config\033[0m")
    print("\033[36m  timing_warning_parser.py -o <output_dir> <log_dir>  # specify output dir\033[0m")
    print("\033[36m  timing_warning_parser.py -h                         # help\033[0m")


def validate_json_file(json_path: str) -> dict:
    """Load and validate JSON configuration file."""
    if not json_path:
        return None
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        logger.info(f"json_path is {json_path}")
        return config
    except json.JSONDecodeError:
        logger.error(f"\033[1;31mError-[Invalid JSON] {json_path} is not valid JSON.\033[0m")
        raise ValueError(f'{json_path} is invalid')
    except FileNotFoundError:
        logger.error(f"\033[1;31mError-[File not Found] Config file '{json_path}' not found.\033[0m")
        raise FileNotFoundError(f'{json_path} does not exist')


# === Entry point ============================================================

if __name__ == "__main__":
    status_code, action, json_path, log_dir, output_dir = parse_arguments()
    if status_code != 0:
        sys.exit(status_code)

    config = validate_json_file(json_path)

    start_time = time.time()
    sim_warning_result, timing_violation_result = process_simulation_logs(
        action, log_dir, config, output_dir)
    end_sim_time = time.time()
    warning_result = process_compilation_logs(action, log_dir, config, output_dir)
    end_comp_time = time.time()

    # Terminal summary output
    if action in ("both", "sim"):
        logger.info(f"\033[1;32mSimulation Analysis Time: {end_sim_time - start_time:.2f} s\033[0m")
        if not sim_warning_result:
            logger.info("\033[1;33mWarning-[Result Empty] No simulation warnings found\033[0m")
        else:
            logger.info("\033[1;36m************************Sim Warning Summary************************\033[0m")
            _, sim_warning_lines = summarize_warning(sim_warning_result)
        if not timing_violation_result:
            logger.info("\033[1;33mWarning-[Result Empty]: No simulation timing violations found.\033[0m")
        else:
            logger.info("\033[1;36m************************Sim Violations Summary************************\033[0m")
            _, vio_lines = summarize_vio(timing_violation_result)

    if action in ("both", "comp"):
        logger.info(f"\033[1;32mCompile Analysis Time: {end_comp_time - end_sim_time:.2f} s\033[0m")
        if not warning_result:
            logger.info("\033[1;31mWarning: No compilation warnings found.\033[0m")
        else:
            logger.info("\033[1;36m************************Comp Warning Summary************************\033[0m")
            _, comp_warning_lines = summarize_warning(warning_result)

    # Write summary file
    summary_lines = []
    if action in ("both", "sim"):
        if sim_warning_result:
            summary_lines.append("************************Sim Warning Summary************************")
            summary_lines.extend(sim_warning_lines)
        if timing_violation_result:
            summary_lines.append("************************Sim Violations Summary************************")
            summary_lines.extend(vio_lines)
    if action in ("both", "comp"):
        if warning_result:
            summary_lines.append("************************Comp Warning Summary************************")
            summary_lines.extend(comp_warning_lines)

    if summary_lines:
        summary_path = os.path.join(output_dir, "filtered_summary.txt")
        with open(summary_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(summary_lines))

    # Print generated files
    logger.info(f"\n\033[1;32mGenerated files:\033[0m")
    for fname in ["filtered_warnings_in_sim.txt", "filtered_timing_violations.txt",
                   "filtered_warnings.txt", "filtered_summary.txt"]:
        fpath = os.path.join(output_dir, fname)
        if os.path.exists(fpath):
            logger.info(f"  {fname}: {os.path.abspath(fpath)}")

    # FIX: meaningful exit codes
    has_violations = len(timing_violation_result) > 0
    has_warnings = len(sim_warning_result) > 0 or len(warning_result) > 0
    if has_violations:
        sys.exit(1)
    elif has_warnings:
        sys.exit(2)
    else:
        sys.exit(0)
