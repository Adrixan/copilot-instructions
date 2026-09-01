#!/usr/bin/env bash
# Verifies every *.instructions.md file starts with YAML frontmatter containing applyTo,
# and that copilot-instructions.md carries the applyTo frontmatter.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

check_frontmatter() {
  local file="$1"
  if ! head -n 1 "$file" | grep -q '^---$'; then
    echo "MISSING FRONTMATTER: $file" >&2
    return 1
  fi
  if ! head -n 20 "$file" | grep -q '^applyTo:'; then
    echo "MISSING applyTo: $file" >&2
    return 1
  fi
  return 0
}

while IFS= read -r -d '' f; do
  check_frontmatter "$f" || status=1
done < <(find "$ROOT" -name '*.instructions.md' -not -path '*/.git/*' -print0)

check_frontmatter "$ROOT/copilot-instructions.md" || status=1

if [[ "$status" -eq 0 ]]; then
  echo "frontmatter OK"
fi
exit "$status"
