---
name: agent-stack
description: >-
  Mandatory token and quality stack for every Cursor agent and spawned child
  subagent: Serena, rtk, explorer, caveman, Ponytail, token-saviour,
  coding-standards, change-handoff. Use when writing or updating agents,
  spawning Task/subagents, running the dev pipeline, or when children must
  inherit stack access that always-on parent rules may not pass through.
---

# Agent stack (mandatory for children)

Parent `alwaysApply` rules may **not** load inside spawned subagents. Treat this skill’s [references/STACK.md](references/STACK.md) as the **portable stack** every child must follow.

## When spawning any subagent

1. Include the **STACK block** from `references/STACK.md` in the child prompt (or rely on it already embedded in `~/.cursor/agents/*.md`).
2. Prefer agents that already embed STACK: `explorer`, `task-formatter`, `dev-planner`, `dev-executor`, `change-handoff`.
3. If spawning `generalPurpose` / built-in `explore`, paste the STACK block into the Task prompt.

## Orchestrators (main / dev-pipeline)

- Keep main thin; children do heavy work **with STACK**.
- Do not assume caveman/Ponytail/token-saviour rules auto-apply to children — STACK does.

## Verify

Child replies should behave as if STACK is active (Serena before mass Read; rtk on noisy shell; Ponytail on writes; caveman on prose).

## Models

See [references/STACK.md](references/STACK.md) agent frontmatter policy:

- Most agents: `auto-smart[optimize_for=cost]`
- Planning only (`dev-planner`): `auto-smart[optimize_for=balanced]`
