#!/usr/bin/env python3
# FILE NAME      : reg_gen.py
# DEPARTMENT     : Digital Verification Department
# AUTHOR         : xiayu
# AUTHOR'S EMAIL : xiayu@chipsea.com
# ABSTRACT       : Register data model (Field/Register), validation, array expansion,
#                  and Jinja2 template rendering utilities.
#
#-------------------------------------------------------------------------

import json
import ast
import os
import math
import re
import sys
import warnings
import getpass
import subprocess
from jinja2 import Environment, FileSystemLoader

# ---------------------------------------------------------------------------
# Utility: clean special characters from names
# ---------------------------------------------------------------------------
def clean_name(value, context=""):
    """Remove special characters (*, #, ~, newline, tab) from a name string.
    Prints a warning if any characters were actually removed."""
    if not isinstance(value, str):
        return value
    cleaned = re.sub(r'[*#~\n\r\t]', '', value).strip()
    if cleaned != value and context:
        warnings.warn(
            f"\033[1;33m[Name Cleaned] {context}: '{value}' -> '{cleaned}' "
            f"(removed special characters)\033[0m", UserWarning)
    return cleaned

# ---------------------------------------------------------------------------
# Utility: safe math expression evaluator (replaces eval)
# ---------------------------------------------------------------------------
def safe_eval_expr(expr_str):
    """Safely evaluate a simple arithmetic expression containing only
    digits, whitespace, and +-*/ operators. Uses ast.literal_eval for
    pure numbers, or validates the pattern before eval."""
    expr_str = expr_str.strip()
    # Pure number fast path
    try:
        return int(expr_str)
    except ValueError:
        pass
    # Allow only safe characters: digits, spaces, +, -, *, /
    if not re.match(r'^[\d\s\+\-\*\/\(\)]+$', expr_str):
        raise ValueError(f"Unsafe expression rejected: '{expr_str}'")
    # Use AST-based evaluation for safety
    try:
        tree = ast.parse(expr_str, mode='eval')
        # Walk AST to ensure only numeric operations
        for node in ast.walk(tree):
            if isinstance(node, (ast.Expression, ast.BinOp, ast.UnaryOp,
                                 ast.Num, ast.Constant, ast.Add, ast.Sub,
                                 ast.Mult, ast.Div, ast.USub, ast.UAdd)):
                continue
            raise ValueError(f"Disallowed AST node: {type(node).__name__}")
        return eval(compile(tree, '<safe_eval>', 'eval'))
    except Exception as e:
        raise ValueError(f"Failed to evaluate expression '{expr_str}': {e}")

# ===========================================================================
# Field class - represents a single bit-field within a register
# ===========================================================================
class Field:
    """Represents a single field (bit-range) inside a register."""

    VALID_ATTRIBUTES = ("RW", "RO", "WO", "RC_W1", "RC_W0", "RC_R", "RS")

    def __init__(self, ip_name, reg_name, field_name, bits,
                 field_attribute, field_reset_value):
        self.ip_name = clean_name(ip_name)
        self.reg_name = clean_name(reg_name, "Reg name in Field")
        self.field_name = (clean_name(field_name, f"Reg {reg_name} Field name")
                           if isinstance(field_name, str)
                           else str(field_name).replace(" ", ""))
        self.bits = bits
        # Validate and sanitize string fields
        self.field_attribute = self._validate_field_str(
            field_attribute, "Field Attribute", ip_name, reg_name, field_name)
        self.field_reset_value = self._validate_field_str(
            field_reset_value, "Field Reset Value", ip_name, reg_name, field_name)
        # Parse bit range and handle X in reset value
        self.start_bit, self.end_bit = self.parse_bits()
        self.get_field_reset_value_str()

    @staticmethod
    def _validate_field_str(value, col_name, ip_name, reg_name, field_name):
        """Validate that a field cell value is a proper string.
        Returns empty string for None, str(value) for non-str types."""
        if value is None:
            warnings.warn(
                f"\033[1;31m[Empty Value] {ip_name} Reg {reg_name} "
                f"Field {field_name}: '{col_name}' is empty in Excel, "
                f"please fill in the corresponding cell\033[0m", UserWarning)
            return ""
        if not isinstance(value, str):
            warnings.warn(
                f"\033[1;31m[Type Error] {ip_name} Reg {reg_name} "
                f"Field {field_name}: '{col_name}' value '{value}' is not "
                f"a string (type={type(value).__name__}), "
                f"please check Excel cell format\033[0m", UserWarning)
            return str(value)
        return value.replace(" ", "")

    # --- Validation methods ------------------------------------------------

    def validate_field_wrapper(self):
        """Run all field-level validations."""
        self.start_bit, self.end_bit = self.parse_bits()
        self.validate_bits()
        self.validate_field_name()
        self.validate_field_attribute()

    def validate_field_attribute(self):
        """Check field attribute is one of the valid access types."""
        if self.field_attribute is None:
            warnings.warn(
                f"\033[1;31m{self.ip_name} {self.reg_name}: field attribute "
                f"for {self.field_name} is None\033[0m", UserWarning)
            return
        if " " in self.field_attribute:
            warnings.warn(
                f"\033[1;31m{self.ip_name} {self.reg_name}: field attribute "
                f"for {self.field_name} contains space: "
                f"'{self.field_attribute}'\033[0m", UserWarning)
        if self.field_attribute.strip() not in self.VALID_ATTRIBUTES:
            warnings.warn(
                f"\033[1;31m{self.ip_name} {self.reg_name}: field attribute "
                f"out of range for {self.field_name}, "
                f"got '{self.field_attribute}'\033[0m", UserWarning)

    def validate_field_name(self):
        """Normalize field name to lowercase."""
        self.field_name = self.field_name.lower()

    def validate_bits(self):
        """Validate the bit-range string format (e.g. '31:0', '5', '7:3')."""
        b = str(self.bits).strip().replace(" ", "")
        if '\uff1a' in b:
            b = b.replace('\uff1a', ':')
        if ':' in b:
            p = b.split(':')
            if len(p) != 2 or not all(x.isdigit() for x in p):
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Reg {self.reg_name}: "
                    f"invalid bit format (high:low), "
                    f"got '{self.bits}' in {self.field_name}\033[0m",
                    UserWarning)
                return False
            h, l = map(int, p)
            if h < l or l < 0:
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Reg {self.reg_name}: "
                    f"high>=low and low>=0 required, "
                    f"got '{self.bits}' in {self.field_name}\033[0m",
                    UserWarning)
                return False
            return True
        # Single-bit format: must be a non-negative digit string
        if not b.isdigit():
            warnings.warn(
                f"\033[1;31m{self.ip_name} Reg {self.reg_name}: "
                f"non-negative integer required, "
                f"got '{self.bits}' in {self.field_name}\033[0m",
                UserWarning)
            return False
        return True

    def parse_bits(self):
        """Parse bit-range string into (low, high) tuple.
        Returns (0, 0) on parse failure to avoid NoneType errors."""
        bits_str = str(self.bits).strip()
        if '\uff1a' in bits_str:
            bits_str = bits_str.replace('\uff1a', ':')
        if ':' in bits_str:
            try:
                high, low = map(int, bits_str.split(':'))
                return (low, high)
            except ValueError:
                warnings.warn(
                    f"\033[1;31m[Value Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} field {self.field_name}: "
                    f"bits '{self.bits}' is invalid\033[0m", UserWarning)
                return (0, 0)
        else:
            try:
                bit = int(bits_str)
                return (bit, bit)
            except ValueError:
                warnings.warn(
                    f"\033[1;31m[Value Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} field {self.field_name}: "
                    f"bits '{self.bits}' is invalid\033[0m", UserWarning)
                return (0, 0)

    # --- Computation methods -----------------------------------------------

    def get_field_size(self):
        """Return the bit-width of this field."""
        return self.end_bit - self.start_bit + 1

    def get_field_msk(self):
        """Return the bit-mask for this field."""
        bit_width = self.end_bit - self.start_bit + 1
        return (1 << bit_width) - 1

    def get_field_reset_value_int(self):
        """Return field reset value as integer. Returns 0 for empty strings."""
        if not self.field_reset_value:
            return 0
        try:
            return int(self.field_reset_value, 16)
        except ValueError:
            return 0

    def get_field_reset_value_str(self):
        """Replace 'X'/'x' in reset value with '0' and log the replacement."""
        matchNA = re.match(r'^0[xX].*[Xx].*', self.field_reset_value, re.I)
        if matchNA:
            old_val = self.field_reset_value
            self.field_reset_value = re.sub(r'[Xx]', '0', self.field_reset_value)
            print(f"\033[1;33m[Reset Value 'X' Replaced] {self.ip_name} "
                  f"Reg {self.reg_name} Field {self.field_name}: "
                  f"'{old_val}' -> '{self.field_reset_value}', "
                  f"please verify with design\033[0m")
        return self.field_reset_value

    def __str__(self):
        return (f"Reg {self.reg_name} Field(field_name='{self.field_name}', "
                f"bits='{self.bits}', field_attribute='{self.field_attribute}', "
                f"field_reset_value='{self.field_reset_value}')")


# ===========================================================================
# Register class - represents a single register with its fields
# ===========================================================================
class Register:
    """Represents a hardware register containing one or more fields."""

    def __init__(self, ip_name, reg_name, address_offset, reset_value,
                 fields, read_mode, write_mode, reset_field,
                 register_num, order_offset, bus_size=32):
        self.ip_name = clean_name(ip_name)
        self.reg_name = (clean_name(reg_name, "Register name")
                         if isinstance(reg_name, str)
                         else str(reg_name).replace(" ", ""))
        self.address_offset = address_offset
        self.reset_value = self._validate_reg_str(
            reset_value, "Reset_Value", ip_name, reg_name)
        self.fields = fields
        self.read_mode = read_mode
        self.write_mode = write_mode
        self.reset_field = reset_field
        self.register_num = register_num
        self.order_offset = order_offset

        # Calculate actual bus size from the highest field bit
        self.bus_bits = 0
        for field in self.fields:
            if field.end_bit > self.bus_bits:
                self.bus_bits = field.end_bit
        self.bus_size = self.bus_bits + 1

    @staticmethod
    def _validate_reg_str(value, col_name, ip_name, reg_name):
        """Validate register-level string cell value."""
        if value is None:
            warnings.warn(
                f"\033[1;31m[Empty Value] {ip_name} Reg {reg_name}: "
                f"'{col_name}' is empty in Excel\033[0m", UserWarning)
            return "0x0"
        if not isinstance(value, str):
            warnings.warn(
                f"\033[1;31m[Type Error] {ip_name} Reg {reg_name}: "
                f"'{col_name}' value '{value}' is not a string "
                f"(type={type(value).__name__})\033[0m", UserWarning)
            return str(value).replace(" ", "")
        return value.replace(" ", "")

    # --- Validation methods ------------------------------------------------

    def validate_register_wrapper(self, rsv_ro_attr_chk):
        """Run all register-level validations in sequence."""
        self.reset_value = self.get_reg_reset_val()
        self.validate_register_name()
        self.validate_addr_offset()
        self.validate_value()
        self.validate_field_names(rsv_ro_attr_chk)
        self.validate_field_index()
        self.validate_reset_consistency()
        # Normalize access mode strings
        if self.read_mode is not None:
            self.read_mode = self.read_mode.replace(" ", "").replace(",", "_")
        if self.write_mode is not None:
            self.write_mode = self.write_mode.replace(" ", "").replace(",", "_")
        if self.reset_field is not None:
            self.validate_reset_field_chk()
        # [FIX #1] Check both read_mode and write_mode (was checking write_mode twice)
        if self.read_mode is not None or self.write_mode is not None:
            self.validate_access_mode()
        self.get_register_address_offset_value_int()
        for field in self.fields:
            field.validate_field_wrapper()

    def get_reg_reset_val(self):
        """Replace X/x in register reset value with 0 and log it."""
        matchNA = re.match(r'^0[xX].*[Xx].*', self.reset_value, re.I)
        if matchNA:
            old_val = self.reset_value
            self.reset_value = re.sub(r'[Xx]', '0', self.reset_value)
            print(f"\033[1;33m[Reset Value 'X' Replaced] {self.ip_name} "
                  f"Reg {self.reg_name}: reset_value '{old_val}' -> "
                  f"'{self.reset_value}', please verify with design\033[0m")
        return self.reset_value

    def validate_addr_offset(self):
        """Strip whitespace and newlines from address offset."""
        if isinstance(self.address_offset, str):
            self.address_offset = (self.address_offset
                                   .replace(" ", "").replace("\n", ""))

    def validate_register_name(self):
        """Warn if register name contains newline characters."""
        if isinstance(self.reg_name, str) and "\n" in self.reg_name:
            warnings.warn(
                f"\033[1;31m{self.ip_name} Reg '{self.reg_name}' "
                f"(offset '{self.address_offset}') contains newline\033[0m",
                UserWarning)

    def validate_value(self):
        """Validate hex format of reset value and address offset."""
        values_to_check = [self.reset_value, self.address_offset]
        for field in self.fields:
            values_to_check.append(field.field_reset_value.replace(" ", ""))
        for temp_value in values_to_check:
            if not isinstance(temp_value, str):
                continue
            if not (temp_value.startswith(("0x", "0X")) and " " not in temp_value):
                warnings.warn(
                    f"\033[1;31m[Value Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} offset '{self.address_offset}': "
                    f"'{temp_value}' must start with 0x/0X with no spaces\033[0m",
                    UserWarning)
            try:
                int(temp_value, 16)
            except ValueError:
                warnings.warn(
                    f"\033[1;31m[Value Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} offset '{self.address_offset}': "
                    f"'{temp_value}' cannot be parsed as hex\033[0m",
                    UserWarning)

    def validate_field_names(self, rsv_ro_attr_chk):
        """Validate all field names: pattern check, reserved attribute check."""
        valid_pattern = re.compile(r'^[a-zA-Z0-9_]+$')
        for field in self.fields:
            name = field.field_name
            if not isinstance(name, str):
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Field name '{name}' "
                    f"is not a string\033[0m", UserWarning)
                continue
            if "\n" in name:
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                    f"field '{name}' contains newline\033[0m", UserWarning)
            # Reserved fields must have RO attribute
            if rsv_ro_attr_chk:
                if (name.lower() == 'reserved'
                        and field.field_attribute != 'RO'):
                    warnings.warn(
                        f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                        f"offset '{self.address_offset}': reserved field "
                        f"'{name}' bits '{field.bits}' attribute is not RO\033[0m",
                        UserWarning)
            if not valid_pattern.match(name):
                warnings.warn(
                    f"\033[1;31m[Name Invalid] {self.ip_name} Reg "
                    f"{self.reg_name} offset '{self.address_offset}': "
                    f"field '{field.field_name}' contains invalid characters "
                    f"(allowed: [a-zA-Z0-9_])\033[0m", UserWarning)

    def validate_reset_field_chk(self):
        """Validate and normalize the reset domain field name."""
        if self.reset_field is None:
            warnings.warn(
                f"\033[1;31m[Reset Field Invalid] {self.ip_name} "
                f"Reg {self.reg_name} offset '{self.address_offset}': "
                f"reset field is None\033[0m", UserWarning)
            return
        if not isinstance(self.reset_field, str):
            if isinstance(self.reset_field, float) and math.isnan(self.reset_field):
                warnings.warn(
                    f"\033[1;31m[Reset Field Invalid] {self.ip_name} "
                    f"Reg {self.reg_name}: reset field is NaN\033[0m",
                    UserWarning)
                return
            self.reset_field = str(self.reset_field)
        self.reset_field = self.reset_field.replace(" ", "_").replace("\n", "_")

    def validate_field_index(self):
        """Check bit-range legality: no overlap, no gaps, no out-of-bounds."""
        used_bits = set()
        for field in self.fields:
            bits_str = str(field.bits).strip()
            if '\uff1a' in bits_str:
                bits_str = bits_str.replace('\uff1a', ':')
            if ':' in bits_str:
                high_str, low_str = bits_str.split(':')
                high, low = int(high_str), int(low_str)
                start_bit, end_bit = low, high
            else:
                start_bit = end_bit = int(bits_str)
            # Range boundary check
            if not (0 <= start_bit <= end_bit < self.bus_size):
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                    f"offset '{self.address_offset}': bit range "
                    f"{start_bit}-{end_bit} exceeds {self.bus_size}-bit "
                    f"boundary\033[0m")
                return False
            # Duplicate bit check
            for bit in range(start_bit, end_bit + 1):
                if bit in used_bits:
                    warnings.warn(
                        f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                        f"offset '{self.address_offset}': field "
                        f"{field.field_name} has duplicate bit {bit}\033[0m")
                    return False
                used_bits.add(bit)
        # Completeness check: all bits must be covered
        all_bits = set(range(self.bus_size))
        if used_bits != all_bits:
            missing = all_bits - used_bits
            warnings.warn(
                f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                f"offset '{self.address_offset}': missing bits "
                f"{missing}\033[0m")
            return False
        return True

    def validate_reset_consistency(self):
        """Verify that combined field reset values equal the register reset value."""
        combined_reset = 0
        for field in self.fields:
            bits = str(field.bits).strip()
            if '\uff1a' in bits:
                bits = bits.replace('\uff1a', ':')
            if ":" in bits:
                high, low = map(int, bits.split(":"))
                start, end = low, high
            else:
                start = end = int(bits)
            bit_width = end - start + 1
            max_value = (1 << bit_width) - 1
            try:
                field_rst = int(field.field_reset_value, 16)
            except ValueError:
                warnings.warn(
                    f"\033[1;31m[Value Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} offset '{self.address_offset}': "
                    f"field {field.field_name} reset value "
                    f"'{field.field_reset_value}' is invalid\033[0m")
                return False
            if field_rst < 0 or field_rst > max_value:
                warnings.warn(
                    f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                    f"offset '{self.address_offset}': field "
                    f"{field.field_name} reset value {field_rst} "
                    f"exceeds max {max_value}\033[0m")
                return False
            combined_reset |= (field_rst << start)
        try:
            reg_reset_value = int(self.reset_value.strip(), 16)
        except ValueError:
            warnings.warn(
                f"\033[1;31m[Value Format Error] {self.ip_name} "
                f"Reg {self.reg_name} offset '{self.address_offset}': "
                f"register reset value '{self.reset_value}' is invalid\033[0m")
            return False
        if combined_reset != reg_reset_value:
            warnings.warn(
                f"\033[1;31m{self.ip_name} Reg {self.reg_name} "
                f"offset '{self.address_offset}': reset value mismatch: "
                f"expected {self.reset_value}, "
                f"got {combined_reset:#x}\033[0m")
            return False
        return True

    def validate_access_mode(self):
        """Validate read/write access mode format (e.g. U, SV, SE)."""
        valid_pattern = re.compile(r'^\w+$')
        if self.write_mode is not None:
            if not valid_pattern.fullmatch(self.write_mode):
                warnings.warn(
                    f"\033[1;31m[Access Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} offset '{self.address_offset}': "
                    f"invalid write access mode '{self.write_mode}', "
                    f"expected e.g. U, SV, SE\033[0m")
        if self.read_mode is not None:
            if not valid_pattern.fullmatch(self.read_mode):
                warnings.warn(
                    f"\033[1;31m[Access Format Error] {self.ip_name} "
                    f"Reg {self.reg_name} offset '{self.address_offset}': "
                    f"invalid read access mode '{self.read_mode}', "
                    f"expected e.g. U, SV, SE\033[0m")

    def calculate_reg_mask(self, rsv_ro_attr_chk):
        """Calculate the writable mask of a register."""
        reg_mask = 0
        for field in self.fields:
            if rsv_ro_attr_chk and field.field_name.lower() == "reserved":
                continue
            if field.field_attribute in ("RO", "WO", "RC_W1", "RC_W0", "RC_R", "RS"):
                continue
            if field.start_bit > field.end_bit:
                raise ValueError(
                    f"Field {field.field_name} invalid range: "
                    f"start({field.start_bit}) > end({field.end_bit})")
            if field.start_bit < 0 or field.end_bit < 0:
                raise ValueError(
                    f"Field {field.field_name} has negative bits: "
                    f"{field.start_bit}-{field.end_bit}")
            bit_length = field.end_bit - field.start_bit + 1
            field_mask = ((1 << bit_length) - 1) << field.start_bit
            reg_mask |= field_mask
        return reg_mask

    def get_register_reset_value_int(self):
        """Return register reset value as integer."""
        return int(self.reset_value, 16)

    def get_register_address_offset_value_int(self):
        """Return address offset as integer.
        Handles array register format '0xP + 0xQ*(n:a..b)' gracefully."""
        try:
            self.address_offset_value_int = int(self.address_offset, 16)
        except ValueError:
            # Array register offset format: extract base address
            match = re.match(r'^0x([0-9A-Fa-f]+)', self.address_offset)
            if match:
                self.address_offset_value_int = int(match.group(1), 16)
            else:
                self.address_offset_value_int = 0
        return self.address_offset_value_int

    def __str__(self):
        fields_str = "\n".join(f"  {field}" for field in self.fields)
        return (f"Register(ip='{self.ip_name}', reg='{self.reg_name}', "
                f"offset='{self.address_offset}', "
                f"read_mode={self.read_mode}, write_mode={self.write_mode}, "
                f"register_num={self.register_num}, "
                f"order_offset={self.order_offset}, "
                f"reset_field={self.reset_field}, "
                f"fields=\n{fields_str})")


# ===========================================================================
# JSON parsing and object construction
# ===========================================================================

def load_json_data(json_path):
    """Load and return JSON data from a file."""
    try:
        with open(json_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: file not found: {json_path}")
        return None
    except json.JSONDecodeError:
        print(f"Error: JSON parse error in {json_path}")
        return None

def parse_obj_from_json(json_obj, parse_obj_config):
    """Convert parsed JSON list into Register/Field object list."""
    register_obj_group = []
    for item in json_obj:
        fields = []
        for field in item.get("field_group", []):
            fields.append(Field(
                ip_name=parse_obj_config["ip_name"],
                reg_name=item.get(parse_obj_config["reg_name"]),
                field_name=field.get(parse_obj_config["field_name"]),
                bits=field.get(parse_obj_config["field_bits"]),
                field_attribute=field.get(parse_obj_config["field_access"]),
                field_reset_value=field.get(parse_obj_config["field_reset_value"])
            ))
        register = Register(
            ip_name=parse_obj_config["ip_name"],
            reg_name=item.get(parse_obj_config["reg_name"]),
            address_offset=item.get(parse_obj_config["reg_addr"]),
            reset_value=item.get(parse_obj_config["reg_reset_value"]),
            read_mode=item.get(parse_obj_config["rd_access_mode"]),
            write_mode=item.get(parse_obj_config["wr_access_mode"]),
            reset_field=item.get(parse_obj_config["reset_field"]),
            register_num=item.get(parse_obj_config["register_num"]),
            order_offset=item.get(parse_obj_config["order_offset"]),
            fields=fields
        )
        register_obj_group.append(register)
    return register_obj_group


# ===========================================================================
# Jinja2 template rendering utilities
# ===========================================================================

def custom_ljust(value, total_length=30, fill_char=' '):
    """Jinja2 filter: left-justify a string with custom fill character."""
    str_value = str(value)
    fill_count = max(0, total_length - len(str_value))
    return str_value + fill_char * fill_count

def get_template_inst(template_path):
    """Load a Jinja2 template from the given file path."""
    template_dir_path = os.path.dirname(template_path)
    env = Environment(loader=FileSystemLoader(template_dir_path))
    env.filters['custom_ljust'] = custom_ljust
    template = env.get_template(os.path.basename(template_path))
    return template


# ===========================================================================
# Array register / field expansion
# ===========================================================================

def process_json_field_name(input_data, parse_obj_config):
    """Expand indexed field names like 'PCLx(x=0-15)' into individual fields.
    [FIX #2] Use field_name key (not reg_reset_value) for name matching.
    [FIX #8] Use safe_eval_expr instead of eval() for bit calculations."""
    result = []
    for reg in input_data:
        new_reg = reg.copy()
        new_fields = []

        reg_reset = reg.get(parse_obj_config["reg_reset_value"], '0x0')
        if reg_reset is None:
            warnings.warn(
                f"\033[1;31mRegister reset value is None for "
                f"{reg.get(parse_obj_config['reg_name'])}\033[0m")
        else:
            reg_reset = reg.get(
                parse_obj_config["reg_reset_value"], '0x0').replace(" ", "")

        for field in reg.get('field_group', []):
            field_name_val = field.get(parse_obj_config["field_name"], '')
            if not isinstance(field_name_val, str):
                warnings.warn(
                    f"\033[1;31mField name is not string: "
                    f"{field_name_val}\033[0m")
                field_name_val = str(field_name_val)
            # [FIX #2] Match against field name, not reset value
            name_match = re.match(
                r'^([A-Z0-9_]+)x([A-Z0-9_]*)\(x=(\d+)-(\d+)\)$',
                field_name_val)
            if not name_match:
                new_fields.append(field)
                continue
            prefix1, prefix2, x1, x2 = name_match.groups()
            x_max, x_min = max(int(x1), int(x2)), min(int(x1), int(x2))

            for x in range(x_max, x_min - 1, -1):
                bits_str = field.get(parse_obj_config["field_bits"], '')
                hb = lb = 0
                if 'x' in bits_str:
                    if ':' in bits_str:
                        l, r = bits_str.split(':')
                        hb = max(safe_eval_expr(l.replace('x', str(x))),
                                 safe_eval_expr(r.replace('x', str(x))))
                        lb = min(safe_eval_expr(l.replace('x', str(x))),
                                 safe_eval_expr(r.replace('x', str(x))))
                    else:
                        hb = lb = safe_eval_expr(bits_str.replace('x', str(x)))
                else:
                    if ':' in bits_str:
                        l, r = bits_str.split(':')
                        span = abs(int(l) - int(r))
                        step = span // (x_max - x_min) if x_max != x_min else 1
                        lb = min(int(l), int(r)) + x * step
                        hb = lb + step - 1

                bits = str(hb) if hb == lb else f"{hb}:{lb}"

                reset_val = field.get(parse_obj_config["field_reset_value"], '')
                if reset_val == '/':
                    reg_val = int(reg_reset.replace('_', ''), 16)
                    mask = (1 << (hb - lb + 1)) - 1
                    reset_val = f"0x{((reg_val >> lb) & mask):X}"

                new_fields.append({
                    'Field Name': f"{prefix1}{x}{prefix2}",
                    'Bits': bits,
                    'Field Attribute': field.get(
                        parse_obj_config["field_access"], ''),
                    'Field Reset Value': str(reset_val)
                })
        new_reg['field_group'] = new_fields
        result.append(new_reg)
    return result

def get_reset_type_list(data):
    """Extract unique reset domain names from register list."""
    reset_list = []
    for register in data:
        if register.reset_field and register.reset_field.upper() not in reset_list:
            reset_list.append(register.reset_field.upper())
    return reset_list

def expand_registers(input_data, parse_obj_config, register_array_en):
    """Expand array register names like 'REGn' with offset '0xP + 0xQ*(n:a..b)'
    into individual registers or keep as array descriptor."""
    new_data = []
    name_pattern = re.compile(r'^([a-zA-Z0-9_]+)n([A-Z0-9_]*)$')
    offset_pattern = re.compile(
        r'^0x([0-9A-Fa-f]+)\s*\+\s*0x([0-9A-Fa-f]+)\s*\*\s*\(n:(\d+)\.\.(\d+)\)$')

    ip_name = parse_obj_config["ip_name"]
    name_key = parse_obj_config["reg_name"]
    offset_key = parse_obj_config["reg_addr"]

    input_data = process_json_field_name(input_data, parse_obj_config)

    for reg in input_data:
        if not isinstance(reg, dict):
            new_data.append(reg)
            continue

        reg_name = reg.get(name_key, 'UNKNOWN')
        reg_offset = reg.get(offset_key, '')

        # Validate name format for potential array registers
        if ('(' in reg_name or ')' in reg_name):
            if not name_pattern.match(reg_name):
                warnings.warn(
                    f"Invalid format for Sheet {ip_name} {name_key} "
                    f"'{reg_name}' {reg_offset}: "
                    f"requires 'PREFIXn' format")
                new_data.append(reg)
                continue

        name_match = name_pattern.match(reg_name)
        if not name_match:
            new_data.append(reg)
            continue

        prefix1, prefix2 = name_match.groups()

        if not offset_pattern.match(reg_offset):
            new_data.append(reg)
            continue

        p_hex, q_hex, a_off, b_off = offset_pattern.match(reg_offset).groups()
        try:
            a_off, b_off = int(a_off), int(b_off)
        except ValueError:
            warnings.warn(
                f"Invalid range in {offset_key} for Sheet {ip_name} "
                f"'{reg_name}': {a_off}..{b_off}")
            new_data.append(reg)
            continue

        a, b = a_off, b_off
        register_num = b + 1 - a
        p, q = int(p_hex, 16), int(q_hex, 16)

        if register_array_en:
            # Keep as single array descriptor
            try:
                new_reg = reg.copy()
                new_reg[name_key] = f"{prefix1}"
                new_reg["Register num"] = f"{register_num}"
                new_reg["Order offset"] = f"0x{q_hex}"
                new_reg[offset_key] = f"0x{p_hex}"
                new_data.append(new_reg)
            except Exception as e:
                warnings.warn(f"Expansion failed for '{reg_name}': {e}")
                new_data.append(reg)
        else:
            # Expand into individual registers
            try:
                for n in range(a, b + 1):
                    new_reg = reg.copy()
                    new_reg[name_key] = f"{prefix1}{n}{prefix2}"
                    new_reg[offset_key] = f"0x{(p + q * n):X}"
                    new_data.append(new_reg)
            except Exception as e:
                warnings.warn(f"Expansion failed for '{reg_name}': {e}")
                new_data.append(reg)

    return new_data


# ===========================================================================
# Warning counter (used to abort on Excel errors)
# ===========================================================================

def count_warnings(message, category, filename, lineno, file=None, line=None):
    """Custom warning handler that counts warnings and prints them."""
    print(f"Warning: {message} in {filename}:{lineno}")
    count_warnings.counter += 1
