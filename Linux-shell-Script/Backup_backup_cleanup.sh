#!/bin/bash

# =============================================================================
#  backup_cleanup.sh — Automated Backup & Disk Cleanup Script
#  Author : Production Automation
#  Version: 1.0.0
#  Usage  : ./backup_cleanup.sh [OPTIONS]
#           ./backup_cleanup.sh --source /var/www --backup-dir /backups
#           ./backup_cleanup.sh --cleanup-only --days 14
#           ./backup_cleanup.sh --dry-run
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ─────────────────────────────────────────────────────────────────────────────
#  DEFAULTS  (override via CLI flags or environment variables)
# ─────────────────────────────────────────────────────────────────────────────
SOURCE_DIR="${SOURCE_DIR:-/var/www/html}"          # Directory to back up
BACKUP_DIR="${BACKUP_DIR:-/var/backups/myapp}"     # Where backups are stored
CLEANUP_DIR="${CLEANUP_DIR:-/tmp/old_files}"       # Directory to scan for old files
LOG_DIR="${LOG_DIR:-/var/log/backup_cleanup}"      # Log directory
RETENTION_DAYS="${RETENTION_DAYS:-7}"              # Days to keep backups
CLEANUP_DAYS="${CLEANUP_DAYS:-30}"                 # Files older than N days → deleted
MAX_LOG_SIZE_MB="${MAX_LOG_SIZE_MB:-10}"           # Rotate log when it exceeds this size
DRY_RUN=false
BACKUP_ONLY=false
CLEANUP_ONLY=false
VERBOSE=false

# ─────────────────────────────────────────────────────────────────────────────
#  COLOURS
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
#  DERIVED PATHS
# ─────────────────────────────────────────────────────────────────────────────
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
LOG_FILE="${LOG_DIR}/backup_cleanup_$(date '+%Y%m').log"
LOCK_FILE="/tmp/backup_cleanup.lock"

# =============================================================================
#  LOGGING
# =============================================================================
log() {
    local level="$1"; shift
    local message="$*"
    local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
    local line="[${ts}] [${level}] ${message}"

    # Append to log file (create dirs if needed)
    mkdir -p "${LOG_DIR}"
    echo "${line}" >> "${LOG_FILE}"

    # Console output with colour
    case "${level}" in
        INFO)    $VERBOSE && echo -e "${GREEN}${line}${RESET}" || true ;;
        SUCCESS) echo -e "${GREEN}${BOLD}${line}${RESET}" ;;
        WARN)    echo -e "${YELLOW}${line}${RESET}" ;;
        ERROR)   echo -e "${RED}${line}${RESET}" >&2 ;;
        SECTION) echo -e "\n${CYAN}${BOLD}${line}${RESET}" ;;
        *)       echo "${line}" ;;
    esac
}

rotate_log() {
    if [[ -f "${LOG_FILE}" ]]; then
        local size_mb
        size_mb=$(du -m "${LOG_FILE}" 2>/dev/null | cut -f1)
        if (( size_mb >= MAX_LOG_SIZE_MB )); then
            local archive="${LOG_FILE%.log}_${TIMESTAMP}.log.gz"
            gzip -c "${LOG_FILE}" > "${archive}"
            : > "${LOG_FILE}"
            log INFO "Log rotated → ${archive}"
        fi
    fi
}

# =============================================================================
#  LOCK FILE  (prevent concurrent runs)
# =============================================================================
acquire_lock() {
    if [[ -e "${LOCK_FILE}" ]]; then
        local old_pid; old_pid="$(cat "${LOCK_FILE}" 2>/dev/null || echo 0)"
        if kill -0 "${old_pid}" 2>/dev/null; then
            log ERROR "Another instance is running (PID ${old_pid}). Exiting."
            exit 1
        else
            log WARN "Stale lock file found. Removing."
            rm -f "${LOCK_FILE}"
        fi
    fi
    echo $$ > "${LOCK_FILE}"
    log INFO "Lock acquired (PID $$)"
}

release_lock() {
    rm -f "${LOCK_FILE}"
    log INFO "Lock released."
}

# Always release lock on exit
trap 'release_lock' EXIT INT TERM

# =============================================================================
#  HELPER UTILITIES
# =============================================================================
human_size() {
    # Convert bytes to human-readable string (pure bash)
    local bytes="$1"
    if   (( bytes >= 1073741824 )); then printf "%.2f GB" "$(echo "scale=2; ${bytes}/1073741824" | bc)"
    elif (( bytes >= 1048576 ));    then printf "%.2f MB" "$(echo "scale=2; ${bytes}/1048576"    | bc)"
    elif (( bytes >= 1024 ));       then printf "%.2f KB" "$(echo "scale=2; ${bytes}/1024"       | bc)"
    else printf "%d B" "${bytes}"
    fi
}

check_disk_space() {
    local target_dir="$1"
    local required_bytes="$2"   # estimated bytes needed
    mkdir -p "${target_dir}"
    local available_bytes
    available_bytes=$(df --output=avail -B1 "${target_dir}" 2>/dev/null | tail -1)
    if (( available_bytes < required_bytes )); then
        log ERROR "Insufficient disk space in ${target_dir}."
        log ERROR "  Required : $(human_size "${required_bytes}")"
        log ERROR "  Available: $(human_size "${available_bytes}")"
        return 1
    fi
    log INFO "Disk space OK — $(human_size "${available_bytes}") available in ${target_dir}"
}

verify_checksum() {
    local archive="$1"
    local checksum_file="${archive}.sha256"
    sha256sum "${archive}" > "${checksum_file}"
    log INFO "Checksum written → ${checksum_file}"
}

# =============================================================================
#  USAGE / HELP
# =============================================================================
usage() {
    cat <<EOF
${BOLD}USAGE${RESET}
    $(basename "$0") [OPTIONS]

${BOLD}OPTIONS${RESET}
    --source       <dir>   Directory to back up          (default: ${SOURCE_DIR})
    --backup-dir   <dir>   Destination for archives      (default: ${BACKUP_DIR})
    --cleanup-dir  <dir>   Directory to scan for old files (default: ${CLEANUP_DIR})
    --log-dir      <dir>   Log directory                 (default: ${LOG_DIR})
    --days         <n>     Delete backups older than N days (default: ${RETENTION_DAYS})
    --cleanup-days <n>     Delete files older than N days   (default: ${CLEANUP_DAYS})
    --dry-run              Simulate — no files are deleted/created
    --backup-only          Run backup step only
    --cleanup-only         Run cleanup step only
    --verbose              Print INFO-level messages to console
    -h, --help             Show this help

${BOLD}ENVIRONMENT VARIABLES${RESET}
    SOURCE_DIR, BACKUP_DIR, CLEANUP_DIR, LOG_DIR
    RETENTION_DAYS, CLEANUP_DAYS, MAX_LOG_SIZE_MB

${BOLD}EXAMPLES${RESET}
    # Full run with custom paths
    $(basename "$0") --source /var/www --backup-dir /mnt/nas/backups --verbose

    # Dry-run to preview what would be deleted
    $(basename "$0") --dry-run --verbose

    # Cleanup only — remove files older than 14 days
    $(basename "$0") --cleanup-only --cleanup-days 14
EOF
    exit 0
}

# =============================================================================
#  ARGUMENT PARSING
# =============================================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source)       SOURCE_DIR="$2";    shift 2 ;;
            --backup-dir)   BACKUP_DIR="$2";    shift 2 ;;
            --cleanup-dir)  CLEANUP_DIR="$2";   shift 2 ;;
            --log-dir)      LOG_DIR="$2";       shift 2 ;;
            --days)         RETENTION_DAYS="$2";shift 2 ;;
            --cleanup-days) CLEANUP_DAYS="$2";  shift 2 ;;
            --dry-run)      DRY_RUN=true;       shift   ;;
            --backup-only)  BACKUP_ONLY=true;   shift   ;;
            --cleanup-only) CLEANUP_ONLY=true;  shift   ;;
            --verbose)      VERBOSE=true;       shift   ;;
            -h|--help)      usage ;;
            *) log ERROR "Unknown option: $1"; usage ;;
        esac
    done
}

# =============================================================================
#  STEP 1 — BACKUP
# =============================================================================
run_backup() {
    log SECTION "══════════  BACKUP  ══════════"

    # Validate source
    if [[ ! -d "${SOURCE_DIR}" ]]; then
        log ERROR "Source directory does not exist: ${SOURCE_DIR}"
        return 1
    fi

    # Estimate compressed size (source dir size × 0.6 as a rough heuristic)
    local src_bytes
    src_bytes=$(du -sb "${SOURCE_DIR}" 2>/dev/null | cut -f1)
    local required_bytes=$(( src_bytes * 6 / 10 ))
    check_disk_space "${BACKUP_DIR}" "${required_bytes}"

    local archive_name="backup_${TIMESTAMP}.tar.gz"
    local archive_path="${BACKUP_DIR}/${archive_name}"

    log INFO "Source      : ${SOURCE_DIR}"
    log INFO "Destination : ${archive_path}"
    log INFO "Dry-run     : ${DRY_RUN}"

    if ${DRY_RUN}; then
        log WARN "[DRY-RUN] Would create: ${archive_path}"
    else
        mkdir -p "${BACKUP_DIR}"

        # Create compressed archive, excluding common junk
        if tar \
            --exclude='*.tmp' \
            --exclude='*.log' \
            --exclude='.git' \
            --exclude='node_modules' \
            --exclude='__pycache__' \
            -czf "${archive_path}" \
            -C "$(dirname "${SOURCE_DIR}")" \
            "$(basename "${SOURCE_DIR}")" 2>>"${LOG_FILE}"; then

            local archive_size; archive_size=$(stat -c%s "${archive_path}" 2>/dev/null || echo 0)
            verify_checksum "${archive_path}"
            log SUCCESS "Backup created: ${archive_name} ($(human_size "${archive_size}"))"
        else
            log ERROR "tar failed — backup NOT created."
            return 1
        fi
    fi
}

# =============================================================================
#  STEP 2 — RETAIN ONLY N MOST-RECENT BACKUPS
# =============================================================================
purge_old_backups() {
    log SECTION "══════════  PURGE OLD BACKUPS  ══════════"

    if [[ ! -d "${BACKUP_DIR}" ]]; then
        log WARN "Backup directory not found — skipping purge."
        return 0
    fi

    log INFO "Retention : ${RETENTION_DAYS} day(s)"
    log INFO "Scanning  : ${BACKUP_DIR}"

    local count=0
    local freed=0

    while IFS= read -r -d '' old_backup; do
        local fsize; fsize=$(stat -c%s "${old_backup}" 2>/dev/null || echo 0)
        if ${DRY_RUN}; then
            log WARN "[DRY-RUN] Would delete backup: ${old_backup} ($(human_size "${fsize}"))"
        else
            rm -f "${old_backup}" "${old_backup}.sha256" 2>/dev/null || true
            log INFO "Deleted old backup: $(basename "${old_backup}") ($(human_size "${fsize}"))"
        fi
        (( count++ )) || true
        (( freed += fsize )) || true
    done < <(find "${BACKUP_DIR}" \
                  -maxdepth 1 \
                  -name 'backup_*.tar.gz' \
                  -mtime "+${RETENTION_DAYS}" \
                  -print0 2>/dev/null)

    if (( count == 0 )); then
        log INFO "No old backups found beyond ${RETENTION_DAYS} day(s)."
    else
        log SUCCESS "Purged ${count} old backup(s), freed ~$(human_size "${freed}")."
    fi
}

# =============================================================================
#  STEP 3 — DISK CLEANUP  (old / temp / unnecessary files)
# =============================================================================
run_cleanup() {
    log SECTION "══════════  DISK CLEANUP  ══════════"

    if [[ ! -d "${CLEANUP_DIR}" ]]; then
        log WARN "Cleanup directory does not exist: ${CLEANUP_DIR}"
        log INFO "Creating it for demonstration: ${CLEANUP_DIR}"
        mkdir -p "${CLEANUP_DIR}"
    fi

    log INFO "Target    : ${CLEANUP_DIR}"
    log INFO "Older than: ${CLEANUP_DAYS} day(s)"

    local total_count=0
    local total_freed=0

    # ── Patterns to clean ──────────────────────────────────────────────────
    declare -A PATTERNS=(
        ["Temp files"]="*.tmp *.temp"
        ["Log files"]="*.log *.log.*"
        ["Core dumps"]="core core.*"
        ["Editor swap"]="*.swp *.swo *~"
        ["Compiled"]="*.o *.pyc *.class"
        ["Archives"]="*.zip *.tar *.tar.gz *.tar.bz2 *.rar"
        ["Cache"]="*.cache .cache"
    )

    for label in "${!PATTERNS[@]}"; do
        local pattern_count=0
        local pattern_freed=0

        for glob in ${PATTERNS[$label]}; do
            while IFS= read -r -d '' f; do
                local fsize; fsize=$(stat -c%s "${f}" 2>/dev/null || echo 0)
                if ${DRY_RUN}; then
                    log WARN "[DRY-RUN] Would delete (${label}): ${f} ($(human_size "${fsize}"))"
                else
                    rm -f "${f}" 2>/dev/null || true
                    log INFO "Deleted (${label}): ${f} ($(human_size "${fsize}"))"
                fi
                (( pattern_count++ )) || true
                (( pattern_freed += fsize )) || true
            done < <(find "${CLEANUP_DIR}" \
                          -name "${glob}" \
                          -mtime "+${CLEANUP_DAYS}" \
                          -type f \
                          -print0 2>/dev/null)
        done

        if (( pattern_count > 0 )); then
            log INFO "  ${label}: ${pattern_count} file(s), ~$(human_size "${pattern_freed}") freed"
        fi

        (( total_count += pattern_count )) || true
        (( total_freed += pattern_freed )) || true
    done

    # ── Empty directories ──────────────────────────────────────────────────
    local empty_count=0
    while IFS= read -r -d '' d; do
        if ${DRY_RUN}; then
            log WARN "[DRY-RUN] Would remove empty dir: ${d}"
        else
            rmdir "${d}" 2>/dev/null && log INFO "Removed empty dir: ${d}" || true
        fi
        (( empty_count++ )) || true
    done < <(find "${CLEANUP_DIR}" \
                  -mindepth 1 \
                  -type d \
                  -empty \
                  -print0 2>/dev/null)

    (( total_count += empty_count )) || true

    if (( total_count == 0 )); then
        log INFO "Nothing to clean in ${CLEANUP_DIR}."
    else
        log SUCCESS "Cleanup complete: ${total_count} item(s) removed, ~$(human_size "${total_freed}") freed."
    fi
}

# =============================================================================
#  STEP 4 — SUMMARY REPORT
# =============================================================================
print_summary() {
    log SECTION "══════════  SUMMARY  ══════════"

    local end_ts; end_ts="$(date '+%Y-%m-%d %H:%M:%S')"

    {
        echo ""
        echo "  ╔══════════════════════════════════════════════╗"
        echo "  ║         BACKUP & CLEANUP SUMMARY             ║"
        echo "  ╠══════════════════════════════════════════════╣"
        printf  "  ║  Finished at : %-29s║\n" "${end_ts}"
        printf  "  ║  Source Dir  : %-29s║\n" "${SOURCE_DIR}"
        printf  "  ║  Backup Dir  : %-29s║\n" "${BACKUP_DIR}"
        printf  "  ║  Cleanup Dir : %-29s║\n" "${CLEANUP_DIR}"
        printf  "  ║  Log File    : %-29s║\n" "${LOG_FILE}"
        printf  "  ║  Dry-Run     : %-29s║\n" "${DRY_RUN}"
        echo "  ╚══════════════════════════════════════════════╝"
        echo ""
    } | tee -a "${LOG_FILE}"
}

# =============================================================================
#  MAIN
# =============================================================================
main() {
    parse_args "$@"

    # Initialise log & lock
    mkdir -p "${LOG_DIR}"
    rotate_log
    acquire_lock

    log SECTION "══════════  STARTING BACKUP & CLEANUP SCRIPT  ══════════"
    log INFO "PID        : $$"
    log INFO "Started at : $(date '+%Y-%m-%d %H:%M:%S')"
    log INFO "Dry-run    : ${DRY_RUN}"

    local exit_code=0

    if ! ${CLEANUP_ONLY}; then
        run_backup      || { log ERROR "Backup step failed.";  exit_code=1; }
        purge_old_backups || { log WARN  "Purge step had issues."; }
    fi

    if ! ${BACKUP_ONLY}; then
        run_cleanup     || { log ERROR "Cleanup step failed."; exit_code=1; }
    fi

    print_summary

    if (( exit_code == 0 )); then
        log SUCCESS "All tasks completed successfully."
    else
        log ERROR   "One or more tasks failed — review the log: ${LOG_FILE}"
    fi

    return "${exit_code}"
}

main "$@"
