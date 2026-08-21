#!/usr/bin/env bash
set -euo pipefail

errors=0
warnings=0

pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; errors=$((errors + 1)); }

echo "Multi-Agent Novel Writer v4.1 verification"
echo "=========================================="

roles=(
  chapter-writer
  plot-architect
  worldbuilder
  character-developer
  continuity-editor
  smart-planner
  error-recovery
)
skills=(
  plan-novel
  write-chapter
  continuity-pass
  revise-chapter
  finalize-manuscript
)

required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/output-styles/autonomous-novelist.md"
  ".codex/config.toml"
  ".codex/hooks.json"
  "launch-novel.sh"
  "sync-state.sh"
  "automation/chapter-completed.sh"
  "automation/codex-chapter-completed.sh"
  "automation/quality-check.sh"
  "automation/session-init.sh"
  "automation/session-summary.sh"
  "automation/system-health-check.sh"
  "automation/dashboard.py"
)
for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then pass "$file exists"; else fail "$file missing"; fi
done

if grep -q '^@AGENTS\.md$' CLAUDE.md; then
  pass "CLAUDE.md imports canonical AGENTS.md"
else
  fail "CLAUDE.md does not import AGENTS.md"
fi

for role in "${roles[@]}"; do
  for path in \
    ".agents/roles/${role}.md" \
    ".claude/agents/${role}.md" \
    ".codex/agents/${role}.toml"; do
    if [[ -f "$path" ]]; then pass "role adapter: $path"; else fail "missing role adapter: $path"; fi
  done
done

for skill in "${skills[@]}"; do
  for path in \
    ".agents/skills/${skill}/SKILL.md" \
    ".claude/skills/${skill}/SKILL.md" \
    ".pi/prompts/${skill}.md"; do
    if [[ -f "$path" ]]; then pass "skill adapter: $path"; else fail "missing skill adapter: $path"; fi
  done
done

if command -v python3 >/dev/null 2>&1; then
  pass "python3 available"
else
  fail "python3 is required"
fi

for cli in claude codex pi; do
  if command -v "$cli" >/dev/null 2>&1; then
    pass "$cli CLI available"
  else
    warn "$cli CLI not found on PATH"
  fi
done

scripts_to_check=(
  launch-novel.sh
  setup-enhancements.sh
  sync-state.sh
  verify-system.sh
  automation/chapter-completed.sh
  automation/codex-chapter-completed.sh
  automation/quality-check.sh
  automation/session-init.sh
  automation/session-summary.sh
  automation/system-health-check.sh
  automation/pre-compact-backup.sh
)
for script in "${scripts_to_check[@]}"; do
  [[ -f "$script" ]] || continue
  if bash -n "$script"; then
    pass "shell syntax: $script"
  else
    fail "shell syntax: $script"
  fi
done

if python3 -m py_compile automation/dashboard.py >/dev/null 2>&1; then
  pass "dashboard Python syntax"
else
  fail "dashboard Python syntax"
fi

for json_file in .claude/settings.json .codex/hooks.json; do
  if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
    pass "valid JSON: $json_file"
  else
    fail "invalid JSON: $json_file"
  fi
done

if python3 - <<'PY'
from pathlib import Path
import sys

try:
    import tomllib
except ModuleNotFoundError:
    print("SKIP")
    raise SystemExit(2)

paths = [Path(".codex/config.toml"), *sorted(Path(".codex/agents").glob("*.toml"))]
for path in paths:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    if path.parent.name == "agents":
        for key in ("name", "description", "developer_instructions"):
            if not data.get(key):
                raise SystemExit(f"{path}: missing {key}")
print("OK")
PY
then
  pass "Codex TOML configuration"
else
  status=$?
  if [[ "$status" -eq 2 ]]; then
    warn "Python <3.11: Codex TOML validation skipped"
  else
    fail "Codex TOML validation"
  fi
fi

if grep -q '"SubagentStop"' .claude/settings.json && grep -q 'chapter-writer' .claude/settings.json; then
  pass "Claude chapter completion uses SubagentStop"
else
  fail "Claude chapter completion hook is not configured"
fi

if grep -q '"SubagentStop"' .codex/hooks.json && grep -q 'codex-chapter-completed.sh' .codex/hooks.json; then
  pass "Codex chapter completion uses JSON-safe SubagentStop adapter"
else
  fail "Codex chapter completion hook is not configured"
fi

for skill in "${skills[@]}"; do
  if grep -q "^name: ${skill}$" ".agents/skills/${skill}/SKILL.md" &&
     grep -q '^description:' ".agents/skills/${skill}/SKILL.md"; then
    pass "canonical skill metadata: $skill"
  else
    fail "invalid canonical skill metadata: $skill"
  fi
done

if grep -R -n --exclude-dir=.git --exclude=CHANGELOG.md \
  -E 'scene-writer|matcher"[[:space:]]*:[[:space:]]*"task"|/output-style([[:space:]]|$)' \
  AGENTS.md CLAUDE.md README.md .agents .claude .codex .pi Documentation 2>/dev/null; then
  fail "stale v3 references remain in active configuration or docs"
else
  pass "no stale v3 scene-writer/task matcher/output-style references"
fi

./sync-state.sh --quiet
if automation/system-health-check.sh --quiet; then
  pass "multi-harness system health check"
else
  fail "multi-harness system health check"
fi

echo
echo "Verification summary: ${errors} error(s), ${warnings} warning(s)."

if (( errors > 0 )); then
  exit 1
fi

echo "v4.1 configuration is ready for Claude Code, Codex, and Pi."
