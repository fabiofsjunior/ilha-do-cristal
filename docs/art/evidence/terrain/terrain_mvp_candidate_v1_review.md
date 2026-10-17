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
- Composição 3×3 dos três grupos de transição e dos 15 caminhos sobre grama/solo: `docs/art/evidence/terrain/terrain_mvp_candidate_v1_context.png` (nearest 4×; não é captura do Godot)

Geração reproduzível a partir da raiz do repositório:

```sh
python tools/art/generate_mvp_terrain_tileset.py --output-dir .
python tools/art/validate_mvp_terrain_tileset.py .
```

O script usa Pillow, seed `20261015` e desenho com coordenadas inteiras em 32 px; não redimensiona imagens nem altera a prancha conceitual ou sprites de personagens. O prompt/resumo visual e paletas estão no próprio script e manifesto.

## Verificações da primeira rodada, antes das correções

- `validate_mvp_terrain_tileset.py`: **PASS_STRUCTURE_ONLY** — 56 IDs únicos e regiões válidas; papéis 17/24/15; PNG RGBA 256×224; alpha apenas 0/255; nenhuma falha de borda nas 17 superfícies base repetíveis.
- `py_compile` nos dois scripts: passou.
- Parse JSON do manifesto: passou.
- Revisão visual local da prancha de contato e da amostra: sem antialias produzido pelo script; as transições e o caminho estão visíveis em grade.
- Na primeira rodada, a continuidade dos conectores ainda não era verificada; a auditoria atual abaixo compõe e valida os encontros em 3×3.

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

**Resultado: candidato / CORRIGIR, com validação Godot e Android pendente.** Na revisão do atlas nativo 256×224 e da prancha nearest 4×, confirmei o reparo anterior de um pixel opaco fora de `path_overlay_tee_e` em `(22,23)`. A correção clipa cada detalhe à máscara e valida a pegada das 15 overlays.

Ao compor as transições em grades 3×3, encontrei outro defeito reproduzível: as bordas dos 12 cantos não coincidiam com as bordas dos conectores cardinais vizinhos. Por exemplo, `shore_sand_water_corner_nw` terminava em areia na borda direita, enquanto `shore_sand_water_edge_n` começava em água na metade norte da borda esquerda. Corrigi as máscaras dos cantos para alcançar os dois lados externos e seguir uma diagonal escalonada até os pontos médios; copiei as duas bordas compartilhadas dos conectores correspondentes, preservando os 56 tiles. O validador confere as 24 bordas conector/base, 24 canto/conector e 24 canto/base, cobrindo os quatro lados e orientações.

A composição nearest 4× está em `terrain_mvp_candidate_v1_context.png`: inclui as três famílias em grade 3×3 e todos os 15 caminhos sobre grama e solo. Na inspeção, as junções dos cantos agora ficam contínuas. O caminho aparece sobre grama; sobre solo marrom, o contraste ainda precisa ser julgado na faixa de zoom 50–125% do motor/aparelho.

Arquivos de terreno examinados: atlas, manifesto, gerador, validador, prancha de contato, amostra, comparação antes/depois do `path_overlay_tee_e` e nova composição de contexto. Também consultei README, GDD, catálogo, arquitetura, handoff, direção de arte e a skill `produce-pixel-sprites` com suas referências de correção e contrato.

Verificações desta revisão:

- `python tools/art/validate_mvp_terrain_tileset.py`: **PASS_STRUCTURE_AND_COMPOSITION_JOINS**; 56 tiles, papéis 17/24/15, alpha 0/255, zero falhas de repetição nas bases, zero divergências nos 72 encontros conector/base e canto/conector/base, e zero pixels fora das máscaras das 15 overlays.
- Teste de regressão contra o atlas antes desta correção de cantos: o validador detecta as bordas incompatíveis; a versão atual passa.
- `python tools/validate_catalogs.py`: passou, 10 grupos e 54 IDs estáveis.
- `python -m py_compile tools/art/generate_mvp_terrain_tileset.py tools/art/validate_mvp_terrain_tileset.py`: passou.
- Regerei em diretório temporário e comparei atlas, manifesto, prancha, amostra e composição de contexto: todos reproduziram byte a byte.
- `git diff --check`: passou.

O manifesto registra `overlay_tiles_checked: 15`, `overlay_footprint_failures: []`, `transition_base_joins_checked: 24`, `transition_base_join_failures: []`, `corner_edge_joins_checked: 24`, `corner_edge_join_failures: []`, `corner_outer_base_joins_checked: 24` e `corner_outer_base_join_failures: []`. Esses testes validam estrutura, pegadas e continuidade exata das bordas; não aprovam a qualidade artística nem a aparência em engine.

SHA-256 dos artefatos após a correção:

| Arquivo | SHA-256 |
|---|---|
| Atlas PNG | `290439d3825ca7fb8824cde87c9278132185eae33d328c2eb0ff93f30cd86a2e` |
| Manifesto JSON | `abe52a7cbeaecd08759d8afb18d9d06ea22590470b2cb0437e085e46fda3a51e` |
| Prancha de contato | `407d19005e6b7fe59b2facd679da701e12929a337190d04893f5b0c5717b86c8` |
| Amostra montada | `940b8559259c8b0bf134d9eda987210e35164779b24becb17771159b1ad10035` |
| Composição de contexto | `08598e202781809d9c3771a6704759082ed083f996823cf89e29068da6f74239` |
| Comparação antes/depois | `27b4b5f6a304e95290be5184ff361abab88dca0320bb19d23763d16bc8b30b12` |
| Gerador | `aa56872c2c9830185cdfbfefee059438b9992e2c6fa95a1618cfed8d432b4687` |
| Validador | `e68a0e19845fd999bc756fcfbc2a3408cd2943c18568d011b3a9e1f0a67d9d83` |

O `project.godot` presente é o harness técnico de QA de sprites e declara Godot 4.5; o executável Godot não está disponível no ambiente. Portanto, as imagens de contexto são composições Pillow e não provam importação, filtro, escala/SQM ou renderização em TileMapLayer. O teste Android também não foi executado. A próxima validação é importar e compor o tileset em uma cena Godot, julgar contraste de caminho sobre solo em zoom 50–125% e conferir em aparelho Android antes de aprovar produção.

## Limitações e próximo gate

Ainda falta importar/renderizar na versão Godot fixada pelo projeto, testar a composição já revisada em uma cena TileMapLayer com filtro nearest, avaliar zoom 50–125% e conferir legibilidade em aparelho Android. As imagens apresentadas são rasterizadas pelo mesmo script e não comprovam importação nem composição em jogo. Os tilesets do MVP devem continuar candidatos até os testes no motor/aparelho; o protótipo de UI v0.7 validado pelo usuário em 2026-10-15 não aprova estes assets.
