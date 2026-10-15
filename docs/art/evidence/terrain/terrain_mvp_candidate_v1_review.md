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

SHA-256 (artefatos iniciais):

| Arquivo | SHA-256 |
|---|---|
| Atlas PNG | `81384c7c16d0049530f77e80105915e42359828d3a62c2c2b1704f3bbda659b3` |
| Manifesto JSON | `ba6cbe71e9afcd2c6c5257e9d42ce894944cffcaaf78b4db4764a162be2eb652` |
| Prancha de contato | `802f037543abb5593647f1ba1d12e9ec28b0015595421c2ed753e20bdc686b29` |
| Amostra montada | `940b8559259c8b0bf134d9eda987210e35164779b24becb17771159b1ad10035` |
| Gerador | `309c1a1cbd0111afff57d6d9e4f8402a23fdf595f5834c40119bab4e8878ec22` |
| Validador | `9888b3055a486ca8f9026c6541af61f798897f876f3d0292d19cd7f4a112ff2b` |

## Limitações e próximo gate

Ainda falta importar/renderizar na versão Godot fixada pelo projeto, testar o tileset em uma cena TileMapLayer com filtro nearest, avaliar zoom 50–125%, compor contornos costeiros e caminhos, e conferir legibilidade em aparelho Android. A amostra apresentada é rasterizada pelo mesmo script e não comprova importação nem composição em jogo. Os tilesets do MVP devem continuar candidatos até a revisão visual solicitada e os testes no motor/aparelho; o protótipo de UI v0.7 validado pelo usuário em 2026-10-15 não aprova estes assets.
