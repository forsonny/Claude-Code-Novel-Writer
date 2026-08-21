---
name: plan-novel
description: Create or substantially revise the novel's structure, premise, chapter plan, character arc plan, and required world foundations. Use for a new novel or a major structural replan.
argument-hint: "[premise or planning constraints]"
---

Plan the novel using the user's request and `$ARGUMENTS`.

1. Inspect existing `planning/`, `characters/`, `worldbuilding/`, and manuscript files.
2. If substantial manuscript prose exists, treat it as canon unless the user explicitly requests a retcon.
3. Use the `Agent` tool with `plot-architect` to design the story structure and chapter purposes.
4. Use `character-developer` and `worldbuilder` only for foundations that materially affect the plan.
5. Write or update `planning/novel-outline.json`.
6. Record unresolved creative choices as explicit open questions or provisional decisions, not hidden assumptions.
7. Run `./sync-state.sh` after planning if tracking files need initialization.

Return a concise summary of the premise, structural shape, major arcs, chapter count, and the next recommended drafting action.
