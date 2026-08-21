#!/usr/bin/env bash
set -euo pipefail

errors=0
warnings=0

pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; errors=$((errors + 1)); }

echo "Claude Code Novel Writer v4 verification"
echo "========================================"

required_files=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".claude/output-styles/autonomous-novelist.md"
  "launch-novel.sh"
  "sync-state.sh"
  "automation/chapter-completed.sh"
  "automation/quality-check.sh"
  "automation/session-init.sh"
  "automation/session-summary.sh"
  "automation/system-health-check.sh"
  "automation/dashboard.py"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then pass "$file exists"; else fail "$file missing"; fi
done

agents=(
  chapter-writer
  plot-architect
  worldbuilder
  character-developer
  continuity-editor
  smart-planner
  error-recovery
)
for agent in "${agents[@]}"; do
  path=".claude/agents/${agent}.md"
  if [[ -f "$path" ]]; then pass "agent ${agent}"; else fail "agent ${agent} missing"; fi
done

skills=(
  plan-novel
  write-chapter
  continuity-pass
  revise-chapter
  finalize-manuscript
)
for skill in "${skills[@]}"; do
  path=".claude/skills/${skill}/SKILL.md"
  if [[ -f "$path" ]]; then pass "skill /${skill}"; else fail "skill /${skill} missing"; fi
done

if command -v python3 >/dev/null 2>&1; then
  pass "python3 available"
else
  fail "python3 is required"
fi

if command -v claude >/dev/null 2>&1; then
  pass "Claude Code CLI available"
else
  warn "Claude Code CLI not found on PATH"
fi

scripts_to_check=(
  launch-novel.sh
  setup-enhancements.sh
  sync-state.sh
  verify-system.sh
  automation/chapter-completed.sh
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

if python3 -m json.tool .claude/settings.json >/dev/null 2>&1; then
  pass ".claude/settings.json is valid JSON"
else
  fail ".claude/settings.json is invalid JSON"
fi

if grep -q '"SubagentStop"' .claude/settings.json && grep -q 'chapter-writer' .claude/settings.json; then
  pass "chapter completion uses SubagentStop"
else
  fail "chapter completion hook is not configured with SubagentStop"
fi

if grep -R -n --exclude-dir=.git --exclude=CHANGELOG.md \
  -E 'scene-writer|matcher"[[:space:]]*:[[:space:]]*"task"|/output-style([[:space:]]|$)' \
  CLAUDE.md README.md .claude Documentation 2>/dev/null; then
  fail "stale v3 Claude Code references remain in active configuration or docs"
else
  pass "no stale scene-writer/task matcher/output-style command references in active config"
fi

./sync-state.sh --quiet
if automation/system-health-check.sh --quiet; then
  pass "system health check"
else
  fail "system health check"
fi

echo
echo "Verification summary: ${errors} error(s), ${warnings} warning(s)."

if (( errors > 0 )); then
  exit 1
fi

echo "v4 configuration is ready."
