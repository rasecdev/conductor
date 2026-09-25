#!/usr/bin/env bash
# Copies an eval fixture (evals/files/<name>) to an isolated temp directory,
# with its own git repo and a single initial commit, and prints the path.
# Extra names are copied as siblings of the main one (each with its own git
# repo), for cases that need a "sibling project" as precedent.
#
# Usage: scripts/prepare_fixture.sh <fixture-name> [<sibling-fixture>...]
#
# Why: a fixture inside this repo would inherit the conductor's git history
# (polluting the maturity signal of Step 1), and fixtures side by side would
# look like "sibling projects" (polluting the cross-project precedent of
# Step 7). Each run gets its own parent directory holding only what it names.

set -euo pipefail

name="${1:?usage: $0 <fixture-name> [<sibling-fixture>...]}"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
parent="$(mktemp -d "${TMPDIR:-/tmp}/conductor-fx-${name}-XXXXXX")"

for fixture in "$@"; do
  src="$repo_root/evals/files/$fixture"
  [ -d "$src" ] || { echo "fixture not found: $src" >&2; exit 1; }
  dest="$parent/$fixture"
  cp -R "$src" "$dest"
  git -C "$dest" init -q
  git -C "$dest" add -A
  git -C "$dest" -c user.name=fixture -c user.email=fixture@example.invalid \
    commit -q -m "estado inicial da fixture $fixture"
done

dest="$parent/$name"
# On Git Bash (Windows), print the native path so any tool can open it.
if command -v cygpath >/dev/null 2>&1; then
  cygpath -w "$dest"
else
  echo "$dest"
fi
