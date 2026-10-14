# Melissa Warrior — tentativa unificada v2

**Candidata, não aprovada.** Continua limitada à etapa1, N/S idle4/walk6.

Ferramenta: imagegen nativa, uma geração nova unificada. Referência de identidade:
`concept-rpg-classico.png`; não houve recorte do concept ou uso de fotos privadas.
Fonte: `melissa_warrior_unified_v2_source.png`, RGBA2172×724.

## Prompt aplicado

Generate one game-ready LOW RESOLUTION sprite animation sheet, NOT concept art.
The supplied image is identity/palette reference only; do not crop its figures
and do not reproduce its front-facing chibi perspective. ONLY Melissa Warrior
age8, long DARK BROWN hair ONE PURPLE FRONT BANG, lilac armor tunic gold trim
brown boots, silver sword gold hilt RIGHT anatomical hand, round dark shield LEFT.
Camera overhead35degrees downward, classic old-school orthogonal topdown RPG
walking on ground: visible crown/top of head and shoulder tops, foreshortened
face below forehead, shortened torso/legs. Same camera and proportions on20frames.
Simple native48×64pixel character clusters, restricted32color palette,
1pixel dark outline, no smooth shading/antialias/semitransparent pixels,
alpha only0or255. Exact logical canvas960×192,10columns2rows96×96 cells;
if enlarged upscale nearest-neighbor. TopN: no purple back stripe, sword screen
right/shield left. BottomS: single frontal purple bang, sword screenleft/shield
right. Columns1–4 chronological idle breathing; columns5–10 six walk phases
alternating feet contact/down/pass. Lock head width/hair volume/armor/weapon
scale across both animations. Fixed feet pivot48,80. No shadow, floor, text/grid.

## Resultado e empacotamento

A ferramenta entregou as20poses e a topologia10×2, mas canvas3:1em vez5:1.
Por isso as regiões fonte são retangulares, **sem forçar uma célula quadrada na
reamostragem**. `tools/art/pack_stage1_v2.py` usa uma escala uniforme0,25nos dois
eixos e em todos os quadros, extrai grade fixa e coloca cada resultado numa
célula96×96. Nenhum quadro foi espelhado, duplicado, redesenhado ou escalado
individualmente. Âncoras de pés fonte manuais por linha: N(108,322), S(108,306). Revisão pela caixa alpha>=240 ajustou uma
âncora comum por direção: N -5px e S -9px; idle fica aproximadamente78–79,
walk80–81. São estimativas, não certificação do contato físico de cada pé.
Idle usa6FPS nesta candidata (proposta; v1usava4FPS); walk10FPS.
Metadados registram regiões fonte, escala e offsets; revisar âncoras no motor.

A identidade e o ângulo superior parecem mais consistentes que na v1;
coroa/ombros ficam mais visíveis e pernas mais curtas. A restrição de alpha
binário e paleta32não foi respeitada: os contornos continuam suaves. Não remover
alpha intermediário silenciosamente para fabricar uma aprovação. Revisão de
passadas/pés, câmera, identidade e bordas no Godot/Android ainda obrigatória.

Atlases separados conservam sufixo`candidate_v2`e não substituem os anteriores.
