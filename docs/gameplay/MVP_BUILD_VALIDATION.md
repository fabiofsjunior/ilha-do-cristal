# Builds de teste solo — 2026-10-16

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
