# Handoff — correções de arte de A Ilha do Cristal

**Branch de trabalho:** `feature/fabio-warrior-stage1`. `main` não foi alterada. O remoto foi conferido e tem somente `main` e `feature/fabio-warrior-stage1`; os commits deste checkpoint ainda precisam ser publicados.

## Próxima ação

Recuperar ou refazer as 12 fontes PNG corrompidas das direções novas de Maíra. Em seguida, corrigir manualmente o alpha/halo, a orientação e a passada de cada personagem no editor de pixel art, uma direção e animação por vez. Preservar os conceitos e as fontes atuais. Pixelorama, LibreSprite e Piskel são opções gratuitas; a edição deve continuar visível, revisável e sem substituição generativa dos atlas.

Depois, importar as candidatas no Godot e validar em tamanho nativo, nearest-neighbor, fundos claros/escuros, zoom 50–125%, pivô/SQM e ciclos. Fazer teste Android quando disponível. Sem essas evidências, as sprites continuam **CORRIGIR** e o terreno continua **CANDIDATO**.

## Estado por asset

| Frente | Correções integradas | Falhas e validação pendentes |
|---|---|---|
| Fábio Warrior | Oito retoques manuais localizados em `idle`/`walk` v3 para remover artefatos desconectados; inclui `walk` SW quadros 2 e 5. V1/V2 e fontes foram preservadas. | Alpha intermediário/halo em todos os candidatos, outros resíduos, passada e apoio/pivô sem comprovação. Existem somente `idle` e `walk`; não cobre `attack`, `hit`, `death` ou `cast`. **CORRIGIR**. |
| Helena Warrior | Sem edição raster nesta rodada; validadores estruturais de 8 direções e etapa 1 passaram. | Alpha/halo, deriva do limite inferior em relação ao pivô e ciclo/apoio precisam de revisão. Godot/Android pendentes. Somente `idle`/`walk`. **CORRIGIR**. |
| Maíra Warrior | Relatório de reauditoria atualizado; nenhuma edição raster segura foi aplicada. | 12/12 fontes das seis novas direções são PNGs truncados que falham ao decodificar. O atlas v2 também tem direções ambíguas e passada fraca; recuperar/refazer fontes antes de corrigir e reempacotar. **CORRIGIR**. |
| Melissa Warrior | V2 acrescentada preservando V1; remove dois pixels isolados com alpha 1 em N/idle/quadro 2. | Alpha/halo permanece; direção S, pose de espada e passadas ainda requerem ajuste. Godot/Android pendentes. **CORRIGIR**. |
| Terreno MVP | Mantidos os 56 tiles (17 base, 24 transições, 15 overlays); corrigidos pixels fora da máscara de caminho e junções dos cantos. | Validador de estrutura/composição passou. Contraste em solo e integração real em TileMap/Godot, escalas e Android pendentes. **CANDIDATO**. |

O contrato de arte prevê oito direções e `idle` 4, `walk` 6, `attack` 6, `hit` 3, `death` 6 e `cast` 6 quadros por aparência/vocação/animação. Os quatro candidatos Warrior têm só `idle` e `walk`; não declarar esse escopo incompleto como produção aprovada.

## Validações deste checkpoint

- `python tools/art/validate_sprite_atlases.py`: **falhou**, 21 entradas com alpha intermediário. Não é uma aprovação visual.
- `python tools/art/validate_helena_8dir.py`: estrutura, metadados, hashes e limites passaram; há alertas por alpha e alinhamento/limite inferior; mantém `CORRIGIR`.
- `python tools/art/validate_helena_stage1.py`: estrutura passou; 17.568 pixels intermediários em idle e 20.476 em walk; mantém `CORRIGIR`.
- `python tools/art/validate_mvp_terrain_tileset.py`: `PASS_STRUCTURE_AND_COMPOSITION_JOINS`; 56 tiles, alpha 0/255 e nenhuma falha de junção/máscara.
- `python tools/validate_catalogs.py`: passou, 10 grupos e 54 IDs estáveis.
- `python -m py_compile` dos scripts de arte alterados, packers reproduzíveis de Fábio/Melissa/terreno e `git diff --check`: passaram nas verificações registradas.
- Não há `godot`, `godot4` ou `adb` instalado neste ambiente; cena/TileMap no motor e Android permanecem pendentes. Não foi encontrado conjunto convencional de testes do projeto para executar sem o motor.

## Commits de correção no branch

- `2e560a0` — corrigir pixels de overlay de caminho do terreno.
- `a95e66d` — alinhar cantos das transições do terreno.
- `e40b5a2` — acrescentar o retoque pontual da Melissa.
- `d811261` — retocar artefatos isolados do Fábio.
- A atualização desta reauditoria é commitada separadamente após a validação final.

Manter `main` intacta e não criar branches remotas temporárias. A última leitura de `git ls-remote --heads origin` mostrou exatamente `main` e `feature/fabio-warrior-stage1`; não havia branches remotas antigas para remover.
