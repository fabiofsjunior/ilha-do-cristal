# Handoff — protótipos MVP e sprites

**Branch atual:** `feature/fabio-warrior-stage1`, baseada em `feature/maira-warrior-stage1` (PR #4 Maíra, em rascunho). **PR #5 Fábio:** [rascunho](https://github.com/fabiofsjunior/ilha-do-cristal/pull/5), sem merge.

## Próxima ação

O protótipo navegável v0.7 foi validado pelo usuário em 2026-10-15. O aceite cobre a composição/interação de protótipo e não aprova UI de produção, gameplay, sprites, Godot ou Android.

1. Importar o candidato de terreno em uma cena de QA no Godot, quando o projeto S0 estiver importável; avaliar filtro nearest, contornos de areia/água e grama/solo, overlays e zoom 50–125%.
2. Comparar a cena com a prancha de contato e a amostra scripted em `docs/art/evidence/terrain/`; validar no Android e pedir revisão visual do candidato antes de expandir o lote ou marcá-lo aprovado.
3. Manter a candidata em `assets/environments/terrain_mvp_candidate_v1/` sem colisão/navegação, e preservar separados os gates das sprites de personagem, que continuam pendentes/corrigir.

## Fábio — personagem jogável aprovado, arte etapa 1 pendente

- Em 2026-10-15, o usuário aprovou Fábio como quarto personagem jogável do MVP. GDD e catálogo agora incluem Fábio, pai de Melissa, com as três vocações.
- O concept de três vocações em `assets/references/generated-candidates/fabio_vocations_concept.png` é referência aprovada, intacta e não é atlas. A fonte bruta de poses, separada, está em `assets/references/generated-candidates/fabio_warrior_stage1_source_v1.png`.
- Descrição aprovada: “Fábio é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, prefere observar, analisar os riscos e planejar a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes.”
- Os protótipos v1/v2 contêm somente Warrior N/S, `idle`4 e `walk`6, células 96×96, pivô candidato (48,80); v2 aplica escala uniforme 1,075× às linhas norte e mantém alpha original. Atlases/metadados estão em `assets/characters/fabio/warrior/`. Relatório, evidência xadrez e empacotador estão em `docs/art/evidence/fabio/fabio_warrior_stage1_review.md`, `fabio_warrior_stage1_contact.png` e `tools/art/pack_fabio_stage1.py`.
- Alpha intermediário, alinhamento dos pés e revisão da passada/loop continuam pendentes; o teste está em **corrigir**. Godot e Android não foram validados. Não incluir fotos reais.


## Helena — candidata técnica Warrior etapa 1

- O GDD não define uma vocação padrão para Helena; Warrior foi escolhido somente como suposição operacional para o primeiro exemplar, sem alterar a regra de escolha livre de vocação.
- A referência oficial `assets/references/concept-rpg-classico.png` foi validada pelo Git blob SHA `82a60ab282c23d0e6846a10a2d8b5e8614537ac3`; o concept está intacto e não foi recortado.
- Fontes geradas, atlas, JSONs, empacotador, validador e revisão estão em `assets/references/generated-candidates/helena_warrior_*_source_v1.png`, `assets/characters/helena/warrior/`, `tools/art/pack_helena_stage1.py`, `tools/art/validate_helena_stage1.py` e `docs/art/evidence/helena/`.
- O escopo segue N/S, `idle` 4 e `walk` 6; células 96×96 e pivô (48,80) são candidatos do contrato técnico, não parâmetros aprovados. A revisão permanece **corrigir** por alpha suave/halo e deriva horizontal no walk S.
- Próximo passo: corrigir ou refazer as passadas e validar pivô/escala em Godot antes de expandir. Godot, zoom/SQM e Android não foram validados; não foram geradas outras vocações ou direções.

## Maíra — checkpoint anterior

Maíra está registrada como personagem jogável do MVP, irmã de Helena, com concept de três vocações em `assets/references/generated-candidates/maira_vocations_concept.png`. O protótipo Warrior etapa 1 segue **corrigir**; relatório e prancha estão em `docs/art/evidence/maira/maira_warrior_stage1_review.md` e `maira_warrior_stage1_contact.png`. A PR #4 permanece em rascunho.

## Outros gates pendentes

- Protótipo navegável v0.7 validado em 2026-10-15 como protótipo; nenhuma UI de produção ou gameplay foi validada pela aprovação do protótipo.
- Tileset de terreno v1 é candidato: falta cena TileMap no Godot, revisão em zoom 50–125% e teste Android. Não inclui colisão/navegação.
- Melissa, Maíra, Fábio e Helena mantêm seus gates de sprite próprios; este incremento não modificou sprites de personagens.
- S0 (projeto Godot importável/APK) e demais fases do roadmap continuam pendentes. Nenhum conteúdo futuro de Vael/exército entra nesta etapa MVP.
