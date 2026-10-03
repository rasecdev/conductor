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
- [x] [Tarefa 4: Regressão completa e fechamento da rodada v1.4](https://github.com/rasecdev/conductor/issues/26) — cobertura de todas as stories
- [x] [Tarefa 5: Documentar a avaliação da skill](https://github.com/rasecdev/conductor/issues/42)

Replanejado pela `planning-and-task-breakdown` (2026-09-25): os casos antigos
citavam projetos em `C:\Projetos\...` inexistentes; viraram fixtures (T4a,
T4b) antes da regressão. Fora da rodada, **provisória**:
[Tarefa 6: comparar com o ask-matt](https://github.com/rasecdev/conductor/issues/43),
só quando a skill estiver pronta.

### Checkpoint: Fase 2

- [x] Suíte completa (10 casos antigos, agora com fixtures, + 6 novos) sem regressão
- [x] Requisitos de #24 conferidos contra o `SKILL.md`; toda story com caso ou justificativa
- [x] `SPEC.md` incorpora o delta da v1.4

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Fixture dentro deste repo herda o `git log` do conductor e contamina o sinal de maturidade do Passo 1 | Alto | Copiar a fixture para diretório temporário com `git init` próprio antes de cada run (Tarefa 1) |
| Caso (c) "gate só no CI" sem CI real na fixture | Médio | Decidido: testar o comportamento degradado — sem acesso, reporta "não verificado" |
| Campo `files` do schema do `skill-creator` pensado para arquivo, não diretório | Baixo | Listar os arquivos da fixture um a um |

## Open Questions

- A `planning-and-task-breakdown` referencia uma Definition of Done (`references/definition-of-done.md`) que não existe nesta instalação. DoD efetiva deste repo: a do `CLAUDE.md` (caso de eval para comportamento novo, conferência requisito por requisito, incorporação ao `SPEC.md`).

# Rodada v1.5 — Enxugar o contexto (carga sob demanda + script de estado)

Spec: [issue #50](https://github.com/rasecdev/conductor/issues/50) (via `/to-spec`). Decidido
em conversa com o usuário (2026-09-25), antes de começar o uso real da skill:
uma execução do conductor custa ≈ 20k tokens a mais que sem skill (70,7k × 50,2k
por run na iteração 8 da v1.4). Rodada de refatoração, sem comportamento novo:
o `SKILL.md` fica só com o fluxo que roda sempre, as regras de proteção e os
gatilhos (princípio registrado em `docs/adr/0002-carga-sob-demanda.md`); casos
condicionais viram referências; fatos mecânicos do projeto alvo vêm de um
script de estado com teste determinístico no CI. Passa na frente da antiga
v1.5 (gates de transição), renumerada para v1.6.

Tarefas geradas pela `planning-and-task-breakdown`. O script vem primeiro
(maior risco, e os gatilhos dependem da saída dele). **Toda execução de eval
(smoke ou regressão) só com aprovação explícita do usuário** — custo na casa
de 1M de tokens.

## Task List

### Fase 1: Script de estado

- [x] [Tarefa 1: Script de estado com teste determinístico no CI](https://github.com/rasecdev/conductor/issues/51) — stories 11–14, 17–19, 23
- [x] [Tarefa 2: Script de estado detecta gates e precedente de irmãos](https://github.com/rasecdev/conductor/issues/52) — stories 8–10, 16, 20

### Checkpoint: Fase 1

- [x] Teste do script verde no CI contra as 16 fixtures, com teste negativo provando que falha quando deve
- [x] Revisão com o usuário antes de mexer no `SKILL.md`

### Fase 2: Carga sob demanda

- [x] [Tarefa 3: Passos 1 e 2 usam o script; casos condicionais viram referências com gatilho](https://github.com/rasecdev/conductor/issues/53) — stories 11–15, 26, 27, 29–31
- [x] [Tarefa 4: Passo 7 enxuto, com a parte mecânica vinda do script](https://github.com/rasecdev/conductor/issues/54) — stories 7–10, 16, 28
- [x] [Tarefa 5: Passo 6 vira referência de artefatos vivos com gatilho mecânico](https://github.com/rasecdev/conductor/issues/55) — stories 3–5, 31
- [x] [Tarefa 6: Passo 5 vira referência de avaliação de skill](https://github.com/rasecdev/conductor/issues/56) — story 6
- [x] [Tarefa 7: Remover duplicações, consolidar regras de proteção e caso de eval combinado](https://github.com/rasecdev/conductor/issues/57) — stories 24, 28, 31
- [x] [Tarefa 7b: Detalhe do Passo 7 atrás de gatilho e artefato de QA no sinal de artefatos](https://github.com/rasecdev/conductor/issues/67) — ajustes do smoke test; stories 7–10, 3–5

### Checkpoint: Fase 2

- [x] `SKILL.md` com pelo menos 50% menos caracteres que os 30,3k da v1.4
- [x] Conferência manual de migração em cada PR: nenhuma regra da v1.4 perdida
- [x] Smoke test (≈ 250k tokens: `legacy-project`, `board-tool-precedent-non-notion`, `skill-evaluation`, `quality-gate-failing`) **só se o usuário liberar** — rodado com liberação: 4/4 em todos, iteration-10

### Fase 3: Fechamento

- [x] [Tarefa 8: Regressão, medição e fechamento da rodada v1.5](https://github.com/rasecdev/conductor/issues/58) — stories 1, 2, 21, 22, 25, 32, 33

### Checkpoint: Fase 3

- [x] Nenhum caso piora frente às iterações 8/9 da v1.4; mediana de tokens abaixo de 70,7k
- [x] Requisitos da #50 conferidos contra o `SKILL.md`; toda story com caso, teste do script ou justificativa
- [x] `SPEC.md` incorpora o delta da v1.5

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Gatilho que não dispara: o modelo pula uma referência e responde pior, sem erro visível | Alto | Gatilhos por sinal mecânico da saída do script; cada gatilho coberto por caso de eval; 3 runs no único gatilho por interpretação |
| Modelo trata a saída do script como conclusão ("plano existe = etapa feita") | Alto | Regra explícita no `SKILL.md`; caso `tasks-without-acceptance-criteria` na regressão |
| Script falha numa máquina (Git Bash no Windows, sem `gh`, sem git) | Médio | Campos indisponíveis com motivo; referência de reserva com a leitura manual |
| Referência lida sem a dependência dela (ex: filtro de tipo de projeto) | Médio | Referências autossuficientes ou com ponteiro explícito; caso de eval combinado |
| Custo da validação | Médio | Linha de base reaproveitada, sem baseline sem skill, eval só com aprovação |
| Rodada entra no meio do período de avaliação de uso real (2026-09-25 a 2026-10-09) | Baixo | Anotar no registro de uso real (`conductor-workspace/uso-real.md`, fora deste repositório — ver `CLAUDE.md` → "Dogfooding ≠ uso real") qual versão estava instalada em cada tarefa — mitigação executável desde que o arquivo passou a existir (#77) |

# Rodada v1.6 — Gates de transição declarativos

Spec: [issue #25](https://github.com/rasecdev/conductor/issues/25) (refeita via `/to-spec`, substitui a #19; renumerada de v1.5 para v1.6 em
2026-09-25, quando a v1.5 passou a ser a rodada de enxugar o contexto, #50). Decidido
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

Motivada a entrar em produção agora por um achado do registro de uso real
(2026-09-30, tarefa do fluxograma no Miro, Achado 5): a regra "reconsultar o
`conductor` a cada checkpoint" existe só como prosa desde o PR #82 e não foi
seguida mesmo já estando escrita. Esta rodada é a resposta estrutural — vira
linha de tabela com sinal mecânico do script em vez de depender só do modelo
lembrar. Tarefas replanejadas em fatias verticais pela `planning-and-task-breakdown`
(2026-09-30): as 4 tarefas originais (#20-23) foram criadas antes do formato
enxuto adotado na v1.5 e separavam por camada (referência / script / passo do
SKILL.md / evals) em vez de por comportamento entregue; ficam 6 tarefas agora,
cada uma amarrada às user stories da #25 que cobre.

## Task List

### Fase 1: Fundação (tabela + script determinístico)

- [x] [Tarefa 1: Criar references/transition-gates.md (tabela + linhas mínimas)](https://github.com/rasecdev/conductor/issues/20) — stories 1–4
- [x] [Tarefa 2: Criar scripts/check-gates.sh (sinais mecânicos determinísticos)](https://github.com/rasecdev/conductor/issues/21) — stories 5–7, 10, 11

### Checkpoint: Fase 1

- [x] `references/transition-gates.md` cobre todo portão hoje implícito nos Passos 2/4/6, incluindo "skill recomendada termina" (o gatilho do Achado 5)
- [x] `scripts/check-gates.sh` avalia sinais mecânicos de forma determinística, com teste próprio contra fixtures; binding ausente → "não avaliado"

### Fase 2: Comportamento principal

- [x] [Tarefa 3: Passo novo de gates de transição no SKILL.md (wiring + filtros + portão manual)](https://github.com/rasecdev/conductor/issues/22) — stories 8, 9, 12, 13, 21–23, 25, 26
- [x] [Tarefa 4: Gates de rastreabilidade SDD (spec sem stories; story sem verificação)](https://github.com/rasecdev/conductor/issues/83) — stories 14–18, 20

### Checkpoint: Fase 2

- [x] Passos 2, 4 e 6 do `SKILL.md` referenciam a tabela em vez de duplicar a regra
- [x] Reconsulta a cada checkpoint (Achado 5) passa a gerar aviso mecânico explícito quando o gatilho dispara, não só instrução em prosa
- [x] Gates de rastreabilidade SDD (spec sem stories; story sem verificação) funcionam de ponta a ponta

### Fase 3: Evals e fechamento

- [x] [Tarefa 5: Casos de eval restantes (a, b, c) + campo de stories em evals.json](https://github.com/rasecdev/conductor/issues/23) — stories 19, 24
- [x] [Tarefa 6: Regressão completa e fechamento da rodada v1.6](https://github.com/rasecdev/conductor/issues/84) — fechamento

### Checkpoint: Fase 3

- [x] evals/evals.json cobre aviso por mudança de arquitetura, gatilho com múltiplas consequências, etapa pulada rumo a skill manual, spec sem user stories e story sem caso de verificação
- [x] Toda story da #25 coberta por caso de eval, teste do script, ou marcada como não verificável com justificativa — 13 por caso (3 por retag retroativo: `non-board-artifact-staleness`→#25:10, `quality-gate-failing`→#25:21, `stage-without-any-skill`→#25:25, `headless-project-no-ui-recommendation`→#25:26) + 13 em `stories_nao_verificaveis`
- [x] `SPEC.md` incorpora o delta da v1.6 (seção "Gates de transição" nas User Stories, Implementation/Testing Decisions, linha na tabela de rodadas)

# Rodada infra — branch/PR, CI e separação clone × instalação

Sem spec de rodada: mudança de processo do repositório, não de comportamento
da skill. Decidido em conversa com o usuário (2026-09-25), seguindo o
precedente de outro projeto do usuário. Executa **antes** da Tarefa 1 da v1.4, que já roda
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
- [x] Revisão com o usuário antes de voltar à v1.4 — caixinha esquecida; confirmado retroativamente em 2026-10-02 (v1.4–v1.7 já aconteceram normalmente depois desta rodada, sem bloqueio)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| markdownlint acusa muitos erros nos docs atuais | Médio | Isolado na Infra 3, com config justificada |
| Evals rodarem contra a instalação (versão antiga) em vez do clone | Médio | Regra explícita no `CLAUDE.md` (Infra 4) |

# Rodada uso real — reconsulta, estágio sem skill, catálogo cego a plugin

Sem spec formal via `/to-spec`: decisão explícita do usuário (2026-09-29) de
implementar direto a partir dos três achados da avaliação de uso real em
andamento (`conductor-workspace/uso-real.md`), sem abrir rodada de spec
própria — mesmo tipo de exceção documentado na "Rodada infra" acima.

## Task List

- [x] [Tarefa: catalog.sh não enxerga skills de plugin](https://github.com/rasecdev/conductor/issues/81) — `scripts/catalog.sh` passa a ler `~/.claude/plugins/installed_plugins.json` e varrer `<installPath>/skills` de cada plugin registrado; documentado o limite que resta (skill embutida no host, sem caminho em disco, continua invisível ao script)
- [x] [Tarefa: sem comportamento definido quando o estágio não tem skill instalada](https://github.com/rasecdev/conductor/issues/80) — Passo 3 do `SKILL.md` instrui somar o catálogo do script com a lista de skills da própria sessão antes de concluir que uma skill não existe, e a dizer isso explicitamente (apontando `find-skills` quando instalada) em vez de inventar um passo
- [x] [Tarefa: pipeline extensível por etapa customizada, com gate informado](https://github.com/rasecdev/conductor/issues/79) — nova seção em `references/pipeline-stages.md` ("Registrar um estágio novo sem skill ainda") permite registrar uma etapa fora da tabela fixa, com coluna de gate (sim/não/não verificado)
- [x] Passo 4 do `SKILL.md` ganha "Quando voltar a ser consultado": reconsultar o `conductor` a cada checkpoint (fim da skill recomendada, antes do próximo estágio, PR aberta/mergeada, mudança de foco), não só no início da tarefa

### Checkpoint

- [x] `scripts/catalog.sh` testado com registro de plugin vazio/ausente (fresh install) sem quebrar — `scripts/test_catalog.sh`, job `catalog-script` no CI
- [x] Caso correspondente em `evals/evals.json` pra cada comportamento novo — já cobertos: `catalog-includes-plugin-skills` (id 20), `stage-without-any-skill` (id 18), `checkpoint-reconsult` (id 19)
- [x] CI verde (gitleaks, shellcheck, evals, markdownlint) antes do merge em `development`

# Rodada v1.7 — lembrete de reconsulta via TodoWrite nos gates G3/G4/G5

Spec: [issue #93](https://github.com/rasecdev/conductor/issues/93), publicada
via `/to-spec`. Origem: achados de uso real (`conductor-workspace/uso-real.md`,
Achado 5 e caso de 2026-10-01) — a reconsulta a cada checkpoint (G3/G4/G5) já
foi perdida de vista duas vezes porque o único reforço hoje é aviso em prosa
na resposta daquela consulta, sem nada que persista entre turnos.

## Overview

Quando G3, G4 ou G5 dispara (sinal de julgamento: skill recomendada terminou,
PR aberta/mergeada, foco da tarefa mudou), o `conductor` passa a registrar um
item pendente via `TodoWrite`, além do aviso em prosa já existente (Passo 8).
O item fica visível entre turnos até ser marcado concluído automaticamente na
próxima vez que o Passo 1 rodar de fato. Não é bloqueio (ADR 0001 continua
valendo) e não exige nenhuma configuração do usuário — ao contrário do hook
`PreToolUse` opt-in registrado como plano futuro no `ROADMAP.md`, que só
entra em cena se este mecanismo mais barato não for suficiente.

## Architecture Decisions

- Mudança só em `SKILL.md` (Passo 8) e `references/transition-gates.md`
  (coluna "Consequência" de G3/G4/G5) — nenhum script novo, nenhuma mudança
  em `scripts/check-gates.sh` (G3/G4/G5 continuam "não avaliado (julgamento)"
  por ele; dedup e conclusão automática são instrução de prosa pro modelo, não
  lógica de script).
- Seam de teste: o de eval já existente (`evals/evals.json`), sem seam novo —
  ver spec #93, Testing Decisions.
- Fora de escopo (ver spec #93): hook `PreToolUse`, pipeline em tempo real,
  ajuste de redação do G11, qualquer gate de sinal mecânico.

## Task List

### Fase 1: Comportamento + teste

- [x] [Tarefa 1: Passo 8 chama TodoWrite em G3/G4/G5 (dedup + conclusão automática)](https://github.com/rasecdev/conductor/issues/95)
- [x] [Tarefa 2: Caso de eval cobrindo TodoWrite nos gates G3/G4/G5](https://github.com/rasecdev/conductor/issues/96) — caso `reconsult-registers-todo` (id 24), stories #93:1-4; reaproveita fixture `maduro-com-plano`

### Checkpoint: Fase 1

- [x] `SKILL.md` (Passo 8) e `references/transition-gates.md` documentam o novo comportamento, sem alterar sinal/tipo/ação dos gates
- [x] `evals/evals.json` cobre o cenário (gate dispara → TodoWrite; reconsulta → item concluído), validado por leitura do schema (`scripts/validate_evals.py` aceita campos extra; Python indisponível no ambiente local)
- [x] Suíte de eval **não executada** nesta rodada — fica pro próximo lote acumulado, com aprovação explícita
- [x] CI verde (gitleaks, shellcheck, evals, markdownlint, state-script, check-gates-script) antes do merge em `development`

### Fase 2: Fechamento da rodada

- [x] Conferir as 12 stories da #93 contra `evals/evals.json`: 5 por caso de eval (`reconsult-registers-todo`, id 24, agora com `#93:10` também), 7 por `stories_nao_verificaveis`
- [x] Incorporar o delta ao `SPEC.md` (User Stories 52–60 "Lembrete de reconsulta via TodoWrite", Implementation Decisions, linha na tabela de rodadas, "Estado consolidado" → v1.7)

### Checkpoint: Fase 2

- [x] Toda story da #93 coberta por caso de eval ou marcada como não verificável com justificativa
- [x] `SPEC.md` incorpora o delta da v1.7

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| "Dedup" e "conclusão automática" são instrução em prosa pro modelo, não lógica determinística — podem falhar na prática como a própria reconsulta falhou antes | Médio | É exatamente o que a rodada testa; se o uso real mostrar que o `TodoWrite` também é ignorado, o hook (`ROADMAP.md`) é a próxima camada |
| Caso de eval novo sem rodar a suíte pode esconder um prompt mal calibrado até o próximo lote | Baixo | `scripts/validate_evals.py` garante só o schema; calibração fica para quando o lote acumulado for rodado |

# Rodada v1.8 — gráficos de custo × ganho no README

Spec: [issue #109](https://github.com/rasecdev/conductor/issues/109), publicada
via `/to-spec`. Origem: decisão já registrada em `CLAUDE.md` → "Artefatos
vivos" (2026-09-25) — "Repositório para gráficos públicos de custo × ganho
(README): gerados de `evals/benchmarks/*.json`, nunca mantidos à mão" — que
ficou pendente até esta rodada.

## Overview

Novo script gera, a partir de `evals/benchmarks/*.json`, um gráfico de custo
(tokens e duração medianos por execução, por versão) e um de ganho (taxa de
acerto `with_skill` vs. `without_skill`, por versão, quando ambos existirem).
Os arquivos gerados substituem, no README, a tabela fixa que só cobre a v1.4;
a linha desatualizada sobre a estrutura do Notion também é corrigida. Rodada
de infraestrutura de documentação do próprio repositório — não muda o
comportamento do `SKILL.md`.

## Architecture Decisions

- Script novo (`scripts/generate_benchmark_charts.py`), mesma família de
  `state.sh`/`check-gates.sh`/`benchmark_summary.py`: lê todos os
  `evals/benchmarks/*.json`, nunca argumento de versão único.
- Seam de teste: script determinístico (`scripts/test_generate_benchmark_charts.sh`),
  não eval — ver spec #109, Testing Decisions. Nenhum caso novo em
  `evals/evals.json`; todas as stories da #109 são não verificáveis por eval.
- Fora de escopo (ver spec #109): gerar `evals/benchmarks/v1.6.json`/`v1.7.json`;
  qualquer mudança de comportamento do `SKILL.md`/pipeline; geração do
  gráfico em tempo real a cada PR no CI.

## Task List

### Fase 1: Script + teste

- [x] [Tarefa 1: scripts/generate_benchmark_charts.py (custo e ganho a partir de evals/benchmarks)](https://github.com/rasecdev/conductor/issues/110)
- [x] [Tarefa 2: teste determinístico do gerador de gráficos + CI](https://github.com/rasecdev/conductor/issues/111)

### Checkpoint: Fase 1

- [x] `scripts/generate_benchmark_charts.py` gera `docs/benchmarks/custo.svg` e `docs/benchmarks/ganho.svg` a partir dos `evals/benchmarks/*.json` já versionados (v1.4, v1.5), com modelo/data anotados
- [x] `scripts/test_generate_benchmark_charts.sh` comprova saída determinística; job `benchmark-chart-script` verde no CI

### Fase 2: README e fechamento

- [ ] [Tarefa 3: README embute os gráficos e corrige a linha do Notion](https://github.com/rasecdev/conductor/issues/112)
- [ ] [Tarefa 4: fechamento da rodada v1.8](https://github.com/rasecdev/conductor/issues/113)

### Checkpoint: Fase 2

- [ ] Seção "Qualidade" do README mostra os gráficos gerados, sem a tabela fixa da v1.4 duplicando a mesma informação
- [ ] Linha sobre "estrutura de acompanhamento no Notion" corrigida
- [ ] Toda story da #109 conferida (não verificável por eval, com justificativa) e `SPEC.md` incorpora o delta da v1.8

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Biblioteca de plotting escolhida não estar disponível no ambiente de CI | Baixo | Job novo instala só o necessário para o teste determinístico; imagem é comitada, não gerada a cada PR |
| Gráfico e tabela antiga do README ficarem redundantes/divergentes se a tabela não for removida | Baixo | Critério de aceite da Tarefa 3 exige remover a tabela ao embutir o gráfico |
