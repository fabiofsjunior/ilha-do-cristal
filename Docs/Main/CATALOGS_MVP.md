# Catálogos do MVP — A Ilha do Cristal

**v0.3 · 2026-10-15.** Esta é a lista de produção das doze famílias de conteúdo. Regras narrativas, identidade das personagens, vocações e magias seguem o [GDD](GDD_MVP.md). Valores numéricos de armas, drops, receitas e construções são **provisórios** para playtest. A representação legível por máquina está em [`data/catalogs/mvp.json`](../../data/catalogs/mvp.json). IDs não devem mudar depois de aparecerem em saves.

## 1. Personagens e vocações

| ID | Nome | Identidade visual fixa | Descrição | Escolha |
|---|---|---|---|---|
| `melissa` | Melissa | Levemente mais alta, cabelo castanho-escuro com **uma única mecha roxa frontal**, acentos lilases | Meiga e doce, esperta e muito observadora; costuma manter a calma e pensar com clareza diante de imprevistos. | Warrior/Archer/Mage |
| `helena` | Helena | Cabelo castanho ondulado, tiara clara, acentos creme-rosa | Carismática e inteligente, tem pavio curto e reage com intensidade; seu jeito espontâneo a torna cheia de iniciativa. | Warrior/Archer/Mage |
| `maira` | Maíra | Cabelos longos castanho-escuros e traje amarelo/dourado, conforme conceito aprovado | Irmã de Helena, é bonita, carismática e muito falante. Atenciosa com os outros, anima o grupo e observa o ambiente antes de agir. | Warrior/Archer/Mage |
| `fabio` | Fábio | Pele morena, cabelo curto escuro com fios grisalhos nas têmporas, barba aparada; trajes vermelho/dourado, verde ou azul conforme o concept das vocações | Pai de Melissa, é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, observa, analisa riscos e planeja a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes. | Warrior/Archer/Mage |

Qualquer conta pode usar qualquer aparência, inclusive repetida na LAN. O equipamento não altera o visual. `warrior`: HP/MP 200/100, FOR/AGI/INT ×2/0,75/0,5; `archer`: 150/150, ×1/2/0,75; `mage`: 100/200, ×0,5/0,75/2. Vocação permanente **por personagem**.

## 2. Atributos e níveis

FOR: melee, vida e regeneração. AGI: físico à distância, crítico e esquiva. INT: mana, regeneração de mana e mágico. Conversões provisórias por ponto efetivo: FOR +0,6 melee e +3 HP; AGI +0,6 distância, +0,05 ponto percentual de crítico e de esquiva; INT +0,6 mágico e +3 MP. Crítico base 5%, esquiva base 3%; tetos de 20% cada.

Regeneração usa o máximo atual de HP/MP como base e as taxas abaixo por segundo. O estado de combate termina após 8 s sem atacar nem receber dano. FOR/INT efetiva (após o multiplicador da vocação) acrescenta, respectivamente, +0,003/+0,010 p.p. de HP/s (combate/fora) e +0,001/+0,004 p.p. de MP/s. Caps: HP 0,5%/s em combate e 2%/s fora; MP 0,25%/s em combate e 1%/s fora. Os caps também limitam personagens de atributos altos.

| Vocação | HP combate / fora | MP combate / fora |
|---|---:|---:|
| Guerreiro | 0,20% / 0,60% | 0,03% / 0,12% |
| Arqueiro | 0,15% / 0,50% | 0,06% / 0,25% |
| Mago | 0,10% / 0,35% | 0,10% / 0,40% |

| Nível alcançado | XP necessário desde o anterior | XP total | Pontos de atributo acumulados de subidas | Pontos de árvore disponíveis |
|---:|---:|---:|---:|---:|
| 1 | 0 | 0 | 0 | 3 |
| 2 | 100 | 100 | 1 | 6 |
| 3 | 130 | 230 | 2 | 9 |
| 4 | 169 | 399 | 3 | 12 |
| 5 | 220 | 619 | 4 | 15 |
| 6 | 286 | 905 | 5 | 18 |
| 7 | 371 | 1.276 | 6 | 21 |
| 8 | 483 | 1.759 | 7 | 24 |
| 9 | 627 | 2.386 | 8 | 27 |
| 10 | 816 | 3.202 | 9 | 30 |

Fórmula: `round(100 × 1,3^(nível atual − 1))`; limite MVP 10. Até chegar ao nível 50, +3 árvore por subida; após, só +1 atributo por subida. O sistema de talentos terá 60 pequenos, 25 grandes e 15 especiais **por vocação** em expansões; até 150 pontos para custo total 185.

## 3. Armas e ferramentas

| ID | Nome | Vocação | Dano inicial → melhorado | Alcance e ritmo provisórios |
|---|---|---|---|---|
| `sword_basic`, `sword_reinforced` | Espada improvisada/reforçada | Warrior | 12→18 AF | adjacente, 1 ataque/s |
| `bow_basic`, `bow_reinforced` | Arco improvisado/reforçado | Archer | 10→15 AF | até 5 SQMs, 0,8/s |
| `staff_basic`, `staff_crystal` | Cajado improvisado/cristalino | Mage | 10→16 AM | até 5 SQMs, 0,8/s |
| `axe_basic`, `pickaxe_basic` | Machado e picareta | todas | sem dano de combate definido | extração de madeira/pedra |

Uma família por vocação no MVP. Armas e ferramentas são itens funcionais; melhorias não alteram a aparência do personagem.

## 4. Habilidades e estados

| ID | Vocação | Alvo | Efeito | CD / MP |
|---|---|---|---|---|
| `war_combo` | Warrior | único | 3×120% AF, sem stun, efeito de item uma vez | 10s/10 |
| `war_circle` | Warrior | adjacentes | 100% AF + sangramento 1% HP máximo/s por 5s; tick até 20% AF, renova sem acumular | 15s/15 |
| `war_quake` | Warrior | área | 150% AF + 50% AM; derrubada/stun 3s | 90s/35 |
| `arc_precise` | Archer | único | invisível até 3s; disparo 100% AF + 50% AM, encerra invisibilidade, sem crítico extra | 10s/10 |
| `arc_bounce` | Archer | cadeia até 5 | 100/90/80/70/60% AF, alvos distintos | 14s/15 |
| `arc_pierce` | Archer | linha | 125% AF + 100% AM; acertar dá +25% velocidade por 6s uma vez | 90s/35 |
| `mag_bolt` | Mage | único | 150% AM | 5s/8 |
| `mag_fire` | Mage | área | 100% AM + queimadura 5% AM/s por 6s, sem acumular ou propagar no MVP | 14s/18 |
| `mag_ice` | Mage | raio | 300% AM, sem controle adicional | 90s/40 |

Estados a implementar: `bleed`, `burn`, `stun`, `invisible`, `attack_speed_up`, `downed`. Cada um precisa de duração, fonte, regras de reaplicação, VFX e UI de feedback; não presumir que a arte conceitual define hitbox.

## 5. Bestiário

| ID | Região | HP / ataque | Comportamento | XP | Loot |
|---|---|---|---|---:|---|
| `fox` | praia/floresta inicial | 35/5 | foge; revida se atacada | 10 | carne 1; couro 1 (50%) |
| `wolf` | floresta | 90/12 | agressivo, alcance curto; eventual dupla | 20 | carne 1, couro 1; presa 1 (30%) |
| `bear` | interior | 240/22 | lento, golpe forte anunciado | 50 | carne 2, couro 2, fragmento 1 |

Sem boss ou escalonamento automático pelo nível do jogador. Host decide drop uma vez, e respawn ocorre fora da visão e da proteção, com população limitada por chunk.

## 6. Recursos e drops

| ID | Fonte | Uso principal | Regra |
|---|---|---|---|
| `wood` | árvores | construções, ferramentas, armas | extração 2 XP |
| `stone` | rochas | construções, ferramentas, armas | extração 2 XP |
| `fiber` | plantas | barracas, curativo | quantidade/respawn a validar |
| `herb` | ervas | curativo | extração 1 XP |
| `meat` | animais | refeição futura/uso básico de recuperação | sem fome compulsória |
| `hide` | animais | crafting posterior | couro |
| `fang` | lobo | componente futuro | drop opcional |
| `crystal_shard` | urso, pontos cristalinos futuros | acampamento III e arma melhorada | ganho garantido no urso |

Recursos obrigatórios próximos do spawn e para evolução não dependem de chance rara.

## 7. Receitas

| ID | Produto | Insumos | Estação | Estado |
|---|---|---|---|---|
| `recipe_bandage` | curativo medicinal | 3 ervas + 1 fibra | bancada/fogueira inicial | 40 HP em 4 s, interrompe ao atacar |
| `recipe_axe` | machado | 5 madeira + 3 pedra | bancada inicial | extração |
| `recipe_pickaxe` | picareta | 4 madeira + 4 pedra | bancada inicial | extração |
| `recipe_sword_upgrade` | espada reforçada | 12 madeira + 8 pedra + 2 fragmentos | bancada II | provisório |
| `recipe_bow_upgrade` | arco reforçado | mesmos insumos | bancada II | provisório |
| `recipe_staff_upgrade` | cajado cristalino | mesmos insumos | bancada II | provisório |

**Dependência a testar:** se fragmentos só vierem do urso, melhoria da arma ocorre após encontrá-lo; o primeiro confronto deve ser vencível com arma básica. Ajustar origem/custo antes do S3 conforme playtest. Primeira fabricação por receita concede 10 XP, uma vez por personagem e mundo.

## 8. Construções e níveis do acampamento

| ID | Nível | Função |
|---|---|---|
| `pure_crystal`, `campfire`, `tent` | I | proteção/centro; descanso; respawn |
| `workbench`, `shared_chest`, `well` | II | craft; armazenagem; água/uso futuro |
| `palisade`, `watchtower` | III | perímetro; defesa simples (até 2 torres) |

Subida I→II: 30 madeira, 20 pedra, 10 fibra. II→III: 60 madeira, 40 pedra, 20 fibra, 5 fragmentos. Slots pré-definidos; torres defendem animais próximos, sem ondas agendadas. Construção concede 40 XP por participante elegível, uma vez por mundo. Slots, raio e dano das torres exigem protótipo.

## 9. Talentos

### Plano de produção vigente

O plano completo segue em 100 nós por vocação: 60 pequenos, 25 grandes e 15 especiais. A lista de produção inicial permanece em 18 candidatos por vocação, com nós conectados a partir da origem e escolhas exclusivas. Pequeno custa 1 ponto, grande 2 e especial 5. A lista é formada por 6 pequenos de combate, 3 de sobrevivência, 3 de exploração, 3 grandes e 3 especiais mutuamente exclusivos. Nomes e efeitos exatos por vocação precisam de aprovação antes de codificar em S3; **não declarar 300 nós implementados**. Até o nível 10 há 30 pontos, enquanto estes candidatos somam 33 se ignoradas as exclusões.

### Árvore passiva candidata v0.5 — arquivada para comparação

O protótipo testa uma malha compartilhada e conectada entre as três vocações. Ela contém 25 passivas pequenas em círculos, 6 passivas grandes em quadrados, 3 origens especiais em losangos com figuras de atores e 61 ligações bidirecionais. O texto “Actor” aparece abaixo de cada origem; ao selecionar qualquer nó, o painel lateral mostra nome, efeito, custo e estado. As origens não custam pontos. Os nós passivos custam 1 ou 2 pontos; os 31 passivos somam 37 pontos, acima dos 30 disponíveis até o nível 10. No protótipo, cada vocação começa com 3 pontos e só pode comprar um nó ligado a outro já desbloqueado; progresso é temporário e não é salvo.

Esta alternativa visual **não substitui** o plano de produção por vocação nem aprova nomes, efeitos ou custos. As IDs abaixo são candidatas de protótipo; IDs de produção continuam pendentes de validação e desenho de S3.

#### Roadmap visual candidato

1. **Escolha de origem:** Warrior no alto, Archer à esquerda e Mage à direita; cada origem abre uma entrada gratuita na rede.
2. **Núcleo de combate e atributos:** nós `s01–s12` e grandes `l01–l04`, próximos ao centro.
3. **Sobrevivência e coleta:** nós `s13–s21` e grandes `l05–l06`, em rotas intermediárias.
4. **Especialização externa:** nós `s22–s25`, nas rotas externas. A progressão real segue as ligações adjacentes, não uma ordem linear obrigatória.

#### Lista completa de nós candidatos

| ID | Tipo visual | Nome | Efeito candidato | Custo |
|---|---|---|---|---|
| `origin_warrior` | Origem especial · Warrior | Origem da Warrior | +2 Força inicial; abre a rota superior da rede. | Grátis |
| `origin_archer` | Origem especial · Archer | Origem da Archer | +2 Agilidade inicial; abre a rota esquerda da rede. | Grátis |
| `origin_mage` | Origem especial · Mage | Origem da Mage | +2 Inteligência inicial; abre a rota direita da rede. | Grátis |
| `s01` | Pequeno · círculo | Força I | +2 Força. Aumenta o dano físico básico. | 1 ponto |
| `s02` | Pequeno · círculo | Agilidade I | +2 Agilidade. Melhora precisão e esquiva. | 1 ponto |
| `s03` | Pequeno · círculo | Inteligência I | +2 Inteligência. Aumenta o dano mágico. | 1 ponto |
| `s04` | Pequeno · círculo | Fio Afiado | +2% de dano com espada. | 1 ponto |
| `s05` | Pequeno · círculo | Mira Estável | +2% de precisão com arco. | 1 ponto |
| `s06` | Pequeno · círculo | Passo Ágil | +2% de velocidade de movimento. | 1 ponto |
| `s07` | Pequeno · círculo | Guarda Firme | +2 de defesa. | 1 ponto |
| `s08` | Pequeno · círculo | Reserva de Mana | +3 de mana máxima. | 1 ponto |
| `s09` | Pequeno · círculo | Ponto Crítico | +1% de chance crítica. | 1 ponto |
| `s10` | Pequeno · círculo | Foco Arcano | +2% de dano mágico. | 1 ponto |
| `s11` | Pequeno · círculo | Reflexos | +2% de esquiva. | 1 ponto |
| `s12` | Pequeno · círculo | Tiro Longo | +1 tile de alcance com arco. | 1 ponto |
| `s13` | Pequeno · círculo | Madeireiro | +4% de madeira por coleta. | 1 ponto |
| `s14` | Pequeno · círculo | Vigor | +4 HP máximo. | 1 ponto |
| `s15` | Pequeno · círculo | Recuperação | +0,2 HP/s fora de combate. | 1 ponto |
| `s16` | Pequeno · círculo | Resistência | +2% de redução de dano físico. | 1 ponto |
| `s17` | Pequeno · círculo | Meditação | +0,2 MP/s fora de combate. | 1 ponto |
| `s18` | Pequeno · círculo | Minerador | +4% de pedra por coleta. | 1 ponto |
| `s19` | Pequeno · círculo | Afinidade Cristalina | +3% de chance de encontrar fragmento de cristal. | 1 ponto |
| `s20` | Pequeno · círculo | Herbologista | +4% de ervas por coleta. | 1 ponto |
| `s21` | Pequeno · círculo | Tratamento | +3% de cura recebida. | 1 ponto |
| `s22` | Pequeno · círculo | Sobrevivência | +3% de HP máximo. | 1 ponto |
| `s23` | Pequeno · círculo | Eficiência de Mana | -2% no custo de habilidades. | 1 ponto |
| `s24` | Pequeno · círculo | Cadência | +2% de velocidade de ataque. | 1 ponto |
| `s25` | Pequeno · círculo | Conhecedor do Terreno | +3% de chance de encontrar recursos raros. | 1 ponto |
| `l01` | Grande · quadrado | Mestre das Lâminas | +12% de dano com espada. | 2 pontos |
| `l02` | Grande · quadrado | Sentinela | +12 de defesa e +5% de bloqueio. | 2 pontos |
| `l03` | Grande · quadrado | Condutor Arcano | +10% de dano mágico e +10 MP. | 2 pontos |
| `l04` | Grande · quadrado | Atirador de Elite | +10% de precisão e +1 tile de alcance com arco. | 2 pontos |
| `l05` | Grande · quadrado | Inquebrável | +12% de HP e +0,2 HP/s fora de combate. | 2 pontos |
| `l06` | Grande · quadrado | Explorador Experiente | +12% de rendimento nas coletas. | 2 pontos |

O catálogo JSON preserva o plano vigente e contém os dados gráficos completos da alternativa em `prototype_graph_candidate`.
### Referência visual escolhida — protótipo v0.6

Arquivo validado: [imagem endgame](../../docs/prototypes/assets/passive_skill_tree_endgame_reference.png), PNG RGBA 1672×941. Esta é a referência visual escolhida pelo usuário e aparece diretamente no protótipo navegável v0.6. A imagem é conceitual; não exporta uma topologia exata de nós e elos.

Regra de progressão para a prévia: o nó inicial da vocação fica desbloqueado por padrão; os demais nós são liberados automaticamente conforme o nível do personagem. O protótipo demonstra níveis 1–10 e associa as cinco gerações aos níveis 2, 4, 6, 8 e 10. Essa associação é apenas ilustrativa e ainda precisa de validação antes de orientar implementação. O plano de conteúdo de 100 nós por vocação continua vigente.

## 10. Regiões e geração

| ID | Distância relativa | Garantias |
|---|---|---|
| `beach_spawn` | centro inicial protegido | destroços do cruzeiro, cristal, fogueira, madeira/pedra/ervas, rota de saída |
| `green_forest` | primeira expansão | raposas/lobos, árvores/rochas, rio, ponte e pontos de interesse |
| `bear_interior` | área distante acessível | ursos, cristais e objetivo final do MVP |
| `corrupted_castle` | apenas no concept | Vael e exército; sem conteúdo jogável no MVP |

Seed fixa, chunks 32×32, ilha até 1000×1000 tiles. Pontos de interesse a ~80–150 SQMs na parte habitada, testados por tempo de travessia. Proteger rota, recursos essenciais e spawn dos personagens; não posicionar inimigos na área segura.

## 11. Animações e VFX

Personagens: 8 direções (N, NE, E, SE, S, SO, O, NO) × `idle` 4, `walk` 6, `attack` 6, `hit` 3, `death` 6, `cast` 6 frames propostos. Uma folha separada por aparência × vocação × estado; células candidatas 96×96 RGBA, pivô nos pés (48,80), alinhamento e fps registrados em metadados. Animais precisam de idle/walk/attack/hit/death coerentes; urso pode usar célula maior. VFX separados: slash, sangue estilizado sem gore, tremor, invisibilidade, ricochete, flecha perfurante, projétil arcano, fogo, gelo, coleta, cura, cristal e construção. Testar alpha/pivô/zoom antes de produção em lote. Ver [guia de sprites](../../docs/art/ART_DIRECTION_AND_SPRITES.md).

## 12. Interface e áudio

**Telas:** abertura, visitante/vínculo da conta, escolha de aparência e vocação, criar/entrar em ilha LAN, gameplay, inventário/craft, árvore, pausa/salvar, resultado da expedição e erro recuperável. **HUD:** retrato, HP/MP, objetivo, minimapa, joystick esquerdo, ataque/três skills à direita, curativo, mochila, interação e zoom 50–125%. Layout sensível a polegares, recorte/notch, DPI e orientação retrato 9:16.

**Áudio mínimo:** tema de abertura/refúgio, ambiência de praia/floresta, coleta, passos, ataque por vocação, nove skills (podem compartilhar camadas), dano, drop, cura, construção, UI e aviso de aliado caído. Arquivos/licenças e mixagem aguardam produção; áudio deve poder ser silenciado por categoria. Efeitos visuais e sonoros confirmam ação, cooldown, erro de mana e salvamento; placeholders técnicos não são aprovação visual.

A proposta de inventário navegável v0.7 organiza a tela em três colunas: grade de equipamento 4×3 à esquerda, mochila com 24 espaços ao centro e painel contextual à direita. A grade segue a matriz acordada: [slot, capacete, amuleto] / [arma principal, armadura, offhand] / [joia, calça, joia] / [slot, botas, slot]. Slots sem item exibem espaços vazios; armaduras e acessórios ainda não possuem catálogo de atributos aprovado.

No protótipo, o painel direito abre em Atributos, com FOR, AGI e INT, descrições, pontos disponíveis, controles de distribuição e o efeito numérico de cada ponto. Ao selecionar um item, o painel mostra nome, descrição, status/localização, atributos e ação contextual (equipar/desequipar ou usar). O exemplo começa no nível 4 com 3 pontos livres; atributos brutos começam em zero, HP/MP base vêm da vocação e os bônus usam os multiplicadores e conversões do GDD. A simulação não salva dados e não aprova a tela para produção. Equipamentos não alteram a aparência do personagem.

## Próximo fechamento de produção

Antes de criar sprites em lote, testar uma personagem e uma raposa em Godot Android; antes da árvore S3, especificar 18 IDs/efeitos/conexões por vocação; antes de LAN, definir IDs de eventos/drops e transações de baú. Os catálogos são completos como **listas de planejamento**, com campos ainda marcados para validação nos sprints.
