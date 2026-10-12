#!/bin/bash
# Automated test suite for timing_warning_parser.py
# Tests various filtering scenarios using local_log.log

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARSER="$SCRIPT_DIR/../timing_warning_parser.py"
TEST_DIR="$SCRIPT_DIR"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

run_test() {
    local test_name="$1"
    local filter_json="$2"
    local expected_vio_count="$3"
    local expected_warn_count="$4"
    local output_dir="$TEST_DIR/test_output_$$"
    
    mkdir -p "$output_dir"
    
    # Run parser (ignore exit code from parser)
    python3 "$PARSER" -s -f "$filter_json" -o "$output_dir" "$TEST_DIR" > /dev/null 2>&1 || true
    
    # Count violations in summary
    local actual_vio_count=0
    local actual_warn_count=0
    if [ -f "$output_dir/filtered_summary.txt" ]; then
        if grep -q "Violations Summary" "$output_dir/filtered_summary.txt"; then
            actual_vio_count=$(grep "^signal:" "$output_dir/filtered_summary.txt" | awk '{sum += $NF} END {print sum+0}')
        fi
        if grep -q "Warning Summary" "$output_dir/filtered_summary.txt"; then
            actual_warn_count=$(grep "^warning_type:" "$output_dir/filtered_summary.txt" | awk '{sum += $NF} END {print sum+0}')
        fi
    fi
    
    # Check results
    local test_pass=true
    if [ "$actual_vio_count" -ne "$expected_vio_count" ]; then
        test_pass=false
    fi
    if [ "$actual_warn_count" -ne "$expected_warn_count" ]; then
        test_pass=false
    fi
    
    if $test_pass; then
        echo -e "${GREEN}[PASS]${NC} $test_name (vio=$actual_vio_count, warn=$actual_warn_count)"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $test_name (expected vio=$expected_vio_count warn=$expected_warn_count, got vio=$actual_vio_count warn=$actual_warn_count)"
        FAIL=$((FAIL + 1))
    fi
    
    rm -rf "$output_dir"
}

echo "=========================================="
echo "  Timing Warning Parser - Test Suite"
echo "=========================================="
echo ""

# Test 1: No filtering - all 9 violations should remain
cat > "$TEST_DIR/test_no_filter.json" << 'EOF'
{
    "comp_log_pattern": [],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [],
    "file_and_line": [],
    "violation_start_limit_global": "-1",
    "cross_match": [],
    "warning_type": [],
    "cross_match_warning": [],
    "first_ignore_line": []
}
EOF
run_test "No filter: all 9 violations pass" "$TEST_DIR/test_no_filter.json" 9 0

# Test 2: Filter by signal pattern (regex fullmatch)
cat > "$TEST_DIR/test_signal_filter.json" << 'EOF'
{
    "comp_log_pattern": [],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [
        "top.u_chip.top.u_sysbus.rst_ctrl.U_DFTOccIP.\\d+.U_DFTClkMuxIP.\\d+.async_bist_data_\\d+_reg"
    ],
    "file_and_line": [],
    "violation_start_limit_global": "-1",
    "cross_match": [],
    "warning_type": [],
    "cross_match_warning": [],
    "first_ignore_line": []
}
EOF
run_test "Signal filter: 2 async_bist_data filtered" "$TEST_DIR/test_signal_filter.json" 7 0

# Test 3: Cross-match filter (path + line + signal)
cat > "$TEST_DIR/test_cross_match.json" << 'EOF'
{
    "comp_log_pattern": [],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [],
    "file_and_line": [],
    "violation_start_limit_global": "-1",
    "cross_match": [
        {
            "path": "sc9mc_40nmLP_base_lvt_c50.v",
            "line_num": 145704,
            "timing_violation_signal": "top.u_chip.top.u_sysbus.core_occ_ctrl_local.U_DFTOccIP.0.U_DFTClkMuxIP.0.clk_bist_data_\\d+_reg"
        }
    ],
    "warning_type": [],
    "cross_match_warning": [],
    "first_ignore_line": []
}
EOF
run_test "Cross-match: 3 violations filtered" "$TEST_DIR/test_cross_match.json" 6 0

# Test 4: file_and_line filter
cat > "$TEST_DIR/test_file_line.json" << 'EOF'
{
    "comp_log_pattern": [],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [],
    "file_and_line": [
        { "path": "sc9mc_40nmLP_base_lvt_c50.v", "line_num": -1 }
    ],
    "violation_start_limit_global": "-1",
    "cross_match": [],
    "warning_type": [],
    "cross_match_warning": [],
    "first_ignore_line": []
}
EOF
run_test "File+line filter: all from same file filtered" "$TEST_DIR/test_file_line.json" 0 0

# Test 5: Output directory option
cat > "$TEST_DIR/test_odir.json" << 'EOF'
{
    "comp_log_pattern": [],
    "sim_log_pattern": [".*.log$"],
    "timing_violation_signal": [],
    "file_and_line": [],
    "violation_start_limit_global": "-1",
    "cross_match": [],
    "warning_type": [],
    "cross_match_warning": [],
    "first_ignore_line": []
}
EOF
mkdir -p "$TEST_DIR/test_output_dir_$$"
python3 "$PARSER" -s -f "$TEST_DIR/test_odir.json" -o "$TEST_DIR/test_output_dir_$$" "$TEST_DIR" > /dev/null 2>&1 || true
if [ -f "$TEST_DIR/test_output_dir_$$/filtered_timing_violations.txt" ]; then
    echo -e "${GREEN}[PASS]${NC} Output dir option: files created in specified dir"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Output dir option: files not found in specified dir"
    FAIL=$((FAIL + 1))
fi
rm -rf "$TEST_DIR/test_output_dir_$$"

# Test 6: Exit code - violations present (exit code should be 1)
python3 "$PARSER" -s -f "$TEST_DIR/test_odir.json" -o "$TEST_DIR/test_exit_$$" "$TEST_DIR" > /dev/null 2>&1
ec=$?
if [ "$ec" -eq 1 ]; then
    echo -e "${GREEN}[PASS]${NC} Exit code: 1 when violations present"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Exit code: expected 1, got $ec"
    FAIL=$((FAIL + 1))
fi
rm -rf "$TEST_DIR/test_exit_$$"

# Test 7: Exit code - all filtered (no violations, exit code should be 0)
python3 "$PARSER" -s -f "$TEST_DIR/test_file_line.json" -o "$TEST_DIR/test_exit2_$$" "$TEST_DIR" > /dev/null 2>&1
ec=$?
if [ "$ec" -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Exit code: 0 when no violations remain"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Exit code: expected 0, got $ec"
    FAIL=$((FAIL + 1))
fi
rm -rf "$TEST_DIR/test_exit2_$$"

# Test 8: Missing log dir should fail
python3 "$PARSER" -s -f "$TEST_DIR/test_odir.json" -o "$TEST_DIR/test_exit3_$$" "/nonexistent/path" > /dev/null 2>&1
ec=$?
if [ "$ec" -ne 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Error handling: non-zero exit for missing log dir"
    PASS=$((PASS + 1))
else
    echo -e "${RED}[FAIL]${NC} Error handling: expected non-zero exit for missing log dir"
    FAIL=$((FAIL + 1))
fi
rm -rf "$TEST_DIR/test_exit3_$$"

# Cleanup temp json files
rm -f "$TEST_DIR/test_no_filter.json" "$TEST_DIR/test_signal_filter.json" \
      "$TEST_DIR/test_cross_match.json" "$TEST_DIR/test_file_line.json" \
      "$TEST_DIR/test_odir.json"

# Cleanup any leftover output files in test dir
rm -f "$TEST_DIR/filtered_*.txt"

echo ""
echo "=========================================="
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "=========================================="

exit $FAIL
