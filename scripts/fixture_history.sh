#!/usr/bin/env bash
# Appends a long, realistic-looking git history to the repo in the current
# directory, fast (git fast-import), for eval fixtures that need to look
# mature. Meant to be called from a fixture's .fixture-setup.sh.
#
# Usage: fixture_history.sh <commits> <extension> <start-epoch>
#
# Pattern (so "mine ~3 similar commits" has something real to triangulate):
# every 5th commit is "feat: nova tela <Entidade>", always touching the same
# three layers (Telas/, Services/, Repos/); the others are small fixes that
# touch a single file. The working tree ends matching the new HEAD.

set -euo pipefail
# Byte lengths for fast-import "data" headers (${#var} counts bytes in C locale).
export LC_ALL=C

count="${1:?usage: $0 <commits> <extension> <start-epoch>}"
ext="${2:?usage: $0 <commits> <extension> <start-epoch>}"
epoch="${3:?usage: $0 <commits> <extension> <start-epoch>}"

branch="$(git symbolic-ref HEAD)"
entities=(Cliente Fornecedor Produto Pedido NotaFiscal Estoque Titulo Lancamento Centro Conta)

{
  for ((i = 1; i <= count; i++)); do
    e="${entities[$((i % ${#entities[@]}))]}"
    when=$((epoch + i * 3600))
    echo "commit $branch"
    echo "committer dev <dev@example.invalid> $when +0000"
    if ((i % 5 == 0)); then
      msg="feat: nova tela $e ($i)"
      echo "data ${#msg}"; echo "$msg"
      for layer in Telas Services Repos; do
        body="// $layer/$e — revisão $i"
        echo "M 644 inline src/$layer/$e.$ext"
        echo "data ${#body}"; echo "$body"
      done
    else
      msg="fix: ajusta $e ($i)"
      echo "data ${#msg}"; echo "$msg"
      [ "$i" -eq 1 ] && echo "from ${branch}^0"
      body="// Services/$e — correção $i"
      echo "M 644 inline src/Services/$e.$ext"
      echo "data ${#body}"; echo "$body"
    fi
    echo
  done
} | git fast-import --quiet

git reset -q --hard
