# Claude Code Novel Writer v4

A project-local, multi-agent workspace for planning, drafting, revising, and tracking long-form fiction with Claude Code.

Version 4 replaces the older "always-on autonomous" design with current Claude Code primitives: custom subagents, project skills, project output styles, lifecycle hooks, and file-based state. The system still supports long-running novel workflows, but it treats automation and quality metrics as aids rather than guarantees.

## What changed in v4

- Uses the current `Agent` tool for subagent delegation instead of legacy `Task` terminology.
- Moves the output style into `.claude/output-styles/`, where Claude Code loads project styles directly.
- Adds project skills for the major writing workflows.
- Uses `SubagentStop` for chapter-completion automation instead of trying to match an agent name in `PostToolUse`.
- Removes the context-injection text-file feedback loop.
- Keeps `CLAUDE.md` concise and moves procedural workflows into skills.
- Replaces hard-coded quality claims with lightweight, inspectable writing signals.
- Stops recommending `--dangerously-skip-permissions`.
- Keeps manuscript files as the source of truth and synchronizes tracking from disk.

## Requirements

- Claude Code
- Python 3
- Bash-compatible shell for the included automation scripts

Check your Claude Code version with:

```bash
claude --version
```

Current Claude Code documentation:

https://code.claude.com/docs

## Quick start

```bash
git clone https://github.com/forsonny/Claude-Code-Novel-Writer.git
cd Claude-Code-Novel-Writer
./launch-novel.sh
claude
```

The project selects the **Autonomous Novelist** output style through `.claude/settings.json`. You can change the active style at any time with `/config`.

Recommended first command inside Claude Code:

```text
/plan-novel
```

Then draft chapters with:

```text
/write-chapter
```

Useful workflows:

```text
/continuity-pass
/revise-chapter
/finalize-manuscript
```

You can pass arguments to skills. For example:

```text
/write-chapter 7
/revise-chapter 7
```

## Architecture

```text
.
├── CLAUDE.md
├── .claude/
│   ├── agents/
│   │   ├── chapter-writer.md
│   │   ├── character-developer.md
│   │   ├── continuity-editor.md
│   │   ├── error-recovery.md
│   │   ├── plot-architect.md
│   │   ├── smart-planner.md
│   │   └── worldbuilder.md
│   ├── output-styles/
│   │   └── autonomous-novelist.md
│   ├── skills/
│   │   ├── continuity-pass/SKILL.md
│   │   ├── finalize-manuscript/SKILL.md
│   │   ├── plan-novel/SKILL.md
│   │   ├── revise-chapter/SKILL.md
│   │   └── write-chapter/SKILL.md
│   └── settings.json
├── manuscript/chapters/
├── planning/
├── characters/
├── worldbuilding/
└── automation/
```

### Responsibilities

**CLAUDE.md** contains stable project rules and the delegation map.

**Skills** define repeatable user workflows. They are available as slash commands because they live under `.claude/skills/`.

**Agents** specialize in planning, prose, continuity, characters, worldbuilding, and workflow recovery.

**Hooks** run deterministic maintenance at Claude Code lifecycle boundaries. Chapter-completion maintenance is triggered when the `chapter-writer` subagent stops.

**Automation scripts** synchronize file-based state, record lightweight quality signals, and provide diagnostics.

## State and source of truth

The manuscript files under `manuscript/chapters/` are authoritative. Tracking files are derived state and can be regenerated:

```bash
./sync-state.sh
```

To inspect the project:

```bash
./verify-system.sh
automation/system-health-check.sh
python3 automation/dashboard.py
```

The dashboard can monitor continuously:

```bash
python3 automation/dashboard.py --monitor
```

## Quality philosophy

The old system treated numeric heuristics as proof of publication quality. v4 does not.

`automation/quality-check.sh` records mechanical signals such as word count, paragraph length, and dialogue share. Those signals can reveal anomalies, but they do not determine literary quality. Revision decisions should use the chapter's purpose, voice, pacing, continuity, and reader effect.

## Safety and permissions

v4 uses Claude Code's normal permission flow. The repository does not require bypassing permissions.

Review project hooks and scripts before running any repository you did not create yourself. This repo's hooks are defined in `.claude/settings.json`.

## Documentation

- `Documentation/User-Guide.md` for daily use
- `Documentation/System-Architecture.md` for implementation details
- `CHANGELOG.md` for the v4 migration summary

## Compatibility note

`setup-enhancements.sh` remains as a compatibility wrapper and now delegates to `launch-novel.sh`.

The old root `output-styles/` copy is no longer used. Project output styles belong under `.claude/output-styles/`.
