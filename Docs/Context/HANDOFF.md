# Handoff — mapa irregular v0.3 aguardando validação

**Branch:** `Staging`  
**Commit base antes deste registro:** `195a3d3445ab33ab456f9c2b612844d337265060`

## Próxima ação exata

Aguardar o usuário revisar [a prancha v0.3](../../docs/prototypes/global_map_island_v0_3.html). Registrar se aprova ou ajusta a escala lógica proposta de 400×250, a composição e a divisão dos 30 pontos (4 litoral, 12 floresta, 8 platôs/interior, 6 faixa corrompida futura). O bestiário está sendo atualizado para 30 tipos; não atribuir nomes ou spawns definitivos até a lista estar pronta.

Se a prancha for aprovada, criar uma amostra representativa na cena alvo e apresentar para revisão antes de qualquer implementação em lote. Não expandir o mapa de produção para 100.000 células sem aprovação e validação de colisões, rampas, culling e desempenho.

## Estado e limites

- O jogo continua com mapa de 250×200 = 50.000 células.
- A v0.3 é um protótipo HTML/SVG; os 30 pontos são distribuição candidata por habitat, não catálogo nem spawns de runtime.
- A arte isométrica candidata ainda exige recortes/importação apropriados; nenhuma cena Godot, colisão, save, câmera ou dado de produção foi alterado.
- Revisões pendentes: validar composição, escala, distribuição por habitat e fluxo global v0.1. Não houve teste de runtime neste incremento.
