# A Ilha do Cristal

RPG de sobrevivência em pixel art. Melissa, Helena, Maíra e Fábio sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado atual:** reconstrução 0.1.9 em Godot 4.5.1, com HUD, minimapa, mapa fixo e prévia LAN de movimento. O boot Android prepara verificação de atualizações de conteúdo para o app 0.1.10/versionCode 11; a exportação desse APK ainda depende do Android SDK Platform 35 e Build Tools 35.0.0. Combate/itens/saves LAN e talentos passivos continuam pendentes. A arte de personagem ainda usa as aparências Warrior compartilhadas.

[Relatório e capturas da reconstrução](docs/gameplay/HUD_RECONSTRUCTION_019.md) · [Metadados do APK0.1.9](artifacts/preview/HUD-0.1.9.json) · [Próxima ação](Docs/Context/HANDOFF.md).

O APK0.1.9 foi entregue na conversa como anexo persistente. O APK0.1.7 em `artifacts/preview/` é histórico; seus links abaixo não apontam para a reconstrução atual. Não houve instalação em Android físico nesta sessão.

No Android, o boot consulta Releases `content-vX.Y.Z`, oferece o botão **Atualizar agora**, valida tamanho/SHA-256 do PCK e recarrega a cena de jogo. Saves ficam separados; mudanças de script/cena exigem APK. O repositório ainda não tem Releases públicos, então o primeiro app 0.1.10 mostrará conteúdo base 1.0.0 atualizado até a publicação do primeiro pacote real. A build Web pula a verificação. Consulte o [guia de atualização por GitHub](docs/technical/GITHUB_CONTENT_UPDATES.md) e o [protótipo aprovado](docs/prototypes/content_update_v0_1.html).

## Revisão visual em andamento — mapa global e bestiário

Os protótipos de mapa global/ilha irregular e a proposta de dez monstros continuam aguardando revisão explícita. A grade atual tem 50.000 tiles (250×200), faixas planas e nenhuma altura. A persistência em camadas editáveis mantém essa composição; ela não aprova nem implementa a proposta de ilha irregular. Consulte [`global_map_island_v0_1.html`](docs/prototypes/global_map_island_v0_1.html), [`BESTIARY_EXPANSION_CANDIDATES_V0_1.md`](docs/art/candidates/BESTIARY_EXPANSION_CANDIDATES_V0_1.md) e o [handoff](Docs/Context/HANDOFF.md).

## Editar o terreno no Godot

Abra `game/scenes/first_island.tscn` e edite as camadas `BaseTiles`, `Transitions` e `Paths`. A cena salva as 50.000 células base, 645 transições e 15 overlays usando o TileSet compartilhado `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.tres`. O jogo lê essas células para montar a apresentação 2.5D e não repinta o mapa ao iniciar.

Essas edições alteram a aparência do terreno. Limites, faixa de água bloqueada, colisões, spawns, obstáculos e recursos continuam definidos por `game/data/first_island_layout.json` e pelos scripts do jogo.

## Jogar e exportar

- **Web:** o ZIP de teste foi exportado desta branch com Godot 4.5.1. Para gerar novamente, use `python3 tools/build/export_web.py` com Godot 4.5.1 e os templates correspondentes. Extraia `build/ilha-do-cristal-web.zip` e execute `Testar_Jogo_Web.bat` no Windows com Python 3; em outro sistema, rode `python3 -m http.server 8000` na pasta extraída e abra `http://localhost:8000/`. A revisão gráfica no navegador ainda está pendente.
- **Android histórico 0.1.7:** [baixar APK antigo ARM64](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk) (0.1.7/versionCode 8; 39.337.295 bytes). O pacote é debug e contém somente `arm64-v8a`, então exige aparelho Android de 64 bits. Foi derivado da exportação Godot de preview removendo a biblioteca ARMv7 e assinando novamente; assinatura v2/v3, manifesto, recursos e integridade passaram. Ainda falta instalar e validar em aparelho físico. SHA-256: `9d723315cae0bfe5f4f68c88527484e618e61897ddcef0be0de8489c25b9e88a`. Builds debug não são para publicação.
- **Atualizador Android:** o preset desta branch é 0.1.10/versionCode 11 e solicita internet. A exportação depende do SDK Platform 35/Build Tools 35.0.0, ausentes neste ambiente. Não há APK 0.1.10 para instalar; validação real de rede, save e aparelho permanece pendente.
- **Controles:** WASD/setas ou joystick movem em oito direções relativas à câmera 2.5D. Clique/toque numa criatura para selecionar; E interage/coleta; 1/2/3 usam skills; H usa curativo; B abre mochila; Esc/P pausa. Os botões da tela oferecem ações touch. O zoom atual varia entre 150% e 300% (padrão 200%).

Ao cair, o jogador fica nessa condição por até 60 s. Pode renascer manualmente no acampamento ou retorna automaticamente quando o prazo termina. No renascimento, metade de cada pilha de materiais coletados na expedição, arredondada para baixo, vai para uma mochila persistente recuperável; XP e equipamentos permanecem. A reanimação em 5 s está exposta somente pelo contrato/API local da sessão: a build solo não tem LAN nem conexão com aliados.

Depois de 8 s sem atacar nem receber dano, HP e MP regeneram fora de combate a 1,2× das taxas base e dos bônus de FOR/INT. As taxas em combate não mudam; os tetos e o limite ao máximo continuam valendo.

O contato de combate corpo a corpo considera os footprints alpha projetados pela câmera, para manter a separação visual coerente com as colisões. Essa regra e o movimento relativo à câmera foram integrados após a build 0.1.7.

Para exportar Web e Android, instale Godot 4.5.1 e os templates correspondentes. A reprodução e os requisitos do Android estão em [ANDROID_BUILD.md](docs/technical/ANDROID_BUILD.md). Binário Godot local, SDK, chaves debug, saves e `build/` ficam fora do Git.

## Documentação

- [Wiki offline do projeto](docs/wiki/index.html) — consulta navegável de personagens, vocações, sprites/atlas, atributos, itens, habilidades, mundo e índice de arquivos. Para abrir sem rede externa, atualize com `python3 tools/wiki/build_index.py`, execute `python3 -m http.server 8000` na raiz e acesse `http://localhost:8000/docs/wiki/`. Valide com `python3 tools/wiki/test_catalog.py`.
- [GDD do MVP](Docs/Main/GDD_MVP.md) — regras e critérios de aceite.
- [Conteúdo e balanceamento](Docs/Main/CONTENT_DATA.md) — atributos, armas, XP, drops, bestiário e árvore.
- [Doze listas de produção](Docs/Main/CATALOGS_MVP.md) e [catálogo JSON](data/catalogs/mvp.json) — conteúdo inicial versionado.
- [Roadmap](Docs/Main/ROADMAP.md) — sprints e validações.
- [Atualizações de conteúdo pelo GitHub](docs/technical/GITHUB_CONTENT_UPDATES.md) — formato do Release, exportação do PCK e testes.
- [Protótipo de atualização v0.1](docs/prototypes/content_update_v0_1.html) — fluxo aprovado; usa dados simulados.
- [Metodologia de prototipagem](Docs/Main/PROTOTYPING_METHODOLOGY.md) — protótipo e validação antes de cada fase.
- [Registro de protótipos](Docs/Context/PROTOTYPE_LOG.md) e [protótipo navegável v0.7](docs/prototypes/mvp_ui_v0_7.html). A v0.7 foi validada como interface simulada em 2026-10-15; isso não valida gameplay, arte ou dispositivos. A referência conceitual da árvore está em [passive_skill_tree_endgame_reference.png](docs/prototypes/assets/passive_skill_tree_endgame_reference.png).
- [Handoff](Docs/Context/HANDOFF.md) e [Journal](Docs/Context/JOURNAL.md) — continuidade entre sessões.
- [Arquitetura](docs/technical/ARCHITECTURE.md) e [arte/sprites](docs/art/ART_DIRECTION_AND_SPRITES.md).
- [AGENTS.md](AGENTS.md) — regras de implementação e revisão.

Estrutura: `game/` (cenas, scripts e dados), `data/` (catálogo versionado), `assets/` (arte candidata e referências), `Docs/Main/` (referência durável), `Docs/Context/` (journal/handoff), `docs/art/` e `docs/technical/`. O harness técnico de sprites permanece em `tools/art/sprite_test/sprite_test.tscn`. Relatórios de criaturas e [prancha nativa/nearest](docs/art/evidence/creatures-contact-candidates.png) documentam uma pose SE estática por animal; direções, animações e alpha final não estão aprovados.

Não publicar fotos originais das crianças, credenciais, keystores ou saves pessoais. A prancha conceitual não substitui sprites de produção.

## Kit UI Crystal v2 — 2026-10-17

A branch `feature/s03-crystal-ui-kit-v2` integra o spritesheet `assets/ui/crystal_v2/sheet.b64` e componentes reutilizáveis nos fluxos principais. O catálogo de mochila usa 24 espaços; estados indisponíveis permanecem bloqueados/identificados como prévia. A UI reutiliza dados e ações existentes, sem simular vocações, talentos ou sistemas não implementados. Validações headless do kit/fluxo e importação Godot 4.5.1 passaram. [Baixar APK Android ARM64 de preview](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk) — debug, somente 64 bits, SHA-256 `9d723315cae0bfe5f4f68c88527484e618e61897ddcef0be0de8489c25b9e88a`. A verificação do pacote passou, mas ainda requer teste em aparelho. O Web foi empacotado, sem validação gráfica em navegador.

## Histórico visual e de build 0.1.7

A build Android debug 0.1.7/versionCode 8 é anterior às PRs #15–#19 e **não foi recompilada com as mudanças posteriores**. Ela registra o joystick ampliado, janela de atributos, restauração de HP/MP ao subir de nível, mapa 192×132 e ajustes de interface/profundidade. As mudanças de gameplay posteriores — janela de queda e retorno, contato por footprint, movimento alinhado à câmera e regeneração de 1,2× — não estão confirmadas nesse APK. A PR #19 integrou a wiki à documentação; ela não faz parte do pacote Android.

O histórico da composição retrato, alvo e dano flutuante está em [validação retrato](docs/gameplay/PORTRAIT_BUILD_VALIDATION.md); a interface 0.1.7 está em [MOBILE_UI_017_VALIDATION.md](docs/gameplay/MOBILE_UI_017_VALIDATION.md). O APK anterior pode não estar presente num checkout, pois `build/` não é versionado. Não trate esse binário como build atual nem como evidência para os recursos integrados depois.
