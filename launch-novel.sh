#!/usr/bin/env bash
set -euo pipefail

echo "Multi-Agent Novel Writer v4.1"
echo "============================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: Python 3 is required by the state and diagnostic scripts."
  exit 1
fi

mkdir -p \
  .agents/roles \
  .agents/skills \
  .claude/agents \
  .claude/output-styles \
  .claude/skills \
  .codex/agents \
  .pi/prompts \
  manuscript/chapters \
  planning \
  worldbuilding \
  characters \
  automation \
  backups

chmod +x launch-novel.sh setup-enhancements.sh sync-state.sh verify-system.sh automation/*.sh 2>/dev/null || true

available=0
for cli in claude codex pi; do
  if command -v "$cli" >/dev/null 2>&1; then
    echo "$cli: $($cli --version 2>/dev/null | head -n 1 || echo installed)"
    available=$((available + 1))
  else
    echo "NOTICE: $cli CLI was not found on PATH."
  fi
done

if [[ "$available" -eq 0 ]]; then
  echo "WARNING: Install at least one supported harness before starting an agent session."
fi

echo
echo "Synchronizing file-based state..."
./sync-state.sh

echo
echo "Verifying project configuration..."
./verify-system.sh

echo
echo "Ready."
echo
echo "Start one supported harness:"
echo "  claude"
echo "  codex"
echo "  pi"
echo
echo "Workflow invocation:"
echo "  Claude Code: /plan-novel, /write-chapter"
echo "  Codex:       \$plan-novel, \$write-chapter"
echo "  Pi:          /plan-novel, /write-chapter"
