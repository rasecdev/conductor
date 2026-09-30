# Gates de transição

Referência fixa do `conductor` pro passo de gates de transição do `SKILL.md`:
tabela declarativa dos portões entre etapas do pipeline e dos eventos que
exigem revisitar uma decisão ou artefato. Complementa
`references/gate-types.md` (gate de **qualidade** do projeto alvo, ex: lint,
teste); aqui são os portões do **processo** que o próprio `conductor` aplica.

Cada linha é um par **gatilho → consequência**. Um gatilho pode aparecer em
várias linhas quando afeta mais de uma consequência — cada uma é avaliada e
reportada separadamente, nunca resumida num único veredito.

- **Sinal mecânico**: `scripts/check-gates.sh` avalia e imprime disparado /
  não disparado / não avaliado (sem binding registrado). O modelo só
  interpreta o resultado.
- **Sinal de julgamento**: sem checagem automática — listado pelo script como
  "não avaliado (julgamento)", avaliado pelo modelo no momento.
- **Ação**: `avisar` (menciona e segue) ou `não recomendar avanço` (o
  `conductor` não recomenda a próxima etapa/skill até o usuário decidir seguir
  mesmo assim — nunca bloqueio mecânico, ver ADR 0001).

## Tabela

| id | Gatilho | Sinal verificável | Tipo | Consequência | Ação |
|---|---|---|---|---|---|
| G1 | Estágio atual (Passo 2) não tem o estágio anterior completo (ex: tarefas sem spec publicada) | Saída de `pipeline` do script de estado: item da sequência do Passo 2 ausente ou vazio | mecânico | Aponta a etapa que falta e a skill correspondente (`references/pipeline-stages.md`) | não recomendar avanço |
| G2 | A etapa que falta (G1) é uma skill com `disable-model-invocation: true` | `scripts/catalog.sh` → campo `MANUAL` da skill recomendada | mecânico | Devolve o comando exato (`/wayfinder`, `/to-spec`, `/grill-with-docs`) pro usuário digitar, sem invocar | avisar |
| G3 | A skill recomendada pelo `conductor` termina (a sessão volta a decidir o próximo passo) | Nenhum — não há estado persistido entre invocações que marque "skill em andamento" | julgamento | Reconsultar o `conductor` (chamar a skill de novo) antes de decidir o próximo passo | avisar |
| G4 | Uma PR do projeto alvo é aberta ou mergeada | `git.prs_abertos` do script de estado (abertura); ausência de uma PR antes presente (merge) — comparação exige leitura anterior, então fica como sinal de apoio, não decisivo sozinho | julgamento | Reconsultar o `conductor` | avisar |
| G5 | O foco da tarefa muda no meio do caminho (usuário pede algo fora do que o `conductor` leu por último) | Nenhum — depende do conteúdo da conversa | julgamento | Reconsultar o `conductor` com o novo foco antes de continuar | avisar |
| G6 | Gate de qualidade esperado (Passo 7 / `gate-types.md`) está vermelho no estágio atual | Saída de `gates` do script de estado, cruzada com `gate-types.md` | mecânico | Avisa o que falhou e a saída, antes de recomendar avançar de estágio/fase | não recomendar avanço |
| G7 | Código/arquivo da área que um artefato vivo registrado acompanha (ex: diagrama de arquitetura) mudou depois da última atualização do artefato | `git log` do caminho da área (binding do Passo 6) vs. data/commit do artefato | mecânico | Aponta a skill de regeneração do artefato; nunca regenera sozinho | avisar |
| G8 | Spec publicada não tem seção de user stories, ou a seção está vazia | Conteúdo do arquivo/issue de spec (`pipeline.spec` do script de estado) | mecânico | Não recomenda `planning-and-task-breakdown`; aponta o que falta na spec | não recomendar avanço |
| G9 | Ao considerar fechar uma rodada, existe user story da spec sem nenhum caso de verificação vinculado e sem justificativa de não-verificabilidade | Campo de stories cobertas em `evals/evals.json` (formato `"#<issue>:<nº>"`, num caso ou no array `stories_nao_verificaveis` — ambos contam como cobertura) cruzado com a contagem de stories da spec (G8) — sem essa convenção registrada no projeto, o script reporta "não avaliado" em vez de julgamento inventado | mecânico | Lista as stories descobertas; não recomenda fechar a rodada | não recomendar avanço |
| G10 | Catálogo (Passo 3) mostra uma skill instalada sem estágio/gate conhecido (nem nesta tabela/`gate-types.md`, nem no registro local do usuário) | Diff entre `scripts/catalog.sh` e as linhas existentes aqui + `references/gate-types.md` + o registro local (ver seção abaixo) | mecânico | Propõe o estágio/gate e pergunta ao usuário; com aprovação, grava no registro **local** do usuário — nunca edita esta tabela nem `gate-types.md` (são do repositório do `conductor`, compartilhados por todo mundo que instala a skill) | avisar |
| G11 | Usuário quer um portão que feche de verdade (não só aviso) | Nenhum — pedido explícito do usuário | julgamento | Aponta o caminho (hook via `update-config`, ou check de CI); nunca instala/configura sozinho | avisar |

## Regras que atravessam a tabela

- **Filtro de tipo de projeto** (Passo 1): gates ligados a artefato de UI (ex:
  G7 quando o artefato é fluxo de tela/design) não são avaliados em projeto
  headless (`sinais_ui` vazio).
- **Binding de artefato vivo**: gates que citam "artefato registrado" (G7)
  usam o binding que o Passo 6 já mantém (onde o artefato vive + fonte de
  verdade que acompanha). Sem registro para aquele artefato → `"não
  avaliado"`, nunca um binding inventado.
- **Cobertura n:1** (G9): um caso de verificação pode cobrir várias stories;
  não precisa de um caso por story.
- **Story não verificável** (G9): quando a story é decisão estrutural, não
  comportamento (nada que um teste/eval observe), marque-a com uma
  justificativa de uma linha em vez de forçar um caso artificial — array
  `stories_nao_verificaveis` em `evals/evals.json`, cada item
  `{"story": "#<issue>:<nº>", "motivo": "<justificativa>"}`. Conta como
  coberta, e é conferida na checagem de fechamento de rodada (a
  justificativa precisa fazer sentido, não só existir).
- **Sem efeito retroativo** (G9): vale a partir da rodada em que o gate entrou
  em produção, nunca reprovando rodada já fechada.
- **Nunca bloqueio mecânico**: a ação mais forte é "não recomendar avanço". Um
  portão que impede de verdade é decisão e configuração do usuário (G11).
- **Evolução da tabela**: só muda por rodada neste repositório (spec + eval).
  Em runtime, o `conductor` nunca edita esta tabela nem `gate-types.md`
  sozinho — uma skill nova sem estágio conhecido (G10) vai pro registro local,
  não pra cá.

## Registro local de skills fora da tabela embutida

Esta tabela e `references/gate-types.md` são genéricas e vêm com o
repositório do `conductor` — compartilhadas por qualquer pessoa que instale a
skill. Uma skill **pessoal** (instalada só numa máquina, em qualquer caminho —
`~/.claude/skills`, escopo de projeto, ou plugin) nunca deveria exigir editar
esse repositório nem abrir PR só para o `conductor` reconhecê-la: quem
instalou não tem por que criar um fork.

O estágio/gate de uma skill assim fica num arquivo **local, por usuário**, fora
do repositório do `conductor` (não versionado, não tocado por atualização da
skill): `~/.claude/conductor-pipeline.json` (substituível pela variável de
ambiente `CONDUCTOR_PIPELINE_REGISTRY`, usada nos testes). Formato: um array
JSON, **um objeto compacto por linha** (`scripts/check-gates.sh` e
`scripts/catalog.sh` fazem parsing linha a linha, sem depender de `jq`):

```json
[
{"skill": "minha-skill-de-diagrama", "estagio": "fora da sequencia: geracao de artefato (diagrama de arquitetura)", "gate": "nao"}
]
```

- `skill`: nome exato como aparece em `scripts/catalog.sh` (`NAME:`).
- `estagio`: texto livre — nome de um estágio já conhecido (`references/pipeline-stages.md`) ou uma descrição curta quando a skill é "fora da sequência" (gera artefato sob demanda, não é etapa de spec).
- `gate`: `nao`, `nao_verificado`, ou uma descrição curta do gate esperado.

`scripts/catalog.sh` imprime `ESTAGIO:`/`GATE:` ao lado de cada skill quando o
registro tem entrada pra ela — é a "lista completa" de skills da pipeline que
esta seção resolve: um comando só, cruzando descoberta (onde a skill está)
com mapeamento (o que ela faz na pipeline), sem exigir que ninguém edite este
repositório pra isso. O `conductor` só escreve nesse arquivo depois de propor
o estágio/gate e o usuário confirmar (G10) — nunca sozinho, e nunca nas
tabelas embutidas da skill.
