# SPEC — projeto exemplo

## Problem Statement

Padronizar o nome dos arquivos de configuração do projeto.

## Solution

Renomear os arquivos e documentar a convenção.

## User Stories

1. Como desenvolvedor, quero que todo arquivo de configuração siga o mesmo
   padrão de nome, para não precisar adivinhar onde cada um está.

## Implementation Decisions

- Renomeação feita numa PR só, sem mudança de comportamento.

## Testing Decisions

- Story 1 é decisão estrutural de nomenclatura, não comportamento — não
  verificável por teste/eval (ver stories_nao_verificaveis em evals.json).
