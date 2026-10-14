# Direção de arte e produção de sprites

Estilo aprovado: **RPG Clássico 2D pixel art**, câmera top-down levemente oblíqua sobre grade ortogonal de SQMs; contornos nítidos, pixels deliberados, contraste legível em Android, paleta acolhedora na área segura e violeta na corrupção. Ver [prancha](../../assets/references/concept-rpg-classico.png). A imagem é conceito: não foi segmentada nem validada como sprite ou tileset. Não publicar fotos originais; o responsável de arte pode usá-las em fluxo privado para referência de identidade.

Melissa: 8 anos, um pouco mais alta, cabelos **castanho-escuros com uma mecha roxa frontal** (não cabelo inteiro roxo), olhos castanhos, roupa/acento lilás. Helena: 7 anos, cabelos castanhos ondulados com tiara clara, olhos castanhos, roupa/acento creme-rosa. Manter identidade e idade em todas as vocações. Warrior espada, Archer arco, Mage cajado; trajes de vocação são aparência escolhida na criação, equipamentos posteriores não mudam visual. Tom familiar sem violência gráfica.

## Contrato de atlas para Godot

Especificação candidata para validar com um sprite técnico antes de produzir em lote: PNG RGBA **transparente**, sem sombra pintada fora da célula, célula uniforme **96×96 px**, figura de aproximadamente 48×64 px, origem/pivô nos pés em **(48, 80)**, espaço livre para arma/efeito sem invadir célula. O tamanho não determina os SQMs do mapa; testar zoom 50–125% e telas reais antes de congelar escala. Sem antialias ou pixels intermediários; importar com filtro nearest, sem mipmap para personagens, sem crop automático; offsets iguais por frame/direção.

Um PNG por aparência × vocação × animação, grade **linhas = N, NE, E, SE, S, SO, O, NO; colunas = frames em ordem temporal**. `idle` 4, `walk` 6, `attack` 6, `hit` 3, `death` 6, `cast` 6 frames (proposta). Exportar metadados JSON com `{id, cell:[96,96], pivot:[48,80], directions:[...], animations:{name:{frames,fps,loop}}}`; por exemplo `melissa_warrior_walk.png` 576×768. Efeitos de skills em atlas separado com pivô/colisão próprios. Não reutilizar quadro de concept como atlas; verificar manualmente alinhamento dos pés e direção de arma em todos os quadros. Animais seguem o mesmo contrato de oito direções, com célula maior e pivô declarado quando necessário (urso).

Tiles: propor 32×32 ou 48×48 px por SQM somente após protótipo de legibilidade; atlas de chão/decor separado; colisão e navegação em layers. O mapa do conceito não é um tileset automaticamente repetível. Registrar paleta, escala e versão aprovada em `assets/manifest.json` quando houver arte de produção.

## Prompts de referência para geração

**Personagens (concept individual):** “A Ilha do Cristal, RPG Clássico pixel art 2D, câmera top-down oblíqua fixa, pixels quadrados nítidos e proporções infantis respeitosas. [NOME], [IDENTIDADE ABAIXO], [WARRIOR espada / ARCHER arco / MAGE cajado]; figura inteira, vista frontal 3/4 e traseira 3/4 coerentes, fundo neutro, sem texto, sem perspectiva isométrica, sem suavização ou 3D. Conservar proporção e paleta entre vocações.” Identidade Melissa: 8 anos, ligeiramente mais alta que Helena, cabelo predominantemente castanho-escuro, uma mecha roxa frontal, acentos lilases. Helena: 7 anos, castanho ondulado e tiara clara, acentos creme/rosa. Usar fotos só no ambiente privado; não incluir foto nos commits.

**Monstros (concept individual):** “Mesmo RPG Clássico 2D pixel art top-down oblíquo, pixels nítidos e escala comparável às crianças: [RAPOSA pequena e arisca / LOBO médio e atento / URSO grande e pesado], animal reconhecível com discretos cristais azul-violeta e sinais de mutação, silhueta clara e animações de movimento/ataque antecipáveis. Fundo neutro, vistas de oito direções coerentes, sem gore, sem horda.” O urso do MVP é animal comum corrompido, não boss.

**Passagem concept → produção:** 1) aprovar silhueta/paleta; 2) criar uma direção e idle com pivô; 3) validar em SQM e zoom Android; 4) produzir oito direções e animações; 5) slice/metadados; 6) teste visual em Godot; 7) só então gerar variantes. Geração de imagem tende a variar frames e texto; corrigir manualmente ou refazer os quadros inconsistentes.
