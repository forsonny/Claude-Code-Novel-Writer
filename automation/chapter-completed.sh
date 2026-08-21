#!/usr/bin/env bash
set -euo pipefail

# Claude Code and Codex send SubagentStop JSON on stdin. Consume the payload so
# the script keeps the lifecycle contract even though current maintenance only
# needs the completed chapter on disk.
hook_input="$(cat || true)"

latest_chapter="$(ls -t manuscript/chapters/chapter-*.md 2>/dev/null | head -n 1 || true)"
if [[ -z "$latest_chapter" ]]; then
  exit 0
fi

./sync-state.sh --quiet
automation/quality-check.sh "$latest_chapter" >/dev/null 2>&1 || true

chapter_num="$(basename "$latest_chapter" | grep -oE '[0-9]+' | head -n 1)"
chapter_num=$((10#$chapter_num))
word_count="$(wc -w < "$latest_chapter" | tr -d ' ')"

mkdir -p planning automation

if [[ "$word_count" -ge 3000 ]]; then
  printf '%s chapter=%s words=%s file=%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$chapter_num" \
    "$word_count" \
    "$latest_chapter" >> automation/completions.log

  if (( chapter_num % 3 == 0 )); then
    printf 'Review continuity across chapters %d-%d.\n' \
      "$((chapter_num - 2))" "$chapter_num" > planning/continuity-flag.txt
  fi

  if (( chapter_num % 5 == 0 )); then
    printf 'Review pacing and plan after chapter %d.\n' \
      "$chapter_num" > planning/planning-flag.txt
  fi
fi
