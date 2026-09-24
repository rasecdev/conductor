# Estágios do pipeline de spec development

Ordem de referência pra classificar uma skill (existente ou nova) num ponto do
fluxo de "ideia solta" até "código em produção revisado". Isso é um ponto de
partida pra comparação, não uma lista fechada — uma skill nova pode não
encaixar em nenhum estágio existente, ou pode justificar um estágio novo.

| # | Estágio | O que resolve | Skills conhecidas (mattpocock/skills) |
|---|---|---|---|
| 1 | Descoberta / decisão nebulosa | Ideia grande demais pra uma sessão, destino ainda não claro | `wayfinder` |
| 2 | Sharpen do plano / modelo de domínio | Interrogar até entendimento compartilhado; fixar vocabulário e ADRs | `grilling`, `grill-with-docs`, `domain-modeling` |
| 3 | Síntese em spec formal | Conversa/decisões viram spec publicado no tracker | `to-spec` |
| 4 | Quebra em tarefas | Spec vira tarefas pequenas com critério de aceite e verificação | `planning-and-task-breakdown` |
| 5 | Implementação | Código + testes, mantendo spec e código alinhados | `implement-specs` |
| 6 | Revisão | PR comparado contra o spec aprovado | `check-impl-against-spec` |

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
