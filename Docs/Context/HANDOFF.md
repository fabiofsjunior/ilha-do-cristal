# Handoff — validação visual da build Web

**Branch de trabalho:** `feature/fabio-warrior-stage1`
**Base antes deste incremento:** `968974a` (`build: add Godot Web export preset`)
**Engine local:** `Godot_v4.5.1-stable_linux.x86_64` na raiz; versão `4.5.1.stable.official.f62fdbde1`, excluída localmente do Git.

## Próxima ação

No Windows, executar `Testar_Jogo_Web.bat` na raiz para abrir a build local em um navegador. Revisar início → seleção → sessão → gameplay, controles, HUD/mapa e escala nearest comparando com o protótipo validado v0.7. Depois abrir o projeto no editor Godot e testar Android: exportar/instalar APK e jogar em paisagem por 10 minutos, dois tamanhos de tela, zoom 50–125%, joystick, pausa, interação, colisões, legibilidade, estabilidade e desempenho. Não fechar S0/S1 sem essas evidências.

## Estado testado nesta sessão

- Importação limpa no Godot 4.5.1 Linux headless; cena principal executada por 300 frames sem log de erro.
- `tools/gameplay/smoke_playable_slice.gd` passou fluxo de cenas, carregamento de quatro atlas, mapa 64×44 (2.816 células base), caminho, movimento pelo joystick, colisão com água, pausa/retomada, retorno à sessão e ao início.
- `tools/art/sprite_test/check_scene.gd` passou 240 seleções de quadros e 48 estados de controles entre três versões Melissa. Isso é QA técnico, não aprovação visual.
- Validadores estruturais gameplay, terreno e catálogo passaram. Helena 8-dir/stage1 passaram com alertas; `validate_sprite_atlases.py` continua falhando em 21 atlas por alpha intermediário. Estado artístico continua **CORRIGIR**; terreno **CANDIDATO**.
- Preset Web exportou com código 0; WASM compilou no Node e o ZIP passou CRC. O launcher `tools/web/serve_web_build.py --no-browser` respondeu HTML/WASM/PCK por HTTP, escolheu porta alternativa quando a porta inicial estava ocupada e encerrou via Ctrl+C. Teste gráfico em navegador ainda não foi feito neste runner.

## Pendências e bloqueios

- Não houve captura/comparação visual em editor nem validação em Android; este runner não fornece display/SDK/aparelho.
- Doze PNGs fonte direcionais de Maíra estão truncados no próprio histórico remoto e não há cópia íntegra nos worktrees. A pasta de referência tem `.gdignore` para não bloquear o import/runtime; isso não recupera fontes, não altera atlas e não muda o status **CORRIGIR**.
- LAN, conta, saves, combate, coleta, inventário funcional e progressão continuam fora desta fatia.
- `main` permanece intacta. Não houve push; o conjunto remoto observado é somente `main` e `feature/fabio-warrior-stage1`.
