# A Ilha do Cristal

RPG de sobrevivência em pixel art. Melissa, Helena, Maíra e Fábio sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado:** recorte solo de teste em Godot 4.5.1. O código atual inclui queda/reanimação solo, contato corpo a corpo calculado pela projeção dos footprints visuais, movimento relativo à câmera, regeneração fora de combate a 1,2× e uma wiki local. A exportação Web foi feita a partir de `main`; a revisão gráfica no navegador continua pendente. O APK 0.1.7 é histórico e não foi recompilado com as mudanças das PRs #15–#18. Uma nova exportação Android está bloqueada neste ambiente pela ausência do SDK Platform 35 e do Build Tools 35.0.0; a instalação e o teste em aparelho também continuam pendentes. **Arte:** personagens e criaturas seguem **CORRIGIR**, terreno **CANDIDATO**. A [prancha conceitual](assets/references/concept-rpg-classico.png) é referência visual.

A cena principal é `game/scenes/main.tscn`. O fluxo percorre início → uma das quatro aparências Warrior → sessão solo → ilha 192×132, com movimento, coleta, raposa/lobo/urso, ataque automático ao alcance, três habilidades Warrior, curativo, XP, inventário de materiais e melhorias de acampamento. O save local separa as quatro aparências e usa slots com checksum e recuperação. Contas, LAN, Archer/Mage, árvore completa e mundo procedural continuam pendentes; o recorte não fecha o aceite integral do GDD. Consulte o [guia do teste solo](docs/gameplay/MVP_SOLO_TEST.md) e a [validação das builds](docs/gameplay/MVP_BUILD_VALIDATION.md).

## Jogar e exportar

- **Web:** a exportação registrada foi feita a partir de `main`. Para gerar novamente, use `python3 tools/build/export_web.py` com Godot 4.5.1 e os templates correspondentes. Extraia `build/ilha-do-cristal-web.zip` e execute `Testar_Jogo_Web.bat` no Windows com Python 3; em outro sistema, rode `python3 -m http.server 8000` na pasta extraída e abra `http://localhost:8000/`. A revisão gráfica no navegador ainda está pendente.
- **Android:** o APK debug 0.1.7/versionCode 8 é uma build anterior, documentada abaixo. Ela não representa o código após as PRs #15–#18. A nova exportação depende do Android SDK Platform 35 e do Build Tools 35.0.0, ausentes neste ambiente; ainda não há APK atual para testar em aparelho. O launcher usa o ícone pixel art do cristal e o nome **A Ilha do Cristal**; builds debug não são para publicação.
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
- [Metodologia de prototipagem](Docs/Main/PROTOTYPING_METHODOLOGY.md) — protótipo e validação antes de cada fase.
- [Registro de protótipos](Docs/Context/PROTOTYPE_LOG.md) e [protótipo navegável v0.7](docs/prototypes/mvp_ui_v0_7.html). A v0.7 foi validada como interface simulada em 2026-10-15; isso não valida gameplay, arte ou dispositivos. A referência conceitual da árvore está em [passive_skill_tree_endgame_reference.png](docs/prototypes/assets/passive_skill_tree_endgame_reference.png).
- [Handoff](Docs/Context/HANDOFF.md) e [Journal](Docs/Context/JOURNAL.md) — continuidade entre sessões.
- [Arquitetura](docs/technical/ARCHITECTURE.md) e [arte/sprites](docs/art/ART_DIRECTION_AND_SPRITES.md).
- [AGENTS.md](AGENTS.md) — regras de implementação e revisão.

Estrutura: `game/` (cenas, scripts e dados), `data/` (catálogo versionado), `assets/` (arte candidata e referências), `Docs/Main/` (referência durável), `Docs/Context/` (journal/handoff), `docs/art/` e `docs/technical/`. O harness técnico de sprites permanece em `tools/art/sprite_test/sprite_test.tscn`. Relatórios de criaturas e [prancha nativa/nearest](docs/art/evidence/creatures-contact-candidates.png) documentam uma pose SE estática por animal; direções, animações e alpha final não estão aprovados.

Não publicar fotos originais das crianças, credenciais, keystores ou saves pessoais. A prancha conceitual não substitui sprites de produção.

## Histórico visual e de build 0.1.7

A build Android debug 0.1.7/versionCode 8 é anterior às PRs #15–#19 e **não foi recompilada com as mudanças posteriores**. Ela registra o joystick ampliado, janela de atributos, restauração de HP/MP ao subir de nível, mapa 192×132 e ajustes de interface/profundidade. As mudanças de gameplay posteriores — janela de queda e retorno, contato por footprint, movimento alinhado à câmera e regeneração de 1,2× — não estão confirmadas nesse APK. A PR #19 integrou a wiki à documentação; ela não faz parte do pacote Android.

O histórico da composição retrato, alvo e dano flutuante está em [validação retrato](docs/gameplay/PORTRAIT_BUILD_VALIDATION.md); a interface 0.1.7 está em [MOBILE_UI_017_VALIDATION.md](docs/gameplay/MOBILE_UI_017_VALIDATION.md). O APK anterior pode não estar presente num checkout, pois `build/` não é versionado. Não trate esse binário como build atual nem como evidência para os recursos integrados depois.
