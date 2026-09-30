#!/usr/bin/env bash
# Deterministic test of scripts/check-gates.sh: runs it against fixtures
# prepared by prepare_fixture.sh exactly as for an eval run, and compares the
# output with evals/check-gates-expected/<fixture>.txt.
#
# Usage: scripts/test_check_gates.sh           # compare, exit 1 on any diff
#        scripts/test_check_gates.sh --update  # rewrite the expected outputs
#
# G10 depends on scripts/catalog.sh, which by design reads this machine's own
# installed skills (~/.claude/skills, project scope, plugins) -- not fixture-
# controlled, so its DISPARADO/MOTIVO legitimately vary machine to machine.
# Normalized out before comparing, same principle as test_state.sh
# normalizing dates/branch/bytes. CONDUCTOR_PIPELINE_REGISTRY is pointed at a
# path that never exists, so the local registry of whoever runs this test
# never leaks into the comparison either.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
expected_dir="$repo_root/evals/check-gates-expected"
update=no
[ "${1:-}" = "--update" ] && update=yes
mkdir -p "$expected_dir"

normalize() {
  sed -e '/^ID: G10$/,/^---$/{ s/^DISPARADO:.*/DISPARADO: <depende da maquina>/; s/^MOTIVO:.*/MOTIVO: <depende da maquina>/ }'
}

run_once() { # $1 = fixture name -> prints normalized output, cleans up
  local fixture actual
  fixture="$(bash "$repo_root/scripts/prepare_fixture.sh" "$1")"
  actual="$(cd "$fixture" && CONDUCTOR_PIPELINE_REGISTRY=/nonexistent/conductor-pipeline.json \
    bash "$repo_root/scripts/check-gates.sh")"
  rm -rf "$(dirname "$fixture")"
  printf '%s\n' "$actual" | normalize
}

# Mechanical signal disparado / nao disparado (G8), binding ausente -> nao
# avaliado (G7, always -- no fixture has a structured artifact binding).
cases=(spec-sem-stories spec-com-stories pasta-vazia)

failed=0
for name in "${cases[@]}"; do
  actual="$(run_once "$name")"
  expected="$expected_dir/$name.txt"
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

# Saida estavel entre execucoes: mesma fixture, duas rodadas, mesmo resultado.
run1="$(run_once pasta-vazia)"
run2="$(run_once pasta-vazia)"
if [ "$run1" = "$run2" ]; then
  echo "ok       saida-estavel-entre-execucoes"
else
  echo "FAIL     saida-estavel-entre-execucoes"
  diff -u <(printf '%s\n' "$run1") <(printf '%s\n' "$run2") || true
  failed=1
fi

exit "$failed"
