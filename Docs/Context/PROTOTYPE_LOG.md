# Registro de protótipos e validações

Esta lista registra a aprovação por fase. **Nenhuma tela de produção está aprovada nesta versão.** O protótipo mostra composição e transições ilustrativas, sem gameplay, contas, rede ou save real.

## Telas do MVP — v0.4 (arquivada para comparação)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_4.html`](../../docs/prototypes/mvp_ui_v0_4.html)

Fábio foi incluído como quarto personagem jogável após aprovação explícita do usuário. A tela acrescenta perfil e silhueta geométrica placeholder, preservando as três vocações selecionáveis. O protótipo aguarda validação; não representa sprite final e nenhuma tela de produção foi implementada.

**Ponto de validação desta versão:** confirmar se o perfil curto de Fábio e sua posição junto às outras três opções deixam clara a escolha de personagem.

## Telas do MVP — v0.3 (arquivada para comparação)

**Artefato desta versão:** [`docs/prototypes/mvp_ui_v0_3.html`](../../docs/prototypes/mvp_ui_v0_3.html)

**Versão anterior:** [`docs/prototypes/mvp_ui_v0_2.html`](../../docs/prototypes/mvp_ui_v0_2.html)

Maíra foi adicionada à escolha de personagem depois de o usuário aprová-la como jogável do MVP. A tela apresenta o terceiro perfil, sua descrição e um placeholder amarelo/dourado; ele não é arte final. As três vocações permanecem selecionáveis. Esta revisão da tela de personagem aguarda validação; nenhum fluxo de produção foi implementado.

## Telas do MVP — v0.2 (arquivada para comparação)

**Artefato desta versão:** [`docs/prototypes/mvp_ui_v0_2.html`](../../docs/prototypes/mvp_ui_v0_2.html)

**Versão anterior:** [`docs/prototypes/mvp_ui_v0_1.html`](../../docs/prototypes/mvp_ui_v0_1.html)

**Viewport-base:** Android em paisagem, proporção 16:9; layout adapta-se ao viewport.

**Estado geral:** v0.1–v0.6 permanecem arquivadas para comparação; v0.7 é a versão navegável atual e aguarda validação explícita.
**Sprites:** placeholders geométricos; não representam sprites aprovados.

| Fase | Telas/estados cobertos | Estado | Próximo passo |
|---|---|---|---|
| S0 | Abertura, entrada de visitante, conta/vínculo, configuração inicial | em validação | Validar ordem de entrada, texto e opção offline |
| S1 | Gameplay, joystick, hotbar, minimapa, HP/MP, interação e zoom | em validação | Validar posição/quantidade dos controles e densidade do HUD |
| S2 | Equipamento + mochila/crafting, acampamento, pausa/save e resultado da expedição | em validação | Revisar matriz de equipamento, 24 espaços de mochila, painel de atributos e detalhes contextuais dos itens na v0.7 |
| S3 | Escolha de personagem/vocação, árvore, habilidades, criaturas e acampamento | em validação | Revisar imagem endgame e progressão da árvore, além do inventário e painel de atributos da v0.7 |
| S4 | Criar/entrar em LAN, aliado caído/reanimação, erro de conexão | em validação | Validar estados de cooperação e recuperação |
| S5 | Visitante, vínculo, status offline e conflito de sincronização | em validação | Validar explicação de origem do progresso e escolha de recuperação |
| S6 | Configurações, áudio, zoom, contraste e erros recuperáveis | em validação | Validar opções visíveis e mensagens compreensíveis |

### Perguntas para a revisão v0.2

1. A ordem `abertura → visitante/conta → personagem/vocação → criar/entrar na ilha` está clara e correta?
2. No HUD paisagem, joystick à esquerda e ataque + três skills à direita deixam espaço suficiente para o mapa e para a mochila/interação?
3. Os slots propostos (cabeça, peitoral, luvas, pernas, botas, arma, colar e dois anéis) fazem sentido para o inventário? Quer adicionar/remover algum espaço, como escudo?
4. As novas descrições de Melissa e Helena representam bem as personalidades que você imaginou?

**Feedback recebido:** usuário pediu remover idade das descrições, desenvolver as personalidades e reformular o inventário com slots de RPG para armadura e acessórios.

**Correções aplicadas:** descrições atualizadas no GDD, catálogo JSON e seleção de personagem; inventário v0.2 agora separa equipamento, mochila, detalhes do item e fabricação. Armaduras e acessórios aparecem como slots vazios/conceituais porque ainda não têm itens ou atributos definidos no catálogo.
**Aprovação explícita:** pendente; nenhuma implementação de tela está liberada.


## Telas do MVP — v0.7 (atual)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_7.html`](../../docs/prototypes/mvp_ui_v0_7.html)  
**Referência visual escolhida:** [`passive_skill_tree_endgame_reference.png`](../../docs/prototypes/assets/passive_skill_tree_endgame_reference.png) · PNG RGBA 1672×941 · SHA-256 `51b511eec2f98714bca7a9379f7bc4b84ad78b7475d30d1952c951f1ab8d2e0e`.

A v0.7 preserva a árvore visual da v0.6 e acrescenta o inventário em três colunas: itens equipados à esquerda, mochila com 24 slots ao centro e painel contextual à direita. A matriz de equipamento é 4×3 conforme a orientação do usuário. O painel direito inicia em Atributos; a seleção de item abre descrição, localização/status, atributos e ação contextual. O exemplo está no nível 4, com 3 pontos livres; FOR/AGI/INT brutos começam em zero. HP/MP base permanecem próprios de cada vocação, enquanto o preview soma os bônus derivados dos atributos pelos multiplicadores do GDD. A simulação não salva progresso.

**Estado:** em revisão explícita. Esta versão demonstra composição e interações; não é implementação e nenhuma tela de produção foi aprovada. A imagem da árvore permanece conceitual, sem representar topologia exata.

## Telas do MVP — v0.6 (arquivada para comparação)

**Artefato:** [`docs/prototypes/mvp_ui_v0_6.html`](../../docs/prototypes/mvp_ui_v0_6.html)

## Telas do MVP — v0.5 (arquivada para comparação)

**Artefato atual:** [`docs/prototypes/mvp_ui_v0_5.html`](../../docs/prototypes/mvp_ui_v0_5.html)

Preserva a v0.4 e acrescenta uma árvore passiva navegável candidata: 25 círculos pequenos, 6 quadrados grandes, 3 origens em losango com um ator e a palavra “Actor” abaixo de cada uma. São 61 ligações bidirecionais entre Warrior (alto), Archer (esquerda) e Mage (direita). Selecionar um nó abre o painel de nome, efeito, tipo, custo e estado; desbloqueios adjacentes e pontos são simulados separadamente por vocação. A lista completa está em [CATALOGS_MVP.md](../Main/CATALOGS_MVP.md#9-talentos).

**Estado:** em validação explícita. A árvore e seus efeitos são candidatos de interface/conteúdo; o plano canônico de produção não foi substituído. Nenhuma UI de produção foi implementada.

### Perguntas para a revisão v0.5

1. A malha compartilhada e as origens Warrior no alto, Archer à esquerda e Mage à direita representam o fluxo que você imaginou?
2. A proporção de 25 círculos, 6 quadrados e 3 origens especiais está correta? O rótulo “Actor” e o painel lateral estão claros?
3. Os nomes, descrições e custos candidatos fazem sentido? O conjunto de 31 passivas custa 37 pontos, enquanto o nível 10 oferece 30; quer manter essa tensão de escolhas?


## Registro futuro por fase

Ao atualizar uma fase, preserve versões anteriores e acrescente a aprovação e o link para a versão validada. Após implementar, anote comparação visual, testes e dispositivo sem alterar retroativamente o resultado da revisão do protótipo.
