---
name: install-dev-kit
description: >-
  Install this cursor-dev-kit into ~/.cursor (skills, rules, agents) and merge
  Serena MCP. Use only when the user invokes /install-dev-kit.
disable-model-invocation: true
---

# Install cursor-dev-kit

Slash command for the **cursor-dev-kit** repo (or after personal install). No required arguments.

## What it does

Runs the repo’s `install.sh` from the kit root so this machine gets:

- Skills → `~/.cursor/skills/`
- Rules → `~/.cursor/rules/`
- Agents → `~/.cursor/agents/`
- Serena MCP merged into `~/.cursor/mcp.json` only if `serena` is missing

Existing same-named items are backed up under `~/.cursor/dev-kit-backup/<timestamp>/`.

## Steps

1. Resolve kit root: directory that contains `install.sh` and folders `skills/`, `rules/`, `agents/`. Prefer the current workspace root when this project skill is used from a clone; if only the personal skill exists, ask the user for the clone path or use the path they provide.
2. Run: `bash "<kit-root>/install.sh"` (full permissions / network not required for file copy; network only if user later installs uv/rtk).
3. Report installer stdout: skills/rules/agents installed, MCP merge result, dependency check lines.
4. Remind: reload Cursor MCP if Serena was added; in each **app** repo run `/bootstrap-coding-standards` then `/setup-serena`.
5. Do **not** edit product application code. Do not overwrite `project.local.yml` or touch unrelated MCP servers beyond merging `serena` when absent.
