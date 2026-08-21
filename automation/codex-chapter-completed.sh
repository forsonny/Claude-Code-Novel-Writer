#!/usr/bin/env bash
set -euo pipefail

hook_input="$(cat || true)"

if printf '%s' "$hook_input" | ./automation/chapter-completed.sh >/dev/null 2>&1; then
  # Codex SubagentStop requires valid JSON on stdout for a successful hook.
  printf '{}\n'
else
  echo "Chapter maintenance failed. Run ./sync-state.sh and automation/quality-check.sh manually." >&2
  exit 1
fi
