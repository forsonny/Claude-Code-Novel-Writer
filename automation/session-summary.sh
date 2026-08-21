#!/usr/bin/env bash
set -euo pipefail

hook_input="$(cat || true)"
session_id="$(python3 -c 'import json,sys; d=json.loads(sys.stdin.read() or "{}"); print(d.get("session_id","unknown"))' <<<"$hook_input" 2>/dev/null || echo unknown)"

current_words="$(python3 - <<'PY'
from pathlib import Path
print(sum(len(p.read_text(encoding="utf-8", errors="replace").split()) for p in Path("manuscript/chapters").glob("chapter-*.md")))
PY
)"

start_file="/tmp/novel-writer-${session_id}-start-words"
if [[ -f "$start_file" ]]; then
  start_words="$(cat "$start_file")"
else
  start_words="$current_words"
fi

words_written=$((current_words - start_words))
chapter_count="$(find manuscript/chapters -maxdepth 1 -type f -name 'chapter-*.md' | wc -l | tr -d ' ')"

mkdir -p automation
printf '%s session=%s words_delta=%s total_words=%s chapters=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$session_id" \
  "$words_written" \
  "$current_words" \
  "$chapter_count" >> automation/sessions.log

rm -f "$start_file"
