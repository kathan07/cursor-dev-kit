#!/usr/bin/env bash
# Install cursor-dev-kit into ~/.cursor (skills, rules, agents) and merge Serena MCP.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CURSOR_HOME/dev-kit-backup/$TS"

mkdir -p "$CURSOR_HOME/skills" "$CURSOR_HOME/rules" "$CURSOR_HOME/agents" "$BACKUP/skills" "$BACKUP/rules" "$BACKUP/agents"

backup_path() {
  local src="$1"
  local dest="$2"
  if [[ -e "$src" || -L "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
  fi
}

echo "Installing cursor-dev-kit into $CURSOR_HOME"
echo "Backups (if any) → $BACKUP"

# Skills
shopt -s nullglob
for dir in "$ROOT/skills"/*/; do
  name="$(basename "$dir")"
  target="$CURSOR_HOME/skills/$name"
  if [[ -e "$target" ]]; then
    backup_path "$target" "$BACKUP/skills/$name"
    rm -rf "$target"
  fi
  mkdir -p "$target"
  cp -a "$dir". "$target/"
  echo "  skill: $name"
done

# Rules
for f in "$ROOT/rules"/*.mdc; do
  name="$(basename "$f")"
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

echo
echo "Done. Reload Cursor MCP if Serena was added."
echo "In each app repo: /bootstrap-coding-standards then /setup-serena"
echo "Re-run install anytime: /install-dev-kit or ./install.sh"
