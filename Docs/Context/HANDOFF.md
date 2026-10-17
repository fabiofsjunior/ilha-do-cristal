# Handoff — movimento alinhado à câmera 2.5D

Branch: `feature/s03-north-south-direction`; baseline `38728f0` (main após PR #16). O commit local desta correção fica no HEAD da branch e seu hash foi informado ao responsável pela revisão.

O teclado e o joystick agora convertem a intenção da tela para o plano XZ pela inversa da projeção da câmera. O facing usa a direção da tela. `tools/gameplay/smoke_playable_slice.gd` cobre oito direções, teclado ↑/↓, alinhamento projetado e normalização da velocidade. Importação e fluxo jogável headless passaram no Godot 4.5.1.

Escopo desta microtarefa: movimento. Colisão, regeneração, morte/renascimento, HUD e arte permaneceram inalterados. Nenhum APK ou teste físico Android foi feito.

Próxima ação: revisar e integrar o commit local no fluxo de trabalho autorizado; manter aberto o aceite S1 em aparelho Android e a verificação visual do controle. Bloqueador: falta playtest físico.
