---
name: install-dev-kit
description: >-
  Install cursor-dev-kit into ~/.cursor, clean leftover Caveman under ~/.cursor
  and ~/.agents, run official Caveman --only cursor, merge Serena MCP. Use only
  when the user invokes /install-dev-kit.
disable-model-invocation: true
---

# Install cursor-dev-kit

Slash command for the **cursor-dev-kit** repo (or after personal install). No required arguments.

## What it does

Runs the repo’s `install.sh` from the kit root:

1. **Cleanup** (backup then remove): `~/.cursor/rules/caveman.mdc`, `~/.cursor/skills/caveman`, `~/.cursor/caveman`, and `~/.agents/skills/caveman` / `caveman-*` / `cavecrew`.
2. Copy kit skills / rules / agents into `~/.cursor` (skips kit caveman skill and any `caveman.mdc`).
3. Merge Serena into `~/.cursor/mcp.json` if `serena` is missing.
4. Run official Caveman: `npx -y github:JuliusBrussee/caveman#v4.1.0 -- --only cursor` (**needs network + Node/npx**).
5. Restore **rtk** shell hook if it was present and got dropped.
6. Print bind checks (`~/.cursor/caveman`, hooks.json).

## Steps

1. Resolve kit root: directory with `install.sh` and folders `skills/`, `rules/`, `agents/`. Prefer workspace root when this project skill is used from a clone; otherwise ask for the clone path.
2. Run: `bash "<kit-root>/install.sh"` with network available for `npx`.
3. Report: cleaned paths, skills/rules/agents installed, MCP merge, Caveman bind success/fail, rtk preserved yes/no, dependency lines.
4. Remind: **new Cursor chat** / reload so the Caveman session hook applies; reload MCP if Serena was added; in each **app** repo run `/bootstrap-coding-standards` then `/setup-serena`.
5. Note: pipeline stages 1–2 use `CAVEMAN_OVERRIDE: off` so Task Card / Execution Plan stay readable.
6. Do **not** edit product application code. Do not re-add `caveman.mdc` always-on rules.
7. Lean meta: sole fat always-on rule is `stack-router.mdc`; other kit rules install with `alwaysApply: false`. Kit agents embed STACK — do not teach parents to re-paste the full fence.
