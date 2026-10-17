# Relatório — raposa SE, exemplar v1

**Estado de arte: CORRIGIR · `approved: false` · revisão de produção pendente.** Este incremento entrega uma pose estática para inspeção e uso experimental. Não é um atlas completo nem uma validação de Godot/Android.

## Contrato para integração

- Atlas: `assets/creatures/fox/fox_se_candidate_v1.png`
- Metadados: `assets/creatures/fox/fox_se_candidate_v1.json`
- ID e espécie: `fox`; célula 96×96; pivô [48,80].
- Direções produzidas: somente `SE`.
- Estado no JSON: `idle`, 1 quadro estático a 1 fps; não representa ciclo animado.
- Caminhada, ataque, hit, morte, direções N/NE/E/S/SW/W/NW, escala de SQM, zoom e uso na engine continuam pendentes.

O catálogo define raposa com HP 35, ataque 5, fuga e revide quando atacada. Esses dados são apenas contexto visual e não foram implementados aqui.

## Leitura e referência

Foram lidos `AGENTS.md`, `README.md`, `Docs/Main/GDD_MVP.md`, `Docs/Main/CATALOGS_MVP.md`, `Docs/Main/ROADMAP.md`, `docs/technical/ARCHITECTURE.md`, `Docs/Context/HANDOFF.md`, `docs/art/ART_DIRECTION_AND_SPRITES.md`, `tools/art/README.md`, `tools/art/sprite_test/README.md` e `tools/art/validate_sprite_atlases.py`. `find . -name SKILL.md` não encontrou skill local dentro do repositório.

Também foram aplicadas as skills `produce-pixel-sprites` (incluindo contrato e correções) e `imagegen` (incluindo prompting e receitas de sprites). Em `view_image`, foram examinados `assets/references/concept-rpg-classico.png` e atlas candidatos de Melissa, Fábio, Helena e Maíra. A prancha serviu só como referência de direção; nenhum pixel dela foi recortado. Os atlas mostram a câmera top-down levemente oblíqua, pixels nítidos e figuras humanas com alturas visuais próximas de 56–62 px em células 96×96. A raposa aqui ocupa cerca de 51×48 px pelo bbox de alpha ≥16, menor em altura que esses exemplos.

## Geração e empacotamento

O modo usado foi **image_gen integrado**, sem CLI. O primeiro PNG e a saída da edição foram preservados, sem alteração, em `assets/references/generated-candidates/fox/`. A edição focou somente em pixel clusters/bordas e alinhamento. Ela não removeu o alpha intermediário: a fonte escolhida ainda tem 256 valores de alpha distintos, dos quais 254 são intermediários. O quadro 96×96 mantém 56 valores intermediários (1.147 pixels). Por isso o metadado e este relatório continuam em **CORRIGIR**.

`tools/art/pack_fox_candidate.py` redimensiona a tela quadrada inteira de 1254×1254 para 96×96 com nearest neighbor. Não faz crop, trim, reposicionamento, limiar de alpha, troca de paleta ou retoque de pixels. O resultado tem pixels visíveis, transparência real, frame não vazio e nenhum pixel visível encostando na borda da célula. `docs/art/evidence/fox/fox_se_candidate_v1_nearest_8x.png` é a mesma célula ampliada 8× com nearest; seu alpha foi mantido.

### Prompt de geração inicial

```text
Use case: stylized-concept
Asset type: one-cell game creature sprite candidate for A Ilha do Cristal, for visual review only
Primary request: one small, cautious fox shown in a clean southeast-facing pose, readable as a fox at a glance; low, light body and alert ears, poised to flee
Subject: a naturally proportioned orange fox with cream muzzle, throat and tail tip, dark paws, and only a few small blue-violet crystal flecks on its back; four legs visible, clear head and bushy tail
Style/medium: crisp RPG Clássico 2D pixel art, deliberate square pixels, hard pixel edges, palette and contrast consistent with classic top-down RPG player sprites
Composition/framing: strict top-down camera with slight oblique view on an orthogonal grid; single isolated full-body sprite centered inside a transparent 96×96 pixel cell, small creature footprint about 46×38 pixels, feet/paw contact centered on x=48 at y=80; southeast means the muzzle and body axis face diagonally toward the lower-right, not a side-view profile
Lighting/mood: neutral consistent game-lighting; small and wary, no dramatic shadows
Color palette: rust orange, warm cream, dark brown/charcoal paws, restrained blue-violet crystal accents
Materials/textures: clustered pixel shading with crisp 1-pixel edges, no painterly texture or gradients
Constraints: actual transparent background with empty pixels around the sprite; one pose only; no frame grid, labels, text, tile, terrain, humans, equipment, weapons, blood, gore, extra creatures, outline glow, cast shadow, antialiasing, or blur; preserve clear pixel clusters at game scale; visual candidate only, not approved production art.
```

### Prompt da única tentativa de correção por imagegen

```text
Use case: precise-object-edit
Asset type: one-cell pixel art sprite for A Ilha do Cristal, review candidate
Input images: Image 1: fox sprite edit target
Primary request: refine only the existing fox sprite into crisp, deliberate pixel art suitable for a 96×96 game sprite cell
Subject: keep the same single small orange fox, cream muzzle/chest/tail tip, dark paws, discreet blue-violet crystals, and cautious southeast-facing pose
Style/medium: classic 2D top-down RPG pixel art, square clustered pixels, hard discrete edges
Composition/framing: preserve a transparent square canvas; the fox should occupy roughly 46×38 pixels within the 96×96 cell, centered horizontally, with ground-contact at x=48 y=80
Constraints: change only pixel rendering and alignment; preserve the fox identity, southeast direction, silhouette, proportions, palette and crystal placement. Remove glow, blur, gradients and antialiasing; redraw edge pixels as fully opaque or fully transparent. Keep real transparency, no shadow, no grid, no background, no extra elements, no text, no other animals. This remains an unapproved candidate.
```

## Validação e pendências

`python tools/art/validate_fox_candidate.py` retornou `structural: PASS`, `art_status: corrigir`, `approved: false`, sem erros estruturais e com aviso de 56 valores de alpha intermediários. Em `view_image`, a célula nativa 96×96 e a prévia 8× nearest foram conferidas visualmente. Isso confirma o empacotamento e a legibilidade básica da pose, não qualidade aprovada.

Pendente: corrigir/remover halos e alpha intermediário por uma nova edição imagegen; revisar câmera/direção, leitura dos pés e pivô no cenário-alvo; avaliar escala/zoom em Godot e no Android; produzir e revisar as direções e animações restantes após o gate do exemplar. Nenhum APK, teste visual na engine ou aparelho foi executado neste incremento.
