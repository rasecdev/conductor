# Plano — FinanceBot

Tarefas rastreadas no GitHub Issues (milestone por fase).

## Fase 9: Multi-canal

- [ ] Tarefa 1: interface comum de canal em `src/canais/` (critério: adaptador do Telegram passa a implementá-la sem mudar comportamento; testes existentes verdes)
- [ ] Tarefa 2: adaptador do canal Meta via API Cloud (critério: recebe webhook, responde texto; teste com payload real gravado)
- [ ] Tarefa 3: templates para mensagens fora da janela de 24h (critério: resumo mensal usa template aprovado; teste cobre janela expirada)

### Checkpoint: Fase 9

- [ ] Os dois canais respondem ao mesmo comando com o mesmo resultado
