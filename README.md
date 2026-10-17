# A Ilha do Cristal

RPG 2D cooperativo de sobrevivência em pixel art. Melissa, Helena, Maíra e Fábio sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado:** recorte solo para teste, em Godot 4.5.1, com exportadores Web e APK Android debug. Importação, fluxo e regras são verificados em modo headless; revisão gráfica no navegador e instalação/teste em Android continuam pendentes. **Arte:** personagens e criaturas seguem **CORRIGIR**, terreno **CANDIDATO**. A [prancha conceitual](assets/references/concept-rpg-classico.png) é referência visual.

A cena principal é `game/scenes/main.tscn`. O fluxo percorre início → uma das quatro aparências Warrior → sessão solo → ilha 192×132, com movimento, coleta, raposa/lobo/urso, ataque automático ao alcance, três habilidades Warrior, curativo, XP, inventário de materiais e melhorias de acampamento. O save local separa as quatro aparências e usa slots com checksum e recuperação. Consulte [guia do teste solo](docs/gameplay/MVP_SOLO_TEST.md) e [validação das builds](docs/gameplay/MVP_BUILD_VALIDATION.md). Contas, LAN, Archer/Mage, árvore completa e mundo procedural continuam pendentes; esta entrega não fecha o aceite integral do GDD.

## Testar e exportar

- **Web:** extraia `build/ilha-do-cristal-web.zip` e execute `Testar_Jogo_Web.bat` no Windows, com Python 3 instalado. O ZIP inclui o servidor; não depende do checkout. Em outro sistema, rode `python3 -m http.server 8000` na pasta extraída e abra `http://localhost:8000/`.
- **Android:** instale `build/android/ilha-do-cristal-debug.apk`. É o APK debug 0.1.7 para ARMv7/ARM64, Android 7 ou superior, em retrato. O launcher mostra o ícone pixel art do cristal e o nome **A Ilha do Cristal**; a assinatura debug não é de publicação.
- **Controles:** WASD/setas ou joystick; suas oito direções seguem os eixos da câmera 2.5D. Clique/toque na criatura para selecionar; E interage/coleta; 1/2/3 usam skills; H usa curativo; B abre mochila; Esc/P pausa. Os botões da tela oferecem as ações touch. Zoom 50–125%.

Ao cair, a tela mostra o prazo de 60 s para reanimação e a quantidade real de cada material que irá para uma mochila persistente se o jogador renascer no acampamento; XP e equipamentos permanecem. Um aliado reanima em 5 s pelo contrato local da sessão, mas esta build solo ainda não implementa LAN ou conexão de aliados.

Após 8 s sem atacar nem receber dano, HP e MP regeneram fora de combate a 1,2× das taxas base e dos bônus de FOR/INT. As taxas em combate não mudam; os caps existentes e o clamp ao máximo continuam valendo.

Com Godot 4.5.1 e os templates correspondentes instalados:

```sh
python3 tools/build/export_web.py
python3 tools/build/export_android.py
```

O guia [ANDROID_BUILD.md](docs/technical/ANDROID_BUILD.md) fixa SDK/JDK, configuração e verificações. Binário Godot local, SDK, chaves debug, saves e `build/` ficam fora do Git.

## Documentação

- [GDD do MVP](Docs/Main/GDD_MVP.md) — regras e critérios de aceite.
- [Conteúdo e balanceamento](Docs/Main/CONTENT_DATA.md) — atributos, armas, XP, drops, bestiário e árvore.
- [Doze listas de produção](Docs/Main/CATALOGS_MVP.md) e [catálogo JSON](data/catalogs/mvp.json) — conteúdo inicial versionado.
- [Roadmap](Docs/Main/ROADMAP.md) — sprints e validações.
- [Metodologia de prototipagem](Docs/Main/PROTOTYPING_METHODOLOGY.md) — protótipo e validação antes de cada fase.
- [Registro de protótipos](Docs/Context/PROTOTYPE_LOG.md) e [protótipo navegável v0.7](docs/prototypes/mvp_ui_v0_7.html). A v0.7 foi validada como interface simulada em 2026-10-15; isso não valida gameplay, arte ou dispositivos. A referência conceitual da árvore está em [passive_skill_tree_endgame_reference.png](docs/prototypes/assets/passive_skill_tree_endgame_reference.png).
- [Handoff](Docs/Context/HANDOFF.md) e [Journal](Docs/Context/JOURNAL.md) — continuidade entre sessões.
- [Arquitetura](docs/technical/ARCHITECTURE.md) e [arte/sprites](docs/art/ART_DIRECTION_AND_SPRITES.md).
- [AGENTS.md](AGENTS.md) — regras de implementação e revisão.

Estrutura: `game/` (cenas, scripts e dados), `data/` (catálogo versionado), `assets/` (arte candidata e referências), `Docs/Main/` (referência durável), `Docs/Context/` (journal/handoff), `docs/art/` e `docs/technical/`. O harness técnico de sprites permanece em `tools/art/sprite_test/sprite_test.tscn`. Relatórios de criaturas e [prancha nativa/nearest](docs/art/evidence/creatures-contact-candidates.png) documentam uma pose SE estática por animal; direções, animações e alpha final não estão aprovados.

Não publicar fotos originais das crianças, credenciais, keystores ou saves pessoais. A prancha conceitual não substitui sprites de produção.

## Ajuste do alvo: retrato 0.1.6

A versão de teste mais recente usa **retrato 9:16**, mundo em tela inteira com expansão para outras proporções, HUD inspirado no protótipo enviado, alvo destacado/trocável e dano numérico flutuante. A seleção agora aparece como uma pequena elipse pixel art dourada no chão, alinhada aos pés do inimigo; deixou de ser um arco vertical grande no celular.

Builds: `python3 tools/build/export_android.py` e `python3 tools/build/export_web.py` com Godot 4.5.1. O Web solicita tela cheia ao entrar como visitante, conforme suporte do navegador; o canvas preenche o viewport mesmo sem permissão. APK debug 0.1.7/versionCode 8. O HUD ocupa o viewport completo; joystick e curativo ficam no canto inferior esquerdo, spells e interação no direito. Áreas seguras incompatíveis com o viewport são descartadas para impedir que controles sumam fora da tela. Teste em aparelho físico continua pendente. Detalhes e verificações: [validação retrato](docs/gameplay/PORTRAIT_BUILD_VALIDATION.md).

## APK Android 0.1.7

O APK atual é 0.1.7/versionCode 8 e inclui o joystick ampliado, janela de atributos, restauração de HP/MP ao subir de nível, mapa 192×132 e correções de contato/ataque básico. Os testes e o hash estão em [validação das builds](docs/gameplay/MVP_BUILD_VALIDATION.md). O ZIP Web ainda corresponde à exportação anterior.

O HUD pixel usa a prancha escolhida pelo usuário em `assets/ui/pixel_hud_v1/`, com recortes por metadados e valores/captions dinâmicos.

## Revisão visual candidata — 2026-10-16

Câmera próxima (150–300%, padrão200%), smoothing5 e HUD adaptativa: rosto ampliado, minimapa com posição, alvo oculto sem seleção e habilidades compactas. Chão e elementos com profundidade oblíqua, mantendo coordenadas e colisões32px. Não é conversão isométrica64×32. Ver `Docs/Context/HANDOFF.md` para limites da base recuperada e validação pendente.

Renascimento:15segundos após derrota, jogador a mais de5SQMs da origem, fora do refúgio. Visibilidade da câmera não bloqueia renascimento.


### Visão 2.5D com Camera3D

A cena apresenta a ilha numa Camera3D ortogonal, X−30°/Y45°, size inicial16 e suavização speed5. O terreno usa o plano XZ e os atores recebem projeção Sprite3D; lógica, colisões e saves ainda operam em SQMs 2D. Consulte game/scripts/world/isometric_3d_view.gd. Render real em navegador/dispositivo permanece pendente.

## Correção visual 0.1.7

Inventário em duas colunas (equipamento/personagem e mochila de 24 slots), ícones originais para materiais/equipamentos, molduras metálicas e cartões de pergaminho para FOR/AGI/INT. O personagem ocupa uma área maior nos painéis; nomes e quantidades permanecem dinâmicos. O botão de atributos usa um livro pixel art. O terreno continua tropical e a identidade das quatro aparências foi preservada.

Corrigida a conversão do pivô 2D para Sprite3D, com inversão do eixo Y e pés acima da superfície; props mantêm profundidade. A câmera considera seu frustum projetado no chão para não revelar vazio nas bordas. O minimapa agora representa a ilha inteira 192×132 e mostra monstros vivos em pontos vermelhos.

Capturas reais e testes: [validação 0.1.7](docs/gameplay/MOBILE_UI_017_VALIDATION.md). Para instalar ao lado de uma build assinada por outra chave debug, use `python3 tools/build/export_android.py --parallel-install --output build/android/ilha-do-cristal-0.1.7-teste.apk`. Essa variante usa `.preview`, mantém a instalação anterior e tem progresso separado. O preset normal continua usando o package original.
