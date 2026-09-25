#!/usr/bin/env python3
"""Validates evals/evals.json against the skill-creator eval schema.

Run from the repo root with no arguments. Exits non-zero and prints every
problem found (not just the first) when the file is invalid.

Checks: valid JSON; top-level `skill_name` and `evals`; each case has the
required fields with the right types; ids and names are unique; every path in
`files` exists (relative to the repo root). Extra fields are allowed.
"""

import json
import sys
from pathlib import Path

EVALS = Path("evals/evals.json")
REQUIRED = {
    "id": int,
    "name": str,
    "prompt": str,
    "expected_output": str,
    "files": list,
}


def main() -> int:
    try:
        data = json.loads(EVALS.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"{EVALS}: {exc}")
        return 1

    errors = []
    if not isinstance(data.get("skill_name"), str):
        errors.append("top-level: missing or non-string 'skill_name'")
    cases = data.get("evals")
    if not isinstance(cases, list) or not cases:
        errors.append("top-level: 'evals' must be a non-empty list")
        cases = []

    seen_ids, seen_names = set(), set()
    for i, case in enumerate(cases):
        where = f"evals[{i}]"
        if not isinstance(case, dict):
            errors.append(f"{where}: must be an object")
            continue
        for field, kind in REQUIRED.items():
            value = case.get(field)
            # bool is a subclass of int; reject it for 'id'.
            if not isinstance(value, kind) or isinstance(value, bool):
                errors.append(f"{where}: '{field}' missing or not {kind.__name__}")
            elif kind is str and not value.strip():
                errors.append(f"{where}: '{field}' is empty")
        if case.get("id") in seen_ids:
            errors.append(f"{where}: duplicate id {case.get('id')}")
        seen_ids.add(case.get("id"))
        if case.get("name") in seen_names:
            errors.append(f"{where}: duplicate name '{case.get('name')}'")
        seen_names.add(case.get("name"))
        for path in case.get("files") or []:
            if not isinstance(path, str) or not Path(path).exists():
                errors.append(f"{where}: file not found: {path}")

    for error in errors:
        print(error)
    if errors:
        return 1
    print(f"{EVALS}: {len(cases)} cases OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
