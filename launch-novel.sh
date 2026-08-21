#!/usr/bin/env bash
set -euo pipefail

echo "Claude Code Novel Writer v4"
echo "==========================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: Python 3 is required by the state and diagnostic scripts."
  exit 1
fi

mkdir -p \
  .claude/agents \
  .claude/output-styles \
  .claude/skills \
  manuscript/chapters \
  planning \
  worldbuilding \
  characters \
  automation \
  backups

chmod +x launch-novel.sh setup-enhancements.sh sync-state.sh verify-system.sh automation/*.sh 2>/dev/null || true

if command -v claude >/dev/null 2>&1; then
  echo "Claude Code: $(claude --version 2>/dev/null | head -n 1 || echo installed)"
else
  echo "WARNING: Claude Code CLI was not found on PATH."
  echo "Install Claude Code before starting a writing session."
fi

echo
echo "Synchronizing file-based state..."
./sync-state.sh

echo
echo "Verifying project configuration..."
./verify-system.sh

echo
echo "Ready."
echo "Start Claude Code with:"
echo "  claude"
echo
echo "Recommended workflow:"
echo "  /plan-novel"
echo "  /write-chapter"
echo "  /continuity-pass"
echo "  /revise-chapter"
echo "  /finalize-manuscript"
