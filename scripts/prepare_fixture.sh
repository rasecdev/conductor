#!/usr/bin/env bash
# Copies an eval fixture (evals/files/<name>) to an isolated temp directory,
# with its own git repo and a single initial commit, and prints the path.
#
# Usage: scripts/prepare_fixture.sh <fixture-name>
#
# Why: a fixture inside this repo would inherit the conductor's git history
# (polluting the maturity signal of Step 1), and fixtures side by side would
# look like "sibling projects" (polluting the cross-project precedent of
# Step 7). Each copy lives alone under its own parent directory.

set -euo pipefail

name="${1:?usage: $0 <fixture-name>}"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo_root/evals/files/$name"
[ -d "$src" ] || { echo "fixture not found: $src" >&2; exit 1; }

parent="$(mktemp -d "${TMPDIR:-/tmp}/conductor-fx-${name}-XXXXXX")"
dest="$parent/$name"
cp -R "$src" "$dest"

git -C "$dest" init -q
git -C "$dest" add -A
git -C "$dest" -c user.name=fixture -c user.email=fixture@example.invalid \
  commit -q -m "estado inicial da fixture $name"

# On Git Bash (Windows), print the native path so any tool can open it.
if command -v cygpath >/dev/null 2>&1; then
  cygpath -w "$dest"
else
  echo "$dest"
fi
