# Teste técnico de sprites — etapa 1

Engine verificada: **Godot 4.5.1 stable**. Abrir `project.godot` na raiz, executar cena principal. Este projeto é uma ferramenta de revisão de arte, não o jogo nem o encerramento de S0.

Controles: direção, animação, zoom de 50 a 125%, SQM candidato 32/48 px, pausar/continuar e próximo frame. A cruz vermelha representa os pés; o retângulo dourado, a célula 96×96. O menu já apresenta oito direções para revisão futura; direções não produzidas mostram aviso explícito.

Nesta etapa os atlas contêm **duas linhas N, S**, em ordem. Não são folhas completas de oito direções. Idle = 4 colunas, walk = 6. Metadados registram ordem real, célula, pivô, frames, FPS candidato e loop. Quando expandir, mudar linhas e metadados juntos para N, NE, E, SE, S, SO, O, NO.

PNGs esperados em `assets/characters/melissa/warrior/`, cada um acompanhado de JSON. As folhas ausentes não são substituídas por concepts. Importação usa nearest; manter mipmaps desativados nos PNGs.

## Fábio Warrior — etapa 1

Para revisar somente as duas direções disponíveis (`N`, `S`) e `idle`/`walk`, abra a cena isolada `fabio_stage1_test.tscn`. Ela permite comparar candidatas v1/v2, zoom 50–125%, fundos claro/escuro, SQM 32/48, pausar e avançar quadro a quadro. A cena exige as duas candidatas em `assets/characters/fabio/warrior/`; continua sendo uma ferramenta de QA, não uma tela do jogo nem aprovação da arte. Godot/Android ainda precisam ser executados e revisados.

```sh
godot --headless --editor --path . --import --quit
godot --path .
```

Revisão obrigatória: cada frame N/S, ausência de bleed entre células, alpha, mecha única frontal, escala nos SQMs, pivô, arma e silhueta em 50/75/100/125%. A execução headless verifica importação/código; não substitui teste visual ou Android. APK/export templates e teste em aparelho não foram entregues neste incremento.

## Evidência renderizada da etapa 1

O harness permite alternar candidatos v1/v2 (v2 inicial), direção, animação e fundos claro/escuro. Os seletores acompanham também mudanças programáticas das capturas. Todos os candidatos continuam **corrigir**.

`docs/art/evidence/godot_v2/all_20_frames_3x.png` contém os vinte quadros reais de V2, desenhados em Godot com `AtlasTexture` nearest 3×. Os outros 16 PNGs mostram N/S × idle/walk × zoom50/75/100/125. Foram capturados via X11/Xvfb e OpenGL4.5 llvmpipe no Godot4.5.1, após reimportação. Não são imagens reconstruídas fora da engine e não comprovam Android.

Scripts reproduzíveis com um display X11/Wayland disponível:

```sh
godot --path . --script tools/art/sprite_test/capture_scene.gd
godot --path . --script tools/art/sprite_test/capture_all_frames.gd
godot --headless --path . --script tools/art/sprite_test/check_scene.gd
python tools/art/validate_sprite_atlases.py
```

Os scripts de captura rejeitam `headless` porque o driver dummy não renderiza. O validator calcula limites de alpha16/128/240 e deslocamentos geométricos do contorno inferior relativos ao pivô; isso não reconhece botas e pode incluir espada/sombra. Não altera os PNGs e não aprova anatomia, identidade ou movimento. Código de saída1 é esperado enquanto houver suavização alpha ou outro defeito contratual.
