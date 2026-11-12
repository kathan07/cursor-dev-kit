#!/usr/bin/env bash
# Install cursor-dev-kit into ~/.cursor, clean leftover Caveman, bind official Caveman for Cursor.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CURSOR_HOME/dev-kit-backup/$TS"
AGENTS_BACKUP="$AGENTS_HOME/dev-kit-backup/$TS"
CAVEMAN_REF="${CAVEMAN_REF:-v4.1.0}"

mkdir -p "$CURSOR_HOME/skills" "$CURSOR_HOME/rules" "$CURSOR_HOME/agents" \
  "$BACKUP/skills" "$BACKUP/rules" "$BACKUP/agents" "$BACKUP/cursor-misc" \
  "$AGENTS_BACKUP/skills"

backup_path() {
  local src="$1"
  local dest="$2"
  if [[ -e "$src" || -L "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
  fi
}

echo "Installing cursor-dev-kit into $CURSOR_HOME"
echo "Backups → $BACKUP"
echo "Agents backups → $AGENTS_BACKUP"
echo

# --- Cleanup leftover Caveman (before kit copy + official install) ---
echo "Cleanup: leftover Caveman under ~/.cursor and ~/.agents"
CLEANED=0

if [[ -e "$CURSOR_HOME/rules/caveman.mdc" ]]; then
  backup_path "$CURSOR_HOME/rules/caveman.mdc" "$BACKUP/rules/caveman.mdc"
  rm -f "$CURSOR_HOME/rules/caveman.mdc"
  echo "  removed ~/.cursor/rules/caveman.mdc"
  CLEANED=1
fi

if [[ -e "$CURSOR_HOME/skills/caveman" ]]; then
  backup_path "$CURSOR_HOME/skills/caveman" "$BACKUP/skills/caveman"
  rm -rf "$CURSOR_HOME/skills/caveman"
  echo "  removed ~/.cursor/skills/caveman"
  CLEANED=1
fi

if [[ -e "$CURSOR_HOME/caveman" ]]; then
  backup_path "$CURSOR_HOME/caveman" "$BACKUP/cursor-misc/caveman"
  rm -rf "$CURSOR_HOME/caveman"
  echo "  removed ~/.cursor/caveman"
  CLEANED=1
fi

HOOKS_JSON="$CURSOR_HOME/hooks.json"
HAD_RTK_HOOK=0
if [[ -f "$HOOKS_JSON" ]]; then
  backup_path "$HOOKS_JSON" "$BACKUP/cursor-misc/hooks.json"
  if grep -q 'rtk hook cursor' "$HOOKS_JSON" 2>/dev/null; then
    HAD_RTK_HOOK=1
  fi
  echo "  backed up ~/.cursor/hooks.json"
fi

if [[ -d "$AGENTS_HOME/skills" ]]; then
  shopt -s nullglob
  for d in "$AGENTS_HOME/skills"/caveman "$AGENTS_HOME/skills"/caveman-* "$AGENTS_HOME/skills"/cavecrew; do
    [[ -e "$d" ]] || continue
    name="$(basename "$d")"
    backup_path "$d" "$AGENTS_BACKUP/skills/$name"
    rm -rf "$d"
    echo "  removed ~/.agents/skills/$name"
    CLEANED=1
  done
  shopt -u nullglob
fi

if [[ "$CLEANED" -eq 0 ]]; then
  echo "  (nothing to clean)"
fi
echo

# --- Copy kit skills (exclude caveman — official owns live skill) ---
shopt -s nullglob
for dir in "$ROOT/skills"/*/; do
  name="$(basename "$dir")"
  if [[ "$name" == "caveman" ]]; then
    echo "  skill: caveman — skipped (official Caveman install owns this)"
    continue
  fi
  target="$CURSOR_HOME/skills/$name"
  if [[ -e "$target" ]]; then
    backup_path "$target" "$BACKUP/skills/$name"
    rm -rf "$target"
  fi
  mkdir -p "$target"
  cp -a "$dir". "$target/"
  echo "  skill: $name"
done

# Rules (skip caveman.mdc if present in tree)
for f in "$ROOT/rules"/*.mdc; do
  name="$(basename "$f")"
  if [[ "$name" == "caveman.mdc" ]]; then
    echo "  rule: caveman.mdc — skipped (official session hook)"
    continue
  fi
  target="$CURSOR_HOME/rules/$name"
  if [[ -e "$target" ]]; then
    backup_path "$target" "$BACKUP/rules/$name"
  fi
  cp -a "$f" "$target"
  echo "  rule: $name"
done

# Agents
for f in "$ROOT/agents"/*.md; do
  name="$(basename "$f")"
  target="$CURSOR_HOME/agents/$name"
  if [[ -e "$target" ]]; then
    backup_path "$target" "$BACKUP/agents/$name"
  fi
  cp -a "$f" "$target"
  echo "  agent: $name"
done

# Merge Serena into mcp.json if missing
MCP_JSON="$CURSOR_HOME/mcp.json"
EXAMPLE="$ROOT/mcp/serena.mcp.json.example"
if [[ -f "$EXAMPLE" ]]; then
  if [[ ! -f "$MCP_JSON" ]]; then
    cp -a "$EXAMPLE" "$MCP_JSON"
    echo "  mcp: created $MCP_JSON with Serena"
  else
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$MCP_JSON" "$EXAMPLE" "$BACKUP/mcp.json" <<'PY'
import json, sys, pathlib, shutil
mcp_path, example_path, backup_path = map(pathlib.Path, sys.argv[1:4])
data = json.loads(mcp_path.read_text())
example = json.loads(example_path.read_text())
servers = data.setdefault("mcpServers", {})
if "serena" in servers:
    print("  mcp: serena already present — left unchanged")
else:
    shutil.copy2(mcp_path, backup_path)
    servers["serena"] = example["mcpServers"]["serena"]
    mcp_path.write_text(json.dumps(data, indent=2) + "\n")
    print("  mcp: merged serena into mcp.json (backup saved)")
PY
    else
      echo "  mcp: python3 missing — merge serena manually from mcp/serena.mcp.json.example"
    fi
  fi
fi

# --- Official Caveman Cursor bind ---
echo
echo "Official Caveman Cursor bind (JuliusBrussee/caveman@$CAVEMAN_REF --only cursor)"
if ! command -v npx >/dev/null 2>&1; then
  echo "  FAIL: npx/Node missing — install Node 18+ then re-run for Caveman bind"
else
  # npm 12+ refuses git fetches unless --allow-git=root (see Caveman INSTALL docs)
  NPX_GIT_FLAGS=()
  if command -v npm >/dev/null 2>&1; then
    NPM_MAJOR="$(npm --version 2>/dev/null | cut -d. -f1 || echo 0)"
    if [[ "$NPM_MAJOR" =~ ^[0-9]+$ ]] && [[ "$NPM_MAJOR" -ge 12 ]]; then
      NPX_GIT_FLAGS+=(--allow-git=root)
      echo "  npx: npm $NPM_MAJOR detected — using --allow-git=root"
    fi
  fi
  if npx "${NPX_GIT_FLAGS[@]}" -y "github:JuliusBrussee/caveman#${CAVEMAN_REF}" -- --only cursor; then
    echo "  caveman: official --only cursor finished"
  else
    echo "  FAIL: official Caveman install exited non-zero"
  fi
fi

# Restore rtk hook if official install dropped it
if [[ "$HAD_RTK_HOOK" -eq 1 ]] && [[ -f "$HOOKS_JSON" ]]; then
  if ! grep -q 'rtk hook cursor' "$HOOKS_JSON" 2>/dev/null; then
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$HOOKS_JSON" "$BACKUP/cursor-misc/hooks.json" <<'PY'
import json, sys, pathlib
live, backup = map(pathlib.Path, sys.argv[1:3])
data = json.loads(live.read_text()) if live.exists() else {"version": 1, "hooks": {}}
bak = json.loads(backup.read_text()) if backup.exists() else {}
hooks = data.setdefault("hooks", {})
pre = hooks.setdefault("preToolUse", [])
rtk_entries = []
for entry in (bak.get("hooks") or {}).get("preToolUse") or []:
    if isinstance(entry, dict) and "rtk hook cursor" in str(entry.get("command", "")):
        rtk_entries.append(entry)
if not rtk_entries:
    rtk_entries = [{"command": "rtk hook cursor", "matcher": "Shell"}]
existing = {json.dumps(e, sort_keys=True) for e in pre}
for e in rtk_entries:
    key = json.dumps(e, sort_keys=True)
    if key not in existing:
        pre.append(e)
live.write_text(json.dumps(data, indent=2) + "\n")
print("  hooks: restored rtk preToolUse from backup")
PY
    else
      echo "  hooks: rtk missing after Caveman install — restore manually from $BACKUP/cursor-misc/hooks.json"
    fi
  else
    echo "  hooks: rtk still present"
  fi
fi

# Verify Caveman bind
echo
echo "Caveman bind check:"
if [[ -d "$CURSOR_HOME/caveman" ]]; then
  echo "  ~/.cursor/caveman: present"
else
  echo "  ~/.cursor/caveman: MISSING"
fi
if [[ -f "$HOOKS_JSON" ]] && grep -qi caveman "$HOOKS_JSON" 2>/dev/null; then
  echo "  hooks.json caveman: present"
else
  echo "  hooks.json caveman: MISSING or not detected"
fi

# Soft dependency checks
echo
echo "Dependency checks:"
if command -v uvx >/dev/null 2>&1 || command -v uv >/dev/null 2>&1; then
  echo "  uv/uvx: ok"
else
  echo "  uv/uvx: MISSING — install from https://docs.astral.sh/uv/ (needed for Serena MCP)"
fi
if command -v rtk >/dev/null 2>&1; then
  echo "  rtk: ok"
else
  echo "  rtk: MISSING — optional; install if your token-saviour / agent stack expects it (e.g. brew)"
fi
if command -v npx >/dev/null 2>&1; then
  echo "  npx: ok"
else
  echo "  npx: MISSING — required for official Caveman bind"
fi

echo
echo "Done. Reload Cursor / start a new chat so the Caveman session hook applies."
echo "Reload MCP if Serena was added."
echo "In each app repo: /bootstrap-coding-standards then /setup-serena"
echo "Re-run: /install-dev-kit or ./install.sh"
