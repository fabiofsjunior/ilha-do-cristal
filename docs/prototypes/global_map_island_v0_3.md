# Protótipo de mapa e zonas de monstros v0.3

**Fase:** S1 — mapa/HUD. **Status:** em validação. **Prancha navegável:** [global_map_island_v0_3.html](global_map_island_v0_3.html).

## Revisão desta versão

- A composição candidata da ilha agora representa a escala lógica proposta de **400×250 células = 100.000** (50.000 acima dos 250×200 atuais). Isso descreve a escala do protótipo; o mapa de produção continua em 50.000 células até uma revisão e implementação aprovadas.
- O mapa traz **30 pontos propostos**, um para cada tipo previsto enquanto o bestiário é atualizado. A cor agrupa o habitat, sem vincular ponto a espécie ou definir coordenada final: 4 litoral/enseadas, 12 floresta ocidental, 8 platôs/interior e 6 faixa corrompida futura.
- A faixa corrompida e as ruínas permanecem conteúdo futuro. Os pontos nela são uma indicação para expansão, fora do escopo jogável do MVP atual.
- Os controles do HTML permitem mostrar/ocultar os pontos de monstros e as demais camadas.
- A composição mantém praia/naufrágio no sudoeste, floresta a oeste, lago cristalino central, cachoeira e platôs ao norte/leste, e ruínas violetas distantes a nordeste.

## Limites

A prancha é um SVG ilustrativo e não é mapa tileado, cena Godot nem asset de produção. A escala de 100.000 células é proposta para o protótipo visual; não altera mapa, spawns, colisões, rotas, salvamento ou desempenho do jogo. Os 30 pontos e a divisão por bioma são candidatos de revisão, não dados do bestiário/runtime. O tileset candidato ainda não está importado como TileSet de produção e os recortes descritos em sua documentação são manuais.

## Referências de tileset

- [Tileset isométrico](../../assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_tileset_isometrico_v1.png)
- [Elementos isométricos](../../assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_elementos_isometricos_v1.png)
- [Padrões do tilemap](../../assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_padroes_tilemap_v1.png)

## Revisão solicitada

Confirmar a composição, a escala proposta de 400×250 e a distribuição de 4/12/8/6 pontos. Os nomes e posições finais só serão associados quando a lista atualizada dos 30 tipos estiver disponível. Após aprovação do protótipo, a próxima etapa é uma amostra representativa na cena alvo para revisão antes de qualquer implementação em lote.
