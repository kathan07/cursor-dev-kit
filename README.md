# cursor-dev-kit

Cursor agent toolkit: **skills**, **rules**, **subagents**, and slash commands for project readiness plus a **dev pipeline** for delivery.

License: [MIT](LICENSE)

Repo: [github.com/kathan07/cursor-dev-kit](https://github.com/kathan07/cursor-dev-kit)

## What you get

Two layers:

1. **Env readiness** — coding standards bootstrap, Serena setup, always-on agent behavior (caveman, Ponytail, token-saviour, agent-stack).
2. **Dev pipeline** — Task Card → plan → wave execute → optional change handoff (`task-formatter`, `dev-planner`, `dev-executor`, `explorer`, `change-handoff`).

## Quick start

```bash
git clone https://github.com/kathan07/cursor-dev-kit.git
cd cursor-dev-kit
```

1. Open this folder in **Cursor**.
2. Run **`/install-dev-kit`** (or `./install.sh` in a terminal).
3. If Serena MCP was added, reload MCP / restart Cursor agents so the server appears.
4. In each **application** repo (not this kit):
   - `/bootstrap-coding-standards`
   - `/setup-serena`

Installer copies packs into `~/.cursor/skills`, `~/.cursor/rules`, and `~/.cursor/agents`. Same-named items are backed up under `~/.cursor/dev-kit-backup/<timestamp>/`. Serena is merged into `~/.cursor/mcp.json` only when the `serena` key is missing.

## Slash commands

| Command | Purpose |
|---------|---------|
| `/install-dev-kit` | Install this kit into `~/.cursor` (+ merge Serena MCP) |
| `/bootstrap-coding-standards` | Seed/customize `.cursor/standards/` for the current repo |
| `/align-coding-standards` | Update standards + align a code Scope |
| `/setup-serena` | Write `.serena/project.yml`, activate, onboard, warm index |
| `/caveman` | Terse chat mode (via caveman skill) |

## Skills (also auto / task-triggered)

| Skill | Role |
|-------|------|
| `coding-standards` | Universal + language + domain standards pack |
| `dev-pipeline` | Orchestrate Task Card → plan → execute waves |
| `explorer` | Codebase scout → Insight Brief |
| `change-handoff` | Branch/PR/commit impact docs |
| `token-saviour` | Prefer Serena / rtk / caveman / Ponytail for fewer tokens |
| `agent-stack` | STACK block for child agents |
| `caveman` | Compressed communication |

## Agents (`~/.cursor/agents`)

Spawned by the pipeline / Task tool:

- `task-formatter`
- `dev-planner`
- `dev-executor`
- `explorer`
- `change-handoff`

## Always-on rules

Installed under `~/.cursor/rules/`:

- `agent-stack`, `token-saviour`, `caveman`, `ponytail`
- `coding-standards` (+ node / go / java / dotnet packs)
- `explorer`, `dev-pipeline`, `change-handoff`

## Dependencies

| Dependency | Required? | Notes |
|------------|-----------|--------|
| [Cursor](https://cursor.com) | Yes | Host for skills, rules, agents, MCP |
| [uv](https://docs.astral.sh/uv/) / `uvx` | For Serena | Used by the Serena MCP server entry |
| [Serena](https://github.com/oraios/serena) | Recommended | Installed via `uvx --from git+…` in MCP config |
| `rtk` | Optional | Soft-checked by installer; used by token-saviour / stack workflows |

Example Serena MCP snippet: [`mcp/serena.mcp.json.example`](mcp/serena.mcp.json.example).

## Repo layout

```text
skills/          # Cursor skills (source + post-install personal copy)
rules/           # Always-on .mdc rules
agents/          # Subagent definitions
mcp/             # MCP examples
install.sh       # Idempotent installer
.cursor/skills/install-dev-kit/   # Project slash skill for first-run
```

## After install (per app repo)

```text
/bootstrap-coding-standards
/setup-serena
```

Then use the **dev pipeline** for feature work (e.g. ask to “run the dev pipeline” or follow the `dev-pipeline` skill).

## Updating

Pull latest `cursor-dev-kit`, open it (or point `/install-dev-kit` at the clone), run `/install-dev-kit` again. Previous copies of overwritten skills/rules/agents are kept in the backup folder.
