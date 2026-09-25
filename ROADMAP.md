# Roadmap — visão de longo prazo

Registrado em 2026-09-25, a partir de uma conversa sobre até onde o
`conductor` pode crescer. Isso não é um plano de tarefas (isso vive em
`tasks/plan.md`, por rodada) — é a visão que justifica a direção das rodadas
futuras, pra não se perder entre sessões.

## A ideia central

> A skill resolve o problema orquestrando o passo a passo da solução — nunca
> sendo ela mesma quem executa o passo.

O `conductor` começou resolvendo uma lacuna estreita (saber em que estágio do
processo de spec um projeto está). Mas o princípio por trás dele — ler estado
real, detectar lacuna, recomendar a peça certa sem nunca decidir/implementar
por conta própria — generaliza pra qualquer parte do fluxo de codificação, não
só spec. Cada nova categoria de problema (arquitetura desatualizada, gate de
qualidade ausente, artefato de UI sem dono) não é um problema novo pro
`conductor` resolver sozinho — é mais um passo pra ele **orquestrar**,
apontando pra skill/ferramenta certa.

### Definição da skill (2026-09-25)

> O foco do `conductor` é conduzir o usuário a criar, manter e melhorar a sua
> pipeline — para qualquer projeto, em qualquer momento dele.

Isso vale pra pipeline de spec, de artefato ou de qualidade — o tipo não
importa, o padrão é sempre o mesmo: identificar o que falta ou ficou pra trás,
e conduzir o usuário até a peça certa pra resolver. O `conductor` nunca é quem
cria, mantém ou melhora a pipeline por conta própria. Essa é a definição
operacional da skill, não só uma aspiração — é o teste pra qualquer feature
nova: se ela faz o `conductor` **criar/implementar** algo, não pertence a ele
— pertence à skill que ele deveria estar apontando.

## Onde isso já chegou (v1.0 → v1.3)

- v1.0: orienta o pipeline de spec (descoberta → sharpen → spec → tarefas →
  implementação → revisão).
- v1.1: board de acompanhamento agnóstico de ferramenta (Notion/Miro/outro).
- v1.2: qualquer artefato vivo do projeto (não só board) é registrado e
  checado contra sua fonte de verdade, pra nunca ficar desatualizado em
  silêncio.
- v1.3: recomendação de artefato passa a considerar o tipo de projeto (UI vs.
  headless) — não empurra fluxo de tela pra um microsserviço sem tela.

## Para onde isso pode ir

O `conductor` pode crescer até se tornar o orquestrador de uma **fábrica de
organização do fluxo de codificação inteiro**, totalmente adaptativa ao
projeto — não um conjunto fixo de etapas, mas um conjunto que cresce conforme
o catálogo de skills/ferramentas disponíveis cresce. Direções já identificadas
(nenhuma implementada ainda, ordem não é prioridade):

- **Gates de qualidade** (v1.4, em planejamento): verificar se cada etapa da
  pipeline tem um gate correspondente configurado no projeto (lint, teste,
  build, arquitetura via dependency-cruiser/madge, etc.), rodar o que já
  existe pra ler o estado real (passou/falhou), e sinalizar lacuna — nunca
  criar o gate sozinho, exceto como setup inicial de baixo risco quando não
  há nenhum e existe precedente claro (organizacional ou de projeto novo).
- **Padronização de código** (formatação, nomenclatura de variável, convenção
  de estilo): fica **fora do escopo do conductor** — isso já é resolvido por
  ferramenta determinística de projeto (ESLint/Prettier), não por uma skill de
  orientação. O `conductor` no máximo detecta ausência dessa ferramenta como
  gate faltando (ver item acima), nunca reimplementa o que o linter já faz
  melhor.
- **Precedente organizacional entre projetos**: quando um projeto novo não
  tem convenção própria nem artefato apontando pra um gate/padrão, comparar
  contra outros projetos do mesmo usuário/organização (não só o histórico do
  próprio repo, como já faz hoje) pra inferir convenção real — com confiança
  menor que precedente explícito, mas maior que benchmark genérico de
  mercado.

## Princípio que não muda

Não importa quantas categorias novas entrem (gate, artefato, estilo,
deploy, o que vier): o `conductor` nunca vira quem **implementa** a validação
ou o artefato. Ele lê estado, detecta lacuna, e aponta a skill/ferramenta
certa — a decisão de agir, e como, continua sempre do usuário (ou da skill
específica que ele aciona). Ver "O que o conductor nunca faz" no `SKILL.md`.
