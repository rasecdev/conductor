# CLAUDE.md — FinanceBot

Bot financeiro pessoal (headless). Design em `PLANO.md`, plano de tarefas em
`tasks/plan.md`.

## Fluxo de implementação

- Cada fase do `PLANO.md` vira um milestone no GitHub; cada tarefa do
  `tasks/plan.md` vira uma issue nesse milestone, criada junto do planejamento.
- Toda tarefa nasce em branch própria (`feat/<slug>`) com PR contra
  `development`; CI verde antes do merge.
- Tarefas são geradas pela skill `planning-and-task-breakdown`.
