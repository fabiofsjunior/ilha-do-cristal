# Handoff — mapa global e conteúdo candidato

**Branch de trabalho:** `feature/s04-global-map-island-content`, baseada no HEAD anterior `6133ee6`. O HEAD desta branch registra os protótipos e notas descritos abaixo; nenhum código de produção foi alterado. A implementação atual do jogo/APK continua a reconstrução 0.1.9, com código no commit `5f14e623f6787e97e1f6b4aa58778cd132f247f8`.

## Estado do mapa

O mapa existente é 250×200 = 50.000 tiles, na grade candidata 32×32. `first_island_layout.json` usa bandas retilíneas e áreas retangulares de floresta; o bake gera 50.000 bases, 645 transições e 15 overlays. Não há alturas por célula, costa recortada, rampas/penhascos com colisão poligonal ou Terrain Sets de autotiling. O baker determinístico passou.

Referência de revisão: `docs/prototypes/global_map_island_v0_1.html` e `docs/prototypes/assets/irregular-island-map-concept-v0.1.png`. O anexo `isometric_tilemap_layers_v0_1.html` demonstra 64×32 e quatro layers, mas não foi aprovação de migração. O protótipo de UI demonstra abrir pelo minimapa, fechar por X/Escape, não pausar, e manter zoom sincronizado.

## Estado do bestiário

GDD/Catalogs têm somente `fox`, `wolf`, `bear` no MVP. Os dez candidatos de expansão e os vínculos à lore estão em `docs/art/candidates/BESTIARY_EXPANSION_CANDIDATES_V0_1.md`, com a prancha `docs/art/candidates/bestiary-expansion-concepts-v0.1.png`. Nada foi adicionado ao catálogo runtime. Concept art não é atlas; a metodologia exige amostra de uma criatura e revisão antes de produzir lote.

## Próxima ação exata

Obter o retorno do usuário sobre: (1) o fluxo do mapa global sem pause e o zoom compartilhado; (2) a forma da ilha e suas elevações; (3) 32×32 atual versus amostra isolada 64×32; (4) aprovação/revisão dos dez monstros e da prancha. Depois implementar somente as decisões aprovadas, adicionar regressões de overlay/câmera, bake/altura/colisão e revisar captura Godot. Gerar a APK nova após implementação e validação.

## APK e pendências

A APK entregue anteriormente é `Ilha-do-Cristal-0.1.9.apk` (source code commit acima). Ela não contém a nova janela de mapa nem o terreno proposto. Instalação/toque/performance Android físico e LAN em dois aparelhos continuam pendentes. Combate, coleta/itens e saves LAN do host continuam próximos passos independentes registrados no handoff anterior.
