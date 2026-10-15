# Candidatos técnicos de personagens

Esta nota documenta separadamente os candidatos de Melissa Warrior gerados com
imagegen; o protótipo Maíra Warrior usa outro pipeline e está isolado em
`assets/characters/maira/warrior/`.

**Status: CORRIGIR.** Não são sprites aprovados; não liberam etapas 2–5.
Somente Melissa Warrior, N/S, idle 4 e walk 6. Não há outros personagens,
animais, Vael, efeitos ou outras direções neste lote.

Gerados com ferramenta nativa imagegen a partir de
`assets/references/concept-rpg-classico.png`, usada como referência de estilo e
identidade, nunca recortada. Nenhuma foto privada foi usada.

## Prompt de geração normalizado

Classic 2D RPG true pixel art, crisp square pixels, no antialiasing, orthogonal
top-down lightly oblique camera. Melissa age 8: long dark brown wavy hair,
exactly one frontal purple streak, brown eyes, lilac short warrior tunic/armor
with gold trim, brown boots; silver sword with gold hilt in anatomical right
hand, round dark shield anatomical left hand. Preserve identity, clothing,
volume, weapon and feet anchors. Transparent alpha background; no shadows,
ground, labels or grid. Uniform logical96x96 cells, figure approximately48x64,
pivot48,80. N back view top row, S front view bottom row. Idle:4 consecutive
subtle breathing frames. Walk:6 distinct contact/down/passing phases alternating
feet. No pose duplicates or other subjects.

## Correções solicitadas à ferramenta

Idle: remover mecha roxa traseira (a mecha é frontal), acrescentar escudo esquerdo,
reduzir detalhes a clusters de pixel e corrigir câmera para vista superior.
Walk: remover roxo traseiro e corrigir troca de mãos nas colunas2/4 do norte;
manter seis fases distintas e invariantes. Cada animação teve uma tentativa
inicial e uma correção; os PNGs aqui são as correções finais, sem retoque.

## Empacotamento reproduzível

`python tools/art/pack_stage1_candidates.py` extrai grade fixa, sem crop
por conteúdo, e usa nearest para reduzir cada célula a75x75, colocada numa
célula96x96 com âncoras manuais registradas no script. O PNG fonte preserva
alpha original; atlas também preserva alpha (inclui valores intermediários).
N2/N4 do walk persistiram com mãos trocadas após a correção imagegen: somente
esses quadros foram espelhados horizontalmente na embalagem para manter espada
à direita e escudo à esquerda na vista norte. Nenhum quadro foi duplicado.

## Pendências observadas

- Câmera ainda demasiado frontal; precisa redesenho superior oblíquo consistente.
- Fonte apresenta antialias/alpha intermediário: nearest não torna o desenho
  automaticamente pixel art aprovada. Bordas e paleta precisam revisão artística.
- Microvariações de volume e equipamento; revisar quadro a quadro.
- Idle respira discretamente; walk precisa revisão de footfall e continuidade.
- Pivô é contrato/estimativa de colocação, não prova de contato exato de cada pé.
- Validação visual em Godot e Android real continua obrigatória; pacote técnico
  e importação bem-sucedida não aprovam a arte.

## Maíra — conceito e protótipo isolado

`maira_vocations_concept.png` é o conceito aprovado pelo usuário para as três
vocações; é referência visual, não sprite nem atlas. As tiras candidatas de
Maíra Warrior geradas pelo Pixel Engine estão em `maira_warrior/`. O primeiro
teste inclui apenas norte/sul, `idle` e `walk` e permanece em **corrigir**;
relatório e prancha: `docs/art/evidence/maira/maira_warrior_stage1_review.md`
e `maira_warrior_stage1_contact.png`. Não incluir fotos de referência.
