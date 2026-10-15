# Demo jogável — primeira fatia

**Estado:** cenas e scripts de gameplay implementados na branch `feature/s01-gameplay-slice`. Este ambiente não tem Godot nem Android SDK, então a importação e a execução no motor continuam pendentes. Não é aceite de S0/S1 nem validação visual.

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

Ainda são gates de S0/S1: importar todas as cenas e recursos no Godot sem erros; comparar o mapa/controles com a v0.7; testar Android por 10 minutos em paisagem, em dois tamanhos de tela e zoom de 50–125%; confirmar leitura, toque, colisão, desempenho e estabilidade. Este runner não contém `godot`, `godot4` nem `adb`, portanto nada disso foi executado aqui.
