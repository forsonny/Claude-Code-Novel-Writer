---
description: Audit the requested manuscript scope for continuity problems.
argument-hint: "[chapter range or priorities]"
---

Follow `AGENTS.md`.

Load and execute the project skill at `.agents/skills/continuity-pass/SKILL.md`.

Invocation arguments: `${ARGUMENTS:-no additional arguments}`

Complete the workflow end-to-end. If Pi has no named specialist subagent available, read the requested `.agents/roles/` file and perform that role directly in this session.
