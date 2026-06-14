#!/usr/bin/env bash
# Setup script for NPS tier directories

GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$GATE_DIR/tiers/tier1"      # Governance
mkdir -p "$GATE_DIR/tiers/tier2"      # Technical Reference  
mkdir -p "$GATE_DIR/tiers/tier3"      # Session History
mkdir -p "$GATE_DIR/tiers/tier4"      # Security Baseline
mkdir -p "$GATE_DIR/tiers/tier5"      # Live Code
mkdir -p "$GATE_DIR/docs/nps-audits"

# Create sample files
echo "# Governance Rules - PRP v3.1" > "$GATE_DIR/tiers/tier1/00-prp-v3.1.md"
echo "# Coding Standards" > "$GATE_DIR/tiers/tier1/01-coding-standards.md"
echo "# API Reference" > "$GATE_DIR/tiers/tier2/api-reference.md"
echo "# Architecture Decisions" > "$GATE_DIR/tiers/tier3/2026-01-15-auth-redesign.md"
echo "# Security Policies" > "$GATE_DIR/tiers/tier4/security-baseline.md"
echo "# Current Implementation" > "$GATE_DIR/tiers/tier5/current-state.md"

echo "✓ NPS tier directories created at: $GATE_DIR/tiers/"
echo "  tier1/ (Governance) — 2 files"
echo "  tier2/ (Technical Reference) — 1 file"
echo "  tier3/ (Session History) — 1 file"
echo "  tier4/ (Security Baseline) — 1 file"
echo "  tier5/ (Live Code) — 1 file"
