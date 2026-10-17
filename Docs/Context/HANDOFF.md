# Handoff — S3, builds e wiki integrada

**Branch documental:** `docs/s03-final-handoff`. **Commit deste handoff:** consulte `git rev-parse --short HEAD` no checkout depois do commit. Esta revisão partiu de `main` após PR #19, inicialmente em `6cfc9f1`.

Antes de iniciar a próxima tarefa, atualize a referência: `git fetch origin`, depois `git rev-parse --short origin/main`. Use o SHA retornado de `origin/main` como baseline e confira `git status --short --branch`; não reutilize o SHA de `HEAD` ou o nome de uma branch local antiga como se ainda representasse `main`.

## Integração em main

| PR | Merge em `main` | Incremento |
|---|---|---|
| #15 | `2aab5f4` (código `b1d0768`) | Queda por 60 s, reanimação por contrato local de 5 s, renascimento manual ou automático no acampamento e mochila persistente com metade de cada pilha atual de materiais, arredondada para baixo. XP e equipamento permanecem. |
| #16 | `38728f0` (código `e3ab242`) | Contato entre jogador e criaturas considera footprints alpha projetados pela câmera, alinhando separação visual e colisão sem ampliar os hitboxes. |
| #17 | `54275e1` (código `030273f`) | Movimento em oito direções transforma input para o plano da câmera 2.5D; cardinais e diagonais mantêm velocidade. |
| #18 | `f64c207` (código `89d60a4`) | Regeneração de HP/MP fora de combate multiplicada por 1,2 após 8 s sem atacar nem receber dano; taxas em combate, caps e clamp preservados. |
| #19 | `6cfc9f1` (código `c995dfa`) | Wiki local integrada em `docs/wiki/`, com índice gerado, busca, filtros e previews. |

O contrato/API de reanimação por aliado é local e prepara uma integração futura pelo host. A build solo não tem LAN, transporte ou conexão com aliados. A wiki usa dados de planejamento e mantém o status de arte candidata explícito.

## Builds e pendências

- **Web:** exportação feita a partir de `main`. A revisão gráfica no navegador continua pendente; execução headless e pacote exportado não substituem esse aceite.
- **Android:** a build debug 0.1.7/versionCode 8 é histórica, anterior às PRs #15–#19 e não recompilada com as mudanças posteriores. Este ambiente não tem Android SDK Platform 35 nem Build Tools 35.0.0; portanto, a exportação APK do estado atual está bloqueada. O APK ainda precisa ser gerado e instalado/testado em aparelho físico. Não há validação de notch, toque, estabilidade ou desempenho em dispositivo.
- **Fase:** S0–S3 e o aceite integral do GDD continuam abertos. LAN em dois Androids, Archer/Mage, árvore completa, mundo procedural/chunks e outras partes do conteúdo permanecem pendentes conforme o roadmap.

## Próxima ação

Instalar/configurar Android SDK Platform 35 e Build Tools 35.0.0, atualizar `origin/main` e confirmar o SHA atual, então exportar o APK desse baseline. Registrar versão, SHA, manifesto, assinatura, integridade e comandos em `docs/gameplay/MVP_BUILD_VALIDATION.md`. Depois instalar no aparelho Android e validar o fluxo de queda (timer, botão e timeout), persistência/recuperação da mochila, movimento relativo à câmera, contato por footprint, regeneração e controles touch. Em paralelo, revisar a exportação Web em navegador.

## Wiki

Arquivos principais: `docs/wiki/index.html`, `wiki.css`, `app.js` e `catalog-data.json`. Para regenerar o catálogo depois de editar documentação ou fontes: `python3 tools/wiki/build_index.py`. Para validar os dados, caminhos, markup/JS e respostas locais: `python3 tools/wiki/test_catalog.py`. Para abrir, rode `python3 -m http.server 8000` na raiz e visite `http://localhost:8000/docs/wiki/`.
