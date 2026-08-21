#!/usr/bin/env bash
set -euo pipefail

quiet=0
if [[ "${1:-}" == "--quiet" ]]; then
  quiet=1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for state synchronization." >&2
  exit 1
fi

mkdir -p manuscript/chapters planning

python3 - "$quiet" <<'PY'
from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

quiet = bool(int(sys.argv[1]))
root = Path(".")
chapters_dir = root / "manuscript" / "chapters"
planning_dir = root / "planning"
chapter_pattern = re.compile(r"^chapter-(\d+)\.md$")

chapter_rows = []
for path in chapters_dir.glob("chapter-*.md"):
    match = chapter_pattern.match(path.name)
    if not match:
        continue
    chapter = int(match.group(1))
    try:
        words = len(path.read_text(encoding="utf-8").split())
    except UnicodeDecodeError:
        words = len(path.read_text(encoding="utf-8", errors="replace").split())

    if words >= 3000:
        status = "complete"
    elif words >= 500:
        status = "in_progress"
    else:
        status = "minimal"

    chapter_rows.append((chapter, path, words, status))

chapter_rows.sort(key=lambda row: row[0])

chapter_status = {}
for chapter, path, words, status in chapter_rows:
    chapter_status[f"chapter_{chapter}"] = {
        "status": status,
        "words": words,
        "file_exists": True,
        "path": str(path),
    }

completed = [chapter for chapter, _, _, status in chapter_rows if status == "complete"]
incomplete = [chapter for chapter, _, _, status in chapter_rows if status != "complete"]
highest = max((row[0] for row in chapter_rows), default=0)
total_words = sum(row[2] for row in chapter_rows)

if incomplete:
    current_chapter = min(incomplete)
    current_status = chapter_status[f"chapter_{current_chapter}"]["status"]
else:
    current_chapter = highest + 1 if highest else 1
    current_status = "not_started"

existing_progress = {}
progress_path = planning_dir / "plot-progress.json"
if progress_path.exists():
    try:
        existing_progress = json.loads(progress_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        existing_progress = {}

outline = {}
outline_path = planning_dir / "novel-outline.json"
if outline_path.exists():
    try:
        outline = json.loads(outline_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        outline = {}

target_words = (
    existing_progress.get("target_words")
    or outline.get("target_word_count")
    or 90000
)
novel_title = existing_progress.get("novel_title") or outline.get("title") or "Untitled"

timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
progress = {
    **existing_progress,
    "novel_title": novel_title,
    "target_words": target_words,
    "current_chapter": current_chapter,
    "current_scene": 1,
    "total_words": total_words,
    "chapter_status": current_status,
    "chapters_completed": completed,
    "next_milestone": f"complete_chapter_{current_chapter}",
    "last_action": "state_synchronized",
    "last_sync_time": timestamp,
}

planning_dir.mkdir(parents=True, exist_ok=True)
(planning_dir / "chapter-status.json").write_text(
    json.dumps(chapter_status, indent=2) + "\n",
    encoding="utf-8",
)
progress_path.write_text(json.dumps(progress, indent=2) + "\n", encoding="utf-8")

if not quiet:
    print("State synchronized from manuscript files.")
    print(f"Chapters found: {len(chapter_rows)}")
    print(f"Completed chapters: {len(completed)}")
    print(f"Total words: {total_words}")
    print(f"Current chapter: {current_chapter}")
PY
