# User Guide

## 1. Initialize the project

```bash
./launch-novel.sh
```

The launcher checks Python, prepares generated directories, synchronizes file-based state, and validates the Claude Code, Codex, and Pi adapters.

## 2. Choose a harness

### Claude Code

```bash
claude
```

Use project slash commands such as `/plan-novel` and `/write-chapter`.

Claude loads `CLAUDE.md`, which imports the canonical `AGENTS.md`. Native specialists live under `.claude/agents/`.

### OpenAI Codex

```bash
codex
```

Mention a shared skill with `$`, for example:

```text
$plan-novel political fantasy about a disgraced cartographer
$write-chapter 7
```

Use `/skills` to inspect skills and `/agent` to inspect active or completed subagent threads.

Codex reads `AGENTS.md`, discovers `.agents/skills/`, and loads named specialists from `.codex/agents/`.

Review project hooks with `/hooks`. Automatic session and chapter maintenance runs only after those hooks are trusted.

### Pi

```bash
pi
```

Use the included prompt templates:

```text
/plan-novel political fantasy about a disgraced cartographer
/write-chapter 7
```

Or invoke the shared skill directly:

```text
/skill:plan-novel
/skill:write-chapter 7
```

Pi reads `AGENTS.md` and discovers `.agents/skills/` after the project is trusted. No third-party subagent extension is required. Pi can read a canonical role and perform it directly.

## 3. Plan a novel

Harness commands:

```text
Claude Code: /plan-novel [premise or constraints]
Codex:       $plan-novel [premise or constraints]
Pi:          /plan-novel [premise or constraints]
```

The shared skill inspects existing project state before planning, preserves drafted prose as canon, and updates `planning/novel-outline.json`.

## 4. Draft chapters

```text
Claude Code: /write-chapter 7
Codex:       $write-chapter 7
Pi:          /write-chapter 7
```

The workflow reads the outline, previous chapter, character state, world state, and continuity notes before drafting.

It refuses to overwrite substantial prose unless the request clearly calls for revision.

After writing, it records mechanical signals and synchronizes tracking. Claude Code and Codex may also perform maintenance through lifecycle hooks.

## 5. Review continuity

```text
Claude Code: /continuity-pass 4-9
Codex:       $continuity-pass 4-9
Pi:          /continuity-pass 4-9
```

The continuity role checks timeline, knowledge, physical state, names, world rules, setups, and payoffs. It reports findings before editing unless fixes were requested.

## 6. Revise a chapter

```text
Claude Code: /revise-chapter 7 tighten the midpoint confrontation
Codex:       $revise-chapter 7 tighten the midpoint confrontation
Pi:          /revise-chapter 7 tighten the midpoint confrontation
```

The shared workflow distinguishes structural, prose, character, pacing, and continuity problems before editing.

## 7. Finalize a manuscript

```text
Claude Code: /finalize-manuscript
Codex:       $finalize-manuscript
Pi:          /finalize-manuscript
```

This performs manuscript-level structural, continuity, arc, and completion review before broad polish.

Automated checks do not certify publication readiness.

## 8. State synchronization

Manuscript files are ground truth.

If tracking looks wrong:

```bash
./sync-state.sh
```

The command regenerates `planning/chapter-status.json` and updates `planning/plot-progress.json` from actual chapter files.

## 9. Diagnostics

```bash
./verify-system.sh
automation/system-health-check.sh
automation/quality-check.sh manuscript/chapters/chapter-7.md
python3 automation/dashboard.py
```

The verification command checks shared roles and skills plus all three harness adapters.

## 10. Lifecycle behavior

### Claude Code

- `SessionStart` loads current workspace state.
- `SubagentStop` for `chapter-writer` synchronizes and checks the latest chapter.
- `PreCompact` creates a backup.
- `SessionEnd` logs manuscript word change.

### Codex

The same lifecycle is configured in `.codex/hooks.json`. The Codex chapter hook uses a JSON-safe wrapper because successful `SubagentStop` hooks must emit JSON.

### Pi

Pi compatibility relies on shared skills and prompt templates rather than a bundled extension. Each writing workflow runs synchronization and writing-signal maintenance explicitly.

## 11. Adding a workflow

1. Add the canonical skill at `.agents/skills/<name>/SKILL.md`.
2. Add a Claude adapter at `.claude/skills/<name>/SKILL.md`.
3. Add a Pi prompt template at `.pi/prompts/<name>.md` when a short `/name` command is useful.
4. Codex and Pi discover the canonical `.agents/skills/` skill automatically.
5. Update `verify-system.sh` and documentation.

## 12. Adding a specialist role

1. Add the canonical role at `.agents/roles/<name>.md`.
2. Add a Claude custom-agent adapter at `.claude/agents/<name>.md`.
3. Add a Codex custom agent at `.codex/agents/<name>.toml`.
4. Describe the direct-execution fallback in the relevant shared skill so Pi remains compatible.
5. Update validation and documentation.
