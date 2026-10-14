# GDD minimalista — A Ilha do Cristal

**v0.1 · 2026-10-14 · Pré-produção.** Mobile-first Android horizontal, desktop futuro. RPG 2D top-down em SQMs, sobrevivência cooperativa casual, ritmo deliberado, exploração procedural e progressão permanente. Arte aprovada: RPG Clássico. Os números descritos são valores iniciais para playtest.

## História e objetivo

Uma tempestade naufraga o cruzeiro. Melissa e Helena chegam a uma ilha, encontram um cristal puro e despertam poderes. Vael, o primeiro humano a usar o cristal, buscou poder até perder sua humanidade; sua corrupção alterou animais, plantas e pessoas. O cristal puro protege o refúgio. No MVP Vael aparece apenas como mistério distante, sem boss/castelo jogável. Objetivo: elevar o acampamento ao nível III e alcançar a região do urso.

Loop: preparar no refúgio → explorar → coletar/lutar → retornar → fabricar/ampliar. Sessões alvo de 15–30 minutos; pequenos encontros, sem hordas, moeda, fome/sede obrigatórias ou perda permanente do personagem.

## Personagens e entrada

Melissa tem 8 anos, é um pouco mais alta e tem cabelo castanho-escuro com **uma única mecha roxa frontal**. Helena tem 7 anos, cabelos castanhos ondulados e tiara clara. Qualquer pessoa pode criar uma das duas em qualquer vocação; aparência não é reservada a uma conta. Guerreiro (Warrior), Arqueiro (Archer) e Mago (Mage) são escolhas permanentes por personagem. Equipamentos alteram números, jamais o visual do personagem. Fotos são referências privadas e não entram no repositório.

No MVP: duas aparências, três vocações, uma arma inicial e uma melhora por vocação, três habilidades ativas por vocação, raposa/lobo/urso, árvore parcial e nível máximo 10, solo e dois jogadores Wi-Fi local. NPCs coletores, novos monstros, outros biomas, castelo, Vael boss, construção livre e desktop são expansões.

## Controle e mundo

Paisagem; joystick virtual à esquerda, ataque/3 skills à direita; toque em objeto para interagir. HP/MP, minimapa, mochila, objetivo, hotbar e zoom em bordas. Zoom padrão 75%, faixa 50–125%, ajustável e salvo localmente. Movimento em oito direções sobre SQMs, diagonal normalizada, ataque básico automático no alvo selecionado quando ao alcance; magias sempre manuais. Legibilidade do personagem e tamanho dos botões dependem de teste real.

Ilha máxima planejada 1000×1000 SQMs; seed e chunks 32×32. Praia/spawn com recursos básicos garantidos, floresta com lobos e interior com ursos. Raposas perto do início. Sem spawn em área protegida ou colado ao jogador. Pontos de interesse a cada ~80–150 SQMs nas áreas do MVP, ajustados pelo tempo de travessia. O MVP pode povoar apenas uma parte da ilha.

## Progressão

HP/MP iniciais: Warrior 200/100; Archer 150/150; Mage 100/200. Força → dano físico melee, HP, regeneração; Agilidade → dano físico à distância, crítico, esquiva; Inteligência → mana, regeneração MP, dano mágico. Multiplicadores por ponto bruto: Warrior FOR 2 / AGI 0,75 / INT 0,5; Archer 1 / 2 / 0,75; Mage 0,5 / 0,75 / 2. Crescimento de atributo é linear; efeitos precisam de coeficientes próprios. Crítico e esquiva limitados a 20%. Regeneração de HP por Força no máximo 2% HP máximo/s fora de combate (após 8 s sem atacar/ser atingido) e 0,5%/s em combate; tetos não são valores iniciais. As três vocações devem poder usar habilidades sem investir em INT.

Cada subida dá 1 ponto bruto de atributo. Árvore: 3 pontos na criação e 3 por subida até nível 50, 150 pontos no total; após 50 continua 1 ponto bruto/subida. Por vocação, plano de 60 nós pequenos (1 ponto), 25 grandes (2) e 15 especiais (5): 185 pontos para comprar tudo. Conexões desde o centro e escolhas exclusivas dão identidade às builds. No nível 10: 30 pontos de árvore; implementar primeiro ~18 nós acessíveis por vocação, conforme `CONTENT_DATA.md`.

XP para sair do nível n: `round(100 × 1,3^(n-1))`. Custos níveis 1→10: 100, 130, 169, 220, 286, 371, 483, 627, 816; total 3.202. Raposa 10 XP, lobo 20, urso 50. Cada participante próximo recebe XP integral por derrota, uma vez. Outras fontes e proteções anti-farm: [CONTENT_DATA.md](CONTENT_DATA.md).

## Habilidades

AF = ataque físico após arma/atributo; AM = ataque mágico. Dano híbrido soma parcelas distintas. Coeficientes, alcance/raio, defesa, animações e custos de MP precisam de testes.

| Vocação | Skill | Efeito | CD / MP |
|---|---|---|---|
| Warrior | Combo | 3 golpes ×120% AF num alvo, sem stun; efeito de item no máximo uma vez | 10 s / 10 |
| Warrior | Corte circular | 100% AF adjacente; sangra 1% HP máximo do alvo/s por 5 s, tick limitado a 20% AF, sem acumular | 15 s / 15 |
| Warrior | Terremoto | 150% AF + 50% AM na área; derruba/atordoa por 3 s | 90 s / 35 |
| Archer | Disparo preciso | invisível por até 3 s; próximo tiro 100% AF + 50% AM, encerra invisibilidade e não recebe segundo multiplicador crítico | 10 s / 10 |
| Archer | Ricochete | salta entre até 5 alvos distintos: 100/90/80/70/60% AF | 14 s / 15 |
| Archer | Flecha perfurante | atravessa linha, 125% AF + 100% AM; ao acertar, +25% velocidade de ataque por 6 s, uma vez por uso | 90 s / 35 |
| Mage | Projétil arcano | 150% AM num alvo | 5 s / 8 |
| Mage | Bola de fogo | 100% AM na área; queima 5% AM/s durante 6 s, sem acumular; propagação futura | 14 s / 18 |
| Mage | Explosão de gelo | 300% AM em raio curto; sem controle adicional no MVP | 90 s / 40 |

## Refúgio, derrota e cooperação

Recursos básicos: madeira, pedra, fibra, erva, carne, couro, presa e fragmento cristalino. Machado/picareta, curativo de ervas e crafting simples. Acampamento I = cristal, fogueira, barracas. II custa 30 madeira/20 pedra/10 fibra e libera bancada, baú compartilhado e poço. III custa 60 madeira/40 pedra/20 fibra/5 fragmentos e libera cerca e duas torres. Construções ocupam slots predefinidos; nenhuma cidade inteira.

Ao chegar a 0 HP, caído por 60 s; aliado reanima em 5 s. Esgotado o prazo: retorna à barraca e deixa metade dos materiais coletados na expedição numa mochila persistente. Equipamentos/XP ficam. Se todos caírem, expedição termina e retornam ao acampamento; mochilas permanecem e nova queda não apaga mochila antiga.

Host Android controla mundo, dano, drops, inventário e construções; cliente envia intenções. Até dois participantes na mesma rede Wi-Fi. Saída do host salva mundo e encerra sessão. Mundo/inventário daquele mundo ficam no dispositivo do host; personagem, vocação, nível, atributos e árvore na conta quando online. Começo visitante e vínculo posterior; LAN deve funcionar sem internet. Plano detalhado de save e conflitos em [ARCHITECTURE.md](../../docs/technical/ARCHITECTURE.md).

## Aceite do MVP

Em dois Androids, criar personagens de aparências/vocações independentes; ajustar câmera; coletar, fabricar, lutar com três animais e nove skills; compartilhar XP e reanimar; concluir acampamento III e alcançar o urso. Fechar/reabrir preserva dados; desconectar cliente/host não duplica itens. Testar solo, pausa do app, save interrompido e reconexão. A prancha é referência visual, não comprovação de sprites ou da interface final.
