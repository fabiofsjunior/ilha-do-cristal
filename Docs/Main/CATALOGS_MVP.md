# Catálogos do MVP — A Ilha do Cristal

**v0.1 · 2026-10-14.** Esta é a lista de produção das doze famílias de conteúdo. Regras narrativas, identidade das personagens, vocações e magias seguem o [GDD](GDD_MVP.md). Valores numéricos de armas, drops, receitas e construções são **provisórios** para playtest. A representação legível por máquina está em [`data/catalogs/mvp.json`](../../data/catalogs/mvp.json). IDs não devem mudar depois de aparecerem em saves.

## 1. Personagens e vocações

| ID | Nome | Identidade visual fixa | Escolha |
|---|---|---|---|
| `melissa` | Melissa | 8 anos, levemente mais alta, cabelo castanho-escuro com **uma mecha roxa frontal**, acentos lilases | Warrior/Archer/Mage |
| `helena` | Helena | 7 anos, cabelo castanho ondulado, tiara clara, acentos creme-rosa | Warrior/Archer/Mage |

Qualquer conta pode usar qualquer aparência, inclusive repetida na LAN. O equipamento não altera o visual. `warrior`: HP/MP 200/100, FOR/AGI/INT ×2/0,75/0,5; `archer`: 150/150, ×1/2/0,75; `mage`: 100/200, ×0,5/0,75/2. Vocação permanente **por personagem**.

## 2. Atributos e níveis

FOR: melee, vida e regeneração. AGI: físico à distância, crítico e esquiva. INT: mana, regeneração de mana e mágico. Conversões provisórias por ponto efetivo: FOR +0,6 melee e +3 HP; AGI +0,6 distância, +0,05 ponto percentual de crítico e de esquiva; INT +0,6 mágico e +3 MP. Crítico base 5%, esquiva base 3%; tetos de 20% cada. Regeneração HP limitada a 2%/s fora de combate e 0,5%/s em combate; não começa no teto.

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

O plano completo são 100 nós por vocação; **a lista de produção inicial contém 18 nós candidatos por vocação**, com conexão a partir do centro e escolhas exclusivas. Pequeno custa 1, grande 2, especial 5. Os 18 candidatos são: 6 pequenos de combate (dano básico, alcance/cadência, custo de mana, precisão, habilidade única, habilidade de área); 3 pequenos de sobrevivência (HP, MP, regeneração); 3 pequenos de exploração (madeira, pedra, erva/pesca futura); 3 grandes (habilidade principal, defesa, eficiência de coleta); 3 especiais mutuamente exclusivos (combate, suporte, exploração). Nomes/efeitos exatos por vocação e grafos completos devem ser aprovados antes de codificar a árvore em S3; **não declarar 300 nós implementados**. Até o nível 10 há 30 pontos, enquanto esses candidatos somam 33 se ignorar exclusões.

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

**Telas:** abertura, visitante/vínculo da conta, escolha de aparência e vocação, criar/entrar em ilha LAN, gameplay, inventário/craft, árvore, pausa/salvar, resultado da expedição e erro recuperável. **HUD:** retrato, HP/MP, objetivo, minimapa, joystick esquerdo, ataque/três skills à direita, curativo, mochila, interação e zoom 50–125%. Layout sensível a polegares, recorte/notch, DPI e orientação horizontal.

**Áudio mínimo:** tema de abertura/refúgio, ambiência de praia/floresta, coleta, passos, ataque por vocação, nove skills (podem compartilhar camadas), dano, drop, cura, construção, UI e aviso de aliado caído. Arquivos/licenças e mixagem aguardam produção; áudio deve poder ser silenciado por categoria. Efeitos visuais e sonoros confirmam ação, cooldown, erro de mana e salvamento; placeholders técnicos não são aprovação visual.

## Próximo fechamento de produção

Antes de criar sprites em lote, testar uma personagem e uma raposa em Godot Android; antes da árvore S3, especificar 18 IDs/efeitos/conexões por vocação; antes de LAN, definir IDs de eventos/drops e transações de baú. Os catálogos são completos como **listas de planejamento**, com campos ainda marcados para validação nos sprints.
