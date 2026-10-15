# Registro de protótipos e validações

Esta lista registra a aprovação por fase. **Nenhuma tela de produção está aprovada nesta versão.** O protótipo mostra composição e transições ilustrativas, sem gameplay, contas, rede ou save real.

## Telas do MVP — v0.4 (atual)

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

**Estado geral:** v0.1–v0.3 permanecem arquivadas; v0.4 é a versão atual e aguarda validação explícita.
**Sprites:** placeholders geométricos; não representam sprites aprovados.

| Fase | Telas/estados cobertos | Estado | Próximo passo |
|---|---|---|---|
| S0 | Abertura, entrada de visitante, conta/vínculo, configuração inicial | em validação | Validar ordem de entrada, texto e opção offline |
| S1 | Gameplay, joystick, hotbar, minimapa, HP/MP, interação e zoom | em validação | Validar posição/quantidade dos controles e densidade do HUD |
| S2 | Equipamento + mochila/crafting, acampamento, pausa/save e resultado da expedição | em validação | Validar conjunto de slots de equipamento e hierarquia do inventário |
| S3 | Escolha de personagem/vocação, árvore, habilidades, criaturas e acampamento | em validação | Validar seleção e hierarquia de progressão |
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

## Registro futuro por fase

Ao atualizar uma fase, preserve versões anteriores e acrescente a aprovação e o link para a versão validada. Após implementar, anote comparação visual, testes e dispositivo sem alterar retroativamente o resultado da revisão do protótipo.
