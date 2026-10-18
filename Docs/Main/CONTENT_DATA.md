# Conteúdo e balanceamento inicial

Valores de teste, não promessa de equilíbrio. Fonte única futura em `data/*.json`; validar esquemas e IDs antes de cada build. Salvar IDs estáveis, não textos exibidos. Fórmulas em GDD.

## Atributos, armas e itens

| Vocação | HP/MP | Atributo primário | Arma inicial → melhoria | Ataque base provisório | Cadência/alcance |
|---|---|---|---|---|---|
| Warrior | 200/100 | FOR | espada improvisada → espada reforçada | 12 → 18 AF | 1 ataque/s, adjacente |
| Archer | 150/150 | AGI | arco improvisado → arco reforçado | 10 → 15 AF | 0,8 ataque/s, até 5 SQMs |
| Mage | 100/200 | INT | cajado improvisado → cajado cristalino | 10 → 16 AM | 0,8 ataque/s, até 5 SQMs |

Para não expor a árvore a escalas ambíguas: ponto bruto investido × multiplicador da vocação gera FOR/AGI/INT efetivo. Conversões: +0,6 dano melee e +3 HP por FOR efetivo; +0,6 dano à distância, +0,05 ponto percentual crítico e +0,05 p.p. esquiva por AGI efetivo; +0,6 dano mágico e +3 MP por INT efetivo. Crítico base 5%, esquiva base 3%, máximo 20% cada. Dano crítico inicialmente 150% do golpe, salvo Disparo preciso cuja parcela já é especial. HP/MP inicial são atributos-base da vocação e não pontos brutos distribuídos: Warrior 200/100, Archer 150/150 e Mage 100/200. Pontos investidos acrescentam bônus conforme os multiplicadores, sem substituir a base. Todos os valores precisam de playtest solo e dupla.

Regeneração é percentual do HP/MP máximo por segundo; cada ponto bruto usa o multiplicador da vocação antes de aplicar o bônus e o teto. Após 8 s sem atacar nem receber dano, usa-se a taxa fora de combate. Nesse estado, base e bônus de atributo são multiplicados por 1,2; combate permanece igual. Bases HP combate/fora após o fator: Warrior 0,20%/0,72%, Archer 0,15%/0,60%, Mage 0,10%/0,42%. Bases MP: Warrior 0,03%/0,144%, Archer 0,06%/0,30%, Mage 0,10%/0,48%. Cada FOR efetiva dá +0,003 p.p./s em combate e +0,012 fora; cada INT efetiva dá +0,001 p.p./s e +0,0048 fora. Tetos: HP 0,5%/s em combate e 2% fora; MP 0,25%/s em combate e 1% fora. O tick não excede o HP/MP máximo e fica suspenso quando o personagem está caído. Subir de nível continua restaurando HP e MP por completo. O catálogo executável é a fonte numérica: `data/catalogs/mvp.json`.

Craft de teste: curativo = 3 ervas + 1 fibra, restaura 40 HP ao longo de 4 s, interrompido se atacar; machado = 5 madeira + 3 pedra; picareta = 4 madeira + 4 pedra. Melhorias de armas: 12 madeira + 8 pedra + 2 fragmentos; receita/quantidade sujeita a teste. Sem equipamentos visuais, tiers ou raridade de loot no MVP. Não oferecer probabilidades aleatórias para recursos indispensáveis às construções.

## Bestiário e drops

| Nome / ID | Região | HP | Ataque | Comportamento | XP | Drops | Sprite estático |
|---|---|---:|---:|---|---:|---|---|
| Raposa (`fox`) | Praia inicial | 35 | 5 | foge; revida se atacada | 10 | 1 meat; 1 hide (50%) | [`PNG`](../../assets/creatures/fox/fox_static_concept_v0_1.png) · pose SE |
| Lobo (`wolf`) | Floresta verde | 90 | 12 | agressivo; persegue e ataca | 20 | 1 meat; 1 hide; 1 fang (30%) | [`PNG`](../../assets/creatures/wolf/wolf_static_concept_v0_1.png) · pose SE |
| Urso (`bear`) | Interior cristalino | 240 | 22 | agressivo; persegue e ataca | 50 | 2 meat; 2 hide; 1 crystal shard | [`PNG`](../../assets/creatures/bear/bear_static_concept_v0_1.png) · pose SE |
| Raposa de Maré (`tidal_fox`) | Praia inicial | 42 | 6 | foge; revida se atacada | 10 | sem loot definido | [`PNG`](../../assets/creatures/tidal_fox/tidal_fox_static_concept_v0_1.png) · pose SE |
| Caranguejo-Cristal (`crystal_crab`) | Praia inicial | 70 | 8 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/crystal_crab/crystal_crab_static_concept_v0_1.png) · pose SE |
| Garça-Lúmen (`lumen_heron`) | Lagoa cristalina | 48 | 7 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/lumen_heron/lumen_heron_static_concept_v0_1.png) · pose SE |
| Lobo-de-Sal (`salt_wolf`) | Praia inicial | 105 | 14 | foge; revida se atacada | 20 | sem loot definido | [`PNG`](../../assets/creatures/salt_wolf/salt_wolf_static_concept_v0_1.png) · pose SE |
| Javali de Raízes (`root_boar`) | Floresta verde | 125 | 16 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/root_boar/root_boar_static_concept_v0_1.png) · pose SE |
| Corça de Musgo (`moss_deer`) | Floresta verde | 48 | 0 | foge; não ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/moss_deer/moss_deer_static_concept_v0_1.png) · pose SE |
| Urso Prismático (`prismatic_bear`) | Interior cristalino | 285 | 26 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/prismatic_bear/prismatic_bear_static_concept_v0_1.png) · pose SE |
| Trepadeira Violeta (`violet_vine`) | Terras corrompidas | 150 | 18 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/violet_vine/violet_vine_static_concept_v0_1.png) · pose SE |
| Sentinela de Obsidiana (`obsidian_sentinel`) | Ruínas de obsidiana | 320 | 28 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/obsidian_sentinel/obsidian_sentinel_static_concept_v0_1.png) · pose SE |
| Errante Corrompido (`corrupted_wanderer`) | Ruínas de obsidiana | 220 | 23 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/corrupted_wanderer/corrupted_wanderer_static_concept_v0_1.png) · pose SE |
| Crocodilo da Lagoa (`lagoon_crocodile`) | Lagoa cristalina | 165 | 19 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/lagoon_crocodile/lagoon_crocodile_static_concept_v0_1.png) · pose SE |
| Tartaruga Coralina (`coral_turtle`) | Praia inicial | 130 | 10 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/coral_turtle/coral_turtle_static_concept_v0_1.png) · pose SE |
| Lagarto de Arrecife (`reef_lizard`) | Praia inicial | 60 | 8 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/reef_lizard/reef_lizard_static_concept_v0_1.png) · pose SE |
| Macaco de Copa (`canopy_monkey`) | Floresta verde | 70 | 9 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/canopy_monkey/canopy_monkey_static_concept_v0_1.png) · pose SE |
| Morcego-Fruta (`fruit_bat`) | Floresta verde | 38 | 6 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/fruit_bat/fruit_bat_static_concept_v0_1.png) · pose SE |
| Cobra das Raízes (`root_snake`) | Floresta verde | 65 | 12 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/root_snake/root_snake_static_concept_v0_1.png) · pose SE |
| Aranha Prismática (`prismatic_spider`) | Floresta verde | 90 | 13 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/prismatic_spider/prismatic_spider_static_concept_v0_1.png) · pose SE |
| Sapo-Lúmen (`lumen_frog`) | Lagoa cristalina | 50 | 6 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/lumen_frog/lumen_frog_static_concept_v0_1.png) · pose SE |
| Slime de Cristal (`crystal_slime`) | Lagoa cristalina | 95 | 12 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/crystal_slime/crystal_slime_static_concept_v0_1.png) · pose SE |
| Besouro de Obsidiana (`obsidian_beetle`) | Terras corrompidas | 110 | 14 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/obsidian_beetle/obsidian_beetle_static_concept_v0_1.png) · pose SE |
| Enguia-Lúmen (`lumen_eel`) | Lagoa cristalina | 80 | 14 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/lumen_eel/lumen_eel_static_concept_v0_1.png) · pose SE |
| Lontra Turquesa (`turquoise_otter`) | Lagoa cristalina | 80 | 9 | agressivo; persegue e ataca | 10 | sem loot definido | [`PNG`](../../assets/creatures/turquoise_otter/turquoise_otter_static_concept_v0_1.png) · pose SE |
| Gárgula de Basalto (`basalt_gargoyle`) | Ruínas de obsidiana | 270 | 25 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/basalt_gargoyle/basalt_gargoyle_static_concept_v0_1.png) · pose SE |
| Lobo Espectral (`spectral_wolf`) | Terras corrompidas | 185 | 21 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/spectral_wolf/spectral_wolf_static_concept_v0_1.png) · pose SE |
| Treant Corrompido (`corrupted_treant`) | Terras corrompidas | 340 | 29 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/corrupted_treant/corrupted_treant_static_concept_v0_1.png) · pose SE |
| Golem de Cristal (`crystal_golem`) | Interior cristalino | 300 | 27 | agressivo; persegue e ataca | 50 | sem loot definido | [`PNG`](../../assets/creatures/crystal_golem/crystal_golem_static_concept_v0_1.png) · pose SE |
| Serpente Violeta (`violet_serpent`) | Terras corrompidas | 200 | 24 | agressivo; persegue e ataca | 20 | sem loot definido | [`PNG`](../../assets/creatures/violet_serpent/violet_serpent_static_concept_v0_1.png) · pose SE |


## XP e árvore

Níveis 1→10: 100, 130, 169, 220, 286, 371, 483, 627, 816 XP (total acumulado 3.202). Coletar árvore 2 XP, pedra 2, erva 1; fabricar uma receita pela primeira vez 10; melhoria do acampamento 40 por participante; descobrir uma região pela primeira vez 30; raposa/lobo/urso 10/20/50. XP de coleta somente na extração efetiva, não por toque; descoberta/primeira receita identificadas por personagem e mundo, sem loop montar/desmontar. XP de monstro integral aos participantes próximos e ativos, nunca duplicado na rede. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest. Ajustar curva após medir tempo até nível 10 em sessões reais.

Árvore planejada **por vocação**: 60 pequenos/25 grandes/15 especiais, divididos aproximadamente em combate (24/10/6), sobrevivência (18/8/4) e exploração/coleta/craft (18/7/5). Não criar 100 nós completos no primeiro sprint. Primeiros ~18 nós por vocação: seis pequenos de atributo/arma, três de HP/MP, três de coleta, três grandes para habilidade principal/defesa/eficiência e três especiais mutuamente exclusivos para especialização de combate, suporte ou exploração. Só comprar nós conectados a uma raiz; específicos da vocação mudam comportamento, não somente +% de dano. Especificar IDs e valores de cada nó antes da implementação da árvore no S3. Limite de 30 pontos no nível 10 e 150 no 50 torna compra integral impossível (custo 185).


O protótipo navegável v0.5 também explora uma malha compartilhada com 25 nós pequenos, 6 grandes e 3 origens de vocação. É uma alternativa visual em avaliação; a distribuição por vocação acima continua vigente até validação explícita. A lista e o roadmap candidatos estão em [CATALOGS_MVP.md](CATALOGS_MVP.md#9-talentos) e a interação pode ser testada em [mvp_ui_v0_5.html](../../docs/prototypes/mvp_ui_v0_5.html).
## Tabelas de dados a criar no S0/S2

`characters.json`: aparência_id, vocacao_id, HP/MP base, multiplicadores; `weapons.json`: ID, família, dano, alcance, cadência, receita; `skills.json`: ID, alvo, alcance/área, AF/AM, duração, CD, MP, estados; `monsters.json`: ID, HP, IA, ataques, XP, tabela de drops; `resources.json`: ID, rendimento, respawn, XP; `recipes.json`: entrada/saída, estação; `talents.json`: ID, custo, conexão, limite/exclusividade. Versionar schema e validar referências cruzadas em CI.


A referência visual da árvore endgame escolhida pelo usuário está em `docs/prototypes/assets/passive_skill_tree_endgame_reference.png` e é exibida no protótipo v0.6. A prévia inicia a origem da vocação desbloqueada e libera automaticamente os demais nós por nível. Os marcos de geração 2/4/6/8/10 são ilustrativos, aguardando validação; a imagem não é uma exportação de dados de nós.


