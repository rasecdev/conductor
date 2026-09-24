# conductor

Uma [Agent Skill](https://support.claude.com/en/articles/12512176-what-are-skills) do Claude Code que orienta o processo de spec development de ponta a ponta — de uma ideia solta até código revisado — para qualquer projeto, novo ou legado.

## O problema que resolve

O pipeline de skills de spec development ([mattpocock/skills](https://github.com/mattpocock/skills)) é poderoso mas fragmentado: `wayfinder` sabe planejar descoberta, `grilling`/`domain-modeling` sabem sharpen de plano, `to-spec` sabe sintetizar spec, `planning-and-task-breakdown` sabe quebrar em tarefas, `implement-specs` sabe implementar, `check-impl-against-spec` sabe revisar — mas nenhuma delas sabe dizer "você está aqui, o próximo passo é ali". É fácil pular uma etapa sem perceber.

O `conductor` é essa peça que faltava: lê o estado real do projeto (specs existentes, tarefas, convenções do próprio repo) e diz exatamente qual skill chamar agora — sem nunca decidir por conta própria disparar as skills mais sensíveis (interrogatório, publicação de spec), que continuam exigindo confirmação explícita.

### Em que difere do `ask-matt` (mattpocock/skills)

O `mattpocock/skills` já tem seu próprio roteador, [`ask-matt`](https://github.com/mattpocock/skills/blob/main/skills/engineering/ask-matt/SKILL.md) — um mapa em prosa de cenário → sequência de skills, cobrindo bem mais fluxo (bugs, handoff, fronteiras de fase) do que este projeto tenta modelar. O `conductor` não substitui isso: a diferença é que `ask-matt` é estático (a mesma prosa pra qualquer projeto), enquanto o `conductor` lê o estado real do repositório atual — `CLAUDE.md`, `tasks/plan.md`, git log, milestones/issues — antes de recomendar. Os dois se complementam: `ask-matt` (ou equivalente) como vocabulário do pipeline, `conductor` como leitura de onde o projeto está de fato.

## Instalação

Copie a pasta `conductor/` para `~/.claude/skills/conductor/` (escopo global — funciona em qualquer projeto automaticamente, sem configuração por repositório):

```bash
git clone <url-deste-repo> ~/.claude/skills/conductor
```

Não depende de nenhuma configuração adicional. Funciona melhor com o pipeline do [mattpocock/skills](https://github.com/mattpocock/skills) instalado (`wayfinder`, `grilling`, `grill-with-docs`, `domain-modeling`, `to-spec`, `planning-and-task-breakdown`, `implement-specs`, `check-impl-against-spec`), mas o catálogo (`scripts/catalog.sh`) se adapta a qualquer skill instalada, lendo o frontmatter de cada `SKILL.md` em tempo real.

## Como funciona

1. **Lê a convenção do projeto atual** — `CLAUDE.md`/`AGENTS.md`, ou equivalentes de outras ferramentas (`.cursor/rules/*.mdc`, etc.), com precedência sobre o fluxo genérico.
2. **Determina o estado real** — existe modelo de domínio? spec formal? tarefas quebradas com critério de aceite? implementação em andamento? Distingue projeto novo de projeto legado maduro sem processo formalizado (usando sinais como histórico de commits e, quando necessário, minerando ~3 commits de mudanças parecidas pra achar a convenção praticada de fato).
3. **Monta o catálogo de skills disponíveis** dinamicamente (`scripts/catalog.sh`) e cruza com a ordem de estágios documentada em `references/pipeline-stages.md`.
4. **Recomenda o próximo passo** — chama direto as skills automáticas, devolve o comando exato para as manuais (`wayfinder`, `to-spec`, `grill-with-docs` continuam exigindo confirmação sua, por design).
5. **Avalia skills novas** propostas para o pipeline, comparando contra o que já existe e contra precedentes já registrados no próprio projeto.
6. **Mantém a estrutura de acompanhamento no Notion** (página de projeto → fase → diagrama de dependência de tarefas) — opcional, não bloqueia o resto se o conector não estiver disponível.

Ver `SKILL.md` para o processo completo.

## Estrutura

```
conductor/
├── SKILL.md               — instruções e frontmatter (nome, description, gatilhos)
├── references/
│   └── pipeline-stages.md — tabela de estágios do pipeline de spec e como avaliar skill nova
├── scripts/
│   └── catalog.sh         — lista nome/description/invocação-manual de toda skill instalada
└── evals/
    └── evals.json         — casos de teste usados para validar o comportamento da skill
```

## Validação

Testada via o processo do `skill-creator` (subagentes com/sem a skill, comparando outputs) contra três perfis de projeto reais:

- **Projeto novo do zero** — reconhece ausência de convenção/spec e recomenda descoberta (`wayfinder`/`grilling`).
- **Projeto maduro com pipeline formalizado** — reconhece planejamento já feito e pula para implementação, sem repetir etapas de spec desnecessariamente.
- **Projeto legado maduro sem pipeline formalizado** — encontra convenção em formato de outra ferramenta, reconhece requisito de artefato já prescrito mas ausente, e deriva o padrão real de arquivos minerando commits anteriores parecidos.

Histórico de correções encontradas nesse processo (e o porquê de cada uma) está no histórico de commits deste repositório.

## Licença

Uso pessoal — sem licença de distribuição definida ainda.
