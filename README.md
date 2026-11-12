# cursor-dev-kit

Cursor agent toolkit: **skills**, **rules**, **subagents**, and slash commands for project readiness plus a **dev pipeline** for delivery.

License: [MIT](LICENSE)

Repo: [github.com/kathan07/cursor-dev-kit](https://github.com/kathan07/cursor-dev-kit)

## What you get

Two layers:

1. **Env readiness** — coding standards bootstrap, Serena MCP, official **Caveman** Cursor bind, Ponytail / token-saviour / agent-stack.
2. **Dev pipeline** — Task Card → plan → wave execute → optional change handoff (`task-formatter`, `dev-planner`, `dev-executor`, `explorer`, `change-handoff`).

## Quick start

```bash
git clone https://github.com/kathan07/cursor-dev-kit.git
cd cursor-dev-kit
```

1. Open this folder in **Cursor**.
2. Run **`/install-dev-kit`** (or `./install.sh` in a terminal). Needs **Node 18+ / `npx`** for Caveman, and network.
3. Reload Cursor / start a **new chat** so the Caveman session hook applies. Reload MCP if Serena was added.
4. In each **application** repo (not this kit):
   - `/bootstrap-coding-standards`
   - `/setup-serena`

### What the installer does

1. **Cleanup** leftover Caveman that fights the official hook:
   - `~/.cursor/rules/caveman.mdc`, kit `~/.cursor/skills/caveman`, incomplete `~/.cursor/caveman`
   - `~/.agents/skills/caveman`, `caveman-*`, `cavecrew` (backed up under `~/.agents/dev-kit-backup/<ts>/`)
2. Copies kit skills / rules / agents into `~/.cursor` (does **not** install a kit `caveman.mdc` or kit caveman skill — official owns those).
3. Merges Serena into `~/.cursor/mcp.json` if `serena` is missing.
4. Runs official [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) pinned to **`v4.1.0`**:  
   `npx -y github:JuliusBrussee/caveman#v4.1.0 -- --only cursor`  
   (on npm 12+, installer adds `--allow-git=root` automatically)
5. Restores the **rtk** shell hook if Caveman install dropped it.

Backups: `~/.cursor/dev-kit-backup/<timestamp>/`.

**Do not** re-add an always-on `caveman.mdc` rule — hook + rule doubles Caveman instructions.

## Caveman + dev pipeline

With the official session hook, new chats may start in caveman. The **dev pipeline** still keeps stages **1–2** readable:

| Stage | Prose |
|-------|--------|
| 1 Task Card / 2 Execution Plan | `CAVEMAN_OVERRIDE: off` — full reviewable markdown |
| 3 Execution Report / 4 Handoff summary | caveman on (compact) |

Cavecrew agents from the official install may appear alongside pipeline agents (different names).

## Slash commands

| Command | Purpose |
|---------|---------|
| `/install-dev-kit` | Install kit + cleanup leftovers + official Caveman + Serena merge |
| `/bootstrap-coding-standards` | Seed/customize `.cursor/standards/` for the current repo |
| `/align-coding-standards` | Update standards + align a code Scope |
| `/setup-serena` | Write `.serena/project.yml`, activate, onboard, warm index |
| `/caveman` | Caveman modes (from official skill / hook) |

## Skills (also auto / task-triggered)

| Skill | Role |
|-------|------|
| `coding-standards` | Universal + language + domain standards pack |
| `dev-pipeline` | Orchestrate Task Card → plan → execute waves |
| `explorer` | Codebase scout → Insight Brief (**Serena first**; Grep only after Gaps) |
| `change-handoff` | Branch/PR/commit impact docs |
| `token-saviour` | Prefer Serena / rtk / caveman / Ponytail for fewer tokens |
| `agent-stack` | STACK block for child agents |

`skills/caveman/` remains in this repo as a **reference copy only**; live Caveman comes from the official installer.

## Agents (`~/.cursor/agents`)

Pipeline:

- `task-formatter`, `dev-planner`, `dev-executor`, `explorer` (Serena-first, behaviorally read-only), `change-handoff`

Official Caveman may also add **Cavecrew** presets.

## Always-on rules

Installed under `~/.cursor/rules/`:

- `agent-stack`, `token-saviour`, `ponytail`
- `coding-standards` (+ node / go / java / dotnet packs)
- `explorer`, `dev-pipeline`, `change-handoff`

Caveman always-on = **official session hook**, not a kit `.mdc`.

## Dependencies

| Dependency | Required? | Notes |
|------------|-----------|--------|
| [Cursor](https://cursor.com) | Yes | Host for skills, rules, agents, MCP |
| Node 18+ / `npx` | For Caveman | Official `--only cursor` bind |
| [uv](https://docs.astral.sh/uv/) / `uvx` | For Serena | MCP server entry |
| [Serena](https://github.com/oraios/serena) | Recommended | Via `uvx --from git+…` |
| `rtk` | Optional | Soft-checked; shell hook preserved when possible |
| [Caveman](https://github.com/JuliusBrussee/caveman) | Via installer | Pinned `v4.1.0` |

Example Serena MCP snippet: [`mcp/serena.mcp.json.example`](mcp/serena.mcp.json.example).

## Repo layout

```text
skills/          # Kit skills (caveman/ is reference-only for install)
rules/           # Always-on .mdc rules (no caveman.mdc)
agents/          # Pipeline subagents
mcp/             # MCP examples
install.sh       # Cleanup + kit copy + official Caveman + Serena
.cursor/skills/install-dev-kit/   # Project slash skill for first-run
```

## After install (per app repo)

```text
/bootstrap-coding-standards
/setup-serena
```

Then use the **dev pipeline** for feature work (e.g. ask to “run the dev pipeline”).

## Updating

Pull latest `cursor-dev-kit`, open it, run `/install-dev-kit` again. Overwrites are backed up under the backup folders above.
