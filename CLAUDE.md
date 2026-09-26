# CLAUDE.md — conductor

Convenção deste repositório. Remote `github.com/rasecdev/conductor`, público,
licença MIT, identidade `rasecdev` via override local em cada clone — não é a
identidade git global da máquina.

## Estrutura

- `SKILL.md` — frontmatter + processo em 7 passos (o corpo da skill).
- `references/gate-types.md` — gate de qualidade esperado por artefato/estágio
  (Passo 7).
- `references/pipeline-stages.md` — tabela de estágios do pipeline de spec
  development conhecido (`wayfinder` → `grilling`/`domain-modeling` → `to-spec`
  → `planning-and-task-breakdown` → `implement-specs` →
  `check-impl-against-spec`) e como avaliar uma skill nova proposta pra ele.
- `references/project-without-convention.md`, `references/project-type.md`,
  `references/manual-state.md`, `references/skill-evaluation.md`,
  `references/live-artifacts.md` — casos
  condicionais (Passos 1, 5 e 6) e plano B da
  leitura de estado, lidos só quando o gatilho no `SKILL.md` dispara
  (`docs/adr/0002-carga-sob-demanda.md`).
- `scripts/state.sh` — sinais mecânicos do projeto alvo em JSON (Passos 1, 2
  e 7); testado por `scripts/test_state.sh` contra `evals/state-expected/`.
- `scripts/catalog.sh` — lista name/description/`disable-model-invocation` de
  toda skill instalada, lido dinamicamente (nunca uma lista fixa mantida à mão).
- `evals/evals.json` — casos de teste do seam de eval (ver "Como validar").
- `tasks/plan.md` — plano de tarefas ativo (ver "Como registrar trabalho").
- `SPEC.md` — spec viva: comportamento **atual** da skill, fonte de verdade do
  que ela faz (ver "Spec Driven Development").
- `CONTEXT.md` — glossário do domínio (termo canônico + termos a evitar). Usar
  esse vocabulário em specs, tarefas e na própria skill.

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
- **Tarefas de uma rodada saem da `planning-and-task-breakdown`**, nunca
  escritas à mão: fatias verticais, cada uma com Acceptance criteria +
  Verification e as user stories da spec que cobre.
- **Ao fechar uma rodada**: conferir cada requisito da issue de spec contra
  o `SKILL.md` (e referências/scripts tocados), requisito por requisito, antes
  de fechá-la; depois incorporar o delta ao `SPEC.md` e adicionar a linha em
  "Histórico de rodadas".
- `ROADMAP.md` continua como visão + princípio que não muda (papel de
  "constitution"), não como spec.
- **Dogfooding — o `conductor` é sempre usado**, sem esperar ser chamado:
  roda no início de cada pedido novo, de cada tarefa e em cada checkpoint,
  antes de decidir o próximo passo neste repo. Se a recomendação dele estiver
  errada aqui, isso é defeito da skill — vira issue (label `bug`) e caso de
  eval (ex: [#27](https://github.com/rasecdev/conductor/issues/27)).
- Decisões difíceis de reverter ficam em `docs/adr/`.

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

## Clone de trabalho × instalação

- **Instalação**: `~/.claude/skills/conductor/` — é a skill que roda em todos
  os projetos. Fica sempre em `master` e só muda por `git pull`. Nunca
  desenvolver nem fazer checkout de outra branch aqui: a skill instalada
  mudaria na hora, pra todo projeto.
- **Clone de trabalho**: `S:\Trampo\conductor` — onde todo desenvolvimento
  acontece.
- **Evals** rodam contra o `SKILL.md` do clone de trabalho (a versão em
  desenvolvimento), nunca contra a instalação. O dogfooding, ao contrário, usa
  a instalação: a versão estável conduz o desenvolvimento da próxima.

## Fluxo de branch e PR

Formalizado em 2026-09-25 na rodada infra (seguindo o precedente do
AutoFinance). Branches: `master` = versão instalada; `development` =
integração.

Por tarefa:

1. Branch a partir de `development`: `<tipo>/<slug-curto>` (`feat/`, `fix/`,
   `chore/`, `docs/`, `test/`) — sem número de tarefa no nome.
2. Implementar conforme o critério de aceite da tarefa e marcar a caixinha em
   `tasks/plan.md` **no mesmo PR**.
3. Push e PR **contra `development`**, corpo com o que foi feito e
   `Closes #<issue>`.
4. CI verde (`gitleaks`, `shellcheck`, `evals`, `markdownlint`) → merge
   (merge commit, não squash) sem pedir aprovação a cada PR. Como
   `development` não é a branch padrão, `Closes #N` não fecha a issue no
   merge: fechar manualmente logo depois.

**Promoção `development` → `master` nunca é automática**: só com decisão
explícita do usuário. Depois dela, `git pull` na instalação e rodar
`scripts/catalog.sh` lá pra confirmar que a skill instalada funciona.

Fora do ciclo de tarefa (mudança pontual), commit/PR/merge exigem pedido
explícito.

## Como validar (seam de eval)

Validação é via framework de eval do `skill-creator`, não teste unitário:

- Roda um subagente com a skill carregada (`with_skill`) contra um subagente
  baseline (sem a skill), ambos contra os mesmos prompts de `evals/evals.json`,
  em paralelo (nunca sequencial).
- Cada caso em `evals/evals.json` tem um `expected_output` em prosa (o que a
  resposta precisa demonstrar), avaliado por comparação `with_skill` vs.
  baseline — não por assertion determinística de string.
- Lista de casos cobertos: `SPEC.md` → "Testing Decisions" (não duplicar
  aqui).
- Scripts oficiais do `skill-creator` (`scripts.aggregate_benchmark`,
  `eval-viewer/generate_review.py --static`) validados contra as iterações do
  v1 em `conductor-workspace/` ([#4](https://github.com/rasecdev/conductor/issues/4)).
  Exigem o layout oficial (camada `run-N` entre config e `grading.json`) e
  `grading.json` formal — nota livre é pulada pelo script. **Gravar toda
  rodada nesse formato desde o início.** As rodadas v1.1–v1.3 foram rodadas
  manualmente (`evals/results-*.md`), fora desse formato.
- **Casos com fixture**: o prompt usa o marcador `<FIXTURE_DIR>`; antes de
  cada run, `bash scripts/prepare_fixture.sh <nome>` copia `evals/files/<nome>`
  para um diretório temporário exclusivo, com git próprio, e imprime o caminho
  que substitui o marcador. Se o caso tiver `fixture_siblings`, passe-as
  depois do nome (`prepare_fixture.sh <nome> <irmã>...`): cada uma vira um
  projeto irmão com git próprio no mesmo diretório pai. Estado que não cabe
  em arquivo (histórico longo, pasta sem git) vem de um `.fixture-setup.sh` na
  fixture — ver o cabeçalho de `scripts/prepare_fixture.sh`. Uma cópia por run — nunca rodar direto em
  `evals/files/` (herdaria o git do conductor e veria as outras fixtures como
  projetos irmãos).
- Ao adicionar um passo/comportamento novo ao `SKILL.md`, adicionar o caso
  correspondente em `evals/evals.json` antes de considerar o trabalho
  concluído, seguindo o mesmo formato dos existentes.

## O que nunca mudar sem decisão explícita

- Frontmatter sem `disable-model-invocation` — a skill só informa/recomenda,
  sem efeito colateral irreversível, por isso pode ser auto-invocável. Ver
  "Implementation Decisions" do `SPEC.md` antes de reabrir essa decisão.
- `conductor` nunca invoca `wayfinder`/`to-spec`/`grill-with-docs` por conta
  própria (bloqueio mecânico do `disable-model-invocation` dessas skills,
  reforçado como regra explícita no próprio `SKILL.md`) — não editar essas
  skills de terceiros pra contornar isso.
