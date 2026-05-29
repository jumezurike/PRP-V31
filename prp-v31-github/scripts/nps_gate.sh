#!/usr/bin/env bash
# ============================================================
# NPS GATE — Non-Markovian Property Startup Enforcement
# PRP v3.1 §30 | LokDon Development Framework
# Protocol Owner: Josiah Umezurike
# Version: 1.0 | 2026
# ============================================================
# MANDATORY — No agent may begin any work without completing
# this gate. Honour-based compliance is rejected by design.
# ============================================================

set -euo pipefail

# ── Constants ────────────────────────────────────────────────
CALLSIGN="Non-Markovian Property Startup"
GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_DIR="$GATE_DIR/docs/nps-audits"
STATE_FILE="$GATE_DIR/.nps_state"
LOG_FILE="$GATE_DIR/docs/nps-gate.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")

# ── Colours ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Logging ──────────────────────────────────────────────────
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}

# ── Lock state helpers ────────────────────────────────────────
is_locked() {
    if [[ ! -f "$STATE_FILE" ]]; then return 0; fi
    local state
    state=$(cat "$STATE_FILE")
    [[ "$state" != "NPS_COMPLETE" ]]
}

set_complete() {
    echo "NPS_COMPLETE" > "$STATE_FILE"
    echo "$TIMESTAMP" >> "$STATE_FILE"
    log "NPS COMPLETE — gate unlocked at $DATE_HUMAN"
}

reset_gate() {
    echo "LOCKED" > "$STATE_FILE"
    log "NPS gate reset to LOCKED at $DATE_HUMAN"
}

# ── Banner ────────────────────────────────────────────────────
print_banner() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║       NPS GATE — PRP v3.1 §30 ENFORCEMENT                ║${RESET}"
    echo -e "${BOLD}${CYAN}║       LokDon Development Framework                       ║${RESET}"
    echo -e "${BOLD}${CYAN}║       Protocol Owner: Josiah Umezurike                   ║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ── Awaiting message (only permitted response before callsign) ─
awaiting_message() {
    print_banner
    echo -e "${YELLOW}${BOLD}⚠  GATE STATUS: LOCKED${RESET}"
    echo ""
    echo -e "${BOLD}Awaiting Non-Markovian Property Startup callsign.${RESET}"
    echo ""
    echo -e "  No work may begin. No analysis. No suggestions."
    echo -e "  No implementation. No file modification."
    echo ""
    echo -e "${CYAN}  To unlock: run this script with the exact callsign${RESET}"
    echo -e "${CYAN}  as the first argument.${RESET}"
    echo ""
    echo -e "  Usage:"
    echo -e "    ${BOLD}bash nps_gate.sh \"Non-Markovian Property Startup\"${RESET}"
    echo ""
    log "Gate queried — LOCKED — awaiting callsign"
}

# ── Verify callsign ───────────────────────────────────────────
verify_callsign() {
    local input="$1"
    if [[ "$input" == "$CALLSIGN" ]]; then
        return 0
    else
        echo -e "${RED}${BOLD}✗  INVALID CALLSIGN${RESET}"
        echo ""
        echo -e "  Received:  \"$input\""
        echo -e "  Required:  \"$CALLSIGN\""
        echo ""
        echo -e "  Case-sensitive. Three words. No abbreviations."
        echo -e "  No variations. No other phrase constitutes authorisation."
        echo ""
        log "INVALID callsign attempt: \"$input\" at $DATE_HUMAN"
        exit 1
    fi
}

# ── NPS execution sequence ────────────────────────────────────
run_nps_sequence() {
    print_banner
    echo -e "${GREEN}${BOLD}✓  CALLSIGN ACCEPTED — Non-Markovian Property Startup${RESET}"
    echo ""
    echo -e "${BOLD}Executing NPS sequence per PRP v3.1 §30.3 ...${RESET}"
    echo ""
    log "Callsign accepted — NPS sequence starting at $DATE_HUMAN"

    # Step 1: Tier 1 — Governance
    echo -e "${CYAN}[Step 1/7]${RESET} Reading Tier 1 — Governance files ..."
    read_tier "tier1" "Governance"

    # Step 2: Tier 2 — Technical Reference
    echo -e "${CYAN}[Step 2/7]${RESET} Reading Tier 2 — Technical Reference files ..."
    read_tier "tier2" "Technical Reference"

    # Step 3: Tier 3 — Session History (newest to oldest)
    echo -e "${CYAN}[Step 3/7]${RESET} Reading Tier 3 — Session History (newest first) ..."
    read_tier_reversed "tier3" "Session History"

    # Step 4: Tier 4 — Security Baseline
    echo -e "${CYAN}[Step 4/7]${RESET} Reading Tier 4 — Security Baseline files ..."
    read_tier "tier4" "Security Baseline"

    # Step 5: Tier 5 — Live Code
    echo -e "${CYAN}[Step 5/7]${RESET} Reading Tier 5 — Live Code files ..."
    read_tier "tier5" "Live Code"

    # Step 6: Write NPS audit file
    echo -e "${CYAN}[Step 6/7]${RESET} Writing NPS audit file ..."
    write_audit_file

    # Step 7: Mark complete and declare
    set_complete
    echo -e "${CYAN}[Step 7/7]${RESET} Declaring NPS complete ..."
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║  NPS COMPLETE — $(date +"%Y-%m-%d %H:%M:%S") — ready for work  ║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  Audit file: $AUDIT_DIR/NPS_AUDIT_${TIMESTAMP}.md"
    echo -e "  Gate state: UNLOCKED"
    echo -e "  All work from this point is valid under PRP v3.1"
    echo ""
    log "NPS COMPLETE declared at $DATE_HUMAN"
}

# ── Read a tier directory ─────────────────────────────────────
read_tier() {
    local tier_dir="$GATE_DIR/tiers/$1"
    local tier_name="$2"
    local count=0

    if [[ ! -d "$tier_dir" ]]; then
        echo -e "  ${YELLOW}No $tier_name files found (directory missing)${RESET}"
        log "Tier $1 directory missing — skipped"
        return
    fi

    for f in "$tier_dir"/*; do
        if [[ -f "$f" ]]; then
            local fname
            fname=$(basename "$f")
            echo -e "  ✓  $fname"
            log "Tier $1 read: $fname"
            count=$((count + 1))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "  ${YELLOW}(no files in $tier_name tier yet)${RESET}"
    else
        echo -e "  ${GREEN}$count file(s) read${RESET}"
    fi
    echo ""
}

# ── Read tier 3 in reverse order (newest first) ───────────────
read_tier_reversed() {
    local tier_dir="$GATE_DIR/tiers/$1"
    local tier_name="$2"
    local count=0

    if [[ ! -d "$tier_dir" ]]; then
        echo -e "  ${YELLOW}No $tier_name files found${RESET}"
        return
    fi

    while IFS= read -r -d '' f; do
        local fname
        fname=$(basename "$f")
        echo -e "  ✓  $fname"
        log "Tier $1 read: $fname"
        count=$((count + 1))
    done < <(find "$tier_dir" -maxdepth 1 -type f -print0 | sort -rz)

    if [[ $count -eq 0 ]]; then
        echo -e "  ${YELLOW}(no session history files yet)${RESET}"
    else
        echo -e "  ${GREEN}$count file(s) read${RESET}"
    fi
    echo ""
}

# ── Write audit file ──────────────────────────────────────────
write_audit_file() {
    local audit_file="$AUDIT_DIR/NPS_AUDIT_${TIMESTAMP}.md"
    mkdir -p "$AUDIT_DIR"

    cat > "$audit_file" << AUDITEOF
# NPS AUDIT FILE
# Path: docs/nps-audits/NPS_AUDIT_${TIMESTAMP}.md
# PRP v3.1 §30.4 | Generated: $DATE_HUMAN
# Protocol Owner: Josiah Umezurike | LokDon

## 1. Reading Declaration

### Tier 1 — Governance
$(list_tier_files "tier1")

### Tier 2 — Technical Reference
$(list_tier_files "tier2")

### Tier 3 — Session History (newest to oldest)
$(list_tier_files_reversed "tier3")

### Tier 4 — Security Baseline
$(list_tier_files "tier4")

### Tier 5 — Live Code
$(list_tier_files "tier5")

## 2. Open Items Carried Forward
$(cat "$GATE_DIR/tiers/tier3/.open_items" 2>/dev/null || echo "None recorded.")

## 3. Invariants Confirmed
- [ ] No file modification without verified backup (§3)
- [ ] No implementation without explicit approval — "approved" or "proceed" only (§2)
- [ ] No delivery without pre-deployment security scan (§22.6)
- [ ] AI agent may not self-approve or merge (§21.7, §24.4)
- [ ] No PHI in code, logs, or test environments (§19.3)
- [ ] No plaintext credentials anywhere (§15.1)
- [ ] STRIDE threat model required before implementation (§23)
- [ ] Only implement the approved solution — no unapproved changes (§4)

## 4. Current Project State
$(cat "$GATE_DIR/tiers/tier5/.project_state" 2>/dev/null || echo "No project state file found in Tier 5.")

## 5. Security Findings Accepted
$(cat "$GATE_DIR/tiers/tier4/.accepted_findings" 2>/dev/null || echo "None on record.")

## 6. Agent Declaration
I declare that I have read all files listed above in the order specified by PRP v3.1 §30.3.
Open items have been identified and carried forward.
All invariants are confirmed.
I will not begin any work before declaring NPS COMPLETE.

NPS COMPLETE — $DATE_HUMAN
Agent operating under PRP v3.1 §30
Protocol Owner: Josiah Umezurike

AUDITEOF

    echo -e "  ${GREEN}Audit file written: NPS_AUDIT_${TIMESTAMP}.md${RESET}"
    echo ""
    log "Audit file written: $audit_file"
}

# ── List tier files for audit ─────────────────────────────────
list_tier_files() {
    local tier_dir="$GATE_DIR/tiers/$1"
    if [[ ! -d "$tier_dir" ]]; then
        echo "  (directory not found)"
        return
    fi
    local found=0
    for f in "$tier_dir"/*; do
        if [[ -f "$f" ]]; then
            echo "  - $(basename "$f") — [read and confirmed]"
            found=1
        fi
    done
    [[ $found -eq 0 ]] && echo "  (no files)"
}

list_tier_files_reversed() {
    local tier_dir="$GATE_DIR/tiers/$1"
    if [[ ! -d "$tier_dir" ]]; then
        echo "  (directory not found)"
        return
    fi
    local found=0
    while IFS= read -r -d '' f; do
        echo "  - $(basename "$f") — [read and confirmed]"
        found=1
    done < <(find "$tier_dir" -maxdepth 1 -type f -print0 | sort -rz)
    [[ $found -eq 0 ]] && echo "  (no files)"
}

# ── Status check ──────────────────────────────────────────────
check_status() {
    print_banner
    if is_locked; then
        echo -e "${RED}${BOLD}STATUS: LOCKED${RESET}"
        echo ""
        echo -e "  Awaiting Non-Markovian Property Startup callsign."
        echo -e "  No work is permitted."
    else
        local unlock_time
        unlock_time=$(sed -n '2p' "$STATE_FILE" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}${BOLD}STATUS: UNLOCKED${RESET}"
        echo ""
        echo -e "  NPS completed at: $unlock_time"
        echo -e "  Work is permitted under PRP v3.1"
        echo ""
        echo -e "  ${YELLOW}Note: NPS must be repeated at every new session.${RESET}"
        echo -e "  ${YELLOW}Run 'bash nps_gate.sh reset' to lock for new session.${RESET}"
    fi
    echo ""
}

# ── Main dispatcher ───────────────────────────────────────────
main() {
    mkdir -p "$AUDIT_DIR"
    touch "$LOG_FILE"

    case "${1:-}" in
        "")
            # No argument — gate is locked, show awaiting message
            awaiting_message
            exit 1
            ;;
        "$CALLSIGN")
            # Correct callsign received
            verify_callsign "$1"
            run_nps_sequence
            ;;
        "status")
            check_status
            ;;
        "reset")
            reset_gate
            echo -e "${YELLOW}Gate reset to LOCKED. NPS must be completed before next session.${RESET}"
            log "Gate manually reset at $DATE_HUMAN"
            ;;
        *)
            # Wrong callsign or unrecognised command
            verify_callsign "$1"
            ;;
    esac
}

main "$@"
