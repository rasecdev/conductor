# Avaliação do conductor

Como a qualidade da skill é medida, o que os números dizem e o que eles **não**
dizem.

## A pergunta que o eval responde

> O `conductor` agrega em cima de um pipeline de SDD que já está instalado?

O **baseline** não é um Claude "cru": é o mesmo modelo, no mesmo ambiente, com
**todas as skills de spec development instaladas** (`wayfinder`, `to-spec`,
`grilling`, `grill-with-docs`, `domain-modeling`,
`planning-and-task-breakdown`, `implement-specs`, `check-impl-against-spec`),
só **sem** o `conductor`. Então um empate significa "o modelo com o pipeline já
faz isso sozinho", não "a skill falhou".

A comparação com alternativas do mesmo tipo (ex: o roteador `ask-matt`) é outra
pergunta e ainda não foi feita — ver
[#43](https://github.com/rasecdev/conductor/issues/43).

## Metodologia

- **Framework**: o de eval do `skill-creator`. Para cada caso, dois subagentes
  em paralelo — um com a skill, um baseline — recebem o mesmo prompt.
- **Casos**: 16, em [`evals/evals.json`](../evals/evals.json). Cada um descreve
  em prosa o que a resposta precisa demonstrar (`expected_output`).
- **Fixtures isoladas**: todo caso com estado roda num projeto sintético mínimo
  ([`evals/files/`](../evals/files/)), copiado para um diretório temporário
  com git próprio a cada run ([`scripts/prepare_fixture.sh`](../scripts/prepare_fixture.sh)).
  Nada roda contra projetos reais, e cada run tem sua própria cópia. Estado
  que não cabe em arquivo (ex: 2000 commits de histórico para o caso legado) é
  gerado por um gancho de setup.
- **Grading**: assertions tiradas do `expected_output`, fixadas **antes** de
  ler as respostas, marcadas passou/falhou com evidência. Gravado no formato
  oficial (`run-N` + `grading.json`) e agregado por
  `scripts.aggregate_benchmark`.
- **Dados**: os benchmarks agregados estão versionados em
  [`evals/results/`](../evals/results/). As respostas brutas ficam fora do
  repositório (`conductor-workspace/`).

## Resultado atual (v1.4)

Regressão completa, iteração 8 —
[`evals/results/iteration-8.json`](../evals/results/iteration-8.json):

| | Com a skill | Baseline |
|---|---|---|
| **Taxa de acerto das assertions** | **100%** | **77,9%** |
| Casos com acerto total | 16 de 16 | 7 de 16 |
| Tempo médio por run | 71 s | 44 s |

Por caso, e a conferência contra a spec, em
[`evals/results-v1.4.md`](../evals/results-v1.4.md).

### Onde a skill faz diferença

- **Projeto novo**: numa pasta vazia, o baseline dá orientação genérica de
  scaffolding; a skill encaminha para a descoberta certa do pipeline e devolve
  o comando da skill manual.
- **Gate de qualidade esperado**: um diagrama registrado como artefato vivo e
  sem nada que o valide passa despercebido pelo baseline; a skill aponta a
  lacuna, com a fonte da expectativa e a confiança.
- **Aviso, não trava**: diante de um gate vermelho ou não verificável, o
  baseline trata como pré-requisito ("ainda não"); a skill avisa e mantém a
  recomendação, deixando a decisão com o usuário.
- **Precedente que não bate** e **artefato desatualizado**: a skill lista o que
  o conector realmente encontra e aponta a ferramenta de regeneração, em vez de
  só pedir confirmação ou se oferecer para editar o arquivo à mão.

### Onde o baseline empata

Em 7 dos 16 casos o baseline também acerta tudo: ler a convenção do projeto,
reconhecer planejamento já feito, tratar legado como legado, respeitar
precedente e recusa de board, reconhecer projeto headless, procurar hooks. Com
o pipeline instalado, o modelo já faz isso sozinho.

## Limites — leia antes de citar os números

- **Uma run por configuração.** Não há medida de variância; um caso pode virar
  com outra execução. As diferenças pequenas (1 assertion) não são robustas.
- **Mesmo modelo avalia.** O grading foi feito pelo modelo que também
  desenvolve a skill, com assertions escritas pelo mesmo autor. As assertions
  foram fixadas antes das respostas para reduzir viés, mas não há avaliador
  independente.
- **Fixtures são pequenas.** Um projeto sintético de poucos arquivos não tem a
  riqueza de um projeto real; o comportamento em projetos grandes pode diferir.
- **Comparabilidade começa na v1.4.** Antes, os casos rodavam contra projetos
  reais do autor e descreviam o estado no próprio prompt. Os números anteriores
  (v1.0–v1.3, em `evals/results-v1.1-*.md` e `evals/results-v1.2-v1.3.md`) não
  são comparáveis com estes e os benchmarks dessas iterações não estão
  versionados por conterem detalhes de projetos privados.
- **Custo.** Com a skill, cada run leva ~60% mais tempo e ~40% mais tokens, por
  ler o `SKILL.md` e as referências.
- **Stories sem caso.** Dois comportamentos da v1.4 ainda não têm caso de eval
  (tipo de artefato novo; conformidade de arquitetura) — ver
  `evals/results-v1.4.md`.

## Histórico

| Iteração | Rodada | Casos | Com a skill | Baseline | Arquivo |
|---|---|---|---|---|---|
| 5 | v1.4, tarefa 1 | 10, 11 | 100% | 29% | [`iteration-5.json`](../evals/results/iteration-5.json) |
| 6 | v1.4, tarefa 2 | 12, 13 | 100% | 77,5% | [`iteration-6.json`](../evals/results/iteration-6.json) |
| 7 | v1.4, tarefa 3 | 14, 15 | 100% | 87,5% | [`iteration-7.json`](../evals/results/iteration-7.json) |
| 8 | v1.4, regressão | 0–15 | 100% | 77,9% | [`iteration-8.json`](../evals/results/iteration-8.json) |
