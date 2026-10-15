# Handoff — primeira fatia jogável

**Worktree/branch de integração:** `ilha-do-cristal`, `feature/fabio-warrior-stage1`
**Base exata:** `feature/fabio-warrior-stage1` em `16e759350ad9a3f76ded314e0050a820939b3a5f`
**Commits integrados localmente:** `b1c66a5` (`feat: add playable local gameplay slice`, cherry-pick de `032f426`) e `b8339e6` (checkpoint documental, cherry-pick de `1398e61`). `main` permaneceu intacta; ainda não houve push para `origin`.

## Próxima ação

Abrir a raiz do repositório com Godot 4.5.1, importar os recursos e executar `game/scenes/main.tscn`. Corrigir eventuais erros de API/recursos, verificar o fluxo contra `docs/prototypes/mvp_ui_v0_7.html` e salvar capturas/evidência de gameplay. Em seguida, exportar/instalar em um aparelho Android e testar por 10 minutos em paisagem, em dois tamanhos de tela, com zoom 50%, 75%, 100% e 125%, cobrindo joystick, pausa, interação, colisões, legibilidade, estabilidade e desempenho. Só então reavaliar S0/S1 e solicitar revisão visual; este commit não fecha essas fases.

## Estado implementado

- Root main scene agora entra na demo. `tools/art/sprite_test/sprite_test.tscn` permanece para QA de atlas.
- Roteamento: início → quatro aparências Warrior → sessão local → mapa; pause overlay pode retomar, voltar à sessão ou ao início. “Entrar” apresenta erro mockado recuperável. A aprovação do usuário em 2026-10-15 é do protótipo v0.7 e não valida a UI real.
- Movimento: WASD/setas, joystick virtual touch arrastável, botão touch de pausa e interação, câmera nearest sem smoothing e zoom 50–125%.
- Mapa determinístico estático inicial: 64×44 tiles de 32 px candidatos, usando a composição 17 bases + 24 transições + 15 overlays. Água, bordas e proxies de árvores/pedras colidem; cristal é alvo de interação não persistente.
- Os quatro atlas Warrior existentes fornecem somente `idle`/`walk` em oito direções. Estado artístico permanece **CORRIGIR** e terreno **CANDIDATO**; nenhum PNG de personagem foi alterado.

## Limitações e validações

LAN, contas, saves, multiplayer, combate, coleta, inventário/progressão e persistência ainda não existem. “Hospedar solo” abre este mapa local; endereço de “Entrar” é um mock. Proxies de cenário e cristal são shapes em código, não arte aprovada.

`validate_playable_slice.py`, validador de terreno, validador de catálogo, `py_compile` e `git diff --check` passaram. O teste estrutural confirma 2.816 células base preenchidas e overlays de caminho com transparência. A inspeção visual Pillow/layout mostra praia, floresta, caminho, spawn, cristal e proxies, mas não é screenshot/render Godot. `validate_sprite_atlases.py` ainda retorna falha por 21 candidatos com alpha intermediário, como já documentado. O runner não tem `godot`, `godot4`, `adb` ou executável Android; `gdtoolkit` 4.5.0 temporário passou parser/lint GDScript. Não houve import/run, build, captura no motor ou teste Android. Os gates de S0/S1 continuam pendentes.
