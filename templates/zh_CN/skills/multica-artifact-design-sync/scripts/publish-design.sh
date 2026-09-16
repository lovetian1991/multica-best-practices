#!/usr/bin/env bash
# Publish one design document through multica-platform-opencontent.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="${MULTICA_SKILLS_ROOT:-$(dirname "$SKILL_DIR")}"
OPENCONTENT_SKILL="${ROOT}/multica-platform-opencontent"
MD_FILE="${1:-}"; ROOT_FOLDER="${OPENCONTENT_ROOT_FOLDER_ID:-}"
[ -f "$MD_FILE" ] || { echo "Usage: [OPENCONTENT_ROOT_FOLDER_ID=...] $0 <design.md>"; exit 1; }
ARGS=("$OPENCONTENT_SKILL/scripts/publish-artifact.py" --type design --file "$MD_FILE" --json)
[ -n "$ROOT_FOLDER" ] && ARGS+=(--root-folder-id "$ROOT_FOLDER")
exec python3 "${ARGS[@]}"
