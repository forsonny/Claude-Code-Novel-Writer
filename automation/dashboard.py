#!/usr/bin/env python3
"""Status dashboard for Claude Code Novel Writer v4."""

from __future__ import annotations

import argparse
import json
import re
import time
from pathlib import Path


CHAPTER_RE = re.compile(r"chapter-(\d+)\.md$")


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def scan_chapters(root: Path) -> list[dict]:
    rows = []
    for path in (root / "manuscript" / "chapters").glob("chapter-*.md"):
        match = CHAPTER_RE.search(path.name)
        if not match:
            continue
        words = len(path.read_text(encoding="utf-8", errors="replace").split())
        status = "complete" if words >= 3000 else "in_progress" if words >= 500 else "minimal"
        rows.append(
            {
                "number": int(match.group(1)),
                "path": path,
                "words": words,
                "status": status,
            }
        )
    return sorted(rows, key=lambda row: row["number"])


def render(root: Path) -> None:
    progress = load_json(root / "planning" / "plot-progress.json")
    health = load_json(root / "planning" / "system-health.json")
    quality = load_json(root / "planning" / "quality-metrics.json")
    chapters = scan_chapters(root)

    total_words = sum(row["words"] for row in chapters)
    target_words = int(progress.get("target_words") or 90000)
    percent = (total_words / target_words * 100) if target_words else 0

    print("=" * 68)
    print("CLAUDE CODE NOVEL WRITER v4")
    print("=" * 68)
    print(f"Title: {progress.get('novel_title', 'Untitled')}")
    print(f"Words: {total_words:,} / {target_words:,} ({percent:.1f}%)")
    print(f"Current chapter: {progress.get('current_chapter', 1)}")
    print(f"Tracked status: {progress.get('chapter_status', 'unknown')}")
    print(f"Last sync: {progress.get('last_sync_time', 'never')}")
    if health:
        print(f"Workspace health: {health.get('status', 'unknown')} ({health.get('health_score', '?')}/100)")

    print()
    print("CHAPTERS")
    print("-" * 68)
    if not chapters:
        print("No chapter files yet.")
    for row in chapters:
        icon = {"complete": "✓", "in_progress": "~", "minimal": "·"}[row["status"]]
        print(f"{icon} {row['number']:>3}  {row['words']:>6,} words  {row['status']:<11}  {row['path'].name}")

    warnings = []
    metrics = quality.get("chapters", {})
    for key, data in metrics.items():
        for warning in data.get("warnings", []):
            warnings.append(f"{key}: {warning}")

    continuity_flag = root / "planning" / "continuity-flag.txt"
    planning_flag = root / "planning" / "planning-flag.txt"

    print()
    print("REMINDERS")
    print("-" * 68)
    reminders = []
    if continuity_flag.exists():
        reminders.append(continuity_flag.read_text(encoding="utf-8").strip())
    if planning_flag.exists():
        reminders.append(planning_flag.read_text(encoding="utf-8").strip())
    reminders.extend(warnings[-5:])
    if reminders:
        for reminder in reminders:
            print(f"- {reminder}")
    else:
        print("No current reminders.")

    print()
    print("Mechanical writing signals are diagnostics, not literary-quality scores.")
    print("=" * 68)


def main() -> None:
    parser = argparse.ArgumentParser(description="Claude Code Novel Writer v4 dashboard")
    parser.add_argument("--path", default=".", help="Path to the novel project")
    parser.add_argument("--monitor", "-m", action="store_true", help="Refresh continuously")
    parser.add_argument("--interval", "-i", type=int, default=30, help="Refresh interval in seconds")
    args = parser.parse_args()

    root = Path(args.path)
    if not args.monitor:
        render(root)
        return

    try:
        while True:
            print("\033[2J\033[H", end="")
            render(root)
            time.sleep(max(1, args.interval))
    except KeyboardInterrupt:
        print("\nMonitoring stopped.")


if __name__ == "__main__":
    main()
