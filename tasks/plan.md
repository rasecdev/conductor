<!-- markdownlint-disable-file MD025 -- um H1 por rodada é a estrutura deste plano -->

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

- [x] [Tarefa 1: Generalizar Passo 6 para registro e checagem de qualquer artefato vivo](https://github.com/rasecdev/conductor/issues/10)
- [x] [Tarefa 2: Adicionar caso em evals/evals.json cobrindo artefato não-board desatualizado](https://github.com/rasecdev/conductor/issues/11)

### Checkpoint: Fase 1

- [x] SKILL.md cobre desatualização de qualquer artefato vivo registrado, não só board
- [x] evals/evals.json cobre pelo menos um cenário de artefato não-board desatualizado — resultado em `evals/results-v1.2-v1.3.md`

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

- [x] [Tarefa 1: Estender Passo 1 com detecção de tipo de projeto (UI vs headless)](https://github.com/rasecdev/conductor/issues/13)
- [x] [Tarefa 2: Adicionar caso em evals/evals.json cobrindo projeto headless sem recomendação de UI](https://github.com/rasecdev/conductor/issues/14)

### Checkpoint: Fase 1

- [x] Passo 1 documenta sinais de tipo de projeto e como filtram recomendação de artefato
- [x] evals/evals.json cobre o cenário de projeto headless não recebendo recomendação de UI — resultado em `evals/results-v1.2-v1.3.md`

# Rodada v1.4 — Reconhecer e verificar gates de qualidade da pipeline

Spec: [issue #24](https://github.com/rasecdev/conductor/issues/24) (refeita via `/to-spec`, substitui a #15). Decidido
em conversa com o usuário, na linha da definição operacional do `ROADMAP.md`
("o conductor conduz o usuário a criar, manter e melhorar sua pipeline —
nunca por conta própria"): reconhecer se cada etapa/artefato tem um gate de
qualidade esperado (lint, teste, conformidade de arquitetura, validação de
artefato visual), verificar seu estado real, e sinalizar lacuna — sem nunca
criar/configurar o gate sozinho. A lógica de "qual gate é esperado onde" é
referência fixa da skill (`references/gate-types.md`), não algo por projeto.

Tarefas geradas pela `planning-and-task-breakdown` em fatias verticais (cada
uma entrega um comportamento completo: referência + `SKILL.md` + fixture +
caso de eval), com critério de aceite amarrado às user stories da #24.
Tarefas no GitHub Issues; aqui só o índice.

## Task List

### Fase 1: Fluxo principal de gate

- [x] [Tarefa 1: Detectar gate esperado ausente, com fonte e confiança](https://github.com/rasecdev/conductor/issues/16) — stories 1–7, 11–15, 17, 21
- [x] [Tarefa 2: Verificar estado real do gate e avisar gate vermelho antes de avançar](https://github.com/rasecdev/conductor/issues/17) — stories 8, 18–20

### Checkpoint: Fase 1

- [x] Casos (a)–(d) passam no formato oficial, sem regressão frente ao baseline
- [x] Revisão com o usuário antes de seguir

### Fase 2: Acionamento e fechamento

- [x] [Tarefa 3: Sinalizar gate não acionado e só oferecer setup inicial](https://github.com/rasecdev/conductor/issues/18) — stories 9, 10, 16
- [x] [Tarefa 4a: Fixtures dos casos de eval que dependem de estado real (0, 1, 3)](https://github.com/rasecdev/conductor/issues/40)
- [x] [Tarefa 4b: Fixtures dos casos de eval descritivos (4, 5, 6, 8, 9)](https://github.com/rasecdev/conductor/issues/41)
- [ ] [Tarefa 4: Regressão completa e fechamento da rodada v1.4](https://github.com/rasecdev/conductor/issues/26) — cobertura de todas as stories
- [ ] [Tarefa 5: Documentar a avaliação da skill](https://github.com/rasecdev/conductor/issues/42)

Replanejado pela `planning-and-task-breakdown` (2026-09-25): os casos antigos
citavam projetos em `C:\Projetos\...` inexistentes; viraram fixtures (T4a,
T4b) antes da regressão. Fora da rodada, **provisória**:
[Tarefa 6: comparar com o ask-matt](https://github.com/rasecdev/conductor/issues/43),
só quando a skill estiver pronta.

### Checkpoint: Fase 2

- [ ] Suíte completa (10 casos antigos, agora com fixtures, + 6 novos) sem regressão
- [ ] Requisitos de #24 conferidos contra o `SKILL.md`; toda story com caso ou justificativa
- [ ] `SPEC.md` incorpora o delta da v1.4

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Fixture dentro deste repo herda o `git log` do conductor e contamina o sinal de maturidade do Passo 1 | Alto | Copiar a fixture para diretório temporário com `git init` próprio antes de cada run (Tarefa 1) |
| Caso (c) "gate só no CI" sem CI real na fixture | Médio | Decidido: testar o comportamento degradado — sem acesso, reporta "não verificado" |
| Campo `files` do schema do `skill-creator` pensado para arquivo, não diretório | Baixo | Listar os arquivos da fixture um a um |

## Open Questions

- A `planning-and-task-breakdown` referencia uma Definition of Done (`references/definition-of-done.md`) que não existe nesta instalação. DoD efetiva deste repo: a do `CLAUDE.md` (caso de eval para comportamento novo, conferência requisito por requisito, incorporação ao `SPEC.md`).

# Rodada v1.5 — Gates de transição declarativos

Spec: [issue #25](https://github.com/rasecdev/conductor/issues/25) (refeita via `/to-spec`, substitui a #19). Decidido
em conversa com o usuário: além dos gates de qualidade (v1.4, do projeto), o
conductor tem portões próprios de transição — quando uma skill/fluxo do
pipeline pode começar, e quando um evento (ex: mudança de arquitetura com
fluxograma registrado) exige revisitar um artefato. Hoje implícitos em prosa
nos Passos 2/4/6; esta rodada os torna uma tabela declarativa (uma linha por
gatilho → consequência) com sinais mecânicos avaliados por script. O conductor
avisa e deixa de recomendar avanço; nunca bloqueia mecanicamente (hook/CI é
decisão do usuário). Inclui gates de rastreabilidade de SDD: spec sem user
stories não segue para quebra em tarefas; cada story precisa de pelo menos um
caso de verificação antes de a rodada fechar. Depende da v1.4.

## Task List

### Fase 1: Gates de transição

- [ ] [Tarefa 1: Criar references/transition-gates.md](https://github.com/rasecdev/conductor/issues/20)
- [ ] [Tarefa 2: Criar scripts/check-gates.sh](https://github.com/rasecdev/conductor/issues/21)
- [ ] [Tarefa 3: Adicionar passo de gates de transição ao SKILL.md](https://github.com/rasecdev/conductor/issues/22)
- [ ] [Tarefa 4: Adicionar casos em evals/evals.json cobrindo gates de transição](https://github.com/rasecdev/conductor/issues/23)

### Checkpoint: Fase 1

- [ ] references/transition-gates.md cobre todo portão hoje implícito nos Passos 2/4/6
- [ ] scripts/check-gates.sh avalia sinais mecânicos de forma determinística, com teste próprio contra fixtures
- [ ] evals/evals.json cobre aviso por mudança de arquitetura, gatilho com múltiplas consequências, etapa pulada rumo a skill manual, spec sem user stories e story sem caso de verificação
- [ ] Toda story da #25 coberta por caso de eval ou marcada como não verificável com justificativa

# Rodada infra — branch/PR, CI e separação clone × instalação

Sem spec de rodada: mudança de processo do repositório, não de comportamento
da skill. Decidido em conversa com o usuário (2026-09-25), seguindo o
precedente do AutoFinance. Executa **antes** da Tarefa 1 da v1.4, que já roda
no fluxo novo. Tarefas geradas pela `planning-and-task-breakdown`, no GitHub
Issues.

## Task List

- [x] [Infra 1: Criar branch development e clone de trabalho em S:\Trampo\conductor](https://github.com/rasecdev/conductor/issues/28)
- [x] [Infra 2: CI com gitleaks, shellcheck e validação do evals.json](https://github.com/rasecdev/conductor/issues/29)
- [x] [Infra 3: markdownlint no CI](https://github.com/rasecdev/conductor/issues/30)
- [x] [Infra 4: Registrar fluxo branch/PR no CLAUDE.md e primeira promoção para master](https://github.com/rasecdev/conductor/issues/31)

### Checkpoint

- [x] CI verde em `development`, com teste negativo provando que o gate falha quando deve
- [x] `master` promovida e instalação atualizada via `git pull`
- [ ] Revisão com o usuário antes de voltar à v1.4

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| markdownlint acusa muitos erros nos docs atuais | Médio | Isolado na Infra 3, com config justificada |
| Evals rodarem contra a instalação (versão antiga) em vez do clone | Médio | Regra explícita no `CLAUDE.md` (Infra 4) |
