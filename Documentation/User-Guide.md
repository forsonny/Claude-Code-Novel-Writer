# User Guide

## 1. Initialize the project

```bash
./launch-novel.sh
```

The launcher checks Python, prepares generated directories, synchronizes state, and runs repository verification.

Start Claude Code normally:

```bash
claude
```

v4 does not require `--dangerously-skip-permissions`.

## 2. Output style

The repository includes:

```text
.claude/output-styles/autonomous-novelist.md
```

`.claude/settings.json` selects **Autonomous Novelist** for this project. Change it through `/config` if you want another output style.

## 3. Start a novel

Inside Claude Code:

```text
/plan-novel
```

You can append a premise or constraints:

```text
/plan-novel political fantasy about a disgraced cartographer; 80k target; close third person
```

The skill inspects existing project state before planning and delegates structural work to the `plot-architect`.

## 4. Draft chapters

Draft the next chapter:

```text
/write-chapter
```

Draft a specific chapter:

```text
/write-chapter 7
```

The skill reads the outline and relevant canon, then delegates complete drafting to `chapter-writer`.

When `chapter-writer` finishes, a `SubagentStop` hook:

1. synchronizes tracking from manuscript files
2. records lightweight writing signals
3. logs completed chapters
4. creates periodic continuity or planning reminders

## 5. Review continuity

```text
/continuity-pass
```

Or specify a range:

```text
/continuity-pass 4-9
```

The continuity editor checks timeline, character knowledge, physical state, world rules, names, setups, and payoffs. It should report findings before editing unless you ask it to fix them.

## 6. Revise a chapter

```text
/revise-chapter 7 tighten the midpoint confrontation and preserve Mara's dry voice
```

The revision workflow distinguishes structural, prose, character, and continuity problems before editing.

## 7. Finalize a manuscript

```text
/finalize-manuscript
```

This performs a manuscript-level review and produces a prioritized revision plan. Automated checks do not certify publication readiness.

## 8. State synchronization

Manuscript files are ground truth.

If tracking looks wrong:

```bash
./sync-state.sh
```

The command regenerates `planning/chapter-status.json` and updates `planning/plot-progress.json` from the actual chapter files.

## 9. Diagnostics

```bash
./verify-system.sh
automation/system-health-check.sh
automation/quality-check.sh
python3 automation/dashboard.py
```

`quality-check.sh` records mechanical signals. It does not score literary quality.

## 10. Resuming work

Starting Claude Code triggers the `SessionStart` hook. It synchronizes state, runs a quick health check, and injects a short summary of the current manuscript position into the session.

This replaces the old `.claude/context-injection.txt` accumulation loop.
