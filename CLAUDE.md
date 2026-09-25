# CLAUDE.md — conductor

Convenção deste repositório. Skill global instalada em `~/.claude/skills/conductor/`
(git próprio, remote `github.com/rasecdev/conductor`, privado, identidade `rasecdev`
via override local — não é a identidade git global da máquina).

## Estrutura

- `SKILL.md` — frontmatter + processo em 6 passos (o corpo da skill).
- `references/pipeline-stages.md` — tabela de estágios do pipeline de spec
  development conhecido (`wayfinder` → `grilling`/`domain-modeling` → `to-spec`
  → `planning-and-task-breakdown` → `implement-specs` →
  `check-impl-against-spec`) e como avaliar uma skill nova proposta pra ele.
- `scripts/catalog.sh` — lista name/description/`disable-model-invocation` de
  toda skill instalada, lido dinamicamente (nunca uma lista fixa mantida à mão).
- `evals/evals.json` — casos de teste do seam de eval (ver "Como validar").
- `tasks/plan.md` — plano de tarefas ativo (ver "Como registrar trabalho").
- `SPEC.md` — spec viva: comportamento **atual** da skill, fonte de verdade do
  que ela faz (ver "Spec Driven Development").

## Spec Driven Development

Decidido em 2026-09-25 (substitui a decisão anterior de manter a spec só como
issue). Modelo "spec atual + propostas de mudança" (mesmo do OpenSpec):

- `SPEC.md` = estado atual, com o conteúdo de PRD (problema, objetivos e
  critérios de sucesso, user stories) e as decisões técnicas e de teste. Não
  há `PRD.md`/`PRODUCT.md`/`TECH.md` separados — o mesmo "o quê" em dois
  lugares diverge.
- Spec de rodada (issue) = delta. **Toda spec de rodada nova passa pelo
  `/to-spec`** (digitado pelo usuário — é skill manual), nunca escrita
  direto em conversa.
- **Ao fechar uma rodada**: conferir cada requisito da issue de spec contra
  o `SKILL.md` (e referências/scripts tocados), requisito por requisito, antes
  de fechá-la; depois incorporar o delta ao `SPEC.md` e adicionar a linha em
  "Histórico de rodadas".
- `ROADMAP.md` continua como visão + princípio que não muda (papel de
  "constitution"), não como spec.
- **Dogfooding**: o `conductor` é usado pra conduzir o próprio
  desenvolvimento (rodar a skill pra decidir o próximo passo neste repo). Se a
  recomendação dela estiver errada aqui, isso é defeito da skill — vira issue
  e caso de eval.

## Como registrar trabalho

**Tracker é o GitHub Issues do próprio repositório (`rasecdev/conductor`), não
`tasks/todo.md`.** `tasks/plan.md` é o grafo de dependência/fases/riscos (saída
normal de `planning-and-task-breakdown`), mas cada tarefa individual é uma
issue — o texto de `tasks/plan.md` linka pra issue correspondente em vez de
duplicar critério de aceite.

- Spec de uma rodada nova: publicada como issue própria via `/to-spec` (ex.
  [issue #1](https://github.com/rasecdev/conductor/issues/1), spec do v1),
  label `ready-for-agent` quando pronta pra implementação.
- Plano pós-spec: `tasks/plan.md`, cada tarefa linkando a issue já criada
  (issues nascem junto do planejamento, não uma a uma na hora de implementar —
  mesmo princípio que o `conductor` recomenda pra outros projetos).
- Ao concluir uma tarefa: marcar a caixinha em `tasks/plan.md` e fechar a
  issue correspondente (via `Closes #N` no commit, ou manualmente quando o
  commit não referencia a issue).

## Fluxo de commit (estado atual: sem branch/PR por tarefa)

As duas tarefas feitas até aqui (`feat: skill inicial do conductor`,
`docs: adiciona plano de tarefas pos-spec v1`) foram commitadas direto em
`master` — projeto solo, sem CI configurado ainda, sem exigência de revisão
externa. **Esse é o padrão real até este ponto, não uma decisão formal de
"nunca usar branch/PR".** Se o repositório ganhar CI ou colaboração externa no
futuro, formalizar branch por tarefa + PR nesse momento, não antes.

## Como validar (seam de eval)

Validação é via framework de eval do `skill-creator`, não teste unitário:

- Roda um subagente com a skill carregada (`with_skill`) contra um subagente
  baseline (sem a skill), ambos contra os mesmos prompts de `evals/evals.json`,
  em paralelo (nunca sequencial).
- Cada caso em `evals/evals.json` tem um `expected_output` em prosa (o que a
  resposta precisa demonstrar), avaliado por comparação `with_skill` vs.
  baseline — não por assertion determinística de string.
- 4 casos cobertos no v1: projeto novo do zero (`fresh-project`), feature nova
  em projeto maduro com pipeline formalizado (`mature-feature`), avaliação de
  skill nova proposta (`skill-evaluation`), projeto legado maduro sem pipeline
  formalizado (`legacy-project`).
- **Pendência conhecida (Tarefa 3 do plano ativo):** essas 4 iterações foram
  rodadas manualmente durante o desenvolvimento da spec, não pelos scripts
  oficiais do `skill-creator` — automatizar isso é trabalho futuro, não
  reprocessar os casos já validados.
- Ao adicionar um passo/comportamento novo ao `SKILL.md`, adicionar o caso
  correspondente em `evals/evals.json` antes de considerar o trabalho
  concluído, seguindo o mesmo formato dos 4 existentes.

## O que nunca mudar sem decisão explícita

- Frontmatter sem `disable-model-invocation` — a skill só informa/recomenda,
  sem efeito colateral irreversível, por isso pode ser auto-invocável. Ver
  "Implementation Decisions" do `SPEC.md` antes de reabrir essa decisão.
- `conductor` nunca invoca `wayfinder`/`to-spec`/`grill-with-docs` por conta
  própria (bloqueio mecânico do `disable-model-invocation` dessas skills,
  reforçado como regra explícita no próprio `SKILL.md`) — não editar essas
  skills de terceiros pra contornar isso.
