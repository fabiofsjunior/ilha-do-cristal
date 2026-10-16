# Fatia S2 — teste solo

**Estado:** loop de gameplay solo implementado no incremento local. O teste cobre coleta, receita, dano/cura, combate/recompensa única e snapshots; isto não aprova o GDD MVP inteiro nem substitui revisão visual ou teste em aparelho.

## Como testar

Com Godot 4.5.1, no diretório do projeto:

```sh
python3 tools/gameplay/validate_playable_slice.py
python3 tools/validate_catalogs.py
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --script tools/gameplay/smoke_playable_slice.gd
./Godot_v4.5.1-stable_linux.x86_64 --headless --path . --script tools/gameplay/test_mvp_solo_loop.gd
```

O smoke da cena confirma a navegação já aprovada, as quatro aparências Warrior, os três candidatos SE, clique para selecionar, autoataque, raposa pacífica até receber dano, fuga e revide da raposa, golpe anunciado do urso cancelado pelo cristal, 2.816 células de terreno, movimento, barreira da água e pausa. O teste de estado usa um diretório `user://mvp_solo_loop_<id>` único e deixa esses arquivos de teste no disco; ele não apaga saves.

Também foram executados `--headless --editor --import --quit` e a cena principal por 300 frames no Godot 4.5.1. Os templates ausentes no worktree inicial foram instalados durante a integração. Exportações e limitações de plataforma são registradas em [MVP_BUILD_VALIDATION.md](MVP_BUILD_VALIDATION.md); não houve teste em aparelho neste incremento.

## Controles e ciclo

- **WASD / setas:** andar. **Joystick:** andar por toque.
- **E / Interagir:** coletar o recurso mais próximo dentro do raio ou recuperar a mochila persistente. O botão muda para a ação disponível.
- **Clique / toque em criatura:** seleciona o alvo. O Warrior ataca automaticamente a curta distância; o botão Auto desliga ou religa essa ação.
- **1 / 2 / 3:** Combo, Corte Circular e Terremoto. Custo de MP, coeficientes, número de golpes, recarga e efeitos usam `data/catalogs/mvp.json`.
- **H / Curativo:** usa um curativo. Ele consome o item ao iniciar, restaura até 40 HP em quatro segundos e um ataque interrompe a cura.
- **B / Mochila:** abre inventário e fabricação. A receita do catálogo exige três ervas e uma fibra.
- **Refúgio:** recupera HP/MP e oferece melhorias quando o jogador está perto do cristal. Níveis II/III consomem os custos do catálogo.
- **Esc / P / Pausa:** pausa; pausa, retorno à sessão, retorno ao início, fechamento da janela e pausa de aplicativo salvam o estado.

Raposa foge enquanto pacífica e ataca quando provocada; lobo persegue ao entrar no alcance curto; urso é lento e anuncia o golpe. A área do cristal impede ataques recebidos e do jogador. No retorno solo após queda, materiais desta expedição podem ser deixados em uma mochila persistente.

HP/MP iniciais e atributos vêm do Warrior no catálogo; XP por coleta, níveis 1–10, XP de criatura, drops, receita, habilidades e melhorias derivam de `mvp.json`. Quantidades por nó, cadência básica e tempos de decisão da IA são parâmetros provisórios desta fatia, pois o catálogo não os define como balanceamento final. Cada morte de vida de criatura só paga XP/drop uma vez; probabilidades de drop seguem o catálogo.

## Save e recuperação

O slot guarda a aparência escolhida, posição, direção, zoom, HP/MP, nível/XP, inventário, coletas concluídas, inimigos e vida, ledger de recompensas, receitas, cooldowns, cura, acampamento e mochilas. O formato é schema 1 sob `user://worlds/solo/<aparência>/`, com temporário, slot ativo, slot anterior e checksum SHA-256. As gravações normais mantêm dois slots, após verificar o temporário, sem acumular um arquivo por autosave; cópias inválidas são preservadas para diagnóstico. Ao carregar, o jogo usa o snapshot válido de maior revisão ou apresenta erro e bloqueia mutações se nenhum slot passar na validação. Não há botão de apagar saves.

## Arte e limites desta fatia

**As três criaturas usam poses SE candidatas, estáticas e ainda não aprovadas.** Não há outras direções, espelhamento nem animações de idle, locomoção, ataque, dano ou morte. O loader deixa a criatura sem textura e emite aviso se PNG ou JSON estiver ausente; não cria sprite procedural.

Esta versão cobre somente a sessão solo local e a vocação Warrior. Não inclui rede/LAN/cloud, Archer, Mage, árvore completa, baú compartilhado funcional, poço, cerca ou torres em funcionamento. A tela de equipamentos mantém a estrutura da UI v0.7; não faz troca de equipamento. O mapa original, a composição de 56 tiles, a colisão e os controles existentes foram preservados.

Exportação APK/Web, inspeção visual no Godot, leitura em escalas reais e teste em aparelho seguem como gates de integração/aceite. Este incremento sozinho não declara S0/S1 nem o GDD MVP inteiros concluídos.
