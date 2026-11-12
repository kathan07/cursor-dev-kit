---
name: change-handoff
description: >-
  Delegates writing handoff / impact / change docs to the change-handoff
  subagent for a branch, PR, commit, or list of commits. Use when the user
  wants what/why/where with file refs and the new flow, PR handoff notes,
  impact analysis, or change summaries for reviewers or other agents.
  Docs always land at docs/<scope-slug>/<change-slug>.md.
---

# Change-handoff skill

Use the **change-handoff** subagent (`~/.cursor/agents/change-handoff.md`) to turn a git range into a structured handoff doc saved under `docs/`. Keep raw diffs out of the main thread.

## When to invoke

- User gives a **branch**, **PR**, **commit**, or **list/range of commits** and wants a handoff / impact / change doc
- “What changed and why?”, “write PR handoff”, “impact of this branch”, “document these commits”
- Preparing notes for another agent or a human reviewer

**Skip** for tiny one-line fixes the user already understands — a short inline summary is enough.

## How to invoke

```
Use the change-handoff subagent.
Source: <branch | PR #n | sha | sha1 sha2 … | base...head>
Base (if branch): <main|master|develop|… or omit>
Scope override (optional): <feature-or-folder-slug>
Always save to docs/<scope-slug>/<change-slug>.md
Return Path + short summary + Gaps (not the full doc unless asked).
```

### Path convention (agent resolves)

- Scope: PR → `pr-<n>`; commit/range → short tip SHA; branch/feature → kebab name; explicit override wins
- File: kebab short title; on collision `-2`, `-3`, …
- Example: `docs/pr-123/oauth-callback-fix.md`

## How to consume

1. Treat the returned **Path** as the artifact; Read the file if follow-up work needs Where / New flow.
2. Use **Impact** (in the file) for test/review focus.
3. Resolve **Gaps** before claiming the doc is complete.
4. Do not re-dump the full handoff or raw diff into chat after a good Path + summary.

## Stack alignment

| Need | Tool |
|------|------|
| Diff / log noise | rtk git / gh |
| Callers / blast radius | Serena |
| Doc prose | caveman-tight |
| Scout unfinished work | explorer (different job) |

## Output contract

Subagent **writes** the full Change Handoff Doc to `docs/<scope-slug>/<change-slug>.md` and returns **Path** + short Summary + Gaps. Main agent should not re-dump the full diff or full doc afterward unless the user asks.
