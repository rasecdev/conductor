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
| G9 | Ao considerar fechar uma rodada, existe user story da spec sem nenhum caso de verificação vinculado e sem justificativa de não-verificabilidade | Campo de stories cobertas em `evals/evals.json` (ou equivalente registrado na convenção do projeto) cruzado com a lista de stories da spec — mecânico só quando o projeto registra essa convenção; sem registro, julgamento | mecânico ou julgamento (depende de convenção registrada) | Lista as stories descobertas; não recomenda fechar a rodada | não recomendar avanço |
| G10 | Catálogo (Passo 3) mostra uma skill nova sem gate/linha correspondente nesta tabela | Diff entre `scripts/catalog.sh` e as linhas existentes aqui | mecânico | Propõe a linha nova e pergunta ao usuário onde ela entra; nunca edita a tabela sozinho | avisar |
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
- **Sem efeito retroativo** (G9): vale a partir da rodada em que o gate entrou
  em produção, nunca reprovando rodada já fechada.
- **Nunca bloqueio mecânico**: a ação mais forte é "não recomendar avanço". Um
  portão que impede de verdade é decisão e configuração do usuário (G11).
- **Evolução da tabela**: só muda por rodada neste repositório (spec + eval).
  Em runtime, o `conductor` só propõe linha nova (G10) e pergunta — nunca
  edita sozinho.
