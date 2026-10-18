# Handoff — terreno editável da primeira ilha

**Branch:** `Staging`  
**Base:** `5a1d4a0a6fa6c9f451d95f0a9715a646b400aed9`

## Implementado

`game/scenes/first_island.tscn` contém as camadas editáveis `BaseTiles` (50.000 células), `Transitions` (645) e `Paths` (15). Elas usam o TileSet `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.tres`. O startup valida as camadas sem repintar do JSON; `isometric_3d_view.gd` constrói a superfície a partir de todas as células salvas. `first_island_layout.json` continua governando colisões, faixa bloqueada de água, limites, spawns, obstáculos e recursos.

## Próxima ação exata

No Godot 4.5.1, abrir `game/scenes/first_island.tscn`, editar uma célula em cada uma das camadas `BaseTiles`, `Transitions` e `Paths`, salvar, fechar e reabrir a cena e executar o jogo para conferir a apresentação/minimapa. Em seguida executar `tools/gameplay/test_fixed_map.gd`, `tools/gameplay/test_expanded_map_population.gd` e `tools/gameplay/smoke_playable_slice.gd`; medir a abertura/renderização em Android com 50.000 células. Godot não estava disponível neste ambiente, então essas verificações permanecem pendentes.

Ajustes de tiles pela cena são visuais. Se uma mudança também precisar alterar colisões, spawns, obstáculos ou recursos, atualizar `game/data/first_island_layout.json` e as regras correspondentes. A proposta de ilha irregular/elevações e o bestiário de expansão continuam aguardando revisão separada.
