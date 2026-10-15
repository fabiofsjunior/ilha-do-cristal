# Demo jogável de A Ilha do Cristal

O projeto Godot 4.5.1 fica na raiz do repositório. `project.godot` inicia `game/scenes/main.tscn`, que implementa a primeira fatia desktop de navegação local e movimento; o harness técnico de sprites continua em `tools/art/sprite_test/sprite_test.tscn`.

O fluxo e as limitações estão em [`docs/gameplay/PLAYABLE_SLICE.md`](../docs/gameplay/PLAYABLE_SLICE.md). Os atlas de personagem e o terreno continuam candidatos (`CORRIGIR`/`CANDIDATO`). A demo não implementa conta, LAN, save, combate ou progressão.

Godot 4.5.1 Linux headless importou o projeto sem warnings/erros e executou a cena principal. `tools/gameplay/smoke_playable_slice.gd` valida o fluxo de cenas, os atlas dos quatro personagens, o mapa inicial, movimento, colisão com água e pausa. A execução headless confirma estrutura e comportamento, não revisão visual. A pasta `assets/references/generated-candidates/maira_warrior/` está excluída do import Godot por conter 12 PNGs fonte truncados; isso não corrige nem aprova as sprites. Editor visual, preset/APK e aparelho Android seguem pendentes. Esta entrega não conclui S0 ou S1.
