#!/usr/bin/env bash
set -euo pipefail

hook_input="$(cat || true)"
session_id="$(python3 -c 'import json,sys; d=json.loads(sys.stdin.read() or "{}"); print(d.get("session_id","unknown"))' <<<"$hook_input" 2>/dev/null || echo unknown)"

mkdir -p manuscript/chapters planning worldbuilding characters automation

./sync-state.sh --quiet
automation/system-health-check.sh --quiet || true

current_words="$(python3 - <<'PY'
from pathlib import Path
print(sum(len(p.read_text(encoding="utf-8", errors="replace").split()) for p in Path("manuscript/chapters").glob("chapter-*.md")))
PY
)"

printf '%s\n' "$current_words" > "/tmp/novel-writer-${session_id}-start-words"

python3 <<'PY'
import json
from pathlib import Path

progress_path = Path("planning/plot-progress.json")
try:
    progress = json.loads(progress_path.read_text(encoding="utf-8"))
except Exception:
    progress = {}

print("Novel workspace state:")
print(f"- title: {progress.get('novel_title', 'Untitled')}")
print(f"- total manuscript words: {progress.get('total_words', 0)}")
print(f"- current chapter: {progress.get('current_chapter', 1)}")
print(f"- chapter status: {progress.get('chapter_status', 'not_started')}")

continuity = Path("planning/continuity-flag.txt")
planning = Path("planning/planning-flag.txt")
if continuity.exists():
    print(f"- reminder: {continuity.read_text(encoding='utf-8').strip()}")
if planning.exists():
    print(f"- reminder: {planning.read_text(encoding='utf-8').strip()}")

print("Manuscript files are ground truth. Use the shared project skills for planning, drafting, revision, and continuity work.")
PY
