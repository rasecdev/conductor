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
- [x] [Tarefa 3: Automatizar o seam de teste com os scripts oficiais do skill-creator](https://github.com/rasecdev/conductor/issues/4)
- [x] [Tarefa 4: Testar de ponta a ponta a escalada de avaliação quantitativa (Passo 5)](https://github.com/rasecdev/conductor/issues/5)

### Checkpoint: Fase 2
- [x] Passo 6 (Notion) validado em execução real
- [x] Seam de teste roda pelos scripts oficiais do skill-creator, não manualmente
- [x] Escalada de avaliação quantitativa (Passo 5) testada ao menos uma vez de ponta a ponta

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Conector Notion não autorizado/carregado na sessão de validação | Médio — bloqueia Tarefa 2 | Skill já degrada avisando (Passo 6); tarefa só pode ser fechada quando a sessão tiver o conector ativo — **resolvido**, conector estava ativo na sessão de validação |
| Nenhum caso real ainda gerou ambiguidade suficiente pra escalar avaliação quantitativa (Passo 5) | Baixo — Tarefa 4 pode precisar de cenário sintético | Se não houver caso real disponível, construir um par de skills propositalmente ambíguo só para o teste — **usado**: par sintético `spec-drafting`/`feature-spec-writer` |

## Open Questions

- ~~Vale rodar `/setup-matt-pocock-skills` formalmente pra esse repo, ou o `CLAUDE.md` próprio (Tarefa 1) já resolve o que falta?~~ Decidido ao executar a Tarefa 1: o `CLAUDE.md` já cobre estrutura, tracker e fluxo de commit reais — sem necessidade de rodar setup adicional.

# Rodada v1.1 — Passo 6 agnóstico de ferramenta

Spec: [issue #6](https://github.com/rasecdev/conductor/issues/6). Decidido em
conversa com o usuário: o Passo 6 (hoje hardcoded pra Notion, com justificativa
explícita contra Miro) deve detectar qual MCP de board/documentação está
disponível na sessão e usar o que houver; se nenhum, perguntar uma vez e, se o
usuário recusar, registrar a recusa persistentemente no projeto alvo (não no
conductor) pra nunca mais perguntar ali.

## Task List

### Fase 1: Passo 6 agnóstico

- [x] [Tarefa 1: Tornar Passo 6 agnóstico de ferramenta (detecção + pergunta única + persistência por projeto)](https://github.com/rasecdev/conductor/issues/7)
- [x] [Tarefa 2: Adicionar caso em evals/evals.json cobrindo o Passo 6 agnóstico](https://github.com/rasecdev/conductor/issues/8)

### Checkpoint: Fase 1
- [x] SKILL.md não cita mais Notion como obrigatório nem descarta Miro
- [x] evals/evals.json cobre os três cenários da spec (ferramenta alternativa detectada, nenhuma disponível, recusa já registrada) — resultado em `evals/results-v1.1-passo6-agnostico.md`

# Rodada v1.2 — Desatualização generalizada pra qualquer artefato vivo

Spec: [issue #9](https://github.com/rasecdev/conductor/issues/9). Decidido em
conversa com o usuário: ao expandir o pipeline com skills de artefato visual
(arquitetura, fluxo de tela, QA/teste), cada uma vira mais uma coisa que pode
ficar desatualizada silenciosamente. A checagem de desatualização que hoje só
existe pro board (Passo 6) precisa generalizar pra qualquer artefato vivo
registrado do projeto.

## Task List

### Fase 1: Generalizar detecção de desatualização

- [ ] [Tarefa 1: Generalizar Passo 6 para registro e checagem de qualquer artefato vivo](https://github.com/rasecdev/conductor/issues/10)
- [ ] [Tarefa 2: Adicionar caso em evals/evals.json cobrindo artefato não-board desatualizado](https://github.com/rasecdev/conductor/issues/11)

### Checkpoint: Fase 1
- [ ] SKILL.md cobre desatualização de qualquer artefato vivo registrado, não só board
- [ ] evals/evals.json cobre pelo menos um cenário de artefato não-board desatualizado

# Rodada v1.3 — Detectar tipo de projeto pra escalar artefatos recomendados

Spec: [issue #12](https://github.com/rasecdev/conductor/issues/12). Decidido
em conversa com o usuário: o conductor vai orientar projetos bem diferentes
entre si (mobile, web, microserviço/backend puro). Nem todo artefato do
pipeline de diagramação (fluxo de tela, design de UI) faz sentido pra todo
projeto — um backend headless não tem tela. Isso é só filtro de
*recomendação*; qual ferramenta usar dentro de um artefato continua sendo
decisão do usuário (mesmo princípio do Passo 6), o conductor não decide isso.

## Task List

### Fase 1: Detecção de tipo de projeto

- [ ] [Tarefa 1: Estender Passo 1 com detecção de tipo de projeto (UI vs headless)](https://github.com/rasecdev/conductor/issues/13)
- [ ] [Tarefa 2: Adicionar caso em evals/evals.json cobrindo projeto headless sem recomendação de UI](https://github.com/rasecdev/conductor/issues/14)

### Checkpoint: Fase 1
- [ ] Passo 1 documenta sinais de tipo de projeto e como filtram recomendação de artefato
- [ ] evals/evals.json cobre o cenário de projeto headless não recebendo recomendação de UI
