# Registro de protótipos e validações

Esta lista registra a aprovação por fase. **Nenhuma tela de produção está aprovada nesta versão.** O protótipo mostra composição e transições ilustrativas, sem gameplay, contas, rede ou save real.

## Telas do MVP — v0.4 (arquivada para comparação)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_4.html`](../../docs/prototypes/mvp_ui_v0_4.html)

Fábio foi incluído como quarto personagem jogável após aprovação explícita do usuário. A tela acrescenta perfil e silhueta geométrica placeholder, preservando as três vocações selecionáveis. O protótipo aguarda validação; não representa sprite final e nenhuma tela de produção foi implementada.

**Ponto de validação desta versão:** confirmar se o perfil curto de Fábio e sua posição junto às outras três opções deixam clara a escolha de personagem.

## Telas do MVP — v0.3 (arquivada para comparação)

**Artefato desta versão:** [`docs/prototypes/mvp_ui_v0_3.html`](../../docs/prototypes/mvp_ui_v0_3.html)

**Versão anterior:** [`docs/prototypes/mvp_ui_v0_2.html`](../../docs/prototypes/mvp_ui_v0_2.html)

Maíra foi adicionada à escolha de personagem depois de o usuário aprová-la como jogável do MVP. A tela apresenta o terceiro perfil, sua descrição e um placeholder amarelo/dourado; ele não é arte final. As três vocações permanecem selecionáveis. Esta revisão da tela de personagem aguarda validação; nenhum fluxo de produção foi implementado.

## Telas do MVP — v0.2 (arquivada para comparação)

**Artefato desta versão:** [`docs/prototypes/mvp_ui_v0_2.html`](../../docs/prototypes/mvp_ui_v0_2.html)

**Versão anterior:** [`docs/prototypes/mvp_ui_v0_1.html`](../../docs/prototypes/mvp_ui_v0_1.html)

**Viewport-base:** Android em paisagem, proporção 16:9; layout adapta-se ao viewport.

**Estado geral:** v0.1–v0.6 permanecem arquivadas para comparação; v0.7 é a versão navegável atual e foi validada pelo usuário como protótipo de interface em 2026-10-15. Esse aceite não se estende às demais fases/telas, nem valida implementação, sprites, Godot, gameplay ou Android.
**Sprites:** placeholders geométricos; não representam sprites aprovados.

| Fase | Telas/estados cobertos | Estado | Próximo passo |
|---|---|---|---|
| S0 | Abertura, entrada de visitante, conta/vínculo, configuração inicial | em validação | Validar ordem de entrada, texto e opção offline |
| S1 | Gameplay, joystick, hotbar, minimapa, HP/MP, interação e zoom | em validação | Validar posição/quantidade dos controles e densidade do HUD |
| S2 | Equipamento + mochila/crafting, acampamento, pausa/save e resultado da expedição | em validação | Revisar matriz de equipamento, 24 espaços de mochila, painel de atributos e detalhes contextuais dos itens na v0.7 |
| S3 | Escolha de personagem/vocação, árvore, habilidades, criaturas e acampamento | em validação | Revisar imagem endgame e progressão da árvore, além do inventário e painel de atributos da v0.7 |
| S4 | Criar/entrar em LAN, aliado caído/reanimação, erro de conexão | em validação | Validar estados de cooperação e recuperação |
| S5 | Visitante, vínculo, status offline e conflito de sincronização | em validação | Validar explicação de origem do progresso e escolha de recuperação |
| S6 | Configurações, áudio, zoom, contraste e erros recuperáveis | em validação | Validar opções visíveis e mensagens compreensíveis |

### Perguntas para a revisão v0.2

1. A ordem `abertura → visitante/conta → personagem/vocação → criar/entrar na ilha` está clara e correta?
2. No HUD paisagem, joystick à esquerda e ataque + três skills à direita deixam espaço suficiente para o mapa e para a mochila/interação?
3. Os slots propostos (cabeça, peitoral, luvas, pernas, botas, arma, colar e dois anéis) fazem sentido para o inventário? Quer adicionar/remover algum espaço, como escudo?
4. As novas descrições de Melissa e Helena representam bem as personalidades que você imaginou?

**Feedback recebido:** usuário pediu remover idade das descrições, desenvolver as personalidades e reformular o inventário com slots de RPG para armadura e acessórios.

**Correções aplicadas:** descrições atualizadas no GDD, catálogo JSON e seleção de personagem; inventário v0.2 agora separa equipamento, mochila, detalhes do item e fabricação. Armaduras e acessórios aparecem como slots vazios/conceituais porque ainda não têm itens ou atributos definidos no catálogo.
**Aprovação explícita:** pendente; nenhuma implementação de tela está liberada.


## Telas do MVP — v0.7 (atual)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_7.html`](../../docs/prototypes/mvp_ui_v0_7.html)  
**Referência visual escolhida:** [`passive_skill_tree_endgame_reference.png`](../../docs/prototypes/assets/passive_skill_tree_endgame_reference.png) · PNG RGBA 1672×941 · SHA-256 `51b511eec2f98714bca7a9379f7bc4b84ad78b7475d30d1952c951f1ab8d2e0e`.

A v0.7 preserva a árvore visual da v0.6 e acrescenta o inventário em três colunas: itens equipados à esquerda, mochila com 24 slots ao centro e painel contextual à direita. A matriz de equipamento é 4×3 conforme a orientação do usuário. O painel direito inicia em Atributos; a seleção de item abre descrição, localização/status, atributos e ação contextual. O exemplo está no nível 4, com 3 pontos livres; FOR/AGI/INT brutos começam em zero. HP/MP base permanecem próprios de cada vocação, enquanto o preview soma os bônus derivados dos atributos pelos multiplicadores do GDD. A simulação não salva progresso.

**Estado:** aprovado como protótipo de interface em 2026-10-15, após validação explícita do usuário (“Protótipos validado.”). A aprovação limita-se à composição e às interações simuladas da v0.7; não aprova arte, implementação Godot, gameplay, Android nem a imagem da árvore como topologia exata.

### Implementação técnica da primeira fatia — comparação pendente

A fatia desktop está em `game/scenes/main.tscn`, com fluxo de início → seleção Warrior → sessão local → mapa e pausa. Em Godot 4.5.1 Linux headless, importação e smoke test de fluxo, atlas, mapa e movimento passaram; consulte [`PLAYABLE_SLICE.md`](../../docs/gameplay/PLAYABLE_SLICE.md) e `tools/gameplay/smoke_playable_slice.gd`. Essa verificação não renderiza uma captura de tela comparável: a revisão visual da cena contra a v0.7 em tamanho nativo/nearest e a validação Android permanecem pendentes. A implementação não está aprovada como UI final.

### Incremento solo S2 — 2026-10-16

A pedido do usuário, o jogo ganhou coleta, alvo/ataque/skills Warrior, curativo, inventário de materiais em três colunas, melhorias de refúgio, feedback e save. A composição parte da v0.7 aprovada; equipamentos continuam informativos e a árvore/LAN/conta ainda não foram implementadas. O smoke verifica os botões/roteamento e a seleção com evento de ponteiro, mas não faz comparação gráfica. Revisão visual lado a lado com a v0.7, legibilidade touch e aparelho seguem pendentes. Consulte [`MVP_BUILD_VALIDATION.md`](../../docs/gameplay/MVP_BUILD_VALIDATION.md).

## Telas do MVP — v0.6 (arquivada para comparação)

**Artefato:** [`docs/prototypes/mvp_ui_v0_6.html`](../../docs/prototypes/mvp_ui_v0_6.html)

## Telas do MVP — v0.5 (arquivada para comparação)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_5.html`](../../docs/prototypes/mvp_ui_v0_5.html)

Preserva a v0.4 e acrescenta uma árvore passiva navegável candidata: 25 círculos pequenos, 6 quadrados grandes, 3 origens em losango com um ator e a palavra “Actor” abaixo de cada uma. São 61 ligações bidirecionais entre Warrior (alto), Archer (esquerda) e Mage (direita). Selecionar um nó abre o painel de nome, efeito, tipo, custo e estado; desbloqueios adjacentes e pontos são simulados separadamente por vocação. A lista completa está em [CATALOGS_MVP.md](../Main/CATALOGS_MVP.md#9-talentos).

**Estado:** em validação explícita. A árvore e seus efeitos são candidatos de interface/conteúdo; o plano canônico de produção não foi substituído. Nenhuma UI de produção foi implementada.

### Perguntas para a revisão v0.5

1. A malha compartilhada e as origens Warrior no alto, Archer à esquerda e Mage à direita representam o fluxo que você imaginou?
2. A proporção de 25 círculos, 6 quadrados e 3 origens especiais está correta? O rótulo “Actor” e o painel lateral estão claros?
3. Os nomes, descrições e custos candidatos fazem sentido? O conjunto de 31 passivas custa 37 pontos, enquanto o nível 10 oferece 30; quer manter essa tensão de escolhas?


## Registro futuro por fase

Ao atualizar uma fase, preserve versões anteriores e acrescente a aprovação e o link para a versão validada. Após implementar, anote comparação visual, testes e dispositivo sem alterar retroativamente o resultado da revisão do protótipo.

### HUD retrato v0.8 — referência fornecida e implementação autorizada

- Data: 2026-10-16 UTC (2026-10-15 Recife).
- Origem: anexo do usuário `1001362477.jpg`; instrução explícita: implementar UI/HUD/visão conforme o protótipo, orientação 9:16, tela inteira, seleção melhor e dano flutuante. Essa instrução valida a referência para este incremento; não exige recriar e reapresentar uma alternativa antes da correção solicitada.
- Estado: referência aprovada para implementação por solicitação explícita.
- Viewport base: 720×1280; testes adicionais 720×1600 e 960×1280.
- Comparação: Godot 4.5.1/OpenGL Compatibility/Mesa llvmpipe em Xvfb; captura local `build/portrait-gameplay.png`.
- Desvios intencionais: mesma hierarquia com a arte pixel candidata da ilha; não reproduz dungeon, ouro, goblins nem habilidades ilustrativas fora do catálogo. Mochila usa seções verticais para caber no retrato.
- Aceite de aparelho Android permanece pendente; render desktop e manifesto não substituem teste no dispositivo.

## 2026-10-16 — Prancha pixel HUD selecionada pelo usuário

Solicitação explícita de colocar a prancha pixel art no repositório e substituir o HUD autoriza a integração dessa referência. Fonte `assets/ui/pixel_hud_v1/source_sheet.png` preservada byte a byte; regiões AtlasTexture em `regions.json` para barras, molduras, spells, joystick e navegação. Textos/HP/MP/EXP/cooldowns continuam valores reais do jogo, não números pintados na imagem. Barras recompõem o preenchimento para esconder os valores ilustrativos da fonte. Ícones em nearest com legendas compactas. Import, regressão de retrato e render Godot/Mesa passaram. Android físico segue pendente. Prancha é referência gerada com algumas junções entre peças, registradas no manifesto, sem aprovação implícita de todo o restante da arte.

## 2026-10-16 — Visão próxima oblíqua e HUD compacta (candidata)

Referência: anexos image(20261016-162830).png (estado anterior) e image(20261016-162915).png (objetivo). Pedido explícito autoriza implementar essa direção.

Mudanças: zoom lógico 150–300%, padrão200%, normalizado pelo lado curto do viewport; smoothing5; HUD de rosto, alvo somente selecionado, sem botão Auto ON; minimapa com posição real; controles reancorados e modais escalados em paisagem/retrato. Chão contínuo com bordas orgânicas, faces de relevo decorativas, props com pivô e Y-sort. Sprites de personagens e regras de combate/save preservadas.

Limites: top-down oblíquo com profundidade visual, não transformação isométrica64x32, nem reprodução integral do lago/ruínas. Arte candidata. Checkout recuperado do GitHub (branch feature/s02-pixel-hud-assets); alterações não publicadas de sessões anteriores não estavam disponíveis. Não afirmar que esta build contém regeneração/XP10x/inventário novos de outro checkout.

Verificações: Godot4.5.1 import e smoke de fluxo/coleta/combate/movimento; test_close_view em1280x720,720x1280,1920x1080; catálogo54 IDs; diff-check. Render gráfico bloqueado pelo ambiente (Xvfb não consegue criar sockets); Android físico e WebGL pendentes. Preview terrain é composição offline, não screenshot do jogo.

## UI 0.1.7 — referências fornecidas em 2026-10-17

O usuário identificou os anexos 3/4 como “como deveria ser” e instruiu aplicar essa composição ao jogo, corrigindo os anexos 1/2. Essas pranchas são o alvo visual fornecido e selecionado explicitamente para esta correção. A adaptação mantém GDD/pixel art, equipamento fixo e conteúdo real; não adota ouro ou valores ilustrativos. Comparação implementada e capturada em `docs/art/evidence/mobile_017/`; ícones/molduras nativos em `assets/ui/classic_v2/`. Revisão de produção em Android ainda pendente; não confundir a direção selecionada com aceite físico da build.

## Reanimação e retorno — referência de fluxo v0.3 — 2026-10-17

- Artefato consultado: `docs/prototypes/mvp_ui_v0_3.html`, estado navegável “Aliado caído”. A solicitação atual autorizou implementar esta tela como referência de fluxo; a página protótipo continua uma simulação e não passa a validar multiplayer, UI de produção ou Android.
- Implementação comparada: janela Godot mostra prazo de 60 s, regra de reanimação em 5 s com indisponibilidade de co-op declarada no solo, conteúdo exato que irá para a mochila persistente e botão “Renascer no acampamento”. A perda é aplicada somente no respawn; XP e equipamentos são mantidos.
- Reanimação é exposta por `FirstIsland.request_ally_revive(reviver_id)` e sinais de início/conclusão/cancelamento para um host futuro. Não há segundo jogador ou transporte LAN nesta versão. Revisão em aparelho Android e comparação gráfica seguem pendentes.


## Kit UI Crystal v2 — referência enviada em 2026-10-17

O usuário pediu a implementação completa do kit mostrado nos anexos (mockup de interface e folha de sprites) no projeto e solicitou novas builds Web/APK. A solicitação autoriza essa composição como referência visual desta implementação. A produção aplica sprites do kit aos fluxos reais já existentes e preserva indisponíveis os sistemas que ainda não existem. Os três conceitos separados de personagens não são usados como sprites de runtime. Essa referência não valida a execução gráfica em navegador nem o teste físico Android.


### APK de preview publicado na branch — 2026-10-17

O usuário pediu armazenar o APK no repositório. A branch do kit contém `artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk` e [link direto para baixar o APK](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk). É um artefato debug ARM64-only, derivado da exportação de preview dual-arch; 32 bits e instalação física não foram validados. O link de branch não representa merge em `main`.

## Reconstrução da referência aprovada — 2026-10-18

Na conversa o usuário confirmou “Prototipagem aprovada”, apontou divergências de HUD/inventário/minimapa e autorizou “Reconstrua e salve no repositório”. Esta autorização foi reutilizada para restaurar a composição solicitada sem nova rodada de confirmação. Comparação gráfica Godot4.5.1 realizada com captura de HUD, inventário, lobby e seleção no relatório `docs/gameplay/HUD_RECONSTRUCTION_019.md`. Campos de equipamentos e spells ampliados, minimapa circular e funções reais de navegação foram conferidos. Arte de Archer/Mage ainda compartilha Warrior; botões usam texto. Não representa aprovação de nova arte nem teste Android físico.

## Mapa global e ilha irregular — protótipo v0.1 — 2026-10-18

- Artefato navegável: `docs/prototypes/global_map_island_v0_1.html`; notas/prompt: `docs/prototypes/global_map_island_v0_1.md`; conceito da ilha em `docs/prototypes/assets/irregular-island-map-concept-v0.1.png`.
- Abrir o minimapa demonstra a janela global; X/Escape retornam à mesma tela; zoom no HUD e mapa compartilha o estado; o indicador de simulação continua avançando. HTML responsivo; comportamento simulado, sem código Godot/runtime.
- O conceito preserva o alvo de 250×200 = 50.000 tiles e propõe costa irregular, praia, floresta, lago cristalino, platôs, penhascos/rampas e região corrompida ao longe. A imagem é concept, não mapa tileável ou asset final.
- O anexo `isometric_tilemap_layers_v0_1.html` foi consultado como amostra de camadas: 64×32, quatro layers, platô/rampa, colisão ilustrada e Y-sort. Não é uma aprovação para substituir a grade atual 32×32/Câmera3D.
- Revisão solicitada: fluxo sem pause, zoom compartilhado, conceito/relevo e escolha entre conservar 32×32 ou testar uma amostra 64×32 isolada. Implementação de produção pendente.

## Mapa irregular e alocação do bestiário — protótipo v0.3 — 2026-10-18

- **Artefatos:** [prancha navegável](../../docs/prototypes/global_map_island_v0_3.html) e [notas da revisão](../../docs/prototypes/global_map_island_v0_3.md).
- A pedido do usuário, a escala lógica do protótipo visual foi ampliada para 400×250 = 100.000 células. O jogo permanece em 250×200 = 50.000; nenhum dado/runtime foi alterado.
- Acrescentados 30 pontos de alocação candidatos: 4 litoral/enseadas, 12 floresta ocidental, 8 platôs/interior e 6 faixa corrompida futura. O usuário informou que o bestiário está sendo atualizado para 30 tipos; os pontos indicam habitats propostos e ainda não se ligam a nomes de criaturas nem coordenadas finais.
- A prancha usa SVG ilustrativo, links para os três tilesets candidatos e controle para ocultar/mostrar os marcadores. Não há tilemap, spawns, colisões ou cena Godot implementados.
- **Estado do gate:** em validação explícita. Rever composição, 400×250 e divisão 4/12/8/6. Não iniciar produção até aprovação; depois testar uma amostra representativa no destino antes de ampliar o lote.

## Bestiário de expansão — concept v0.1 — 2026-10-18

- Fonte consultada: GDD, catálogos e conteúdo de balanceamento. Bestiário MVP tem `fox`, `wolf`, `bear`; candidatos e derivações estão em `docs/art/candidates/BESTIARY_EXPANSION_CANDIDATES_V0_1.md`.
- Prancha `docs/art/candidates/bestiary-expansion-concepts-v0.1.png` gerada como concept de dez candidatos, não sprite sheet nem entrada de catálogo. Espécies/variantes de expansão permanecem fora do MVP até aprovação.
- Gate em validação: aprovar ou corrigir lista e concept; após aprovação, produzir apenas uma amostra de sprite para revisar antes de qualquer lote.

## Atualização de conteúdo — protótipo v0.1 — 2026-10-18

- **Objetivo:** verificar conteúdo ao iniciar, oferecer atualização, indicar progresso/verificação, recarregar o jogo e permitir continuar ou tentar novamente quando a atualização falhar.
- **Artefato:** [`docs/prototypes/content_update_v0_1.html`](../../docs/prototypes/content_update_v0_1.html).
- **Viewport:** retrato, responsivo para a tela inicial mobile.
- **Simulado:** consulta, release `1.0.1`, notas, download, integridade, recarregamento e erro; o protótipo não acessa GitHub nem grava progresso.
- **Feedback:** o usuário aprovou explicitamente o protótipo (“prototipo aprovado.”) em 2026-10-18.
- **Estado do gate:** aprovado para implementar o fluxo. Isso não valida APK, rede real ou aparelho Android.
- **Comparação após implementação:** `game/scenes/update_boot.tscn` e `game/scripts/ui/update_boot.gd` preservam a ordem de estados; a UI lê release, tamanho, notas e progresso reais. Ao instalar, a Godot monta o PCK verificado e recarrega a cena de jogo. Testes Android e download real ainda pendentes.


## Logo do jogo no ícone e na inicialização — 2026-10-18

- Referência: anexo `icone Ilha do Cristal.jpg`, arte quadrada com cristal azul, moldura e wordmark. O usuário pediu explicitamente que fosse usada como ícone do APK e logo antes de iniciar o jogo; essa seleção aprova a referência para este incremento sem redesenho da marca.
- Aplicação: ícone principal com a arte integral, ícone adaptativo com a logo contida na área segura, símbolo monocromático de cristal derivado do centro da marca, splash nativa e cabeçalho da tela de verificação. O fluxo e a gameplay não mudam.
- A comparação de produção é feita no Godot após a importação. Exportação/instalação e revisão em Android físico continuam pendentes.


## Wiki — tema claro e controle de modo escuro v0.1 — 2026-10-18

- **Objetivo:** revisar a paleta clara, o controle de ativar/desativar modo escuro e a legibilidade da wiki em ambas as aparências.
- **Artefato:** [`docs/prototypes/wiki_theme_v0_1.html`](../../docs/prototypes/wiki_theme_v0_1.html).
- **Simulado:** a wiki mantém o modo escuro atual como padrão; o botão alterna entre as paletas escura e clara, atualiza o rótulo acessível e grava a preferência localmente. O conteúdo é representativo, sem conexão ao catálogo.
- **Feedback:** o usuário aprovou explicitamente o protótipo e solicitou a publicação na branch `Staging` em 2026-10-18.
- **Estado do gate:** aprovado para implementar a alternância de tema; a validação foi limitada à aparência e ao comportamento demonstrados no protótipo.
- **Implementação:** `docs/wiki/index.html` aplica a preferência antes da primeira pintura; `wiki.css` define paletas completas; `app.js` alterna o tema, atualiza o estado acessível e salva a preferência. README e roadmap também documentam a opção.
- **Verificação:** testes automatizados e revisão visual em navegador não foram executados nesta atualização.

### Bestiário — prancha conceitual de poses estáticas v0.1 — 2026-10-18

- **Artefatos:** [prancha PNG](../../Docs/art/candidates/bestiary-static-concepts-30-v0.1.png) e [índice com nomes, HP, dano e ordem](../../Docs/art/candidates/BESTIARY_STATIC_CONCEPTS_30_V0_1.md).
- **Conteúdo visual:** 30 poses únicas em grade 5×6, sem animações, na ordem row-major do índice. Direção tropical pixel art com acentos cianos e violetas, usando as referências do projeto.
- **Arquivo:** 1145×1374 px, PNG RGBA com fundo transparente; células de 229×229 px. As 30 células foram recortadas sem redimensionar ou alterar o alpha e têm metadata individual.
- **Origem/licença:** imagem conceitual original gerada para esta revisão; não contém sprites dos pacotes CC0 pesquisados.
- **Estado da integração:** 30 fichas no catálogo, com uma região recomendada por espécie; a cena base é reaproveitada nas espécies sem prefab próprio. O layout e seus spawns não foram alterados nesta atualização. Os concepts continuam estáticos, não são atlas nem arte de produção.
- **Próximo passo:** importar no Godot e revisar tamanho, pivô, alpha e contato em espécies pequenas, médias e grandes. Valores e loot das fichas novas exigem playtest.
