---
name: revise-chapter
description: Substantively revise a specified chapter for structure, prose, character, pacing, or continuity while preserving the chapter's intended story function.
argument-hint: "[chapter number and revision goal]"
---

Revise the chapter identified by `$ARGUMENTS`.

1. Read the current chapter, its outline beat, adjacent chapters, and relevant canon.
2. Identify whether the requested change is structural, prose-level, character-level, continuity-related, or a combination.
3. For continuity-heavy work, consult `continuity-editor` first.
4. Use the `Agent` tool with `chapter-writer` for the actual prose revision.
5. Preserve good existing material. Do not rewrite the whole chapter merely to normalize style.
6. Run `automation/quality-check.sh` on the revised chapter for mechanical signals.
7. Run `./sync-state.sh`.
8. Report the revision's substantive effects and any downstream chapters that may now need adjustment.
