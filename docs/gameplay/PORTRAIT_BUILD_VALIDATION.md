# Validação — retrato

## Atualização Android 0.1.5 — marcador de alvo no chão — 2026-10-16

- O destaque de alvo agora é uma elipse pixel art compacta, plana e dourada sob os pés do inimigo. Mantém alinhamento com o sprite 3D e aparece somente no alvo selecionado.
- `test_close_view.gd` validou tamanho da textura, orientação plana, alinhamento do marcador e HUD de alvo; `test_portrait_combat.gd` passou nos quatro níveis de zoom, troca e persistência de alvo; `test_mobile_controls_layout.gd` passou no layout retrato.
- APK debug **0.1.5/versionCode 6**, 61.881.163 bytes. SHA-256: `323a7bcc9579537f19fd2a2f7d0e86c215b1817501a2ef18803afd3e7dd94ab8`. Manifesto, assinatura v2/v3, ícones e CRC passaram.
- ZIP Web **14.627.842 bytes**. SHA-256: `b0754dcfdba4cd27235c76d3755b8b26567dc831842ad106725119e4a74bbc47`; CRC passou.
- Renderização em aparelho Android e navegador ainda depende de playtest físico/gráfico.

## Atualização Android 0.1.4 — safe area validada — 2026-10-16

- A captura do usuário mostrou joystick/spells ausentes e rótulos do topo sobrepostos. O layout agora rejeita um safe rect Android incompatível com a proporção do viewport e usa o viewport completo como fallback; rótulos foram encurtados para Bolsa/Base.
- `test_mobile_controls_layout.gd` passou em quatro cenários, incluindo dimensões de tela incompatíveis simuladas, além de limites, cantos inferiores e toque/soltura do joystick.
- Regressões `test_close_view.gd`, `test_portrait_combat.gd`, `smoke_playable_slice.gd`, catálogo e compilação dos exportadores passaram.
- APK debug **0.1.4 / versionCode 5**, 61.881.163 bytes. SHA-256: `4d43316b2bd6229d78fdc44afe838aa2746575f688260c8046717b4629da06d4`. Assinatura v2/v3, ícone, label, orientação retrato e CRC passaram.
- ZIP Web atualizado: 14.627.315 bytes. SHA-256: `06057289c6d511813e9e65ad7685120cebf2f51be8a8059b025c5a3b7d753cf5`; CRC passou.
- Não há aparelho Android conectado para confirmar a renderização física. A captura enviada motivou a correção; instalação e toque na versão 0.1.4 ainda precisam ser conferidos no aparelho.

## Atualização Android 0.1.3 — controles nos cantos 9:16 — 2026-10-16

- A raiz do `CanvasLayer` agora cobre o viewport inteiro; os insets do Android servem somente para afastar controles das bordas seguras. Isso evita que a raiz menor altere os anchors e jogue o joystick para fora da tela.
- Joystick e curativo ficam no canto inferior esquerdo; spells e interação ficam alinhados no canto inferior direito. A linha das spells compartilha o alinhamento inferior do joystick.
- `test_mobile_controls_layout.gd` passou em três proporções/áreas seguras simuladas. Confirma viewport completo, HUD dentro da área segura, joystick inferior esquerdo, spells inferior direito e entrada/toque/soltura no joystick.
- `test_close_view.gd`, `test_portrait_combat.gd`, `smoke_playable_slice.gd`, catálogos, compilação Python e `git diff --check` passaram.
- APK debug **0.1.3 / versionCode 4**, package `com.fabiofsjunior.ilhadocristal`, ARMv7/ARM64, label e ícones confirmados, assinatura v2/v3 válida e CRC íntegro. Tamanho: 61.881.163 bytes. SHA-256: `672b885a864465d37c4972675dc93c7c1feebeb89d778b4d72ecaa7518d3d7af`.
- O pacote Web também foi reexportado: `build/ilha-do-cristal-web.zip`, 14.627.289 bytes, SHA-256 `081a44301a9d8d199ca1f5ee44ff12cabaac93c5761137591e08dc78d425d5ed`; CRC passou. Execução gráfica em navegador não foi validada nesta sessão.
- Não havia aparelho Android conectado; a posição foi validada por layout e toque sintético, sem teste físico de notch, multitouch ou playtest.

## Histórico Android 0.1.2 — ícone e safe area

- Ícone launcher pixel art do cristal: versão clássica e camadas adaptativa/monocromática; rótulo exportado **A Ilha do Cristal**.
- Corrigida a aplicação da área segura edge-to-edge. O HUD mantém tamanho positivo e usa a posição/tamanho do safe rect; joystick, skills e interação permanecem visíveis.
- `test_mobile_controls_layout.gd` passou com recortes sintéticos em três proporções, incluindo arrasto/soltura do joystick. Import, regressão de câmera/viewport, combate retrato, smoke de gameplay, catálogo e export Android passaram.
- APK debug **0.1.2 / versionCode 3**, package `com.fabiofsjunior.ilhadocristal`, ARMv7/ARM64, assinatura v2/v3 válida, ícones e label confirmados, CRC íntegro. SHA-256: `1f13d728643acf6cac77a22c150b7de04d3630a246034756e5c0c5c5b19427f0`.
- Não havia aparelho Android conectado; notch real, multitouch e playtest ainda pendentes.

## Alterações

Base 720×1280, retrato Android e expansão do mundo para preencher outras proporções. Controles respeitam safe area Android. Web ocupa o viewport e solicita fullscreen/orientação por gesto quando suportado. Menus e overlays em retrato. HUD mantém a hierarquia do anexo escolhido pelo usuário, usando a arte candidata existente da ilha.

Seleção por corpo visível, raio mínimo em pixels lógicos compensado por zoom, retenção de alvo no chão e troca entre monstros visíveis. Indicador de alvo e barra HP local. Números flutuantes de HP efetivamente removido: básico, skills, sangramento, fatal e recebido. Efeitos continuam após morte do monstro e são removidos por tween.

## Verificações

- Godot 4.5.1 import sem erro de script.
- Smoke menu → personagem → sessão → ilha, atlas, IA, movimento, seleção e pausa: passou.
- Estado solo/craft/recompensa única/camp II–III/save/corrupção/recuperação: passou; warnings de corrupção são esperados no teste.
- Catálogo e recursos: passou, sem mudança em PNGs de personagem.
- `test_portrait_combat.gd`: passou em headless e render OpenGL/Mesa llvmpipe via Xvfb. Limites de painéis/botões em 720×1280, 720×1600, 960×1280; toque em 50/75/100/125%; retenção/ciclo de alvo; números causado/recebido/fatal e remoção. Captura `build/portrait-gameplay.png` inspecionada.
- APK Debug: exportador verifica package `com.fabiofsjunior.ilhadocristal`, portrait `screenOrientation=1`, assinatura v2/v3, CRC, dados runtime e ausência de referências/docs/ferramentas. VersionCode 2 / 0.1.1.
- Web sem threads: ZIP contém runtime/launcher/BUILD_INFO; executar por HTTP.

## Limites

Não foi instalado em Android físico. Notch por fabricante, multitouch no aparelho e 10 minutos de estabilidade são pendências de aceite. Fullscreen/orientação na Web dependem do navegador. APK usa assinatura debug local; não é release para loja. Preservar progresso antes de trocar instalação se Android apontar assinatura incompatível. Arte, três vocações, LAN e demais gates do roadmap seguem com seus estados anteriores.

## Artefatos exportados e conferidos

Código-fonte das builds: `b02cf9c1a1efe169bbbc2242f37ecb1289dc734a` (Godot 4.5.1).

| Artefato | SHA-256 |
| --- | --- |
| `Ilha-do-Cristal-0.1.1-teste.apk` | `fe238f0e3bad606902a616811becb19b4c7c9beb9b15f53817997f328c4e8a33` |
| `Ilha-do-Cristal-0.1.1-Web.zip` | `6528c4a45f4e83102ea50901cf238497e3e6f57b5c3b95eb754ab4df5dd312d5` |

Ambos sidecars `BUILD_INFO.json` apontam para o commit acima. O export Android final passou em todos os gates do exportador, incluindo manifesto portrait e assinatura. ZIP Web passou CRC e WebAssembly compilou em Node. A tentativa de abrir Chromium no workspace falhou na inicialização porque o ambiente bloqueia o socket local do processo; não foi possível validar WebGL/IndexedDB no navegador. Isso não impediu a revisão gráfica nativa Godot via Xvfb/TCP/Mesa, que passou.

PR: https://github.com/fabiofsjunior/ilha-do-cristal/pull/10 (base da branch jogável, main preservada).
