# Roadmap mobile-first

Sem datas arbitrárias. Cada etapa fecha com demonstração no aparelho e critérios verificáveis. Trabalho em PRs pequenos por sprint; a fase seguinte começa após validação da anterior. A ordem vem do processo mecânica → escala/visão → arte técnica → loop → persistência → rede → nuvem. GDD e catálogo permanecem em `Docs/Main/`; Journal e Handoff em `Docs/Context/` registram continuidade.

**Gate transversal obrigatório:** antes da implementação de cada sprint, prototipar as telas, estados e transições que serão afetados e obter validação explícita do usuário. Correções voltam ao protótipo antes de virar código. A metodologia completa está em [PROTOTYPING_METHODOLOGY.md](PROTOTYPING_METHODOLOGY.md); versões, comentários e decisões ficam em [PROTOTYPE_LOG.md](../Context/PROTOTYPE_LOG.md). O protótipo navegável atual está em [`docs/prototypes/mvp_ui_v0_7.html`](../../docs/prototypes/mvp_ui_v0_7.html). A v0.7 acrescenta inventário, distribuição de atributos e inspeção de itens; o usuário validou esse protótipo em 2026-10-15. O aceite é somente da interface simulada, não valida implementação, gameplay, arte, Godot ou Android.

| Fase | Prototipar antes do código |
|---|---|
| S0 | Abertura, orientação horizontal, áreas seguras, entrada visitante e configuração inicial |
| S1 | HUD, joystick, botões, câmera, zoom e interação em SQMs |
| S2 | Fluxo coleta → combate → cura → craft/refúgio → pausa/salvamento |
| S3 | Aparência/vocação, habilidades, árvore parcial, biomas, criaturas e acampamento I–III |
| S4 | Criar/entrar em sessão LAN, conexão perdida, aliado caído e reanimação |
| S5 | Visitante, vínculo de conta, operação offline, sincronização e divergência de progresso |
| S6 | Tutorial, acessibilidade, áudio, feedback, erros recuperáveis e ajustes finais de UX |

Prototipagem atual: **UI navegável v0.7 validada como protótipo em 2026-10-15; árvore endgame segue como imagem conceitual com regras de nível ilustrativas**. O aceite do protótipo não conclui nenhuma fase técnica nem valida UI de produção.

| Sprint | Entrega | Aceite |
|---|---|---|
| S0 — Preparação | Fixar versão Godot 4, projeto importável, preset Android, orientação horizontal, tela base e CI leve de importação/export debug; criar script opcional Pillow para asset geométrico de teste | Projeto abre sem erros e APK inicial instala em aparelho |
| S1 — Movimento | Tilemap pequeno, câmera 50–125%, joystick 8 direções, colisão, toque em objeto | Jogar em paisagem por 10 min sem travar; botões legíveis em dois tamanhos de tela |
| S2 — Loop vertical | Melissa, uma vocação, raposa, madeira/erva, ataque, drop, curativo, fogueira/baú | Coletar → enfrentar → curar → retornar → salvar/reabrir no Android |
| S3 — Mundo e conteúdo | Seed/chunks, praia/floresta/interior, Helena, Maíra e Fábio, três vocações/nove skills, raposa/lobo/urso, crafting, acampamento I–III, XP/árvore parcial | Meta do MVP concluída solo, progressão e construção persistem |
| S4 — LAN | Host autoritativo, entrada por IP/código local ou descoberta testada, sincronização de combate/itens, reanimação | Dois Androids na mesma rede sem duplicar drops; desconexão salva mundo |
| S5 — Contas | Prova Firebase Auth, vínculo de visitante, progressão na nuvem, fila offline e resolução de conflitos | Troca de aparelho recupera personagem; mundo continua no host; internet ausente não bloqueia LAN |
| S6 — Beta | UX, acessibilidade, áudio, otimização, save interrompido, tutorial, correção e build distribuível | Bateria de testes em aparelhos reais e sessão 30 min sem perda de progresso |
| S7 — Atualizações de conteúdo | Verificação na inicialização, release versionado no GitHub, download de PCK e recuperação/offline | Atualização real aplicada no Android, hash validado e save preservado; APK permanece separado |

Gate de cada PR: objetivo e antes/depois, teste específico, nenhum arquivo privado, importação Godot, evidência APK quando aplicável. Documentar resultado de FPS/memória sem prometer valor antes de medir. Conteúdo além do nível 10, NPCs coletores, outros monstros, castelo/Vael jogável e desktop ficam para atualizações posteriores.

Checklist vivo:

- [x] GDD minimalista, balanceamento inicial, arquitetura e arte conceitual.
- [x] Pastas `Docs/Main/` e `Docs/Context/`, Journal, Handoff e regras `AGENTS.md`.
- [ ] S0: Godot importável, orientação e APK Android instalado.
- [ ] S1: movimento, escala e câmera em aparelhos reais.
- [ ] S2: loop vertical coleta → combate → curativo → save.
- [ ] S3: conteúdo, geração em chunks, progressão e meta solo.
- [ ] S4: LAN entre dois Androids.
- [ ] S5: conta/progressão e modo visitante/offline.
- [ ] S6: beta e testes de resiliência.
- [x] S7 técnico parcial: tela inicial verifica Releases `content-v*`, apresenta atualização, baixa PCK, compara tamanho/SHA-256, monta o pacote e recarrega o jogo; testes de parser e montagem local passam.
- [ ] S7 restante: publicar release real, exportar APK 0.1.10, testar rede/offline e preservação de save em Android físico. Não há release de conteúdo criada por esta tarefa.

#### Subitens da primeira fatia em `feature/fabio-warrior-stage1`

Os itens marcados como implementados descrevem validação técnica desktop/headless, não aceite visual ou de plataforma. **S0 e S1 continuam pendentes** até comparação visual e gates de aparelho desta tabela.

- [x] S0 parcial: `project.godot` inicia uma cena de jogo (`game/scenes/main.tscn`), mantém viewport horizontal 1280×720, stretch `canvas_items` e renderer Compatibility; o harness de sprites foi preservado em `tools/art/sprite_test/`.
- [x] S0 técnico desktop: importação do projeto e execução da cena principal em Godot 4.5.1 Linux headless; smoke test automatizado cobre cenas, atlas, mapa e movimento. A pasta de fontes de referência truncadas da Maíra é explicitamente excluída do import Godot; ela não é dependência de runtime.
- [x] Ferramenta de teste Web: preset e exportador usam Godot 4.7.2; o launcher valida `--version`, prioriza executáveis locais válidos da raiz e ignora arquivos inválidos/versões diferentes antes de procurar o caminho salvo, `GODOT_BIN`, locais comuns ou abrir a seleção do `.exe`. Binários Godot ficam locais e fora do Git. A exportação com templates 4.7.2 e a execução visual ainda precisam de revisão no Windows.
- [x] S0 export: preset Android Debug, SDK/JDK/templates e scripts de export Web/APK; APK com assinatura debug e manifesto validados.
- [ ] S0 restante: APK instalado e testado em aparelho.
- [x] S1 parcial: mapa inicial estático 64×44; tile atlas mantém 56 IDs (17 base, 24 transições, 15 overlays); jogador usa idle/walk das quatro aparências Warrior e movimentação em oito direções por teclado/joystick touch, alinhada aos eixos da câmera 2.5D; há colisão de água, bordas e proxies, câmera nearest com zoom 50–125% e interação demonstrativa com cristal.
- [x] Fluxo de tela validado em Godot headless: início → aparência/vocação → sessão local → gameplay; pause overlay permite retomar ou navegar à sessão/início. “Entrar” permanece erro mockado.
- [ ] S1 restante: revisão visual no editor e comparação com a v0.7; aceitar Android após 10 min em paisagem, dois tamanhos de tela, zoom 50–125%, revisão de legibilidade, toque, colisões, estabilidade e desempenho.

Após GDD, produzir em sequência: contratos JSON em `data/`, protótipo de controles, sprites técnicos com pivôs, teste de cache/chunks, save resiliente, rede LAN. O tamanho 1000×1000 é limite de mundo, não requisito de preencher toda área com conteúdo no primeiro APK.

#### Recorte solo S2 para teste — 2026-10-16

- [x] Código e testes headless: madeira/pedra/fibra/erva, receita de curativo, cura interrompível, seleção por clique/toque, ataque automático, três skills Warrior e raposa/lobo/urso com comportamentos distintos.
- [x] Estado local: XP 1–10, materiais, custos de acampamento II/III, queda/retorno solo com prévia exata da penalidade, mochilas persistentes, recompensa única por vida e snapshot schema 1 com checksum, temporário e slot anterior. Rotação normal mantém dois slots; testes cobrem revive local via API, timer, respawn e recuperação de mochila.

Reanimação por aliado usa API/sinais locais de cinco segundos para futura integração pelo host; não há sessão LAN nem jogadores remotos nesta build. Isso não fecha S4.
- [x] Três candidatos estáticos SE integrados sem espelhamento ou animação inventada. QA estrutural passou; **arte CORRIGIR**, com alpha e demais direções/animações pendentes.
- [ ] Aceite S2: demonstrar coleta → combate → curativo → retorno → fechar/reabrir no Android; comparar visualmente o HUD com v0.7 e revisar Web no navegador.

O recorte usa quatro aparências Warrior e mapa estático. Upgrades II/III persistem números/custos; baú compartilhado, poço, cerca e torres funcionais, Archer/Mage, árvore, chunks, LAN e conta seguem pendentes. Resultados e limitações: [guia solo](../../docs/gameplay/MVP_SOLO_TEST.md) e [validação das builds](../../docs/gameplay/MVP_BUILD_VALIDATION.md). As fases principais permanecem abertas até seus aceites completos.

#### Regeneração fora de combate — 2026-10-17

- [x] Taxas base e bônus de FOR/INT fora de combate multiplicados por 1,2 nas três vocações; rates em combate, tetos, clamp por máximo e pausa quando caído preservados. Teste de regras, painel de atributos, import Godot 4.5.1 e smoke do recorte solo passaram.
- [ ] Playtest Android físico para validar o ritmo de recuperação; esta correção não fecha S3.

### Correção retrato 9:16 — 2026-10-16

A solicitação atual substitui a orientação horizontal das descrições históricas acima.

- [x] HUD retrato conforme hierarquia do anexo do usuário; mundo expandido até as bordas, controles em safe area Android.
- [x] Menus e painéis de inventário/refúgio em retrato, alvo por toque no corpo, ciclo de alvos visíveis, anel/barra e números de dano com limpeza.
- [x] Regressões em três proporções, seleção em quatro zooms e render Godot Compatibility/Mesa.
- [ ] Aceite Android físico: instalação, notch/navegação, multitouch e estabilidade por 10 minutos.

### Ícone e layout touch 0.1.2 — 2026-10-16

- [x] Ícone de cristal para launcher clássico/adaptativo/monocromático e rótulo “A Ilha do Cristal”.
- [x] Safe rect Android aplicado como posição/tamanho válidos; regressão com recortes simulados em três proporções e toque no joystick.
- [x] APK debug 0.1.2/versionCode 3 exportado e manifesto/ícones/assinatura verificados.
- [ ] Instalar no aparelho do usuário e validar safe area, toque e multitouch reais.

A aprovação técnica desta correção não fecha os gates físicos de S0–S2.

### Revisão visual próxima candidata

- [x] Câmera próxima, HUD compacta, minimapa, alvo contextual e profundidade oblíqua em código.
- [x] Import/smoke e regressão de enquadramento em três proporções.
- [ ] Comparação visual da cena real com referência e revisão Android/WebGL.
- [ ] Reconciliar alterações anteriores não publicadas e conversão isométrica64×32.

### Correção visual 0.1.7

- [x] Inventário lado a lado, ícones originais, atributos em cartões e personagem ampliado conforme referências 3/4.
- [x] Pivô/profundidade corrigidos e câmera sem vazio nas bordas; minimapa completo com pontos vermelhos para monstros vivos.
- [x] Capturas reais Godot Compatibility/Mesa e testes de layout/fluxo/combate aprovados.
- [ ] Aceite no Android: instalar variante de teste, conferir HUD, notch, toque, save e 10 minutos de estabilidade.

### Wiki local de catalogação — 2026-10-17

- [x] Wiki HTML responsiva e sem dependências externas em `docs/wiki/`, com índice gerado a partir dos dados do projeto, previews clicáveis de PNGs, busca e links relativos aos arquivos.
- [x] Gerador, verificador e servidor Node.js local: `python3 tools/wiki/build_index.py`, `python3 tools/wiki/test_catalog.py` e `node tools/wiki/serve.js`; no Windows, `Acessar_Wiki.bat` abre a wiki sem dependências npm.
- [x] README aponta para a wiki e documenta a execução local; o servidor atende os links relativos e previews e bloqueia áreas geradas/privadas. Esta entrega é documentação/ferramenta de consulta; não altera o status de aceite das fases de jogo.


### Kit UI Crystal v2 — 2026-10-17

- [x] Incorporar o spritesheet de UI e aplicar molduras/controles nos fluxos de HUD, inventário/equipamento, refúgio/crafting, vocações/talentos, seleção e pausa.
- [x] Testes Godot 4.5.1 para recortes do atlas e fluxo integrado; ZIP Web validado e APK debug ARM64 armazenado em `artifacts/preview/` na branch. [Download do APK](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk); somente `arm64-v8a`.
- [ ] Revisão Web gráfica em navegador e teste Android físico (safe area, toque, save e estabilidade por 10 min). Esta entrega não conclui S0–S3 nem habilita vocações/talentos ausentes.

## Reconstrução persistida — 2026-10-18

- [x] HUD aprovada: equipamentos96×96, spells144×144, navegação exclusiva, engrenagem e inventário responsivo.
- [x] Minimap circular projetado pela câmera e zoom compartilhado, com teste geométrico.
- [x] Mapa fixo50mil tiles, três vocações locais/VFX e LAN de movimento reconstruídos e versionados.
- [x] Mapa visual persistido em `game/scenes/first_island.tscn`: 50.000 bases, 645 transições e 15 overlays, com TileSet compartilhado e sem repintura no início.
- [x] Atlas tropical fornecido importado em 64 slices e camadas vazias para pintura manual (`ManualTerrain`/`ManualProps`); aprovação visual e teste no editor continuam pendentes.
- [ ] Validar no Godot 4.5.1 edição, salvar/reabrir e renderização das camadas `BaseTiles`, `Transitions`, `Paths`, `ManualTerrain` e `ManualProps`; medir a cena com 50.000 células no Android.
- [x] Import, testes locais, comparação gráfica Godot e export/assinatura/integridade APK0.1.9.
- [ ] Sincronizar combate pelo host; depois itens/coleta e saves idempotentes do host.
- [ ] Testar o mesmo APK em dois Androids reais; validar UI/toque/safe area, LAN e persistência.
- [ ] Terrain Sets64×32/elevações e novas amostras de arte/atlas. Nenhum gate Android foi encerrado por testes headless.

### Proposta de mapa global/ilha irregular — aguardando validação

- [ ] Revisar o fluxo navegável em `docs/prototypes/global_map_island_v0_1.html`: toque no minimapa, mapa global, retorno sem pausar e zoom compartilhado.
- [ ] Revisar o conceito visual e a proposta de costa/biomas/elevações. A ilha atual já tem 250×200 = 50.000 tiles, porém com faixas de terreno planas; a nova arte não altera os dados de produção.
- [ ] Decidir se a amostra técnica seguinte conserva 32×32 em Camera3D ou testa 64×32 isoladamente, conforme o HTML de camadas anexado.
- [ ] Após validar a amostra visual, implementar dados irregulares e relevo no recorte de 50.000 tiles; não converter toda a malha sem teste de colisão, rampa, culling e performance.

### Proposta de bestiário de expansão — aguardando validação

- [ ] Revisar os dez candidatos e a prancha concept em `docs/art/candidates/BESTIARY_EXPANSION_CANDIDATES_V0_1.md`.
- [ ] Se a direção for aprovada, definir uma amostra de uma criatura, testar escala/pivô/alpha/legibilidade no Godot e pedir revisão antes de fazer sprites em lote.
- [ ] Manter espécies/variantes novas fora do MVP e do catálogo de runtime até aprovação e escopo explícitos.


### Identidade visual do aplicativo — 2026-10-18

- [x] Aplicar a logo enviada pelo usuário ao ícone clássico do app, ao foreground do ícone adaptativo e à splash/tela de verificação de atualizações.
- [x] Gerar variantes nos tamanhos Android exigidos e validar importação/teste de presença da logo no boot.
- [ ] Exportar a APK 0.1.10/versionCode 11 e conferir ícone, splash, safe area e escala em Android físico.

### Cenas herdadas de criatura — 2026-10-18

- [x] Criado prefab Godot 4 com `CharacterBody2D`, colisão corporal e áreas editáveis de detecção/ataque; raposa, lobo e urso herdam cenas próprias e mantêm os parâmetros de colisão atuais como padrão.
- [x] Spawns e respawns usam a cena da espécie. `creature_actor.gd` lê as formas salvas nas cenas sem recriar ou sobrescrever colisores em runtime; o teste de contato valida formas personalizadas.
- [ ] Abrir e editar cada cena no Godot 4.5.1, salvar/reabrir e revisar o encaixe visual da forma na respectiva sprite. Testes headless não substituem essa revisão manual.
