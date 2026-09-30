#!/usr/bin/env bash
# Lists every installed skill's name, description, and whether it requires
# explicit user invocation (disable-model-invocation: true in frontmatter).
#
# Run with no arguments. Reads global skills (~/.claude/skills), if run from
# inside a repo with a .claude/skills directory, project-scoped ones too, and
# skills installed via a marketplace plugin (read from
# ~/.claude/plugins/installed_plugins.json).
#
# Known blind spot: skills that ship bundled with the host/harness itself
# (injected at session start, no stable path under the user's home
# directory) are invisible to this script no matter what. The SKILL.md tells
# the calling model to also cross-check its own session's "available skills"
# listing for those — this script can only cover what's on disk.
#
# Also reads the user's local pipeline registry (never the conductor's own
# repo — see references/transition-gates.md, "Registro local de skills fora
# da tabela embutida"): $CONDUCTOR_PIPELINE_REGISTRY, or
# ~/.claude/conductor-pipeline.json if unset. When a skill has an entry
# there, ESTAGIO/GATE are printed alongside it.
#
# Output: one skill per block, tab-free plain text, easy to read and to parse:
#   NAME: <name>
#   MANUAL: yes|no
#   DESC: <description>
#   ESTAGIO: <stage>       (only when the local registry has an entry)
#   GATE: <gate>           (only when the local registry has an entry)
#   ---

set -euo pipefail

registry="${CONDUCTOR_PIPELINE_REGISTRY:-$HOME/.claude/conductor-pipeline.json}"
declare -A REG_ESTAGIO=() REG_GATE=()
if [ -f "$registry" ]; then
  while IFS= read -r line; do
    [[ "$line" =~ \"skill\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] || continue
    sk="${BASH_REMATCH[1]}"
    [[ "$line" =~ \"estagio\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] && REG_ESTAGIO[$sk]="${BASH_REMATCH[1]}"
    [[ "$line" =~ \"gate\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] && REG_GATE[$sk]="${BASH_REMATCH[1]}"
  done <"$registry"
fi

scan_dir() {
  local base="$1"
  [ -d "$base" ] || return 0
  for skill_md in "$base"/*/SKILL.md; do
    [ -f "$skill_md" ] || continue
    # Extract the YAML frontmatter block (between the first two '---' lines).
    local fm
    fm=$(awk '/^---$/{c++; next} c==1' "$skill_md")
    local name desc manual
    name=$(printf '%s\n' "$fm" | sed -n 's/^name: *//p' | head -1)
    manual=$(printf '%s\n' "$fm" | grep -q '^disable-model-invocation: *true' && echo yes || echo no)
    # description may be a quoted, possibly multi-line-folded scalar; take the
    # first line's content after 'description:' and strip surrounding quotes.
    desc=$(printf '%s\n' "$fm" | sed -n 's/^description: *//p' | head -1 | sed -e 's/^"//' -e 's/"$//')
    [ -n "$name" ] || name=$(basename "$(dirname "$skill_md")")
    echo "NAME: $name"
    echo "MANUAL: $manual"
    echo "DESC: $desc"
    [ -n "${REG_ESTAGIO[$name]+x}" ] && echo "ESTAGIO: ${REG_ESTAGIO[$name]}"
    [ -n "${REG_GATE[$name]+x}" ] && echo "GATE: ${REG_GATE[$name]}"
    echo "---"
  done
}

scan_plugin_registry() {
  # Marketplace-installed plugins keep their skills under
  # <installPath>/skills/, with <installPath> recorded in this registry
  # (one entry per installed version) instead of a fixed, guessable path.
  local registry="$HOME/.claude/plugins/installed_plugins.json"
  [ -f "$registry" ] || return 0
  local path
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    scan_dir "$path/skills"
  done < <(grep -o '"installPath": *"[^"]*"' "$registry" | sed -E 's/.*: *"(.*)"/\1/' | sed 's/[\][\]/\//g')
}

scan_dir "$HOME/.claude/skills"
if [ -d "./.claude/skills" ]; then
  scan_dir "./.claude/skills"
fi
scan_plugin_registry
