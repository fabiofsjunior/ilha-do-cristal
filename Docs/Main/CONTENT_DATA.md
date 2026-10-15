# Conteúdo e balanceamento inicial

Valores de teste, não promessa de equilíbrio. Fonte única futura em `data/*.json`; validar esquemas e IDs antes de cada build. Salvar IDs estáveis, não textos exibidos. Fórmulas em GDD.

## Atributos, armas e itens

| Vocação | HP/MP | Atributo primário | Arma inicial → melhoria | Ataque base provisório | Cadência/alcance |
|---|---|---|---|---|---|
| Warrior | 200/100 | FOR | espada improvisada → espada reforçada | 12 → 18 AF | 1 ataque/s, adjacente |
| Archer | 150/150 | AGI | arco improvisado → arco reforçado | 10 → 15 AF | 0,8 ataque/s, até 5 SQMs |
| Mage | 100/200 | INT | cajado improvisado → cajado cristalino | 10 → 16 AM | 0,8 ataque/s, até 5 SQMs |

Para não expor a árvore a escalas ambíguas: ponto bruto investido × multiplicador da vocação gera FOR/AGI/INT efetivo. Proposta de conversão inicial: +0,6 dano melee e +3 HP por FOR efetivo; +0,6 dano à distância, +0,05 ponto percentual crítico e +0,05 p.p. esquiva por AGI efetivo; +0,6 dano mágico e +3 MP por INT efetivo. Regeneração HP/MP derivada de atributos deve começar baixa e respeitar tetos. Crítico base 5%, esquiva base 3%, máximo 20% cada. Dano crítico inicialmente 150% do golpe, salvo Disparo preciso cuja parcela já é especial. HP/MP inicial são atributos-base da vocação e não pontos brutos distribuídos: Warrior 200/100, Archer 150/150 e Mage 100/200. Pontos investidos acrescentam bônus conforme os multiplicadores, sem substituir a base. Todos os valores precisam de playtest solo e dupla.

Craft de teste: curativo = 3 ervas + 1 fibra, restaura 40 HP ao longo de 4 s, interrompido se atacar; machado = 5 madeira + 3 pedra; picareta = 4 madeira + 4 pedra. Melhorias de armas: 12 madeira + 8 pedra + 2 fragmentos; receita/quantidade sujeita a teste. Sem equipamentos visuais, tiers ou raridade de loot no MVP. Não oferecer probabilidades aleatórias para recursos indispensáveis às construções.

## Bestiário e drops

| ID | HP | Ataque | Comportamento | XP | Drops garantidos / probabilísticos |
|---|---:|---:|---|---:|---|
| fox | 35 | 5 | foge, reage se ferida; praia/floresta inicial | 10 | carne 1; couro 1 com 50% |
| wolf | 90 | 12 | persegue alcance curto; floresta, ocasionalmente dupla | 20 | carne 1, couro 1; presa 1 com 30% |
| bear | 240 | 22 | lento; golpe forte telegráfico e pausa; interior | 50 | carne 2, couro 2, fragmento 1 |

Desaparecer/reaparecer fora da visão do jogador com limite de população por chunk; sem spawn no perímetro protegido, sem enxame e sem boss. Defesa, intervalo de ataque, raio e crescimento por região aguardam playtest. Monstros não escalam automaticamente com o nível do jogador: variantes futuras são ligadas a regiões/expansões. Drops são decididos pelo host; uma morte de monstro gera exatamente um evento de recompensa.

## XP e árvore

Níveis 1→10: 100, 130, 169, 220, 286, 371, 483, 627, 816 XP (total acumulado 3.202). Coletar árvore 2 XP, pedra 2, erva 1; fabricar uma receita pela primeira vez 10; melhoria do acampamento 40 por participante; descobrir uma região pela primeira vez 30; raposa/lobo/urso 10/20/50. XP de coleta somente na extração efetiva, não por toque; descoberta/primeira receita identificadas por personagem e mundo, sem loop montar/desmontar. XP de monstro integral aos participantes próximos e ativos, nunca duplicado na rede. Ajustar curva após medir tempo até nível 10 em sessões reais.

Árvore planejada **por vocação**: 60 pequenos/25 grandes/15 especiais, divididos aproximadamente em combate (24/10/6), sobrevivência (18/8/4) e exploração/coleta/craft (18/7/5). Não criar 100 nós completos no primeiro sprint. Primeiros ~18 nós por vocação: seis pequenos de atributo/arma, três de HP/MP, três de coleta, três grandes para habilidade principal/defesa/eficiência e três especiais mutuamente exclusivos para especialização de combate, suporte ou exploração. Só comprar nós conectados a uma raiz; específicos da vocação mudam comportamento, não somente +% de dano. Especificar IDs e valores de cada nó antes da implementação da árvore no S3. Limite de 30 pontos no nível 10 e 150 no 50 torna compra integral impossível (custo 185).


O protótipo navegável v0.5 também explora uma malha compartilhada com 25 nós pequenos, 6 grandes e 3 origens de vocação. É uma alternativa visual em avaliação; a distribuição por vocação acima continua vigente até validação explícita. A lista e o roadmap candidatos estão em [CATALOGS_MVP.md](CATALOGS_MVP.md#9-talentos) e a interação pode ser testada em [mvp_ui_v0_5.html](../../docs/prototypes/mvp_ui_v0_5.html).
## Tabelas de dados a criar no S0/S2

`characters.json`: aparência_id, vocacao_id, HP/MP base, multiplicadores; `weapons.json`: ID, família, dano, alcance, cadência, receita; `skills.json`: ID, alvo, alcance/área, AF/AM, duração, CD, MP, estados; `monsters.json`: ID, HP, IA, ataques, XP, tabela de drops; `resources.json`: ID, rendimento, respawn, XP; `recipes.json`: entrada/saída, estação; `talents.json`: ID, custo, conexão, limite/exclusividade. Versionar schema e validar referências cruzadas em CI.


A referência visual da árvore endgame escolhida pelo usuário está em `docs/prototypes/assets/passive_skill_tree_endgame_reference.png` e é exibida no protótipo v0.6. A prévia inicia a origem da vocação desbloqueada e libera automaticamente os demais nós por nível. Os marcos de geração 2/4/6/8/10 são ilustrativos, aguardando validação; a imagem não é uma exportação de dados de nós.
