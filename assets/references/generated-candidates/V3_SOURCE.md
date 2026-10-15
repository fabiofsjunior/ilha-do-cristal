# Melissa Warrior — correção focada V3

**Estado: corrigir; não aprovada.** Somente N/S, idle 4 e walk 6. A V3 não substitui nem aprova a V2.

Fonte gerada pela ferramenta nativa imagegen usando a V2 como alvo de correção. Pedido normalizado: preservar identidade, câmera superior, escala, roupa e arma; tornar a direção sul frontal e simétrica no eixo vertical; mostrar seis fases de caminhada com alternância inequívoca das pernas em N/S; eliminar suavização e usar alpha binário. A referência conceitual continua sendo a oficial. Nenhuma fotografia privada foi usada.

`tools/art/pack_stage1_v3.py` extrai regiões fixas da grade de 10 colunas e 2 linhas, separa idle/walk e usa escala uniforme 0,25 nos dois eixos. Células 96×96, pivô contratual (48,80), âncoras fonte comuns por direção N(108,322) e S(108,306). Nenhum quadro foi espelhado, duplicado ou escalado individualmente. O alpha da fonte foi preservado, inclusive os valores intermediários que reprovam o acabamento pixel.

A geração não assegurou alternância clara das passadas nem alpha binário. A avaliação da direção sul e comparação com a V2 estão no [QA](../../../docs/art/MELISSA_TECHNICAL_QA.md). Importação e capturas Godot não aprovam automaticamente anatomia, movimento ou legibilidade em Android.
