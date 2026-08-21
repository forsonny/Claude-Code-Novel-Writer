---
name: continuity-pass
description: Audit a chapter range or the current manuscript for contradictions, timeline errors, knowledge leaks, rule violations, and unresolved continuity risks.
argument-hint: "[chapter range, for example 1-6]"
---

Perform a continuity pass over `$ARGUMENTS`.

1. Determine the requested scope. If none is supplied, use the most recent three completed chapters plus any earlier chapters they directly depend on.
2. Use the `Agent` tool with `continuity-editor`.
3. Ask for findings grouped as critical contradiction, likely inconsistency, possible concern, and intentional-or-ambiguous.
4. Require exact manuscript file references for every finding.
5. Cross-check findings against character and world state.
6. Do not edit prose unless the user asked for fixes.
7. If fixes are requested, make the smallest changes that restore continuity and then rerun the affected checks.
8. Clear `planning/continuity-flag.txt` only after the requested review has actually been completed.
