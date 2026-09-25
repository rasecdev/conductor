# CLAUDE.md — DocsBot

Bot headless que responde dúvidas a partir da documentação em `docs/`.

## Gates de qualidade

- `markdownlint` valida `docs/**/*.md` e roda em **pre-commit**, pra nenhum
  commit entrar com documentação quebrada.
