# Changelog

## 4.1.0 - 2026-08-21

### Shared multi-harness core

- Added root `AGENTS.md` as the canonical project instruction file.
- Added canonical specialist definitions under `.agents/roles/`.
- Added canonical Agent Skills workflows under `.agents/skills/`.
- Changed `CLAUDE.md` to import `AGENTS.md` and keep only Claude-specific adapter notes.
- Replaced full Claude role and skill copies with thin adapters to the shared core.

### OpenAI Codex

- Added `.codex/config.toml` with bounded multi-agent concurrency.
- Added seven project custom agents under `.codex/agents/`.
- Added `.codex/hooks.json` for session start, chapter completion, pre-compaction backup, and session-end logging.
- Added a JSON-safe Codex `SubagentStop` adapter for chapter maintenance.
- Documented `$skill-name`, `/skills`, `/agent`, and `/hooks` usage.

### Pi

- Added native discovery through `.agents/skills/`.
- Added `.pi/prompts/` templates for short `/plan-novel`, `/write-chapter`, `/continuity-pass`, `/revise-chapter`, and `/finalize-manuscript` commands.
- Added direct canonical-role fallback so Pi works without a third-party subagent extension.
- Documented `/skill:<name>` invocation and project trust.

### Automation and validation

- Generalized session temporary-file names beyond Claude Code.
- Expanded system health and verification across Claude Code, Codex, and Pi.
- Added JSON and TOML validation for harness configuration.
- Updated the launcher to detect all three supported CLIs.

### Documentation

- Rebranded v4.1 as Multi-Agent Novel Writer.
- Added a compatibility guide and cross-harness invocation matrices.
- Rewrote the README, user guide, architecture guide, and documentation index.

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
