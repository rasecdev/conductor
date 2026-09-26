#!/usr/bin/env python3
"""Summarizes eval iterations (skill-creator layout) into numbers-only JSON.

Usage:
  python scripts/benchmark_summary.py --version v1.5 --model <id|none> \
      --date YYYY-MM-DD [--note "..."] <iteration-dir> [<iteration-dir>...]

Reads <iteration-dir>/eval-*/<config>/run-*/{grading,timing}.json and prints
one JSON object to stdout, meant for evals/benchmarks/<version>.json. Later
iteration dirs override earlier ones for the same eval. Only numbers go out:
never prompts, responses or evidence text, which can cite private projects.
"""

import argparse
import json
import re
import statistics
import sys
from pathlib import Path


def read(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def run_numbers(run: Path) -> dict:
    grading = read(run / "grading.json") or {}
    timing = read(run / "timing.json") or {}
    summary = grading.get("summary", {})
    metrics = grading.get("execution_metrics", {})
    return {
        "run": run.name,
        "passed": summary.get("passed"),
        "total": summary.get("total"),
        "tokens": timing.get("total_tokens"),
        "duration_s": timing.get("total_duration_seconds"),
        "tool_calls": metrics.get("total_tool_calls"),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--version", required=True)
    ap.add_argument("--model", required=True, help="model id, or 'none' if not recorded")
    ap.add_argument("--date", required=True)
    ap.add_argument("--note", default="")
    ap.add_argument("iterations", nargs="+", type=Path)
    args = ap.parse_args()

    cases = {}
    for it in args.iterations:
        for case_dir in sorted(it.glob("eval-*")):
            m = re.match(r"eval-(\d+)-(.+)", case_dir.name)
            if not m:
                continue
            configs = {}
            for cfg in sorted(p for p in case_dir.iterdir() if p.is_dir()):
                runs = [run_numbers(r) for r in sorted(cfg.glob("run-*")) if r.is_dir()]
                if runs:
                    configs[cfg.name] = runs
            if configs:
                cases[int(m.group(1))] = {"id": int(m.group(1)), "name": m.group(2),
                                          "iteration": it.name, "configs": configs}

    def median_tokens(config: str):
        vals = [r["tokens"] for c in cases.values() for r in c["configs"].get(config, [])
                if r["tokens"] is not None]
        return statistics.median(vals) if vals else None

    configs = sorted({k for c in cases.values() for k in c["configs"]})
    out = {
        "version": args.version,
        "model": None if args.model == "none" else args.model,
        "date": args.date,
        "note": args.note,
        "iterations": [it.name for it in args.iterations],
        "median_tokens_per_run": {cfg: median_tokens(cfg) for cfg in configs},
        "cases": [cases[k] for k in sorted(cases)],
    }
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
