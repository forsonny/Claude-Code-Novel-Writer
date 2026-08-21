---
name: plan-novel
description: Create or substantially revise a novel premise, structure, chapter plan, character arcs, and required world foundations. Use for a new novel or major structural replan.
---

# Plan Novel

Use any premise, constraints, or priorities supplied with the invocation.

1. Resolve the repository root and inspect `planning/`, `characters/`, `worldbuilding/`, and `manuscript/chapters/`.
2. Treat substantial manuscript prose as canon unless the user explicitly requests a retcon.
3. Read `.agents/roles/plot-architect.md`.
4. If the harness exposes a named `plot-architect` specialist, delegate a bounded planning task to it. Otherwise perform that role directly.
5. Use `character-developer` and `worldbuilder` only for foundations that materially affect the plan.
6. Create causally connected chapter purposes, turning points, setups, payoffs, and character decisions.
7. Write or update `planning/novel-outline.json`.
8. Record unresolved creative choices as explicit questions or provisional decisions, not hidden assumptions.
9. Run `./sync-state.sh` when tracking needs initialization or reconciliation.
10. Summarize the premise, structural shape, major arcs, chapter count, open decisions, and next recommended drafting action.
