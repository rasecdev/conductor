# SPEC — projeto exemplo

Spec viva consolidada, com mais de uma rodada já incorporada.

## Problem Statement

Usuários perdem tempo repetindo uma tarefa manual todo dia.

## Solution

Automatizar a tarefa com um script agendado, com alerta de falha.

## User Stories

1. Como usuário, quero que a tarefa rode sozinha todo dia, para não precisar
   lembrar de fazer manualmente.
2. Como usuário, quero ver um log do que rodou, para confirmar que funcionou.
3. Como usuário, quero receber um alerta se a tarefa falhar, para agir rápido.
4. Como usuário, quero poder pausar a tarefa temporariamente, para não rodar
   durante uma manutenção.
5. Como usuário, quero ver o histórico das últimas execuções, para auditar o
   que já rodou.

## Implementation Decisions

- Script roda via cron.

## Testing Decisions

- Teste manual do log gerado.

## Histórico de rodadas

| Rodada | Spec | O que mudou | Validação |
|---|---|---|---|
| v1.0 | #1 | Tarefa agendada, log e alerta de falha | `evals/evals.json` |
| v1.1 | #2 | Pausa temporária e histórico de execuções | `evals/evals.json` |
