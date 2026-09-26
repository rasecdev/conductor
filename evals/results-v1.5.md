# Resultado do eval — v1.5 (enxugar o contexto)

Spec: [#50](https://github.com/rasecdev/conductor/issues/50). Rodada de
refatoração: nenhum comportamento novo; o critério é nenhum caso piorar e o
custo por run cair. Formato oficial do `skill-creator` (`run-N` +
`grading.json` + `timing.json`). Workspace: `conductor-workspace/iteration-10`
(smoke) e `iteration-11` (regressão), fora do repositório. Números por run em
`evals/benchmarks/v1.4.json` e `v1.5.json`, gerados por
`scripts/benchmark_summary.py`.

- **with_skill** lê o `SKILL.md` do clone de trabalho (`development` em
  `b97ba7b`, T1 a T7b mergeadas).
- **Sem baseline sem skill nesta rodada** (decisão da spec, para caber no
  custo): a configuração sem skill não depende do `conductor`; a comparação é
  `with_skill` v1.5 × `with_skill` v1.4 (iteração 8; caso 16 da iteração 9).
- 1 run por caso; 3 runs em `skill-evaluation`, o único gatilho de julgamento.
- Assertions iguais às da v1.4; as do caso novo (17) fixadas antes da run.
- Cada caso com estado rodou numa fixture isolada. Nenhuma run alterou fixture
  ou projeto irmão (`git status` limpo em todas).

## Regressão completa (iteration-11)

| # | Caso | v1.4 | v1.5 | Tokens v1.4 | Tokens v1.5 |
|---|---|---|---|---|---|
| 0 | `fresh-project` | 4/4 | 4/4 | 68.954 | 63.977 |
| 1 | `mature-feature` | 4/4 | 4/4 | 73.286 | 66.758 |
| 2 | `skill-evaluation` (3 runs) | 4/4 | 4/4 ×3 | 68.100 | 62.931 / 63.293 / 64.996 |
| 3 | `legacy-project` | 4/4 | 4/4 | 79.350 | 67.169 |
| 4 | `board-tool-precedent-non-notion` | 4/4 | 4/4 | 72.124 | 72.343 |
| 5 | `board-tool-first-ask` | 3/3 | 3/3 | 71.671 | 63.049 |
| 6 | `board-tool-refusal-remembered` | 3/3 | 3/3 | 68.717 | 66.317 |
| 7 | `board-tool-precedent-mismatch` | 3/3 | 3/3 | 68.992 | 62.229 |
| 8 | `non-board-artifact-staleness` | 3/3 | 3/3 | 70.918 | 69.765 |
| 9 | `headless-project-no-ui-recommendation` | 3/3 | 3/3 | 69.263 | 64.389 |
| 10 | `quality-gate-expected-missing` | 4/4 | 4/4 | 70.001 | 72.327 |
| 11 | `quality-gate-low-confidence` | 3/3 | 3/3 | 67.129 | 63.620 |
| 12 | `quality-gate-failing` | 4/4 | 4/4 | 69.446 | 68.254 |
| 13 | `quality-gate-ci-unverifiable` | 5/5 | 5/5 | 69.399 | 65.821 |
| 14 | `quality-gate-not-triggered` | 4/4 | 4/4 | 71.019 | 67.031 |
| 15 | `quality-gate-setup-offered-not-executed` | 4/4 | 4/4 | 72.632 | 68.356 |
| 16 | `tasks-without-acceptance-criteria` | 5/5 | 5/5 | — | 64.820 |
| 17 | `combined-legacy-with-live-artifact` (novo) | — | 4/4 | — | 76.498 |

- **Nenhum caso piorou.** 20 de 20 runs com todas as assertions.
- **Tokens por run `with_skill`:** média 70,7k → **66,7k**; mediana 69,7k →
  **66,1k**. Nos 16 casos com os dois lados, a mediana cai de 69,7k para 66,5k
  (−4,6%).
- **Custo próprio da skill** (run com skill − run sem skill, 50,2k de média na
  v1.4): ≈ 20,5k → **≈ 16,5k (−20%)**.
- **Mais caros:** casos 4 (+0,2k) e 10 (+2,3k). Nos dois, vários gatilhos
  disparam e a run lê 3–4 referências; é o custo esperado de carga sob demanda
  (mais barato no caso comum, um pouco mais caro quando muito se aplica).
- Duração: 43 s a 91 s por run (mediana 61 s).

### Gatilhos observados

| Referência | Lida em | Esperado |
|---|---|---|
| `project-without-convention.md` | 0, 3, 11, 15, 17 | sem `CLAUDE.md`/`AGENTS.md` |
| `project-type.md` | 17 | `sinais_ui` preenchido antes de recomendar artefato/gate de UI |
| `live-artifacts.md` | 4, 6, 7, 8, 10, 12, 14, 17 | `artefatos` preenchido ou ferramenta citada |
| `skill-evaluation.md` | 2 (×3) | usuário propõe skill |
| `gate-details.md` | 1, 4, 8, 10, 12, 13, 14, 15, 17 | gate configurado, irmão, artefato ou convenção que exige gate |

Nenhuma referência foi lida fora do gatilho; nenhuma foi pulada quando o
gatilho valia.

## Tamanho (caracteres, sem CR)

| | v1.4 | v1.5 |
|---|---|---|
| `SKILL.md` | 29.781 (30.257 com CRLF) | **14.232 (−52%)** |
| Carga fixa (`SKILL.md` + `pipeline-stages.md` + `gate-types.md`) | 36.211 | **19.975 (−45%)** |

## Custo da validação

| Etapa | Runs | Tokens |
|---|---|---|
| Smoke test (iteration-10, antes da T7b) | 4 | 271k |
| Regressão completa (iteration-11, 3 lotes) | 20 | 1,33M |
| **Total** | 24 | **≈ 1,6M** (v1.4: ≈ 1,9M) |

## Medição de projeto real (dogfooding)

Pendente de aprovação do usuário no momento da escrita. Ver a issue #58.

## Observações

- **Contas reais nos evals.** Os casos 4 e 7 usam o conector de Miro da sessão
  e listam boards reais do usuário. Já acontecia na v1.4. As respostas brutas
  ficam só no workspace; os benchmarks versionados têm só números.
- **Diagrama em `.html`** não entra em `artefatos.arquivos_de_artefato` (a
  extensão é ambígua); é achado pela menção no arquivo de progresso, que é
  como o artefato fica registrado. Caso 8 passou assim.
- **Pergunta única de ferramenta** (Passo 6 com `artefatos` vazio) apareceu nos
  casos 0, 1, 3, 5, 9, 11, 13, 15, 16 e 17 (neste, para fluxo de tela), sempre ao fim
  da resposta, sem atrapalhar a recomendação.

## Conferência da spec #50

| Story | Evidência |
|---|---|
| 1 | Carga fixa −45%; custo próprio da skill −20% por run |
| 2 | Regressão: nenhum caso piorou |
| 3 | `artefatos` vazio → `live-artifacts.md` não lida (casos 0, 1, 3, 5, 9, 11, 13, 15, 16) |
| 4 | Artefato registrado → desatualização checada (casos 8, 17) |
| 5 | Registrar/escolher ferramenta está no gatilho do Passo 6; pergunta única no `SKILL.md` (caso 5) |
| 6 | `skill-evaluation.md` só no caso 2, 3/3 runs iguais |
| 7 | Passo 7 roda sempre; invariantes no `SKILL.md` (casos 10–15) |
| 8 | `gates.ferramentas.configurados`; teste do script (`gate-sem-hook`, `lint-falhando`) |
| 9 | `gates.ultima_run_ci` com data ou `indisponivel` |
| 10 | `indisponivel` com motivo; caso 13 reporta "não verificado" |
| 11 | `maturidade` (commits, manifestos, código); casos 3 e 17 |
| 12 | `tipo_projeto` (sinais de UI e headless); casos 9 e 17 |
| 13 | `convencao` lista CLAUDE/AGENTS/Cursor/Copilot/Windsurf; caso 3 |
| 14 | `pipeline` com caminho e tamanho |
| 15 | "Leia o conteúdo, não só a existência" mantido no Passo 2; caso 16 |
| 16 | `gates.irmaos`; caso 15 (confiança média) |
| 17 | Script só lê, nunca roda comando do projeto (cabeçalho e `gate-details.md`) |
| 18 | Bash sem `jq` nem dependência nova; CI em Ubuntu e uso em Git Bash |
| 19 | Cada fonte que falha vira `indisponivel`; exit 0 |
| 20 | Ferramentas lidas da tabela de `gate-types.md` (linha `ruff` testada na T2) |
| 21 | Tokens antes/depois nesta página e em `evals/benchmarks/` |
| 22 | Dogfooding: ver seção acima |
| 23 | Job `state-script` no CI, 18 casos de fixture + teste negativo |
| 24 | Duplicações removidas (T7): roteador estático, precedência da convenção, avaliação de skill |
| 25 | ADR 0002 → "Consequences": rodadas seguintes nascem no formato enxuto |
| 26 | `project-without-convention.md` → mineração (casos 3 e 17) |
| 27 | Mesma referência → convenção de outra ferramenta (caso 3) |
| 28 | "O que o conductor nunca faz" e invariantes do Passo 7 fora de gatilho |
| 29 | `references/manual-state.md` (plano B) |
| 30 | "A saída é mapa do que abrir, nunca conclusão" no Passo 1 |
| 31 | `live-artifacts.md` e `project-type.md` apontam o filtro de tipo; `gate-details.md` aponta a tabela |
| 32 | Validação ≈ 1,6M contra ≈ 1,9M da v1.4 |
| 33 | Toda execução de eval (smoke, lotes 1–3) com aprovação explícita |
