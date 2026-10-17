# Validação — retrato 0.1.1

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
