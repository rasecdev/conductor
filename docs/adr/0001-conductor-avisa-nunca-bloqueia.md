---
status: accepted
---

# O conductor avisa, nunca bloqueia mecanicamente

Quando um gate (de qualidade ou de transição) dispara, a ação mais forte do conductor é avisar e deixar de recomendar o avanço; ele nunca bloqueia mecanicamente uma ação, nunca instala hook e nunca exige CI. Decidido porque o conductor é uma skill sem presença contínua (só roda quando invocada), porque instalar hook seria efeito colateral que derruba a decisão de mantê-lo auto-invocável, e porque a decisão de seguir mesmo com gate disparado é do usuário.

## Considered Options

- **Bloqueio via hook do harness** (`PreToolUse`/`PostToolUse`) instalado pelo conductor: pegaria o evento na hora, mas é efeito colateral irreversível, some do controle do usuário e contradiz "identificar e conduzir, nunca criar" (ROADMAP).
- **Recusar invocar a próxima skill** quando um gate dispara: não cobre skills manuais (o usuário as digita direto) e transforma recomendação em trava.

## Consequences

- Se o usuário quiser um gate que feche de verdade, o conductor aponta o caminho (hook via `update-config`, check de CI) e o usuário configura.
- O `disable-model-invocation` de skills de terceiros continua sendo o único bloqueio mecânico do pipeline — é do autor delas, não do conductor.
