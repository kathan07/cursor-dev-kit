---
name: explorer
description: >-
  Delegates codebase and source reconnaissance to the explorer subagent and
  consumes its Insight Brief for planning, task creation, and execution.
  Use when starting multi-file work, unclear ownership, architecture questions,
  or before writing a plan/todos — and whenever the user asks to explore, map,
  or scout the repo for another agent.
---

# Explorer skill

Use the **explorer** subagent (`~/.cursor/agents/explorer.md`) as a read-only scout. Keep heavy search out of the main thread.

## When to invoke

Invoke explorer **before**:
- Multi-file features or refactors
- Ambiguous bugs ("something in auth is broken")
- Architecture / "how does X work" that spans modules
- Writing plans, PR scopes, or task lists for another agent

**Skip** when the user already named the exact file/symbol and a single Read/Serena call is enough.

## How to invoke

Delegate with a crisp prompt:

```
Use the explorer subagent to scout <topic>.
Need an Insight Brief for planning/execution: entrypoints, key files with line ranges,
call flow, blast radius, risks, and a short task breakdown.
Do not implement. Prefer Serena for symbols when available.
```

Pass any known hints (paths, error strings, tickets).

## How to consume the brief

1. Treat the Insight Brief as source of truth for locations.
2. Build the plan / todos from **Suggested task breakdown**.
3. Executor agents should open cited ranges first — not re-explore from scratch.
4. If Gaps are non-empty, resolve those first or ask the user.

## Stack alignment

| Layer | Tool |
|-------|------|
| Symbol / call-path | Serena (inside explorer) |
| Noisy shell | rtk |
| Prose in main chat | caveman |
| Implementation after brief | Ponytail |

Do not run a second full explore in the main agent after a good brief — that wastes tokens.

## Output contract

Explorer returns only an Insight Brief (Map, flow, blast radius, risks, tasks, Gaps). Main agent should not ask it to write code.
