# Terreno MVP — candidata v1

**Estado geral: CANDIDATO, aguardando revisão visual no Godot e validação do usuário.** Não é arte aprovada para produção; não valida engine, gameplay, escala/SQM ou Android.

## Escopo

Prancha modular para a praia/spawn, faixa de grama da praia/floresta e solo do interior descritos no GDD. O interior é tratado como terreno da ilha com ursos, sem pressupor uma caverna. Não há personagens, árvores como props, construções, recursos coletáveis ou conteúdo fora do escopo.

- Grade ortogonal; pixels desenhados na resolução nativa, hard edges e paleta pequena.
- Célula de **32×32 px candidata**. A direção de arte admite 32 ou 48 px/SQM e pede teste; nenhum valor foi congelado.
- Atlas de **256×224 px**, 8 colunas × 7 linhas, 56 tiles.
- Composição: 17 superfícies base, 24 conectores de transição (areia/água, areia/grama, grama/solo; cada família tem 4 lados e 4 cantos), 15 overlays transparentes de caminho (reta, curva, T, ponta e cruz).
- Metadados descrevem IDs, retângulos, grupos, papéis e restrições de uso. Colisão/navegação não estão codificadas.

## Arquivos

- Atlas: `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.png`
- Manifesto: `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.json`
- Fonte reprodutível: `tools/art/generate_mvp_terrain_tileset.py`
- Validador: `tools/art/validate_mvp_terrain_tileset.py`
- Prancha: `docs/art/evidence/terrain/terrain_mvp_candidate_v1_contact.png`
- Amostra montada pelo script: `docs/art/evidence/terrain/terrain_mvp_candidate_v1_sample.png` (**não** é captura do Godot)

Geração reproduzível a partir da raiz do repositório:

```sh
python tools/art/generate_mvp_terrain_tileset.py --output-dir .
python tools/art/validate_mvp_terrain_tileset.py .
```

O script usa Pillow, seed `20261015` e desenho com coordenadas inteiras em 32 px; não redimensiona imagens nem altera a prancha conceitual ou sprites de personagens. O prompt/resumo visual e paletas estão no próprio script e manifesto.

## Verificações feitas

- `validate_mvp_terrain_tileset.py`: **PASS_STRUCTURE_ONLY** — 56 IDs únicos e regiões válidas; papéis 17/24/15; PNG RGBA 256×224; alpha apenas 0/255; nenhuma falha de borda nas 17 superfícies base repetíveis.
- `py_compile` nos dois scripts: passou.
- Parse JSON do manifesto: passou.
- Revisão visual local da prancha de contato e da amostra: sem antialias produzido pelo script; as transições e o caminho estão visíveis em grade.
- O teste de repetição verifica bordas de superfícies base. Conectores são peças de interface de uma célula, não estão sujeitos a repetição individual; sua continuidade precisa ser testada na montagem.

SHA-256 dos artefatos originais, antes da correção do overlay:

| Arquivo | SHA-256 |
|---|---|
| Atlas PNG | `81384c7c16d0049530f77e80105915e42359828d3a62c2c2b1704f3bbda659b3` |
| Manifesto JSON | `ba6cbe71e9afcd2c6c5257e9d42ce894944cffcaaf78b4db4764a162be2eb652` |
| Prancha de contato | `802f037543abb5593647f1ba1d12e9ec28b0015595421c2ed753e20bdc686b29` |
| Amostra montada | `940b8559259c8b0bf134d9eda987210e35164779b24becb17771159b1ad10035` |
| Gerador | `309c1a1cbd0111afff57d6d9e4f8402a23fdf595f5834c40119bab4e8878ec22` |
| Validador | `9888b3055a486ca8f9026c6541af61f798897f876f3d0292d19cd7f4a112ff2b` |

## Auditoria de correção — 2026-10-15

**Resultado: candidato / CORRIGIR, com validação no motor e no Android pendente.** Encontrei um pixel opaco fora da máscara do `path_overlay_tee_e`, na coordenada local `(22,23)`. O gerador testava se o primeiro pixel do detalhe estava na trilha, mas podia desenhar o segundo fora dela. Corrigi a geração para clipar cada pixel à máscara e acrescentei ao validador a checagem espacial das 15 overlays. A contagem e o layout permanecem em 56 tiles; a correção removeu um único pixel do atlas.

A comparação antes/depois está em `terrain_mvp_candidate_v1_path_overlay_tee_e_before_after.png`, com ampliação nearest de 8× sobre quadriculado. Usei ImageMagick 6.9.12, disponível no ambiente, para recortar e montar a evidência; o atlas continua sendo gerado pelo script Pillow versionado. Pixelorama, LibreSprite, Piskel e Godot CLI não estavam instalados/disponíveis neste ambiente.

Arquivos de terreno examinados: `terrain_mvp_candidate_v1.png`, `terrain_mvp_candidate_v1.json`, `generate_mvp_terrain_tileset.py`, `validate_mvp_terrain_tileset.py`, `terrain_mvp_candidate_v1_contact.png`, `terrain_mvp_candidate_v1_sample.png` e `terrain_mvp_candidate_v1_path_overlay_tee_e_before_after.png`. Também consultei README, GDD, catálogo, arquitetura, handoff, direção de arte e a skill `produce-pixel-sprites` com suas referências de correção e contrato.

Verificações após a correção:

- `python tools/art/validate_mvp_terrain_tileset.py`: **PASS_STRUCTURE_AND_OVERLAY_FOOTPRINT**; 56 tiles, papéis 17/24/15, alpha 0/255, nenhuma falha nas superfícies base e zero pixels fora das máscaras das 15 overlays.
- Reexecutei o novo validador contra o atlas original: ele reproduziu a falha exata em `path_overlay_tee_e` `(22,23)`; o atlas corrigido passa.
- `python tools/validate_catalogs.py`: passou, 10 grupos e 54 IDs estáveis.
- `python -m py_compile tools/art/generate_mvp_terrain_tileset.py tools/art/validate_mvp_terrain_tileset.py`: passou.
- Regerei o candidato em uma pasta temporária e comparei atlas, manifesto, prancha e amostra com `cmp`: todos reproduziram byte a byte. A diferença do atlas é um pixel; a amostra de composição permanece byte a byte igual.
- `git diff --check`: passou.

O manifesto registra `overlay_tiles_checked: 15` e `overlay_footprint_failures: []`. O estado continua candidato porque a correção rasterizada ainda não foi importada/revisada no motor.

SHA-256 dos artefatos após a correção:

| Arquivo | SHA-256 |
|---|---|
| Atlas PNG | `e8006cfe95d5fc13e456f8f624bf97ca20ad9d1e042b9c6418c3bea5d258232b` |
| Manifesto JSON | `242fcc645571b82fbbf951d66587365cbee74b22303cc47771c84ab8d0f23171` |
| Prancha de contato | `01d877d6735050a47bd5d0372d54c26ca592b2480532edc3bc2b6c4104b2ae25` |
| Amostra montada | `940b8559259c8b0bf134d9eda987210e35164779b24becb17771159b1ad10035` |
| Comparação antes/depois | `27b4b5f6a304e95290be5184ff361abab88dca0320bb19d23763d16bc8b30b12` |
| Gerador | `c354d2532de7782092ec13a944f40257a24425570829d8a71248f1af8a5199b9` |
| Validador | `bc6e4f5d269105fdfb746304cfe869c17a779b47f25e6cd015de68886a6a844a` |

O `project.godot` presente é o harness técnico de QA de sprites e declara Godot 4.5; o executável Godot não está disponível no ambiente. Portanto, a amostra é somente uma composição do Pillow e não prova importação, filtro, transições, escala/SQM ou renderização em TileMapLayer. O teste Android também não foi executado. A próxima validação continua sendo importar e compor o tileset em uma cena Godot, revisar zoom de 50–125% e conferir em aparelho Android antes de aprovar produção.

## Limitações e próximo gate

Ainda falta importar/renderizar na versão Godot fixada pelo projeto, testar o tileset em uma cena TileMapLayer com filtro nearest, avaliar zoom 50–125%, compor contornos costeiros e caminhos, e conferir legibilidade em aparelho Android. A amostra apresentada é rasterizada pelo mesmo script e não comprova importação nem composição em jogo. Os tilesets do MVP devem continuar candidatos até a revisão visual solicitada e os testes no motor/aparelho; o protótipo de UI v0.7 validado pelo usuário em 2026-10-15 não aprova estes assets.
