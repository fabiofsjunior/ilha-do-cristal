# Journal — Diário de bordo

## 2026-10-14 — Organização de pré-produção

- GDD do MVP, catálogo de conteúdo, arquitetura Godot/Android, contrato de sprites, roadmap e concept RPG Clássico criados na branch `docs/gdd-mvp-producao`, PR #1 em rascunho.
- Processo adaptado a partir do resumo do vídeo MagmaDev fornecido pelo usuário: documentos persistentes em `Docs/Main/`, contexto volátil em `Docs/Context/`, regras operacionais em `AGENTS.md`, iteração mecânica/visual e assets simples determinísticos via Python/Pillow.
- Godot 4 escolhido em lugar de MonoGame porque o jogo requer export Android, tilemap, câmera, UI por toque, animação e LAN. Esta escolha é de projeto; nenhum código ou APK foi implementado ainda.
- Links locais de Markdown e PNG concept devem ser validados após a reorganização. Números de balanceamento seguem provisórios até playtest.

Modelo para próximas entradas: data, objetivo, branch/commit, arquivos relevantes, comportamento obtido, testes/dispositivos, falhas e decisões, próximo passo. Registrar fatos observados, não intenções como entregas.

## 2026-10-14 — Catálogo do MVP

- Organizadas doze listas em `Docs/Main/CATALOGS_MVP.md`, com versão de planejamento em `data/catalogs/mvp.json` e verificador de integridade. Valores provisórios permanecem assinalados.
- Ainda faltam os efeitos/IDs individuais de talentos e os parâmetros fechados de duração/colisão/defesa; serão definidos nos sprints que os implementarem após playtest.

## 2026-10-14 — ferramenta de revisão de sprites

Branch `feature/s00-melissa-sprite-test`, a partir de `docs/gdd-mvp-producao`. Lidos GDD, catálogos, arte, README, roadmap, arquitetura, handoff e AGENTS. Adicionado projeto Godot 4.5.1 técnico na raiz, cena de inspeção com seleção direção/idle/walk, pausa, frame, zoom50–125%, candidatos SQM32/48 e marcadores de célula/pés. Contratos JSON da etapa 1 (N/S, idle4/walk6) preparados. Não implementa gameplay/S0/Android; o roadmap permanece sem etapas concluídas. Validação final dos PNGs deve ser registrada após importação. Aprovação visual e aparelho Android seguem obrigatórios antes de lotes seguintes.

Validação técnica: Godot4.5.1 `--headless --editor --import --quit` e execução da cena passaram com os atlas candidatos. `check_scene.gd` verificou 80 seleções de frame: idle/walk × N/S × quatro zooms. Isso testa carregamento e contrato, não aparência. Validator detecta alpha intermediário nos candidatos e retorna falha esperada; status **corrigir**. Xvfb ausente; instalação local falhou por restrição setgroups, obtenção de pacotes remotos sem resposta. Não foi capturado viewport Godot nem testado Android.

## 2026-10-14 — revisão V2 e evidência renderizada

Continuada a mesma branch e PR #2. Gerada fonte conjunta com 20 poses de Melissa Warrior (N/S, idle 4 e walk 6), com câmera mais superior e volume mais consistente. Candidatos V2 preservam V1 e usam escala uniforme nos dois eixos, regiões fixas, células 96×96 e âncoras comuns por direção. Não houve geração das etapas seguintes.

Superado o bloqueio de captura: dependências Xvfb extraídas em scratch, sem instalação, com conexão TCP local. Godot 4.5.1/OpenGL llvmpipe renderizou 16 capturas de zoom e uma folha com todos os 20 quadros, disponíveis em `docs/art/evidence/godot_v2/`. A cena permite comparar V1/V2 e fundos claro/escuro. O teste de carregamento repetido na V2 passou 80 seleções; catálogo mantém 52 IDs válidos; diff sem erros de espaços. Diagnóstico de alpha/pivô atualizado. Validador continua falhando por bordas suavizadas: resultado registrado, sem aprovação artificial.

Estado: **corrigir**, não produção aprovada. Revisão de direção sul, contato dos pés, continuidade de passadas e acabamento pixel ainda necessária; teste Android não realizado. Captura desktop real supera a limitação anterior, mas não aprova legibilidade em aparelho. Próximo passo: corrigir os defeitos registrados no QA e repetir revisão, antes de oito direções ou variantes.

Uma correção focada V3 tentou sul simétrico, alternância clara das pernas e alpha binário, preservando identidade e escala. A ferramenta não resolveu esses requisitos: a revisão ainda identifica sul próximo de SE, a mesma bota à frente em grande parte da caminhada e contornos suavizados. V3 foi preservada para comparação, sem substituir a V2 preferida. A pedido do usuário, a revisão e integração seguintes foram delegadas a GPT-6 Luna com raciocínio máximo. Nenhuma expansão do lote foi iniciada.

A integração Luna importou as três versões e verificou 240 seleções de frame e 48 estados sincronizados dos seletores. V3 tem folha dos 20 quadros e quatro capturas representativas a 100% em `docs/art/evidence/godot_v3/`. Validador cobre seis atlas e continua reprovando alpha intermediário. O usuário solicitou reutilizar o aprendizado como skill: o fluxo de produção e correção está sendo registrado separadamente, com diagnóstico estrutural e aprovação artística/plataforma independentes.

## 2026-10-14 — metodologia de prototipagem MVP

Branch `docs/mvp-prototyping-gates`, baseada na branch de teste de sprites. A pedido do usuário, estabelecido um gate visual/navegável antes da implementação de cada fase S0–S6, incluindo prototipagem de telas, estados e transições e validação explícita do usuário. A regra foi adicionada às instruções centrais, ao roadmap e às decisões; procedimento e registro vivem em `Docs/Main/PROTOTYPING_METHODOLOGY.md` e `Docs/Context/PROTOTYPE_LOG.md`.

Criado protótipo navegável de interface com telas do GDD em `docs/prototypes/mvp_ui_v0_1.html`. Controles e dados são simulados, sem gameplay, conta, rede ou salvamento real; sprites são placeholders. Todas as telas estão pendentes de revisão do usuário. Nenhuma tela de produção foi implementada. O projeto de sprites permanece separado e em `corrigir`; Pixelorama não está disponível como aplicativo local neste workspace, e o editor web oficial observado não renderizou o canvas nesta sessão.

## 2026-10-15 — revisão de personagens e inventário

- A pedido do usuário, removidas idades das descrições de Melissa e Helena no GDD, catálogo Markdown e `data/catalogs/mvp.json`. O texto de Melissa reforça doçura, atenção e equilíbrio; o de Helena reforça carisma, inteligência, pavio curto e espontaneidade.
- Criado `docs/prototypes/mvp_ui_v0_2.html`, preservando a v0.1 como versão anterior. A tela de personagem mostra as novas descrições; o inventário propõe espaços de cabeça, peitoral, luvas, pernas, botas, arma, colar e dois anéis, além da mochila de 24 espaços, detalhes do item e fabricação.
- Slots de armadura e acessórios ainda não representam conteúdo aprovado: itens e atributos não constam do catálogo do MVP e aguardam validação antes de qualquer implementação. Nenhuma tela de produção foi implementada.
- Validações estruturais: `python tools/validate_catalogs.py` passou; parse do HTML e JSON, `node --check` do JavaScript e verificações de whitespace passaram.

## 2026-10-15 — protótipo técnico Maíra Warrior

- Com a aprovação explícita do usuário, Maíra foi registrada como terceira personagem jogável do MVP, irmã de Helena. GDD, catálogo Markdown/JSON, direção de arte, README, roadmap e tela de seleção foram alinhados. Conceito de três vocações guardado como referência; não foi recortado para produzir sprites.
- Criadas tiras candidatas no Pixel Engine para Maíra Warrior N/S: `idle` 4 quadros e `walk` 6. O empacotador `tools/art/pack_maira_stage1.py` monta atlas de 96×96, pivô candidato (48,80), sem redimensionar ou aparar células; máscara binária removeu alpha do fundo e contaminação magenta.
- Atlas e prancha de contato estão em `assets/characters/maira/warrior/` e `docs/art/evidence/maira/`. A revisão estática delegada a GPT-6 Luna max confirmou alpha binário e ausência de halo magenta evidente. Escala N/S difere (~8% na altura), idle é sutil e passada/pés/loop permanecem sem aprovação; estado **corrigir**.
- Criada cena isolada `tools/art/sprite_test/maira_stage1_test.tscn` com seleção de direção, animação, zoom, fundo e SQM. Revisão estática Luna max não encontrou bloqueio provável de GDScript; não houve execução porque Godot não está disponível neste ambiente.
- `python tools/validate_catalogs.py`, compilação Python, `node --check` do JS v0.3 e `git diff --check` passaram. O validador de atlas não acusa erros para Maíra; execução global ainda retorna os seis erros pré-existentes de alpha intermediário nos atlas Melissa V1–V3. Android não testado.
- Próximo passo: revisão do usuário da prancha técnica; depois corrigir o que for necessário e validar a cena no Godot antes de ampliar direções/vocações. Nenhum lote de produção adicional foi gerado.

## 2026-10-15 — teste técnico Fábio Warrior etapa 1

- Branch `feature/fabio-warrior-stage1`, baseada em `feature/maira-warrior-stage1`. O concept gerado aprovado de Fábio foi copiado integralmente para `assets/references/generated-candidates/fabio_vocations_concept.png`; não foi fatiado. Também foi arquivada a folha gerada para o teste como fonte bruta/candidata, não como arte aprovada.
- Não foi localizada decisão de inclusão de Fábio no elenco jogável do MVP; GDD/catálogo permanecem sem mudanças e a inclusão fica pendente. A descrição aprovada foi registrada junto ao concept.
- Gerados e empacotados somente Warrior N/S, `idle` 4 e `walk` 6, célula candidata 96×96, pivô candidato (48,80), redução uniforme nearest de células-fonte 256×256 para 72×72 e alpha preservado. Atlases, JSONs, empacotador e folha xadrez em `assets/characters/fabio/warrior/`, `tools/art/pack_fabio_stage1.py` e `docs/art/evidence/fabio/`.
- Medição objetiva da fonte RGBA 1536×1024: alpha 0–254, 255 valores únicos, 991.461 pixels transparentes, 581.403 pixels com alpha intermediário e zero pixels alpha 255. O alpha suavizado permaneceu intacto; a revisão estática mantém estado **corrigir** por acabamento/alpha intermediário, variação N/S de escala/alinhamento, idle sutil e continuidade/pés sem validação de engine.
- Pixel Engine não pôde gerar neste workspace (4 créditos disponíveis; mínimo de geração 6). Não há Pixelorama/Godot executável nesta sessão. O fallback image_gen produziu a grade bruta; não houve validação Godot, zoom/SQM em engine ou Android.
- Validações locais e resultado detalhado registrados em `docs/art/evidence/fabio/fabio_warrior_stage1_review.md`. Não foram gerados Archer/Mage, direções adicionais ou efeitos.

## 2026-10-15 — Fábio aprovado como personagem jogável do MVP

- O usuário aprovou Fábio como o quarto personagem jogável do MVP. GDD, catálogo Markdown/JSON, direção de arte, README, roadmap e decisões foram alinhados; ele é pai de Melissa e pode escolher Warrior, Archer ou Mage. A foto privada não foi incluída.
- Criados o protótipo navegável `docs/prototypes/mvp_ui_v0_4.html`, preservando a v0.3, e a cena técnica `tools/art/sprite_test/fabio_stage1_test.tscn` para comparar v1/v2, direção, animação, frame, zoom, SQM e fundos. A cena ficou sem execução por indisponibilidade do Godot.
- Fábio aparece no protótipo de seleção com placeholder geométrico; o protótipo aguarda validação explícita e não libera implementação de UI.
- Atualizada a validação do catálogo para exigir os quatro IDs (`melissa`, `helena`, `maira`, `fabio`). `python tools/validate_catalogs.py`, `node --check` do JS da v0.4 e `git diff --check` passaram. Nenhum arquivo de foto privada está rastreado.
- O PR #5 foi mantido em rascunho e sua descrição atualizada. Fábio Warrior etapa 1 continua **corrigir**; Godot/Android não foram validados. A revisão corretiva delegada a GPT-6 Luna com raciocínio máximo gerou uma v2 isolada: escala uniforme nearest 1,075× nas linhas norte, pivô candidato (48,80), alpha preservado e v1 intacta. A altura alpha ≥128 aproximou idle N/S de ~58/64 para 62/64 px; no walk, N/S ficou em 66 contra 63–64 px. O acabamento suavizado ainda deixa a arte em **corrigir**; o verificador estrutural de atlas reporta dez avisos conhecidos de alpha intermediário e nenhum erro de célula vazia/limite. Godot/Android continuam pendentes.
- Próximo gate: validar o protótipo v0.4 e revisar a correção técnica Warrior etapa 1 antes de qualquer ampliação.


## 2026-10-15 — árvore passiva candidata v0.5

- O usuário orientou uma rede de passivas com 25 círculos, 6 nós retangulares e três atores; em seguida pediu que os nós retangulares fossem quadrados ou círculos maiores. A v0.5 usa 25 círculos pequenos, 6 quadrados grandes e 3 origens em losango com figuras de ator e rótulo “Actor”.
- A malha distribuída conecta Warrior (alto), Archer (esquerda) e Mage (direita) por 61 ligações bidirecionais. Cada origem alcança os 34 nós. A tela permite selecionar nós para ver tipo, efeito, custo e estado e simular compra de nós adjacentes; pontos são separados por vocação e não persistem.
- Registradas no catálogo as 34 entradas candidatas e um roadmap visual de quatro etapas. Os 31 nós passivos custam 37 pontos no total; o nível 10 dispõe de 30. Os valores não substituem o plano vigente (100 por vocação/18 candidatos iniciais) até revisão explícita.
- Verificações estáticas no protótipo: sintaxe JavaScript, contagens (25/6/3), 61 conexões bidirecionais, sem IDs duplicadas ou pontas soltas, e conectividade completa desde as três origens. Catálogo JSON validado por parse; não houve execução em navegador, Godot ou Android neste ambiente.
- Próximo gate: revisão do usuário da árvore v0.5 e dos nomes/efeitos/custos candidatos. Nenhuma UI de produção foi implementada.


## 2026-10-15 — árvore conceitual v0.6

O usuário selecionou a imagem endgame anexada para orientar a estrutura do protótipo. O PNG foi validado (1672×941, RGBA) e salvo em `docs/prototypes/assets/passive_skill_tree_endgame_reference.png`. A v0.6 mostra essa imagem, lista nós para inspeção, alterna Warrior/Archer/Mage e simula níveis 1–10. Origem inicia desbloqueada; outros nós são liberados automaticamente por nível. A sequência de geração em 2/4/6/8/10 é ilustrativa e aguarda validação. A imagem conceitual não contém dados exatos de topologia; v0.5 foi preservada.


## 2026-10-15 — inventário e atributos v0.7

A pedido do usuário, o protótipo navegável ganha tela de inventário em três colunas: 12 slots de equipamento na matriz 4×3, 24 espaços de mochila e painel contextual à direita. A seleção de item troca o painel de atributos por detalhes, status/localização e ações de equipar/desequipar ou usar. O painel de atributos exibe descrições de FOR/AGI/INT, multiplicadores por vocação, efeitos por ponto e prévia de HP/MP máximo. A simulação inicia no nível 4 com 3 pontos livres; atributos brutos são zero e HP/MP base permanecem por vocação. O protótipo não salva progresso e segue aguardando revisão; a árvore e a referência v0.6 são preservadas.


## 2026-10-15 — candidata técnica Helena Warrior etapa 1

- A etapa foi limitada a uma aparência/candidata Warrior, direções N/S, `idle` 4 e `walk` 6. O GDD permite qualquer vocação para Helena sem default; Warrior foi usado apenas como suposição do primeiro exemplar.
- Validado o concept oficial intacto pelo Git blob SHA `82a60ab282c23d0e6846a10a2d8b5e8614537ac3`. Ele serviu apenas como referência de identidade; os quadros vêm de fontes geradas separadas.
- O GDD requer movimento em oito direções, mas não fixa pixel-cell/pivô. Para a etapa 1, o contrato do PR #5 e a direção de arte indicam N/S, 96×96 px, pivô candidato (48,80), idle4 e walk6; o tamanho e pivô ainda dependem de validação visual e em aparelho.
- Preservadas três fontes RGBA em `assets/references/generated-candidates/`; criados atlas e JSON em `assets/characters/helena/warrior/`, empacotador/verificador em `tools/art/` e prancha/relatório/diagnóstico em `docs/art/evidence/helena/`.
- Fonte idle é 1774×887, alpha 0–255 com 667.058 pixels intermediários; o atlas idle é 384×192 e tem 17.568 intermediários. Walk N e S são 1536×1024, alpha 0–254 com 518.795/518.217 pixels intermediários; o atlas walk é 576×192 com 20.476 intermediários e nenhum alpha 255. O alpha foi preservado; halo e bordas suaves mantêm a arte em **corrigir**.
- Validador estrutural passou para RGBA, dimensões, contagens, regiões, direções, células, metadados de pivô, concept e alpha≥128 sem tocar a borda; `py_compile` passou. O relatório registra boxes, pivô e deriva de até 18 px no centro dos quadros walk S. Esses checks não são validação artística nem provam contato dos pés.
- Sem execução Godot, zoom/SQM ou teste Android. Próximo gate: corrigir/refazer alpha e deriva, revisar ciclo/contato no motor, manter o escopo fechado até aprovação.


## 2026-10-15 — protótipo v0.7 validado e terreno MVP candidato

- O usuário validou o protótipo navegável v0.7 em 2026-10-15 (“Protótipos validado.”). O registro marca o protótipo de interface como aprovado; esse aceite não valida telas de produção, gameplay, sprites, Godot ou Android.
- Criada a candidata de terreno v1 em `assets/environments/terrain_mvp_candidate_v1/`: 56 tiles em célula candidata 32×32 (17 bases, 24 transições e 15 overlays de caminho), atlas 256×224. O tamanho não está congelado.
- Fonte e validação reproduzíveis em `tools/art/generate_mvp_terrain_tileset.py` e `tools/art/validate_mvp_terrain_tileset.py`; prancha de contato, amostra scripted e relatório em `docs/art/evidence/terrain/`. Nenhuma sprite de personagem foi alterada.
- Resultado estrutural: PNG RGBA, alpha apenas 0/255, 56 IDs/regiões válidas, base 17/transition 24/overlay 15, sem falha de borda nas superfícies repetíveis; Python compile e JSON parse passaram. Status permanece **CANDIDATO**, aguardando revisão visual, cena TileMap no Godot, zoom 50–125% e Android. A amostra não é render do motor.
- Próximo gate: importar em cena de QA Godot, examinar vizinhança costeira/caminho no tamanho real, testar aparelho; só então solicitar revisão/expandir. S0 e todas as sprites de personagens continuam com estados independentes e não aprovados.


## 2026-10-15 — auditoria orquestrada de arte

- Inspecionados AGENTS, GDD, catálogos, direção de arte, conceitos, assets, histórico e validadores. Cinco revisões isoladas (Fábio, Helena, Maíra, Melissa e terreno) foram coordenadas em worktrees detached, usando GPT-6 Luna com raciocínio máximo. Nenhuma branch remota temporária foi criada.
- Os quatro candidatos Warrior existentes têm somente `idle` e `walk` em oito direções. O contrato da direção de arte propõe também `attack`, `hit`, `death` e `cast`; esses estados e as vocações Archer/Mage não foram criados nesta auditoria.
- Não alteramos atlas raster: tentativas de edição generativa que mudaram a grade ou não removeram o halo foram descartadas. Defeitos que requerem redesenho quadro a quadro ficam pendentes para editor de pixel art com revisão manual. Maíra tem 12 fontes PNG malformadas/truncadas; o packer não consegue decodificá-las e não há cópia íntegra no histórico.
- Fábio: alpha suave/halo e fragmentos desconectados em células diagonais; ciclo e apoios não comprovados. Helena: alpha/halo e deriva de pivô/passada; o validador stage1 foi corrigido para listar exatamente três fontes e testar ausência. Maíra: E/W e diagonais inconsistentes, passada incerta e fontes inválidas. Melissa: alpha intermediário e poses de espada/passadas inconsistentes. Todos permanecem **CORRIGIR**.
- Terreno: prancha de contato e amostra nearest não mostraram falha demonstrável; o relatório foi atualizado. Os 56 tiles permanecem candidatos, aguardando TileMapLayer em Godot e Android.
- Ferramentas gratuitas pesquisadas: Pixelorama (recomendação para edição frame a frame e onion skinning), LibreSprite e Piskel. Nenhum editor ou Godot está instalado no runner; não foi feita captura no motor nem teste Android.
- Validações: atlas geral retornou 20 erros de alpha intermediário; Helena 8-dir passou estruturalmente com alertas; Helena stage1 passou após correção, com teste negativo de arquivo ausente; terreno passou **somente estruturalmente**; catálogos passaram (10 grupos/54 IDs); packer Maíra falha nas fontes inválidas; `git diff --check` passou.
- Relatórios de Maíra/terreno e validador Helena foram integrados em `feature/fabio-warrior-stage1` nos commits `35b17d7`, `e41c173` e `df35d71`. `main` permaneceu intacta; a lista remota observada contém apenas `main` e `feature/fabio-warrior-stage1`.
- Próximo gate: usar um editor gráfico para recuperar/refazer fontes inválidas e corrigir direções, alpha, passadas e âncoras; validar no Godot e em Android. Manter cada asset em **CORRIGIR/CANDIDATO** até evidência específica.

## 2026-10-15 — retoques de pixels e revalidação

- O usuário autorizou cinco frentes isoladas (Fábio, Helena, Maíra, Melissa e terreno) e uso de editores gratuitos como Pixelorama, LibreSprite ou Piskel. Nenhum agente aplicou um editor GUI nesta rodada; onde houve correção, foram seleções pixel a pixel delimitadas, reproduzíveis e revisadas em tamanho nativo/nearest. Nenhuma saída generativa substituiu os atlas.
- Fábio v3: oito caixas manuais removeram artefatos vermelhos desconectados em idle SW/NW e walk SE/SW; a comparação antes/depois de SW walk quadros 2 e 5 confirma a remoção. Foram preservados fontes, v1 e v2. Alpha intermediário, halo e ciclo/pivô seguem pendentes.
- Helena: nenhum retoque raster foi considerado seguro nesta rodada. A auditoria visual das oito direções mantém dúvidas de passada e pivô; validadores estruturais passam com alertas de alpha e alinhamento.
- Maíra: nenhuma correção raster. As 12 fontes PNG das direções novas falham ao decodificar (IDAT truncado); ângulos E/W/diagonais e ciclo de passada do atlas v2 seguem sem aprovação.
- Melissa: foi preservado o candidato v1 e criado v2 com remoção de dois pixels desconectados alpha=1 em N/idle/quadro 2. Alpha/halo nas demais bordas, variação da espada, direção sul e passadas seguem pendentes.
- Terreno: mantidos 56 tiles; além da correção do caminho fora da máscara, foram alinhadas junções de canto. A prancha 3×3 foi revisada em nearest; contraste no solo e integração no TileMap ainda aguardam Godot/Android.
- Commits integrados na branch `feature/fabio-warrior-stage1`: `2e560a0` (overlay do terreno), `a95e66d` (cantos do terreno), `e40b5a2` (Melissa v2), `d811261` (Fábio v3). Nenhuma alteração foi feita em `main`.
- Revalidação: `validate_sprite_atlases.py` falha com 21 entradas de alpha intermediário; `validate_helena_8dir.py` passa estruturalmente com alertas; `validate_helena_stage1.py` passa estrutura mas registra 17.568 pixels intermediários em idle e 20.476 em walk; `validate_mvp_terrain_tileset.py` passa estrutura e junções (56 tiles, alpha 0/255); catálogos passam (10 grupos/54 IDs). Godot, Android e inspeção em motor permanecem pendentes; os candidatos seguem **CORRIGIR**, terreno **CANDIDATO**.
- `git ls-remote --heads origin` confirmou somente `main` e `feature/fabio-warrior-stage1`; não havia branches remotas antigas para excluir. Os novos commits locais ainda aguardam tentativa de push.
- Próxima ação: recuperar ou refazer as fontes truncadas de Maíra, continuar a correção manual dos contornos e ciclos em editor de pixel art e concluir revisão Godot/Android antes de qualquer status de produção.

## 2026-10-15 — primeira fatia jogável desktop

- Iniciada em worktree isolada `feature/s01-gameplay-slice`, baseada exatamente no HEAD local `16e759350ad9a3f76ded314e0050a820939b3a5f` da `feature/fabio-warrior-stage1`. A worktree base permaneceu limpa; não houve branch remota, cherry-pick ou push.
- Confirmado no Journal e no registro do protótipo que o usuário validou explicitamente a UI navegável v0.7 em 2026-10-15. O código segue abertura → escolha de aparência Warrior → “Criar/entrar na ilha” → gameplay; “Hospedar solo” entra localmente e “Entrar” dá erro mockado recuperável; pausa retoma, volta à sessão ou ao início.
- Criados scenes/scripts de roteamento, seleção de quatro aparências candidatas, sessão, pausa, mapa e jogador. A movimentação de oito direções lê WASD/setas e o joystick touch; há botão touch de pausa/interação, zoom 50–125%, câmera sem smoothing/nearest/pixel snap, colisão com água, bordas, árvores e pedras placeholder, além de cristal interativo somente demonstrativo.
- Primeiro mapa estático tem 64×44 células candidatas de 32 px e compõe os 56 IDs do atlas existente: 17 bases, 24 transições, 15 overlays. A estrutura mantém todas as 17 variações base, as 24 transições e uma rede conectada usando cada overlay uma vez. O terreno segue **CANDIDATO**.
- As quatro aparências usam atlas Warrior já existente e metadata atual; idle 4 quadros/6 FPS e walk 6 quadros/10 FPS em N, NE, E, SE, S, SW, W, NW. O loader aceita metadata plana e `animations.idle/walk` (formato da Helena). Nenhum PNG de personagem foi reprocessado; todas permanecem **CORRIGIR**, `approved:false`.
- `project.godot` agora inicia `game/scenes/main.tscn`; o harness QA técnico segue disponível em `tools/art/sprite_test/`. README, Roadmap, DECISIONS, Handoff e `docs/gameplay/PLAYABLE_SLICE.md` descrevem o recorte. O Roadmap marca subitens de código, mas mantém S0/S1 incompletos até importação, execução e aceite Android.
- Validações: `python3 tools/gameplay/validate_playable_slice.py` passou (18 cenas/scripts resolvidos, 8 animações de metadata, 56 IDs e nenhuma alteração em PNG de personagem); `python3 tools/art/validate_mvp_terrain_tileset.py` passou estrutura/composição e manteve Godot/Android pendentes; `python3 tools/validate_catalogs.py` passou (10 grupos/54 IDs); `python3 -m py_compile tools/gameplay/validate_playable_slice.py` e `git diff --check` passaram.
- `python3 tools/art/validate_sprite_atlases.py` segue com saída 1 e 21 erros conhecidos de alpha intermediário nos atlas candidatos. Isso mantém o status **CORRIGIR** e não representa aprovação visual.
- O runner não tem `godot`, `godot4`, `adb` ou executável Android; não foi possível fazer import/run no motor, captura Godot, build APK ou teste de dez minutos no aparelho. O `gdtoolkit` 4.5.0 foi instalado temporariamente em `/tmp` somente para parse/lint estático: todos os scripts GDScript passaram. Uma inspeção Pillow/layout confirmou os elementos do mapa, mas não é render do Godot. Esses gates ainda bloqueiam conclusão de S0/S1. LAN, contas, saves, inventário funcional, combate e progressão não foram simulados como funcionalidades existentes.
- Commit local de implementação: `032f4266448a7c1f8cd8acbffc962aa6f124a6d8` (`feat: add playable local gameplay slice`). Este registro e o Handoff recebem uma atualização documental subsequente na mesma branch; o commit de gameplay é identificável sem cherry-pick ou push.
- Integração concluída localmente em `feature/fabio-warrior-stage1`: `b1c66a5` traz a fatia, `b8339e6` registra o checkpoint documental e `63511d3` atualiza este estado de integração. `main` permaneceu intacta; os commits locais ainda não foram enviados a `origin`.
