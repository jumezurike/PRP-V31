# PRP v3.1 — Problem Resolution Protocol
## AI-Assisted Developer Framework for Secure Code

**LokDon Development Framework · Lancaster University**  
**Protocol Owner: Josiah Umezurike**

| PRP Version | License | NPS Gate | OWASP | LLM |

---

## The Problem

**Honour-based AI compliance has already failed.**

Every major AI coding assistant — Claude, GPT-4, Gemini, Copilot — operates on a trust model: the agent is *asked* to follow documentation *by choice*.

This has been proven insufficient. **Violation 3 (2026-04-17):** an agent began work without reading session history. The response was not to write better instructions. The response was to make non-compliance **structurally impossible**.

---

## What PRP v3.1 Does

| WITHOUT PRP v3.1 | WITH PRP v3.1 |
|-----------------|----------------|
| Agent reads docs *if it feels like it* | Agent **CANNOT BEGIN** until callsign received and all tiers read |
| "Go ahead" = approval | ONLY **"approved"** or **"proceed"** counts |
| Backup is your problem | **No file touched** without verified backup |
| Security scan = best practice | Pre-deployment scan **NON-OVERRIDABLE** |
| AI reviews its own work | AI **CANNOT self-approve**. Period. |
| Compliance is expected | Violations have **automatic consequences** |

---

## How It Works — NPS Enforcement Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Step 1 — setup_nps_tiers.sh                                    │
│  Run once to create folders: tiers/tier1-5,                     │
│  docs/nps-audits, sample placeholder files                      │
└──────────────────────────┬──────────────────────────────────────┘
                           │ run once
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Tier folder structure (your knowledge base)                    │
│                                                                 │
│  ┌────────┐ ┌────────┐ ┌──────────────┐ ┌────────┐ ┌────────┐ │
│  │ tier1  │ │ tier2  │ │    tier3     │ │ tier4  │ │ tier5  │ │
│  │Govern- │ │  Tech  │ │   Session    │ │Securi- │ │  Live  │ │
│  │ ance   │ │  Ref   │ │   History    │ │  ty    │ │  Code  │ │
│  └────────┘ └────────┘ └──────────────┘ └────────┘ └────────┘ │
└──────────────────────────┬──────────────────────────────────────┘
                           │ each session
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 2 — nps_gate.sh "Non-Markovian Property Startup"          │
│  Verifies callsign → reads all 5 tiers →                        │
│  writes audit file → stamps session UNLOCKED (1hr TTL)          │
│                                                                 │
│  What nps_gate.sh does inside (7 steps):                        │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │1. Verify │→ │2. Read   │→ │3. Read   │→ │4. Read   │       │
│  │callsign  │  │tier1-2   │  │tier3     │  │tier4-5   │       │
│  └──────────┘  └──────────┘  │(newest   │  └──────────┘       │
│                               │ first)   │                      │
│                               └──────────┘                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐    │
│  │5. Write audit│→ │6. Write      │→ │7. UNLOCKED         │    │
│  │   .md file   │  │  .nps_state  │  │   1hr timer starts │    │
│  └──────────────┘  └──────────────┘  └────────────────────┘    │
└──────────────────────────┬──────────────────────────────────────┘
                           │ before any work
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 3 — nps_work_gate.sh [your command]                       │
│  Checks .nps_state → if UNLOCKED runs command;                  │
│  if LOCKED or EXPIRED blocks it entirely                        │
└──────────────┬──────────────────────────────────┬───────────────┘
               │                                  │
               ▼                                  ▼
┌─────────────────────────────┐  ┌────────────────────────────────┐
│  BLOCKED                    │  │  PERMITTED                     │
│  Logs attempt,              │  │  Logs session ID,              │
│  exits with error           │  │  runs command                  │
│                             │  │                                │
│  No callsign /              │  │  NPS complete + within 1hr     │
│  session expired            │  │                                │
└─────────────────────────────┘  └──────────────┬─────────────────┘
                                                │ before committing
                                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 4 — approval_gate.sh + stage_for_approval.sh               │
│  No edit ships without explicit Protocol Owner sign-off          │
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │ approval_gate.sh │ →  │ stage_for_         │                  │
│  │ --request        │    │ approval.sh        │                  │
│  │ logs + STOPS      │    │ writes             │                  │
│  └──────────────────┘    │ .local/approval.txt│                  │
│         │                 │ from `git add`     │                  │
│  human types              │ STOPS              │                  │
│  "approved" in chat        └──────────────────┘                  │
│         │                          │                              │
│         ▼                          ▼                              │
│  ┌──────────────────┐    Protocol Owner flips STATUS to          │
│  │ approval_gate.sh │    APPROVED, signs UWA in the file          │
│  │ --grant           │                                            │
│  │ writes sentinel   │                                            │
│  └──────────────────┘                                            │
│         │                                                         │
│         ▼                                                         │
│  Edits / commit now permitted                                    │
└─────────────────────────────────────────────────────────────────┘

Other nps_gate.sh commands:
  status     — check lock state
  reset      — end session
  force-lock — emergency block all work

Other approval_gate.sh commands:
  --status   — check whether a commit is currently permitted
  --log      — view the full approval audit trail
  --clear    — emergency manual reset of the sentinel
```

---

## Architecture Overview

```
╔═════════════════════════════════════════════════════════════╗
║              PRP v3.1 ENFORCEMENT STACK                     ║
║                   SESSION START                             ║
╚═════════════════════════════════════════════════════════════╝
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  NPS GATE  (§30)                              [LOCKED]      │
│  ─────────────────────────────────────────────────────────  │
│  Callsign: "Non-Markovian Property Startup"                 │
│  Wrong / missing → "Awaiting NPS callsign."  EXIT.         │
│  Correct →                                                  │
│    → Read Tier 1  (Governance)                              │
│    → Read Tier 2  (Technical Reference)                     │
│    → Read Tier 3  (Session History, newest → oldest)        │
│    → Read Tier 4  (Security Baseline)                       │
│    → Read Tier 5  (Live Code)                               │
│    → Write NPS audit file                                   │
│    → Declare NPS COMPLETE                     [UNLOCKED]    │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  ANALYSIS GATE  (§2)                                        │
│  ─────────────────────────────────────────────────────────  │
│  Problem Genesis → Root Cause →                             │
│  Solution Roadmap (with STRIDE + NFR)                       │
│  No implementation until analysis is complete.              │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  APPROVAL GATE  (§2)                                        │
│  ─────────────────────────────────────────────────────────  │
│  Valid triggers:  "approved"  |  "proceed"  — exact words.  │
│  "go ahead", "sounds good", "ok" = NOT approval.            │
│  No other phrase accepted.  No exceptions.                  │
│  Enforced by: approval_gate.sh + stage_for_approval.sh       │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKUP GATE  (§3)                                          │
│  ─────────────────────────────────────────────────────────  │
│  Backup created → verified readable → baseline recorded.    │
│  No backup = no file modification.  Ever.                   │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  IMPLEMENTATION  (§4)                                       │
│  ─────────────────────────────────────────────────────────  │
│  Approved plan ONLY.  No unapproved changes.  Ever.         │
│  Milestone backups at 25% / 50% / 75%.                      │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  REVIEW GATE  (§5)                                          │
│  ─────────────────────────────────────────────────────────  │
│  Correctness · Security · Consistency · Test coverage       │
│  No credentials · Supply chain verified.                    │
│  Work is incomplete until review passes.                    │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  DELIVERY GATE  (§6 + §22.6)                                │
│  ─────────────────────────────────────────────────────────  │
│  THREE SCANNERS — run in parallel:                          │
│    1. Dependency audit  (npm / pip / Snyk)                  │
│    2. SAST scan                                             │
│    3. HoundDog  (secrets / credentials)                     │
│  ANY Critical or High finding = HALT.  NON-OVERRIDABLE.     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  DOCUMENTATION GATE  (§7)                                   │
│  ─────────────────────────────────────────────────────────  │
│  Progress report filed.                                     │
│  NPS-PROTOCOL.md updated.                                   │
│  Session closed.                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## The NPS Gate — Non-Markovian Property Startup

The naming is not metaphorical. It derives from the OKT traversal architecture in the ECSMID/LFKI framework: each session carries forward the accumulated history of all prior sessions — anomaly signatures, open items, accepted findings — without exposing the traversal paths that generated them.

**The agent knows what has happened. It cannot pretend otherwise.**

### NPS Gate Commands

```bash
# Locked — no argument
$ bash scripts/nps_gate.sh
⚠  GATE STATUS: LOCKED
   Awaiting Non-Markovian Property Startup callsign.

# Wrong callsign
$ bash scripts/nps_gate.sh "proceed"
✗  INVALID CALLSIGN
   Received:  "proceed"
   Required:  "Non-Markovian Property Startup"

# Correct callsign — full sequence runs
$ bash scripts/nps_gate.sh "Non-Markovian Property Startup"
✓  CALLSIGN ACCEPTED
[Step 1/7] Reading Tier 1 — Governance ...
[Step 2/7] Reading Tier 2 — Technical Reference ...
[Step 3/7] Reading Tier 3 — Session History ...
[Step 4/7] Reading Tier 4 — Security Baseline ...
[Step 5/7] Reading Tier 5 — Live Code ...
[Step 6/7] Writing NPS audit file ...
[Step 7/7] Declaring NPS complete ...
╔══════════════════════════════════════════╗
║  NPS COMPLETE — 2026-05-29 17:48 — ready ║
╚══════════════════════════════════════════╝

# Check status
$ bash scripts/nps_gate.sh status
STATUS: UNLOCKED
  Session ID:    a7f3k92c-1e4b...
  NPS completed: 2026-06-13 14:30:00
  Session expires in: 1800 seconds (30 minutes)

# Reset gate (end session)
$ bash scripts/nps_gate.sh reset
Gate reset to LOCKED. NPS must be completed before next session.

# Emergency force lock
$ bash scripts/nps_gate.sh force-lock
🔒 FORCE LOCK ENGAGED
  Previous state archived to: .nps_state.force-lock.1718294400
  All work gates now BLOCKED.

# Work gate — blocks any command if NPS not done
$ bash scripts/nps_work_gate.sh python my_script.py
✗  WORK BLOCKED — PRP v3.1 §30 VIOLATION
   Per §11: All work performed before NPS COMPLETE is invalid.
```

---

## The Approval Gate — PRP v3.1 §2

NPS proves the agent has read the history. The Approval Gate proves the agent
isn't *acting* on its own judgment — every change is proposed, then stopped,
until the Protocol Owner gives explicit sign-off. "Go ahead," "sounds good,"
and "ok" do not count. Only an explicit grant — recorded by running the
script below — counts as approval.

There are two complementary scripts:

- **`approval_gate.sh`** — for proposing and approving a *change* before any
  edits are made. Tracks the request/grant cycle with a single-use sentinel
  file and a full audit log.
- **`stage_for_approval.sh`** — for the moment just before a *commit*. It
  reads whatever you've already run `git add` on, writes the exact file list
  to `.local/approval.txt`, and stops. The Protocol Owner reviews the list,
  flips the status to `APPROVED`, signs with their UWA, and only then does
  the agent commit.

### How to use the new gate going forward

```bash
# 1. Agent proposes a change — logs it and stops
bash scripts/approval_gate.sh --request "description of what I want to do"

# 2. You say "approved" in chat

# 3. Agent writes the sentinel, then makes edits
bash scripts/approval_gate.sh --grant "description"

# 4. View the audit trail any time
bash scripts/approval_gate.sh --log
```

### Approval Gate Commands

```bash
# Request — logs and stops, awaiting approval
$ bash scripts/approval_gate.sh --request "refactor auth module to use JWT"
╔══════════════════════════════════════════════════════════╗
║   APPROVAL GATE — CHANGE REQUEST LOGGED                 ║
╠══════════════════════════════════════════════════════════╣
║  refactor auth module to use JWT                        ║
╠══════════════════════════════════════════════════════════╣
║  Awaiting Protocol Owner approval in chat.              ║
║  Agent is STOPPED.                                      ║
║  Run --grant once the owner says approved.              ║
╚══════════════════════════════════════════════════════════╝

# Grant — only after the owner has typed "approved" or "proceed"
$ bash scripts/approval_gate.sh --grant "refactor auth module to use JWT"
╔══════════════════════════════════════════════════════════╗
║   APPROVAL GATE — CHANGE APPROVED                       ║
╠══════════════════════════════════════════════════════════╣
║  Sentinel written. One commit permitted.                ║
╚══════════════════════════════════════════════════════════╝

# Status — check whether a commit is currently permitted
$ bash scripts/approval_gate.sh --status

# Full audit log
$ bash scripts/approval_gate.sh --log

# Emergency manual reset
$ bash scripts/approval_gate.sh --clear
```

### Pre-Commit File Review

```bash
# Stage your files first
$ git add scripts/nps_gate.sh README.md

# Then generate the human-reviewable approval file
$ bash scripts/stage_for_approval.sh
╔══════════════════════════════════════════════════════╗
║  ✋  HUMAN APPROVAL REQUIRED — PRP v3.1 Gate         ║
╠══════════════════════════════════════════════════════╣
║  Approval file written to: .local/approval.txt       ║
║                                                      ║
║  Agent is STOPPED. Next steps for Protocol Owner:   ║
║  1. Open .local/approval.txt                         ║
║  2. Review the staged file list                      ║
║  3. Change STATUS to APPROVED                        ║
║  4. Sign with your UWA                               ║
║  5. Tell the agent to commit                         ║
╚══════════════════════════════════════════════════════╝
```

`.local/approval.txt` is never committed — it's a local, human-in-the-loop
checkpoint between staging and committing. The Protocol Owner edits the file
directly: changing `STATUS: AWAITING_APPROVAL` to `STATUS: APPROVED` and
signing the `UWA:` line is the only way a commit is authorized to proceed.

> **Note:** the header comment in `approval_gate.sh` references a pre-commit
> hook that automatically checks and clears the `.approval_granted` sentinel
> after a successful commit. That hook is not yet included in this repo — add
> one under `.git/hooks/pre-commit` (or a tracked equivalent) if you want the
> sentinel cleared automatically rather than manually via `--clear`.

---

PRSM v1.1 — Positional Risk Scoring Module
Every PRP enforcement verdict produces a quantitative score:

text
PRSM = PE × CW × (1 + IGAF) × CF

PE   — Positional Exposure    (0.0–1.0)  How reachable is the threat?
CW   — Chain Weight           (0.0–1.0)  How complete is the attack chain?
IGAF — Identity Grain Anomaly (0.0–1.0+) Is ECSMID operating correctly?
CF   — PRP Compliance Factor  (0 or 1)   CF=0 means work is INVALID. Score=0.
Band	Score	Response
INVALID	CF=0	Revert all work. Restart from §1.
HIGH	>0.70	Mandatory §26 Incident Response
MEDIUM	0.40–0.70	STRIDE update + RPL policy review
LOW	0.20–0.40	Document in threat register
MINIMAL	<0.20	Standard monitoring
A violated work product has a PRSM score of zero. The score is a gate, not a dashboard.

Quick Start
1. Clone and initialise
bash
git clone https://github.com/jumezurike/PRP-V31.git
cd PRP-V31
chmod +x scripts/nps_gate.sh scripts/nps_work_gate.sh scripts/setup_nps_tiers.sh scripts/approval_gate.sh scripts/stage_for_approval.sh
bash scripts/setup_nps_tiers.sh
2. Populate your tier directories
text
tiers/
├── tier1/    ← Your governance documents (PRP, roles, violation table)
├── tier2/    ← Architecture, STRIDE model, NFR baseline
├── tier3/    ← Session history reports (added each session close)
├── tier4/    ← Accepted security findings, open CVEs, PRSM scores
└── tier5/    ← Live code references, project state
3. Start every session with the gate
bash
# Reset from previous session
bash scripts/nps_gate.sh reset

# Provide callsign to begin
bash scripts/nps_gate.sh "Non-Markovian Property Startup"
4. Wrap all work commands
bash
# Any command blocked until NPS complete
bash scripts/nps_work_gate.sh <your command>

# Examples
bash scripts/nps_work_gate.sh npm run build
bash scripts/nps_work_gate.sh python deploy.py
bash scripts/nps_work_gate.sh git push origin main

# Dry-run (logs without executing)
bash scripts/nps_work_gate.sh --log-only dangerous_command.sh
5. Close every session
bash
# Fill in session report template
# Save as tiers/tier3/JU_DEV_YYYYMMDD_HHMM_PR.txt

# Update documentation
# Update docs/NPS-PROTOCOL.md

# Reset gate for next session
bash scripts/nps_gate.sh reset
The Five Tiers
Tier	Name	Contents	Read Order
1	Governance	PRP document, roles, violation table	First — establishes law
2	Technical Reference	Architecture, STRIDE model, NFR baseline	Second — establishes context
3	Session History	All prior session progress reports	Third — newest to oldest
4	Security Baseline	Accepted findings, open CVEs, PRSM scores	Fourth — establishes known risk
5	Live Code	Current project state, key files	Fifth — establishes current reality
Framework Alignment
Framework	PRP v3.1 Coverage
OWASP LLM Top 10	All 10 categories covered — §21, §22, §23, §14
MITRE ATLAS	All tactics covered — §23 STRIDE, §26 incident response
NIST AI RMF	GOVERN/MAP/MEASURE/MANAGE — PRSM scoring aligns exactly
Cambridge Taxonomy	Safety/Security/Privacy/Reliability/Resilience — §1–30
HIPAA/HITECH	§19 PHI governance — full compliance standard
GDPR	§14 RPL + §19 + LINDDUN privacy threat model
What PRP v3.1 Governs
Section	Gate	Cannot Be Bypassed
§2	Analysis	No implementation without approved roadmap
§3	Backup	No file modification without verified backup
§4	Implementation	Approved plan only — no unapproved changes
§5	Review	Work incomplete until review passes
§6+§22.6	Delivery	Three scanners — Critical/High = halt
§7	Documentation	No session closure without progress report
§11	Violations	Automatic consequences — no discretion
§14	RPL	Sensitive data never in code/logs/prompts
§21.7	AI Restrictions	AI cannot self-approve, merge, or access production
§23	STRIDE	Mandatory before any implementation
§24	Branch/PR	AI cannot serve as reviewer or approve merges
§30	NPS Gate	Callsign required — structurally enforced
Environment Variables
Variable	Default	Description
NPS_TTL_SECONDS	3600	Session timeout in seconds (1 hour)
bash
# Override session TTL (e.g., 8 hour workday)
export NPS_TTL_SECONDS=28800
bash scripts/nps_gate.sh "Non-Markovian Property Startup"
Licence
LokDon Open Enforcement Licence
This protocol and its enforcement tools may be:

✅ Adopted by any organisation
✅ Renamed and adapted for your context
✅ Deployed commercially
✅ Extended with additional sections

With one non-negotiable condition:

Enforcement principles must not be weakened.

The backup gate, the approval gate, the delivery scan gate, and the NPS startup lock are structural. Remove them and you have reverted to an honour system that has already been proven to fail.

Attribution: Josiah Umezurike, LokDon / Lancaster University, 2026

Authors
Josiah Johnson Umezurike — Protocol Owner, LokDon Security Research

Dr Ignatius Ezeani — Lancaster University

🌐 b2b.lokdon.com

Related Work
LFKI: OKT-Native Photonic AI Compute Fabric — The architecture whose Non-Markovian traversal property inspired the NPS gate

ECSMID / DataShieldAI — The mandated cryptographic APIs (§15)

PRSM v1.1 — Positional Risk Scoring Module (included in full PRP v3.1 document)

"PRP v3.1 is mandatory. No exceptions."
— Josiah Umezurike, Protocol Owner
