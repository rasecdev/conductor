---
status: accepted
---

# O SKILL.md carrega só o que roda sempre; casos condicionais ficam atrás de gatilho

O `SKILL.md` contém só três coisas: o fluxo que roda em toda execução, as regras de proteção (o que o conductor nunca faz) e os gatilhos. Todo caso que só às vezes se aplica — um passo inteiro ou um caso dentro de um passo — vive numa referência, e o gatilho diz quando lê-la. Gatilhos são sinais mecânicos (campo da saída do script de estado) sempre que possível. Decidido na v1.5 (#50) porque o conductor custava ≈ 20k tokens a mais por chamada (70,7k × 50,2k na regressão da v1.4) e cada rodada acrescentava mais um passo carregado em toda execução.

## Considered Options

- **Tudo no `SKILL.md`** (situação até a v1.4): nenhum risco de pular instrução, mas o custo cresce a cada rodada e é pago mesmo quando o caso não se aplica.
- **Tudo atrás de gatilho, inclusive o núcleo:** um gatilho que sempre dispara só acrescenta uma leitura, e uma regra de proteção atrás de gatilho some justamente quando o gatilho falha.
- **Reescrever a skill em código (Python):** tira do modelo o que é sinal mecânico, mas o núcleo da skill é sinal de julgamento; o código só voltaria a precisar de um LLM dentro dele.

## Consequences

- O corte é por caso, não por passo; referências são agrupadas por situação (ex: "projeto legado", "artefatos vivos"), não uma por parágrafo, porque cada leitura é uma chamada de ferramenta a mais.
- Regras de proteção nunca ficam atrás de gatilho.
- A saída do script é mapa do que abrir, nunca conclusão de que uma etapa está completa.
- Uma referência lida sozinha traz ou aponta explicitamente o que precisa de outra parte da skill.
- Cada gatilho precisa de pelo menos um caso de eval; gatilho que depende de interpretação roda com mais de uma run na regressão.
- Rodadas seguintes (a começar pela v1.6) acrescentam comportamento novo nesse formato: referência sob demanda e parte mecânica em script.
