#!/usr/bin/env bash
# ============================================================
# NPS WORK GATE — PRP v3.1 §30
# Wraps any work command — refuses execution if NPS not complete
# Usage: bash nps_work_gate.sh "<command to run>"
# ============================================================

set -euo pipefail

GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="$GATE_DIR/.nps_state"
LOG_FILE="$GATE_DIR/docs/nps-gate.log"
DATE_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}

is_nps_complete() {
    if [[ ! -f "$STATE_FILE" ]]; then return 1; fi
    local state
    state=$(head -1 "$STATE_FILE")
    [[ "$state" == "NPS_COMPLETE" ]]
}

if ! is_nps_complete; then
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
    exit 1
fi

# NPS is complete — permit the work
echo -e "${GREEN}✓  NPS gate: UNLOCKED — proceeding${RESET}"
log "Work permitted — NPS complete — running: ${*:-none}"

if [[ $# -gt 0 ]]; then
    exec "$@"
fi
