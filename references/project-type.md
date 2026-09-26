# Tipo de projeto (filtro de recomendação de artefato)

Lida pelo Passo 1 do `SKILL.md` antes de recomendar artefato visual (Passo 6)
ou gate de artefato de UI (Passo 7), quando o campo `tipo_projeto` da saída do
script de estado não decide sozinho. O tipo de projeto não muda o pipeline de
spec em si (Passos 2–5 valem igual); só filtra quais artefatos visuais faz
sentido recomendar.

O script só lista sinais (`sinais_ui`, `sinais_headless`); classificar é
decisão sua, conferindo o que o sinal não cobre (ex: um projeto
`Microsoft.NET.Sdk.Web` pode servir páginas Razor/Blazor, e o script não olha
dependência de frontend fora do `package.json`).

- **Tem UI própria** (web: `package.json` com framework de frontend; mobile:
  `pubspec.yaml`/Flutter, projeto React Native, projeto nativo iOS/Android;
  desktop: Electron ou equivalente) → fluxo de tela e design de UI são
  artefatos relevantes de recomendar.
- **Headless/backend puro** (API, worker, bot, microserviço sem camada de
  apresentação própria — ex: um bot de Telegram como back-end puro) → não
  recomende fluxo de tela nem design de UI de forma não solicitada.
- **Sinal ambíguo ou misto** (ex: backend com painel administrativo web,
  monorepo com API e app, `sinais_ui` e `sinais_headless` ambos preenchidos):
  pergunte ao usuário em vez de presumir.

Isso é só filtro de **recomendação**, nunca uma trava: se o usuário pedir um
desses artefatos mesmo fora do perfil detectado, atenda normalmente — a
detecção só evita *oferecer* algo que não se aplica, não impede pedir.
