#!/usr/bin/env python3
"""Loop over single-file publication; each file keeps an independent result."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", required=True, choices=["requirement", "design", "api", "test-cases", "test-reports", "cicd"])
    parser.add_argument("--file", action="append", required=True)
    parser.add_argument("--root-folder-id", default="")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    script = Path(__file__).with_name("publish-artifact.py")
    results: list[dict] = []
    for file_path in args.file:
        command = [sys.executable, str(script), "--type", args.type, "--file", file_path, "--json"]
        if args.root_folder_id:
            command.extend(["--root-folder-id", args.root_folder_id])
        process = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
        if process.returncode == 0:
            results.append(json.loads(process.stdout))
        else:
            results.append({"status": "BLOCKED", "file_name": Path(file_path).name, "error": (process.stderr or process.stdout).strip()})
    status = "PASS" if all(item.get("status") == "PASS" for item in results) else "BLOCKED"
    json.dump({"status": status, "total": len(results), "items": results}, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0 if status == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
