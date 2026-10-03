#!/usr/bin/env bash
# Evaluates the mechanical signals of references/transition-gates.md against
# the target project. Run with no arguments from the target project's root,
# same convention as scripts/state.sh and scripts/catalog.sh.
#
# Judgment-typed rows (tipo = julgamento) are never evaluated here -- printed
# as "nao_avaliado" with that reason, for the model to interpret at the
# moment. Mechanical rows without a usable signal in this project (no
# structured artifact binding, gate not re-run, etc.) also print
# "nao_avaliado" with the reason -- never guessed.
#
# Output, one block per gate row, plain text (style of scripts/catalog.sh):
#   ID: <id>
#   TIPO: mecanico|julgamento
#   DISPARADO: sim|nao|nao_avaliado
#   MOTIVO: <short reason / raw data>
#   ---
#
# The gate id/tipo pairs come from references/transition-gates.md itself (the
# table's own repo, next to this script) -- never hardcoded here, so the
# table stays the single source of truth (same principle as gate-types.md in
# scripts/state.sh).

set -uo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
table="$skill_dir/references/transition-gates.md"

DISPARADO=nao_avaliado
MOTIVO=""

# --- G8: spec sem secao de user stories, ou secao vazia ---------------------

G8_SPEC=""
G8_COUNT=""

check_G8() {
  local f found=""
  shopt -s nullglob
  for f in SPEC.md PRD.md docs/spec*.md specs/*.md; do
    [ -f "$f" ] || continue
    found="$f"; break
  done
  shopt -u nullglob
  if [ -z "$found" ]; then
    DISPARADO=nao_avaliado
    MOTIVO="nenhuma spec encontrada (SPEC.md, PRD.md, docs/spec*.md, specs/*.md)"
    return
  fi

  local in_section=0 count=0 line section_level heading_level
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^(#+)[[:space:]]*[Uu]ser[[:space:]][Ss]tories ]]; then
      in_section=1
      section_level=${#BASH_REMATCH[1]}
      continue
    fi
    if [ "$in_section" = 1 ]; then
      if [[ "$line" =~ ^(#+)[[:space:]] ]]; then
        heading_level=${#BASH_REMATCH[1]}
        # Only a heading at the same level or shallower ends the section --
        # subsections (###, ####, ...) are still part of it.
        [ "$heading_level" -le "$section_level" ] && break
        continue
      fi
      [[ "$line" =~ ^[[:space:]]*([0-9]+\.|[-*])[[:space:]] ]] && count=$((count + 1))
    fi
  done <"$found"

  G8_SPEC="$found"
  G8_COUNT="$count"
  if [ "$count" -eq 0 ]; then
    DISPARADO=sim
    MOTIVO="$found sem secao 'User Stories' com itens (0 encontrados)"
  else
    DISPARADO=nao
    MOTIVO="$found: $count user stories encontradas"
  fi
}

# --- G9: story sem caso de verificacao vinculado -----------------------------

check_G9() {
  local f="evals/evals.json"
  if [ -z "$G8_COUNT" ]; then check_G8; fi
  if [ ! -f "$f" ]; then
    DISPARADO=nao_avaliado
    MOTIVO="evals/evals.json nao existe"
    return
  fi
  if ! grep -qE '#[0-9]+:[0-9]+' "$f"; then
    DISPARADO=nao_avaliado
    MOTIVO='nenhum caso usa a convencao de stories ("#<issue>:<no>"); projeto nao registrou essa convencao'
    return
  fi
  if [ -z "$G8_COUNT" ] || [ "$G8_COUNT" -eq 0 ]; then
    DISPARADO=nao_avaliado
    MOTIVO="convencao de stories presente em evals.json, mas o total de stories da spec (G8) nao foi determinado"
    return
  fi

  # A numeracao de user stories em G8_SPEC so mapeia 1:1 com as tags
  # "#<issue>:<no>" de evals.json enquanto existir uma unica rodada ainda nao
  # incorporada. Um "Historico de rodadas" com 2+ linhas (ex: "| v1.6 | ...")
  # significa que G8_SPEC e a spec CONSOLIDADA (numeracao continua atraves de
  # rodadas), enquanto as tags sao escopadas por issue da rodada onde a story
  # nasceu -- os numeros nao tem relacao entre si a partir da segunda rodada.
  # Sem jeito mecanico de saber quais numeros de G8_SPEC pertencem a qual
  # rodada sem ler o tracker (fora do que estes scripts fazem), "nao
  # avaliado" em vez de comparar numeros que nao correspondem (achado via
  # dogfooding, issue #102).
  local hist_rows
  hist_rows=$(grep -cE '^\| v[0-9]' "$G8_SPEC" 2>/dev/null || true)
  if [ -n "$hist_rows" ] && [ "$hist_rows" -ge 2 ]; then
    DISPARADO=nao_avaliado
    MOTIVO="$G8_SPEC consolida $hist_rows rodadas incorporadas (Historico de rodadas); numeracao de stories nao corresponde as tags por issue de evals.json a partir da segunda rodada -- sem spec de rodada isolada pra comparar"
    return
  fi

  local nums missing=() i covered
  nums=$(grep -oE '#[0-9]+:[0-9]+' "$f" | sed -E 's/.*://' | LC_ALL=C sort -nu)
  for ((i = 1; i <= G8_COUNT; i++)); do
    covered=$(printf '%s\n' "$nums" | grep -qx "$i" && echo yes || echo no)
    [ "$covered" = no ] && missing+=("$i")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    DISPARADO=sim
    MOTIVO="stories sem caso vinculado: ${missing[*]}"
  else
    DISPARADO=nao
    MOTIVO="todas as $G8_COUNT stories de $G8_SPEC tem caso vinculado em evals.json"
  fi
}

# --- G10: skill instalada sem estagio/gate conhecido ------------------------
# Conhecido = mencionada nas tabelas embutidas da skill (transition-gates.md,
# gate-types.md -- genericas, compartilhadas por quem instala o conductor) OU
# tem entrada no registro local do usuario (skill pessoal, nunca editada
# nessas tabelas -- ver "Registro local" em transition-gates.md).

check_G10() {
  local catalog names=() missing=() n registry
  catalog=$(bash "$skill_dir/scripts/catalog.sh" 2>/dev/null || true)
  mapfile -t names < <(printf '%s\n' "$catalog" | sed -n 's/^NAME: //p')
  if [ ${#names[@]} -eq 0 ]; then
    DISPARADO=nao_avaliado
    MOTIVO="catalogo vazio ou scripts/catalog.sh indisponivel"
    return
  fi

  registry="${CONDUCTOR_PIPELINE_REGISTRY:-$HOME/.claude/conductor-pipeline.json}"
  declare -A reg=()
  if [ -f "$registry" ]; then
    local line sk
    while IFS= read -r line; do
      [[ "$line" =~ \"skill\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] || continue
      sk="${BASH_REMATCH[1]}"
      [[ "$line" =~ \"estagio\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] && reg[$sk]=1
    done <"$registry"
  fi

  for n in "${names[@]}"; do
    grep -qw -- "$n" "$table" "$skill_dir/references/gate-types.md" 2>/dev/null && continue
    [ -n "${reg[$n]+x}" ] && continue
    missing+=("$n")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    DISPARADO=sim
    MOTIVO="sem estagio conhecido (nem tabela embutida, nem registro local): ${missing[*]}"
  else
    DISPARADO=nao
    MOTIVO="toda skill do catalogo tem estagio conhecido (tabela embutida ou registro local)"
  fi
}

# --- Rows without a usable mechanical signal in this project -----------------
# G1/G2 need to know which stage is being pursued right now (intent), not
# just file existence -- the model reads pipeline/catalog output for that
# (Passo 2). G6 needs re-running the target project's own gate command,
# which this script does not do on its own (Passo 7 already does it with
# context). G7 needs a structured artifact<->code-area binding that no
# target project registers today (Passo 6 keeps that in prose, not a
# machine-readable field) -- this is the deliberate "binding ausente ->
# nao_avaliado" case the table calls for, never guessed.

check_G1() { DISPARADO=nao_avaliado; MOTIVO="requer saber qual etapa esta sendo perseguida agora (Passo 2 le conteudo, nao so existencia de arquivo)"; }
check_G2() { DISPARADO=nao_avaliado; MOTIVO="depende de G1 ter disparado"; }
check_G6() { DISPARADO=nao_avaliado; MOTIVO="requer reexecutar o comando do gate configurado (Passo 7); nao reexecutado aqui para nao rodar comando do projeto alvo sem o contexto do Passo 7"; }
check_G7() { DISPARADO=nao_avaliado; MOTIVO="nenhum binding estruturado entre artefato e area de codigo neste projeto (Passo 6 registra isso em prosa, nao em campo lido por este script)"; }

# --- parse references/transition-gates.md: one "id|tipo" pair per row ------

ids=()
tipos=()
if [ -f "$table" ]; then
  while IFS='|' read -r _ col_id _ _ col_tipo _ _; do
    id=$(printf '%s' "$col_id" | tr -d '[:space:]')
    [[ "$id" =~ ^G[0-9]+$ ]] || continue
    tipo=$(printf '%s' "$col_tipo" | tr -d '[:space:]')
    ids+=("$id")
    tipos+=("$tipo")
  done <"$table"
else
  echo "ID: -" >&2
  echo "references/transition-gates.md nao encontrada em $table" >&2
  exit 1
fi

for i in "${!ids[@]}"; do
  id="${ids[$i]}"
  tipo="${tipos[$i]}"
  DISPARADO=nao_avaliado
  MOTIVO="sinal mecanico sem verificacao implementada neste script"

  if [ "$tipo" = "julgamento" ]; then
    MOTIVO="sinal de julgamento, nao avaliado por script"
  elif declare -F "check_$id" >/dev/null; then
    "check_$id"
  fi

  echo "ID: $id"
  echo "TIPO: $tipo"
  echo "DISPARADO: $DISPARADO"
  echo "MOTIVO: ${MOTIVO//$'\n'/ }"
  echo "---"
done
