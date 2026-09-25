# SPEC — conductor

Spec viva do `conductor`: descreve o comportamento **atual** da skill (o que já
está implementado e validado), não o que está planejado. É a fonte de verdade
do que a skill faz; o `SKILL.md` é a implementação dela.

- Mudanças entram como spec de rodada publicada no tracker (issue, via
  `/to-spec`) — ver "Histórico de rodadas" no fim. Ao fechar a rodada, o delta
  é incorporado aqui.
- Visão de longo prazo e o princípio que não muda ficam em `ROADMAP.md`; plano
  de tarefas em `tasks/plan.md`.

Estado consolidado: v1.0 → v1.3.

## Problem Statement

O usuário mantém vários projetos em estágios muito diferentes de maturidade
(do zero; maduro com processo formalizado; legado maduro sem processo de IA
formalizado) e usa um pipeline de skills de spec development (descoberta →
sharpen/modelo de domínio → spec formal → quebra em tarefas → implementação →
revisão) que é poderoso mas fragmentado: nenhuma skill sabe dizer "você está
aqui, o próximo passo é ali". É fácil pular uma etapa (ex: escrever tarefas sem
spec formal) sem perceber.

Além do pipeline de spec, o projeto acumula **artefatos vivos** (board de
fases, diagrama de arquitetura, fluxo de tela, artefatos de QA) que ficam
desatualizados em silêncio quando a decisão que eles registram muda — e nem
todo artefato faz sentido pra todo tipo de projeto.

## Solution

Uma skill global (`conductor`) que lê o estado real de um projeto e sua
convenção específica, diz exatamente qual skill do pipeline chamar agora, e
mantém os artefatos vivos do processo rastreados contra sua fonte de verdade.
Ela identifica o que falta ou ficou pra trás e conduz o usuário até a peça
certa — nunca é ela quem cria, mantém ou melhora a pipeline por conta própria.
Nunca dispara as skills sensíveis (marcadas como manuais), e nunca decide
sozinha entre alternativas: recomenda, o usuário decide.

## Objetivos e critérios de sucesso

| Objetivo | Critério verificável (via eval) |
|---|---|
| O usuário sabe o próximo passo sem reler o pipeline | Resposta nomeia estágio atual + próxima skill + motivo amarrado ao estado do repo |
| Nenhum trabalho pronto é refeito | Em projeto maduro, não recomenda spec/planejamento que já existe (`mature-feature`) |
| Projeto legado não é tratado como ideia nova | Não recomenda `wayfinder`/`grilling` de descoberta em legado (`legacy-project`) |
| Controle do usuário sobre ações caras | Nunca invoca skill manual; devolve o comando exato (todos os casos) |
| Artefato vivo não fica desatualizado em silêncio | Avisa divergência e aponta a skill certa, sem regenerar (`non-board-artifact-staleness`) |
| Recomendação proporcional ao projeto | Não oferece artefato de UI a projeto headless (`headless-project-no-ui-recommendation`) |
| Pergunta só uma vez | Recusa de tipo de artefato registrada no projeto não é perguntada de novo (`board-tool-refusal-remembered`) |
| Skill agrega sobre o baseline | `with_skill` ≥ baseline em todos os casos de `evals/evals.json` |

Estado atual desse último critério: nenhuma regressão, mas diferenciação
fraca (empate com o baseline) em `board-tool-precedent-non-notion`,
`board-tool-precedent-mismatch`, `non-board-artifact-staleness` e
`headless-project-no-ui-recommendation` — registrado nos `evals/results-*.md`
como limite dos cenários escolhidos, não falha da skill.

## User Stories

### Orientação no pipeline

1. Como desenvolvedor solo com vários projetos ativos, quero perguntar "onde
   estamos"/"o que eu faço agora" em qualquer repositório, para não precisar
   lembrar em que estágio do processo de spec cada projeto está.
2. Como desenvolvedor começando um projeto do zero, quero que a skill
   reconheça a ausência total de convenção/spec e recomende a descoberta certa
   (`wayfinder` para escopo grande/multi-sessão, `grilling` para escopo menor),
   para não pular direto para tarefas.
3. Como desenvolvedor num projeto maduro com pipeline formalizado, quero que a
   skill leia o estado real (specs, tarefas, milestones, issues — conteúdo, não
   só existência de arquivo) antes de recomendar, para não ser mandado a
   refazer planejamento pronto.
4. Como desenvolvedor num projeto legado sem processo formalizado, quero que a
   skill reconheça sinais de maturidade (histórico de commits, volume de
   código, estrutura de solução) e recomende mapear o sistema existente, não
   descobrir uma ideia nova.
5. Como desenvolvedor num projeto legado, quero que a skill encontre
   convenções em formatos de outras ferramentas de IA (`.cursor/rules`,
   `.github/copilot-instructions.md`, `.windsurfrules`), inclusive exigências
   de artefato de planejamento obrigatório.
6. Como desenvolvedor num projeto legado, quero que a skill minere ~3 commits
   de mudanças parecidas e compare os arquivos tocados, para derivar a
   convenção praticada — e diga quando os três divergem, em vez de inventar
   um padrão.
7. Como desenvolvedor, quero que a convenção do projeto (`CLAUDE.md` ou
   equivalente) tenha precedência sobre a ordem genérica do pipeline.
8. Como desenvolvedor, quero ser avisado proativamente quando estiver pulando
   uma etapa (ex: tarefas sem spec), só com a recomendação — sem a skill
   disparar nada sozinha.

### Controle sobre invocação

9. Como desenvolvedor, quero que a skill nunca dispare as skills manuais
   (`disable-model-invocation: true`), apenas devolva o comando exato.
10. Como desenvolvedor, quero que a skill ofereça chamar diretamente as skills
    não manuais do pipeline quando fizer sentido.
11. Como desenvolvedor, quero que a skill nunca edite o frontmatter de outra
    skill.

### Catálogo e avaliação de skill nova

12. Como desenvolvedor, quero ver as skills do pipeline ordenadas por estágio,
    com uma frase curta de cada.
13. Como desenvolvedor, quero que o catálogo seja lido dinamicamente das skills
    instaladas, para que uma skill nova apareça sem editar o `conductor`.
14. Como desenvolvedor, quero propor uma skill nova e receber uma avaliação
    (complementa / substitui / redundante) contra o que já existe no mesmo
    estágio, sem a skill decidir qual fica.
15. Como desenvolvedor, quero que essa avaliação considere precedente já
    registrado no projeto (skill parecida já aceita/rejeitada).
16. Como desenvolvedor, quero poder pedir — ou receber a oferta, quando a
    leitura ficar ambígua — uma avaliação quantitativa via `skill-creator`,
    nunca disparada automaticamente.
17. Como desenvolvedor, quero que um roteador estático já instalado (ex:
    `ask-matt`) seja tratado como vocabulário do pipeline, com a recomendação
    final vindo da leitura de estado.

### Artefatos vivos

18. Como desenvolvedor, quero que a ferramenta de cada tipo de artefato siga o
    precedente do projeto; sem precedente, a disponível na sessão; com mais de
    uma, que a skill pergunte — nenhuma ferramenta é padrão por definição.
19. Como desenvolvedor, quando o precedente registrado não bater com o que o
    conector encontra, quero ver o que foi encontrado e escolher, em vez de só
    uma confirmação de identidade.
20. Como desenvolvedor sem ferramenta disponível, quero ser perguntado uma
    única vez por projeto e por tipo de artefato; se recusar, que a recusa
    fique registrada **no projeto alvo** e nunca mais seja perguntada ali — e
    que recusar um tipo não se estenda aos outros.
21. Como desenvolvedor, quero um board de fases com página-hub do projeto e uma
    subpágina por fase contendo o grafo de dependência das tarefas (Mermaid ou
    formato nativo), com tarefas como nós — nunca páginas próprias.
22. Como desenvolvedor, quero que a skill nunca crie página esporádica sem
    perguntar, recomendando nota na fase atual (pontual) ou subpágina dedicada
    (grande).
23. Como desenvolvedor, quero que qualquer artefato vivo registrado (board,
    diagrama de arquitetura, fluxo de tela, QA — lista aberta) seja checado
    contra sua fonte de verdade, e que a skill avise e aponte a skill de
    regeneração quando divergir, sem regenerar sozinha.
24. Como desenvolvedor, quero que conector indisponível nunca bloqueie o resto
    da orientação — só avise que aquela parte ficou pendente.

### Tipo de projeto

25. Como desenvolvedor, quero que a skill reconheça se o projeto tem UI (web,
    mobile, desktop) ou é headless, e não ofereça fluxo de tela/design de UI a
    projeto headless.
26. Como desenvolvedor com projeto ambíguo (ex: backend com painel admin),
    quero ser perguntado em vez de a skill presumir.
27. Como desenvolvedor, quero poder pedir um artefato fora do perfil detectado
    e ser atendido — a detecção filtra recomendação, não trava pedido.

## Implementation Decisions

- **Skill global**, não por projeto: funciona em qualquer repositório sem
  configuração.
- **Módulos**: `SKILL.md` (frontmatter + processo em 6 passos), referência de
  estágios do pipeline (tabela estágio → o que resolve → skills de exemplo, e
  como avaliar skill nova), script de catálogo (name / description / manual
  de cada skill instalada, lido do frontmatter na hora).
- **Auto-invocável** (sem `disable-model-invocation`): só informa/recomenda,
  sem efeito colateral irreversível. Reabrir isso exige decisão explícita.
- **Skills manuais nunca invocadas**: bloqueio mecânico da ferramenta de
  skill, reforçado como regra explícita. Qual skill é manual vem sempre do
  catálogo, não da lista de exemplo.
- **Nomes de skill são exemplo**: a referência de estágios não hardcoda nomes
  como universais; o catálogo é a fonte de verdade do que está instalado.
- **Processo em 6 passos**:
  1. Convenção do projeto (`CLAUDE.md`/`AGENTS.md`/equivalentes de outras
     ferramentas), sinais de maturidade, mineração de ~3 commits em legado, e
     detecção de tipo de projeto (UI / headless / ambíguo).
  2. Estado do projeto em ordem (modelo de domínio/ADR → spec formal →
     tarefas com critério de aceite → implementação em andamento → PR em
     revisão); o primeiro "não" indica o próximo passo; ler conteúdo e
     índice, nunca concluir por `grep` solto.
  3. Catálogo dinâmico cruzado com a referência de estágios; skill fora da
     tabela vira candidata a entrar nela (pergunta ao usuário o estágio).
  4. Recomendação no formato "Você está em X. O próximo passo é Y — motivo";
     manual → devolve comando e para; não manual → oferece invocar.
  5. Avaliação de skill nova por leitura + precedente do projeto, com
     escalada opt-in para avaliação quantitativa via `skill-creator`.
  6. Artefatos vivos: escolha de ferramenta (precedente → disponível →
     pergunta única), estrutura do board, detecção de desatualização por
     artefato, degradação.
- **Decisões persistidas no projeto alvo**, nunca no `conductor` (recusa de
  artefato, registro de artefato: onde vive + fonte de verdade que acompanha).
- **Tipo de projeto é filtro de recomendação**, nunca trava.

## Testing Decisions

- **Seam único**: framework de eval do `skill-creator` — subagente com a skill
  (`with_skill`) vs. subagente baseline, mesmos prompts, sempre em paralelo;
  avaliação por comparação contra `expected_output` em prosa, não assertion
  determinística de string.
- **Testa comportamento externo** do `SKILL.md` inteiro (a recomendação que o
  usuário recebe), não passos isolados.
- **Casos cobertos** (`evals/evals.json`): `fresh-project`, `mature-feature`,
  `skill-evaluation`, `legacy-project`, `board-tool-precedent-non-notion`,
  `board-tool-first-ask`, `board-tool-refusal-remembered`,
  `board-tool-precedent-mismatch`, `non-board-artifact-staleness`,
  `headless-project-no-ui-recommendation`. Resultados em `evals/results-*.md`.
- **Validações em execução real** (fora do eval): Passo 6 com Notion num
  projeto piloto; seam rodado pelos scripts oficiais do `skill-creator`
  (`aggregate_benchmark`, `generate_review.py`); escalada quantitativa do
  Passo 5 com par sintético propositalmente ambíguo.
- **Regra**: passo/comportamento novo no `SKILL.md` exige caso novo em
  `evals/evals.json` antes de a rodada fechar.
- **Prior art**: a iteração 1 de `mature-feature` expôs que a skill (e a
  assertion) presumiam falta de spec sem ler `tasks/plan.md` a fundo — origem
  da regra "ler conteúdo, não só existência".

## Out of Scope

- Criar, configurar ou implementar qualquer parte da pipeline (spec,
  artefato, gate) — isso é da skill/ferramenta que o `conductor` aponta.
- Invocar skills manuais, mesmo que fosse possível.
- Plataforma de orquestração de terceiro para gerenciar projetos — avaliada e
  rejeitada (resolve outro problema; proveniência de código não confiável).
- Kernel de pontuação determinístico sempre ligado para avaliar skills —
  overhead desproporcional; avaliação quantitativa fica opt-in.
- Padronização de código (formatação, nomenclatura) — resolvida por
  ferramenta determinística do projeto (ESLint/Prettier), não por orientação.

## Histórico de rodadas

Cada rodada é uma spec de delta no tracker; depois de implementada e validada,
foi incorporada acima.

| Rodada | Spec | O que mudou | Validação |
|---|---|---|---|
| v1.0 | [#1](https://github.com/rasecdev/conductor/issues/1) | Orientação no pipeline, catálogo, avaliação de skill nova, board no Notion | 4 casos de eval + validações reais (#3, #4, #5) |
| v1.1 | [#6](https://github.com/rasecdev/conductor/issues/6) | Passo 6 agnóstico de ferramenta (Notion deixa de ser obrigatório) | `evals/results-v1.1-passo6-agnostico.md` |
| v1.2 | [#9](https://github.com/rasecdev/conductor/issues/9) | Desatualização checada para qualquer artefato vivo, não só board | `evals/results-v1.2-v1.3.md` |
| v1.3 | [#12](https://github.com/rasecdev/conductor/issues/12) | Detecção de tipo de projeto filtra recomendação de artefato de UI | `evals/results-v1.2-v1.3.md` |

Em andamento (não incorporadas): v1.4 gates de qualidade, v1.5 gates de
transição — ver `tasks/plan.md`.
