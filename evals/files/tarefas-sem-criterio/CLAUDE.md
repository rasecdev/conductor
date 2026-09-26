# CLAUDE.md — NotasAPI

API de notas pessoais (headless, Node/TS). Spec em `docs/spec.md`, plano de
tarefas em `tasks/plan.md`.

## Fluxo

- Toda feature nova tem spec publicada via `to-spec` antes de virar tarefa.
- Tarefas são rastreadas como issues. Sem acesso ao tracker, o corpo de cada
  issue fica espelhado em `tasks/issues/<número>.md`.
- Cada tarefa em branch própria (`feat/<slug>`), PR contra `development`.
