# Spec — Exportar notas em PDF

## Problem Statement

Quem usa a NotasAPI não tem como tirar as notas do sistema num formato que dê
para imprimir ou mandar para outra pessoa.

## User Stories

1. Como usuário, quero exportar uma nota em PDF, para imprimir.
2. Como usuário, quero exportar todas as notas de uma etiqueta num PDF só,
   para compartilhar um assunto inteiro.
3. Como usuário, quero que o PDF preserve títulos e listas da nota, para ele
   ficar legível.
4. Como usuário, quero receber erro claro ao exportar uma etiqueta sem notas,
   em vez de um PDF vazio.

## Implementation Decisions

- Endpoint `GET /notas/:id/pdf` e `GET /etiquetas/:nome/pdf`.
- Conversão Markdown → HTML → PDF numa camada de exportação isolada.

## Testing Decisions

- Testes de integração nos dois endpoints, conferindo status e tipo do
  conteúdo; etiqueta vazia retorna 404.
