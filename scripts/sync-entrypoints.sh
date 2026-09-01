#!/usr/bin/env bash
# Regenerates all agent entry-point files from the canonical source (AGENTS.md).
# - Identical copies: CLAUDE.md, GEMINI.md, ANTIGRAVITY.md
# - Copilot copy: copilot-instructions.md (canonical + YAML applyTo frontmatter)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/AGENTS.md"

if [[ ! -f "$SRC" ]]; then
  echo "Error: canonical source AGENTS.md not found" >&2
  exit 1
fi

for target in CLAUDE.md GEMINI.md ANTIGRAVITY.md; do
  cp -f "$SRC" "$ROOT/$target"
  echo "synced: $target"
done

{
  printf -- '---\napplyTo: "**"\n---\n'
  cat "$SRC"
} > "$ROOT/copilot-instructions.md"
echo "synced: copilot-instructions.md (with applyTo frontmatter)"
