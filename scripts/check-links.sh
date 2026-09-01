#!/usr/bin/env bash
# Checks that all relative markdown links inside .md files resolve to existing files
# or directories. External links (http/https/mailto) and pure anchors are skipped.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
broken=0

while IFS= read -r -d '' mdfile; do
  dir="$(dirname "$mdfile")"
  # Extract markdown link targets: [text](target)
  while IFS= read -r target; do
    # Skip external schemes, mailto, and pure anchors
    case "$target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    # Strip anchor fragment
    path="${target%%#*}"
    [[ -z "$path" ]] && continue
    # Resolve relative to the file's directory
    resolved="$(realpath -m "$dir/$path")"
    if [[ ! -e "$resolved" ]]; then
      echo "BROKEN LINK: $mdfile -> $target" >&2
      broken=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$mdfile" | sed -E 's/^\]\(//; s/\)$//' | tr -d '\r')
done < <(find "$ROOT" -name '*.md' -not -path '*/.git/*' -print0)

if [[ "$broken" -eq 0 ]]; then
  echo "all relative links resolve"
fi
exit "$broken"
