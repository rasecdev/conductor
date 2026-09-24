# Implementation Plan: conductor v1 — itens pendentes pós-spec

Tarefas rastreadas no GitHub Issues do repositório `rasecdev/conductor` (não há `tasks/todo.md` — tracker externo, conforme convenção da skill `planning-and-task-breakdown` para quando o projeto designa um tracker).

## Overview

O `SKILL.md`, `references/pipeline-stages.md` e `scripts/catalog.sh` já estão implementados e validados via eval (`skill-creator`) contra três perfis de projeto: novo do zero, maduro com pipeline formalizado, e legado sem pipeline formalizado (ver spec, [issue #1](https://github.com/rasecdev/conductor/issues/1), seção "Testing Decisions"). Este plano cobre o que ficou pendente na spec ("Further Notes") e lacunas de processo encontradas ao rodar o `to-spec`/`planning-and-task-breakdown` na própria skill: falta validar o Passo 6 (Notion) em execução real, falta convenção formal (`CLAUDE.md`) para o próprio repositório, e o seam de teste foi operado manualmente em vez de usar os scripts oficiais do `skill-creator`.

## Architecture Decisions

- Tracker: GitHub Issues em `rasecdev/conductor` (decisão já tomada ao publicar a spec como issue #1).
- Nenhuma tarefa aqui adiciona funcionalidade nova ao `conductor` — são todas de validação/formalização do que já foi construído, dado que a spec documenta um v1 já implementado.

## Task List

### Fase 1: Formalização de convenção

- [x] [Tarefa 1: CLAUDE.md formalizando a convenção do próprio repositório](https://github.com/rasecdev/conductor/issues/2)

### Checkpoint: Fase 1
- [x] `CLAUDE.md` do repositório existe e reflete a convenção real usada até aqui

### Fase 2: Validação dos gaps conhecidos

- [x] [Tarefa 2: Validar Passo 6 (estrutura Notion) em execução real](https://github.com/rasecdev/conductor/issues/3)
- [ ] [Tarefa 3: Automatizar o seam de teste com os scripts oficiais do skill-creator](https://github.com/rasecdev/conductor/issues/4)
- [ ] [Tarefa 4: Testar de ponta a ponta a escalada de avaliação quantitativa (Passo 5)](https://github.com/rasecdev/conductor/issues/5)

### Checkpoint: Fase 2
- [ ] Passo 6 (Notion) validado em execução real
- [ ] Seam de teste roda pelos scripts oficiais do skill-creator, não manualmente
- [ ] Escalada de avaliação quantitativa (Passo 5) testada ao menos uma vez de ponta a ponta

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Conector Notion não autorizado/carregado na sessão de validação | Médio — bloqueia Tarefa 2 | Skill já degrada avisando (Passo 6); tarefa só pode ser fechada quando a sessão tiver o conector ativo |
| Nenhum caso real ainda gerou ambiguidade suficiente pra escalar avaliação quantitativa (Passo 5) | Baixo — Tarefa 4 pode precisar de cenário sintético | Se não houver caso real disponível, construir um par de skills propositalmente ambíguo só para o teste |

## Open Questions

- ~~Vale rodar `/setup-matt-pocock-skills` formalmente pra esse repo, ou o `CLAUDE.md` próprio (Tarefa 1) já resolve o que falta?~~ Decidido ao executar a Tarefa 1: o `CLAUDE.md` já cobre estrutura, tracker e fluxo de commit reais — sem necessidade de rodar setup adicional.
