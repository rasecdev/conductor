#!/usr/bin/env bash
# Collects the mechanical facts of the target project (the conductor's
# "sinais mecânicos") and prints them as one JSON object, so the skill reads a
# short map instead of opening files one by one to discover them.
#
# Run with no arguments, from the target project's root. Read-only: never runs
# the project's own commands and never writes anything. Every source that can't
# be read (no git, no gh, no remote) becomes {"indisponivel": "<motivo>"} and
# the script still exits 0.
#
# The output is a map of what exists and where, never a conclusion: a plan
# file existing does not mean the stage is done — the skill still reads it.
#
# Groups: convencao, maturidade, tipo_projeto, pipeline, git, gates.
#
# Helpers write to R instead of printing, and file contents are matched in
# bash, to keep subprocesses few: on Git Bash (Windows) every fork is slow and
# can fail transiently.

set -uo pipefail

# --- helpers ----------------------------------------------------------------

js() { # R = JSON string literal of $1
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\t'/\\t}
  s=${s//$'\r'/}
  s=${s//$'\n'/\\n}
  R="\"$s\""
}

arr() { # R = JSON array of the arguments as strings
  local out="" x
  for x in "$@"; do js "$x"; out+="${out:+, }$R"; done
  R="[$out]"
}

unavailable() { js "$1"; R="{\"indisponivel\": $R}"; }

num() { # R = $1 if it is a non-negative integer, else null
  if [[ "$1" =~ ^[0-9]+$ ]]; then R="$1"; else R=null; fi
}

declare -A bytes=()
all_files=()
# Files up to depth 3 with their size, skipping dependency/build dirs.
while IFS=$'\t' read -r n f; do
  [ -n "$f" ] || continue
  bytes[$f]=$n
  all_files+=("$f")
done < <(find . -maxdepth 3 \( -name .git -o -name node_modules -o -name bin -o -name obj \
  -o -name dist -o -name build -o -name .venv -o -name vendor \) -prune \
  -o -type f -printf '%s\t%P\n' 2>/dev/null | LC_ALL=C sort -t $'\t' -k2)

files_json() { # R = [{"caminho": ..., "bytes": N}] for each listed file argument
  local out="" f
  for f in "$@"; do
    [ -n "${bytes[$f]+x}" ] || continue
    js "$f"
    out+="${out:+, }{\"caminho\": $R, \"bytes\": ${bytes[$f]}}"
  done
  R="[$out]"
}

has_git=no
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && has_git=yes

# --- convencao --------------------------------------------------------------

conv=()
for f in "${all_files[@]}"; do
  case "$f" in
    CLAUDE.md | AGENTS.md | .claude/CLAUDE.md | .cursorrules | .github/copilot-instructions.md | \
      .windsurfrules | .cursor/rules/*.mdc | .windsurf/rules/*) conv+=("$f") ;;
  esac
done

# --- maturidade -------------------------------------------------------------

manifests=()
code_count=0
for f in "${all_files[@]}"; do
  case "${f##*/}" in
    package.json | pubspec.yaml | pyproject.toml | requirements.txt | go.mod | Cargo.toml | \
      pom.xml | build.gradle | build.gradle.kts | Gemfile | composer.json | *.sln | *.csproj)
      manifests+=("$f") ;;
  esac
  case "$f" in
    *.ts | *.tsx | *.js | *.jsx | *.mjs | *.py | *.cs | *.java | *.kt | *.go | *.rs | *.rb | \
      *.php | *.dart | *.swift | *.vue | *.svelte | *.c | *.cpp | *.h | *.sh)
      code_count=$((code_count + 1)) ;;
  esac
done

if [ "$has_git" = yes ] && git rev-parse -q --verify HEAD >/dev/null 2>&1; then
  # One git call: commit count and first/last commit dates.
  mapfile -t dates < <(git log --format=%cs 2>/dev/null)
  num "${#dates[@]}"; commits=$R
  js "${dates[${#dates[@]}-1]:-}"; first=$R
  js "${dates[0]:-}"; last=$R
  history="{\"commits\": $commits, \"primeiro_commit\": $first, \"ultimo_commit\": $last}"
elif [ "$has_git" = yes ]; then
  history='{"commits": 0}'
else
  unavailable "sem repositório git"; history=$R
fi

# --- tipo_projeto -----------------------------------------------------------
# Only signals; classifying a mixed/ambiguous project is the model's call.

ui=()
headless=()
for f in "${manifests[@]}"; do
  content=$(<"$f")
  case "${f##*/}" in
    package.json)
      for dep in react react-dom vue svelte @angular/core next nuxt solid-js react-native expo electron vite; do
        [[ "$content" == *"\"$dep\":"* || "$content" == *"\"$dep\" :"* ]] && ui+=("$f: $dep")
      done
      for dep in express fastify koa @nestjs/core hono telegraf grammy node-telegram-bot-api; do
        [[ "$content" == *"\"$dep\":"* || "$content" == *"\"$dep\" :"* ]] && headless+=("$f: $dep")
      done
      ;;
    pubspec.yaml) ui+=("$f: flutter") ;;
    *.csproj)
      [[ "$content" == *Microsoft.NET.Sdk.Web* ]] && headless+=("$f: Microsoft.NET.Sdk.Web")
      [[ "$content" == *UseWindowsForms* || "$content" == *UseWPF* || "$content" == *Microsoft.Maui* ]] &&
        ui+=("$f: desktop/mobile .NET")
      ;;
  esac
done
for d in android ios; do [ -d "$d" ] && ui+=("$d/"); done

# --- pipeline ---------------------------------------------------------------

spec_files=()
plan_files=()
adr_count=0
for f in "${all_files[@]}"; do
  case "$f" in
    PRODUCT.md | TECH.md | SPEC.md | PRD.md | docs/spec*.md | specs/*.md) spec_files+=("$f") ;;
    tasks/plan.md | tasks/todo.md | tasks/issues/*.md | PLANO.md | PROGRESSO.md | ROADMAP.md | \
      development_plan.md | TODO.md) plan_files+=("$f") ;;
    docs/adr/*.md | docs/decisions/*.md | adr/*.md) adr_count=$((adr_count + 1)) ;;
  esac
done

tasks="" # open/checked markdown checkboxes of the plan files that have any
open_re='^[[:space:]]*[-*] \[ \]'
done_re='^[[:space:]]*[-*] \[[xX]\]'
for f in "${plan_files[@]}"; do
  open=0 marked=0
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ $open_re ]]; then open=$((open + 1))
    elif [[ "$line" =~ $done_re ]]; then marked=$((marked + 1)); fi
  done <"$f"
  [ $((open + marked)) -gt 0 ] || continue
  js "$f"
  tasks+="${tasks:+, }{\"caminho\": $R, \"abertas\": $open, \"marcadas\": $marked}"
done

# --- git --------------------------------------------------------------------

if [ "$has_git" = yes ]; then
  branch=$(git symbolic-ref --short -q HEAD || echo "(detached)")
  mapfile -t branches < <(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)
  if [ -z "$(git remote 2>/dev/null)" ]; then
    unavailable "sem remote"
  elif ! command -v gh >/dev/null 2>&1; then
    unavailable "gh não instalado"
  elif ! pr_list=$(gh pr list --state open --json number,title,headRefName,baseRefName \
    --template '{{range .}}#{{.number}} {{.headRefName}} -> {{.baseRefName}}: {{.title}}{{"\n"}}{{end}}' 2>/dev/null); then
    unavailable "gh sem acesso ao repositório"
  else
    mapfile -t pr_lines < <(printf '%s' "$pr_list")
    arr "${pr_lines[@]}"
  fi
  prs=$R
  js "$branch"; b=$R
  arr "${branches[@]}"
  git_json="{\"branch_atual\": $b, \"branches_locais\": $R, \"prs_abertos\": $prs}"
else
  unavailable "sem repositório git"; git_json=$R
fi

# --- gates ------------------------------------------------------------------
# Tools come from the table in references/gate-types.md (single source): each
# backticked name in the "Ferramenta" column, plus the npx command in the same
# position of the "Comando típico" column as an alias of it.
# A gate "exists" only where something runs it: project scripts, CI or hooks;
# a dependency nobody calls does not count (gate-types.md).

gate_ref="$(dirname "$0")/../references/gate-types.md"
tools=()
declare -A alias_of=()
if [ -f "$gate_ref" ]; then
  # shellcheck disable=SC2016 # literal backticks, not command substitution
  tick_re='`([^`]+)`'
  while IFS= read -r line; do
    [[ "$line" == "| "* ]] || continue  # header and separator have no backticks
    IFS='|' read -r _ _ _ col_tool col_cmd _ <<<"$line"
    names=() cmds=()
    while [[ "$col_tool" =~ $tick_re ]]; do
      names+=("${BASH_REMATCH[1]}"); col_tool=${col_tool#*"${BASH_REMATCH[0]}"}
    done
    while [[ "$col_cmd" =~ $tick_re ]]; do
      c=${BASH_REMATCH[1]#npx }; c=${c%% *}; cmds+=("${c##*/}"); col_cmd=${col_cmd#*"${BASH_REMATCH[0]}"}
    done
    for i in "${!names[@]}"; do
      tools+=("${names[$i]}")
      alias_of[${names[$i]}]=${cmds[$i]:-${names[$i]}}
    done
  done <"$gate_ref"
fi

mentions() { # does text $1 call tool $2 (or its alias)?
  local n re
  for n in "$2" "${alias_of[$2]:-$2}"; do
    re="(^|[^A-Za-z0-9_.-])${n//./\\.}([^A-Za-z0-9_]|$)"
    [[ "$1" =~ $re ]] && return 0
  done
  return 1
}

# gate_scan <dir>: sets G_WHERE[tool] ("; "-joined places), G_POINTS_* lists.
gate_scan() {
  local dir="$1" f text name cmd tool kind label scripts_block
  G_WHERE=()
  G_POINTS_SCRIPTS=() G_POINTS_CI=() G_POINTS_HOOKS=()
  local -A pkg_scripts=()
  local -a srcs=()
  shopt -s nullglob
  for f in "$dir"/package.json "$dir"/Makefile "$dir"/justfile "$dir"/scripts/*.sh; do
    [ -f "$f" ] || continue
    srcs+=("scripts|$f"); G_POINTS_SCRIPTS+=("${f#"$dir"/}")
  done
  for f in "$dir"/.github/workflows/*.yml "$dir"/.github/workflows/*.yaml "$dir"/.gitlab-ci.yml \
    "$dir"/azure-pipelines.yml "$dir"/bitbucket-pipelines.yml; do
    [ -f "$f" ] || continue
    srcs+=("ci|$f"); G_POINTS_CI+=("${f#"$dir"/}")
  done
  for f in "$dir"/.husky/* "$dir"/.pre-commit-config.yaml "$dir"/lefthook.yml \
    "$dir"/.git/hooks/pre-commit "$dir"/.git/hooks/pre-push; do
    [ -f "$f" ] || continue
    srcs+=("hook|$f"); G_POINTS_HOOKS+=("${f#"$dir"/}")
  done
  shopt -u nullglob

  # package.json: only the "scripts" block counts (not devDependencies).
  if [ -f "$dir/package.json" ]; then
    text=$(<"$dir/package.json")
    scripts_block=""
    if [[ "$text" == *'"scripts"'* ]]; then
      scripts_block=${text#*\"scripts\"}; scripts_block=${scripts_block#*\{}; scripts_block=${scripts_block%%\}*}
    fi
    local pair_re='"([^"]+)"[[:space:]]*:[[:space:]]*"([^"]*)"'
    while [[ "$scripts_block" =~ $pair_re ]]; do
      pkg_scripts[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
      scripts_block=${scripts_block#*"${BASH_REMATCH[0]}"}
    done
  fi

  local -a script_names=()
  [ ${#pkg_scripts[@]} -eq 0 ] || mapfile -t script_names < <(printf '%s
' "${!pkg_scripts[@]}" | LC_ALL=C sort)
  for tool in "${tools[@]}"; do
    local where=""
    for name in "${script_names[@]}"; do
      mentions "${pkg_scripts[$name]}" "$tool" && where+="${where:+; }package.json scripts.$name"
    done
    for f in "${srcs[@]}"; do
      kind=${f%%|*}; f=${f#*|}
      [ "${f##*/}" = package.json ] && continue
      text=$(<"$f"); label="$kind: ${f#"$dir"/}"
      if mentions "$text" "$tool"; then
        where+="${where:+; }$label"
      elif [ "$kind" != scripts ]; then
        # Indirect: CI/hook runs a package.json script that calls the tool.
        for name in "${script_names[@]}"; do
          cmd=${pkg_scripts[$name]}
          mentions "$cmd" "$tool" || continue
          [[ "$text" == *"run $name"* || "$text" == *"yarn $name"* || "$text" == *"pnpm $name"* ]] &&
            where+="${where:+; }$label (via scripts.$name)"
        done
      fi
    done
    [ -n "$where" ] && G_WHERE[$tool]=$where
  done
}

declare -A G_WHERE=()
gate_scan "."
configured="" absent=()
for tool in "${tools[@]}"; do
  if [ -n "${G_WHERE[$tool]+x}" ]; then
    js "$tool"; t=$R; js "${G_WHERE[$tool]}"
    configured+="${configured:+, }{\"ferramenta\": $t, \"configurado_em\": $R}"
  else
    absent+=("$tool")
  fi
done
arr "${absent[@]}"; o_absent=$R
arr "${G_POINTS_SCRIPTS[@]}"; p_s=$R
arr "${G_POINTS_CI[@]}"; p_c=$R
arr "${G_POINTS_HOOKS[@]}"; p_h=$R

if [ ${#tools[@]} -eq 0 ]; then
  unavailable "referência de tipos de gate não encontrada"; o_tools=$R
else
  o_tools="{\"configurados\": [$configured], \"ausentes\": $o_absent}"
fi

if [ "$has_git" != yes ]; then
  unavailable "sem repositório git"
elif [ -z "$(git remote 2>/dev/null)" ]; then
  unavailable "sem remote"
elif ! command -v gh >/dev/null 2>&1; then
  unavailable "gh não instalado"
elif ! run=$(gh run list --branch "$branch" --limit 1 --json workflowName,status,conclusion,createdAt \
  --template '{{range .}}{{.workflowName}}|{{.status}}|{{.conclusion}}|{{.createdAt}}{{end}}' 2>/dev/null); then
  unavailable "gh sem acesso ao CI"
elif [ -z "$run" ]; then
  unavailable "nenhuma run de CI na branch $branch"
else
  IFS='|' read -r w s c d <<<"$run"
  js "$w"; w=$R; js "$s"; s=$R; js "$c"; c=$R; js "$d"; d=$R
  R="{\"workflow\": $w, \"status\": $s, \"conclusao\": $c, \"data\": $d}"
fi
o_ci=$R

# Sibling projects (same parent dir): which gate tools each one configures.
siblings=""
here=$(pwd -P)
for sib in ../*/; do
  sib=${sib%/}
  [ "$(cd "$sib" 2>/dev/null && pwd -P)" = "$here" ] && continue
  [ -d "$sib/.git" ] || [ -f "$sib/package.json" ] || continue
  gate_scan "$sib"
  [ ${#G_WHERE[@]} -gt 0 ] || continue
  sib_tools=()
  for tool in "${tools[@]}"; do [ -n "${G_WHERE[$tool]+x}" ] && sib_tools+=("$tool: ${G_WHERE[$tool]}"); done
  js "${sib##*/}"; n=$R; arr "${sib_tools[@]}"
  siblings+="${siblings:+, }{\"projeto\": $n, \"gates\": $R}"
done

gates_json="{\"ferramentas\": $o_tools, \"pontos_de_execucao\": {\"scripts\": $p_s, \"ci\": $p_c, \"hooks\": $p_h}, \"ultima_run_ci\": $o_ci, \"irmaos\": [$siblings]}"

# --- output -----------------------------------------------------------------

files_json "${conv[@]}"; o_conv=$R
arr "${manifests[@]}"; o_man=$R
arr "${ui[@]}"; o_ui=$R
arr "${headless[@]}"; o_head=$R
files_json "${spec_files[@]}"; o_spec=$R
files_json "${plan_files[@]}"; o_plan=$R
files_json CONTEXT.md; o_glos=$R

cat <<EOF
{
  "convencao": $o_conv,
  "maturidade": {"historico": $history, "manifestos": $o_man, "arquivos_de_codigo": $code_count},
  "tipo_projeto": {"sinais_ui": $o_ui, "sinais_headless": $o_head},
  "pipeline": {"spec": $o_spec, "planejamento": $o_plan, "tarefas": [$tasks], "glossario": $o_glos, "adrs": $adr_count},
  "git": $git_json,
  "gates": $gates_json
}
EOF
