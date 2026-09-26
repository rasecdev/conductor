# Leitura de estado manual (plano B)

Lida quando `scripts/state.sh` falha (erro, saída que não é JSON, `bash`
indisponível). Colete à mão os mesmos sinais, grupo a grupo, e siga o
`SKILL.md` normalmente usando o que encontrou no lugar de cada campo. Um valor
que não der pra obter é "indisponível", nunca presumido.

| Campo | Como obter à mão |
|---|---|
| `convencao` | `CLAUDE.md`, `AGENTS.md` e `.claude/CLAUDE.md` na raiz; regras de outro assistente: `.cursor/rules/*.mdc`, `.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`, `.windsurf/rules/*`. |
| `maturidade` | `git log` (quantos commits, primeiro e último); manifestos de projeto (`package.json`, `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle*`, `Gemfile`, `composer.json`, `*.sln`, `*.csproj`); volume de arquivos de código. |
| `tipo_projeto` | Dependências de frontend/mobile/desktop no manifesto (React, Vue, Angular, Flutter, React Native, Electron, WinForms/WPF/MAUI), pastas `android/`/`ios/`; dependências de servidor/bot (Express, Fastify, NestJS, `Microsoft.NET.Sdk.Web`, bibliotecas de bot). |
| `pipeline` | Spec: `PRODUCT.md`, `TECH.md`, `SPEC.md`, `PRD.md`, `docs/spec*.md`, `specs/*.md`. Planejamento: `tasks/plan.md`, `tasks/todo.md`, `tasks/issues/*.md`, `PLANO.md`, `PROGRESSO.md`, `ROADMAP.md`, `development_plan.md`, `TODO.md` — e as caixinhas abertas/marcadas em cada um. Glossário: `CONTEXT.md`. ADRs: `docs/adr/`. |
| `git` | Branch atual, branches locais; PRs abertas com `gh pr list` (sem remote ou sem `gh` = indisponível). |
| `gates` | Ver `references/gate-types.md` → "Como saber se um gate existe": ferramentas da tabela citadas em scripts (`package.json` → `scripts`, `Makefile`, `justfile`, `scripts/*.sh`), CI (`.github/workflows/`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `bitbucket-pipelines.yml`) e hooks (`.husky/`, `.pre-commit-config.yaml`, `lefthook.yml`, `.git/hooks/pre-commit`/`pre-push`); última run de CI com `gh run list --branch <branch> --limit 1`; precedente nos repositórios irmãos (pastas vizinhas com `.git` ou `package.json`). |

A mesma regra da saída do script vale aqui: o que você encontrou é mapa do que
abrir, nunca conclusão de que uma etapa está completa.
