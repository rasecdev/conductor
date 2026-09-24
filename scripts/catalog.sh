#!/usr/bin/env bash
# Lists every installed skill's name, description, and whether it requires
# explicit user invocation (disable-model-invocation: true in frontmatter).
#
# Run with no arguments. Reads global skills (~/.claude/skills) and, if run
# from inside a repo with a .claude/skills directory, project-scoped ones too.
#
# Output: one skill per block, tab-free plain text, easy to read and to parse:
#   NAME: <name>
#   MANUAL: yes|no
#   DESC: <description>
#   ---

set -euo pipefail

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
    echo "---"
  done
}

scan_dir "$HOME/.claude/skills"
if [ -d "./.claude/skills" ]; then
  scan_dir "./.claude/skills"
fi
