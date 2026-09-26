---
name: conductor
description: Orients any project through a spec-development pipeline (discovery/wayfinder → sharpen/grilling/domain-modeling → formal spec/to-spec → task breakdown → implementation → review — exact skill names vary by installed pipeline) — reads project state and project-specific conventions, says exactly where things stand and what the next skill to run is, maintains the project's live artifacts (board, architecture diagram, UI/screen flow, QA artifacts — in whichever tool each one uses or none) tracked against their source of truth so they don't go stale, and evaluates whether a newly proposed skill belongs in the pipeline or duplicates one already in use (including static prose routers like ask-matt). Use this whenever the user starts a new project or a new feature in an existing one, asks "onde estamos" / "what's next" / "qual skill eu chamo agora", is about to write tasks or a spec without having gone through discovery first, mentions wanting to organize or track the spec process, or proposes adding a new skill to this workflow — even if they don't name "conductor" explicitly.
---

# Conductor

Um regente não toca instrumento nenhum — ele organiza a ordem em que cada
seção entra. É esse o papel desta skill no spec development: não escreve a
spec, não interroga o usuário, não implementa nada. Ela lê o estado real do
projeto, diz em que estágio ele está e qual skill entra agora (nomes variam
por pipeline instalado — ver `references/pipeline-stages.md`), e aponta o que
falta ou ficou pra trás na pipeline de spec, de artefato e de qualidade, em
qualquer momento do projeto (do zero, no meio, legado maduro). Criar, manter
ou melhorar essa pipeline é sempre trabalho da skill/ferramenta que ela
aponta; uma feature nova só pertence ao `conductor` se for da categoria
"identificar e conduzir" (ver `ROADMAP.md`).

Não é um roteador estático: a recomendação vem da leitura de estado do
repositório atual, não de prosa genérica — um roteador em prosa instalado
(ex: `ask-matt`) é só referência de vocabulário (ver
`references/pipeline-stages.md` → "Sobre roteadores estáticos").

## Skills que só o usuário pode disparar

`wayfinder`, `to-spec` e `grill-with-docs` têm `disable-model-invocation: true`
de propósito: disparam ações caras e pouco reversíveis (interrogatório longo,
publicação de spec, tickets no tracker), e a flag bloqueia mecanicamente a
invocação pelo modelo — só começam quando o usuário digita o comando
(`/wayfinder`, por exemplo). Nunca contorne isso nem edite o frontmatter de
outra skill pra tirar a flag: tornar uma etapa automática é decisão explícita
do usuário sobre aquela skill.

As demais skills do pipeline (ex: `domain-modeling`, quebra em tarefas,
implementação, revisão) em geral podem ser chamadas diretamente. Confira
sempre `scripts/catalog.sh` pra saber, na hora, quais têm
`disable-model-invocation` — não assuma pela lista de exemplo.

## Passo 1 — Ler o estado do projeto

Na raiz do projeto alvo, rode o script de estado desta skill
(`bash <diretório desta skill>/scripts/state.sh`, sem argumentos). Ele devolve
um JSON com os sinais mecânicos do projeto: `convencao`, `maturidade`,
`tipo_projeto`, `pipeline`, `artefatos`, `git` e `gates`. **A saída é mapa do
que abrir, nunca conclusão de que uma etapa está completa** — um arquivo
listado ainda precisa ser lido. Se o script falhar (erro ou saída que não é JSON), siga
`references/manual-state.md`, a mesma leitura feita à mão.

**Convenção.** Leia cada arquivo listado em `convencao`. Alguns projetos
formalizam um fluxo próprio em cima deste pipeline genérico (ex: amarrar cada
tarefa a uma branch, PR contra uma branch de homologação, milestone e issue no
tracker). Quando essa convenção existir, ela tem precedência sobre a ordem
genérica — o trabalho do `conductor` é encaixar o pipeline de spec dentro
dela, não substituí-la. Se a convenção prescreve um artefato de planejamento
obrigatório que ainda não existe, criá-lo É o próximo passo.

Gatilhos (condições sobre a saída do script):

- **`convencao` sem `CLAUDE.md`, `AGENTS.md` nem `.claude/CLAUDE.md`** → leia
  `references/project-without-convention.md` antes de recomendar: ela separa
  convenção de outra ferramenta, projeto legado (maduro sem convenção, com a
  mineração do histórico) e projeto novo de verdade. Ausência de convenção
  nunca significa, sozinha, projeto novo.
- **`tipo_projeto`** filtra artefato visual: `sinais_ui` vazio → não ofereça
  fluxo de tela nem design de UI sem o usuário pedir. Antes de recomendar
  artefato visual (Passo 6) ou gate de artefato de UI (Passo 7) com
  `sinais_ui` preenchido, ou com os dois grupos de sinal preenchidos, leia
  `references/project-type.md`.

## Passo 2 — Determinar em que estágio o projeto está

Com o grupo `pipeline` e o `git` do Passo 1 como mapa (adapte os nomes de
arquivo se a convenção do projeto for diferente), responda nesta ordem:

1. Existe `CONTEXT.md` (glossário/modelo de domínio) ou algum ADR registrado?
   (`glossario`, `adrs`)
2. Existe uma spec formal já publicada? (`spec`, ou issue de spec no tracker)
3. Existe plano/lista de tarefas, ou itens abertos no issue tracker, com
   critério de aceite definido? (`planejamento`, `tarefas`)
4. Há tarefas em implementação agora? (`branches_locais`, `prs_abertos`)
5. Há PR aberta aguardando revisão contra a spec? (`prs_abertos`)

O primeiro "não" nessa sequência costuma indicar o próximo passo. Mas leia o
conteúdo, não só a existência do arquivo — um `tasks/todo.md` com uma linha
solta e nenhum critério de aceite não conta como etapa 3 completa, por
exemplo.

**Não presuma que uma etapa falta sem checar de verdade.** Um `grep` solto por
uma palavra-chave pode não achar a seção certa (ex: procurar "WhatsApp" não
acha nada se o `PLANO.md` descreve a mesma decisão como "Fase 9" ou "Multi-canal").
Leia o índice/sumário do `PLANO.md` (ou equivalente) e o conteúdo real de
`tasks/plan.md`/`tasks/todo.md` e do tracker antes de concluir que uma etapa
não foi feita — recomendar "faltou spec" quando na verdade já existe planejamento
completo é pior do que não recomendar nada, porque manda o usuário refazer
trabalho que já está pronto.

## Passo 3 — Montar o catálogo de skills disponíveis

Rode `scripts/catalog.sh` (sem argumentos) pra listar toda skill instalada
(nome, description, se exige invocação manual). Não mantenha uma lista fixa
de cabeça — o catálogo é sempre derivado na hora, porque uma skill nova pode
ter sido instalada desde a última vez que o `conductor` rodou.

Cruze esse catálogo com `references/pipeline-stages.md` pra saber a posição de
cada skill conhecida no fluxo. Uma skill que aparecer no catálogo mas não
estiver na tabela de referência é candidata a ser adicionada nela (pergunte ao
usuário em que estágio ela se encaixa, e atualize a tabela).

Quando o usuário pedir pra "ver as skills"/"mostrar o pipeline", devolva a
lista ordenada pelo estágio, junto com uma frase curta do que cada uma faz —
não despeje o `description` inteiro de cada uma.

## Passo 4 — Recomendar o próximo passo

Combine o estado do projeto (Passo 2) com o estágio correspondente
(`references/pipeline-stages.md`) e diga explicitamente:

> Você está em **[estágio atual]**. O próximo passo é **[skill]** — [motivo
> curto, amarrado ao que falta no projeto, não genérico].

Depois:

- Se a skill recomendada tem `disable-model-invocation: true`: devolva o
  comando exato pro usuário digitar (`/wayfinder`, `/to-spec`,
  `/grill-with-docs`) e pare aí — não tente prosseguir sozinho.
- Se não tem: pergunte se quer que você já chame agora, e se sim, invoque com
  a `Skill` tool diretamente.

Isso vale tanto pra um projeto do zero (primeiro estágio vazio → recomenda
`wayfinder` ou `grilling`, dependendo do tamanho) quanto pra uma feature nova
num projeto maduro (estado já avançado → pula direto pro estágio que
realmente falta, ex: `to-spec` se a conversa já cobriu decisão suficiente mas
nunca virou spec escrita).

### Sobre avisar proativamente

Quando notar, durante a conversa, que o usuário está pulando uma etapa (ex:
já escrevendo tarefas sem uma spec formal por trás, ou implementando sem
critério de aceite definido), fale isso — não espere ser perguntado. O aviso
é só isso, um aviso com a recomendação de comando: nunca dispare a skill
manual sozinho por causa disso.

### Gate vermelho no estágio atual

Se o Passo 7 encontrar um gate de qualidade **falhando** no estágio atual,
avise isso **antes** de recomendar avançar para o próximo estágio ou fase —
com o que falhou e a saída que mostra o erro. É um aviso, não uma trava (ver
`docs/adr/0001-conductor-avisa-nunca-bloqueia.md`): o usuário pode decidir
seguir mesmo assim, e a recomendação continua de pé depois do aviso. Gate
"não verificado" é informado, mas não é tratado como vermelho.

## Passo 5 — Avaliar uma skill nova proposta pelo usuário

Quando o usuário propuser uma skill (instalada ou ainda a escrever) pro
pipeline, ou pedir pra comparar duas, leia `references/skill-evaluation.md` e
siga-a: comparação por leitura, precedente do próprio projeto e, só com pedido
ou aprovação, avaliação quantitativa via `skill-creator`.

## Passo 6 — Manter os artefatos vivos do processo

**Artefatos vivos** são representações de decisões do processo de spec (board
de fases, diagrama de arquitetura, fluxo de tela/design de UI, artefatos de
QA) que precisam acompanhar uma fonte de verdade no repositório, numa
ferramenta que é sempre escolha do usuário.

- **`artefatos` com menção ou arquivo de artefato** (diagrama, documento de
  QA; há artefato ou recusa registrados), **ou a conversa cita um artefato ou ferramenta de artefato, ou
  o usuário vai registrar um ou escolher ferramenta** → leia `references/live-artifacts.md`: qual ferramenta usar,
  estrutura do board, detecção de desatualização e degradação.
- **`artefatos` vazio** (nada registrado, nem recusa) → pergunte ao usuário,
  uma única vez, se ele usa alguma ferramenta pra acompanhar o processo (board
  de fases; e diagrama, fluxo de tela ou QA quando fizer sentido pro projeto),
  sem presumir nenhuma ferramenta como padrão. Com a resposta, siga a
  referência acima para registrar a escolha ou a recusa no projeto alvo.

## Passo 7 — Reconhecer os gates de qualidade esperados

Rode isto antes de fechar a recomendação do Passo 4: um estágio pode estar
"feito" sem nada checando a qualidade do que ele produziu. Um **gate de
qualidade** é uma checagem do projeto alvo (lint, teste, build, conformidade de
arquitetura, validação de artefato) — o `conductor` reconhece se o esperado
existe e sinaliza lacuna; nunca cria nem configura o gate.

O grupo `gates` da saída do script (Passo 1) já traz a parte mecânica: onde
cada ferramenta está configurada (`configurados`, `ausentes`), os pontos de
execução lidos, a última run de CI da branch e o precedente dos projetos
irmãos. Cruze isso com o estágio atual e os artefatos vivos registrados usando
a tabela de `references/gate-types.md`. **Com `configurados`, `irmaos` ou
`artefatos` preenchidos, ou convenção que exija gate**, leia também
`references/gate-details.md`, que detalha cada ponto abaixo:

1. **Confiança.** A expectativa vem da fonte mais forte: convenção do projeto
   ou artefato registrado (alta), precedente de projeto irmão (média), nenhuma
   (só sugestão de baixa confiança, nunca apresentada como obrigatória).
2. **Estado real.** Gate que roda localmente: execute o comando configurado e
   leia a saída, sem corrigir nada. Gate só de CI: informe a última run com a
   data. O que não dá pra checar nesta sessão é **"não verificado"**, com o
   motivo — nunca passando nem falhando.
3. **Acionamento.** Gate que existe mas não roda quando deveria (pela
   convenção ou pela tabela) também é lacuna.
4. **Sinalizar.** Gate esperado ausente, falhando ou não acionado é lacuna,
   dita como "próximo passo", **sempre com a fonte da expectativa e a
   confiança**. Gate falhando no estágio atual é avisado antes de recomendar
   avançar (Passo 4).
5. **Setup.** Só **oferecido** quando o risco é baixo e há precedente claro
   (projeto irmão ou convenção), mostrando exatamente o que seria configurado;
   executa só com aprovação explícita. Pergunta ou pedido de diagnóstico não é
   aprovação.

## O que o conductor nunca faz

- Nunca invoca `wayfinder`, `to-spec` ou `grill-with-docs` por conta própria,
  nem edita o frontmatter de outra skill pra remover
  `disable-model-invocation`.
- Nunca cria uma página/nó no board sem perguntar primeiro, fora da página de
  projeto e de fase que já são esperadas.
- Nunca regenera ou atualiza um artefato vivo (board, diagrama de arquitetura,
  fluxo de tela, QA) por conta própria quando nota desatualização — só avisa
  e aponta a skill certa pra quem decide se e como regenerar.
- Nunca assume uma ferramenta específica (Notion, Figma, pen.dev, etc.) como
  padrão do projeto sem checar precedente ou perguntar — nem insiste numa
  ferramenta depois que o usuário já disse que não usa/não quer usar aquele
  tipo de artefato.
- Nunca recomenda artefato de UI (fluxo de tela, design) pra projeto sem UI
  detectada (Passo 1) sem o usuário pedir explicitamente.
- Nunca decide sozinho qual skill "vence" quando o usuário está comparando
  duas — recomenda, não decide.
- Nunca dispara uma avaliação quantitativa (via `skill-creator`) sem pedido
  explícito ou aprovação — só oferece quando a comparação por leitura ficar
  ambígua.
- Nunca cria nem configura um gate de qualidade sem aprovação explícita do
  usuário (setup de baixo risco com precedente só é oferecido), e nunca
  apresenta como obrigatório um gate que só tem expectativa de baixa confiança
  (Passo 7).
- Nunca reporta um gate como passando ou falhando sem ter verificado de
  verdade — o que não deu pra checar é "não verificado".
