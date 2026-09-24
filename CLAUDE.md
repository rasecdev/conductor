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

Não há `PRODUCT.md`/`TECH.md` neste repositório: a spec do v1 vive como issue
no tracker (ver abaixo), não como arquivo checked-in — decisão tomada ao
publicá-la, não uma lacuna a corrigir.

## Como registrar trabalho

**Tracker é o GitHub Issues do próprio repositório (`rasecdev/conductor`), não
`tasks/todo.md`.** `tasks/plan.md` é o grafo de dependência/fases/riscos (saída
normal de `planning-and-task-breakdown`), mas cada tarefa individual é uma
issue — o texto de `tasks/plan.md` linka pra issue correspondente em vez de
duplicar critério de aceite.

- Spec de uma rodada nova: publicada como issue própria (ex.
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
  em projeto maduro com pipeline formalizado (`mature-feature`, AutoFinance),
  avaliação de skill nova proposta (`skill-evaluation`), projeto legado maduro
  sem pipeline formalizado (`legacy-project`, Contabilidade).
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
  "Implementation Decisions" da issue #1 antes de reabrir essa decisão.
- `conductor` nunca invoca `wayfinder`/`to-spec`/`grill-with-docs` por conta
  própria (bloqueio mecânico do `disable-model-invocation` dessas skills,
  reforçado como regra explícita no próprio `SKILL.md`) — não editar essas
  skills de terceiros pra contornar isso.
