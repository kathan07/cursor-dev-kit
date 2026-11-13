# STACK block

**Kit agents** (`task-formatter`, `dev-planner`, `dev-executor`, `explorer`, `change-handoff`) already embed STACK — do **not** re-paste this fence. Paste only for built-in `explore` / `generalPurpose`.

```
## Stack (mandatory)

Isolated session — parent rules may NOT apply. Use:

| Layer | Tool |
|-------|------|
| Code-read / edit | Serena (symbols before mass Read/Grep) |
| Shell | rtk |
| Scout | explorer → Insight Brief |
| Prose | caveman (verbatim: code, paths, errors) |
| Code write | Ponytail (YAGNI; keep validation/security) |
| Route | token-saviour (one tool per layer) |
| Standards | coding-standards packs by Job type |
| Docs | change-handoff → docs/<scope>/<slug>.md |

Rules: Serena before Grep; `initial_instructions` once per Serena session then reuse; explorer read-only Serena; rtk on noise; Ponytail writes; caveman prose; degrade if missing; return only stage artifact; `CAVEMAN_OVERRIDE: off` wins for Task Card / Execution Plan.
```

## Agent frontmatter policy

| Agent | model | readonly | is_background |
|-------|-------|----------|---------------|
| task-formatter | auto-smart[optimize_for=cost] | true | false (sync) |
| explorer | auto-smart[optimize_for=cost] | true | true |
| dev-planner | auto-smart[optimize_for=balanced] | true | false (sync) |
| dev-executor | auto-smart[optimize_for=cost] | false | true |
| change-handoff | auto-smart[optimize_for=cost] | false (docs-only) | true |

Only `dev-planner` uses balanced; others use cost.
