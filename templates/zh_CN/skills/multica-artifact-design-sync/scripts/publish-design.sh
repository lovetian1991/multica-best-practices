#!/usr/bin/env bash
# Publish one design document through multica-platform-opencontent.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="${MULTICA_SKILLS_ROOT:-$(dirname "$SKILL_DIR")}"
OPENCONTENT_SKILL="${ROOT}/multica-platform-opencontent"
ISSUE_KEY="${1:-}"; MD_FILE="${2:-}"; WORKSPACE="${WORKSPACE_SLUG:-}"; ROOT_FOLDER="${OPENCONTENT_ROOT_FOLDER_ID:-}"
[ -n "$ISSUE_KEY" ] && [ -f "$MD_FILE" ] && [ -n "$WORKSPACE" ] || { echo "Usage: WORKSPACE_SLUG=... [OPENCONTENT_ROOT_FOLDER_ID=...] $0 <ISSUE-KEY> <design.md>"; exit 1; }
ARGS=("$OPENCONTENT_SKILL/scripts/publish-artifact.py" --type design --workspace "$WORKSPACE" --issue "$ISSUE_KEY" --file "$MD_FILE" --json)
[ -n "$ROOT_FOLDER" ] && ARGS+=(--root-folder-id "$ROOT_FOLDER")
exec python3 "${ARGS[@]}"
