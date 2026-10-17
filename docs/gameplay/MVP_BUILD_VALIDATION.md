# Builds de teste solo — 2026-10-17

## Android 0.1.6 — atualização do APK

APK debug `build/android/ilha-do-cristal-debug.apk`, **0.1.6/versionCode 7**, 64.680.671 bytes, SHA-256 `94a3e75920b3608c870e42af0172aaef3d23e28b465243b1077dfb7cfe153517`. Exportado no Godot 4.5.1 a partir do worktree atual da branch `feature/s02-pixel-hud-assets` (HEAD base `8140343`; alterações de trabalho não commitadas). Manifesto/package ID, retrato, ícones, assinatura v2/v3, CRC (286 entradas), permissões e dados runtime passaram.

Inclui a janela ATR e alocação de pontos, joystick ampliado, restauração de vida/mana ao evoluir, mundo de 192×132 células, câmera 3D ortogonal e correção para ataques básicos funcionarem na distância visual de contato e no contato dos hitboxes. Passaram: `test_melee_contact_spacing.gd`, `test_portrait_combat.gd`, `test_close_view.gd`, `smoke_playable_slice.gd`, `test_expanded_map_population.gd`, `test_mobile_controls_layout.gd`, `test_level_up_restores_resources.gd`, `test_respawn_radius.gd`, `test_mvp_solo_loop.gd`, `test_regeneration_rules.gd`, `test_attributes_window.gd`, `test_attributes_hud_integration.gd`, `test_inventory_overlay_layout.gd`, `validate_playable_slice.py` e `git diff --check`.

O APK não foi instalado num aparelho físico nesta sessão. O pacote Web não foi reexportado nesta correção.

## Android/Web 0.1.5 — marcador de alvo no chão

A seleção de inimigo usa uma elipse pixel art dourada plana e compacta no chão, sob os pés do monstro. `test_close_view.gd`, `test_portrait_combat.gd` e `test_mobile_controls_layout.gd` passaram. APK debug 0.1.5/versionCode 6: 61.881.163 bytes, SHA-256 `323a7bcc9579537f19fd2a2f7d0e86c215b1817501a2ef18803afd3e7dd94ab8`. ZIP Web: 14.627.842 bytes, SHA-256 `b0754dcfdba4cd27235c76d3755b8b26567dc831842ad106725119e4a74bbc47`. CRC, manifesto e assinatura v2/v3 passaram.

## Atualização Android 0.1.4 — validação da área segura

A captura do usuário ainda mostrava joystick/spells ausentes e rótulos superiores sobrepostos. O novo APK debug `build/android/ilha-do-cristal-debug.apk` está na versão 0.1.4/versionCode 5, 61.881.163 bytes, SHA-256 `4d43316b2bd6229d78fdc44afe838aa2746575f688260c8046717b4629da06d4`. O cálculo do safe rect agora rejeita dimensões incompatíveis e cai no viewport completo; labels superiores foram encurtados.

O teste `test_mobile_controls_layout.gd` passou em quatro cenários (três proporções e uma safe area com orientação incompatível simulada), incluindo posição dos controles e toque/soltura. Testes de close-view, combate retrato, smoke gameplay, catálogo, assinatura/manifesto/ícones/CRC APK e CRC Web passaram. Não foi possível testar fisicamente no Android.

ZIP Web atualizado `build/ilha-do-cristal-web.zip`, 14.627.315 bytes, SHA-256 `06057289c6d511813e9e65ad7685120cebf2f51be8a8059b025c5a3b7d753cf5`.

## Atualização Android 0.1.3 — layout dos controles 9:16

APK debug `build/android/ilha-do-cristal-debug.apk`, 61.881.163 bytes, versão 0.1.3/versionCode 4. SHA-256: `672b885a864465d37c4972675dc93c7c1feebeb89d778b4d72ecaa7518d3d7af`. Mantém o ícone cristal e o rótulo **A Ilha do Cristal**. Manifesto retrato, ARMv7/ARM64, nenhuma permissão, assinatura v2/v3 e CRC passaram. O layout headless valida o joystick no canto inferior esquerdo e spells no inferior direito em três cenários de safe area, além de entrada/toque/soltura. Nenhum aparelho estava conectado para teste físico.

Pacote Web atualizado `build/ilha-do-cristal-web.zip`, 14.627.289 bytes, SHA-256 `081a44301a9d8d199ca1f5ee44ff12cabaac93c5761137591e08dc78d425d5ed`. A integridade CRC do ZIP passou; teste gráfico em navegador continua pendente.

## Histórico Android 0.1.2 — ícone e safe area

APK debug `build/android/ilha-do-cristal-debug.apk`, 61.881.163 bytes, versão 0.1.2/versionCode 3. SHA-256: `1f13d728643acf6cac77a22c150b7de04d3630a246034756e5c0c5c5b19427f0`. Label **A Ilha do Cristal** e ícones clássico/adaptativo/monocromático foram encontrados no APK. Manifesto retrato, ARMv7/ARM64, nenhuma permissão e assinatura v2/v3 passaram. O teste de controles simulou recortes em três proporções e confirmou toque/soltura do joystick; instalação em aparelho ainda não foi possível.

## Escopo entregue

Fonte de gameplay: `bbba04f8d278f141cef7cb431dbecd22d1c02c49`, em `feature/fabio-warrior-stage1`. `main` permanece em `b3d3f9a0f9405dae020d04785069b55c702f6894`. Commits posteriores de entrega atualizam documentação e ferramentas de exportação.

O recorte permite selecionar Melissa, Helena, Maíra ou Fábio Warrior, explorar a ilha estática 64×44, coletar madeira/pedra/fibra/erva, selecionar e combater raposa/lobo/urso, usar três skills, fabricar/usar curativo, ganhar XP e pagar melhorias II/III do acampamento. Inventário, posição, inimigos, recompensas e progresso persistem localmente por aparência. [Controles, regras e limites](MVP_SOLO_TEST.md).

Não é o aceite integral do GDD: faltam Archer/Mage, árvore, mundo procedural/chunks, LAN em dois Androids, conta/cloud e construções funcionais. Melhorias do acampamento persistem os custos/nível, sem implementar baú compartilhado, poço, cerca ou torres.

## Pacotes

Os exportadores escrevem `build/web/`, `build/ilha-do-cristal-web.zip` e `build/android/ilha-do-cristal-debug.apk`, fora do Git. Cada plataforma tem `BUILD_INFO.json` com engine, commit e data; Android também registra o SHA-256 do APK.

| Plataforma | Pacote | Bytes | SHA-256 |
|---|---|---:|---|
| Web | `build/ilha-do-cristal-web.zip` | 12,434,884 | `1b245c797a1053693c7ac383e24531b7114e37fef9fc3ec2c05eb08a3551df3c` |
| Android debug | `build/android/ilha-do-cristal-debug.apk` | 59,550,750 | `ddff51ff5a290a7ad4ce04e0ea5205dfd913d0f9626151354d02b853d50d1112` |

Web: extraia o ZIP inteiro e execute `Testar_Jogo_Web.bat` no Windows com Python 3. O servidor e o launcher estão dentro do pacote; não exigem checkout nem Godot no computador de teste. Em outro sistema, sirva a pasta extraída com `python3 -m http.server 8000` e abra `http://localhost:8000/`.

Android: APK debug, `com.fabiofsjunior.ilhadocristal`, ARMv7/ARM64, min SDK 24 / target 35, paisagem, sem permissões. A chave debug é local e não está versionada. [Reprodução da build Android](../technical/ANDROID_BUILD.md).

## Verificações executadas

| Verificação | Resultado e alcance |
|---|---|
| Godot 4.5.1 import | PASS; reimport ETC2/ASTC e scripts sem erros de import/parse. Sem daemon adb conectado. |
| Cena principal, 300 frames headless | PASS; não é captura gráfica. |
| `smoke_playable_slice.gd` | PASS; navegação, quatro aparências, três texturas candidatas, coleta, clique real, autoataque, IA, área segura, 2.816 células, movimento/colisão e pausa. |
| `test_mvp_solo_loop.gd` | PASS; receita exata, cura 40 HP/4 s, interrupção, XP/drop único, camp II/III, rotação limitada a dois slots e recuperação após corrupção de checksum. Os warnings de corrupção/recuperação são provocados pelo teste isolado. |
| `tools/art/sprite_test/check_scene.gd` | PASS técnico; 240 seleções de quadros e 48 estados sincronizados. |
| `validate_playable_slice.py` | PASS; 22 referências, quatro aparências idle4/walk6 em oito direções e composição completa de 56 tiles. |
| `validate_catalogs.py` | PASS; 10 grupos, 54 IDs estáveis. |
| `validate_mvp_terrain_tileset.py` | PASS de estrutura e junções; 56 tiles, alpha 0/255. Revisão no motor/aparelho pendente. |
| `validate_helena_8dir.py` / `validate_helena_stage1.py` | PASS estrutural com alertas de alpha, apoio/pivô e passada. |
| `validate_sprite_atlases.py` | FALHA conhecida: 21 atlas de personagem com alpha intermediário. |
| `validate_fox_candidate.py` | PASS estrutural; alpha permanece pendente. |
| `validate_creature_candidates.py` | PASS estrutural dos três. `--strict-art` falha por alpha e contrato de animação/direção incompleto. |
| Python compile / `git diff --check` | PASS. |

| Exportação/pacote | Resultado |
|---|---|
| Web release, Godot 4.5.1, sem threads | PASS; HTML/JS/WASM/PCK e metadados no ZIP, CRC íntegro, sem sidecars de import. |
| PCK Web extraído, sem checkout no diretório de teste | PASS; smoke completo em Godot nativo headless com script externo. Demonstra recursos exportados e lógica; não renderiza WebGL. |
| WASM | PASS de compilação no Node; não é execução gráfica do navegador. |
| Localhost portátil | PASS; pasta com espaços, execução fora do checkout, HTTP HTML/WASM/PCK, MIME WASM, porta livre e encerramento Ctrl+C. O helper Python foi executado no Linux; o `.bat` foi incluído e inspecionado, sem execução Windows neste ambiente. |
| APK debug | PASS; aapt xmltree, apkanalyzer XML, assinatura v2/v3, CRC (234 entradas), JSONs de catálogo/mapa/3 criaturas e exclusões de tools/docs/referências/build. Sem instalação/aparelho. |

Os exportadores recusam `ERROR:`/`SCRIPT ERROR:` mesmo se o Godot terminar com código zero. Android registra uma única exceção explícita: a mensagem completa de ícone de projeto ausente, usando o ícone padrão do template para esta build debug; ela permanece visível no log. Os templates Web corretos são `web_nothreads_debug.zip` e `web_nothreads_release.zip`, pois o preset desativa threads.

### Revisão visual e plataforma pendentes

- As três poses foram examinadas em tamanho nativo e nearest. A [prancha de QA](../art/evidence/creatures-contact-candidates.png) compõe os mesmos PNGs sobre checkerboard; não é screenshot do jogo.
- A execução gráfica no navegador não foi demonstrada: Chrome local foi bloqueado pelas restrições do ambiente; o navegador remoto não alcançou o localhost deste workspace. HTTP, integridade e execução headless do pacote não validam WebGL, toque nem persistência IndexedDB.
- Não há aparelho Android, emulador ou KVM disponível. Assinatura/manifesto/CRC não provam instalação, legibilidade, desempenho ou salvamento no dispositivo.
- Próximo aceite: instalar o APK e percorrer o loop, fechar/reabrir, pausar o app, conferir controles/zoom 50–125% e comparar com a UI v0.7 em dois tamanhos de tela. Revisar Web graficamente no navegador.

## Estado da arte

| Asset | Alterações neste incremento | Pendências |
|---|---|---|
| Fábio | Atlas existentes preservados; Warrior disponível no loop. | Alpha/halo, direção, passada/pivô e estados além de idle/walk: CORRIGIR. |
| Helena | Atlas existentes preservados; Warrior disponível no loop. | Alpha, passada/pivô e revisão visual por direção: CORRIGIR. |
| Maíra | Atlas existentes preservados; Warrior disponível no loop. | 12 fontes antigas truncadas continuam isoladas do import; direções/passadas e alpha: CORRIGIR. |
| Melissa | Atlas existentes preservados; Warrior disponível no loop. | Alpha, espada e passadas: CORRIGIR. |
| Terreno | Os 56 IDs e a composição do mapa foram mantidos. | CANDIDATO; revisão gráfica no contexto do jogo/Android pendente. |
| Raposa | Uma pose SE, 96×96, pivô [48,80]. | 1.147 pixels com alpha intermediário; outras sete direções e animações pendentes: CORRIGIR. |
| Lobo | Uma pose SE, 96×96, pivô [48,80]. | 1.659 pixels com alpha intermediário; outras sete direções e animações pendentes: CORRIGIR. |
| Urso | Uma pose SE, 128×128, pivô [64,108]. | 4.158 pixels com alpha intermediário; outras sete direções e animações pendentes: CORRIGIR. |

Relatórios por criatura: [raposa](../art/evidence/fox/fox_se_candidate_v1_report.md), [lobo](../art/evidence/wolf/wolf_stage1_review.md) e [urso](../art/evidence/bear/BEAR_CANDIDATE_QA.md). Fontes brutas e empacotadores foram preservados; não houve binarização de alpha, espelhamento ou multiplicação de poses para simular atlas completos. Nenhuma arte foi aprovada para produção.

## Arquivos alterados

Comparação com a base `e7eb0e0e4dc130fc642c327715effdb5a78be6b3`; builds e ferramentas locais não entram na lista.

- `.gitignore`
- `Docs/Context/DECISIONS.md`
- `Docs/Context/HANDOFF.md`
- `Docs/Context/JOURNAL.md`
- `Docs/Context/PROTOTYPE_LOG.md`
- `Docs/Main/ROADMAP.md`
- `README.md`
- `Testar_Jogo_Web.bat`
- `assets/creatures/bear/bear_se_candidate_v1.json`
- `assets/creatures/bear/bear_se_candidate_v1.png`
- `assets/creatures/fox/fox_se_candidate_v1.json`
- `assets/creatures/fox/fox_se_candidate_v1.png`
- `assets/creatures/wolf/wolf_se_candidate_v1.json`
- `assets/creatures/wolf/wolf_se_candidate_v1.png`
- `assets/references/generated-candidates/bear/README.md`
- `assets/references/generated-candidates/bear/bear_se_source_v1.png`
- `assets/references/generated-candidates/bear/bear_se_source_v2.png`
- `assets/references/generated-candidates/fox/fox_se_source_imagegen_v1.png`
- `assets/references/generated-candidates/fox/fox_se_source_imagegen_v2.png`
- `assets/references/generated-candidates/wolf/.gdignore`
- `assets/references/generated-candidates/wolf/GENERATION_NOTES.md`
- `assets/references/generated-candidates/wolf/wolf_se_source_v1.png`
- `assets/references/generated-candidates/wolf/wolf_se_source_v2.png`
- `assets/references/generated-candidates/wolf/wolf_se_source_v3.png`
- `docs/art/evidence/bear/BEAR_CANDIDATE_QA.md`
- `docs/art/evidence/bear/bear_se_candidate_v1_native.png`
- `docs/art/evidence/bear/bear_se_candidate_v1_nearest_4x.png`
- `docs/art/evidence/creatures-contact-candidates.png`
- `docs/art/evidence/fox/fox_se_candidate_v1_nearest_8x.png`
- `docs/art/evidence/fox/fox_se_candidate_v1_report.md`
- `docs/art/evidence/fox/fox_se_source_imagegen_v2_native.png`
- `docs/art/evidence/wolf/wolf_se_nearest_preview_v1.png`
- `docs/art/evidence/wolf/wolf_stage1_review.md`
- `docs/gameplay/MVP_BUILD_VALIDATION.md`
- `docs/gameplay/MVP_SOLO_TEST.md`
- `docs/gameplay/PLAYABLE_SLICE.md`
- `docs/technical/ANDROID_BUILD.md`
- `export_presets.cfg`
- `game/data/first_island_layout.json`
- `game/scripts/actors/creature_art_loader.gd`
- `game/scripts/actors/player.gd`
- `game/scripts/combat/combat_rules.gd`
- `game/scripts/combat/creature_actor.gd`
- `game/scripts/core/main.gd`
- `game/scripts/save/expedition_state.gd`
- `game/scripts/world/first_island.gd`
- `game/scripts/world/first_island_hud.gd`
- `project.godot`
- `tools/art/README.md`
- `tools/art/pack_bear_candidate.py`
- `tools/art/pack_fox_candidate.py`
- `tools/art/pack_wolf_candidate_v1.py`
- `tools/art/validate_creature_candidates.py`
- `tools/art/validate_fox_candidate.py`
- `tools/build/export_android.py`
- `tools/build/export_web.py`
- `tools/gameplay/smoke_playable_slice.gd`
- `tools/gameplay/test_mvp_solo_loop.gd`
- `tools/web/serve_web_build.py`
