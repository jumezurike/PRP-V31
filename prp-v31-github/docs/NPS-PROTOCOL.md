# NPS-PROTOCOL.md
# Non-Markovian Property Startup — Reading Order and Tier Structure
# PRP v3.1 §30 | Protocol Owner: Josiah Umezurike | LokDon 2026
# ============================================================
# MANDATORY — This file must be updated at every session close.
# A session is not closed until this file reflects the current session.
# Per PRP v3.1 §30.6 and §10.
# ============================================================

## Callsign

The only valid callsign is the exact phrase:

    Non-Markovian Property Startup

Case-sensitive. Three words. No abbreviations. No variations.
Before the callsign is received, the only permitted agent response is:

    "Awaiting Non-Markovian Property Startup callsign."

---

## Tier Structure

### TIER 1 — Governance (read first, in order)
Place files in: nps-gate/tiers/tier1/

| Order | Filename | Description |
|-------|----------|-------------|
| 01 | PRP_v31_Final.md | Problem Resolution Protocol v3.1 — full governing standard |
| 02 | ROLES.md | Roles and responsibilities — §12 |
| 03 | VIOLATION_TABLE.md | Violation consequences — §11 |

### TIER 2 — Technical Reference (read second, in order)
Place files in: nps-gate/tiers/tier2/

| Order | Filename | Description |
|-------|----------|-------------|
| 01 | ARCHITECTURE.md | Current system architecture overview |
| 02 | STRIDE_CURRENT.md | Current STRIDE threat model — §23 |
| 03 | NFR_BASELINE.md | Non-functional requirements — §29 |

### TIER 3 — Session History (read third, NEWEST FIRST)
Place files in: nps-gate/tiers/tier3/

Naming convention: JDEV_YYYYMMDD_HHMM_PR.txt
New session reports are added here at every session close.
Agent reads newest to oldest — carries open items forward.

### TIER 4 — Security Baseline (read fourth, in order)
Place files in: nps-gate/tiers/tier4/

| Order | Filename | Description |
|-------|----------|-------------|
| 01 | ACCEPTED_FINDINGS.md | All accepted security findings on record |
| 02 | OPEN_CVES.md | Open CVEs affecting current dependencies |
| 03 | PRSM_SCORES.md | Current PRSM v1.1 composite scores |

### TIER 5 — Live Code (read fifth, in order)
Place files in: nps-gate/tiers/tier5/

Agent reads current project state — key files, recent changes, known issues.
Add new core files here when they are created or significantly modified.

---

## Invariants — Confirmed at Every NPS

These must be confirmed in every NPS audit file:

1. No file modification without verified backup (§3)
2. No implementation without explicit approval — "approved" or "proceed" only (§2)
3. No delivery without pre-deployment security scan (§22.6)
4. AI agent may not self-approve or merge (§21.7, §24.4)
5. No PHI in code, logs, or test environments (§19.3)
6. No plaintext credentials anywhere (§15.1)
7. STRIDE threat model required before implementation (§23)
8. Only implement the approved solution — no unapproved changes (§4)

---

## Session Close Requirements (§30.6 + §10)

At every session close, update this file to add:

1. New session progress report to Tier 3 list
2. New core files created this session to Tier 5 list
3. New accepted security findings to Tier 4 list
4. Any new open items to tiers/tier3/.open_items

A session is NOT closed until this file reflects the current session.

---

## Amendment Record

| Date | Change | Approved by |
|------|--------|-------------|
| 2026-05-29 | Initial creation | Josiah Umezurike |
