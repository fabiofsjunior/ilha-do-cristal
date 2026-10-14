# Registro de protótipos e validações

Esta lista registra a aprovação por fase. **Nenhuma tela de produção está aprovada nesta versão.** O protótipo mostra composição e transições ilustrativas, sem gameplay, contas, rede ou save real.

## Telas do MVP — v0.1

**Artefato:** [`docs/prototypes/mvp_ui_v0_1.html`](../../docs/prototypes/mvp_ui_v0_1.html)  
**Viewport-base:** Android em paisagem, proporção 16:9; layout adapta-se ao viewport.  
**Estado geral:** em validação com o usuário. Revisão ainda pendente.  
**Sprites:** placeholders geométricos; não representam sprites aprovados.

| Fase | Telas/estados cobertos | Estado | Próximo passo |
|---|---|---|---|
| S0 | Abertura, entrada de visitante, conta/vínculo, configuração inicial | em validação | Validar ordem de entrada, texto e opção offline |
| S1 | Gameplay, joystick, hotbar, minimapa, HP/MP, interação e zoom | em validação | Validar posição/quantidade dos controles e densidade do HUD |
| S2 | Mochila/crafting, acampamento, pausa/save e resultado da expedição | em validação | Validar navegação e prioridade das ações do loop |
| S3 | Escolha de personagem/vocação, árvore, habilidades, criaturas e acampamento | em validação | Validar seleção e hierarquia de progressão |
| S4 | Criar/entrar em LAN, aliado caído/reanimação, erro de conexão | em validação | Validar estados de cooperação e recuperação |
| S5 | Visitante, vínculo, status offline e conflito de sincronização | em validação | Validar explicação de origem do progresso e escolha de recuperação |
| S6 | Configurações, áudio, zoom, contraste e erros recuperáveis | em validação | Validar opções visíveis e mensagens compreensíveis |

### Perguntas para a revisão v0.1

1. A ordem `abertura → visitante/conta → personagem/vocação → criar/entrar na ilha` está clara e correta?
2. No HUD paisagem, joystick à esquerda e ataque + três skills à direita deixam espaço suficiente para o mapa e para a mochila/interação?
3. A hierarquia visual e as telas de mochila, talentos e acampamento estão no nível certo, ou alguma informação precisa ganhar prioridade?

**Feedback recebido:** pendente.  
**Correções solicitadas:** pendente.  
**Aprovação explícita:** pendente; nenhuma implementação de tela está liberada.

## Registro futuro por fase

Ao atualizar uma fase, preserve versões anteriores e acrescente a aprovação e o link para a versão validada. Após implementar, anote comparação visual, testes e dispositivo sem alterar retroativamente o resultado da revisão do protótipo.
