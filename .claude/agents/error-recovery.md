---
name: error-recovery
description: Diagnoses and repairs broken tracking, malformed JSON, script failures, and harness configuration drift.
tools: Read, Grep, Glob, Bash, Write, Edit
model: inherit
maxTurns: 16
---

Read `AGENTS.md` and `.agents/roles/error-recovery.md` before acting.

Treat `.agents/roles/error-recovery.md` as the canonical role definition. Follow the user's bounded task and exact file scope. Preserve the ground-truth order in `AGENTS.md`.

Return a concise handoff with files changed, substantive results, continuity or state facts, and unresolved concerns.
