#!/usr/bin/env bash
# =============================================================================
# approval_gate.sh — PRP v3.1 Change Approval Gate
# LokDon AISM · Codified 2026-06-20 · Protocol Owner: Josiah Umezurike
#
# Usage:
#   bash scripts/approval_gate.sh --request "description of proposed change"
#   bash scripts/approval_gate.sh --grant   "description of approved change"
#   bash scripts/approval_gate.sh --status
#   bash scripts/approval_gate.sh --log
#   bash scripts/approval_gate.sh --clear
#
# Flow:
#   1. Agent proposes change  → runs --request (logs request, STOPS)
#   2. Protocol Owner approves in chat
#   3. Agent runs --grant     (writes single-use sentinel, logs grant)
#   4. Agent makes file edits
#   5. Pre-commit hook checks .approval_granted sentinel, clears it on pass
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SENTINEL="$REPO_ROOT/scripts/.approval_granted"
LOG_FILE="$REPO_ROOT/scripts/.approval_log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

usage() {
  echo ""
  echo "Usage: bash scripts/approval_gate.sh [OPTION]"
  echo ""
  echo "  --request <desc>   Log a change request and print AWAITING banner"
  echo "  --grant   <desc>   Write approval sentinel (run after owner approves)"
  echo "  --status           Show whether a valid approval sentinel exists"
  echo "  --log              Print the full approval audit log"
  echo "  --clear            Remove the sentinel manually (emergency reset)"
  echo ""
  exit 1
}

[ $# -lt 1 ] && usage

case "$1" in

  --request)
    DESC="${2:-unspecified change}"
    echo "[$TIMESTAMP] REQUEST: $DESC" >> "$LOG_FILE"
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   APPROVAL GATE — CHANGE REQUEST LOGGED                 ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf  "║  %-56s  ║\n" "$DESC"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  Awaiting Protocol Owner approval in chat.              ║"
    echo "║  Agent is STOPPED.                                      ║"
    echo "║  Run --grant once the owner says approved.              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    ;;

  --grant)
    DESC="${2:-unspecified change}"
    echo "$TIMESTAMP:$DESC" > "$SENTINEL"
    echo "[$TIMESTAMP] GRANTED: $DESC" >> "$LOG_FILE"
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   APPROVAL GATE — CHANGE APPROVED                       ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf  "║  %-56s  ║\n" "$DESC"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  Sentinel written. One commit permitted.                ║"
    echo "║  Sentinel clears automatically after commit.            ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    ;;

  --status)
    echo ""
    if [ -f "$SENTINEL" ]; then
      CONTENT=$(cat "$SENTINEL")
      echo "╔══════════════════════════════════════════════════════════╗"
      echo "║   APPROVAL GATE — ACTIVE (commit permitted)             ║"
      echo "╠══════════════════════════════════════════════════════════╣"
      printf  "║  %-56s  ║\n" "$CONTENT"
      echo "╚══════════════════════════════════════════════════════════╝"
    else
      echo "╔══════════════════════════════════════════════════════════╗"
      echo "║   APPROVAL GATE — LOCKED (no approval on record)        ║"
      echo "║   Run --request then --grant before committing.         ║"
      echo "╚══════════════════════════════════════════════════════════╝"
    fi
    echo ""
    ;;

  --log)
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo " APPROVAL GATE — AUDIT LOG"
    echo "═══════════════════════════════════════════════════════════"
    if [ -f "$LOG_FILE" ]; then
      cat "$LOG_FILE"
    else
      echo " (no entries yet)"
    fi
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    ;;

  --clear)
    rm -f "$SENTINEL"
    echo "[$TIMESTAMP] CLEARED: sentinel removed manually" >> "$LOG_FILE"
    echo "Approval sentinel cleared."
    ;;

  *)
    usage
    ;;

esac
