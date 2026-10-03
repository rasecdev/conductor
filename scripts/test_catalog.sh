#!/usr/bin/env bash
# Deterministic test of scripts/catalog.sh: confirms it degrades cleanly
# (exit 0, no crash) on a fresh install -- no ~/.claude/skills, no
# ~/.claude/plugins/installed_plugins.json, no project-scoped .claude/skills,
# no local pipeline registry. Does not assert any specific skill listing
# (that's always machine-dependent) -- only that absence of every optional
# source is handled, not treated as an error.
#
# Usage: scripts/test_catalog.sh

set -uo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
catalog="$repo_root/scripts/catalog.sh"

fresh_home="$(mktemp -d)"
work_dir="$(mktemp -d)"
# shellcheck disable=SC2317 # invoked indirectly via trap, not unreachable
cleanup() { rm -rf "$fresh_home" "$work_dir"; }
trap cleanup EXIT

failed=0

# Caso 1: HOME sem ~/.claude/skills nem ~/.claude/plugins -- nada pra listar,
# mas nao pode quebrar.
out=$(cd "$work_dir" && HOME="$fresh_home" CONDUCTOR_PIPELINE_REGISTRY=/nonexistent/registry.json bash "$catalog" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
  echo "FAIL     fresh-install-sem-plugins (exit $status)"
  printf '%s\n' "$out"
  failed=1
elif [ -n "$out" ]; then
  echo "FAIL     fresh-install-sem-plugins (esperava saida vazia, obteve algo)"
  printf '%s\n' "$out"
  failed=1
else
  echo "ok       fresh-install-sem-plugins"
fi

# Caso 2: installed_plugins.json existe mas vazio (registro presente, sem
# nenhum plugin instalado) -- grep sem match tambem nao pode quebrar com set
# -e no caller.
mkdir -p "$fresh_home/.claude/plugins"
echo '{}' >"$fresh_home/.claude/plugins/installed_plugins.json"
out=$(cd "$work_dir" && HOME="$fresh_home" CONDUCTOR_PIPELINE_REGISTRY=/nonexistent/registry.json bash "$catalog" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
  echo "FAIL     plugins-registry-vazio (exit $status)"
  printf '%s\n' "$out"
  failed=1
else
  echo "ok       plugins-registry-vazio"
fi

exit "$failed"
