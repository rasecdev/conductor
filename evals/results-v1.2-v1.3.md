# Resultado do eval — v1.2 (artefato genérico) e v1.3 (tipo de projeto)

Rodado manualmente (`with_skill` vs baseline em paralelo), mesmo formato das
rodadas anteriores. Casos: ids 8-9 de `evals.json`.

## Caso 8 — `non-board-artifact-staleness` (v1.2)

- **Com skill**: identificou corretamente que o diagrama de arquitetura
  (2026-07-01) está desatualizado frente ao ADR de troca de mensageria
  (2026-09-20), recusou-se a regenerar sozinho, perguntou qual skill/ferramenta
  usar — e, de forma honesta, rodou o catálogo real (`scripts/catalog.sh`) e
  notou que nenhuma skill de diagrama está de fato instalada nesta sessão,
  em vez de inventar que `archify` estava disponível.
- **Baseline**: também identificou a desatualização e recomendou os passos
  certos, sem regenerar nada — qualidade parecida à da skill.
- **Veredito**: comportamento correto nos dois; diferenciação fraca (mesmo
  padrão já registrado nos casos 4/7 da v1.1 — um raciocinador competente já
  nota esse tipo de inconsistência de data sozinho). Não é falha, é limite do
  cenário.

## Caso 9 — `headless-project-no-ui-recommendation` (v1.3)

- **Com skill**: reconheceu o projeto como backend puro, não recomendou
  fluxo de tela/design de UI, e pediu as informações do Passo 2 (convenção,
  spec, tasks) em vez de presumir estágio sem ler nada — postura consistente
  com "não presuma etapa faltando sem checar de verdade".
- **Baseline**: também reconheceu corretamente que etapas de UI "não se
  aplicam" a um projeto backend puro — diferenciação fraca de novo.
- **Veredito**: comportamento correto, sem regressão. A skill acrescenta processo
  explícito (Passo 1→2, catálogo real) onde o baseline dá uma resposta
  qualitativamente boa mas sem a mesma disciplina de "ler antes de afirmar".

## Conclusão

2/2 casos novos com comportamento correto da skill (v1.2 e v1.3), nenhuma
regressão. Diferenciação fraca em ambos frente ao baseline — mesmo padrão já
observado antes: cenários de "note a inconsistência óbvia" tendem a ser
resolvidos razoavelmente bem até sem a skill. O valor real da skill aparece
mais na disciplina de processo (nunca regenerar sozinho, nunca presumir
estágio, usar o catálogo real em vez de nomes hardcoded) do que na conclusão
final, que costuma coincidir com o bom senso do baseline nesses casos.
