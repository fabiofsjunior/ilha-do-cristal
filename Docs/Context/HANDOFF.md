# Handoff — integrar e entregar o APK 0.1.6

**Branch de integração:** `feature/s02-main-sync-016`
**Código consolidado local:** `b0b7b7f188e157642fd50de0dd26e19751c29bfe`
**Main remoto ao iniciar:** `b3d3f9a0f9405dae020d04785069b55c702f6894`
**Integração:** pendente; as PRs #10 e #11 estavam empilhadas sobre branches de feature.

## APK validado

`build/android/ilha-do-cristal-debug.apk`, versão **0.1.6**, versionCode **7**, 64.680.671 bytes, SHA-256 `94a3e75920b3608c870e42af0172aaef3d23e28b465243b1077dfb7cfe153517`.

Manifesto: package `com.fabiofsjunior.ilhadocristal`, retrato, ARMv7/ARM64. CRC sem falhas; blocos de assinatura v2/v3 presentes. O sidecar registra a base `8140343`; a documentação de build afirma que o pacote foi exportado do worktree sujo que depois foi consolidado no commit `b0b7b7f`.

## Verificações e limitações

Passaram novamente: catálogo (10 grupos/54 IDs), validador de gameplay, separação visual de combate corpo a corpo e estrutura do terreno (56 tiles); SHA-256 e integridade ZIP do APK conferidos. O validador de gameplay foi ajustado para vigiar somente os atlases Warrior carregados em runtime; fontes candidatas de Mago não alteram essa fatia.

O ambiente atual não tem Godot, Android SDK, `adb` nem aparelho conectado. Portanto, não reexportei o APK nem repeti os testes Godot nesta etapa; os resultados anteriores estão registrados em `MVP_BUILD_VALIDATION.md`. A build Web permanece na 0.1.5.

## Próxima ação

Publicar a branch de integração, abrir PR para `main`, integrar as features e entregar o APK para download. Depois, instalar a 0.1.6 em Android físico e validar controles, leitura do HUD e estabilidade.

## Histórico — revisão visual candidata

Branch: feature/s02-pixel-hud-assets. Base recuperada: 8140343ab27752fb0452e2ce2285a66fecc1d0cd.

## 2026-10-16 — Visão próxima oblíqua e HUD compacta (candidata)

Referência: anexos image(20261016-162830).png (estado anterior) e image(20261016-162915).png (objetivo). Pedido explícito autoriza implementar essa direção.

Mudanças: zoom lógico 150–300%, padrão200%, normalizado pelo lado curto do viewport; smoothing5; HUD de rosto, alvo somente selecionado, sem botão Auto ON; minimapa com posição real; controles reancorados e modais escalados em paisagem/retrato. Chão contínuo com bordas orgânicas, faces de relevo decorativas, props com pivô e Y-sort. Sprites de personagens e regras de combate/save preservadas.

Limites: top-down oblíquo com profundidade visual, não transformação isométrica64x32, nem reprodução integral do lago/ruínas. Arte candidata. Checkout recuperado do GitHub (branch feature/s02-pixel-hud-assets); alterações não publicadas de sessões anteriores não estavam disponíveis. Não afirmar que esta build contém regeneração/XP10x/inventário novos de outro checkout.

Verificações: Godot4.5.1 import e smoke de fluxo/coleta/combate/movimento; test_close_view em1280x720,720x1280,1920x1080; catálogo54 IDs; diff-check. Render gráfico bloqueado pelo ambiente (Xvfb não consegue criar sockets); Android físico e WebGL pendentes. Preview terrain é composição offline, não screenshot do jogo.

Histórico daquela etapa: executar Web em navegador e comparar câmera/HUD com referência; revisar terreno candidato e planejar TileMap isométrico caso exija projeção64x32. Naquele momento o APK não foi gerado por falta de SDK; a build 0.1.5 com SDK instalado está registrada abaixo.

## 2026-10-16 — Renascimento corrigido

Monstros renascem após15s quando o jogador está a mais de5SQMs (160px) do ponto de origem. Removido bloqueio por visibilidade da câmera; refúgio permanece protegido. Teste test_respawn_radius.gd passou: prazo, distâncias0/159/160/161px e ausência de renascimento duplicado.

## Escolha Camera3D mantida

Cena Isometric3DView/Camera3D: projeção ortogonal, size16, rotação X−30°/Y45°, lerp speed5. Conversão visual SQM XY→XZ com sprites billboard; HUD CanvasLayer; jogo, saves e colisões continuam simulados em 2D. Script: game/scripts/world/isometric_3d_view.gd.

Import Godot4.5.1, smoke_playable_slice.gd, test_close_view.gd, test_portrait_combat.gd e test_respawn_radius.gd passaram. WebGL em navegador e Android físico ainda precisam de validação visual/performance.

## Atualização — marcador de alvo e builds 0.1.5

O indicador de alvo grande foi substituído por uma elipse pixel art dourada, compacta e plana no chão, alinhada aos pés do inimigo e visível apenas quando selecionado. `test_close_view.gd`, `test_portrait_combat.gd` e `test_mobile_controls_layout.gd` passaram. APK/Web 0.1.5 exportados. Hashes: APK `323a7bcc9579537f19fd2a2f7d0e86c215b1817501a2ef18803afd3e7dd94ab8`; Web `b0754dcfdba4cd27235c76d3755b8b26567dc831842ad106725119e4a74bbc47`. Fazer playtest no Android quando disponível.

## APK 0.1.6 — joystick, atributos e level-up

O joystick foi dobrado (144→288 px lógicos) e seu toque foi corrigido para considerar a transformação completa do HUD. A navegação ganhou o botão `ATR`, ligado à janela de pontos FOR/AGI/INT com confirmação, reset temporário e save. Cada level-up agora restaura HP e MP aos máximos da vocação/atributos. Estas mudanças foram exportadas no APK 0.1.6/versionCode 7; ver o registro atual no início deste handoff. O ZIP Web continua anterior.

## Histórico — playtest do APK 0.1.4

Branch atual: `feature/s02-pixel-hud-assets`. HEAD: `8140343`. APK Android 0.1.4/versionCode 5 em `build/android/ilha-do-cristal-debug.apk` e ZIP Web atualizado em `build/ilha-do-cristal-web.zip`. A captura do usuário mostrou os controles ausentes; esta versão valida a safe area Android e recua para o viewport completo quando as dimensões reportadas não correspondem à orientação do jogo. Os rótulos do topo também foram encurtados.

Verificações concluídas: Godot import; `test_mobile_controls_layout.gd` (quatro cenários, incluindo orientação incompatível de safe area, limites de HUD e joystick touch); `test_close_view.gd`; `test_portrait_combat.gd`; `smoke_playable_slice.gd`; catálogos; assinatura, manifesto, ícones e CRC do APK/ZIP Web. Hashes: APK `4d43316b2bd6229d78fdc44afe838aa2746575f688260c8046717b4629da06d4`; Web `06057289c6d511813e9e65ad7685120cebf2f51be8a8059b025c5a3b7d753cf5`.

Bloqueio restante: nenhum aparelho Android está conectado. Próxima ação: instalar a build 0.1.4 no aparelho e confirmar se os controles aparecem na captura, além de notch, multitouch e estabilidade. Câmera/terreno continuam apresentação 2.5D candidata; render WebGL e arte seguem sem aceite visual.
