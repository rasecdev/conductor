# Tipos de gate de qualidade

Referência fixa do `conductor` para o Passo 7: qual **gate de qualidade** é
esperado para cada artefato vivo ou estágio do projeto alvo, com que
ferramenta real ele se checa e quando deveria rodar. É conhecimento da skill,
não do projeto — o que é do projeto é só o que está registrado nele (artefatos,
convenção), lido nos Passos 1, 2 e 6.

**Lista aberta.** Cruze com o catálogo do Passo 3: um tipo de artefato novo que
entrar no pipeline é candidato a ganhar uma linha aqui. As ferramentas abaixo
são exemplos com uso real; quando houver mais de uma possível para o mesmo
artefato e o projeto não tiver precedente, pergunte ao usuário em vez de
escolher.

| Artefato / estágio | Gate esperado | Ferramenta de checagem | Comando típico | Quando deveria rodar |
|---|---|---|---|---|
| Diagrama Mermaid (`.mmd`, bloco `mermaid` em Markdown) | O diagrama compila | `mmdc` (mermaid-cli) | `npx @mermaid-js/mermaid-cli -i <arquivo> -o /tmp/out.svg` | CI a cada PR que toca o diagrama |
| Diagrama de arquitetura em SVG/HTML | O arquivo é SVG/XML válido | `svgo` ou parser XML | `npx svgo --dry-run <arquivo>` | CI a cada PR que toca o diagrama |
| Diagrama de arquitetura (qualquer formato) | O código respeita as dependências que o diagrama declara | `dependency-cruiser` ou `madge` (JS/TS) | `npx depcruise src` / `npx madge --circular src` | CI a cada PR que toca código da área |
| Artefato de QA em Markdown | O documento é Markdown válido e consistente | `markdownlint` | `npx markdownlint-cli2 "<glob>"` | CI a cada PR; pre-commit opcional |
| Código TS/JS (só em projeto desse stack) | Tipos e lint passam | `tsc`, `eslint` | `npx tsc --noEmit` / `npx eslint .` | Pre-commit e CI a cada PR |

## Como saber se um gate "existe" no projeto alvo

Um gate existe quando o comando (ou a ferramenta) da tabela aparece configurado
em algum ponto que o projeto de fato executa:

- scripts do projeto (`package.json` → `scripts`, `Makefile`, `justfile`, etc.);
- workflow de CI (`.github/workflows/*.yml` ou equivalente);
- hook de pre-commit (`.husky/`, `.pre-commit-config.yaml`, `lefthook.yml`).

Ferramenta só instalada como dependência, sem nenhum desses pontos chamando,
**não** conta como gate existente.
