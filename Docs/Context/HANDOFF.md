# Handoff — Ilha do Cristal, amostra técnica v0.2

**Branch:** `Staging`  
**Commit da amostra em Staging:** `66fbf6fdf14e1272f6df2dbddd60595239618895`  
**Base anterior:** `8c70debdab37f0589298354c847828e7b17eb8f7`  
**Artefato de revisão:** `tools/world/ilha_cristal_tilemap_review_v0_2.tscn`  
**Captura local:** `outputs/ilha-cristal-tilemap-review-v0.2.png`

## Próxima ação exata

Apresentar a captura da amostra v0.2 ao usuário e pedir revisão do encaixe entre as faces, das transições de costa e da leitura dos quatro habitats. O usuário já aprovou o protótipo de composição v0.3 (400×250 e distribuição 4/12/8/6); aguardar validação explícita da amostra de arte antes de expandir os atlas ou alterar cenas e dados de runtime.

## Estado e limites

- O jogo mantém o mapa de produção de 250×200 = 50.000 células. Não houve alteração de mapa, colisões, saves ou spawns.
- A cena candidata é isolada, usa um patch 16×10 no renderer 2.5D e mostra 30 alocações por habitat sem atribuir espécies.
- A cena recorta as imagens-fonte versionadas e compõe os TileSets candidatos em memória; a face de terreno alinha ao UV 128×64. A cobertura 1.0 fica isolada nessa cena e o padrão 1.10 permanece nas demais.
- A cena foi executada visualmente no Godot 4.5.1. A importação completa do checkout esparso registra a ausência de `assets/ui/app_icon.png` em uma tela não relacionada. Não houve teste Android ou de desempenho em 100.000 células.

## Bloqueios e perguntas abertas

- Aceite explícito da amostra corrigida ou novos ajustes de alinhamento/shoreline.
- Após a aprovação, integrar a arte em lote; para expansão runtime a 100.000 células ainda validar colisões, rampas, culling e desempenho.
- Associar os marcadores às 30 espécies e fixar coordenadas/quantidade de spawns somente em uma atualização própria do layout.
