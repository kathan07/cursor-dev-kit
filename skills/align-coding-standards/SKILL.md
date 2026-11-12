---
name: align-coding-standards
description: >-
  Update this repo's .cursor/standards files, write the project standards
  rule, then align a named scope of code to those standards. Use only when
  the user invokes /align-coding-standards.
disable-model-invocation: true
---

# Align coding standards

Slash command for the current repo. Edit this repo's `.cursor/standards/` and the named code scope. Do not edit `~/.cursor/skills/coding-standards/` or the dev pipeline.

**Layers** match global coding-standards: universal → language → domain. Align known packs only. Unknown languages → **skip and report** (do not invent idioms).

## Required input

Stop and ask when either part is missing. Edit nothing until both are present.

- **Standards:** which project file changes, and the rule text.
- **Scope:** one or more paths inside this repo. The whole repo only when the command text includes `scope: all`.

`override-local` in the command text applies `.cursor/standards/` even when `CONTRIBUTING` or `.editorconfig` disagrees. Without that phrase, those two files win and conflicting code stays unchanged.

## Project files

Seed/sync these under `.cursor/standards/` (from `~/.cursor/skills/coding-standards/references/<same-name>`):

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
- `README.md` (from coding-standards skill **Always enforce** summary — not a references copy)

## Code alignment (in-scope extensions)

When the path is inside **Scope**, align using the matching language + domain pack:

| Pack / kind | Extensions / paths |
|-------------|--------------------|
| App languages | `.cs`, `.go`, `.java`, `.ts`, `.tsx`, `.js`, `.jsx` |
| Thin languages | `.py`, `.sh`, `.bash` |
| Cloud / IaC | `.tf`, `.tfvars`, `.bicep`, Helm `Chart.yaml` / templates, k8s-ish `.yaml` / `.yml` under obvious infra paths |
| AI eng | Same language files when scope is clearly prompts / agents / evals — apply `ai-engineering.md` (secrets, tool boundaries); no framework rewrites |
| Other | Skip and list in the report |

Pick domain ref from path shape (`api-services` / `background-services` / `scripting` / `cloud-manifests` / `ai-engineering`) — not always API services.

## Steps

1. **Seed / sync standards**
   - If `.cursor/standards/` is **missing**: create it and copy **all** reference files listed above from `~/.cursor/skills/coding-standards/references/`. Write `README.md` from the **Always enforce** summary in `~/.cursor/skills/coding-standards/SKILL.md`.
   - If `.cursor/standards/` **exists**: copy **only missing** filenames from global refs. Do **not** overwrite existing customized files unless the user’s Standards input explicitly asks to refresh/replace from global.
2. Apply the standards delta to the named standards files (when Standards input requests edits). Update `README.md` when the summary would otherwise be wrong.
3. Write `.cursor/rules/project-standards.mdc` with `alwaysApply: true` and this body:

```markdown
# Project standards

Apply coding-standards layers in this repo: universal always; language chapter when the stack is known; domain pack by path / job shape (`app` | `script` | `ai-eng` | `cloud`).

1. `CONTRIBUTING` and `.editorconfig` win over `.cursor/standards/`.
2. `.cursor/standards/` wins over `~/.cursor/skills/coding-standards/references/`.
3. Read `.cursor/standards/` for naming, git, comments, coding, LLD, API services, background services, scripting, AI engineering, and cloud manifests.
4. Unknown languages: do not invent idioms — follow universal + repo docs only, or skip alignment for that file.
5. `override-local` applies only while running `/align-coding-standards`. That invocation applies `.cursor/standards/` even when `CONTRIBUTING` or `.editorconfig` disagrees.
```

4. Re-read the project standards just written. Align only in-scope source matching the extension table above. Skip everything else and say so.
5. Smallest diff that meets the new rule. No new abstractions, no drive-by refactors, no LLD rewrite unless the standards delta explicitly changes a pattern for that code.
6. On conflict with `CONTRIBUTING` or `.editorconfig`, report the conflict and leave that code alone, unless the command text includes `override-local`.
7. Report standard files changed, code files changed, files skipped, and conflicts. Run an existing lint or test command only when the repo already has one for the touched area. Do not add a test framework.
