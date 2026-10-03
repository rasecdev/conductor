#!/usr/bin/env bash
# Deterministic test of scripts/generate_benchmark_charts.py: running it
# against the repository's own evals/benchmarks/*.json must always produce
# the same custo.svg/ganho.svg bytes. No visual/pixel inspection -- just a
# hash comparison across two runs plus a check that the committed output
# matches what the script produces right now.
#
# Usage: scripts/test_generate_benchmark_charts.sh

set -uo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
generator="$repo_root/scripts/generate_benchmark_charts.py"
out_dir="$repo_root/docs/benchmarks"

cd "$repo_root" || exit 1

failed=0

run1_tmp="$(mktemp -d)"
run2_tmp="$(mktemp -d)"
# shellcheck disable=SC2317 # invoked indirectly via trap, not unreachable
cleanup() { rm -rf "$run1_tmp" "$run2_tmp"; }
trap cleanup EXIT

python3 "$generator" >/dev/null 2>&1 || python "$generator" >/dev/null 2>&1
status=$?
if [ "$status" -ne 0 ]; then
  echo "FAIL     generator-exits-zero (exit $status)"
  failed=1
else
  echo "ok       generator-exits-zero"
fi

if [ ! -f "$out_dir/custo.svg" ] || [ ! -f "$out_dir/ganho.svg" ]; then
  echo "FAIL     generator-produces-both-files"
  failed=1
else
  echo "ok       generator-produces-both-files"
fi

cp "$out_dir/custo.svg" "$run1_tmp/custo.svg" 2>/dev/null
cp "$out_dir/ganho.svg" "$run1_tmp/ganho.svg" 2>/dev/null

python3 "$generator" >/dev/null 2>&1 || python "$generator" >/dev/null 2>&1

if cmp -s "$run1_tmp/custo.svg" "$out_dir/custo.svg" && cmp -s "$run1_tmp/ganho.svg" "$out_dir/ganho.svg"; then
  echo "ok       saida-deterministica-entre-execucoes"
else
  echo "FAIL     saida-deterministica-entre-execucoes (saida mudou sem mudar evals/benchmarks/)"
  failed=1
fi

# "A " (staged, new file -- first commit of the generated output) is fine.
# "M"/"??" means the working tree now differs from what git already knows
# about (modified-but-not-restaged, or untracked) -- that is drift.
status_out="$(git status --porcelain -- docs/benchmarks/custo.svg docs/benchmarks/ganho.svg 2>/dev/null | grep -Ev '^A  ')"
if [ -z "$status_out" ]; then
  echo "ok       saida-comitada-esta-atualizada"
else
  echo "FAIL     saida-comitada-esta-atualizada (docs/benchmarks/*.svg comitado difere do gerado agora -- rode o script e commit o resultado)"
  printf '%s\n' "$status_out"
  failed=1
fi

exit "$failed"
