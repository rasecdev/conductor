#!/usr/bin/env python3
"""Generates the README's cost x gain charts from evals/benchmarks/*.json.

Run from the repo root with no arguments. Reads every
evals/benchmarks/<versao>.json (numbers-only, written by
benchmark_summary.py) and writes two SVG files to docs/benchmarks/:

- custo.svg: median tokens and median duration per run, by version,
  comparing the with_skill and without_skill configs when both exist.
- ganho.svg: pass rate (passed/total, aggregated across cases and runs)
  per version, same with_skill/without_skill comparison.

A version missing one of the two configs (e.g. v1.5, which reuses v1.4's
without_skill baseline instead of re-running it) only draws the bar for the
config it actually has -- never a fabricated "without skill" number.

Pure stdlib: no plotting library, so there is nothing new to install in CI.
Output is a deterministic function of the input files -- same
evals/benchmarks/*.json always produces byte-identical SVGs.
"""

import json
import statistics
import sys
from pathlib import Path

BENCHMARKS_DIR = Path("evals/benchmarks")
OUT_DIR = Path("docs/benchmarks")

CONFIGS = ("with_skill", "without_skill")
CONFIG_LABEL = {"with_skill": "com a skill", "without_skill": "sem a skill"}
CONFIG_COLOR = {"with_skill": "#2f6f4f", "without_skill": "#9a9a9a"}


def version_key(version: str) -> tuple:
    return tuple(int(p) for p in version.lstrip("v").split("."))


def load_versions() -> list:
    versions = []
    for path in sorted(BENCHMARKS_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        versions.append(data)
    versions.sort(key=lambda d: version_key(d["version"]))
    return versions


def config_runs(version_data: dict, config: str) -> list:
    return [
        run
        for case in version_data["cases"]
        for run in case["configs"].get(config, [])
    ]


def median_field(version_data: dict, config: str, field: str):
    values = [r[field] for r in config_runs(version_data, config) if r.get(field) is not None]
    return statistics.median(values) if values else None


def pass_rate(version_data: dict, config: str):
    passed = total = 0
    for run in config_runs(version_data, config):
        if run.get("total"):
            passed += run.get("passed") or 0
            total += run["total"]
    return (passed / total * 100) if total else None


def caption(version_data: dict) -> str:
    model = version_data.get("model") or "modelo não registrado"
    return f"{version_data['version']}: {model}, {version_data['date']}"


# --- SVG rendering -----------------------------------------------------------

PANEL_W = 560
PANEL_H = 220
PAD_LEFT = 56
PAD_RIGHT = 20
PAD_TOP = 36
PAD_BOTTOM = 34
BAR_GAP = 10


def fmt_value(value: float, unit: str) -> str:
    if unit == "tokens":
        return f"{value:,.0f}".replace(",", ".")
    if unit == "s":
        return f"{value:.1f}s"
    if unit == "%":
        return f"{value:.0f}%"
    return f"{value:.1f}"


def panel_svg(title: str, unit: str, categories: list, series: dict, y_offset: int) -> list:
    """One grouped-bar panel: one group of bars per category (version)."""
    present_configs = [c for c in CONFIGS if any(v is not None for v in series.get(c, []))]
    all_values = [v for c in present_configs for v in series[c] if v is not None]
    max_value = max(all_values) if all_values else 1.0
    max_value = max_value * 1.15 or 1.0

    plot_w = PANEL_W - PAD_LEFT - PAD_RIGHT
    plot_h = PANEL_H - PAD_TOP - PAD_BOTTOM
    n_cat = max(len(categories), 1)
    group_w = plot_w / n_cat
    n_series = max(len(present_configs), 1)
    bar_w = (group_w - BAR_GAP) / n_series

    out = [f'<g transform="translate(0,{y_offset})">']
    out.append(
        f'<text x="{PANEL_W / 2:.0f}" y="18" text-anchor="middle" '
        f'font-size="14" font-weight="600" fill="#1a1a1a">{title}</text>'
    )
    # axis line
    axis_y = PAD_TOP + plot_h
    out.append(
        f'<line x1="{PAD_LEFT}" y1="{axis_y}" x2="{PAD_LEFT + plot_w}" y2="{axis_y}" '
        f'stroke="#888" stroke-width="1"/>'
    )

    for i, cat in enumerate(categories):
        group_x = PAD_LEFT + i * group_w
        out.append(
            f'<text x="{group_x + group_w / 2:.1f}" y="{axis_y + 16}" '
            f'text-anchor="middle" font-size="11" fill="#333">{cat}</text>'
        )
        for j, config in enumerate(present_configs):
            value = series.get(config, [None] * len(categories))[i]
            if value is None:
                continue
            bar_h = (value / max_value) * plot_h
            bar_x = group_x + j * bar_w + BAR_GAP / 2
            bar_y = axis_y - bar_h
            out.append(
                f'<rect x="{bar_x:.1f}" y="{bar_y:.1f}" width="{bar_w:.1f}" '
                f'height="{bar_h:.1f}" fill="{CONFIG_COLOR[config]}"/>'
            )
            out.append(
                f'<text x="{bar_x + bar_w / 2:.1f}" y="{bar_y - 4:.1f}" '
                f'text-anchor="middle" font-size="10" fill="#1a1a1a">'
                f"{fmt_value(value, unit)}</text>"
            )

    legend_x = PAD_LEFT
    for k, config in enumerate(present_configs):
        lx = legend_x + k * 130
        out.append(f'<rect x="{lx}" y="2" width="10" height="10" fill="{CONFIG_COLOR[config]}"/>')
        out.append(
            f'<text x="{lx + 14}" y="11" font-size="10" fill="#333">'
            f"{CONFIG_LABEL[config]}</text>"
        )
    out.append("</g>")
    return out


def build_svg(panels: list, captions: list) -> str:
    total_h = PANEL_H * len(panels) + 18 * len(captions) + 12
    body = []
    for idx, (title, unit, categories, series) in enumerate(panels):
        body.extend(panel_svg(title, unit, categories, series, idx * PANEL_H))

    caption_y = PANEL_H * len(panels) + 16
    for cap in captions:
        body.append(
            f'<text x="{PAD_LEFT}" y="{caption_y}" font-size="10" fill="#555">{cap}</text>'
        )
        caption_y += 15

    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {PANEL_W} {total_h:.0f}" '
        f'width="{PANEL_W}" height="{total_h:.0f}" font-family="sans-serif">\n'
        f'<rect width="100%" height="100%" fill="#ffffff"/>\n'
        + "\n".join(body)
        + "\n</svg>\n"
    )


def main() -> int:
    versions = load_versions()
    if not versions:
        print(f"{BENCHMARKS_DIR}: nenhum benchmark encontrado", file=sys.stderr)
        return 1

    categories = [v["version"] for v in versions]
    captions = [caption(v) for v in versions]

    tokens_series = {c: [median_field(v, c, "tokens") for v in versions] for c in CONFIGS}
    duration_series = {c: [median_field(v, c, "duration_s") for v in versions] for c in CONFIGS}
    pass_series = {c: [pass_rate(v, c) for v in versions] for c in CONFIGS}

    custo_svg = build_svg(
        [
            ("Tokens medianos por execução", "tokens", categories, tokens_series),
            ("Duração mediana por execução", "s", categories, duration_series),
        ],
        captions,
    )
    ganho_svg = build_svg(
        [("Taxa de acerto por versão", "%", categories, pass_series)],
        captions,
    )

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "custo.svg").write_text(custo_svg, encoding="utf-8", newline="\n")
    (OUT_DIR / "ganho.svg").write_text(ganho_svg, encoding="utf-8", newline="\n")
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")
    print(f"{OUT_DIR.as_posix()}/custo.svg, {OUT_DIR.as_posix()}/ganho.svg gerados a partir de {len(versions)} versao(oes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
