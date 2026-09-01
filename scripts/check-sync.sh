#!/usr/bin/env bash
# Verifies all agent entry-point files are in sync with the canonical source (AGENTS.md).
# Used by CI; run scripts/sync-entrypoints.sh to repair drift.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/AGENTS.md"
status=0

for target in CLAUDE.md GEMINI.md ANTIGRAVITY.md; do
  if ! cmp -s "$SRC" "$ROOT/$target"; then
    echo "DRIFT: $target differs from AGENTS.md" >&2
    status=1
  fi
done

expected="$(mktemp)"
{
  printf -- '---\napplyTo: "**"\n---\n'
  cat "$SRC"
} > "$expected"
if ! cmp -s "$expected" "$ROOT/copilot-instructions.md"; then
  echo "DRIFT: copilot-instructions.md differs from frontmatter + AGENTS.md" >&2
  status=1
fi
rm -f "$expected"

if [[ "$status" -eq 0 ]]; then
  echo "entry points in sync"
fi
exit "$status"
