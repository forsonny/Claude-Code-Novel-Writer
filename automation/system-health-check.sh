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
import sys
from datetime import datetime, timezone
from pathlib import Path

quiet = bool(int(sys.argv[1]))

roles = [
    "chapter-writer",
    "plot-architect",
    "worldbuilder",
    "character-developer",
    "continuity-editor",
    "smart-planner",
    "error-recovery",
]
skills = [
    "plan-novel",
    "write-chapter",
    "continuity-pass",
    "revise-chapter",
    "finalize-manuscript",
]

required_files = [
    "AGENTS.md",
    "CLAUDE.md",
    ".claude/settings.json",
    ".claude/output-styles/autonomous-novelist.md",
    ".codex/config.toml",
    ".codex/hooks.json",
    "sync-state.sh",
    "automation/quality-check.sh",
    "automation/codex-chapter-completed.sh",
]

issues: list[str] = []
warnings: list[str] = []

for rel in required_files:
    if not Path(rel).is_file():
        issues.append(f"missing required file: {rel}")

for role in roles:
    for rel in [
        Path(".agents/roles", f"{role}.md"),
        Path(".claude/agents", f"{role}.md"),
        Path(".codex/agents", f"{role}.toml"),
    ]:
        if not rel.is_file():
            issues.append(f"missing role adapter: {rel}")

for skill in skills:
    for rel in [
        Path(".agents/skills", skill, "SKILL.md"),
        Path(".claude/skills", skill, "SKILL.md"),
        Path(".pi/prompts", f"{skill}.md"),
    ]:
        if not rel.is_file():
            issues.append(f"missing skill adapter: {rel}")

for rel in [
    ".claude/settings.json",
    ".codex/hooks.json",
    "planning/plot-progress.json",
    "planning/chapter-status.json",
]:
    path = Path(rel)
    if not path.exists():
        if rel.startswith("planning/"):
            warnings.append(f"missing generated JSON: {rel}")
        else:
            issues.append(f"missing JSON: {rel}")
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
            issues.append("Claude settings missing SubagentStop chapter hook")
        if settings.get("outputStyle") != "Autonomous Novelist":
            warnings.append("Claude project outputStyle is not Autonomous Novelist")
    except Exception:
        pass

codex_hooks_path = Path(".codex/hooks.json")
if codex_hooks_path.exists():
    try:
        hooks = json.loads(codex_hooks_path.read_text(encoding="utf-8")).get("hooks", {})
        for event in ["SessionStart", "SubagentStop", "SessionEnd"]:
            if event not in hooks:
                issues.append(f"Codex hooks missing {event}")
    except Exception:
        pass

try:
    import tomllib
except ModuleNotFoundError:
    warnings.append("Python <3.11: TOML validation skipped")
else:
    toml_paths = [Path(".codex/config.toml"), *Path(".codex/agents").glob("*.toml")]
    for path in toml_paths:
        try:
            data = tomllib.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:
            issues.append(f"invalid TOML in {path}: {exc}")
            continue
        if path.parent.name == "agents":
            for key in ["name", "description", "developer_instructions"]:
                if not data.get(key):
                    issues.append(f"{path} missing required key: {key}")

for rel in [
    "launch-novel.sh",
    "sync-state.sh",
    "verify-system.sh",
    "automation/codex-chapter-completed.sh",
]:
    if Path(rel).exists() and not os.access(rel, os.X_OK):
        warnings.append(f"script is not executable: {rel}")

score = max(0, 100 - len(issues) * 12 - len(warnings) * 4)
status = "healthy" if not issues and score >= 90 else "warning" if not issues else "critical"
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
