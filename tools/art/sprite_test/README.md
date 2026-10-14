# Teste técnico de sprites — etapa 1

Engine verificada: **Godot 4.5.1 stable**. Abrir `project.godot` na raiz, executar cena principal. Este projeto é uma ferramenta de revisão de arte, não o jogo nem o encerramento de S0.

Controles: direção, animação, zoom de 50 a 125%, SQM candidato 32/48 px, pausar/continuar e próximo frame. A cruz vermelha representa os pés; o retângulo dourado, a célula 96×96. O menu já apresenta oito direções para revisão futura; direções não produzidas mostram aviso explícito.

Nesta etapa os atlas contêm **duas linhas N, S**, em ordem. Não são folhas completas de oito direções. Idle = 4 colunas, walk = 6. Metadados registram ordem real, célula, pivô, frames, FPS candidato e loop. Quando expandir, mudar linhas e metadados juntos para N, NE, E, SE, S, SO, O, NO.

PNGs esperados em `assets/characters/melissa/warrior/`, cada um acompanhado de JSON. As folhas ausentes não são substituídas por concepts. Importação usa nearest; manter mipmaps desativados nos PNGs.

```sh
godot --headless --editor --path . --import --quit
godot --path .
```

Revisão obrigatória: cada frame N/S, ausência de bleed entre células, alpha, mecha única frontal, escala nos SQMs, pivô, arma e silhueta em 50/75/100/125%. A execução headless verifica importação/código; não substitui teste visual ou Android. APK/export templates e teste em aparelho não foram entregues neste incremento.
