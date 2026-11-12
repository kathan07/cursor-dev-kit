---
name: dev-pipeline
description: >-
  Orchestrates the four-stage dev pipeline: format raw text into a Task Card,
  plan in Plan mode, execute via wave-assigned spawned dev-executor, then optional
  change-handoff. Use for any Job type (app, script, ai-eng, cloud, mixed).
  Use proactively for "dev pipeline", "run the pipeline", Plan UI Build after a
  pipeline plan, approve/implement/execute/continue wave after an Execution Plan,
  or unstructured build requests with approval gates. Main never implements —
  always Task-spawn stage agents. Approval artifacts must appear in full in the
  main chat.
---

# Dev pipeline

Four stages with **user approval between each**. Main session = thin orchestrator. Heavy work runs in **spawned subagents** (isolated context). Same pipeline for all Job types (`app` | `script` | `ai-eng` | `cloud` | `mixed`); standards packs come from the Task Card.

Main chat keeps: raw ask, approvals, and the **latest stage artifact in full** (Task Card / Execution Plan / Execution Report / Handoff Path+summary). Compact only explorer dumps and tool scratch — **never** the approvable artifact. Stage 4 full prose lives in `docs/<scope-slug>/<change-slug>.md`.

## Stages

| # | Subagent | Mode | Artifact in / out | Spawn |
|---|----------|------|-------------------|-------|
| 1 | `task-formatter` | Agent (light) | Raw text → **Task Card** (Job type + packs + slice) | sync (`run_in_background: false`) |
| 2 | `dev-planner` | **Plan** | Task Card → **Execution Plan** + **Waves** | sync (`run_in_background: false`) |
| 3 | `dev-executor` | **Agent** | **One wave** → **Execution Report** (fresh spawn per wave) | background OK |
| 4 | `change-handoff` | Agent (docs-only writes) | Branch/PR/commits → **`docs/<scope-slug>/<change-slug>.md`** + Path/summary | background OK |

Stage 4 runs **only when the user asks** after execution (or explicitly requests handoff).

## Context isolation (mandatory)

1. Launch each stage via the **Task / subagent** tool (`task-formatter`, `dev-planner`, `dev-executor`, `change-handoff`).
2. Stages **1 and 2 must be sync**: set `run_in_background: false` so the full artifact returns into the parent turn.
3. Pass **only** the needed artifact into the child prompt — not the entire chat history.
4. **Always include STACK** (skill `agent-stack` → `references/STACK.md`) in every spawn prompt.
5. Child returns **only** its artifact.
6. Main session **pastes that artifact verbatim**, then asks for approval/continue.
7. Children may spawn further subagents (`explorer`, etc.) with STACK.

## Orchestration loop

```
User raw text
  → spawn task-formatter sync (+ STACK)
  → PASTE full Task Card in chat → WAIT approval / edits
  → SwitchMode plan (explain: designing execution plan)
  → spawn dev-planner sync (+ STACK)
  → PASTE full Execution Plan markdown in chat → WAIT approval / edits
  → on Build / approve / implement / SwitchMode agent:
       FIRST tool call = Task dev-executor for wave-1 (+ STACK) — main does NOT edit code
  → PASTE full Execution Report → WAIT ack / continue / stop / revise
  → while Next wave != None and user continues:
       spawn FRESH dev-executor for wave-N (+ STACK + prior report summary)
       → PASTE report → WAIT
  → on user ask: spawn change-handoff for branch/PR/commits (+ STACK)
```

On rejection: revise with user notes; re-spawn **that stage only** (do not restart the whole pipeline unless asked).

## Stage 3 — wave execution (hard rules)

Cursor Plan **Build** and chat `approve` / `implement` / `execute` after a pipeline Execution Plan mean: **spawn `dev-executor` for `wave-1`** (or the only wave).

`continue` / `next wave` / ack after Partial with Next wave set mean: **spawn a fresh `dev-executor` for that wave**.

### Wave rules

- Parse **Waves** table from the plan; default first assign = `wave-1`.
- If total todos ≤ 7 there is typically one wave — still pass Assigned wave.
- When Waves has more than one row, never say “implement the entire plan” without a wave assignment.
- **One executor at a time** — no parallel executors for the same plan.
- **Fresh session per wave** — do not rely on `resume` to finish later waves.
- Main **never** implements remaining waves inline.

### Orchestrator MUST (first action on execute signals)

1. Call Task with `subagent_type: dev-executor` (do not Write/StrReplace/edit first).
2. Pass STACK + Task Card + full Execution Plan + **Assigned wave** + todo id list (+ prior report summary for wave-N>1).
3. Use `run_in_background: true` unless user asked for sync executor.
4. Paste the full Execution Report; ask **ack** / **continue** / **stop** / **revise**.

### Orchestrator MUST NOT

- Implement the plan in the main session
- Skip wave verify notes when the report asks to verify before continuing
- Spawn two executors in parallel for the same plan
- Finish leftover waves in main when the child hits context limits

If main already edited files: stop editing, spawn `dev-executor` with the approved plan + note what main already touched, and stay orchestrator thereafter.

## Stage 2 visibility (hard rule — plan must be visible)

The user must see the **entire** Execution Plan in the main chat thread **before** the approve prompt.

**Orchestrator MUST:** spawn `dev-planner` sync; paste plan **verbatim**; then ask approval.

**Orchestrator MUST NOT:** summary-only plans, caveman-compress the plan body, approve-with-hyperlink-only.

**If Multitask Mode forces background:** on completion, paste the full plan body into main chat in that turn.

**Caveman exception:** always-on caveman / token-saviour do **not** apply to stage 1–2 approval messages.

## Spawn prompt templates

Include this STACK header on every spawn (from `agent-stack/references/STACK.md`):

```
Apply agent-stack STACK (mandatory): Serena, rtk, explorer, caveman, Ponytail,
token-saviour, coding-standards (universal + language/domain packs as applicable).
Parent rules may not apply.
```

### Stage 1
```
Use task-formatter.
STACK: Serena/rtk/explorer/caveman/Ponytail/token-saviour/coding-standards as applicable.
Raw request:
<user text>
Return only the Task Card (include Job type, Standards packs, Delivery slice).
```
Parent: `run_in_background: false`. Paste full Task Card, then approve prompt.

### Stage 2
```
Use dev-planner.
STACK: mandatory — spawn explorer; Serena; rtk; coding-standards packs from Task Card;
LLD from lld-patterns.md catalog for Job type (+ domain ref).
Approved Task Card:
<card>
Return only a Plan-mode-quality Execution Plan markdown (YAML frontmatter with
name/overview/todos + detailed body: defaults including wave count, architecture,
path-cited file changes, LLD chosen/rejected for Job type, Waves table, execution
order, verification, risks, gaps).
Every todo id in exactly one wave; ≤7 todos per wave; one wave if ≤7 todos total.
Not a thin bullet stub. Plan body is full prose for human approval (not caveman).
Read-only. No code edits.
Your final message MUST be the complete plan document only — parent will paste
it verbatim into the user chat for approval.
```
Parent: `run_in_background: false`. Paste **full** plan (not summary), then approve prompt.

### Stage 3
Parent: **first** tool call is Task `dev-executor`. Do not edit code in parent.
```
Use dev-executor.
STACK: mandatory — Serena edits; rtk; Ponytail; coding-standards packs from Task Card;
explorer if lost; caveman report.
Approved Task Card:
<card>
Approved Execution Plan:
<plan>
Assigned wave: <wave-N>
Todo ids for this wave only: <ids>
Prior wave report summary (if any):
<paths / completed ids / deviations>
Implement ONLY this wave. Follow comments.md (WHY/contracts only; no narration).
Return only the Execution Report with Wave + Status.
Do not start later waves in this session.
Parent is orchestrator only — you own all file edits for this wave.
```

### Stage 4
```
Use change-handoff.
STACK: mandatory — rtk git; Serena blast radius; caveman doc.
Source: <branch | PR | commits>
Scope override (optional): <feature-or-folder-slug>
Always save to docs/<scope-slug>/<change-slug>.md
Return Path + short summary + Gaps (full doc in the file).
```

## Stack reuse

| Concern | Use |
|---------|-----|
| Portable child access | skill **`agent-stack`** + rule **`agent-stack.mdc`** |
| Scout before/during plan | `explorer` |
| Symbols / edits | Serena |
| Shell noise | rtk |
| Lean implementation | Ponytail |
| Terse prose | caveman (not on stage 1–2 approval paste) |
| Token routing | token-saviour |
| Final doc | `change-handoff` |
| Standards | `coding-standards` packs by Job type; LLD = `lld-patterns.md` + domain refs; comments = `comments.md` |

## Models (agent frontmatter)

| Agent | Model | readonly | background |
|-------|-------|----------|------------|
| `task-formatter` | `auto-smart[optimize_for=cost]` | yes | **no (sync)** |
| `explorer` | `auto-smart[optimize_for=cost]` | yes | yes |
| `dev-planner` | `auto-smart[optimize_for=balanced]` | yes | **no (sync)** |
| `dev-executor` | `auto-smart[optimize_for=cost]` | no | yes |
| `change-handoff` | `auto-smart[optimize_for=cost]` | no (docs-only under `docs/`) | yes |

## Approval UX

After pasting the full artifact for stages 1–2, ask:

> Approve this \<Task Card|Execution Plan\>? Reply **approve**, **revise: …**, or **stop**.

After an Execution Report:

> Ack this Execution Report? Reply **continue** (next wave), **ack** (done), **revise: …**, or **stop**.

**Build / approve after Execution Plan** → immediately stage 3 spawn for **wave-1**. Do not ask again if they already clicked Build or said approve.

## Anti-patterns

- **Main agent implementing** after Build / approve / continue / SwitchMode agent
- Re-exploring the repo in main after a good Insight Brief / Plan
- Skipping pattern chosen/rejected or **Waves** sections
- Forcing GoF rejects onto script/cloud plans
- Executor starting later waves in the same session
- Parallel executors for one plan
- Accepting a thin Execution Plan or missing Waves table
- Spawning children **without** STACK
- Running change-handoff before the user asks (unless requested up front)

## Stage 2 quality gate (orchestrator)

Before asking the user to approve the Execution Plan, sanity-check:

1. Full plan body is **in the same user-visible message** as the approve prompt
2. Has YAML frontmatter with `overview` + ordered `todos`
3. Cites real paths
4. Has LLD Chosen **and** Rejected (catalog for Job type)
5. Has numbered execution order + verification / stop condition
6. Has **Waves** table; every todo id in exactly one wave; each wave ≤ 7 todos

If any fail → re-spawn `dev-planner` with revise notes; do not treat a stub or summary as approvable.
