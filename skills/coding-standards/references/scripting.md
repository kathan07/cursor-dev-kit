# Scripting standards

**Job type:** `script` — one-shot or automation scripts (shell, Python, Make, small Node CLIs), not long-lived API/worker services.

## Responsibilities

- Automate a bounded task; fail loudly; leave the system in a known state; be safe to re-run when possible.

## Chosen / Rejected (for planner LLD)

| Pattern | Choose when | Reject when |
|---------|-------------|-------------|
| **Single file script** | One clear job, few deps | Growing into a multi-module app (promote to `app`) |
| **Small shared lib + thin CLI** | Real duplication across scripts | Speculative “platform” for one script |
| **Make / task runner target** | Repo already uses it; multi-step glue | New build system for a one-liner |
| **Dry-run / check mode** | Mutates infra, files, or remotes | Pure read-only report |

## Rules

1. **Idempotency** — re-running should be safe or clearly refused; document side effects at top.
2. **Dry-run** — prefer `--dry-run` / `-n` for destructive or remote changes.
3. **Exit codes** — `0` success; non-zero on failure; don’t exit 0 after partial failure.
4. **Logging** — progress on stderr or structured logs; never print secrets.
5. **Args** — explicit flags; validate required inputs before side effects.
6. **Unsafe ban** — no `eval` of untrusted input; no `curl | sh`; pin URLs/versions when fetching.
7. **Secrets** — env / secret files / vault — not CLI flags that land in shell history when avoidable.
8. **Timeouts** — bound network and long subprocesses.

## Verification (typical)

- Run with `--help` / dry-run.
- Happy path once; one failure path (missing arg, bad env).
- Confirm exit codes and that re-run behavior matches docs.

## Anti-patterns

- Silent `|| true` that hides real failures
- Hardcoded prod credentials
- Scripts that only work on the author’s machine (undocumented paths/tools)
