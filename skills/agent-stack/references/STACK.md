# STACK block (paste into every child / keep in agent prompts)

```
## Stack (mandatory)

You run in an isolated session. Parent always-on rules may NOT apply. You MUST use this stack:

| Layer | Use | How |
|-------|-----|-----|
| Code-read / symbol edit | **Serena MCP** | Symbol tools before reading many whole files |
| Shell noise | **rtk** | Prefix noisy cmds: `rtk git`, `rtk test`, `rtk grep`, `rtk diff`, `rtk ls`… |
| Multi-file scout | **explorer** subagent | Insight Brief — do not dump Grep into the parent |
| Prose | **caveman** | Terse replies; code, paths, errors, commands verbatim |
| Code generation | **Ponytail** | YAGNI; minimal diff; keep validation/security |
| Token routing | **token-saviour** | Pick layer first: Serena vs rtk vs caveman vs Ponytail |
| Standards | **coding-standards** | Universal + language/domain packs by Job type — refs under skills/coding-standards/references/ (LLD: `lld-patterns.md`; comments: `comments.md`; domains: api/worker/scripting/ai-engineering/cloud-manifests) |
| Completed-change docs | **change-handoff** | Branch/PR/commit handoff when asked; always writes `docs/<scope-slug>/<change-slug>.md` (docs-only) |

Rules:
1. Prefer Serena over mass Read/Grep for symbols.
2. Prefer explorer over exploring in the parent thread.
3. Prefer rtk for verbose command output.
4. Prefer Ponytail on code writes; caveman on narration.
5. Follow coding-standards packs for Job type / touched language; repo-local conventions win; do not invent idioms for unknown languages.
6. If a tool is missing, degrade to plain tools — never pretend it ran.
7. Return only your stage artifact to the parent.
```

## Agent frontmatter policy

| Agent | `model` | `readonly` | `is_background` |
|-------|---------|------------|-----------------|
| `task-formatter` | `auto-smart[optimize_for=cost]` | `true` | `false` (sync — full Task Card in parent) |
| `explorer` | `auto-smart[optimize_for=cost]` | `true` | `true` |
| `dev-planner` | `auto-smart[optimize_for=balanced]` | `true` | `false` (sync — full Execution Plan pasted in chat) |
| `dev-executor` | `auto-smart[optimize_for=cost]` | `false` | `true` |
| `change-handoff` | `auto-smart[optimize_for=cost]` | `false` (docs-only writes under `docs/`) | `true` |

Only the planning agent uses **balanced**; all other pipeline agents use **cost**.
