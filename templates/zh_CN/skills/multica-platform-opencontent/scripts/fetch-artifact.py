#!/usr/bin/env python3
"""Fetch the current file content through its OpenContent internal link."""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

from oc_common import command_help, emit, run_oc


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--internal-link", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    command_help("download")
    result = run_oc("download", {"url": args.internal_link, "outputPath": str(output)})
    emit({"status": "PASS", "internal_link": args.internal_link, "output_path": str(output), "download": result})
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        raise SystemExit(2)
