# Pranchas isométricas candidatas

As pranchas-fonte são PNGs RGBA de 1254 × 1254 px, com organização visual de 8 × 8 elementos. O fundo tem transparência real, além de resíduos semitransparentes próximos a algumas peças. A divisão não é uniforme; usar limites de recorte medidos manualmente, sem partir a imagem em oito células iguais.

## Amostra técnica v0.2

Abra `tools/world/ilha_cristal_tilemap_review_v0_2.tscn`. Ao iniciar, a cena recorta as imagens originais em memória e monta TileSets Godot temporários; não depende de cópias processadas das pranchas. As superfícies planas são reencaixadas no losango 128 × 64 px esperado pelo renderer 2.5D. O atlas de objetos seleciona 15 props representativos de praia, floresta, planalto e corrupção, com pivô visual na base.

A amostra cobre uma grade 16 × 10 e mostra 30 marcadores de habitat sem IDs de espécie. O parâmetro de cobertura fica em 1.0 apenas nessa cena; as outras cenas mantêm o valor padrão de 1.10. A cena não altera o mapa real, spawns, colisões, saves ou os assets usados no jogo.

**Estado:** correção de encaixe preparada e aguardando revisão visual explícita antes de expandir o lote de arte ou substituir assets existentes.
