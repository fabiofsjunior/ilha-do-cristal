# Terreno tropical oblíquo — candidato

Referência visual: imagem enviada pelo usuário em 2026-10-16 (`image(20261016-162915).png`). Implementação solicitada diretamente pelo usuário; revisão visual no aparelho permanece pendente.

O plano mantém as coordenadas originais em SQMs de 32 px, layout, IDs de coleta e colisões. Superfície orgânica contínua substitui visualmente as faixas ortogonais. Faces de rocha, troncos, copas e cristal recebem volume local em perspectiva oblíqua. Não há transformação isométrica matemática das coordenadas, alteração do movimento nem novos lagos bloqueantes.

`ground.png`: 2048×1408 RGBA, chão na resolução nativa do mapa. `generate_tropical_oblique.py` produz formas e texturas de terreno determinísticas; estes são assets candidatos, não uma reprodução integral da arte de referência. As TileMapLayers antigas continuam carregadas como dados, mas ficam ocultas no render. A camada de chão é um Sprite2D, não um atlas isométrico.

Props usam nearest, sem mipmap, pivô na base e Y-sort compartilhado com atores. Colisões e pontos de coleta existentes foram preservados. Não há novo conteúdo de gameplay/ruínas/lagos. Nenhuma animação de personagem foi alterada.

`docs/art/evidence/terrain/tropical_oblique_surface_preview.png` é composição offline da superfície e props, sem personagens/HUD, e não comprova render Godot nem Android.

Validação técnica: importação headless Godot 4.5.1 sem erro após integração. Avaliação visual em escala final e aparelho cabe ao teste integrado.

## Palmeira representativa gerada

`palm_generated_source.png` foi criada com imagegen integrado, sem fallback CLI. `palm_generated.png` usa redução uniforme 1086×1448 → 96×128 com nearest; a fonte completa foi preservada, sem recorte automático, binarização ou limpeza de alpha. Redução descarta detalhe e não significa preservação integral da qualidade. Pivô visual (69,126), compensado em runtime para (69,118) de modo que o pé continue no centro y=8 do collider existente. A peça substitui apenas as palmas costeiras; nenhum lote adicional foi gerado. Metadata e prompt em `palm_generated.json`. Inspeção da imagem reduzida confirmou silhueta/tronco legíveis; importação/render/dispositivo têm gates separados.
