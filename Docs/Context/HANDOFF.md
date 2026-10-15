# Handoff — protótipos MVP e sprites

**Branch atual:** `feature/fabio-warrior-stage1`, baseada em `feature/maira-warrior-stage1` (PR #4 Maíra, em rascunho). **PR #5 Fábio:** [rascunho](https://github.com/fabiofsjunior/ilha-do-cristal/pull/5), sem merge.

## Próxima ação

Revisar `docs/art/evidence/fabio/fabio_warrior_stage1_contact.png` e o relatório adjacente. O teste segue em **corrigir**. Resolver acabamento/alpha intermediário, escala relativa N/S, alinhamento e leitura de ciclo; só depois importar os atlas na cena de teste Godot e conferir direção, pés/pivô, fundo claro/escuro, SQM32/48 e zoom50–125%. Teste Android continua obrigatório antes de aprovar arte ou ampliar. Não gerar Archer/Mage, direções adicionais ou efeitos nesta etapa.

## Fábio — concept e Warrior etapa 1

- O concept de três vocações em `assets/references/generated-candidates/fabio_vocations_concept.png` é referência aprovada, intacta e não é atlas. A fonte de poses bruta, separada, está em `assets/references/generated-candidates/fabio_warrior_stage1_source_v1.png`.
- Descrição aprovada para o concept: “Fábio é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, prefere observar, analisar os riscos e planejar a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes.”
- GDD e catálogo MVP continuam listando Melissa, Helena e Maíra. Não há decisão clara para inclusão de Fábio no elenco; tratar como pendente, sem atualizar os documentos de elenco.
- O protótipo contém somente Warrior N/S, `idle`4 e `walk`6, células96×96, pivô candidato (48,80); atlases/metadados estão em `assets/characters/fabio/warrior/`. Relatório, evidência xadrez e empacotador estão em `docs/art/evidence/fabio/fabio_warrior_stage1_review.md`, `fabio_warrior_stage1_contact.png` e `tools/art/pack_fabio_stage1.py`.
- Alpha intermediário foi medido e preservado; o teste está em **corrigir**. Godot e Android não foram validados. Não incluir fotos reais.

## Maíra — checkpoint anterior

Maíra está registrada como personagem jogável do MVP, irmã de Helena, com concept de três vocações em `assets/references/generated-candidates/maira_vocations_concept.png`. O protótipo Warrior etapa 1 segue **corrigir**; relatório e prancha estão em `docs/art/evidence/maira/maira_warrior_stage1_review.md` e `maira_warrior_stage1_contact.png`. A PR #4 permanece em rascunho.

## Outros gates pendentes

- `docs/prototypes/mvp_ui_v0_3.html` é o protótipo navegável atual; aprovação do usuário continua pendente.
- Não iniciar implementação dependente do protótipo nem expandir lotes de arte antes das revisões correspondentes. Nenhum conteúdo futuro de Vael/exército entra nesta etapa MVP.
