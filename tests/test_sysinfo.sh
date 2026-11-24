#!/usr/bin/env bash
set -uo pipefail

# Resolve absolute paths so tests work regardless of where you run them from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/sysinfo.sh"

# Create a temporary workspace that automatically deletes itself when the test exits
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

STUB_BIN="$TMP_DIR/bin"
mkdir -p "$STUB_BIN"

# Helper to create a fake 'df' returning a specific percentage
create_df_stub() {
    local pct="$1"
    cat <<EOF > "$STUB_BIN/df"
#!/usr/bin/env bash
echo "Filesystem     1024-blocks      Used Available Capacity Mounted on"
echo "/dev/sda1         50000000  25000000  25000000      ${pct}% /"
EOF
    chmod +x "$STUB_BIN/df"
}

test_no_args_exits_2() {
    "$SCRIPT" >/dev/null 2>&1
    if [[ $? -eq 2 ]]; then
        echo "PASS: test_no_args_exits_2"
    else
        echo "FAIL: test_no_args_exits_2"
    fi
}

test_non_numeric_threshold_exits_2() {
    "$SCRIPT" "abc" "$TMP_DIR/test.log" >/dev/null 2>&1
    if [[ $? -eq 2 ]]; then
        echo "PASS: test_non_numeric_threshold_exits_2"
    else
        echo "FAIL: test_non_numeric_threshold_exits_2"
    fi
}

test_stub_df_below_threshold_exits_0() {
    create_df_stub 40
    # Prepend STUB_BIN to PATH so our fake df is found first
    PATH="$STUB_BIN:$PATH" "$SCRIPT" 80 "$TMP_DIR/below.log" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "PASS: test_stub_df_below_threshold_exits_0"
    else
        echo "FAIL: test_stub_df_below_threshold_exits_0"
    fi
}

test_stub_df_above_threshold_exits_1() {
    create_df_stub 90
    PATH="$STUB_BIN:$PATH" "$SCRIPT" 80 "$TMP_DIR/above.log" >/dev/null 2>&1
    if [[ $? -eq 1 ]]; then
        echo "PASS: test_stub_df_above_threshold_exits_1"
    else
        echo "FAIL: test_stub_df_above_threshold_exits_1"
    fi
}

test_log_file_gets_timestamped_lines() {
    local log_file="$TMP_DIR/timestamp.log"
    create_df_stub 50
    PATH="$STUB_BIN:$PATH" "$SCRIPT" 80 "$log_file" >/dev/null 2>&1
    
    # Check that log exists and every line starts with ISO 8601 (YYYY-MM-DDTHH:MM:SS)
    if [[ -s "$log_file" ]] && grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ' "$log_file"; then
        echo "PASS: test_log_file_gets_timestamped_lines"
    else
        echo "FAIL: test_log_file_gets_timestamped_lines"
    fi
}

test_shellcheck_clean() {
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck "$SCRIPT" "$REPO_ROOT/tests/test_sysinfo.sh"; then
            echo "PASS: test_shellcheck_clean"
        else
            echo "FAIL: test_shellcheck_clean"
        fi
    else
        echo "FAIL: test_shellcheck_clean (shellcheck not installed)"
    fi
}

# Run all 6 tests
test_no_args_exits_2
test_non_numeric_threshold_exits_2
test_stub_df_below_threshold_exits_0
test_stub_df_above_threshold_exits_1
test_log_file_gets_timestamped_lines
test_shellcheck_clean
