# System Architecture

## Design goal

v4 is a file-backed orchestration layer for Claude Code. It separates creative specialization from deterministic maintenance:

- agents handle bounded reasoning and writing tasks
- skills define repeatable workflows
- hooks run maintenance at lifecycle boundaries
- scripts derive state from files
- manuscript prose remains the source of truth

## Claude Code primitives

### Custom subagents

Agents live in:

```text
.claude/agents/
```

The main conversation delegates with the current `Agent` tool. v4 does not use `Task` in active instructions.

The seven project agents are:

| Agent | Responsibility |
| --- | --- |
| `chapter-writer` | Complete chapter drafting and substantive prose revision |
| `plot-architect` | Structure, turning points, chapter beats, setup and payoff |
| `character-developer` | Motivation, arcs, relationships, voice, knowledge |
| `worldbuilder` | Setting rules, institutions, history, geography, systems |
| `continuity-editor` | Cross-file consistency and contradiction auditing |
| `smart-planner` | Pacing and next-action analysis |
| `error-recovery` | Repository state, JSON, script, and configuration recovery |

Agent frontmatter uses current tool names such as `Read`, `Glob`, `Grep`, `Write`, `Edit`, and `Bash`.

Official reference:

https://code.claude.com/docs/en/sub-agents

### Project skills

Skills live in:

```text
.claude/skills/<skill-name>/SKILL.md
```

They provide the user-facing workflow layer:

- `/plan-novel`
- `/write-chapter`
- `/continuity-pass`
- `/revise-chapter`
- `/finalize-manuscript`

Official reference:

https://code.claude.com/docs/en/skills

### Output style

The project output style lives at:

```text
.claude/output-styles/autonomous-novelist.md
```

It changes the main conversation from software-engineering defaults toward fiction work. Subagents use their own prompts.

Official reference:

https://code.claude.com/docs/en/output-styles

### Hooks

Hooks are configured in `.claude/settings.json`.

#### SessionStart

Runs `automation/session-init.sh`.

The script:

- synchronizes tracking
- runs a quick health check
- captures starting word count for the session
- prints a concise state summary that Claude Code adds to session context

#### SubagentStop: chapter-writer

Runs `automation/chapter-completed.sh`.

`SubagentStop` matches agent type, which is the appropriate lifecycle event for chapter-writer completion.

The script:

- synchronizes state
- runs writing-signal analysis on the latest chapter
- logs a chapter that has reached full-draft length
- creates periodic continuity and planning reminders

#### PreCompact

Runs the existing `automation/pre-compact-backup.sh` for automatic compaction.

#### SessionEnd

Runs `automation/session-summary.sh` and logs the session's net manuscript word change.

Official reference:

https://code.claude.com/docs/en/hooks

## Why context-injection.txt was removed

v3 appended reminder strings to `.claude/context-injection.txt` after tool calls and made the orchestrator reread that file repeatedly.

That design had several drawbacks:

- unbounded repeated context
- fragile dependency on stale tool names
- duplicated instructions already present in project configuration
- unnecessary file writes
- no clear lifecycle ownership

v4 uses static instructions in `CLAUDE.md`, procedural instructions in skills, and lifecycle context from hooks.

## CLAUDE.md scope

`CLAUDE.md` contains only stable rules needed in most sessions. Multi-step procedures live in skills so startup context stays smaller and the workflows can evolve independently.

Official reference:

https://code.claude.com/docs/en/memory

## State model

### Source of truth

`manuscript/chapters/chapter-N.md` files are authoritative for drafted prose and actual word counts.

### Derived state

`sync-state.sh` updates:

- `planning/chapter-status.json`
- `planning/plot-progress.json`

The synchronizer preserves user planning metadata such as title and target words where possible.

### Creative state

These remain authored or semi-authored sources rather than purely derived data:

- `planning/novel-outline.json`
- `characters/`
- `worldbuilding/`

## Quality signals

`automation/quality-check.sh` measures:

- word count
- paragraph count
- average and maximum paragraph length
- approximate dialogue share
- a few anomaly warnings

The output explicitly labels these as mechanical signals, not a literary-quality score.

## Permissions

v4 relies on Claude Code's normal permission flow. It does not require bypass mode.

Hooks should remain deterministic, quick, and reviewable. Creative decisions belong in the conversation and agents, not in shell scripts.
