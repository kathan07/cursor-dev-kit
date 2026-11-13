---
name: agent-stack
description: >-
  Portable STACK for child subagents (Serena, rtk, explorer, caveman, Ponytail).
  Use when spawning Task/subagents or updating agents. Kit agents embed STACK —
  paste fence only for built-in explore/generalPurpose.
---

# Agent stack

Parent always-on rules may **not** load in spawned subagents. Portable stack: [references/STACK.md](references/STACK.md).

## When spawning

1. Prefer kit agents that **embed** STACK — do **not** re-paste the fence.
2. Built-in `explore` / `generalPurpose` → paste the STACK fence from `references/STACK.md`.
3. Stage 1–2: include `CAVEMAN_OVERRIDE: off` for Task Card / Execution Plan.

## Orchestrators

Main stays thin. Children do heavy work with STACK. Do not assume parent caveman/Ponytail/token-saviour rules apply to children.

## Models

See `references/STACK.md` frontmatter policy (`dev-planner` = balanced; others = cost).
