# A Ilha do Cristal

RPG 2D cooperativo de sobrevivência em pixel art. Melissa, Helena, Maíra e Fábio sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado:** primeira fatia jogável desktop testada em Godot 4.5.1 no modo headless (importação e smoke test de fluxo/gameplay). O pacote Web também foi exportado para `build/web/`; a revisão visual em navegador continua pendente. **Android:** build/aparelho não validados; plataforma-alvo continua Android em paisagem. **Arte:** atlas de personagens seguem **CORRIGIR** e terreno **CANDIDATO**, sem aprovação por esta entrega. [Prancha conceitual](assets/references/concept-rpg-classico.png) é referência, não sprite utilizável.

A cena principal configurada no `project.godot` é `game/scenes/main.tscn`. O fluxo percorre início → seleção de aparência Warrior → sessão local (host solo ou erro de entrada mockado) → mapa com movimento e pausa. A demo não implementa contas, LAN, saves, combate, progressão ou inventário funcional. O joystick touchscreen, controles de teclado, zoom, colisões e o cristal demonstrativo estão descritos em [primeira fatia jogável](docs/gameplay/PLAYABLE_SLICE.md), com smoke test automatizado em `tools/gameplay/smoke_playable_slice.gd`. O harness técnico preservado para QA de sprite é `tools/art/sprite_test/sprite_test.tscn`.

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

Estrutura: `game/` (cenas, scripts e dados da demo), `data/` (catálogo versionado), `assets/` (arte candidata e referências), `Docs/Main/` (referência durável), `Docs/Context/` (journal/handoff), `docs/art/` e `docs/technical/`. A execução requer Godot 4.5.1. Importação e smoke test desktop foram validados em modo headless; Android e revisão visual permanecem pendentes. Instruções de QA estrutural estão no guia da fatia jogável.

Para gerar novamente a build Web, instale os templates de exportação do Godot 4.5.1 e rode `./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --export-release Web build/web/index.html`. Sirva a pasta `build/web/` por HTTP; veja [primeira fatia jogável](docs/gameplay/PLAYABLE_SLICE.md) para comandos e limitações.

Não publicar fotos originais das crianças, credenciais, keystores ou saves pessoais. A prancha conceitual não substitui sprites de produção.
