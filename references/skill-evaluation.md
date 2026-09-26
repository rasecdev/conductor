# Avaliar uma skill nova proposta pro pipeline

Lida quando o usuário propõe uma skill (instalada ou ainda a escrever) pro
pipeline de spec — gatilho do Passo 5 do `SKILL.md`. A recomendação é sempre
complementa / substitui / redundante; **nunca decida sozinho qual fica**, é o
usuário quem escolhe.

## Comparação por leitura

1. Leia a `description` dela (via `scripts/catalog.sh` se já estiver instalada,
   ou o que o usuário descrever se ainda não estiver).
2. Compare com a coluna "O que resolve" de cada linha da tabela de
   `references/pipeline-stages.md` — qual estágio ela mais se parece com o
   objetivo dela?
3. Se um estágio já tem uma skill cobrindo o mesmo objetivo, a pergunta pro
   usuário é: ela complementa (cobre um caso que a existente não cobre),
   substitui (faz a mesma coisa melhor/diferente) ou é redundante (mesma
   coisa, sem ganho)? Um roteador estático em prosa (ex: `ask-matt`) é
   comparado da mesma forma — ver `references/pipeline-stages.md` → "Sobre
   roteadores estáticos".
4. Se não encaixa em nenhum estágio existente, diga isso explicitamente — pode
   ser um estágio novo que ainda não existia neste pipeline (ex: algo entre
   "revisão" e "deploy"), e a tabela de estágios deveria crescer pra registrar
   isso.

## Precedente do próprio projeto

Antes de concluir, cheque se o projeto atual já tem **precedente próprio**
registrado — procure no `PLANO.md`/`PROGRESSO.md` (ou equivalente, ver
`planejamento` na saída do script de estado) por menções a skills já avaliadas
e aceitas/rejeitadas anteriormente. Um projeto pode já ter decidido não adotar
algo parecido, com o motivo documentado — isso é sinal mais forte do que
comparar só descriptions genéricas, porque reflete uma decisão já tomada com
contexto real do próprio usuário.

## Quando a leitura não basta: avaliação quantitativa

Comparar `description` contra `description` é rápido e cobre a maioria dos
casos, mas às vezes não é suficiente pra desempatar — duas skills descrevem
objetivos parecidos e não fica claro, só pela leitura, se uma é redundante com
a outra ou se cobre um caso real que a outra não cobre.

Nesse cenário, existe uma opção mais cara e mais confiável: rodar as duas
skills de verdade contra 2-3 prompts realistas, com subagentes em paralelo
(um por skill), e comparar os resultados lado a lado — exatamente o processo
que o `skill-creator` usa pra validar uma skill nova (o próprio `conductor` foi
validado assim, com casos de teste, assertions e grading real, não só por
leitura). Não reimplemente esse processo aqui — ao chegar nesse ponto, invoque
a skill `skill-creator` pra conduzir a comparação.

Isso **nunca dispara sozinho**, pelo mesmo motivo que `wayfinder`/`to-spec` não
disparam: tem custo real (minutos de execução, vários agentes, tokens). Duas
formas de chegar lá:

1. O usuário pede explicitamente ("roda uma avaliação de verdade pra comparar
   essas skills").
2. Você nota que a comparação por description ficou genuinamente ambígua, e
   **oferece** rodar a avaliação — nunca decide sozinho que vale a pena e já
   dispara. Se o usuário preferir decidir só com a leitura, respeite isso.
