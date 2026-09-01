#!/usr/bin/env bash
# Description: Example deployment script following the bash preamble spec.
# Usage: ./deploy.sh [--env <name>] <artifact-path>
# Requirements: curl

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-0}" == "1" ]] && set -x

ENV_NAME="staging"
ARTIFACT=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [--env <name>] <artifact-path>

Options:
  --env <name>   Target environment (default: staging)
  -h, --help     Show this help
EOF
}

log() { printf '%s\n' "$*" >&2; }
die() { log "Error: $*"; exit 1; }

# --- Argument parsing: while/case pattern, validate after the loop ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      [[ $# -ge 2 ]] || die "--env requires a value"
      ENV_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      ARTIFACT="$1"
      shift
      ;;
  esac
done

[[ -n "$ARTIFACT" ]] || { usage; die "artifact path is required"; }

# Allowlist validation — never pass unchecked input further.
[[ "$ENV_NAME" =~ ^(staging|production)$ ]] || die "env must be 'staging' or 'production'"
[[ -f "$ARTIFACT" ]] || die "artifact not found: $ARTIFACT"

# Dependency check
command -v curl &>/dev/null || die "curl is required"

# Temp file with cleanup trap (mktemp, never predictable paths)
tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT

# --- Idempotent operations: check before acting ---
deploy_dir="/var/deploy/${ENV_NAME}"
if [[ ! -d "$deploy_dir" ]]; then
  mkdir -p "$deploy_dir"
  log "created $deploy_dir"
fi

log "deploying $(basename "$ARTIFACT") to ${ENV_NAME}…"
cp "$ARTIFACT" "$tmpfile"
mv "$tmpfile" "$deploy_dir/current" || die "install failed"

log "deploy complete: ${deploy_dir}/current"
