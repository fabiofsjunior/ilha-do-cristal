# Fábio Warrior 8-dir — registro dos prompts

**Ferramenta:** ImageGen nativo do Work Mode. As imagens de origem são arte gerada e permanecem candidatas.

## Referências

- `assets/references/generated-candidates/fabio_vocations_concept.png`: concept aprovado; somente o Warrior à esquerda orienta identidade, rosto, paleta e espada. Não foi recortado para produzir quadros.
- Candidatos Warrior anteriores de Fábio: referência de escala e câmera; não foram substituídos.
- Nenhuma foto real ou privada foi usada.

## Prompt-base — cardinais E/W

Gerar folha PNG RGBA 1536×1024, grade fixa 6×4 de células 256×256. Linhas na ordem E idle (4 poses; 2 vazias), E walk (6), W idle (4; 2 vazias), W walk (6). Fábio Warrior fiel ao concept: pele morena, cabelo curto escuro com grisalho nas têmporas, barba curta, capa vermelha e dourada, armadura ouro/creme, espada prata/dourada. Câmera top-down oblíqua fixa; perfil cardinal leste/direita e oeste/esquerda redesenhados, sem espelhamento; escala e pés alinhados entre células. Idle com quatro mudanças sutis; walk na sequência contato esquerdo, descida, passagem, contato direito, descida, passagem, com pernas alternadas. Sem fundo, brilho, sombra, rótulos, bordas, artefatos ou antialias; alpha 0/255.

## Prompt-base — diagonais

Gerar duas folhas com a mesma grade e dimensões. A folha NE/SE contém NE idle (4), NE walk (6), SE idle (4), SE walk (6); a folha SW/NW contém SW idle (4), SW walk (6), NW idle (4), NW walk (6). Manter o concept de Fábio, câmera e arma. NE/NW voltados para cima; SE/SW para baixo; cada diagonal deve ser um eixo distinto, com vista frontal/traseira coerente. Redesenhar anatomia por direção, sem espelhar. Repetir a ordem de passada definida acima. Transparência real e alpha binário foram solicitados; o ImageGen não cumpriu inteiramente esses critérios.

## Correções experimentais

1. Uma edição da folha cardinal tentou eliminar halo/alpha suave, preservando poses e grade. Reduziu a quantidade de pixels intermediários, mas manteve glow e zero pixels alpha 255. A fonte original foi preservada.
2. Uma edição em cada folha diagonal tentou reduzir os personagens dentro das células sem recorte. Persistiram resíduos nas bordas; a edição SW/NW reduziu a linha SW walk para quatro poses. Ambas foram preservadas e não são usadas no atlas final.

As folhas selecionadas para empacotamento foram inspecionadas visualmente e verificadas por dimensões/células. Os defeitos permaneceram explícitos nos candidatos e no relatório; nenhuma máscara automática foi usada.
