# Estágios do pipeline de spec development

Ordem de referência pra classificar uma skill (existente ou nova) num ponto do
fluxo de "ideia solta" até "código em produção revisado". Isso é um ponto de
partida pra comparação, não uma lista fechada — uma skill nova pode não
encaixar em nenhum estágio existente, ou pode justificar um estágio novo.

**Os nomes de skill abaixo são um exemplo, não uma lista fechada.** Pipelines
diferentes usam nomes diferentes pro mesmo estágio (ex: "quebra em tarefas"
chama `planning-and-task-breakdown` num pipeline e `to-tickets` noutro;
"implementação" pode já embutir revisão internamente, como o `/implement` do
[mattpocock/skills](https://github.com/mattpocock/skills) faz rodando
`/code-review` sozinho no final). **Nunca hardcode esses nomes como se fossem
universais** — a fonte de verdade é sempre `scripts/catalog.sh`, que lê o que
está de fato instalado. Use a tabela só pra saber em que estágio uma skill
(conhecida ou nova) se encaixa.

| # | Estágio | O que resolve | Exemplos de skill (nomes variam por pipeline) |
|---|---|---|---|
| 1 | Descoberta / decisão nebulosa | Ideia grande demais pra uma sessão, destino ainda não claro | `wayfinder` |
| 2 | Sharpen do plano / modelo de domínio | Interrogar até entendimento compartilhado; fixar vocabulário e ADRs | `grilling`, `grill-with-docs`, `domain-modeling` |
| 3 | Síntese em spec formal | Conversa/decisões viram spec publicado no tracker | `to-spec` |
| 4 | Quebra em tarefas | Spec vira tarefas pequenas com critério de aceite e verificação | `planning-and-task-breakdown`, `to-tickets` |
| 5 | Implementação | Código + testes, mantendo spec e código alinhados | `implement-specs`, `implement` |
| 6 | Revisão | PR comparado contra o spec aprovado | `check-impl-against-spec`, ou embutida na própria etapa de implementação (`/code-review` dentro de `/implement`) |

## Sobre roteadores estáticos já existentes num pipeline (ex: `ask-matt`)

Alguns pipelines já trazem sua própria skill de roteamento em prosa (ex:
`ask-matt` no [mattpocock/skills](https://github.com/mattpocock/skills) —
mapeia cenário → sequência de skills, incluindo fluxo de bug, handoff entre
sessões, decisões de fronteira de fase). O `conductor` não substitui isso, e
não deveria tentar recriar esse mapa inteiro — a diferença é que um roteador
desses é estático (a mesma prosa pra qualquer projeto), enquanto o `conductor`
lê o estado real do repositório atual (`CLAUDE.md`, `tasks/plan.md`, git log)
antes de recomendar. Se uma skill assim estiver instalada, trate-a como
referência de vocabulário do pipeline (pode até citá-la na recomendação), mas
a decisão final do `conductor` continua vindo da leitura de estado, não da
prosa dela.

## Como usar isso pra avaliar uma skill nova

Ver `references/skill-evaluation.md` (lida só quando o usuário propõe uma
skill pro pipeline).

## Convenção por projeto pode mudar a ordem

A convenção do projeto alvo tem precedência sobre esta tabela genérica — ver
o Passo 1 do `SKILL.md`.
