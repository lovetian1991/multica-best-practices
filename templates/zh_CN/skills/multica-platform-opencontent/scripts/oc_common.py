"""Small, dependency-free wrapper around the oc-basic CLI."""
from __future__ import annotations

import json
import os
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any


def cli_command() -> list[str]:
    bundled_cli = Path(__file__).resolve().parent.parent / "cli" / "bin" / "oc.js"
    value = os.environ.get("OC_CLI_PATH") or os.environ.get("OPENCONTENT_CLI_PATH") or str(bundled_cli)
    parts = shlex.split(value, posix=os.name != "nt")
    if not parts:
        raise RuntimeError("OC_CLI_PATH is empty")
    if parts[0].lower().endswith((".js", ".mjs")):
        return ["node", *parts]
    return parts


def run_oc(command: str, params: dict[str, Any] | None = None, *, help_only: bool = False) -> dict[str, Any]:
    args = [*cli_command(), command, "--help" if help_only else "--json"]
    if not help_only:
        for key, value in (params or {}).items():
            if value is None or value is False:
                continue
            if value is True:
                value = "true"
            args.append(f"{key}={value}")
    # Keep platform-injected credentials available to oc-basic/oc.js.
    proc = subprocess.run(
        args,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=os.environ.copy(),
    )
    output = (proc.stdout or "").strip()
    if proc.returncode != 0:
        detail = (proc.stderr or output or f"oc-basic {command} failed").strip()
        raise RuntimeError(detail)
    if help_only:
        return {"help": output}
    try:
        return json.loads(output)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"oc-basic {command} returned non-JSON output: {output[:500]}") from exc


def command_help(command: str) -> None:
    run_oc(command, help_only=True)


def first_value(data: Any, *keys: str) -> Any:
    if isinstance(data, dict):
        for key in keys:
            if data.get(key) not in (None, ""):
                return data[key]
        for value in data.values():
            found = first_value(value, *keys)
            if found not in (None, ""):
                return found
    elif isinstance(data, list):
        for value in data:
            found = first_value(value, *keys)
            if found not in (None, ""):
                return found
    return None


def items(data: Any) -> list[dict[str, Any]]:
    if isinstance(data, dict):
        value = data.get("items")
        if isinstance(value, list):
            return [item for item in value if isinstance(item, dict)]
        for child in data.values():
            found = items(child)
            if found:
                return found
    elif isinstance(data, list):
        return [item for item in data if isinstance(item, dict)]
    return []


def emit(data: Any) -> None:
    json.dump(data, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
