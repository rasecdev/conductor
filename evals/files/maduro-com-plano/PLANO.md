# PLANO — FinanceBot

## Sumário

1. Fase 1–7: núcleo (contas, cartões, lançamentos) — concluídas
2. Fase 8: Relatórios mensais — concluída
3. Fase 9: Multi-canal — planejada

## Fase 8: Relatórios mensais

Resumo mensal por categoria enviado no primeiro dia do mês.

## Fase 9: Multi-canal

Hoje o bot só atende pelo Telegram. Esta fase adiciona um segundo canal: o
app de mensagens da Meta, via API Cloud oficial. O núcleo não muda; cada
canal vira um adaptador em `src/canais/` com a mesma interface.

Decisões: webhook próprio para o novo canal; mesma autenticação por número
cadastrado; mensagens fora da janela de 24h só com template aprovado.
