# Detalhe do Passo 7 (gates de qualidade)

Lida pelo Passo 7 do `SKILL.md` quando há gate a avaliar de verdade:
`gates.ferramentas.configurados` ou `gates.irmaos` preenchidos na saída do
script de estado, `artefatos` preenchido (artefato registrado pode implicar
gate) ou convenção do projeto que exige gate. Sem nada disso, o resumo do
`SKILL.md` basta: só sugestão de baixa confiança, se houver. A tabela de gates
fica em `references/gate-types.md`.

## Quais gates são esperados

Cruze o estágio atual e os artefatos vivos registrados (Passos 2 e 6) com a
tabela de `references/gate-types.md`. Aplique o filtro de tipo de projeto do Passo 1 (projeto headless
não espera gate de artefato de UI) e de stack (não espere `tsc` num projeto que
não é TS/JS).

## Com que confiança

A expectativa de cada gate vem da fonte mais forte disponível, nesta ordem:

1. **Convenção do projeto** exige o gate explicitamente — confiança alta.
2. **Artefato registrado** que implica o gate (ex: diagrama Mermaid registrado
   → gate de compilação Mermaid) — confiança alta.
3. **Precedente de outro projeto do mesmo usuário** (`gates.irmaos` na saída do
   script, ou os repositórios que o usuário indicar) que usa esse gate —
   confiança média.
4. **Nenhuma das anteriores** — só sugestão de baixa confiança, nunca
   apresentada como obrigatória.

## Estado real

Para cada gate que existe, verifique de verdade — nunca presuma nem simule o
resultado:

- **Roda localmente** (script, `Makefile`, hook): execute o comando configurado
  no projeto e leia a saída. É só leitura de estado: não corrija nada do que
  ele acusar. Quem roda é você, não o script de estado (ele nunca executa
  comando do projeto).
- **Só roda no CI** (ex: usa uma action que não existe fora dele): use
  `gates.ultima_run_ci` (ou `gh run list --branch <branch> --limit 1`) e
  informe o resultado **com a data** da run.
- **Não dá pra verificar nesta sessão** (ferramenta não instalada, projeto sem
  remote, sem acesso ao CI — `indisponivel` na saída do script diz o motivo):
  reporte o gate como **"não verificado"**, dizendo o porquê — nunca como
  passando nem como falhando. Isso não trava o resto da orientação.

## Acionamento

Um gate que existe mas não roda no momento em que deveria quase não protege
nada. Compare onde ele está configurado (`configurado_em`) com quando deveria
rodar — pela convenção do projeto, se ela disser, ou pela coluna "Quando
deveria rodar" da tabela de `references/gate-types.md`. Exemplos de lacuna: a convenção exige o gate em
pre-commit, mas ele só existe como script manual e não há hook; o gate é de
CI, mas a última run é bem mais antiga que os últimos commits da branch
(`maturidade.historico.ultimo_commit`).

## Como sinalizar

Gate esperado ausente, falhando ou **não acionado no momento esperado** é uma
lacuna — diga isso na mesma linguagem de "próximo passo" do Passo 4, **sempre
citando a fonte da expectativa e a confiança** (ex: "o diagrama
`docs/arquitetura.mmd` está registrado como artefato vivo, mas nada verifica
que ele compila — gate esperado com confiança alta, pela fonte 'artefato
registrado'"). Sugestão de baixa confiança vai separada, como sugestão, não
como lacuna. Se houver mais de uma ferramenta possível para o mesmo gate e o
projeto não tiver precedente, pergunte ao usuário qual prefere.

## Oferecer setup

Configurar o gate é trabalho do usuário (ou implementação normal que ele
pedir), nunca iniciativa do `conductor`. A única exceção é **oferecer** o setup
inicial quando o projeto não tem o gate, o risco é baixo (ex: acrescentar um
script e um job de CI; nada que apague ou reescreva o que existe) e há
**precedente claro** — outro projeto do mesmo usuário já usa esse gate, ou a
convenção diz qual ferramenta. Nesse caso, mostre exatamente o que seria
configurado, copiando o padrão do precedente, e **só execute com aprovação
explícita** do usuário. Uma pergunta ou um pedido de diagnóstico ("o que
falta?") não é aprovação.
