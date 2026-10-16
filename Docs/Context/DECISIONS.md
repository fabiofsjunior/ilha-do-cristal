# Decisões — 2026-10-14

- Nome **A Ilha do Cristal**; naufrágio de cruzeiro; estética **RPG Clássico 2D pixel art**. Vael perde a humanidade ao buscar poder e causa mutações; castelo e exército são expansão futura.
- Mobile-first Android, paisagem, joystick virtual esquerdo, ações e magias à direita, toque em objetos, zoom padrão 75% e faixa 50–125% sujeita a teste.
- Qualquer conta cria Melissa, Helena, Maíra ou Fábio em qualquer vocação; vocação permanente por personagem. Equipamento não altera a aparência.
- Ilha alvo até 1000×1000 SQMs, gerada por seed e carregada em chunks; save do mundo local ao host, personagem na conta.
- Escolha inicial: Firebase Spark para identidade/progressão, condicionada a protótipo de integração no Godot; LAN deve funcionar sem internet.
- Curva XP +30% por nível. 3 pontos de árvore na criação e 3 a cada subida até 50 (150 no total); 1 ponto de atributo por subida. Cap inicial nível 10.
- Números de dano, recursos, XP por atividade e construção são hipóteses para playtest.

Validar antes de consolidar integração: fluxo Firebase Auth offline/online em Godot Android; descoberta LAN e permissões em dispositivos alvo; performance por chunk; importação de sprite; comportamento quando host perde o save ou desinstala o app.

## Decisão — protótipos por fase antes de implementar

- Antes de codificar cada fase do MVP, produzir um protótipo visual/navegável das telas, estados e transições afetados e apresentá-lo ao usuário para validação explícita. Aplicar o gate também a mudanças materiais posteriores e a lotes de arte: primeiro um exemplar técnico, depois revisão e só então expansão.
- Manter o protótipo e o registro de feedback no repositório; correções de UX devem atualizar a versão do protótipo antes de alterar a implementação. Sem validação, não iniciar o código dependente.
- O protótipo não é especificação final, gameplay, arte de produção nem evidência de funcionamento no Android. A validação Godot/aparelho continua obrigatória por fase.
- O protótipo navegável `docs/prototypes/mvp_ui_v0_4.html` é a versão atual para revisão; versões anteriores permanecem arquivadas. A tela de personagem inclui quatro aparências; a aprovação do protótipo de interface continua pendente.
- Descrições atuais para Melissa e Helena omitem idade: Melissa é meiga, doce, esperta e observadora, mantém calma e clareza; Helena é carismática e inteligente, tem pavio curto e reage com intensidade. O inventário RPG com slots de equipamento continua proposto na interface v0.3; conjunto de slots e novos itens aguardam validação antes de entrar no catálogo de produção.

## Incremento de personagem — Maíra

- O usuário aprovou Maíra como personagem jogável do MVP e aprovou o conceito nas três vocações. Maíra é irmã de Helena; identidade visual aprovada: cabelo longo castanho-escuro e traje amarelo/dourado. Descrição de catálogo: bonita, carismática e muito falante; atenciosa com os outros, anima o grupo e observa o ambiente antes de agir.
- O teste técnico inicial está limitado a Maíra Warrior, norte/sul, `idle` e `walk`. A arte continua **corrigir** e não libera o lote completo; a revisão do teste é o próximo gate.

## Incremento de arte — teste Melissa Warrior

- Atendendo ao lote de sprites solicitado, criar primeiro ferramenta técnica de QA na raiz (`project.godot`) com cena em `tools/art/sprite_test/`. Desvio deliberado da futura pasta `game/`: a raiz permite referenciar/exportar `assets/` sem duplicar imagens nem usar caminhos absolutos externos ao projeto. Não move nem implementa o jogo planejado.
- Fixar **Godot 4.5.1 stable** para reproduzir este teste; atualização futura exige repetir importação. Não afirmar que esta é a versão estável mais recente.
- Etapa 1 usa só duas linhas N/S e metadados explícitos; a expansão futura exige oito linhas na ordem contratual. 96×96 e pivô48,80 continuam candidatos até aprovação visual/Android. Sem aprovação, nenhuma variante, monstro ou VFX é produzido.

## Incremento de personagem — Fábio

- Em 2026-10-15, o usuário aprovou Fábio como quarto personagem jogável do MVP. Ele é pai de Melissa e pode escolher Warrior, Archer ou Mage; qualquer conta pode usar qualquer aparência.
- O concept das três vocações permanece referência visual aprovada, não sprite/atlas. Identidade: pele morena, cabelo curto escuro com fios grisalhos nas têmporas, barba aparada, trajes de Warrior vermelho/dourado, Archer verde e Mage azul. Descrição: “Fábio é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, prefere observar, analisar os riscos e planejar a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes.”
- GDD e catálogos do MVP agora registram quatro personagens. O protótipo de interface v0.4 inclui Fábio e aguarda validação explícita antes de qualquer implementação da tela de seleção.
- O teste técnico Fábio Warrior etapa 1 contém somente N/S, `idle` 4 e `walk` 6; permanece em **corrigir** e não aprova a arte nem libera expansão.


## Árvore passiva candidata — v0.5

- O usuário orientou uma rede inspirada em árvore passiva, com três atores e conexões direcionais/bidirecionais; para os seis nós retangulares, pediu quadrados ou círculos maiores. A v0.5 representa 25 passivas pequenas como círculos, 6 grandes como quadrados e as três origens de vocação como losangos com atores e rótulo “Actor”.
- A rede tem 61 ligações bidirecionais; cada origem alcança os 34 nós. Nós exibem somente o símbolo no grafo; nome, efeito, tipo e custo aparecem no painel após seleção. O protótipo simula desbloqueios adjacentes, sem salvamento.
- Essa composição, nomes, efeitos e custos são **candidatos aguardando validação**. O plano canônico permanece 100 nós por vocação e a lista de produção permanece sem IDs aprovadas até o usuário revisar a v0.5.


## Referência visual da árvore — protótipo v0.6

- O usuário escolheu a imagem endgame anexada como referência visual oficial do protótipo: `docs/prototypes/assets/passive_skill_tree_endgame_reference.png`.
- A árvore é exibida diretamente no protótipo v0.6; nós são inspecionáveis pelo seletor lateral. A origem da vocação inicia desbloqueada; demais nós são desbloqueados automaticamente por nível na simulação.
- Os marcos 2/4/6/8/10 para cinco gerações são provisórios para demonstração. A imagem conceitual não deve ser tomada como exportação exata da topologia, nem aprova a tela para produção.
- O candidato de 34 nós da v0.5 permanece arquivado para comparação. O plano de conteúdo de 100 nós por vocação não foi alterado.


## Inventário e distribuição de atributos — protótipo v0.7

- O usuário definiu a tela em três colunas: equipamento à esquerda na matriz 4×3; mochila ao centro; painel direito de atributos e, quando um item é selecionado, seus detalhes e ações.
- A demonstração começa no nível 4 com 3 pontos disponíveis (um por nível ganho desde o nível 2). FOR/AGI/INT brutos começam em zero; a eficácia de cada ponto segue os multiplicadores existentes do GDD.
- HP/MP base continuam vinculados à vocação (Warrior 200/100, Archer 150/150, Mage 100/200). Com +3 HP por FOR efetiva e +3 MP por INT efetiva, representar todo o HP/MP inicial apenas com atributos exigiria aproximadamente 100 pontos Warrior, 117 Archer e 100 Mage. Esses pontos não são alocados na criação.
- v0.7 é uma simulação sem salvamento. A revisão do protótipo não aprova implementação de produção.


## Incremento técnico — primeira fatia jogável (2026-10-15)

- O usuário validou explicitamente o protótipo navegável v0.7 em 2026-10-15. Esta implementação segue seu fluxo inicial: abertura, seleção de aparência/vocação, etapa “Criar/entrar na ilha”, gameplay e pausa. A validação foi do protótipo; telas reais ainda exigem importação Godot e revisão visual.
- A fatia foi desenvolvida em worktree isolada baseada em `feature/fabio-warrior-stage1` no commit local `16e7593` e integrada localmente nessa branch nos commits `b1c66a5` (implementação) e `b8339e6` (checkpoint documental). `main` não foi alterada e não houve push. `project.godot` aponta para a demo e preserva `tools/art/sprite_test/` como harness QA separado.
- A seleção limita-se à vocação Warrior porque as quatro aparências têm apenas atlas candidatos Warrior com `idle` e `walk` disponíveis. O mapa usa primeira composição estática 64×44 e os 56 IDs completos do atlas candidato; não inicia o sistema de chunks/seed do mundo final.
- Joystick touch e botão touch de pausa estão implementados em código junto aos controles desktop. LAN/conta/save, combate, inventário/progressão e persistência não existem; “Hospedar solo” é local e “Entrar” mostra erro mockado e recuperável. O alvo do cristal e props de cenário são proxies geométricos demonstrativos.
- Os PNGs de personagens permanecem byte a byte sem mudança; a implementação lê pivô, grade, direção e FPS das metadata e não promove `corrigir`/`CANDIDATO`. Sem Godot/Android no runner, S0/S1 permanecem incompletos; a verificação em aparelho Android (10 min, paisagem, dois tamanhos, zoom 50–125%) é obrigatória antes do aceite.

## Recorte solo distribuível para teste — 2026-10-16

- O usuário pediu continuidade com APK/Web testáveis e delegação das sprites da raposa, lobo e urso. Cinco frentes isoladas, GPT-6 Luna com esforço máximo, produziram criaturas, gameplay e export Android; a integração permaneceu em `feature/fabio-warrior-stage1`.
- A implementação avança o loop solo da interface v0.7 já validada. É um recorte técnico S2; os gates de aparelho de S0/S1 permanecem abertos. O aceite integral do GDD continua exigindo três vocações, LAN em dois Androids e o restante do conteúdo.
- O catálogo provisório é usado como fonte dos valores para playtest: HP/MP, XP, drops, receitas, custos e skills. Quantidade por nó, cadência de ataques/IA e respawn de criatura em 90 s fora da visão são provisórios; o mapa continua estático 64×44.
- O save desta fatia separa progresso por aparência Warrior no dispositivo, schema 1. Isso não substitui o futuro modelo host/mundo/conta. A gravação verifica o temporário antes de rotacionar dois slots; snapshots inválidos são preservados para diagnóstico.
- As três criaturas têm somente uma pose SE para teste. Alpha intermediário e direções/animações finais bloqueiam aprovação artística; nenhum asset foi promovido a produção. Os atlas existentes dos quatro jogadores e os 56 tiles foram preservados.
- Web é exportado com um ZIP portátil e servidor localhost; Android é um APK debug assinado localmente, ARMv7/ARM64, paisagem e sem permissões. SDK, Godot, chaves, builds e saves não entram no Git. Testes de pacote/assinatura/headless não substituem execução gráfica ou aparelho.

## 2026-10-16 — Retrato e HUD de combate

A solicitação explícita do usuário substitui a orientação horizontal anterior: base 720×1280 (9:16), retrato Android, stretch expand e mundo até as bordas em outras proporções. O anexo `1001362477.jpg` é o protótipo escolhido para implementar a hierarquia: retrato e HP/MP/EXP no topo esquerdo, alvo/HP no topo direito, navegação compacta, joystick esquerdo e ações circulares à direita. Não adiciona goblins, dungeon, ouro ou habilidades fora do catálogo. Preservados os sprites candidatos e o mundo da ilha.

Seleção usa elipse no corpo visível, mínimo de 36 pixels lógicos por raio corrigido pelo zoom, escolhe o centro normalizado mais próximo em sobreposição e preserva o alvo em toque no chão. Trocar alvo percorre monstros visíveis ordenados por distância ao jogador. Número flutuante usa HP efetivamente removido, inclusive bleed/skills e golpe fatal; amarelo para causado, vermelho para recebido.
