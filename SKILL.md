---
name: conductor
description: Orients any project through a spec-development pipeline (discovery/wayfinder → sharpen/grilling/domain-modeling → formal spec/to-spec → task breakdown → implementation → review — exact skill names vary by installed pipeline) — reads project state and project-specific conventions, says exactly where things stand and what the next skill to run is, maintains a live board structure (project page → phase pages with task-dependency diagrams, in whichever tool the project uses or none) for the project's spec history, and evaluates whether a newly proposed skill belongs in the pipeline or duplicates one already in use (including static prose routers like ask-matt). Use this whenever the user starts a new project or a new feature in an existing one, asks "onde estamos" / "what's next" / "qual skill eu chamo agora", is about to write tasks or a spec without having gone through discovery first, mentions wanting to organize or track the spec process, or proposes adding a new skill to this workflow — even if they don't name "conductor" explicitly.
---

# Conductor

Um regente não toca instrumento nenhum — ele organiza a ordem em que cada
seção entra, e sabe a partitura inteira de cor. É esse o papel desta skill no
processo de spec development: não escreve a spec, não interroga o usuário,
não implementa nada — ela sabe em que ponto do processo cada projeto está, diz
qual é o próximo instrumento a entrar, e mantém o registro de tudo isso vivo
no Notion.

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

## Passo 6 — Manter a estrutura no board vivo do processo de spec

Cada projeto pode ter um board vivo do processo de spec, mas a ferramenta que
hospeda isso não é fixa — pode ser Notion, Miro, ClickUp Docs, ou qualquer
outra que sirva ao mesmo propósito. Nenhuma delas é a recomendada por
definição; a escolha é do usuário e do que já estiver em uso no projeto.

### Qual ferramenta usar

1. **Precedente do projeto.** Cheque primeiro se o projeto já tem uma
   ferramenta registrada — uma menção em `PROGRESSO.md`/`CLAUDE.md`, um link
   pra página/board já existente, ou o próprio uso ao longo da conversa. Se
   houver, use essa ferramenta sem perguntar de novo.
   - **Precedente que não bate com a realidade** (ex: o link/nome registrado
     não é encontrado pelo conector, ou a busca não retorna o board/página
     esperado): não trave pedindo só uma confirmação de identidade. Liste os
     boards/páginas que a busca real *encontrou* nessa ferramenta e pergunte
     ao usuário se algum deles é o certo — ou se nenhum é, seguindo então
     pro passo 2 (nenhum precedente utilizável) a partir daí.
2. **Nenhum precedente: detectar o que está disponível.** Verifique quais
   MCPs/conectores de board ou documentação estão disponíveis nesta sessão
   (Notion, Miro, ClickUp Docs, etc.) — mesmo princípio do catálogo dinâmico
   de skills do Passo 3, não mantenha uma lista fixa de cabeça. Se exatamente
   um estiver disponível e conectado, use-o. Se mais de um estiver disponível
   e não houver precedente, pergunte ao usuário qual prefere.
3. **Nenhuma ferramenta disponível nem precedente registrado.** Pergunte ao
   usuário, **uma única vez por projeto**, se ele usa alguma ferramenta desse
   tipo (Notion, Miro, etc.) pra acompanhar o processo de spec.
   - Se responder que sim: use a ferramenta indicada assim que o conector
     correspondente estiver acessível (mesma degradação descrita no fim desta
     seção).
   - Se responder que não usa e não quer usar: registre essa decisão de forma
     persistente **no projeto alvo** (nunca no `conductor`) — por exemplo uma
     nota curta em `PROGRESSO.md` ou `CLAUDE.md` do projeto ("processo de spec
     não usa board externo, decidido em `<data>`"). A partir daí, nunca mais
     pergunte isso *naquele projeto* — continue orientando o processo
     normalmente, só sem a parte de board.
   - Antes de perguntar, sempre confira se essa decisão já foi registrada
     (Passo 1/2 já leem `PROGRESSO.md`/`CLAUDE.md` do projeto) — a pergunta é
     por projeto, não é feita de novo só porque a sessão mudou.

### Estrutura, uma vez que haja ferramenta

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

**Detectar mudança de arquitetura ou fluxo já mapeado.** Ao ler
`PLANO.md`/`docs/adr/` (Passo 2), preste atenção não só ao estágio atual, mas
a se algo que já está representado no board mudou desde a última vez — uma
decisão de arquitetura revista, um ADR novo que substitui/altera um anterior,
ou um fluxo (diagrama de fase, dependência de tarefas) que não bate mais com o
que o `tasks/plan.md` ou o `PLANO.md` descrevem agora. Sinais disso: um ADR
com data mais recente que a última atualização da página/nó correspondente no
board, ou uma seção do `PLANO.md` que diverge do que está registrado ali.

Quando notar isso, avise o usuário e pergunte se quer atualizar a página/nó
correspondente na ferramenta em uso — nunca edite sozinho. Mesmo critério de
tamanho da "página esporádica": mudança pontual vira nota na página da fase
atual; mudança grande/estrutural vira sugestão de subpágina dedicada. A
decisão de atualizar ou não, e como, continua sendo do usuário.

### Degradação

As ferramentas chegam via conector MCP (ex: `plugin:design:notion` pra
Notion, ou o que estiver instalado pra Miro/ClickUp Docs/outra). Se a
ferramenta escolhida não estiver disponível nesta sessão (conector não
autorizado, ou autorizado mas ainda não carregado — isso exige uma sessão
nova depois da autorização), não trave o resto do trabalho: avise o usuário
que a atualização do board ficou pendente, continue orientando o processo
normalmente, e ofereça retomar a atualização assim que as ferramentas
estiverem acessíveis.

## O que o conductor nunca faz

- Nunca invoca `wayfinder`, `to-spec` ou `grill-with-docs` por conta própria —
  mecanicamente não consegue, e não deveria mesmo se conseguisse.
- Nunca edita o frontmatter de outra skill (ex: pra remover
  `disable-model-invocation`).
- Nunca cria uma página/nó no board sem perguntar primeiro, fora da página de
  projeto e de fase que já são esperadas.
- Nunca atualiza uma página do board por causa de mudança de
  arquitetura/fluxo sem perguntar primeiro — só avisa e oferece.
- Nunca assume Notion (ou qualquer outra ferramenta específica) como padrão
  do projeto sem checar precedente ou perguntar — nem insiste numa ferramenta
  depois que o usuário já disse que não usa/não quer usar board nenhum.
- Nunca decide sozinho qual skill "vence" quando o usuário está comparando
  duas — recomenda, não decide.
- Nunca dispara uma avaliação quantitativa (via `skill-creator`) sem pedido
  explícito ou aprovação — só oferece quando a comparação por leitura ficar
  ambígua.
