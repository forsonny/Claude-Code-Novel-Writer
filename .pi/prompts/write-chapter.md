---
description: Draft the next or specified chapter using the shared project skill.
argument-hint: "[chapter number or constraints]"
---

Follow `AGENTS.md`.

Load and execute the project skill at `.agents/skills/write-chapter/SKILL.md`.

Invocation arguments: `${ARGUMENTS:-no additional arguments}`

Complete the workflow end-to-end. If Pi has no named specialist subagent available, read the requested `.agents/roles/` file and perform that role directly in this session.
