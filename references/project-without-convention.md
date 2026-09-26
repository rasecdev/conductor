# Projeto sem `CLAUDE.md`/`AGENTS.md`

Lida pelo Passo 1 do `SKILL.md` quando `convencao` (saída do script de estado)
não lista `CLAUDE.md`, `AGENTS.md` nem `.claude/CLAUDE.md`. Três situações
possíveis, distinguidas pelos campos `convencao` e `maturidade`.

## Convenção no formato de outra ferramenta

`convencao` lista regra de outro assistente (`.cursor/rules/*.mdc`,
`.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`,
`.windsurf/rules/*`). Nem todo projeto usa Claude Code como ferramenta
principal: trate essas regras como convenção do projeto igualmente, mesmo que
precise "traduzir" a terminologia de uma ferramenta pra outra.

Preste atenção especial a qualquer instrução dessas regras que já prescreva um
artefato de planejamento obrigatório (ex: "criar `development_plan.md` pra todo
projeto", "gerar plano pra projeto existente que não tiver um"). Se essa
exigência já existe e o arquivo não foi criado ainda, isso É o próximo passo,
não uma escolha entre skills do pipeline genérico.

## Projeto maduro sem convenção (legado)

Sinais em `maturidade`: histórico longo (`historico.commits` na casa das
centenas ou mais), `manifestos` de solução/projeto estabelecida (`.sln`,
`package.json` com dependências reais, etc.) e `arquivos_de_codigo` com volume
real. Vale também quando a única convenção é de outra ferramenta (seção
anterior).

**Ausência de convenção não significa projeto novo.** Um projeto com milhares
de commits e código em produção que simplesmente nunca formalizou processo de
IA/spec é um caso **diferente** de uma pasta genuinamente vazia — nunca
recomende `wayfinder` ou `grilling` como se fosse descoberta de ideia nova. O
que falta ali não é decidir o que construir (isso já existe e funciona), é
mapear o sistema existente antes de mexer nele: o passo certo tende a ser
`domain-modeling`/`grill-with-docs` com foco em entender a arquitetura atual,
não interrogar sobre uma ideia nova.

### Minerar o histórico real, não só a regra escrita

Regra documentada (`CLAUDE.md`, `.cursor/rules`, etc.) costuma ser genérica ou
incompleta em projetos antigos — o padrão realmente seguido está no que as
pessoas de fato fizeram. Quando for orientar uma mudança nesse tipo de projeto,
procure no `git log` **uns 3 commits** de tarefas parecidas com o que o usuário
quer fazer agora (mesmo tipo de mudança — ex: "nova tela", "novo endpoint",
"correção de X") e compare os arquivos tocados entre eles. Um commit só pode
ser um conserto pontual e simples, não representativo do padrão real; três dá
triangulação — se os três tocam o mesmo conjunto de camadas/arquivos na mesma
ordem, isso é convenção de fato, mais confiável do que qualquer regra escrita
desatualizada. Se os três divergirem entre si, diga isso ao usuário em vez de
inventar um padrão que não existe.

## Projeto novo de verdade

`convencao` vazio **e** sinais de maturidade ausentes (poucos commits, pouco
código, ou nenhum). Trate a ausência de convenção como um sinal, não como um
vazio a ignorar: pode valer perguntar ao usuário se ele quer formalizar uma
antes de avançar muito, mas isso não bloqueia recomendar o primeiro passo.
