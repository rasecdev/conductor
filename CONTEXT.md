# conductor

Skill que orienta qualquer projeto através de um pipeline de spec development: identifica em que ponto o projeto está, o que falta ou ficou pra trás, e conduz o usuário até a skill ou ferramenta certa — nunca sendo ela quem executa o passo.

## Language

### Pipeline

**Pipeline**:
A sequência de estágios pela qual uma ideia vira código revisado num projeto, e o conjunto de skills que ocupa cada estágio.
_Avoid_: fluxo, workflow, processo (quando se refere ao todo)

**Estágio**:
Uma posição do pipeline (descoberta, sharpen, spec formal, quebra em tarefas, implementação, revisão), definida pelo que resolve, não pela skill que a ocupa.
_Avoid_: etapa, fase (fase é outra coisa — ver **Fase**)

**Skill manual**:
Skill que só roda quando o usuário digita o comando dela; o modelo não consegue invocá-la. É o gate que o autor dela escolheu.
_Avoid_: skill bloqueada, skill protegida

**Catálogo**:
A lista de skills instaladas, lida na hora a partir delas mesmas — nunca uma lista mantida à mão.
_Avoid_: registry, lista de skills

**Roteador estático**:
Skill de terceiro que descreve em prosa a sequência de skills de um pipeline, igual para qualquer projeto. O conductor trata como vocabulário, não como decisão.
_Avoid_: orquestrador

### Projeto alvo

**Projeto alvo**:
O repositório que o conductor está orientando no momento. Decisões sobre ele ficam registradas nele, nunca no conductor.
_Avoid_: projeto atual, repo (ambíguo com o repositório do próprio conductor)

**Convenção do projeto**:
Regra de processo que o projeto alvo formalizou por escrito, em qualquer formato de ferramenta de IA. Tem precedência sobre a ordem genérica do pipeline.
_Avoid_: regras, configuração

**Convenção praticada**:
O padrão que se repete em mudanças parecidas do histórico real do projeto alvo, independente do que está escrito.
_Avoid_: padrão de fato, costume

**Precedente**:
Uma decisão já tomada antes — no projeto alvo ou em outro projeto do mesmo usuário — usada como sinal para não perguntar de novo ou para inferir o que é esperado. Precedente de outro projeto vale menos que o do próprio.
_Avoid_: histórico (genérico demais), default

**Maturidade**:
Quanto o projeto alvo já existe de fato (histórico, volume de código, estrutura), independente de ter processo formalizado. Separa **projeto novo** de **legado**.

**Legado**:
Projeto alvo maduro que nunca formalizou processo de spec. O que falta nele é mapear o sistema existente, não descobrir o que construir.
_Avoid_: projeto antigo, projeto sem CLAUDE.md

**Tipo de projeto**:
Se o projeto alvo tem interface própria (UI) ou é headless. Filtra o que o conductor recomenda, nunca o que o usuário pode pedir.

**Fase**:
Unidade de planejamento do projeto alvo, com o nome que ele usa (fase, milestone, sub-fase).
_Avoid_: rodada (reservado ao conductor), sprint

### Artefatos

**Artefato vivo**:
Representação visual ou estruturada de uma decisão do projeto alvo (board, diagrama de arquitetura, fluxo de tela, artefato de QA) que precisa acompanhar uma **fonte de verdade**.
_Avoid_: documentação, diagrama (genérico demais), board (é só um tipo)

**Fonte de verdade**:
O registro de onde a decisão que um artefato vivo representa realmente vem. Quando divergem, quem está errado é o artefato.
_Avoid_: origem, documento-base

**Registro de artefato**:
A declaração, no projeto alvo, de onde um artefato vivo vive e qual fonte de verdade ele acompanha.

**Binding**:
O que liga um conceito genérico do conductor (ex: "arquitetura") aos caminhos reais de um projeto alvo específico. Vem do registro de artefato; nunca é inventado.
_Avoid_: vínculo, mapeamento

**Desatualização**:
Estado de um artefato vivo cuja fonte de verdade mudou depois da última vez que ele foi atualizado.
_Avoid_: stale, obsoleto

### Gates

**Gate**:
Uma condição verificável que decide se algo pode seguir. Sempre é de um dos dois tipos abaixo.
_Avoid_: portão, check, trava

**Gate de qualidade**:
Gate do projeto alvo que valida se um artefato ou código está correto (lint, teste, build, conformidade de arquitetura). O conductor verifica e sinaliza; nunca cria.
_Avoid_: gate de CI, validação

**Gate de transição**:
Gate do próprio conductor que decide se uma skill ou estágio pode começar, ou se um evento exige revisitar um artefato vivo. Pode ter como gatilho o estado de um gate de qualidade.
_Avoid_: gate de fluxo, gate de pipeline

**Sinal mecânico**:
Condição de um gate que um comando consegue checar com resultado sempre igual para o mesmo estado.
_Avoid_: sinal automático, sinal determinístico

**Sinal de julgamento**:
Condição de um gate que depende de interpretação do modelo. Nunca é apresentada como determinística.
_Avoid_: sinal heurístico, sinal subjetivo

**Lacuna**:
Algo que o pipeline do projeto alvo deveria ter e não tem, ou tem e não funciona: estágio pulado, gate ausente, gate falhando, gate não acionado, artefato desatualizado.
_Avoid_: gap, problema, pendência

### Spec Driven Development (do próprio conductor)

**Spec viva**:
Descrição do comportamento atual do conductor — o que ele faz hoje, não o que está planejado. Contém o conteúdo de PRD e as decisões técnicas e de teste.
_Avoid_: PRD, spec (sozinho), documentação

**Spec de rodada**:
Descrição de uma mudança no conductor (um delta), publicada no tracker. Depois de implementada e conferida, é incorporada à spec viva.
_Avoid_: spec (sozinho), proposta, feature

**Spec formal**:
A saída do estágio de spec num projeto alvo, qualquer que seja o formato dele.
_Avoid_: spec (sozinho)

**Rodada**:
Unidade de mudança do conductor: uma spec de rodada, suas tarefas e o fechamento. Numerada por versão.
_Avoid_: fase (é do projeto alvo), sprint, release

**Fechamento de rodada**:
O momento em que cada requisito da spec de rodada é conferido contra a skill e o delta é incorporado à spec viva.

**Critério de aceite**:
Condição testável que diz se uma tarefa entregou a coisa certa.
_Avoid_: verificação (é outra coisa — ver **Verificação**)

**Verificação**:
Como provar que um critério de aceite foi cumprido (caso de eval, teste, checagem manual).
_Avoid_: critério de aceite, validação

**Caso de eval**:
Um prompt realista com o resultado esperado em prosa, rodado com e sem a skill, lado a lado. É a verificação do comportamento do conductor.
_Avoid_: teste, cenário

**Seam**:
O ponto por onde o comportamento é testado. O conductor tem o de eval e, para scripts com saída determinística, o de teste do script.
_Avoid_: harness, camada de teste

**Fixture**:
Projeto alvo sintético e mínimo, isolado, montado só para um caso de eval ter estado real para verificar.
_Avoid_: mock, projeto de exemplo

**Dogfooding**:
Usar o conductor para conduzir o desenvolvimento dele mesmo. Recomendação errada nesse uso é defeito da skill.
