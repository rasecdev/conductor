# 0004 — Integração fiscal assíncrona via fila (2026-09-12)

A emissão de nota fiscal deixa de chamar a SEFAZ de forma síncrona pela tela e
passa a publicar numa fila, processada por um worker separado.
