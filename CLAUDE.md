# Claude Code Novel Writer v4

## Purpose

This repository is a long-form fiction workspace. Help the user plan, draft, revise, and maintain a novel while preserving continuity and the user's creative intent.

## Operating rules

1. Treat files in `manuscript/chapters/` as the source of truth for drafted prose.
2. Treat `planning/`, `characters/`, and `worldbuilding/` as working state that must agree with the manuscript.
3. Inspect existing files before creating or replacing substantial story content.
4. Preserve established canon unless the user explicitly asks to change it.
5. Do not claim that heuristic metrics prove literary or publication quality.
6. Do not invent completion, validation, or recovery that did not actually occur.
7. Prefer normal Claude Code permissions. Do not instruct users to bypass permissions unless they explicitly choose that tradeoff.
8. Keep generated state machine-readable where JSON already exists.
9. When a workflow has a matching project skill, prefer that skill.
10. Use the `Agent` tool for specialized delegation.

## Ground-truth order

When sources disagree, use this order unless the user says otherwise:

1. Explicit instructions from the user
2. Existing manuscript prose
3. Accepted outline and planning files
4. Character and world state
5. Derived metrics, flags, and automation output

If tracking disagrees with manuscript files, run `./sync-state.sh` rather than rewriting prose to match stale tracking.

## Agent map

Delegate focused work with the `Agent` tool:

- `plot-architect`: premise, structure, outline, turning points, chapter beats
- `chapter-writer`: complete chapter drafting and prose revision
- `character-developer`: motivation, arcs, relationships, voice, knowledge state
- `worldbuilder`: setting, systems, institutions, history, constraints
- `continuity-editor`: contradictions, timeline, knowledge, unresolved setups, canon checks
- `smart-planner`: pacing, next-step analysis, scope adjustment, milestone planning
- `error-recovery`: diagnose broken tracking, scripts, JSON, or workflow state

Do not delegate merely to create activity. Use an agent when specialization or an isolated task materially helps.

## Drafting workflow

Before drafting a chapter:

1. Read `planning/novel-outline.json` when present.
2. Read `planning/plot-progress.json` and `planning/chapter-status.json`.
3. Read the previous chapter and any directly relevant earlier chapters.
4. Read relevant character and world files.
5. Confirm the target chapter does not already contain substantial prose.

For a new chapter, delegate the complete draft to `chapter-writer`. Give it the chapter goal, required beats, POV, continuity constraints, and any style requirements. Prefer one coherent chapter over many disconnected scene fragments.

After a chapter is written, the `SubagentStop` hook runs chapter maintenance. If state still looks stale, run `./sync-state.sh`.

## Planning workflow

Use `/plan-novel` for a new project or a structural replan. Planning should produce enough detail to guide drafting without locking every scene prematurely.

Keep the outline adaptable. Update it when the story changes intentionally.

## Revision workflow

Use `/revise-chapter` for substantive chapter revision and `/continuity-pass` for cross-chapter consistency.

Before revising, distinguish between:

- prose/style problems
- structural problems
- continuity problems
- intentional ambiguity
- user-preferred stylistic choices

Do not "fix" intentional voice into generic prose.

## Milestones

At useful intervals:

- review continuity across recent chapters
- check unresolved setups and character knowledge
- reassess pacing against the outline
- update planning if the drafted story has evolved

Flags in `planning/continuity-flag.txt` and `planning/planning-flag.txt` are reminders, not commands.

## Completion

A manuscript is not finished because it reaches a word count. When the user is ready to finish, use `/finalize-manuscript` to review structure, continuity, unresolved threads, chapter order, and revision priorities.

## Useful commands

```bash
./launch-novel.sh
./sync-state.sh
./verify-system.sh
automation/system-health-check.sh
automation/quality-check.sh
python3 automation/dashboard.py
```
