# Handoff — mapa de 100.000 células no loop jogável

**Branch:** `Staging`  
**Commit da implementação:** `8c2b6ba9a7392aa8fa52bcdd0682bbcef4477f3e`  
**Commit de normalização do diff:** `467e5ba5a8baf6218f6764793436e91133c71293` (apenas finais de linha)  
**Base anterior:** `4c6cdd5a8dfc90963d1275c2c35320cf90862244`  
**Cena principal:** `game/scenes/first_island.tscn`

## Próxima ação exata

Abrir o checkout completo no Godot 4.5.1 e validar a primeira ilha no Play normal: conferir encaixe dos tiles durante movimento, leitura dos 30 pontos e da legenda, câmera/zoom, interação e combate. Depois medir culling e desempenho em Android e revisar as rotas/rampas.

## Estado verificado

- Grade lógica de 400×250 = 100.000 células; 6.300 tiles isométricos agrupam 4×4 células.
- `first_island_layout.json` contém 30 pontos ligados aos 30 IDs do catálogo nas zonas 4/12/8/6. O jogo desenha os pontos e a legenda no minimapa e os pontos coloridos no terreno.
- A simulação instancia 30 atores com as cenas de combate disponíveis: raposa, lobo e urso. Os outros 27 IDs estão associados às áreas, mas ainda não têm prefabs de combate próprios.
- O bake estático passou. A execução headless da cena principal validou deslocamento de 165 px, colisão em `IslandShoreBoundary_00` e `LagoonBoundary_00_00`, e jogador dentro da ilha após os testes.
- Essa execução ocorreu no checkout local esparso, sem a folha UI `assets/ui/crystal_v2/sheet.b64`, `assets/ui/app_icon.png` e a aparência da Melissa. Os avisos são de assets ausentes dessa cópia; não foi feita revisão visual completa em janela nem em Android.

## Pendências

- Validar visualmente a apresentação no Play com o checkout/assets completos.
- Medir uso de memória, culling e desempenho do mapa em Android; testar rotas/rampas.
- O fluxo separado de abrir um mapa global no minimapa continua pendente.
