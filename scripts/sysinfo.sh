#!/usr/bin/env bash
set -euo pipefail

# Default values
DEFAULT_LOG="$HOME/sysinfo.log"
LOGFILE=""
THRESHOLD=""
WARN_TRIGGERED=0

usage() {
    # >&2 redirects output to Standard Error (stderr), standard practice for error/usage messages
    echo "Usage: $(basename "$0") THRESHOLD_PERCENT [LOGFILE]" >&2
    echo "  THRESHOLD_PERCENT : Integer between 1 and 100" >&2
    echo "  LOGFILE           : Path to log file (default: $DEFAULT_LOG)" >&2
}

log_line() {
    local message="$1"
    local is_warn="${2:-0}"
    local timestamp
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

    # 1. Print to terminal (stdout)
    # -t 1 checks if file descriptor 1 (stdout) is an interactive terminal.
    # If redirected to a file or pipe, we strip ANSI color codes so logs stay clean!
    if [[ "$is_warn" -eq 1 && -t 1 ]]; then
        printf '\033[31m%s\033[0m\n' "$message"
    else
        printf '%s\n' "$message"
    fi

    # 2. Append plain text with ISO 8601 timestamp to the log file
    printf '%s %s\n' "$timestamp" "$message" >> "$LOGFILE"
}

validate_threshold() {
    local val="${1:-}"
    # Regex ^[0-9]+$ ensures only digits exist (rejects empty strings, letters, negatives)
    if ! [[ "$val" =~ ^[0-9]+$ ]] || [[ "$val" -lt 1 || "$val" -gt 100 ]]; then
        usage
        exit 2
    fi
}

report_host() {
    log_line "Hostname: $(hostname)"
    log_line "Uptime: $(uptime -p 2>/dev/null || uptime)"
    
    # Extract memory stats cleanly using free -m
    local mem_info
    mem_info=$(free -m | awk '/^Mem:/ {printf "Used %sMB / Total %sMB", $3, $2}')
    log_line "Memory: $mem_info"
}

report_disks() {
    # df -P forces POSIX output format (prevents long device names from wrapping onto 2 lines)
    # tail -n +2 skips the header row
    while read -r fs size used avail cap mount; do
        # Strip the '%' sign from capacity (e.g., "85%" -> "85")
        local pct="${cap%\%}"
        
        # Ensure pct is numeric before comparing
        if [[ "$pct" =~ ^[0-9]+$ ]]; then
            if [[ "$pct" -ge "$THRESHOLD" ]]; then
                log_line "WARN: Filesystem $fs ($mount) is at ${pct}% (threshold: ${THRESHOLD}%)" 1
                WARN_TRIGGERED=1
            else
                log_line "OK: Filesystem $fs ($mount) is at ${pct}%" 0
            fi
        fi
    done < <(df -P | tail -n +2)
}

main() {
    # Ensure at least 1 argument and no more than 2
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        usage
        exit 2
    fi

    validate_threshold "$1"
    THRESHOLD="$1"
    LOGFILE="${2:-$DEFAULT_LOG}"

    # Ensure the directory for the logfile exists
    mkdir -p "$(dirname "$LOGFILE")"

    report_host
    report_disks

    # Exit 1 is used by monitoring tools (like Nagios/Zabbix) to signal a WARNING state
    if [[ "$WARN_TRIGGERED" -eq 1 ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
