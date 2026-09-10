#!/usr/bin/env python3
"""Resolve and create the stable OpenContent folder for one artifact."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import sys

import yaml

from oc_common import command_help, emit, first_value, items, run_oc


def load_config() -> dict:
    path = Path(__file__).resolve().parent.parent / "config.yaml"
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def resolve_env(value: object) -> str:
    """Resolve ${NAME} placeholders used for runtime-injected configuration."""
    text = str(value or "").strip()
    if text.startswith("${") and text.endswith("}"):
        return os.environ.get(text[2:-1], "").strip()
    return text


def folder_name(data: dict, expected: str) -> str | None:
    for item in items(data):
        if str(item.get("name", "")) == expected and str(item.get("type", "folder")).lower() in {"folder", "directory", "dir"}:
            return str(item.get("id") or item.get("guid") or item.get("folderId"))
    return None


def ensure_child(parent: str, name: str) -> str:
    command_help("file-list")
    listing = run_oc("file-list", {"folderId": parent, "pageNum": 1, "pageSize": 100})
    existing = folder_name(listing, name)
    if existing:
        return existing
    command_help("create-folder")
    created = run_oc("create-folder", {"name": name, "parentFolderId": parent})
    result = first_value(created, "folderId", "id", "guid")
    if not result:
        raise RuntimeError(f"create-folder returned no folder identifier for {name!r}")
    return str(result)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", required=True, choices=["requirement", "design", "api", "test-cases", "test-reports", "cicd"])
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--issue", required=True)
    parser.add_argument("--root-folder-id", default="")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    cfg = load_config().get("opencontent", {})
    # The issue-scoped runtime value is the normal Multica integration path.
    # Explicit CLI input remains useful for local/manual runs and takes priority.
    root_folder_id = (
        str(args.root_folder_id or "").strip()
        or os.environ.get("MULTICA_KB_FOLDER_ID", "").strip()
        or resolve_env(cfg.get("artifact_root_folder_id"))
    )
    if not root_folder_id:
        raise RuntimeError("root folder is missing; set MULTICA_KB_FOLDER_ID, pass --root-folder-id, or configure artifact_root_folder_id")
    allowed = {resolve_env(value) for value in cfg.get("allowed_root_folder_ids", [])}
    allowed.discard("")
    if root_folder_id not in allowed:
        raise RuntimeError("root folder is not in opencontent.allowed_root_folder_ids")
    command_help("folder-info")
    run_oc("folder-info", {"folderId": root_folder_id})
    workspace = ensure_child(root_folder_id, args.workspace)
    issue = ensure_child(workspace, args.issue)
    artifact_name = (cfg.get("folders") or {}).get(args.type, args.type)
    artifact = ensure_child(issue, artifact_name)
    emit({"root_folder_id": root_folder_id, "workspace_folder_id": workspace, "issue_folder_id": issue, "folder_id": artifact, "artifact_type": args.type})
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        raise SystemExit(2)
