# Resultado do eval — v1.4 (gates de qualidade)

Spec: [#24](https://github.com/rasecdev/conductor/issues/24). Rodado no formato
oficial do `skill-creator` (camada `run-N` + `grading.json`), agregado por
`scripts.aggregate_benchmark`. Workspace: `conductor-workspace/iteration-5` a
`iteration-8` (fora do repositório).

- **Baseline** = Claude com todas as skills de SDD instaladas, **sem** o
  `conductor`. Mede se o `conductor` agrega em cima do pipeline que já existe.
- **with_skill** lê o `SKILL.md` do clone de trabalho (versão da rodada).
- Todo caso com estado roda numa fixture isolada (`scripts/prepare_fixture.sh`),
  uma cópia por run. Nenhuma run alterou fixture ou projeto irmão.
- Assertions tiradas do `expected_output` e fixadas **antes** de ler as
  respostas da iteração.

## Regressão completa (iteration-8)

16 casos × 2 configurações. Runs sem a skill dos casos 10–15 reaproveitadas das
iterações 5–7 (mesma fixture, mesmo prompt).

| # | Caso | with_skill | baseline |
|---|---|---|---|
| 0 | `fresh-project` | 4/4 | 2/4 |
| 1 | `mature-feature` | 4/4 | 4/4 |
| 2 | `skill-evaluation` | 4/4 | 3/4 |
| 3 | `legacy-project` | 4/4 | 4/4 |
| 4 | `board-tool-precedent-non-notion` | 4/4 | 4/4 |
| 5 | `board-tool-first-ask` | 3/3 | 3/3 |
| 6 | `board-tool-refusal-remembered` | 3/3 | 3/3 |
| 7 | `board-tool-precedent-mismatch` | 3/3 | 2/3 |
| 8 | `non-board-artifact-staleness` | 3/3 | 2/3 |
| 9 | `headless-project-no-ui-recommendation` | 3/3 | 3/3 |
| 10 | `quality-gate-expected-missing` | 4/4 | 1/4 |
| 11 | `quality-gate-low-confidence` | 3/3 | 1/3 |
| 12 | `quality-gate-failing` | 4/4 | 3/4 |
| 13 | `quality-gate-ci-unverifiable` | 5/5 | 4/5 |
| 14 | `quality-gate-not-triggered` | 4/4 | 4/4 |
| 15 | `quality-gate-setup-offered-not-executed` | 4/4 | 3/4 |
| | **Pass rate médio** | **100%** | **77,9%** (Δ +0,22) |

**Nenhuma regressão**: a versão v1.4 passa em todos os casos, inclusive nos 10
que existiam antes dela.

**Custo**: com a skill, cada run leva em média +27 s e cerca de 40% mais tokens
(~70k contra ~50k), por ler o `SKILL.md` e as referências.

### Onde o baseline empata

Casos 1, 3, 4, 5, 6, 9 e 14: o modelo sem a skill, com as skills de SDD
instaladas, já lê a convenção, reconhece planejamento existente e legado,
respeita precedente e recusa de board, reconhece headless e procura hooks. Nesses
comportamentos a skill não agrega diferença mensurável.

### Onde a skill faz diferença

- **Roteamento no pipeline** (caso 0): sem a skill, uma pasta vazia recebe
  orientação genérica de scaffolding, sem nenhuma skill do pipeline.
- **Gate esperado ausente** (caso 10) e **confiança pela fonte** (casos 11,
  15): sem a skill, o diagrama registrado não gera nenhuma expectativa de gate, e
  "falta lint" vira lacuna sem qualificação.
- **Aviso, não trava** (casos 12, 13): sem a skill, gate vermelho ou não
  verificado vira pré-requisito; com a skill, é aviso e a recomendação continua.
- **Precedente que não bate** (caso 7) e **apontar a ferramenta de
  regeneração** (caso 8).

## Conferência requisito por requisito (#24 → `SKILL.md`)

| Decisão de implementação (#24) | Onde está | Situação |
|---|---|---|
| Referência fixa de tipos de gate, com "quando deveria rodar" e as 4 linhas mínimas | `references/gate-types.md` | Atendido |
| Conhecimento fixo; binding do projeto vem dos Passos 1/2/6 | `gate-types.md` (introdução), Passo 7 item 1 | Atendido |
| Passo novo cruzando estágio + artefatos com a referência | Passo 7 | Atendido |
| Verificação real: local, CI com data, "não verificado" | Passo 7 item 4 | Atendido |
| Ordem de confiança das fontes, citada na resposta | Passo 7 itens 2 e 6 | Atendido |
| Três lacunas: ausente, falhando, não acionado | Passo 7 itens 5 e 6 | Atendido |
| Setup de baixo risco só oferecido, executa com aprovação | Passo 7 (fecho) | Atendido |
| Gate vermelho avisado antes de avançar, sem travar | Passo 4 → "Gate vermelho no estágio atual" | Atendido |
| Filtro de tipo de projeto também filtra gates | Passo 7 item 1 | Atendido |
| "O que o conductor nunca faz" atualizado | Duas entradas novas | Atendido |
| Seam de eval no formato oficial, com fixtures | `evals/`, `scripts/prepare_fixture.sh` | Atendido |
| Casos mínimos (a)–(d) | Casos 10–13 (+ 14, 15) | Atendido |

## Cobertura das user stories (#24)

O gate "cada story com caso de verificação" só passa a valer na v1.5 (#25);
registrado aqui para a v1.4 mesmo assim.

| Stories | Caso(s) |
|---|---|
| 1, 14 | 10, 12 |
| 4 | 10 |
| 6 | 14 |
| 7 | 10, 11, 15 |
| 8 | 12, 13, 14 |
| 9, 10 | 14 |
| 11 | 10 (artefato), 11 (baixa), 12 e 14 (convenção), 15 (média) |
| 12, 16 | 15 |
| 13 | 10, 15 |
| 15 | 10, 11, 14, 15 (guardrails) |
| 17 | 14 — exercitada (a skill pediu a escolha da ferramenta de hook), sem assertion própria |
| 18, 19 | 12, 13 |
| 20 | 13 |
| 21 | Indireta: fixtures 12–14 são headless e nenhum gate de UI foi esperado |

**Sem cobertura por eval:**

- **2** (lista fixa na skill): decisão estrutural, conferida pela existência de
  `references/gate-types.md` — não verificável por eval.
- **3** (lista aberta cruzada com o catálogo): nenhum caso apresenta um tipo de
  artefato novo. **Lacuna real**; candidata a caso na próxima rodada.
- **5** (conformidade de arquitetura via `dependency-cruiser`/`madge`): nenhuma
  fixture tem diagrama de arquitetura + código JS/TS. **Lacuna real.**
