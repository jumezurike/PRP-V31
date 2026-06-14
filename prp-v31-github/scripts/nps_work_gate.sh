#!/usr/bin/env bash
# ============================================================
# NPS WORK GATE — PRP v3.1 §30
# Wraps any work command — refuses execution if NPS not complete
# Usage: bash nps_work_gate.sh <command> [args...]
# Also supports: --log-only (record but don't block for dry-run)
# ============================================================

set -euo pipefail

GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="$GATE_DIR/.nps_state"
LOG_FILE="$GATE_DIR/docs/nps-gate.log"
WORK_LOG="$GATE_DIR/docs/work-execution.log"
DATE_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")
DATE_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

LOG_ONLY=false
if [[ "${1:-}" == "--log-only" ]]; then
    LOG_ONLY=true
    shift
fi

log() {
    echo "[$DATE_HUMAN] $1" >> "$LOG_FILE"
}

work_log() {
    echo "[$DATE_ISO] $1" >> "$WORK_LOG"
}

is_nps_complete() {
    if [[ ! -f "$STATE_FILE" ]]; then return 1; fi
    local state
    state=$(head -1 "$STATE_FILE" 2>/dev/null || echo "LOCKED")
    [[ "$state" == "NPS_COMPLETE" ]]
}

is_expired() {
    if [[ ! -f "$STATE_FILE" ]]; then return 0; fi
    local expiry
    expiry=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
    if [[ -z "$expiry" ]]; then return 0; fi
    local now
    now=$(date +%s)
    [[ $now -gt $expiry ]]
}

get_session_id() {
    grep "^SESSION_ID=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2 || echo "unknown"
}

if ! is_nps_complete; then
    if [[ "$LOG_ONLY" == false ]]; then
        echo ""
        echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}${BOLD}║  WORK BLOCKED — PRP v3.1 §30 VIOLATION                   ║${RESET}"
        echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${BOLD}No work may be performed before NPS is complete.${RESET}"
        echo ""
        echo -e "  Awaiting Non-Markovian Property Startup callsign."
        echo ""
        echo -e "  To unlock:"
        echo -e "    ${BOLD}bash scripts/nps_gate.sh \"Non-Markovian Property Startup\"${RESET}"
        echo ""
        echo -e "  ${YELLOW}Per §11: All work performed before NPS COMPLETE is invalid.${RESET}"
        echo -e "  ${YELLOW}Per §30: Agent cannot work in ignorance of session history.${RESET}"
        echo ""
        log "WORK BLOCKED — NPS not complete — attempted command: ${*:-none} at $DATE_HUMAN"
        work_log "BLOCKED|no_session|${*:-none}"
        exit 1
    else
        echo -e "${YELLOW}[LOG-ONLY] Would block: ${*}${RESET}" >&2
        work_log "LOG_ONLY_BLOCKED|no_session|${*:-none}"
        exit 0
    fi
fi

if is_expired; then
    if [[ "$LOG_ONLY" == false ]]; then
        echo ""
        echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}${BOLD}║  WORK BLOCKED — NPS SESSION EXPIRED                      ║${RESET}"
        echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${BOLD}Your NPS session has expired.${RESET}"
        echo ""
        echo -e "  To continue working:"
        echo -e "    ${BOLD}bash scripts/nps_gate.sh reset${RESET}"
        echo -e "    ${BOLD}bash scripts/nps_gate.sh \"Non-Markovian Property Startup\"${RESET}"
        echo ""
        log "WORK BLOCKED — NPS expired — attempted command: ${*:-none}"
        work_log "BLOCKED|expired|$(get_session_id)|${*:-none}"
        exit 1
    else
        echo -e "${YELLOW}[LOG-ONLY] Would block (expired): ${*}${RESET}" >&2
        work_log "LOG_ONLY_BLOCKED|expired|$(get_session_id)|${*:-none}"
        exit 0
    fi
fi

SESSION_ID=$(get_session_id)
echo -e "${GREEN}✓  NPS gate: UNLOCKED (session: ${SESSION_ID:0:8}...) — proceeding${RESET}"
log "Work permitted — NPS complete — session $SESSION_ID — running: ${*:-none}"
work_log "PERMITTED|$SESSION_ID|${*:-none}"

if [[ $# -gt 0 ]]; then
    exec "$@"
else
    echo -e "${YELLOW}No command provided.${RESET}"
    exit 0
fi
