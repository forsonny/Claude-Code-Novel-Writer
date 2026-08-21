# Changelog

## 4.0.0 - 2026-08-21

### Claude Code modernization

- Replaced active `Task` terminology with the current `Agent` tool.
- Replaced the stale `PostToolUse` agent-name matcher with a `SubagentStop` hook for `chapter-writer`.
- Removed the `.claude/context-injection.txt` feedback loop from the active architecture.
- Added project skills for planning, chapter drafting, continuity review, revision, and manuscript finalization.
- Moved the Autonomous Novelist output style into `.claude/output-styles/`.
- Updated project settings to select the project output style directly.
- Rewrote `CLAUDE.md` as concise stable project instructions.
- Rebuilt all seven agent definitions around current Claude Code tool names and bounded responsibilities.

### Automation

- Reworked `sync-state.sh` so manuscript files are the source of truth.
- Reworked chapter-completion maintenance around the `SubagentStop` lifecycle.
- Replaced the old numeric quality-control system with mechanical writing signals and explicit warnings that they do not measure literary quality.
- Reworked session initialization to inject a concise current-state summary through hook stdout.
- Reworked session summaries to use the hook `session_id`.
- Rebuilt system health and verification checks around the v4 layout.
- Removed automatic package installation and bypass-permission recommendations from setup.

### Documentation

- Rewrote the README, user guide, and architecture guide for v4.
- Corrected the `scene-writer` versus `chapter-writer` drift.
- Documented current project skill, output style, subagent, and hook locations.

### Compatibility

- `setup-enhancements.sh` remains as a wrapper around `launch-novel.sh`.
- Existing manuscript, planning, character, worldbuilding, dashboard, backup, and ancillary automation files remain in place unless superseded by the v4 scripts.
