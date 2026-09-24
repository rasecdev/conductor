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

Quando o usuário propuser uma skill nova pra entrar no pipeline:

1. Leia a `description` dela (via `scripts/catalog.sh` se já estiver instalada,
   ou o que o usuário descrever se ainda não estiver).
2. Compare com a coluna "O que resolve" de cada linha desta tabela — qual
   estágio ela mais se parece com o objetivo dela?
3. Se um estágio já tem uma skill cobrindo o mesmo objetivo, a pergunta pro
   usuário é: ela complementa (cobre um caso que a existente não cobre),
   substitui (faz a mesma coisa melhor/diferente) ou é redundante (mesma
   coisa, sem ganho)? Não decida sozinho qual delas "vence" — é uma
   recomendação, a escolha final é do usuário.
4. Se não encaixa em nenhum estágio existente, diga isso explicitamente — pode
   ser um estágio novo que ainda não existia neste pipeline (ex: algo entre
   "revisão" e "deploy"), e essa tabela deveria crescer pra registrar isso.

## Convenção por projeto pode mudar a ordem

Um projeto específico pode ter seu próprio fluxo documentado no `CLAUDE.md` do
repo (ex: formalizar branch → PR → milestone → checkpoint em cima deste
pipeline genérico). Quando existir, a convenção do projeto tem
precedência sobre esta tabela genérica — leia o `CLAUDE.md` do repo atual
antes de recomendar o próximo passo.
