# Protótipo do mapa global da ilha v0.1

**Fase:** S1 — mapa/HUD. **Status:** em validação. **Viewport:** HTML responsivo, com foco em retrato Android; não valida dispositivo. **Arquivo navegável:** [`global_map_island_v0_1.html`](global_map_island_v0_1.html).

## Fluxo representado

- Tocar no minimapa circular abre a janela do mapa global; X, clique fora e Escape fecham e retornam à mesma tela de jogo.
- Os controles de zoom dentro e fora da janela compartilham o mesmo estado. O mapa global permanece enquadrado e o polígono de câmera muda para indicar a visão atual.
- O estado “simulação ativa” avança enquanto a janela fica aberta, para demonstrar que o mapa não pausa o mundo.
- A arte conceitual mostra costa irregular, praia, floresta, lago cristalino, platôs/rampas e uma área corrompida futura. O alvo do mapa continua 250×200 = 50.000 células.
- A escala 64×32 do protótipo de camadas enviado não foi escolhida; a implementação atual permanece grade 32×32 em Camera3D até decisão explícita.

## Limites

A imagem do mapa é concept, não layout tileado, terreno compilável ou arte de produção. A HUD de fundo e os marcadores são dados estáticos. Não há input de jogo, inimigos reais, pause, combate, saves, navegação real, collision layers nem medição de performance.

## Prompt usado no mapa conceitual

Ferramenta: imagegen integrada, modo de geração de imagem. Prompt final: “Create a complete irregular island map in a high three-quarter top-down angle for a classic family-friendly pixel-art RPG. Show one jagged island surrounded by deep blue ocean: sandy southwest beach and shipwreck; varied central/western green forest; a distinct cyan crystal lake near the center; a stepped rocky plateau with cliffs and a winding walkable ramp; and a distant northeast violet-corrupted region with an inactive ruined castle, explicitly a far-future landmark. Keep a connected beach-to-forest route. Crisp deliberate square pixel clusters, readable at mobile-map size, warm daylight in safe regions and restrained violet haze only in the distant corrupted zone. Landscape 3:2, entire island centered, north at top. No UI, labels, text, grid, icons, characters, monsters, watermark, rectangle bands, repeated tile pattern, extra continents, photorealism, painterly blur or 3D render. Concept art only, not production tiles.”
