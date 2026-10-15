# Decisões — 2026-10-14

- Nome **A Ilha do Cristal**; naufrágio de cruzeiro; estética **RPG Clássico 2D pixel art**. Vael perde a humanidade ao buscar poder e causa mutações; castelo e exército são expansão futura.
- Mobile-first Android, paisagem, joystick virtual esquerdo, ações e magias à direita, toque em objetos, zoom padrão 75% e faixa 50–125% sujeita a teste.
- Qualquer conta cria Melissa, Helena ou Maíra em qualquer vocação; vocação permanente por personagem. Equipamento não altera a aparência.
- Ilha alvo até 1000×1000 SQMs, gerada por seed e carregada em chunks; save do mundo local ao host, personagem na conta.
- Escolha inicial: Firebase Spark para identidade/progressão, condicionada a protótipo de integração no Godot; LAN deve funcionar sem internet.
- Curva XP +30% por nível. 3 pontos de árvore na criação e 3 a cada subida até 50 (150 no total); 1 ponto de atributo por subida. Cap inicial nível 10.
- Números de dano, recursos, XP por atividade e construção são hipóteses para playtest.

Validar antes de consolidar integração: fluxo Firebase Auth offline/online em Godot Android; descoberta LAN e permissões em dispositivos alvo; performance por chunk; importação de sprite; comportamento quando host perde o save ou desinstala o app.

## Decisão — protótipos por fase antes de implementar

- Antes de codificar cada fase do MVP, produzir um protótipo visual/navegável das telas, estados e transições afetados e apresentá-lo ao usuário para validação explícita. Aplicar o gate também a mudanças materiais posteriores e a lotes de arte: primeiro um exemplar técnico, depois revisão e só então expansão.
- Manter o protótipo e o registro de feedback no repositório; correções de UX devem atualizar a versão do protótipo antes de alterar a implementação. Sem validação, não iniciar o código dependente.
- O protótipo não é especificação final, gameplay, arte de produção nem evidência de funcionamento no Android. A validação Godot/aparelho continua obrigatória por fase.
- O protótipo navegável `docs/prototypes/mvp_ui_v0_3.html` é a versão atual para revisão; v0.1 e v0.2 permanecem arquivadas. A tela de personagem agora inclui Maíra; a aprovação do protótipo de interface continua pendente.
- Descrições atuais para Melissa e Helena omitem idade: Melissa é meiga, doce, esperta e observadora, mantém calma e clareza; Helena é carismática e inteligente, tem pavio curto e reage com intensidade. O inventário RPG com slots de equipamento continua proposto na interface v0.3; conjunto de slots e novos itens aguardam validação antes de entrar no catálogo de produção.

## Incremento de personagem — Maíra

- O usuário aprovou Maíra como personagem jogável do MVP e aprovou o conceito nas três vocações. Maíra é irmã de Helena; identidade visual aprovada: cabelo longo castanho-escuro e traje amarelo/dourado. Descrição de catálogo: bonita, carismática e muito falante; atenciosa com os outros, anima o grupo e observa o ambiente antes de agir.
- O teste técnico inicial está limitado a Maíra Warrior, norte/sul, `idle` e `walk`. A arte continua **corrigir** e não libera o lote completo; a revisão do teste é o próximo gate.

## Incremento de arte — teste Melissa Warrior

- Atendendo ao lote de sprites solicitado, criar primeiro ferramenta técnica de QA na raiz (`project.godot`) com cena em `tools/art/sprite_test/`. Desvio deliberado da futura pasta `game/`: a raiz permite referenciar/exportar `assets/` sem duplicar imagens nem usar caminhos absolutos externos ao projeto. Não move nem implementa o jogo planejado.
- Fixar **Godot 4.5.1 stable** para reproduzir este teste; atualização futura exige repetir importação. Não afirmar que esta é a versão estável mais recente.
- Etapa 1 usa só duas linhas N/S e metadados explícitos; a expansão futura exige oito linhas na ordem contratual. 96×96 e pivô48,80 continuam candidatos até aprovação visual/Android. Sem aprovação, nenhuma variante, monstro ou VFX é produzido.

## Concept de personagem — Fábio (pendente de elenco)

- O conceito gerado de Fábio nas três vocações foi aprovado como referência visual, não como sprite/atlas. Descrição aprovada para o concept: “Fábio é alto e forte, tem presença serena e olhar atento. Inteligente e reservado, prefere observar, analisar os riscos e planejar a estratégia antes de agir. Melissa parece ter herdado dele a calma e a atenção aos detalhes.”
- GDD e catálogo do MVP registram Melissa, Helena e Maíra; não foi encontrada decisão clara de incluir Fábio como personagem jogável. Mantê-lo como concept e inclusão pendente, sem alterar o elenco documentado.
- O teste técnico Fábio Warrior etapa 1 contém apenas N/S, `idle` 4 e `walk` 6; continua em **corrigir** e não aprova a arte nem libera expansão.
