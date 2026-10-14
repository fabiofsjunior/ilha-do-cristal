# Decisões — 2026-10-14

- Nome **A Ilha do Cristal**; naufrágio de cruzeiro; estética **RPG Clássico 2D pixel art**. Vael perde a humanidade ao buscar poder e causa mutações; castelo e exército são expansão futura.
- Mobile-first Android, paisagem, joystick virtual esquerdo, ações e magias à direita, toque em objetos, zoom padrão 75% e faixa 50–125% sujeita a teste.
- Qualquer conta cria Melissa ou Helena em qualquer vocação; vocação permanente por personagem. Equipamento não altera a aparência.
- Ilha alvo até 1000×1000 SQMs, gerada por seed e carregada em chunks; save do mundo local ao host, personagem na conta.
- Escolha inicial: Firebase Spark para identidade/progressão, condicionada a protótipo de integração no Godot; LAN deve funcionar sem internet.
- Curva XP +30% por nível. 3 pontos de árvore na criação e 3 a cada subida até 50 (150 no total); 1 ponto de atributo por subida. Cap inicial nível 10.
- Números de dano, recursos, XP por atividade e construção são hipóteses para playtest.

Validar antes de consolidar integração: fluxo Firebase Auth offline/online em Godot Android; descoberta LAN e permissões em dispositivos alvo; performance por chunk; importação de sprite; comportamento quando host perde o save ou desinstala o app.
