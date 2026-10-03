# Syncing this fork with Lauren Tan's pstack

This repository is Michael Yu's fork of [`cursor/plugins/pstack`](https://github.com/cursor/plugins/tree/main/pstack)
(MIT, by poteto / Lauren Tan), translated so the skills run in Claude Code and Codex as well as Cursor.
It began as a fork of [`backnotprop/pstack`](https://github.com/backnotprop/pstack), whose harness-neutral
rewrites it keeps. Upstream is Cursor's repository, not backnotprop.

Two branches keep the translation safe:

- `upstream` holds Cursor's `pstack/` folder exactly, with no local edits. Each commit names the Cursor commit it copies.
- `main` is `upstream` plus the translation edits.

Never copy Cursor's files onto `main` directly. That erases the edits.

## Sync

```bash
scripts/sync-upstream.sh            # fetch Cursor's latest, update `upstream`, merge into `main`
scripts/sync-upstream.sh --check    # report only: is Cursor ahead of our `upstream` branch?
```

The script stops on a merge conflict. A conflict means Cursor changed a line this fork also changed.
Keep Cursor's new meaning and reapply the harness-neutral wording, then `git add -A && git commit`.
After every sync, read the script's "new Cursor-only instructions" report and rewrite any hits the way
the existing edits do. The Harness section in `skills/poteto-mode/SKILL.md` lists the mappings. Then
refresh the bundled Comment Sicko prompt:

```bash
cp agents/comment-sicko.md skills/no-comments/references/comment-sicko.md
git push origin main upstream
```

## Translation rules (the substitution map)

| Upstream (Cursor) | Here |
|---|---|
| `~/.cursor/rules/pstack-models.mdc` | "the pstack settings file (`~/.cursor/rules/pstack-models.mdc` in Cursor, `~/.agents/pstack-models.md` in other harnesses)" |
| `Task` tool, `subagent_type: generalPurpose` | kept, with an **Other harnesses** paragraph mapping to `Agent` (Claude Code), `spawn_agent` (Codex), `task` (OpenCode) |
| Cursor cloud agents (`environment: "cloud"`) | local subagents, one worktree or output path each |
| `agent-transcripts/` | per-harness session directories, listed in `show-me-your-work` |
| `.cursor/skills/`, `~/.cursor/skills/` | `.claude/skills/`, `.agents/skills/`, and user equivalents |
| `AskQuestion` | "your structured-question tool" (`AskUserQuestion` in Claude Code) |
| `deslop`, `control-ui`, `control-cli`, `create-skill` | `unslop`, the project's `verify-<app>` skill, and the agentskills.io format |
| Graphite / Origin CLI | kept verbatim, gated on `command -v origin`; `gh` is the default |
| `name: Poteto Mode`, `name: Make Bot UI` (display names with spaces) | `name: poteto-mode`, `name: make-bot-ui`. Claude Code requires lowercase-hyphen skill names equal to the directory; the desktop app otherwise registers no usable slash command. |
