# Melissa Warrior — fontes das oito direções

**Candidata técnica, estado CORRIGIR.** O usuário autorizou completar `idle` e `walk` de Warrior nas oito direções. A imagem conceitual oficial e a fonte V3 existente foram usadas somente como referências de identidade, roupa, armas, paleta e estilo. Nenhuma parte do concept foi recortada e nenhuma foto privada foi usada.

## Prompt set usado

Geração nativa `image_gen` em sete chamadas: uma para cada direção nova (NE, E, SE, SW, W e NW), mais uma tentativa direcionada para NW. Cada chamada pediu uma folha com quatro poses idle e seis poses walk, vista top-down levemente oblíqua, menina de cabelo castanho-escuro com uma única mecha roxa frontal, traje Warrior lilás/dourado, espada na mão direita e escudo na esquerda. A ordem walk pedida foi contato do pé esquerdo → descida → passagem → contato do pé direito → descida → passagem. A prancha conceitual foi referência visual, nunca fonte de recorte.

As fontes geradas foram preservadas intactas com seus nomes por direção. O primeiro NW (`melissa_warrior_NW_source_8dir_v1.png`) distribuiu idle irregularmente à esquerda; foi mantido para comparação, e uma segunda geração direcionada corrigiu a colocação das células. O empacotador usa NW v2.

## Fontes e empacotamento

- NE, E, SE, SW, W e NW v2 têm 2172×724 px e foram lidas como grade-fonte 6×2 de 362×362 px. Idle ocupa quatro células iniciais da primeira linha; walk, seis células da segunda linha.
- O empacotador `tools/art/pack_melissa_8dir_candidate_v1.py` preserva N/S copiando as células existentes da V3 sem alteração. Nas direções geradas, aplica o mesmo recorte fixo com margem de 8 px, escala uniforme de 0,20 com nearest-neighbor e âncora estimada comum por animação. Não escala quadros individualmente, não espelha nem duplica poses.
- A borda de 8 px remove traços de separação desenhados pelo gerador na fonte E; os arquivos-fonte continuam intactos. O alpha da arte não é binarizado nem apagado.
- A ordem no atlas final é N, NE, E, SE, S, SW, W, NW.

As folhas permanecem candidatas: a geração inclui alpha suave/antialias, a passada não passou em reprodução animada e o pivô/escala ainda não foram testados na cena Godot nem em Android. Ver [revisão](../../../docs/art/evidence/melissa/melissa_warrior_8dir_candidate_v1_review.md) e [validação estrutural](../../../docs/art/evidence/melissa/melissa_warrior_8dir_candidate_v1_structure.json).
