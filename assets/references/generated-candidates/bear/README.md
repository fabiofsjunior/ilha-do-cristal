# Candidatos brutos do urso

Fontes raster produzidas com o imagegen integrado usando como referências a prancha aprovada assets/references/concept-rpg-classico.png e o atlas existente de Melissa Warrior.

- bear_se_source_v1.png: primeira geração; pose SE reconhecível, porém cristais grandes e luminosos demais.
- bear_se_source_v2.png: edição via imagegen da v1, alterando os cristais para três marcas pequenas no dorso; esta é a fonte selecionada para empacotar o candidato.

Os PNGs brutos foram preservados sem retoque local. Cada fonte mede 1254×1254. O alpha contém valores intermediários. O atlas é criado separadamente por tools/art/pack_bear_candidate.py: reamostragem nearest-neighbor do canvas inteiro para 112×112 e colocação transparente numa célula 128×128. Esse empacotamento descarta detalhe fino por redução e copia os valores alfa amostrados; não faz threshold, binarização, pintura ou remoção de pixels.
