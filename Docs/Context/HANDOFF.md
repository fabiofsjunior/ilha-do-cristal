# Handoff — protótipos MVP e sprites

**Branch atual:** `feature/fabio-warrior-stage1`, baseada em `feature/maira-warrior-stage1` (PR #4 Maíra, em rascunho). **PR #5 Fábio:** [rascunho](https://github.com/fabiofsjunior/ilha-do-cristal/pull/5), sem merge.

## Próxima ação

Validar a nova árvore navegável em `docs/prototypes/mvp_ui_v0_5.html`: topologia compartilhada, posições das origens, proporção dos nós, lista de efeitos e custos. O plano por vocação permanece vigente até essa validação. Em paralelo, revisar a candidata técnica Fábio Warrior etapa 1: comparar v1/v2 e executar `tools/art/sprite_test/fabio_stage1_test.tscn` quando Godot estiver disponível, conferindo SQM, fundos, cada quadro e zoom 50–125%. A sprite continua em **corrigir**; Godot e Android permanecem pendentes. Nenhuma UI de produção está liberada.

## Fábio — personagem jogável aprovado, arte etapa 1 pendente

- Em 2026-10-15, o usuário aprovou Fábio como quarto personagem jogável do MVP. GDD e catálogo agora incluem Fábio, pai de Melissa, com as três vocações.
- O concept de três vocações em `assets/references/generated-candidates/fabio_vocations_concept.png` é referência aprovada, intacta e não é atlas. A fonte bruta de poses, separada, está em `assets/references/generated-candidates/fabio_warrior_stage1_source_v1.png`.
- Descrição aprovada: “Fábio é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, prefere observar, analisar os riscos e planejar a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes.”
- Os protótipos v1/v2 contêm somente Warrior N/S, `idle`4 e `walk`6, células 96×96, pivô candidato (48,80); v2 aplica escala uniforme 1,075× às linhas norte e mantém alpha original. Atlases/metadados estão em `assets/characters/fabio/warrior/`. Relatório, evidência xadrez e empacotador estão em `docs/art/evidence/fabio/fabio_warrior_stage1_review.md`, `fabio_warrior_stage1_contact.png` e `tools/art/pack_fabio_stage1.py`.
- Alpha intermediário, alinhamento dos pés e revisão da passada/loop continuam pendentes; o teste está em **corrigir**. Godot e Android não foram validados. Não incluir fotos reais.

## Maíra — checkpoint anterior

Maíra está registrada como personagem jogável do MVP, irmã de Helena, com concept de três vocações em `assets/references/generated-candidates/maira_vocations_concept.png`. O protótipo Warrior etapa 1 segue **corrigir**; relatório e prancha estão em `docs/art/evidence/maira/maira_warrior_stage1_review.md` e `maira_warrior_stage1_contact.png`. A PR #4 permanece em rascunho.

## Outros gates pendentes

- `docs/prototypes/mvp_ui_v0_5.html` é o protótipo navegável atual; aprovação do usuário continua pendente.
- Não iniciar implementação dependente do protótipo nem expandir lotes de arte antes das revisões correspondentes. Nenhum conteúdo futuro de Vael/exército entra nesta etapa MVP.
