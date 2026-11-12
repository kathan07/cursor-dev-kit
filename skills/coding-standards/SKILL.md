---
name: coding-standards
description: >-
  Language-agnostic coding standards with universal rules, language packs
  (.NET/C#, Go, Java, Node/TypeScript, thin Python/Shell), and domain packs
  (API, workers, scripting, AI engineering, cloud manifests): naming, git/PRs,
  production commenting (WHY/contracts), coding style, LLD patterns. Use when
  writing or reviewing code, naming files/symbols, opening PRs, committing,
  designing handlers/services/scripts/IaC/AI work, or when the user mentions
  standards, conventions, comments, or LLD.
---

# Coding standards (universal · language · domain)

**Layers (apply in order):**

1. **Universal** — always (`coding.md` Universal, `git-pr-commit.md`, `comments.md` semantics).
2. **Language** — when the stack is known (detailed: .NET / Go / Java / Node·TS; thin: Python / Shell). Unknown language → universal + repo standards only; **do not invent idioms**.
3. **Domain** — from Task Card **Job type**: `app` → `api-services.md` and/or `background-services.md`; `script` → `scripting.md`; `ai-eng` → `ai-engineering.md`; `cloud` → `cloud-manifests.md`; `mixed` → primary + secondary packs.

**Conflict rule:** apply the first source that exists:

1. `CONTRIBUTING` and `.editorconfig` in the repo.
2. `.cursor/standards/` in the repo, when that folder exists. Read those files instead of this skill's `references/` copies (same filenames: `naming.md`, `git-pr-commit.md`, `comments.md`, `coding.md`, `lld-patterns.md`, `api-services.md`, `background-services.md`, `scripting.md`, `ai-engineering.md`, `cloud-manifests.md`).
3. This skill's `references/` when the repo has no `.cursor/standards/`.
4. Ponytail still applies under those — do not add layers/patterns the task did not need; document rejected patterns in plans.

## Quick map

| Topic | File |
|-------|------|
| Files & symbols | [references/naming.md](references/naming.md) |
| Branches / commits / PRs | [references/git-pr-commit.md](references/git-pr-commit.md) |
| Comments / docs | [references/comments.md](references/comments.md) |
| Coding style | [references/coding.md](references/coding.md) |
| LLD patterns | [references/lld-patterns.md](references/lld-patterns.md) |
| API services (`app`) | [references/api-services.md](references/api-services.md) |
| Background / workers (`app`) | [references/background-services.md](references/background-services.md) |
| Scripting (`script`) | [references/scripting.md](references/scripting.md) |
| AI engineering (`ai-eng`) | [references/ai-engineering.md](references/ai-engineering.md) |
| Cloud manifests / IaC (`cloud`) | [references/cloud-manifests.md](references/cloud-manifests.md) |

## Always enforce (summary)

1. **Names** — language idioms when known (see naming.md); files match primary type where the language expects it.
2. **Git** — `type/ticket-or-slug` branches; Conventional Commits; PR = why + test plan.
3. **Comments** — WHY / contracts / invariants / security / concurrency (see `comments.md`); never narrate obvious code; actionable `TODO`/`FIXME`/`HACK` only.
4. **Code** — validate at boundaries; structured errors/logs; no secrets; async/cancellation/timeouts honored.
5. **Shape** — pick domain pack by Job type; do not force API layering onto scripts/IaC.
6. **LLD** — principles first (SOLID, KISS, YAGNI, …), then catalog by job type (see `lld-patterns.md`); record chosen vs rejected (dev-planner).

## When planning or executing

- `dev-planner`: set Job type + Standards packs; fill LLD Chosen/Rejected from the catalog for that job type; group todos into **Waves** (≤7 todos/wave; single wave if ≤7 todos total).
- `dev-executor`: match naming + coding + **comments** for touched language/domain packs; implement **assigned wave only**; do not invent patterns absent from the approved plan; comments only for WHY/contract/invariant/security/etc. — never narrate.
- Reviews: flag violations as Critical (security/correctness/stale security comments) or Suggestion (style / missing WHY on non-obvious code).
