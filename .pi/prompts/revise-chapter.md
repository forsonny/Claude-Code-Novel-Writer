---
description: Revise a specified chapter for the requested goals.
argument-hint: "[chapter number and revision goal]"
---

Follow `AGENTS.md`.

Load and execute the project skill at `.agents/skills/revise-chapter/SKILL.md`.

Invocation arguments: `${ARGUMENTS:-no additional arguments}`

Complete the workflow end-to-end. If Pi has no named specialist subagent available, read the requested `.agents/roles/` file and perform that role directly in this session.
