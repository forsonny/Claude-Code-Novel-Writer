# Multi-Agent Novel Writer v4.1

A file-backed novel planning, drafting, revision, and continuity workspace compatible with Claude Code, OpenAI Codex, and Pi.

The repository uses one shared creative core:

- `AGENTS.md` for harness-neutral project guidance
- `.agents/roles/` for canonical specialist roles
- `.agents/skills/` for canonical writing workflows
- manuscript files as the source of truth
- deterministic scripts for synchronization and diagnostics

Claude Code, Codex, and Pi each receive a thin native adapter instead of three independent copies of the novel system.

## Compatibility

| Capability | Claude Code | OpenAI Codex | Pi |
| --- | --- | --- | --- |
| Project instructions | `CLAUDE.md` imports `AGENTS.md` | `AGENTS.md` | `AGENTS.md` |
| Shared skills | `.claude/skills/` adapters | `.agents/skills/` | `.agents/skills/` |
| Named specialists | `.claude/agents/*.md` | `.codex/agents/*.toml` | Canonical role fallback |
| Short workflow commands | `/plan-novel` | `$plan-novel` or `/skills` | `/plan-novel` or `/skill:plan-novel` |
| Lifecycle maintenance | `.claude/settings.json` | `.codex/hooks.json` | Skills run maintenance explicitly |
| Writing style adapter | Claude output style | `AGENTS.md` and roles | `AGENTS.md` and roles |

Pi does not need a third-party subagent extension. When named subagents are unavailable, the workflow reads the canonical role and performs it in the current session.

## Requirements

- Python 3
- Bash-compatible shell for included automation
- At least one supported agent harness:
  - Claude Code
  - OpenAI Codex
  - Pi

## Quick start

```bash
git clone https://github.com/forsonny/Claude-Code-Novel-Writer.git
cd Claude-Code-Novel-Writer
./launch-novel.sh
```

Then start one harness.

### Claude Code

```bash
claude
```

Inside Claude Code:

```text
/plan-novel
/write-chapter
/continuity-pass
/revise-chapter
/finalize-manuscript
```

### OpenAI Codex

```bash
codex
```

Mention a project skill in the prompt:

```text
$plan-novel
$write-chapter 7
$continuity-pass 4-9
$revise-chapter 7 tighten the midpoint confrontation
$finalize-manuscript
```

You can also use `/skills` to inspect available skills and `/agent` to inspect subagent threads.

Codex project hooks are reviewable project resources. Open `/hooks` and trust the repository hooks before relying on automatic session and chapter maintenance.

### Pi

```bash
pi
```

The project includes short prompt templates:

```text
/plan-novel
/write-chapter 7
/continuity-pass 4-9
/revise-chapter 7 tighten the midpoint confrontation
/finalize-manuscript
```

Pi also exposes the shared skills directly:

```text
/skill:plan-novel
/skill:write-chapter 7
```

Project skills and prompt templates load after the project is trusted.

## Architecture

```text
.
├── AGENTS.md                         # Canonical project guidance
├── CLAUDE.md                         # Claude imports AGENTS.md
├── .agents/
│   ├── roles/                        # Canonical specialist roles
│   └── skills/                       # Canonical Agent Skills workflows
├── .claude/
│   ├── agents/                       # Claude custom-agent adapters
│   ├── skills/                       # Claude slash-command adapters
│   ├── output-styles/
│   └── settings.json                 # Claude lifecycle hooks
├── .codex/
│   ├── agents/                       # Codex project custom agents
│   ├── config.toml
│   └── hooks.json                    # Codex lifecycle hooks
├── .pi/
│   └── prompts/                      # Pi short workflow commands
├── manuscript/chapters/
├── planning/
├── characters/
├── worldbuilding/
└── automation/
```

## Shared roles

Seven canonical roles live under `.agents/roles/`:

- `chapter-writer`
- `plot-architect`
- `character-developer`
- `worldbuilder`
- `continuity-editor`
- `smart-planner`
- `error-recovery`

Claude Code and Codex expose these as native named specialists. Pi follows the same role files directly unless the user has added a compatible delegation extension.

## Shared skills

Five canonical skills live under `.agents/skills/`:

- `plan-novel`
- `write-chapter`
- `continuity-pass`
- `revise-chapter`
- `finalize-manuscript`

Codex and Pi discover this shared location natively. Claude slash commands are thin adapters that load the same workflow files.

## State and source of truth

Manuscript files under `manuscript/chapters/` are authoritative. Tracking is derived and can be regenerated:

```bash
./sync-state.sh
```

Diagnostics:

```bash
./verify-system.sh
automation/system-health-check.sh
python3 automation/dashboard.py
```

Continuous dashboard:

```bash
python3 automation/dashboard.py --monitor
```

## Quality philosophy

`automation/quality-check.sh` records mechanical signals such as word count, paragraph length, and approximate dialogue share. These can reveal anomalies, but they do not determine literary quality.

Revision decisions should use chapter purpose, voice, pacing, continuity, motivation, and reader effect.

## Permissions and trust

Use each harness's normal permission and project-trust flow.

Claude hooks are defined in `.claude/settings.json`. Codex hooks are defined in `.codex/hooks.json` and require review through `/hooks`. Pi project resources load only after the project is trusted.

Review hooks, skills, prompts, and scripts before running a repository you did not create.

## Documentation

- `Documentation/User-Guide.md`
- `Documentation/System-Architecture.md`
- `Documentation/Compatibility.md`
- `CHANGELOG.md`

## Official references

Claude Code memory and AGENTS.md interoperability:

https://code.claude.com/docs/en/memory

OpenAI Codex AGENTS.md:

https://learn.chatgpt.com/docs/agent-configuration/agents-md

OpenAI Codex skills:

https://learn.chatgpt.com/docs/build-skills

OpenAI Codex subagents:

https://learn.chatgpt.com/docs/agent-configuration/subagents

OpenAI Codex hooks:

https://learn.chatgpt.com/docs/hooks

Pi skills:

https://pi.dev/docs/latest/skills

Pi prompt templates:

https://pi.dev/docs/latest/prompt-templates
