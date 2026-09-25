# SPEC — conductor

Spec viva do `conductor`: descreve o comportamento **atual** da skill (o que já
está implementado e validado), não o que está planejado. É a fonte de verdade
do que a skill faz; o `SKILL.md` é a implementação dela.

- Mudanças entram como spec de rodada publicada no tracker (issue, via
  `/to-spec`) — ver "Histórico de rodadas" no fim. Ao fechar a rodada, o delta
  é incorporado aqui.
- Visão de longo prazo e o princípio que não muda ficam em `ROADMAP.md`; plano
  de tarefas em `tasks/plan.md`.

Estado consolidado: v1.0 → v1.4.

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

E um estágio pode estar "feito" sem nada checando a qualidade do que ele
produziu: diagrama registrado que ninguém valida, lint que só roda quando alguém
lembra, gate vermelho há semanas — e a recomendação de avançar sai como se
estivesse tudo bem.

## Solution

Uma skill global (`conductor`) que lê o estado real de um projeto e sua
convenção específica, diz exatamente qual skill do pipeline chamar agora, e
mantém os artefatos vivos do processo rastreados contra sua fonte de verdade,
e reconhece os gates de qualidade que cada estágio/artefato deveria ter —
verificando o estado real deles e avisando, sem travar, antes de recomendar
avançar.
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
| Qualidade do estágio não passa em silêncio | Sinaliza gate esperado ausente citando fonte e confiança (`quality-gate-expected-missing`) |
| Estado de gate nunca é presumido | Roda o gate ou reporta "não verificado" (`quality-gate-failing`, `quality-gate-ci-unverifiable`) |
| Aviso, não trava | Gate vermelho é avisado antes de recomendar avançar, e a decisão continua do usuário (`quality-gate-failing`) |
| Skill agrega sobre o baseline | `with_skill` ≥ baseline em todos os casos de `evals/evals.json` |

Estado atual desse último critério (regressão completa da v1.4, 16 casos em
fixtures isoladas, formato oficial): `with_skill` 100%, baseline 77,9%; nenhuma
regressão. Empate com o baseline em `mature-feature`, `legacy-project`,
`board-tool-precedent-non-notion`, `board-tool-first-ask`,
`board-tool-refusal-remembered`, `headless-project-no-ui-recommendation` e
`quality-gate-not-triggered` — o modelo com as skills de SDD instaladas já faz
isso sozinho. Detalhes e limites em `evals/results-v1.4.md`.

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

### Gates de qualidade

28. Como desenvolvedor, quero saber, ao perguntar "onde estamos", se os gates
    de qualidade esperados do estágio atual existem e estão passando — não só
    se o estágio está "feito".
29. Como desenvolvedor, quero que "qual gate é esperado onde" seja uma régua
    fixa da skill (lista aberta), filtrada pelo tipo e pela stack do projeto.
30. Como desenvolvedor, quero que a expectativa de um gate venha de uma fonte
    explícita — convenção, artefato registrado, projeto irmão, ou só sugestão
    de baixa confiança — e que a resposta diga a fonte e a confiança.
31. Como desenvolvedor, quero que o estado do gate seja verificado de verdade
    (rodando o gate, ou lendo a última run de CI com data) e reportado como
    "não verificado" quando não der para checar.
32. Como desenvolvedor, quero ser avisado quando um gate existe mas não roda no
    momento em que deveria (ex: convenção pede pre-commit e não há hook).
33. Como desenvolvedor, quero ser avisado de gate vermelho antes de qualquer
    recomendação de avançar, podendo seguir mesmo assim — aviso, não trava.
34. Como desenvolvedor, quero que a skill nunca crie nem configure gate sozinha;
    com precedente claro e risco baixo, que só ofereça o setup, e pergunte
    quando houver mais de uma ferramenta possível.

## Implementation Decisions

- **Skill global**, não por projeto: funciona em qualquer repositório sem
  configuração.
- **Módulos**: `SKILL.md` (frontmatter + processo em 7 passos), referência de
  estágios do pipeline (tabela estágio → o que resolve → skills de exemplo, e
  como avaliar skill nova), referência de tipos de gate (artefato/estágio →
  gate → ferramenta → comando → quando deveria rodar, e o que conta como gate
  existente), script de catálogo (name / description / manual de cada skill
  instalada, lido do frontmatter na hora).
- **Auto-invocável** (sem `disable-model-invocation`): só informa/recomenda,
  sem efeito colateral irreversível. Reabrir isso exige decisão explícita.
- **Skills manuais nunca invocadas**: bloqueio mecânico da ferramenta de
  skill, reforçado como regra explícita. Qual skill é manual vem sempre do
  catálogo, não da lista de exemplo.
- **Nomes de skill são exemplo**: a referência de estágios não hardcoda nomes
  como universais; o catálogo é a fonte de verdade do que está instalado.
- **Processo em 7 passos**:
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
  7. Gates de qualidade: esperados pela referência (filtrados por tipo e
     stack), confiança pela fonte, existência (script, CI ou hook), estado
     real ou "não verificado", acionamento no momento esperado; lacuna sempre
     com fonte e confiança. O Passo 4 avisa gate vermelho antes de recomendar
     avançar. Setup só oferecido, executado com aprovação.
- **Decisões persistidas no projeto alvo**, nunca no `conductor` (recusa de
  artefato, registro de artefato: onde vive + fonte de verdade que acompanha).
- **Tipo de projeto é filtro de recomendação**, nunca trava.
- **Avisa, nunca bloqueia** ([ADR 0001](docs/adr/0001-conductor-avisa-nunca-bloqueia.md)):
  a ação mais forte diante de um gate é avisar e deixar de recomendar avanço.

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
  `headless-project-no-ui-recommendation`, `quality-gate-expected-missing`,
  `quality-gate-low-confidence`, `quality-gate-failing`,
  `quality-gate-ci-unverifiable`, `quality-gate-not-triggered`,
  `quality-gate-setup-offered-not-executed`. Resultados em
  `evals/results-*.md`.
- **Fixtures isoladas**: todo caso com estado roda numa cópia de
  `evals/files/<fixture>` com git próprio, uma por run
  (`scripts/prepare_fixture.sh`); estado que não cabe em arquivo (histórico
  longo, pasta sem git) vem de um gancho de setup. A comparação com o baseline
  só é válida a partir da v1.4: antes disso os casos citavam projetos reais e
  descreviam o estado no próprio prompt.
- **Formato oficial** do `skill-creator` (`run-N` + `grading.json`), com
  assertions tiradas do `expected_output` e fixadas antes das runs.
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
| v1.4 | [#24](https://github.com/rasecdev/conductor/issues/24) | Gates de qualidade: esperados, fonte e confiança, estado real, acionamento, aviso sem trava; casos antigos migrados para fixtures | `evals/results-v1.4.md` |

Em andamento (não incorporada): v1.5 gates de transição — ver `tasks/plan.md`.
