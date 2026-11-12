---
name: bootstrap-coding-standards
description: >-
  Seed this repo's .cursor/standards from global coding-standards, customize
  them for the detected project languages and domains (multilanguage OK), write
  the project-standards rule, and optionally align a code scope. Use only when
  the user invokes /bootstrap-coding-standards.
disable-model-invocation: true
---

# Bootstrap coding standards

Slash command for the **current repo workspace**. Installs project-local standards from the global pack, **customizes them for this repo’s detected stack** (one or many languages), writes the project rule, then optionally aligns code.

Do **not** edit `~/.cursor/skills/coding-standards/`, `/align-coding-standards`’s skill file, or the dev pipeline.

**Layers:** universal → language(s) present in this repo → domain(s) present. Unknown / undetected languages → do not invent idioms; leave them out of the project profile (or mark N/A).

## Invoke examples

```text
/bootstrap-coding-standards
```

```text
/bootstrap-coding-standards
Scope: apps/server apps/web
```

```text
/bootstrap-coding-standards
Scope: scope: all
```

```text
/bootstrap-coding-standards refresh
Scope: src/
```

```text
/bootstrap-coding-standards override-local
Scope: scope: all
```

```text
/bootstrap-coding-standards generic-only
```

## Flags / inputs

| Input | Meaning |
|-------|---------|
| *(none beyond the command)* | Seed/sync → **project-aware customize** → write rule. **No code alignment.** |
| `Scope: <paths>` | After seed/customize/rule, align that path(s) like `/align-coding-standards` |
| `Scope: scope: all` | Align the whole repo (still skip unknown languages) |
| `refresh` | Re-copy listed standards files (+ README base) from global, then **re-run project-aware customize** |
| `override-local` | While aligning code, apply `.cursor/standards/` even when `CONTRIBUTING` / `.editorconfig` disagree |
| `generic-only` | Skip project-aware customize (seed + rule only — old behavior) |

No separate **Standards** prompt is required — bootstrap implies: *seed from global → customize for this project’s languages/domains → write project-standards rule.*

## Project files

Seed under `.cursor/standards/` from `~/.cursor/skills/coding-standards/references/<same-name>`:

- `naming.md`
- `git-pr-commit.md`
- `comments.md`
- `coding.md`
- `lld-patterns.md`
- `api-services.md`
- `background-services.md`
- `scripting.md`
- `ai-engineering.md`
- `cloud-manifests.md`
- `README.md` — Always enforce summary, then rewritten in the customize step with the project profile

## Stack detection (project-aware)

Scan the **repo root** (and common monorepo roots like `apps/`, `packages/`, `services/`, `backend/`, `frontend/`). Ignore `node_modules/`, `dist/`, `build/`, `.git/`, vendor caches.

### Languages (detect all that apply — multilanguage OK)

| Language id | Evidence (any strong hit) |
|-------------|---------------------------|
| `node-ts` | `package.json`, `tsconfig*.json`, `*.ts` / `*.tsx` (non-ignored), `jsconfig.json` with TS deps |
| `node-js` | `package.json` + substantial `*.js` / `*.jsx` without TS config (still use Node naming/coding chapters) |
| `dotnet` | `*.csproj`, `*.sln`, `global.json`, `*.cs` |
| `go` | `go.mod`, `go.work`, `*.go` |
| `java` | `pom.xml`, `build.gradle` / `build.gradle.kts`, `*.java` |
| `python` | `pyproject.toml`, `requirements.txt`, `Pipfile`, `setup.py`, `*.py` (non-generated) |
| `shell` | tracked `*.sh` / `*.bash`, or `scripts/` with shell entrypoints |

Map language ids to global chapters:

- `node-ts` / `node-js` → **Node / TypeScript** (coding + naming)
- `dotnet` → **.NET (C#)**
- `go` → **Go**
- `java` → **Java**
- `python` → **Python (thin)**
- `shell` → **Shell (thin)**

If **no** known language is detected → keep Universal only in customized language files; report “no known language detected”; do not invent a stack.

### Domains (detect all that apply)

| Domain id | Evidence |
|-----------|----------|
| `api` | HTTP/gRPC server apps, `*Controller*`, route folders, OpenAPI, Nest/Express/Fastify/ASP.NET/etc. |
| `workers` | `*-service` workers, queues, cron/schedulers, consumers, background jobs |
| `script` | top-level / `scripts/` CLIs, one-shot automation (not the main app) |
| `cloud` | `Dockerfile*`, `docker-compose*`, `*.tf`, Helm, k8s manifests, Bicep, cloud IaC dirs |
| `ai-eng` | agents, prompts, evals, LLM client wrappers, obvious AI paths |

Map to packs: `api` → `api-services.md`; `workers` → `background-services.md`; `script` → `scripting.md`; `cloud` → `cloud-manifests.md`; `ai-eng` → `ai-engineering.md`.

Also note layout when obvious: monorepo (`apps/`+`packages/`, turborepo/nx/pnpm-workspaces), polyglot services, single package.

### Repo docs that win

Before rewriting rules into standards files, read `CONTRIBUTING*`, `.editorconfig`, and existing `.cursor/standards/` notes. Those conventions stay authoritative unless the invocation includes `override-local` (which only affects **code** alignment, not inventing conflicts into markdown). Prefer reflecting CONTRIBUTING into the project profile when it is more specific than global.

## Steps

1. **Seed / sync `.cursor/standards/`**
   - Folder **missing** → create it; copy **all** reference files above; write a temporary `README.md` from Always enforce.
   - Folder **exists** and command has **`refresh`** → replace listed files (+ README base) from global.
   - Folder **exists** and **no** `refresh` → copy **only missing** filenames; do not overwrite already-customized files **except** as required in step 2 when re-customizing after detection (see below).

2. **Detect stack** (unless `generic-only`)  
   Build lists: `languages[]`, `domains[]`, optional `layout` note, evidence bullets (short). Multilanguage → keep **every** detected language; do not collapse to one.

3. **Project-aware customize** (unless `generic-only`)  
   Goal: local standards describe **this** repo, not the full unused global encyclopedia.

   Rules for edits:
   - **Always keep** Universal sections and cross-cutting rules.
   - **`coding.md` / `naming.md`:** keep chapters for **detected** languages only. Remove or collapse undetected language chapters into a short “Not in this repo” note listing omitted languages (so agents do not apply them). For multilanguage repos, keep **all** detected chapters side by side.
   - **Domain packs:** keep full files for **detected** domains. For undetected domain files that were seeded, either leave content but add a one-line banner at top: `> Status: not detected in this repo — apply only if a future path clearly matches.` — or omit from README “Apply” list. Do **not** delete domain files on first bootstrap (keeps refresh/align simple); mark status instead.
   - **`comments.md` / `git-pr-commit.md` / `lld-patterns.md`:** keep global content; prepend a short **Project profile** blurb (languages + domains + “prefer patterns already in repo”).
   - **`README.md`:** rewrite to include:
     1. Always enforce (from global skill)
     2. **This project** — languages, domains, layout, evidence one-liners
     3. File table — which packs to apply here
     4. Priority stack (CONTRIBUTING → `.cursor/standards/` → global)
   - Do **not** invent language idioms absent from global chapters.
   - Do **not** encode one-off product features; standards stay conventions, not architecture fiction.
   - When folder **exists** and user did **not** pass `refresh`: still update `README.md` and refresh Project profile banners / language chapter sets if detection differs — but if a file was **hand-edited** beyond prior bootstrap (user customization), preserve hand edits and only update README + report “skipped customize for \<file\> (local edits)”. Heuristic: file still matches global ref or prior bootstrap shape → safe to re-customize; clearly divergent prose → preserve.

4. **Write** `.cursor/rules/project-standards.mdc` with `alwaysApply: true` and this body (fill braces from detection; if `generic-only`, use the generic body without the Project stack bullet):

```markdown
# Project standards

Apply coding-standards layers in this repo: universal always; language chapter when the stack is known; domain pack by path / job shape (`app` | `script` | `ai-eng` | `cloud`).

**Project stack (bootstrap detection):** languages: {comma-separated or `unknown`}; domains: {comma-separated or `none detected`}.

1. `CONTRIBUTING` and `.editorconfig` win over `.cursor/standards/`.
2. `.cursor/standards/` wins over `~/.cursor/skills/coding-standards/references/`.
3. Read `.cursor/standards/` for naming, git, comments, coding, LLD, API services, background services, scripting, AI engineering, and cloud manifests. Prefer chapters listed in `.cursor/standards/README.md` for this project; do not apply “Not in this repo” language chapters.
4. Unknown languages: do not invent idioms — follow universal + repo docs only, or skip alignment for that file.
5. `override-local` applies only while running `/bootstrap-coding-standards` or `/align-coding-standards`. That invocation applies `.cursor/standards/` even when `CONTRIBUTING` or `.editorconfig` disagrees.
```

5. **Code alignment (only if Scope was provided)**  
   Follow the same align rules as `/align-coding-standards`:
   - Extensions: `.cs` `.go` `.java` `.ts` `.tsx` `.js` `.jsx` `.py` `.sh` `.bash`; cloud/IaC (`.tf` `.tfvars` `.bicep` Helm/k8s yaml); AI paths when obvious.
   - Prefer **detected** language + domain packs from step 2.
   - Domain pack from path shape; smallest diff; no new abstractions; no drive-by LLD rewrites.
   - Skip unknown languages; report them.
   - Respect `CONTRIBUTING` / `.editorconfig` unless `override-local`.
   - Lint/test only if the repo already has a command for the touched area.

6. If **no Scope** → stop after seed + customize + rule. Do not edit product code.

7. **Final report** must include:
   - standards files created / updated / skipped
   - **detected languages** + **detected domains** (+ layout)
   - customize actions (chapters kept/removed, banners added)
   - rule written
   - code files changed (if any)
   - conflicts with CONTRIBUTING / `.editorconfig`

## Relation to `/align-coding-standards`

| Command | Use when |
|---------|----------|
| `/bootstrap-coding-standards` | First-time (or refresh) install: seed + **project-aware multilanguage customize** + rule; optional scoped align |
| `/align-coding-standards` | Explicit Standards deltas + required Scope (ongoing alignment) |
| `generic-only` | Need a plain global mirror with no stack trimming |

After bootstrap, further hand-tuning of `.cursor/standards/` is expected; later `/align-coding-standards` or `refresh` + bootstrap re-customize as needed.
