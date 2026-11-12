# Coding standards

## Universal (always)

- **Boundaries first:** validate/sanitize untrusted input at API/queue/CLI/edge.
- **Errors:** fail with typed/structured errors; never swallow; wrap with context once.
- **Logging:** structured fields (`orderId`, `requestId`); no PII/secrets.
- **Config:** env/config providers — no hardcoded prod secrets.
- **Concurrency / timeouts:** honor cancellation tokens / contexts / interruptible loops; bound waits.
- **Tests:** cover domain logic + one path through the boundary; deterministic.
- **Deps:** prefer stdlib / existing project libs (Ponytail ladder).
- **Unknown language:** apply Universal + repo `CONTRIBUTING` / `.cursor/standards/` / `.editorconfig` only — do not invent idioms.

---

## .NET (C#)

- Nullable reference types on; avoid `!` unless proven safe.
- `async` all the way; no `.Result` / `.Wait()` on async in app code.
- Inject abstractions via DI; register lifetimes intentionally (`Singleton`/`Scoped`/`Transient`).
- Prefer `IReadOnlyList<T>` / `IEnumerable<T>` on returns when mutation isn’t needed.
- Use `record` / `record struct` for immutable DTOs when it fits.
- Controllers/Minimal APIs thin; business logic in services/handlers.
- `ILogger<T>`; no `Console.WriteLine` in library code.
- Dispose: `await using` / `using`; prefer `IAsyncDisposable` when needed.

## Go

- Pass `context.Context` as first param on I/O / RPC.
- Return `error` last; wrap with `%w`; compare with `errors.Is` / `As`.
- Accept interfaces, return structs.
- No panics for routine errors; panic only for programmer bugs / `main` startup.
- Table-driven tests; use `t.Parallel` only when safe.
- Modules: tidy `go.mod`; no unused deps.

## Java

- Prefer immutability (`final`, records on modern Java).
- Checked exceptions: don’t force callers into empty `catch`; map to domain errors at edges.
- Constructor injection (Spring); avoid field injection in new code.
- Streams: keep readable — don’t nest complex pipelines without need.
- Close resources with try-with-resources.
- Null: prefer `Optional` at return boundaries sparingly; don’t use Optional for fields.

## Node / TypeScript

- `strict` TypeScript; avoid `any` (use `unknown` + narrow).
- `async`/`await`; never leave floating promises without void/catch.
- Propagate errors to a single error middleware / central handler.
- Prefer `node:` built-ins; pin major versions thoughtfully.
- ESM/CJS: follow repo module type; don’t mix casually.
- Validate request bodies with schema (zod/joi/class-validator — whatever repo uses).

## Python (thin)

- Prefer type hints on public functions; `mypy`/`pyright` when the repo already uses them.
- Raise specific exceptions; don’t bare `except:`; use `raise ... from e` when wrapping.
- Prefer `pathlib` over string path concat; close resources with context managers.
- `asyncio`: don’t block the loop; pass timeouts on network I/O.
- Virtualenv / lockfile — follow repo; don’t add deps without need (Ponytail).
- No secrets in source or default argparse values printed in help/logs.

## Shell (thin)

- Prefer `set -euo pipefail` (or document why not); quote expansions `"$var"`.
- Check commands exist before use; fail with clear stderr messages and exit codes.
- Prefer functions over copy-paste; avoid `eval` and `curl | sh`.
- Secrets via env or files with restricted perms — never in argv of `ps`-visible commands when avoidable.
- Make scripts idempotent or support `--dry-run` when mutating systems.
