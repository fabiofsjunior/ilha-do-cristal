# Handoff — protótipos MVP e sprites

**Branch atual:** `feature/fabio-warrior-stage1`, baseada em `feature/maira-warrior-stage1` (PR #4 Maíra, em rascunho). **PR #5 Fábio:** [rascunho](https://github.com/fabiofsjunior/ilha-do-cristal/pull/5), sem merge.

## Próxima ação

Revisar `docs/prototypes/mvp_ui_v0_7.html` (inventário, painel de atributos, detalhes dos itens e árvore) com a imagem conceitual escolhida em `docs/prototypes/assets/passive_skill_tree_endgame_reference.png`: validar a composição visual, a lista de efeitos e a regra de desbloqueio automático por nível. A origem já inicia desbloqueada. Os marcos de geração 2/4/6/8/10 são apenas uma demonstração; a topologia da imagem não é dado exato. O plano de 100 nós por vocação permanece vigente. Em paralelo, revisar a candidata técnica Fábio Warrior etapa 1: comparar v1/v2 e executar `tools/art/sprite_test/fabio_stage1_test.tscn` quando Godot estiver disponível, conferindo SQM, fundos, cada quadro e zoom 50–125%. A sprite continua em **corrigir**; Godot e Android permanecem pendentes. Nenhuma UI de produção está liberada.

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

- `docs/prototypes/mvp_ui_v0_7.html` é o protótipo navegável atual; revisão explícita do usuário continua pendente.
- Não iniciar implementação dependente do protótipo nem expandir lotes de arte antes das revisões correspondentes. Nenhum conteúdo futuro de Vael/exército entra nesta etapa MVP.
