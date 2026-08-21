@AGENTS.md

# Claude Code adapter

The imported `AGENTS.md` is the canonical project guidance.

Claude Code-specific resources:

- `.claude/agents/` contains native custom-agent adapters for the canonical roles in `.agents/roles/`.
- `.claude/skills/` contains slash-command adapters for the canonical skills in `.agents/skills/`.
- `.claude/output-styles/autonomous-novelist.md` provides the project writing style.
- `.claude/settings.json` selects that style and configures lifecycle hooks.

Use the `Agent` tool with the exact specialist names in `AGENTS.md`. When a Claude skill is invoked, read and follow its canonical `.agents/skills/` workflow.

The `chapter-writer` `SubagentStop` hook runs chapter maintenance. If tracking still looks stale, run `./sync-state.sh` directly.
