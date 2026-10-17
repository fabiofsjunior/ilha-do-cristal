# Demo jogável — primeira fatia

> Registro histórico da primeira fatia de navegação e movimento. O incremento solo seguinte e os comandos atuais estão em [MVP_SOLO_TEST.md](MVP_SOLO_TEST.md). As listas de funcionalidades ausentes abaixo descrevem a entrega anterior.

**Estado:** cenas e scripts de gameplay integrados em `feature/fabio-warrior-stage1`. Godot 4.5.1 Linux headless importou o projeto e passou o smoke test automatizado de fluxo, atlas, mapa, movimento, colisão e pausa. O preset Web exporta a build para `build/web/`; a validação em navegador, a revisão visual e o aceite de S0/S1 continuam pendentes. Android também continua pendente.

## Fluxo

1. **Início:** continuar como visitante abre a seleção. Esta fatia não cria conta.
2. **Personagem/vocação:** quatro aparências Warrior (Melissa, Helena, Maíra e Fábio) usam os atlas atuais e permitem selecionar uma. Archer e Mage não são selecionáveis nesta fatia.
3. **Criar/entrar na ilha:** “Hospedar solo” abre a sessão local de demonstração. “Entrar” mostra erro mockado e recuperável; nenhum endereço é usado e não há rede LAN.
4. **Gameplay:** o mapa preserva a aparência escolhida. A pausa permite retomar, voltar à sessão ou ao início.

A UI navegável v0.7 foi validada pelo usuário em 2026-10-15. Esta fatia implementa somente o trecho de navegação e movimento necessário para a primeira demonstração; inventário, árvore, conta, LAN e demais ações simuladas no protótipo continuam fora do jogo.

## Controles

- Teclado: **WASD** ou **setas** para mover em oito direções; **E** para tentar interagir; **Esc** ou **P** para pausar.
- Toque/desktop: arraste o joystick visível no canto inferior esquerdo; o ponteiro pode sair da área do joystick enquanto arrasta. O botão **Pausa** abre o overlay e **Interagir** tenta ativar o cristal quando o jogador está perto.
- Os botões −/+ ajustam a câmera entre zooms de 50%, 75%, 100% e 125%; início em 75%.

## Jogador e arte

Os pares idle/walk vêm de `game/data/player_appearances.json` e dos metadados dos quatro Warriors. A execução constrói `AnimatedSprite2D` com `AtlasTexture`, lê célula, pivô, direções e FPS da metadata, e usa nearest. Cada aparência tem 8 direções, idle 4 quadros a 6 FPS e walk 6 quadros a 10 FPS. O leitor aceita tanto metadata plana quanto `animations.idle/walk` (Helena usa a forma aninhada).

Os atlas PNGs de personagem não foram reprocessados nem alterados. Os estados originais permanecem `corrigir` e `approved:false`; esta implementação não é aprovação artística. Não há sprites novas de personagem.

## Mapa, câmera e colisão

`game/data/first_island_layout.json` descreve uma faixa inicial estática de 64×44 células (2.048×1.408 pixels em célula candidata de 32×32). A cena compõe os 17 tiles base, 24 transições e 15 overlays do atlas `terrain_mvp_candidate_v1`; usa todas as variantes de base, as três famílias completas de transição, uma área de floresta e uma rede de caminho conectada com todos os overlays. O mapa não reduz a composição prevista de 56 tiles.

A água inicial, as bordas do mundo, árvores e pedras placeholder têm colisão. Árvores/pedras são proxies geométricos temporários, não assets aprovados. A câmera segue o jogador, respeita as bordas, não suaviza e usa nearest/pixel snap para evitar blur. Zoom e composição precisam de inspeção no motor e em aparelho real.

As bandas base preenchem as 2.816 células do mapa. A floresta substitui células base dentro de sua área, e os overlays transparentes do caminho são desenhados sobre essa superfície; tiles de transição compõem suas próprias células sem deixar buracos. Uma inspeção estática Pillow/layout confirmou a presença de praia, floresta, caminho, spawn, cristal e proxies; ela não é screenshot/render do Godot e não substitui a revisão no motor.

O cristal é um marcador geométrico demonstrativo; ao aproximar e interagir, exibe uma mensagem. Não cria item, drop, objetivo persistente ou progresso.

## O que ainda não existe

Sem combate, criatura, coleta, inventário funcional, construção, progressão, save, multiplayer, conexão LAN, autenticação ou sincronização. “Hospedar solo” é apenas uma entrada local ao mapa. A escolha Warrior/appearance não representa um personagem persistido.

## Rodar e validar

Com Godot 4.5.1 estável instalado, abra o projeto na raiz do repositório e rode a cena principal (`project.godot` aponta para `game/scenes/main.tscn`). O harness técnico de sprites permanece em `tools/art/sprite_test/sprite_test.tscn`; selecione e rode essa cena separadamente quando necessário.

Validação estrutural independente do motor:

```sh
python3 tools/gameplay/validate_playable_slice.py
python3 tools/art/validate_mvp_terrain_tileset.py
python3 tools/validate_catalogs.py
```

Ainda são gates de S0/S1: testar o pacote Web em navegador com WebAssembly/WebGL 2; comparar visualmente o mapa/controles com a v0.7; revisar a leitura em escala nativa e nearest; testar Android por 10 minutos em paisagem, em dois tamanhos de tela e zoom de 50–125%; confirmar leitura, toque, colisão, desempenho e estabilidade. O runner não oferece navegador gráfico para revisão visual nem aparelho/SDK Android.

### Exportação Web

O preset `Web` está em `export_presets.cfg`. Com os templates de exportação do Godot 4.5.1 instalados, gere o pacote completo (HTML, JavaScript, WebAssembly e PCK) assim:

```sh
mkdir -p build/web
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --export-release Web build/web/index.html
```

Sirva a pasta por HTTP para executar no navegador; o arquivo `index.html` não deve ser aberto via `file://`:

```sh
python3 -m http.server 8000 --directory build/web
```

Abra `http://localhost:8000/`. Os controles são os mesmos da demo desktop. O pacote ZIP entregue desta exportação é `build/ilha-do-cristal-web.zip`. O navegador deste runner não está disponível, então o carregamento final em navegador ainda não foi verificado.

No Windows, `Testar_Jogo_Web.bat` inicia o servidor em `127.0.0.1`, abre o navegador quando a página responde e encerra com `Ctrl+C`. Requer Python 3. Para validar o servidor sem abrir o navegador, use `python tools/web/serve_web_build.py --no-browser`.

### Verificação Godot 4.5.1 em Linux headless

O binário oficial `Godot_v4.5.1-stable_linux.x86_64` foi obtido para esta sessão e fica localmente ignorado pelo Git na raiz. Comandos executados:

```sh
./Godot_v4.5.1-stable_linux.x86_64 --headless --editor --path . --import --quit
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --quit-after 300
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --script res://tools/gameplay/smoke_playable_slice.gd
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --script res://tools/art/sprite_test/check_scene.gd
```

Importação, execução da cena principal, smoke test, QA técnico de atlas e exportação Web passaram. O smoke test confirma início → seleção → sessão → ilha, carregamento das quatro aparências Warrior, 2.816 células de base, caminho, movimento pelo joystick, bloqueio da água e pausa/retorno. O teste de atlas percorre 240 frames/seleções e 48 estados de controles. `assets/references/generated-candidates/maira_warrior/` contém 12 fontes PNG truncadas já versionadas; não são usadas pelo jogo e a pasta tem `.gdignore` para evitar que o importador as trate como recursos de runtime. As fontes continuam sem recuperação e o estado artístico permanece **CORRIGIR**. Sem navegador/servidor gráfico neste runner, não houve revisão visual em tela nativa/nearest nem teste da build Web em navegador; Android e aparelho também seguem pendentes.
