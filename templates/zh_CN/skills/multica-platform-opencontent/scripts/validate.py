#!/usr/bin/env python3
"""Offline validation for the platform skill."""
from __future__ import annotations

from pathlib import Path
import sys

import yaml


ROOT = Path(__file__).resolve().parent.parent
required = ["SKILL.md", "config.yaml", ".env.example", "cli/bin/oc.js", "scripts/oc_common.py", "scripts/resolve-folder.py", "scripts/publish-artifact.py", "scripts/publish-artifacts.py", "scripts/fetch-artifact.py"]
missing = [item for item in required if not (ROOT / item).is_file()]
if missing:
    raise SystemExit(f"missing required files: {', '.join(missing)}")
cfg = yaml.safe_load((ROOT / "config.yaml").read_text(encoding="utf-8")) or {}
oc = cfg.get("opencontent") or {}
allowed = oc.get("allowed_root_folder_ids") or []
if not allowed:
    raise SystemExit("opencontent.allowed_root_folder_ids must not be empty")
if (oc.get("upload") or {}).get("update_strategy") != "majorUpgrade":
    raise SystemExit("update_strategy must be majorUpgrade")
print("multica-platform-opencontent validation ok")
