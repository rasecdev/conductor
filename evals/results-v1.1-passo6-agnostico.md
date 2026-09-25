# Resultado do eval — Passo 6 agnóstico de ferramenta (v1.1)

Rodado manualmente (subagentes `with_skill` vs baseline em paralelo, mesmo
princípio do seam oficial do `skill-creator`, sem o layout formal de
`conductor-workspace/`/`grading.json` — mesmo gap já registrado na Tarefa 3 da
rodada v1). Casos: ids 4-6 de `evals.json`.

## Caso 4 — `board-tool-precedent-non-notion`

- **Com skill**: reconheceu o Miro como ferramenta já em uso (precedente no
  PROGRESSO.md) e tentou usá-lo diretamente (buscou o board de verdade via MCP
  do Miro conectado nesta sessão real), sem sugerir Notion nem mencionar
  qualquer limitação do Miro.
- **Baseline**: também não sugeriu Notion nem mencionou limitação — cenário
  simples demais pra diferenciar de verdade.
- **Veredito**: comportamento da skill correto, mas o caso não diferencia bem
  skill vs. baseline. Ficaria melhor com um cenário onde a tentação de sugerir
  Notion fosse mais forte (ex: usuário pedindo "cria uma página" sem
  especificar ferramenta, com Miro já em uso).

## Caso 5 — `board-tool-first-ask`

- **Com skill**: detectou múltiplos MCPs de board conectados nesta sessão
  (Miro, ClickUp Docs, Claude Docs) e, como não havia precedente registrado,
  perguntou ao usuário qual preferia — sem presumir Notion, sem escolher
  sozinho.
- **Baseline**: decidiu explicitamente **não perguntar nada** sobre ferramenta
  de board ("já que nenhum arquivo menciona isso, o correto é não introduzir
  uma agora").
- **Veredito**: PASS claro — a skill muda o comportamento exatamente como
  esperado (baseline nem levanta a pergunta).
- **Achado**: a resposta com skill não seguiu o `expected_output` ao pé da
  letra (que previa uma pergunta genérica sim/não tipo "você usa Notion/Miro
  pra isso?"). Ela seguiu a lógica mais específica escrita no Passo 6 — com
  mais de um MCP conectado e sem precedente, pergunta **qual** o usuário
  prefere, em vez de pergunta genérica se usa algo. Isso é o comportamento
  correto pela spec real; o texto do `expected_output` ficou desatualizado
  frente ao SKILL.md — vale ajustar a redação do caso numa próxima revisão do
  eval, não o comportamento da skill.

## Caso 6 — `board-tool-refusal-remembered`

- **Com skill**: reconheceu a nota já registrada no PROGRESSO.md e disse
  explicitamente que não ia perguntar de novo sobre nenhuma ferramenta de
  board, seguindo o processo normalmente.
- **Baseline**: não chegou a reconhecer isso como uma decisão já resolvida
  sobre ferramenta — tratou de forma mais genérica, focando em pedir mais
  contexto do projeto.
- **Veredito**: PASS — skill demonstra o comportamento esperado com clareza.

## Conclusão

3/3 casos novos com comportamento correto da skill; diferenciação forte nos
casos 5 e 6, fraca no caso 4 (não é falha, é limite do cenário escolhido).
Nenhuma regressão observada. Pendência conhecida (mesma da Tarefa 3 da v1):
formalizar isso no layout oficial do `skill-creator`
(`conductor-workspace/`/`grading.json`) fica como trabalho futuro, não bloqueia
esta rodada.
