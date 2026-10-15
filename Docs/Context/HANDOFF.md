# Handoff — auditoria de arte de A Ilha do Cristal

**Branch de trabalho:** `feature/fabio-warrior-stage1`. A auditoria partiu de `b3d3f9a`; `main` não foi alterada. A lista remota conferida contém somente `main` e `feature/fabio-warrior-stage1`.

## Próxima ação

Usar um editor de pixel art gratuito em um ambiente com interface gráfica — recomendação: [Pixelorama](https://pixelorama.org/), com timeline e onion skinning — para redesenhar os quadros defeituosos sem substituir os atlas por saídas generativas inconsistentes. Preservar as fontes, corrigir uma direção/animação por vez, revisar visualmente, empacotar e repetir os validadores. As 12 fontes novas de Maíra precisam ser recuperadas ou refeitas antes de usar o empacotador 8-dir.

Em seguida, importar as candidatas em uma cena de QA Godot, revisar fundo claro/escuro, tamanho nativo, zoom 50–125%, SQM, pivô e ciclos. Só então validar em Android. Godot e Android não estavam disponíveis neste ambiente; até essas evidências existirem, os assets permanecem **CORRIGIR** ou **CANDIDATO**.

## Estado por asset

| Frente | Conteúdo atual | Falhas/pendências confirmadas |
|---|---|---|
| Fábio Warrior | `idle` 4 + `walk` 6, oito direções | Alpha intermediário/halo; fragmentos vermelhos desconectados em SE/SW e SW/NW; passada/pivô sem comprovação. Archer, Mage e demais estados ainda não existem. |
| Helena Warrior | `idle` 4 + `walk` 6, oito direções | Alpha/halo, apoio e pivô inconsistentes nas diagonais; validação Godot/Android pendente. O validador stage1 foi corrigido para verificar somente as três fontes da etapa e detectar ausência. |
| Maíra Warrior | `idle` 4 + `walk` 6, oito direções | E e W não se opõem, diagonais se confundem, passada incerta e alpha intermediário. Doze fontes das seis direções novas estão malformadas/truncadas; o packer falha e não há cópia íntegra no histórico. |
| Melissa Warrior | `idle` 4 + `walk` 6, oito direções | Alpha intermediário; passadas e poses da espada variam sem continuidade clara. |
| Terreno MVP | 56 tiles: 17 base, 24 transições e 15 overlays | Nenhum defeito demonstrável na prancha/amostra atual; escala/SQM, composição real em TileMapLayer, Godot e Android pendentes. |

O contrato de arte propõe oito direções e `idle` 4, `walk` 6, `attack` 6, `hit` 3, `death` 6 e `cast` 6 quadros por aparência/vocação/animação. Os quatro candidatos Warrior existentes contêm somente `idle` e `walk`. Não criar animações ausentes para mascarar esta lacuna nem aprovar os candidatos atuais.

## Validações deste checkpoint

- `python tools/art/validate_sprite_atlases.py`: falha com 20 atlas contendo alpha intermediário; estrutura/alpha devem continuar separados de aprovação artística.
- `python tools/art/validate_helena_8dir.py`: passa estruturalmente, mas emite alertas de alpha, alinhamento e mantém o status **CORRIGIR**.
- `python tools/art/validate_helena_stage1.py`: passa após correção do glob de fontes; teste regressivo confirma erro explícito quando falta um arquivo esperado.
- `python tools/art/validate_mvp_terrain_tileset.py`: `PASS_STRUCTURE_ONLY`, 56 tiles e alpha 0/255; não comprova renderização no motor.
- `python tools/validate_catalogs.py`: passou, 10 grupos e 54 IDs.
- `python tools/art/pack_maira_8dir_candidates.py`: falha ao ler fontes PNG malformadas.
- `git diff --check`: passou. Godot e Android: pendentes.

## Arquivos e commits da auditoria

Nenhum PNG de personagem/terreno foi substituído. Foram atualizados relatórios de evidência para Maíra e terreno e corrigido `tools/art/validate_helena_stage1.py`. Commits locais integrados na branch: `35b17d7` (terreno), `e41c173` (validador Helena), `df35d71` (integridade das fontes Maíra). A próxima ação é a revisão manual com editor gráfico e, depois, teste no motor/aparelho.
