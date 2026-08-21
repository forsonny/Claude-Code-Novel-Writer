#!/usr/bin/env bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for quality signals." >&2
  exit 1
fi

target="${1:-}"

python3 - "$target" <<'PY'
from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

target_arg = sys.argv[1]
chapters_dir = Path("manuscript/chapters")

if target_arg:
    path = Path(target_arg)
else:
    candidates = sorted(
        chapters_dir.glob("chapter-*.md"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    if not candidates:
        print("No chapter files found.")
        raise SystemExit(0)
    path = candidates[0]

if not path.exists():
    print(f"ERROR: chapter file not found: {path}", file=sys.stderr)
    raise SystemExit(1)

text = path.read_text(encoding="utf-8", errors="replace")
words = re.findall(r"\b[\w'’-]+\b", text)
paragraphs = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
paragraph_word_counts = [
    len(re.findall(r"\b[\w'’-]+\b", p)) for p in paragraphs
]
quoted = re.findall(r'["“](.+?)["”]', text, flags=re.DOTALL)
dialogue_words = sum(len(re.findall(r"\b[\w'’-]+\b", q)) for q in quoted)

word_count = len(words)
paragraph_count = len(paragraphs)
avg_paragraph = round(
    sum(paragraph_word_counts) / paragraph_count, 1
) if paragraph_count else 0
max_paragraph = max(paragraph_word_counts, default=0)
dialogue_share = round(dialogue_words / word_count, 3) if word_count else 0

warnings = []
if 0 < word_count < 1200:
    warnings.append("Chapter is very short for a full draft; confirm that it is intentionally brief.")
if word_count > 7000:
    warnings.append("Chapter is unusually long; review whether a structural split would improve pacing.")
if avg_paragraph > 120:
    warnings.append("Average paragraph length is high; inspect readability and scene rhythm.")
if max_paragraph > 350:
    warnings.append("At least one paragraph is very long; inspect it for accidental wall-of-text formatting.")

chapter_match = re.search(r"chapter-(\d+)", path.name)
chapter_key = f"chapter_{int(chapter_match.group(1))}" if chapter_match else path.stem
timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

metrics_path = Path("planning/quality-metrics.json")
try:
    metrics = json.loads(metrics_path.read_text(encoding="utf-8")) if metrics_path.exists() else {}
except json.JSONDecodeError:
    metrics = {}

metrics.setdefault("chapters", {})
metrics["chapters"][chapter_key] = {
    "timestamp": timestamp,
    "path": str(path),
    "word_count": word_count,
    "paragraph_count": paragraph_count,
    "avg_paragraph_words": avg_paragraph,
    "max_paragraph_words": max_paragraph,
    "dialogue_share": dialogue_share,
    "warnings": warnings,
    "note": "Mechanical signals only. These values do not measure literary quality.",
}
metrics_path.parent.mkdir(parents=True, exist_ok=True)
metrics_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")

print(f"Writing signals for {path}:")
print(f"  words: {word_count}")
print(f"  paragraphs: {paragraph_count}")
print(f"  average paragraph words: {avg_paragraph}")
print(f"  dialogue share: {dialogue_share:.1%}")
if warnings:
    print("  warnings:")
    for warning in warnings:
        print(f"    - {warning}")
else:
    print("  warnings: none")
print("These are mechanical signals, not a literary-quality score.")
PY
