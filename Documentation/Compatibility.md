# Claude Code, Codex, and Pi Compatibility

## Canonical versus adapter files

Canonical files:

```text
AGENTS.md
.agents/roles/
.agents/skills/
```

Adapters:

```text
CLAUDE.md
.claude/
.codex/
.pi/prompts/
```

Edit canonical files first. Keep adapters thin.

## Invocation matrix

| Workflow | Claude Code | Codex | Pi |
| --- | --- | --- | --- |
| Plan | `/plan-novel` | `$plan-novel` | `/plan-novel` or `/skill:plan-novel` |
| Draft | `/write-chapter 7` | `$write-chapter 7` | `/write-chapter 7` or `/skill:write-chapter 7` |
| Continuity | `/continuity-pass 4-9` | `$continuity-pass 4-9` | `/continuity-pass 4-9` |
| Revision | `/revise-chapter 7 ...` | `$revise-chapter 7 ...` | `/revise-chapter 7 ...` |
| Final review | `/finalize-manuscript` | `$finalize-manuscript` | `/finalize-manuscript` |

## Specialist matrix

| Role | Claude Code | Codex | Pi |
| --- | --- | --- | --- |
| Chapter writer | Native custom agent | Native project custom agent | Direct canonical role |
| Plot architect | Native custom agent | Native project custom agent | Direct canonical role |
| Character developer | Native custom agent | Native project custom agent | Direct canonical role |
| Worldbuilder | Native custom agent | Native project custom agent | Direct canonical role |
| Continuity editor | Native custom agent | Native project custom agent | Direct canonical role |
| Smart planner | Native custom agent | Native project custom agent | Direct canonical role |
| Error recovery | Native custom agent | Native project custom agent | Direct canonical role |

A Pi delegation extension can be added later, but it is not a dependency of the repository.

## Lifecycle matrix

| Lifecycle | Claude Code | Codex | Pi |
| --- | --- | --- | --- |
| Session state context | `SessionStart` hook | `SessionStart` hook | Read through `AGENTS.md`; skills synchronize |
| Chapter completion | `SubagentStop` hook | `SubagentStop` hook | Skill post-write steps |
| Pre-compaction backup | `PreCompact` hook | `PreCompact` hook | Manual or custom extension |
| Session word log | `SessionEnd` hook | `SessionEnd` hook | Manual or custom extension |

## Why shared `.agents/skills`

Codex and Pi both discover project skills under `.agents/skills/`. Keeping the canonical skills there provides progressive disclosure and prevents the Claude, Codex, and Pi workflows from drifting apart.

Claude Code keeps adapters under `.claude/skills/` so its native slash commands remain available.

## Why AGENTS.md is canonical

Codex reads `AGENTS.md` directly. Pi also reads project agent instructions. Claude Code officially supports importing `AGENTS.md` from `CLAUDE.md`, so the repository can share one core instruction file without relying on symlinks.

## Why Pi uses prompt templates

Pi skills are available as `/skill:<name>`. Project prompt templates under `.pi/prompts/` add shorter `/name` commands and forward invocation arguments to the shared skill.

This is a small, stable adapter with no TypeScript extension API dependency.

## Codex hook trust

Codex project hooks do not silently run merely because they are committed. Review them in Codex:

```text
/hooks
```

Trust the exact hook definitions after inspecting `.codex/hooks.json` and the referenced scripts.

## Pi project trust

Pi only loads project skills and prompt templates after the project is trusted. Review `AGENTS.md`, `.agents/skills/`, and `.pi/prompts/` before granting trust to an unfamiliar repository.

## Adding another harness

A future harness should ideally consume:

1. `AGENTS.md`
2. `.agents/skills/`
3. `.agents/roles/`

Add only the smallest native adapter needed for command discovery, named-agent registration, or lifecycle hooks.
