---
name: conductor
description: Orients any project through a spec-development pipeline (discovery/wayfinder → sharpen/grilling/domain-modeling → formal spec/to-spec → task breakdown → implementation → review — exact skill names vary by installed pipeline) — reads project state and project-specific conventions, says exactly where things stand and what the next skill to run is, maintains the project's live artifacts (board, architecture diagram, UI/screen flow, QA artifacts — in whichever tool each one uses or none) tracked against their source of truth so they don't go stale, and evaluates whether a newly proposed skill belongs in the pipeline or duplicates one already in use (including static prose routers like ask-matt). Use this whenever the user starts a new project or a new feature in an existing one, asks "onde estamos" / "what's next" / "qual skill eu chamo agora", is about to write tasks or a spec without having gone through discovery first, mentions wanting to organize or track the spec process, or proposes adding a new skill to this workflow — even if they don't name "conductor" explicitly.
---

# Conductor

Um regente não toca instrumento nenhum — ele organiza a ordem em que cada
seção entra, e sabe a partitura inteira de cor. É esse o papel desta skill no
processo de spec development: não escreve a spec, não interroga o usuário,
não implementa nada — ela sabe em que ponto do processo cada projeto está, diz
qual é o próximo instrumento a entrar, e mantém os artefatos vivos do processo
(board, diagramas, QA) em dia com o que o projeto de fato decidiu.

Ela existe porque um pipeline de skills de spec (descoberta → sharpen/modelo
de domínio → spec formal → quebra em tarefas → implementação → revisão —
ver `references/pipeline-stages.md` pra nomes de skill de exemplo, que variam
por pipeline instalado) é poderoso mas fragmentado: cada peça sabe fazer sua
parte, nenhuma sabe dizer "você está aqui, o próximo passo é ali". É fácil
esquecer uma etapa (ex: começar a escrever tarefas sem ter passado por spec
formal) simplesmente porque ninguém lembrou que ela existia.

**Isso não é um roteador estático.** Alguns pipelines já trazem o próprio
roteador em prosa (ex: `ask-matt` no
[mattpocock/skills](https://github.com/mattpocock/skills), que mapeia cenário
→ sequência de skills). O `conductor` não substitui isso nem tenta recriar
esse mapa — a diferença é que ele lê o estado real do repositório atual
(`CLAUDE.md`, `tasks/plan.md`, git log, milestones/issues) antes de
recomendar, em vez de descrever o fluxo genericamente. Se um roteador desses
estiver instalado, trate-o como referência de vocabulário do pipeline; a
recomendação final do `conductor` continua vindo da leitura de estado, não da
prosa dele.

## Por que várias dessas skills não podem ser chamadas automaticamente

`wayfinder`, `to-spec` e `grill-with-docs` têm `disable-model-invocation: true`
no frontmatter delas — de propósito. Elas disparam ações caras e um tanto
irreversíveis (interrogatório longo, publicação de spec, criação de tickets no
tracker), e quem escreveu esses skills decidiu que só devem começar quando o
usuário pede explicitamente, nunca por iniciativa do modelo. Essa flag também
bloqueia mecanicamente a ferramenta de chamar skills — não é possível invocar
uma skill com essa flag a não ser que o usuário tenha digitado o comando dela
(`/wayfinder`, por exemplo) ele mesmo.

Isso não é uma limitação desta skill — é a mesma regra que vale pra qualquer
skill, incluindo o `conductor`. Nunca tente contornar isso, e nunca edite o
frontmatter de outra skill pra remover essa flag: se o usuário achar que uma
etapa deveria virar automática, isso é decisão dele, tomada explicitamente
sobre aquela skill específica — não algo que o `conductor` decide por conta
própria.

As demais skills do pipeline (ex: `domain-modeling`, e o que fizer o papel de
"quebra em tarefas"/"implementação"/"revisão" no pipeline instalado) em geral
não têm essa flag — o `conductor` pode chamá-las diretamente quando fizer
sentido, em vez de só recomendar. Confira sempre `scripts/catalog.sh` pra
saber, na hora, quais skills instaladas têm `disable-model-invocation` — não
assuma pela lista de exemplo.

## Passo 1 — Ler a convenção do projeto atual

Antes de recomendar qualquer coisa, leia o `CLAUDE.md` (ou `AGENTS.md`) do
repositório atual, se existir. Alguns projetos formalizam um fluxo próprio em
cima deste pipeline genérico (ex: amarrar cada tarefa a uma branch, PR contra
uma branch de homologação, milestone e issue no tracker). Quando essa
convenção existir, ela tem precedência sobre a ordem genérica — o trabalho do
`conductor` aqui é encaixar o pipeline de spec dentro dela, não substituí-la.

**Convenção pode estar num formato de outra ferramenta.** Nem todo projeto usa
Claude Code como ferramenta principal — procure também por regras equivalentes
de outros assistentes: `.cursor/rules/*.mdc` (Cursor), `.github/copilot-instructions.md`
(Copilot), `.windsurfrules`, etc. Um projeto sem `CLAUDE.md` pode ainda assim
ter convenção formalizada, só que noutro lugar — trate isso como convenção do
projeto igualmente, mesmo que precise "traduzir" a terminologia de uma
ferramenta pra outra. Preste atenção especial a qualquer instrução dessas
regras que já prescreva um artefato de planejamento obrigatório (ex: "criar
`development_plan.md` pra todo projeto", "gerar plano pra projeto existente
que não tiver um") — se essa exigência já existe e o arquivo não foi criado
ainda, isso É o próximo passo, não uma escolha entre skills do pipeline
genérico.

**Ausência de convenção não significa projeto novo.** Antes de tratar a falta
de `CLAUDE.md`/regras equivalentes como "projeto do zero", cheque sinais de
maturidade do próprio código: `git log` com histórico longo, volume de código
real, estrutura de solução/projeto já estabelecida (`.sln`, `package.json`
com dependências reais, etc.). Um projeto com milhares de commits e código em
produção que simplesmente nunca formalizou processo de IA/spec é um caso
**diferente** de uma pasta genuinamente vazia — nunca recomende `wayfinder`
ou `grilling` como se fosse descoberta de ideia nova nesse caso. O que falta
ali não é decidir o que construir (isso já existe e funciona), é mapear o
sistema existente antes de mexer nele — o passo certo tende a ser
`domain-modeling`/`grill-with-docs` com foco em entender a arquitetura atual,
não interrogar sobre uma ideia nova.

**Em projeto legado, minere o histórico real, não só a regra escrita.** Regra
documentada (`CLAUDE.md`, `.cursor/rules`, etc.) costuma ser genérica ou
incompleta em projetos antigos — o padrão realmente seguido está no que as
pessoas de fato fizeram. Quando for orientar uma mudança nesse tipo de
projeto, procure no `git log` **uns 3 commits** de tarefas parecidas com o que
o usuário quer fazer agora (mesmo tipo de mudança — ex: "nova tela", "novo
endpoint", "correção de X") e compare os arquivos tocados entre eles. Um
commit só pode ser um conserto pontual e simples, não representativo do
padrão real; três dá triangulação — se os três tocam o mesmo conjunto de
camadas/arquivos na mesma ordem, isso é convenção de fato, mais confiável do
que qualquer regra escrita desatualizada. Se os três divergirem entre si, diga
isso ao usuário em vez de inventar um padrão que não existe.

Se de fato não existir `CLAUDE.md`/`AGENTS.md`/equivalente **e** os sinais de
maturidade também estiverem ausentes (poucos commits, pouco código, ou
nenhum), é um projeto novo de verdade — trate a ausência de convenção como um
sinal, não como um vazio a ignorar: pode valer perguntar ao usuário se ele
quer formalizar uma antes de avançar muito, mas isso não bloqueia recomendar
o primeiro passo.

### Detectar tipo de projeto (pra filtrar recomendação de artefato)

Além de convenção e maturidade, note sinais de **tipo de projeto** — isso não
muda o pipeline de spec em si (Passos 2-5 valem igual), mas filtra quais
artefatos visuais do Passo 6 fazem sentido recomendar:

- **Tem UI própria** (web: `package.json` com framework de frontend; mobile:
  `pubspec.yaml`/Flutter, projeto React Native, projeto nativo iOS/Android;
  desktop: Electron ou equivalente) → fluxo de tela e design de UI são
  artefatos relevantes de recomendar.
- **Headless/backend puro** (API, worker, bot, microserviço sem camada de
  apresentação própria — ex: um bot de Telegram como back-end puro) → não
  recomende fluxo de tela nem design de UI de forma não solicitada.
- **Sinal ambíguo ou misto** (ex: backend com painel administrativo web,
  monorepo com API e app): pergunte ao usuário em vez de presumir.

Isso é só filtro de **recomendação**, nunca uma trava: se o usuário pedir um
desses artefatos mesmo fora do perfil detectado, atenda normalmente — a
detecção só evita *oferecer* algo que não se aplica, não impede pedir.

## Passo 2 — Determinar o estado atual do projeto

Verifique, nesta ordem, o que já existe no repositório (adapte os nomes de
arquivo se a convenção do projeto for diferente):

1. Existe `CONTEXT.md` (glossário/modelo de domínio) ou algum ADR registrado?
2. Existe uma spec formal (`PRODUCT.md`, `TECH.md`, ou equivalente) já
   publicada?
3. Existe `tasks/plan.md` / `tasks/todo.md`, ou itens abertos no issue
   tracker do projeto, com critério de aceite definido?
4. Há tarefas em implementação agora (branch aberta, PR em andamento)?
5. Há PR aberta aguardando revisão contra a spec?

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

## Passo 5 — Avaliar uma skill nova proposta pelo usuário

Quando o usuário propuser uma skill (instalada ou ainda a escrever) pro
pipeline, siga `references/pipeline-stages.md` → "Como usar isso pra avaliar
uma skill nova". Resumo: compare a `description` dela com o que já existe no
mesmo estágio, e devolva uma recomendação (complementa / substitui /
redundante) — nunca decida sozinho qual fica, é o usuário quem escolhe.

Antes de concluir, cheque também se o projeto atual já tem **precedente
próprio** registrado — procure no `PLANO.md`/`PROGRESSO.md` (ou equivalente)
por menções a skills já avaliadas e aceitas/rejeitadas anteriormente. Um
projeto pode já ter decidido não adotar algo parecido, com o motivo
documentado — isso é sinal mais forte do que comparar só descriptions
genéricas, porque reflete uma decisão já tomada com contexto real do próprio
usuário.

### Quando a comparação por leitura não é suficiente: avaliação quantitativa

Comparar `description` contra `description` é rápido e cobre a maioria dos
casos, mas às vezes não é suficiente pra desempatar — duas skills descrevem
objetivos parecidos e não fica claro, só pela leitura, se uma é redundante com
a outra ou se cobre um caso real que a outra não cobre.

Nesse cenário, existe uma opção mais cara e mais confiável: rodar as duas
skills de verdade contra 2-3 prompts realistas, com subagentes em paralelo
(um por skill), e comparar os resultados lado a lado — exatamente o processo
que o `skill-creator` usa pra validar uma skill nova (ver o próprio histórico
deste `conductor`: foi validado assim, com casos de teste, assertions, e
grading real, não só por leitura). Não reimplemente esse processo aqui — ao
chegar nesse ponto, invoque a skill `skill-creator` pra conduzir a comparação.

Isso **nunca dispara sozinho**, pelo mesmo motivo que `wayfinder`/`to-spec` não
disparam: tem custo real (minutos de execução, vários agentes, tokens). Duas
formas de chegar lá:

1. O usuário pede explicitamente ("roda uma avaliação de verdade pra comparar
   essas skills").
2. Você nota que a comparação por description ficou genuinamente ambígua, e
   **oferece** rodar a avaliação — nunca decide sozinho que vale a pena e já
   dispara. Se o usuário preferir decidir só com a leitura, respeite isso.

## Passo 6 — Manter os artefatos vivos do processo

Um projeto pode ter vários **artefatos vivos** — representações visuais ou
estruturadas de decisões do processo de spec, que devem acompanhar uma fonte
de verdade no repositório. O board de fases (o mais comum) é só um deles.
Outros exemplos, conforme o pipeline instalado e o tipo de projeto (Passo 1):

| Artefato | O que registra | Fonte de verdade que acompanha |
|---|---|---|
| Board de fases | Estágio atual, dependência de tarefas | `tasks/plan.md`, milestones/issues |
| Diagrama de arquitetura | Componentes, serviços, fluxo de dados | `PLANO.md`, `docs/adr/` |
| Fluxo de tela / design de UI | Navegação entre telas, design visual | Decisões do spec (`to-spec`: User Stories, Implementation Decisions) — só relevante se o Passo 1 indicar que o projeto tem UI |
| Artefatos de QA/teste | Test plan, casos de teste, matriz de rastreabilidade | Decisões de teste do spec (`to-spec`: Testing Decisions) |

Essa lista **não é fechada** — cruze com o catálogo dinâmico do Passo 3: uma
skill nova de geração de artefato que entrar no pipeline (arquitetura, fluxo
de tela, QA, ou outro tipo) é candidata a virar uma linha nova aqui. Pra
qualquer um desses tipos, a ferramenta que hospeda não é fixa — pode ser
Notion, Miro, Figma, um arquivo no próprio repositório, ou qualquer outra que
sirva ao mesmo propósito. Nenhuma é a recomendada por definição; a escolha de
ferramenta (e onde o arquivo-fonte fica) é sempre do usuário.

### Qual ferramenta usar (mesmo processo pra qualquer tipo de artefato)

1. **Precedente do projeto.** Cheque primeiro se o projeto já tem uma
   ferramenta registrada *pra esse tipo de artefato* — uma menção em
   `PROGRESSO.md`/`CLAUDE.md`, um link já existente, ou o próprio uso ao
   longo da conversa. Se houver, use essa ferramenta sem perguntar de novo.
   - **Precedente que não bate com a realidade** (ex: o link/nome registrado
     não é encontrado pelo conector, ou a busca não retorna o
     board/página/arquivo esperado): não trave pedindo só uma confirmação de
     identidade. Liste o que a busca real *encontrou* nessa ferramenta e
     pergunte ao usuário se algo ali é o certo — ou se nada é, seguindo então
     pro passo 2 (nenhum precedente utilizável) a partir daí.
2. **Nenhum precedente: detectar o que está disponível.** Verifique quais
   MCPs/conectores relevantes pra esse tipo de artefato estão disponíveis
   nesta sessão (board/documentação: Notion, Miro, ClickUp Docs; design/UI:
   Figma, pen.dev; etc.) — mesmo princípio do catálogo dinâmico de skills do
   Passo 3, não mantenha uma lista fixa de cabeça. Se exatamente um estiver
   disponível e conectado, use-o. Se mais de um estiver disponível e não
   houver precedente, pergunte ao usuário qual prefere.
3. **Nenhuma ferramenta disponível nem precedente registrado.** Pergunte ao
   usuário, **uma única vez por projeto e por tipo de artefato**, se ele usa
   alguma ferramenta desse tipo (e, se for algo que pode viver no próprio
   repositório, se prefere isso a uma ferramenta externa).
   - Se responder que sim: use a ferramenta indicada assim que o conector
     correspondente estiver acessível (mesma degradação descrita no fim desta
     seção).
   - Se responder que não usa e não quer usar **esse tipo de artefato**:
     registre essa decisão de forma persistente **no projeto alvo** (nunca no
     `conductor`) — por exemplo uma nota curta em `PROGRESSO.md` ou
     `CLAUDE.md` do projeto ("processo de spec não usa `<tipo de artefato>`
     externo, decidido em `<data>`"). A partir daí, nunca mais pergunte isso
     *naquele projeto, pra aquele tipo de artefato* — continue orientando o
     processo normalmente, só sem essa parte. A recusa de um tipo de artefato
     não se estende aos outros (recusar board não significa recusar diagrama
     de arquitetura, por exemplo).
   - Antes de perguntar, sempre confira se essa decisão já foi registrada
     (Passo 1/2 já leem `PROGRESSO.md`/`CLAUDE.md` do projeto) — a pergunta é
     por projeto e por tipo, não é feita de novo só porque a sessão mudou.

### Estrutura do board de fases, uma vez que haja ferramenta

- **Página do projeto** (sempre existe, é o hub): estágio atual, link pra
  cada página de fase, link pro board de referência do pipeline de skills.
- **Subpágina/nó por fase/rodada** (ex: cada milestone do GitHub, ou cada
  sub-fase documentada no `PLANO.md`): contém o grafo de dependência das
  tarefas daquela fase, renderizado como diagrama Mermaid (ou o formato de
  diagrama nativo da ferramenta escolhida, se ela não suportar Mermaid).
  Tarefas individuais são nós dentro desse diagrama — nunca ganham
  página/nó próprio (evita dezenas de páginas soltas; um projeto real já
  passa de 20 fases).
- **Página esporádica** (bug estrutural, correção de impacto, algo fora do
  mapeamento previsto): **nunca crie sozinho**. Pergunte primeiro. Se for algo
  pequeno e pontual, sugira registrar como nota dentro da página da fase
  atual; se for grande/multi-etapa, sugira uma subpágina dedicada, linkada da
  página do projeto. A decisão final é sempre do usuário.

Outros tipos de artefato (diagrama de arquitetura, fluxo de tela, QA) têm sua
própria estrutura natural, definida pela skill que os gera (ex: `archify`
decide como organiza seu HTML/SVG) — o `conductor` não prescreve isso, só
garante que o artefato está registrado (onde vive, o que acompanha) e que
alguém vai notar se ele ficar pra trás.

### Detectar desatualização (qualquer artefato registrado, não só board)

Ao ler `PLANO.md`/`docs/adr/`/`tasks/plan.md`/spec (Passo 2), para cada
artefato vivo já registrado no projeto (tabela acima), compare contra a fonte
de verdade que ele deveria acompanhar. Sinais de desatualização:

- Um ADR novo, ou uma seção do `PLANO.md` revisada, com data mais recente que
  a última atualização do artefato correspondente (diagrama de arquitetura).
- Uma decisão de UI (`User Stories`/`Implementation Decisions` do spec) que
  não bate mais com o que o fluxo de tela/design registrado mostra.
- Uma seção de `Testing Decisions` do spec que diverge do que o artefato de
  QA já documentou.
- Um fluxo de fase/dependência de tarefas que não bate mais com o
  `tasks/plan.md` (caso do board, já coberto antes da v1.2).

Quando notar isso, avise o usuário e pergunte se quer atualizar o artefato —
apontando a skill certa pra regenerá-lo (`archify`, `pen.dev`,
`qa-manual-istqb`, ou o que estiver instalado pra aquele tipo) — mas **nunca
regenere sozinho**. Mesmo critério de tamanho da "página esporádica": mudança
pontual vira nota; mudança grande/estrutural vira sugestão de regenerar o
artefato inteiro. A decisão de atualizar ou não, e como, continua sendo do
usuário.

### Degradação

As ferramentas chegam via conector MCP (ex: `plugin:design:notion` pra
Notion, ou o que estiver instalado pra Miro/Figma/ClickUp Docs/outra) ou via
CLI/arquivo local (ex: `pen.dev`). Se a ferramenta escolhida não estiver
disponível nesta sessão (conector não autorizado, ou autorizado mas ainda não
carregado — isso exige uma sessão nova depois da autorização), não trave o
resto do trabalho: avise o usuário que a atualização daquele artefato ficou
pendente, continue orientando o processo normalmente, e ofereça retomar assim
que as ferramentas estiverem acessíveis.

## O que o conductor nunca faz

- Nunca invoca `wayfinder`, `to-spec` ou `grill-with-docs` por conta própria —
  mecanicamente não consegue, e não deveria mesmo se conseguisse.
- Nunca edita o frontmatter de outra skill (ex: pra remover
  `disable-model-invocation`).
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
