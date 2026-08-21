# Multi-Agent Novel Writer v4.1

## Purpose

This repository is a long-form fiction workspace for planning, drafting, revising, and maintaining a novel across Claude Code, OpenAI Codex, and Pi.

Preserve the user's creative intent, established voice, and story continuity. Use automation as support, not as proof of literary quality.

## Supported harnesses

- Claude Code uses `CLAUDE.md`, `.claude/agents/`, `.claude/skills/`, the project output style, and Claude lifecycle hooks.
- OpenAI Codex reads this `AGENTS.md`, discovers `.agents/skills/`, loads project agents from `.codex/agents/`, and can run `.codex/hooks.json`.
- Pi reads this `AGENTS.md`, discovers `.agents/skills/`, and exposes project prompt templates from `.pi/prompts/`.

The shared source of truth for roles and workflows lives under `.agents/`. Harness-specific directories are adapters.

## Ground-truth order

When sources disagree, use this order unless the user says otherwise:

1. Explicit instructions from the user
2. Existing prose in `manuscript/chapters/`
3. Accepted outline and planning files
4. Character and world state
5. Derived metrics, flags, logs, and automation output

Manuscript files are authoritative for drafted prose and actual word counts. If tracking disagrees with manuscript files, run `./sync-state.sh`. Do not rewrite prose to match stale tracking.

## Core operating rules

1. Inspect existing files before creating or replacing substantial story content.
2. Preserve established canon unless the user explicitly authorizes a change.
3. Confirm the target chapter does not already contain substantial prose before drafting.
4. Keep character knowledge, chronology, physical state, and world rules consistent.
5. Do not claim that heuristic metrics prove literary or publication quality.
6. Do not invent completion, validation, recovery, or test results.
7. Keep JSON machine-readable where JSON is already used.
8. Prefer the smallest useful change during revision or continuity repair.
9. Do not delegate merely to create activity.
10. For repository maintenance, temporarily prioritize technically correct edits and validation over fiction generation.
11. Use normal harness permissions and project trust. Do not recommend bypassing safeguards as a default.
12. Before finishing repository changes, run the relevant validation commands.

## Canonical specialist roles

Role definitions live in `.agents/roles/`:

- `plot-architect`: premise, structure, turning points, chapter beats, setup, and payoff
- `chapter-writer`: complete chapter drafting and substantive prose revision
- `character-developer`: motivation, arcs, relationships, voice, and knowledge state
- `worldbuilder`: setting, institutions, history, geography, systems, and constraints
- `continuity-editor`: timeline, knowledge, physical state, names, rules, setups, and payoffs
- `smart-planner`: pacing, milestone analysis, and the next high-value action
- `error-recovery`: broken tracking, malformed JSON, scripts, and harness configuration

### Specialist execution protocol

If the current harness exposes a named specialist or custom subagent, use the exact role name above when specialization materially helps.

If named subagents are unavailable, disabled, or unnecessary, read the matching file in `.agents/roles/` and perform the role directly in the current session.

When delegating:

- provide a bounded task and exact file scope
- include the relevant chapter, outline, character, world, and continuity context
- require a concise handoff with changed files, story-state changes, and unresolved concerns
- keep creative decisions in the main workflow when they affect the user's intent

Pi compatibility does not require a third-party subagent extension. Pi can execute the canonical role directly.

## Shared project skills

Canonical skills live in `.agents/skills/`:

- `plan-novel`
- `write-chapter`
- `continuity-pass`
- `revise-chapter`
- `finalize-manuscript`

Harness invocation:

- Claude Code: use the matching slash command, such as `/write-chapter 7`
- Codex: mention the skill, such as `$write-chapter 7`, or select it through `/skills`
- Pi: use `/skill:write-chapter 7`, or the shorter project template `/write-chapter 7`

The Claude and Pi command layers are adapters. The canonical workflow remains the file under `.agents/skills/<name>/SKILL.md`.

## Planning workflow

Before planning:

1. Inspect `planning/`, `characters/`, `worldbuilding/`, and existing manuscript files.
2. Treat substantial manuscript prose as canon unless the user requests a retcon.
3. Identify premise, viewpoint, structural shape, central conflict, stakes, and character arcs.
4. Build causally connected chapter purposes rather than a list of unrelated events.
5. Record unresolved creative choices as explicit questions or provisional decisions.
6. Update `planning/novel-outline.json`.
7. Run `./sync-state.sh` when tracking needs initialization or reconciliation.

Use the `plan-novel` skill for the full procedure.

## Drafting workflow

Before drafting a chapter:

1. Run or inspect `./sync-state.sh`.
2. Read `planning/novel-outline.json` when present.
3. Read `planning/plot-progress.json` and `planning/chapter-status.json`.
4. Read the previous chapter and any directly relevant earlier chapters.
5. Read relevant character, world, and continuity state.
6. Confirm the target path does not already contain substantial prose.
7. Draft one coherent complete chapter unless the task calls for a bounded partial draft.

After writing:

1. Run `automation/quality-check.sh <chapter-path>` for mechanical signals.
2. Run `./sync-state.sh`.
3. Report the file, approximate word count, story-state changes, and continuity facts.
4. Note any downstream chapter or planning changes that may be needed.

Claude Code and Codex may perform some of this through trusted lifecycle hooks. Verify the resulting state rather than assuming the hook ran.

## Revision workflow

Before revising, distinguish among:

- prose and voice problems
- structural problems
- character motivation problems
- pacing problems
- continuity problems
- intentional ambiguity
- user-preferred stylistic choices

Preserve good existing material. Do not rewrite a whole chapter merely to normalize style. Recheck affected continuity after substantive changes.

## Continuity workflow

Audit before editing. Separate true contradictions from intentional ambiguity, unreliable narration, delayed revelation, or plausible off-page change.

Findings should include exact file references and be grouped by severity. Apply the smallest fix that restores consistency when the user asks for edits.

## Completion workflow

A manuscript is not complete merely because it reaches a word count. Before final polish, review:

- structural gaps
- unresolved promises and subplots
- character arc resolution
- continuity and chronology
- chapter order and pacing
- incomplete or unusually short chapter files
- revision priorities

Do not declare publication readiness solely because automated checks pass.

## Useful commands

```bash
./launch-novel.sh
./sync-state.sh
./verify-system.sh
automation/system-health-check.sh
automation/quality-check.sh manuscript/chapters/chapter-N.md
python3 automation/dashboard.py
```

## Repository validation

For configuration changes, validate all active adapters:

```bash
./verify-system.sh
python3 -m json.tool .claude/settings.json
python3 -m json.tool .codex/hooks.json
python3 -m py_compile automation/dashboard.py
```

Use Python `tomllib` to validate `.codex/config.toml` and `.codex/agents/*.toml` when Python 3.11 or newer is available.
