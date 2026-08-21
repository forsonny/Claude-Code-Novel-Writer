---
name: write-chapter
description: Draft the next chapter or a specified chapter from the accepted outline while preserving manuscript continuity and established voice.
argument-hint: "[chapter number or chapter-specific constraints]"
---

Draft a chapter using `$ARGUMENTS`.

1. Run or inspect `./sync-state.sh` output to determine current file state.
2. Resolve the target chapter from the argument, outline, and tracking state.
3. Refuse to overwrite substantial existing prose unless the request clearly asks for revision.
4. Read the relevant outline beat, previous chapter, character state, world state, and continuity notes.
5. Use the `Agent` tool with `chapter-writer` to produce the complete chapter in `manuscript/chapters/chapter-N.md`.
6. Let the chapter-writer completion hook run its maintenance.
7. If the hook did not leave tracking aligned, run `./sync-state.sh`.
8. Report what changed in the story and any continuity facts that should affect the next chapter.

Do not split a normal chapter into many agent calls unless there is a concrete reason such as a very large chapter or a difficult revision.
