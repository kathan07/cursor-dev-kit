# AI engineering standards

**Job type:** `ai-eng` — prompts, agents/tools, RAG pipelines, evals, model clients — not generic CRUD unless the change is model/agent-specific.

## Responsibilities

- Call models/tools safely; version prompts; bound cost/latency; evaluate behavior; keep secrets and untrusted content out of privileged sinks.

## Chosen / Rejected (for planner LLD)

| Pattern | Choose when | Reject when |
|---------|-------------|-------------|
| **Thin model client + explicit prompts** | Small feature; repo has no agent framework | You only need one completion |
| **Existing agent/framework in repo** | Team already standardized | Introducing a second stack for one feature |
| **Tool/schema boundary** | Model can call side-effecting ops | Free-form string → shell/SQL without validation |
| **Eval / smoke harness** | Behavior can regress silently | Pure plumbing with no model output |

## Rules

1. **Prompt versioning** — store prompts as files or named constants; note version/date when behavior matters.
2. **Tool boundaries** — validate/authorize tool args; least privilege; never pass raw model text to shell/SQL/file write without checks.
3. **Secrets** — API keys via env/secret store; never in prompts, logs, or repos.
4. **Untrusted input** — treat user/retrieved docs as untrusted (prompt-injection); separate system instructions from data.
5. **RAG provenance** — record source ids/paths for retrieved chunks; don’t invent citations.
6. **Timeouts & cost** — set request timeouts, token/budget caps; fail closed when exceeded.
7. **Evals** — at least one smoke/eval path for critical behaviors when changing prompts/tools.
8. **Determinism** — seed/temperature choices documented when tests depend on them.

## Verification (typical)

- Smoke call or recorded fixture against the changed prompt/tool.
- Confirm secrets not logged; tool args rejected when invalid.
- Eval checklist item for the acceptance criteria that involve model behavior.

## Anti-patterns

- Logging full prompts with PII/secrets
- Unbounded agent loops without iteration/time caps
- Silent fallback that hides model/tool failures
