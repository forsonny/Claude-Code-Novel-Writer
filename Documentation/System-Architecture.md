# System Architecture

## Design goal

v4.1 is a file-backed novel orchestration layer shared by Claude Code, OpenAI Codex, and Pi.

It separates:

- canonical creative instructions
- harness-native adapters
- deterministic maintenance
- authored story state
- derived tracking state

The system avoids maintaining three divergent prompt stacks.

## Shared core

### AGENTS.md

`AGENTS.md` contains stable harness-neutral rules, ground-truth precedence, role resolution, workflow expectations, and validation commands.

Codex and Pi read it directly.

Claude Code reads `CLAUDE.md`, whose first line imports `AGENTS.md`. Claude-specific instructions follow the import.

### Canonical roles

Role definitions live under:

```text
.agents/roles/
```

They contain creative and editorial behavior without harness-specific frontmatter or tool names.

The seven roles are:

| Role | Responsibility |
| --- | --- |
| `chapter-writer` | Complete chapter drafting and substantive prose revision |
| `plot-architect` | Structure, turning points, chapter beats, setup, and payoff |
| `character-developer` | Motivation, arcs, relationships, voice, and knowledge |
| `worldbuilder` | Setting rules, institutions, history, geography, and systems |
| `continuity-editor` | Cross-file consistency and contradiction auditing |
| `smart-planner` | Pacing and next-action analysis |
| `error-recovery` | Tracking, JSON, scripts, and harness configuration recovery |

### Canonical skills

Skills live under:

```text
.agents/skills/<skill-name>/SKILL.md
```

These follow the Agent Skills directory format and provide the shared user workflows:

- `plan-novel`
- `write-chapter`
- `continuity-pass`
- `revise-chapter`
- `finalize-manuscript`

Each skill supports two execution paths:

1. delegate to the matching named specialist when the harness exposes one
2. read the canonical role file and perform the role directly

The second path keeps Pi fully functional without requiring a third-party delegation extension.

## Claude Code adapter

### Instructions

`CLAUDE.md` imports `AGENTS.md`.

### Custom agents

`.claude/agents/*.md` files preserve Claude-specific frontmatter, tool allowlists, model inheritance, and turn limits. Their bodies point to canonical role files.

### Skills

`.claude/skills/*/SKILL.md` files preserve Claude slash-command discovery and forward invocation arguments to canonical skills.

### Output style

`.claude/output-styles/autonomous-novelist.md` adjusts the main Claude conversation toward fiction work.

### Hooks

`.claude/settings.json` configures:

- `SessionStart`
- `SubagentStop` for `chapter-writer`
- `PreCompact`
- `SessionEnd`

## OpenAI Codex adapter

### Instructions

Codex reads root `AGENTS.md` before work.

### Skills

Codex discovers the canonical `.agents/skills/` tree directly. Users can mention a skill with `$skill-name` or inspect skills through `/skills`.

### Custom agents

Project custom agents live under:

```text
.codex/agents/*.toml
```

Each TOML file declares `name`, `description`, and `developer_instructions`. The developer instructions load `AGENTS.md` and the corresponding canonical role file.

`.codex/config.toml` enables agents and bounds concurrent subagent threads without pinning a model.

### Hooks

`.codex/hooks.json` configures project lifecycle hooks.

Codex requires project hooks to be reviewed and trusted. The repository uses:

- `SessionStart` for synchronization and current-state context
- `SubagentStop` for `chapter-writer`
- `PreCompact` for backup
- `SessionEnd` for word-delta logging

Codex expects valid JSON on successful `SubagentStop` stdout. `automation/codex-chapter-completed.sh` runs the shared chapter maintenance script and emits `{}` on success.

## Pi adapter

### Instructions and skills

Pi reads `AGENTS.md` and discovers `.agents/skills/` after project trust.

### Prompt templates

Project templates live under:

```text
.pi/prompts/*.md
```

They provide short `/plan-novel`-style commands and forward `$ARGUMENTS` to the canonical skill.

Pi also exposes canonical skills through `/skill:<name>`.

### Role execution

The repository does not bundle a Pi extension or third-party subagent package. Shared skills explicitly fall back to reading `.agents/roles/<name>.md` and executing the role in the current Pi session.

This keeps compatibility native and minimizes version-sensitive extension code.

## Deterministic maintenance

Scripts under `automation/` handle:

- state synchronization
- chapter writing signals
- chapter completion logging
- session word deltas
- backups
- health checks
- dashboard display

Creative judgment remains in the conversation, canonical roles, and skills.

## State model

### Source of truth

`manuscript/chapters/chapter-N.md` files are authoritative for drafted prose and actual word counts.

### Derived state

`sync-state.sh` updates:

- `planning/chapter-status.json`
- `planning/plot-progress.json`

The synchronizer preserves user planning metadata where possible.

### Authored creative state

These are authored or semi-authored sources, not purely generated state:

- `planning/novel-outline.json`
- `characters/`
- `worldbuilding/`

## Quality signals

`automation/quality-check.sh` measures mechanical signals such as:

- word count
- paragraph count
- average and maximum paragraph length
- approximate dialogue share
- anomaly warnings

These signals do not constitute a literary-quality score.

## Validation

`verify-system.sh` checks:

- canonical roles and skills
- Claude agent and skill adapters
- Codex agent TOML and hook JSON
- Pi prompt templates
- shell and Python syntax
- stale v3 references
- synchronized state and health

Missing harness CLIs produce warnings rather than failures. The repository can be prepared on a machine that has only one supported harness installed.

## Trust and security

Harness-specific project resources are executable or instruction-bearing content.

- Claude Code uses its workspace trust and permission flow.
- Codex requires project hook review through `/hooks`.
- Pi loads project resources after project trust.

The repository does not require permission bypass modes.
