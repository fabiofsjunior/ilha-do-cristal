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
