# A Ilha do Cristal

RPG 2D cooperativo de sobrevivência em pixel art. Melissa, Helena, Maíra e Fábio sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado:** recorte solo para teste, em Godot 4.5.1, com exportadores Web e APK Android debug. Importação, fluxo e regras são verificados em modo headless; revisão gráfica no navegador e instalação/teste em Android continuam pendentes. **Arte:** personagens e criaturas seguem **CORRIGIR**, terreno **CANDIDATO**. A [prancha conceitual](assets/references/concept-rpg-classico.png) é referência visual.

A cena principal é `game/scenes/main.tscn`. O fluxo percorre início → uma das quatro aparências Warrior → sessão solo → ilha 64×44, com movimento, coleta, raposa/lobo/urso, ataque automático ao alcance, três habilidades Warrior, curativo, XP, inventário de materiais e melhorias de acampamento. O save local separa as quatro aparências e usa slots com checksum e recuperação. Consulte [guia do teste solo](docs/gameplay/MVP_SOLO_TEST.md) e [validação das builds](docs/gameplay/MVP_BUILD_VALIDATION.md). Contas, LAN, Archer/Mage, árvore completa e mundo procedural continuam pendentes; esta entrega não fecha o aceite integral do GDD.

## Testar e exportar

- **Web:** extraia `build/ilha-do-cristal-web.zip` e execute `Testar_Jogo_Web.bat` no Windows, com Python 3 instalado. O ZIP inclui o servidor; não depende do checkout. Em outro sistema, rode `python3 -m http.server 8000` na pasta extraída e abra `http://localhost:8000/`.
- **Android:** instale `build/android/ilha-do-cristal-debug.apk`. É um APK de desenvolvimento para ARMv7/ARM64, Android 7 ou superior, em paisagem; a assinatura debug não é assinatura de publicação.
- **Controles:** WASD/setas ou joystick; clique/toque na criatura para selecionar; E interage/coleta; 1/2/3 usam skills; H usa curativo; B abre mochila; Esc/P pausa. Os botões da tela oferecem as ações touch. Zoom 50–125%.

Com Godot 4.5.1 e os templates correspondentes instalados:

```sh
python3 tools/build/export_web.py
python3 tools/build/export_android.py
```

O guia [ANDROID_BUILD.md](docs/technical/ANDROID_BUILD.md) fixa SDK/JDK, configuração e verificações. Binário Godot local, SDK, chaves debug, saves e `build/` ficam fora do Git.

## Documentação

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

## Correção de teste: retrato 0.1.1

A versão de teste mais recente usa **retrato 9:16**, mundo em tela inteira com expansão para outras proporções, HUD inspirado no protótipo enviado, alvo destacado/trocável e dano numérico flutuante. A seleção de aparência usa grade 2×2 e os painéis cabem no retrato.

Builds: `python3 tools/build/export_android.py` e `python3 tools/build/export_web.py` com Godot 4.5.1. O Web solicita tela cheia ao entrar como visitante, conforme suporte do navegador; o canvas preenche o viewport mesmo sem permissão. APK debug 0.1.1/versionCode 2. Instalação em aparelho ainda requer playtest. Detalhes e verificações: [validação retrato](docs/gameplay/PORTRAIT_BUILD_VALIDATION.md).
