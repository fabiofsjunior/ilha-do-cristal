# Handoff — atlas tropical para pintura manual

**Branch:** `Staging`  
**Base desta alteração:** `9f43dad7d0d1d931914401eb8a83ac590fb4ee90`

## Implementado

A folha enviada foi limpa e cortada em 64 slices RGBA de 128×128. `assets/environments/tropical_manual_v1/` contém o atlas, os TileSets e o manifesto. `ManualTerrain` expõe os IDs 00–39; `ManualProps`, 40–63. Cada tile ocupa 4×4 SQMs da grade de jogo. As camadas começam vazias e a apresentação 2.5D lê as alterações salvas na cena; o mapa original de 50.000 células, colisões e spawns seguem intactos.

## Próxima ação exata

No Godot 4.5.1, abra `game/scenes/first_island.tscn`. Selecione `ManualTerrain` na árvore da cena, abra o painel TileMap e pinte o terreno; use `ManualProps` para vegetação, rochas e objetos. Salve a cena, feche e reabra para confirmar a persistência. As células manuais são 128×128 px (4×4 SQMs). O layout de colisões, limites, spawns, obstáculos e recursos continua em `game/data/first_island_layout.json`.

## Validação

O validador estrutural da folha, dos 64 slices, dos TileSets e das referências da cena passou. A importação real, a pintura/salvamento/reabertura no editor e o teste em Android ainda precisam ser feitos no Godot instalado no computador de desenvolvimento.
