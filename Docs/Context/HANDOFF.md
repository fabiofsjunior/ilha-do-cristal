# Handoff — teste de retrato 0.1.1

Branch: `feature/s02-portrait-combat-hud`, código exportado `b02cf9c1a1efe169bbbc2242f37ecb1289dc734a`, origem `d0abbb6` na branch jogável `feature/fabio-warrior-stage1`; main preservada.

## Próxima ação exata

Instalar o novo APK debug 0.1.1 (versionCode 2) e testar entrada → aparência 2×2 → solo → seleção/toque e Trocar alvo → combate/números flutuantes → mochila/curativo/refúgio → pausa/retorno → fechar/reabrir. Conferir em Android físico retrato 9:16 e tela alongada: notch, navegação, multitouch e 10 minutos de estabilidade. Assinatura debug desta máquina pode diferir da anterior; erro de assinatura exige preservar o progresso antes de trocar a instalação.

Abrir Web por HTTP via launcher no ZIP. Tela cheia depende do suporte e gesto do navegador; o canvas usa todo viewport.

## Implementação e evidência

HUD solicitado pelo usuário em `1001362477.jpg`: retrato/HP/MP/XP, alvo/retrato/HP, ações circulares, joystick, cenário sem letterbox. Mundo/sprites candidatos da ilha preservados. Seleção no corpo com raio compensado por zoom, anel e HP visíveis, toque vazio mantém alvo. Dano efetivo causado/recebido/fatal flutua e desaparece. Menus/mochila/refúgio ajustados ao retrato; router não bloqueia mais clique no mundo.

Import, smoke, estado/save/recovery, catálogos, recursos e regressão `tools/gameplay/test_portrait_combat.gd` passaram. Regressão cobre 3 proporções e 4 zooms; render Godot OpenGL/Mesa em Xvfb inspecionado. APK e Web são builds de teste: nenhuma aprovação nova de arte ou conclusão de S0–S2. Ver `docs/gameplay/PORTRAIT_BUILD_VALIDATION.md` e sidecars `BUILD_INFO.json` nos arquivos de entrega.

Godot 4.5.1 local `/tmp/godot/Godot_v4.5.1-stable_linux.x86_64`; SDK `/opt/android-sdk`, JDK17; templates 4.5.1 e keystore locais, fora do Git. Exportadores existentes agora validam manifesto portrait.

## Arquivos finais

`Ilha-do-Cristal-0.1.1-teste.apk` e `Ilha-do-Cristal-0.1.1-Web.zip`. Export/CRC/assinatura/portrait aprovados; WebAssembly compila. WebGL/IndexedDB não verificados: Chromium local bloqueado ao criar socket. PR #10 aberta sobre a branch jogável. Hashes completos no relatório de validação.
