#!/usr/bin/env bash
# Deterministic test of scripts/state.sh (the conductor's script seam): runs it
# against every eval fixture, prepared by prepare_fixture.sh exactly as for an
# eval run, and compares the output with evals/state-expected/<fixture>.json.
#
# Usage: scripts/test_state.sh           # compare, exit 1 on any difference
#        scripts/test_state.sh --update  # rewrite the expected outputs
#
# Normalized before comparing (they vary by run or by machine): dates, the
# default branch name (git config) and file sizes (CRLF checkout on Windows).

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
expected_dir="$repo_root/evals/state-expected"
update=no
[ "${1:-}" = "--update" ] && update=yes
mkdir -p "$expected_dir"

normalize() {
  sed -E -e 's/[0-9]{4}-[0-9]{2}-[0-9]{2}/<data>/g' \
    -e 's/"(master|main)"/"<branch-padrao>"/g' \
    -e 's/"bytes": [0-9]+/"bytes": "<n>"/g'
}

failed=0
for src in "$repo_root"/evals/files/*/; do
  name="$(basename "$src")"
  fixture="$(bash "$repo_root/scripts/prepare_fixture.sh" "$name")"
  actual="$(cd "$fixture" && bash "$repo_root/scripts/state.sh" | normalize)"
  rm -rf "$(dirname "$fixture")"

  expected="$expected_dir/$name.json"
  if [ "$update" = yes ]; then
    printf '%s\n' "$actual" >"$expected"
    echo "updated  $name"
  elif ! diff -u "$expected" <(printf '%s\n' "$actual") >/dev/null 2>&1; then
    echo "FAIL     $name"
    diff -u "$expected" <(printf '%s\n' "$actual") || true
    failed=1
  else
    echo "ok       $name"
  fi
done

exit "$failed"
