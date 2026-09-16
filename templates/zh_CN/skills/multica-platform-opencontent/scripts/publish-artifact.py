#!/usr/bin/env python3
"""Publish one artifact and return a Multica metadata/comment handoff."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
from urllib.parse import urlsplit

from oc_common import command_help, emit, first_value, items, load_config, resolve_env, run_oc


TYPES = ("requirement", "design", "api", "test-cases", "test-reports", "cicd")


def resolve_link_base() -> str:
    """Browser-facing address of the KB platform.

    oc.js builds the preview link from MULTICA_SERVER_URL, which is the Multica
    API facade. The KB UI lives on its own address, so it has to come from
    config; an empty value keeps the CLI's URL unchanged.
    """
    cfg = load_config().get("opencontent", {})
    value = resolve_env(cfg.get("internal_link_base_url")) or os.environ.get("OPENCONTENT_WEB_URL", "")
    return value.strip().rstrip("/")


def apply_link_base(url: str, base: str) -> str:
    """Replace the link origin, keeping path, query and the preview fragment."""
    if not base:
        return url
    if not base.startswith(("http://", "https://")):
        raise RuntimeError(f"internal_link_base_url must be an absolute http(s) URL: {base!r}")
    parsed = urlsplit(url)
    suffix = parsed.path
    if parsed.query:
        suffix += f"?{parsed.query}"
    if parsed.fragment:
        suffix += f"#{parsed.fragment}"
    return f"{base}{suffix}"


def load_reference(path: str | None) -> dict:
    if not path:
        return {}
    return json.loads(Path(path).read_text(encoding="utf-8"))


def resolve_folder(args: argparse.Namespace) -> dict:
    script = Path(__file__).with_name("resolve-folder.py")
    cmd = [sys.executable, str(script), "--type", args.type]
    if args.root_folder_id:
        cmd.extend(["--root-folder-id", args.root_folder_id])
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        raise RuntimeError((result.stderr or result.stdout).strip())
    return json.loads(result.stdout)


def locate_existing(folder_id: str, filename: str) -> dict | None:
    command_help("file-list")
    data = run_oc("file-list", {"folderId": folder_id, "pageNum": 1, "pageSize": 100})
    matches = [item for item in items(data) if str(item.get("name", "")) == filename and str(item.get("type", "file")).lower() not in {"folder", "directory", "dir"}]
    if len(matches) > 1:
        raise RuntimeError(f"BLOCKED: multiple files named {filename!r} exist in folder {folder_id}")
    return matches[0] if matches else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", required=True, choices=TYPES)
    parser.add_argument("--file", required=True)
    parser.add_argument("--root-folder-id", default="", help="Upstream override; otherwise use platform config default")
    parser.add_argument("--reference", help="JSON file containing previous file_id/file_guid/internal_link")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    local_file = Path(args.file)
    if not local_file.is_file():
        raise RuntimeError(f"artifact file does not exist: {local_file}")
    folder = resolve_folder(args)
    reference = load_reference(args.reference)
    existing = reference.get("file_id") or reference.get("file_guid") or reference.get("internal_link")
    if not existing:
        existing_item = locate_existing(folder["folder_id"], local_file.name)
        existing = (existing_item or {}).get("id") or (existing_item or {}).get("guid")
    params = {"filePaths": str(local_file), "folderId": folder["folder_id"]}
    if existing:
        params.update({"fileId": existing, "fileModel": "UPDATE", "strategy": "majorUpgrade"})
    else:
        params["fileModel"] = "UPLOAD"
    command_help("upload")
    uploaded = run_oc("upload", params)
    success = first_value(uploaded, "success")
    if success is False:
        raise RuntimeError(f"upload failed: {uploaded}")
    file_id = first_value(uploaded, "fileId", "id") or existing
    file_guid = first_value(uploaded, "fileGuid", "guid")
    if not file_id and not file_guid:
        raise RuntimeError(f"upload returned no file identifier: {uploaded}")
    locator = str(file_id or file_guid)
    command_help("file-internal-link")
    linked = run_oc("file-internal-link", {"fileId": locator})
    internal_link = first_value(linked, "url", "internalLink", "internal_link")
    if not internal_link:
        raise RuntimeError(f"file-internal-link returned no url: {linked}")
    link_base = resolve_link_base()
    internal_link = apply_link_base(str(internal_link), link_base)
    operation = "UPDATE" if existing else "UPLOAD"
    prefix = f"artifact_{args.type.replace('-', '_')}"
    root_folder_id = folder["root_folder_id"]
    metadata = {f"{prefix}_internal_link": internal_link, f"{prefix}_file_id": file_id or file_guid, "artifact_root_folder_id": root_folder_id}
    result = {"status": "PASS", "operation": operation, "artifact_type": args.type, "file_name": local_file.name, "internal_link": internal_link, "internal_link_base_url": link_base, "file_id": file_id, "file_guid": file_guid, "folder_id": folder["folder_id"], "root_folder_id": root_folder_id, "metadata_patch": metadata, "comment": f"{operation} {args.type} artifact {local_file.name}: {internal_link}"}
    emit(result)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        raise SystemExit(2)
