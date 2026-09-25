#!/usr/bin/env bash
# Valida o plano de QA: toda seção "## Casos de teste" precisa ter ao menos um item.
set -u
file="docs/qa/plano.md"
if ! awk '/^## Casos de teste/{f=1;next} /^## /{f=0} f && /^- /{found=1} END{exit !found}' "$file"; then
  echo "FALHOU: $file — seção 'Casos de teste' está vazia" >&2
  exit 1
fi
echo "OK: $file"
