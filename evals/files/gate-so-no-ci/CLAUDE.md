# CLAUDE.md — CofreSecrets

Serviço headless que guarda configurações. Plano em `tasks/plan.md`.

## Gates de qualidade

- Varredura de segredos com gitleaks roda no CI (`.github/workflows/ci.yml`) e
  precisa estar verde antes de avançar de fase.
