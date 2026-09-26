# Artefatos vivos do processo

Lida pelo Passo 6 do `SKILL.md` quando `artefatos` na saída do script de
estado tem menção ou arquivo de artefato (diagrama, documento de QA) (há artefato ou recusa registrados:
checar desatualização e qual ferramenta usar), ou quando o usuário vai
registrar um artefato ou escolher ferramenta para um.

Filtro de que esta referência depende: o tipo de projeto. Fluxo de tela e
design de UI só são recomendados para projeto com UI — `tipo_projeto` na saída
do script e, quando ele não decide sozinho, `references/project-type.md`.

Um projeto pode ter vários **artefatos vivos** — representações visuais ou
estruturadas de decisões do processo de spec, que devem acompanhar uma fonte
de verdade no repositório. O board de fases (o mais comum) é só um deles.
Outros exemplos, conforme o pipeline instalado e o tipo de projeto (filtro acima):

| Artefato | O que registra | Fonte de verdade que acompanha |
|---|---|---|
| Board de fases | Estágio atual, dependência de tarefas | `tasks/plan.md`, milestones/issues |
| Diagrama de arquitetura | Componentes, serviços, fluxo de dados | `PLANO.md`, `docs/adr/` |
| Fluxo de tela / design de UI | Navegação entre telas, design visual | Decisões do spec (`to-spec`: User Stories, Implementation Decisions) — só relevante se o projeto tiver UI (filtro acima) |
| Artefatos de QA/teste | Test plan, casos de teste, matriz de rastreabilidade | Decisões de teste do spec (`to-spec`: Testing Decisions) |

Essa lista **não é fechada** — cruze com o catálogo dinâmico do Passo 3: uma
skill nova de geração de artefato que entrar no pipeline (arquitetura, fluxo
de tela, QA, ou outro tipo) é candidata a virar uma linha nova aqui. Pra
qualquer um desses tipos, a ferramenta que hospeda não é fixa — pode ser
Notion, Miro, Figma, um arquivo no próprio repositório, ou qualquer outra que
sirva ao mesmo propósito. Nenhuma é a recomendada por definição; a escolha de
ferramenta (e onde o arquivo-fonte fica) é sempre do usuário.

## Qual ferramenta usar (mesmo processo pra qualquer tipo de artefato)

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
     (`artefatos.mencoes` aponta as linhas de `PROGRESSO.md`/`CLAUDE.md` que citam artefato ou recusa) — a pergunta é
     por projeto e por tipo, não é feita de novo só porque a sessão mudou.

## Estrutura do board de fases, uma vez que haja ferramenta

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

## Detectar desatualização (qualquer artefato registrado, não só board)

Ao ler `PLANO.md`/`docs/adr/`/`tasks/plan.md`/spec (Passo 2 do `SKILL.md`), para cada
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

## Degradação

As ferramentas chegam via conector MCP (ex: `plugin:design:notion` pra
Notion, ou o que estiver instalado pra Miro/Figma/ClickUp Docs/outra) ou via
CLI/arquivo local (ex: `pen.dev`). Se a ferramenta escolhida não estiver
disponível nesta sessão (conector não autorizado, ou autorizado mas ainda não
carregado — isso exige uma sessão nova depois da autorização), não trave o
resto do trabalho: avise o usuário que a atualização daquele artefato ficou
pendente, continue orientando o processo normalmente, e ofereça retomar assim
que as ferramentas estiverem acessíveis.
