#!/usr/bin/env bash
# stage_for_approval.sh
# Generates .local/approval.txt listing every staged file.
# Agent MUST run this and then STOP — no commit until Protocol Owner approves.
#
# Usage: bash scripts/stage_for_approval.sh
set -e
APPROVAL_FILE=".local/approval.txt"
DATE=$(date -u +"%Y-%m-%d %H:%M UTC")
STAGED=$(git diff --cached --name-only)
if [[ -z "$STAGED" ]]; then
  echo "ERROR: No staged files found. Run 'git add <files>' first." >&2
  exit 1
fi
mkdir -p .local
{
  echo "STATUS: AWAITING_APPROVAL"
  echo "Date: $DATE"
  echo ""
  echo "Staged files requiring Protocol Owner approval:"
  echo "$STAGED" | while IFS= read -r f; do
    echo "  $f"
  done
  echo ""
  echo "---"
  echo "PROTOCOL OWNER INSTRUCTIONS:"
  echo "  1. Review every file listed above."
  echo "  2. Change 'STATUS: AWAITING_APPROVAL' to 'STATUS: APPROVED'."
  echo "  3. Add your UWA on the line below."
  echo "  4. Tell the agent to proceed with the commit."
  echo ""
  echo "UWA: "
} > "$APPROVAL_FILE"
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✋  HUMAN APPROVAL REQUIRED — PRP v3.1 Gate         ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Approval file written to: .local/approval.txt       ║"
echo "║                                                      ║"
echo "║  Agent is STOPPED. Next steps for Protocol Owner:   ║"
echo "║  1. Open .local/approval.txt                         ║"
echo "║  2. Review the staged file list                      ║"
echo "║  3. Change STATUS to APPROVED                        ║"
echo "║  4. Sign with your UWA                               ║"
echo "║  5. Tell the agent to commit                         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "--- Current approval.txt ---"
cat "$APPROVAL_FILE"
