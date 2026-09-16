#!/usr/bin/env bash
# Publish one PRD through multica-platform-opencontent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ROOT="${MULTICA_SKILLS_ROOT:-$(dirname "$SKILL_DIR")}"
OPENCONTENT_SKILL="${ROOT}/multica-platform-opencontent"

usage() {
  echo "Usage: $0 --file PATH [--root-folder-id ID] [--reference JSON]"
  exit 1
}

ROOT_FOLDER=""; FILE=""; REFERENCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root-folder-id) ROOT_FOLDER="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    --reference) REFERENCE="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -f "$FILE" ] || usage

ARGS=("$OPENCONTENT_SKILL/scripts/publish-artifact.py" --type requirement --file "$FILE" --json)
[ -n "$ROOT_FOLDER" ] && ARGS+=(--root-folder-id "$ROOT_FOLDER")
[ -n "$REFERENCE" ] && ARGS+=(--reference "$REFERENCE")
exec python3 "${ARGS[@]}"
