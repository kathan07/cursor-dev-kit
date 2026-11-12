---
name: setup-serena
description: >-
  Write .serena/project.yml, activate Serena, onboard memories when missing,
  and warm the symbol index so the workspace is ready for development. Use
  only when the user invokes /setup-serena.
disable-model-invocation: true
---

# Setup Serena

Slash command for the current workspace. Leaves the repo **ready for coding**: config written, project activated, onboarding memories present (when missing), and language-server symbol cache warmed.

Do **not** edit `.serena/project.local.yml`. That file overrules `project.yml`.

Keys set in `.serena/project.yml` overrule the same keys in `~/.serena/serena_config.yml`. Leave empty keys empty so they keep the PC setting. Do not reimplement that override.

Serena has **no** full-repo index API. Warming = bounded `get_symbols_overview` calls after activate.

## Invoke examples

```text
/setup-serena
```

```text
/setup-serena skip-onboard
```

```text
/setup-serena skip-warm
```

```text
/setup-serena skip-onboard skip-warm
```

## Flags

| Flag | Behavior |
|------|----------|
| *(none)* | Full path: config + activate + onboard + warm |
| `skip-onboard` | Skip onboarding / memories |
| `skip-warm` | Skip symbol warm |

## Detect language servers

Search the workspace outside `node_modules`, `dist`, `build`, and `.git`.

- Any `package.json` → `typescript`. Keep `typescript` while a Node manifest exists. JavaScript uses the same server.
- `go.mod` → `go`
- `*.csproj` → `csharp`
- `pom.xml` → `java`

Put `typescript` first when it is present. `project_name` is the workspace directory name.

## Steps

### 1. Write / sync `project.yml`

If `.serena/project.yml` is missing, create it with only these keys:

```yaml
project_name: "<workspace directory name>"
language_servers:
  - typescript
encoding: "utf-8"
ignore_all_files_in_gitignore: true
ls_workspace_folders:
  - "."
read_only: false
```

Use the detected `language_servers` list, not a hardcoded typescript-only list, when other manifests exist.

If `project.yml` exists, change only `project_name`, `language_servers`, and `ls_workspace_folders` when they disagree with detection. Leave every other key and comment as it is.

### 2. Ensure `.serena/.gitignore`

If `.serena/.gitignore` is missing, create it with exactly:

```
/cache
/project.local.yml
```

If it exists, leave it unchanged unless those two entries are absent — then append the missing lines only.

### 3. Register and activate

1. In `~/.serena/serena_config.yml`, under `projects:`, add this workspace's absolute path only when that path is absent. Do not rewrite the rest of the file.
2. Call Serena `initial_instructions` when you have no session id.
3. Call Serena `activate_project` with `project` set to this workspace path and `session` set to that session id.
4. If activation fails, stop; report failure. Do not onboard or warm.

### 4. Onboarding (default on; skip if `skip-onboard`)

After successful activate:

1. If `.serena/memories/` already has onboarding-style memories (non-empty set that clearly covers project structure / how to run / conventions) → skip; report “onboarding already present”.
2. Else call Serena `onboarding` **once**, follow the returned instructions, and write the requested memories via Serena memory tools (`write_memory` / related).
3. Base memories on repo evidence only (README, package scripts, `apps/` / `packages/` layout, LOCAL_SETUP, etc.). Do **not** invent product fiction.

### 5. Warm index (default on; skip if `skip-warm`)

After activate (and after onboard when that step ran):

1. Discover up to **40** source files outside `node_modules` / `dist` / `build` / `.git`, preferring:
   - `apps/*/src/**/index.ts`, `main.ts`, `server.ts`, `app.ts`, `processor.ts`, `App.tsx`
   - `packages/*/src/**/index.ts`
   - other shallow `src/*.ts` / `src/*.tsx` entrypoints if under the cap
2. For each path, call Serena `get_symbols_overview` with `relative_path` set to the path relative to the workspace root. Batch independent calls when practical; sequential is fine.
3. Failures on individual files: skip and list; do **not** abort the whole setup.
4. Verify readiness:
   - **ready for dev** if `.serena/cache/<ls>/` has files **or** at least one overview succeeded
   - **partial** if the LS cache is empty and every overview failed (or warm was skipped and cache empty with no prior warm)

When both `skip-onboard` and `skip-warm` are set, still complete config + activate; report ready only if cache already non-empty, otherwise partial (config-only).

### 6. Final report

Must include:

- `language_servers`
- `project.yml` created vs updated (or unchanged)
- config path registered vs already present
- activation success
- onboard: ran / skipped (`skip-onboard`) / already present
- warm: N files overviewed, skips, cache non-empty yes/no (or skipped)
- **ready for dev** vs **partial**
