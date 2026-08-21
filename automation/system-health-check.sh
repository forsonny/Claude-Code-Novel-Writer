#!/usr/bin/env bash
set -euo pipefail

quiet=0
if [[ "${1:-}" == "--quiet" ]]; then
  quiet=1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required." >&2
  exit 1
fi

mkdir -p planning

python3 - "$quiet" <<'PY'
from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

quiet = bool(int(sys.argv[1]))

required_files = [
    "CLAUDE.md",
    ".claude/settings.json",
    ".claude/output-styles/autonomous-novelist.md",
    "sync-state.sh",
    "automation/quality-check.sh",
]
required_agents = [
    "chapter-writer.md",
    "plot-architect.md",
    "worldbuilder.md",
    "character-developer.md",
    "continuity-editor.md",
    "smart-planner.md",
    "error-recovery.md",
]
required_skills = [
    "plan-novel",
    "write-chapter",
    "continuity-pass",
    "revise-chapter",
    "finalize-manuscript",
]

issues = []
warnings = []

for rel in required_files:
    if not Path(rel).is_file():
        issues.append(f"missing required file: {rel}")

for name in required_agents:
    if not Path(".claude/agents", name).is_file():
        issues.append(f"missing agent: {name}")

for name in required_skills:
    if not Path(".claude/skills", name, "SKILL.md").is_file():
        issues.append(f"missing skill: {name}")

json_files = [
    ".claude/settings.json",
    "planning/plot-progress.json",
    "planning/chapter-status.json",
]
for rel in json_files:
    path = Path(rel)
    if not path.exists():
        warnings.append(f"missing generated JSON: {rel}")
        continue
    try:
        json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        issues.append(f"invalid JSON in {rel}: {exc}")

settings_path = Path(".claude/settings.json")
if settings_path.exists():
    try:
        settings = json.loads(settings_path.read_text(encoding="utf-8"))
        hooks = settings.get("hooks", {})
        if "SubagentStop" not in hooks:
            issues.append("settings missing SubagentStop chapter hook")
        if settings.get("outputStyle") != "Autonomous Novelist":
            warnings.append("project outputStyle is not Autonomous Novelist")
    except Exception:
        pass

for rel in ["launch-novel.sh", "sync-state.sh", "verify-system.sh"]:
    if Path(rel).exists() and not os.access(rel, os.X_OK):
        warnings.append(f"script is not executable: {rel}")

score = max(0, 100 - len(issues) * 15 - len(warnings) * 5)
status = "healthy" if not issues and score >= 90 else "warning" if score >= 70 else "critical"
report = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "health_score": score,
    "status": status,
    "issues": issues,
    "warnings": warnings,
}
Path("planning/system-health.json").write_text(
    json.dumps(report, indent=2) + "\n",
    encoding="utf-8",
)

if not quiet:
    print(f"System health: {status} ({score}/100)")
    for item in issues:
        print(f"ERROR: {item}")
    for item in warnings:
        print(f"WARNING: {item}")
    print("Report: planning/system-health.json")

raise SystemExit(1 if issues else 0)
PY
