# Journal — Diário de bordo

## 2026-10-18 — descoberta do Godot no launcher Web

- Corrigido o caso em que `Testar_Jogo_Web.bat` falhava ao exportar `build/web/` porque o Godot 4.5.1 não estava no `PATH`. O exportador também procura executáveis em pastas comuns do Windows, lê `GODOT_BIN` e um caminho local salvo em `.godot-path`.
- Se o Godot não for localizado, o launcher abre o seletor de arquivos do Windows; depois de selecionado, verifica que a versão é 4.5.1 e guarda o caminho localmente. O arquivo fica ignorado pelo Git. A mensagem de exportação agora diferencia a ausência do executável de uma falha dos templates.
- Verificação: `py_compile`, smoke test de resolução via `GODOT_BIN` e `.godot-path`, `tools/wiki/test_catalog.py` e `git diff --check` passaram. Não foi possível abrir o seletor nem exportar a build neste ambiente Linux, sem Godot 4.5.1; confirmar no Windows com o executável e templates Web instalados.
- Branch `feature/s12-web-godot-discovery`; PR #27 foi integrada em `Staging` no commit `183373acb9a86726dee0cf010ed2c024fed25a48`. README, checklist do launcher e handoff foram atualizados. O ajuste não altera o jogo nem fecha a revisão gráfica Web.

## 2026-10-17 — handoff final e integração das PRs #15–#19

- Revisados README e Handoff para refletir o estado integrado de `main`: queda por 60 s, metade de cada pilha de materiais na mochila (arredondada para baixo), renascimento manual/automático no acampamento, reanimação de aliado apenas pelo contrato local sem LAN, contato por footprint visual, movimento relativo à câmera e regeneração fora de combate a 1,2×. A wiki offline permanece ligada ao catálogo e ao índice de arquivos.
- Registro dos merges: PR #15 `2aab5f4` (código `b1d0768`), #16 `38728f0` (`e3ab242`), #17 `54275e1` (`030273f`), #18 `f64c207` (`89d60a4`) e #19 `6cfc9f1` (`c995dfa`). A documentação desta revisão parte da main após #19; para trabalho futuro, consultar `git fetch origin` e `git rev-parse --short origin/main` em vez de reusar hash local.
- A build 0.1.7/versionCode 8 foi rotulada como histórica, anterior às mudanças das PRs #15–#19 e não recompilada com elas. A Web foi exportada a partir de `main`; a revisão gráfica no navegador continua pendente. APK atual bloqueado neste ambiente pela ausência do Android SDK Platform 35 e Build Tools 35.0.0; instalação e teste em aparelho físico permanecem pendentes.
- Próxima ação registrada no Handoff: instalar/configurar os componentes Android, consultar o SHA atual de `origin/main`, exportar e validar APK, depois testar em aparelho queda/renascimento/mochila, movimento, contato, regeneração e touch; revisar Web no navegador.
- Validação documental: `python3 tools/wiki/build_index.py` regenerou `docs/wiki/catalog-data.json` com 74 previews e 368 arquivos; `python3 tools/wiki/test_catalog.py` passou (contagens, caminhos/links, busca, filtros, paginação, JS e servidor HTTP local); `git diff --check` passou. A checagem local confirmou que `/opt/android-sdk/platforms/android-35` e `/opt/android-sdk/build-tools/35.0.0` estão ausentes, portanto não houve exportação Android.

## 2026-10-17 — wiki local de catalogação (PR #19)

- Branch de origem `feature/s03-game-wiki`, baseada em `f64c207` (main após PR #18); integrada pela PR #19 (`c995dfa`, merge `6cfc9f1`). Criada wiki HTML responsiva, sem dependências externas, em `docs/wiki/`: seções de personagens/vocações, sprites/atlas, atributos, itens, habilidades/combate, mundo/criaturas e documentação; busca global; previews ampliáveis; índice de caminhos relativos.
- `tools/wiki/build_index.py` deriva o JSON do catálogo do arquivo `data/catalogs/mvp.json`, do layout/aparências do recorte e dos PNGs/metadados versionados. A wiki identifica o catálogo como planejamento provisório e não anuncia candidatos de arte como aprovados.
- README e roadmap apontam para a consulta local. Validação: `python3 tools/wiki/test_catalog.py` confere contagens e caminhos, sintaxe JS, breakpoints/markup e respostas HTTP de HTML/CSS/JS/JSON/PNGs por servidor local.
- Escopo exclusivamente de catalogação; nenhum comportamento ou dado de runtime do jogo foi alterado. Aceites mobile e estado de arte permanecem pendentes conforme roadmap.

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

## 2026-10-15 — Godot 4.5.1 e smoke test da primeira fatia

- Baixado o binário oficial Godot 4.5.1 Linux x86_64 para a raiz do repositório, conferida a versão `4.5.1.stable.official.f62fdbde1`. O executável está excluído apenas localmente via `.git/info/exclude`; não será incluído no Git.
- A primeira importação revelou 12 fontes PNG truncadas em `assets/references/generated-candidates/maira_warrior/`. Uma auditoria leu os blobs versionados e confirmou que `HEAD`, `main` e `origin/feature/fabio-warrior-stage1` têm os mesmos bytes; não foi encontrada cópia íntegra nos worktrees. Como são referências sem dependência de runtime, `.gdignore` isola essa pasta da varredura do Godot. A alteração não repara as imagens nem aprova Maíra; o empacotador e o trabalho artístico continuam bloqueados até restaurar/refazer fontes completas.
- `Godot --headless --editor --path . --import --quit` passou sem warnings/erros após o isolamento, incluindo importação em uma cópia limpa sem cache ou sidecars `.import`. `Godot --headless --path . --quit-after 300` iniciou a cena principal sem erro. Criado `tools/gameplay/smoke_playable_slice.gd`: o teste percorre menu → seleção → sessão → ilha, carrega as quatro aparências Warrior, verifica 2.816 células base e caminho, move o jogador pelo joystick, confirma colisão da água e percorre pausa/retomada/volta à sessão/volta ao início. Passou.
- `tools/art/sprite_test/check_scene.gd` passou: 240 seleções de quadros e 48 estados de controles para V1/V2/V3. Isso comprova o loader, não aprovação visual.
- Validadores: gameplay passou (18 referências de cenas/scripts, quatro atlas idle/walk e composição 56 tiles); terreno passou estrutura/junções (56 tiles, alpha 0/255), revisão Godot visual/Android pendente; catálogos passaram (10 grupos, 54 IDs); Helena 8-dir e stage1 passaram estruturalmente com avisos de alpha/pivô e status **CORRIGIR**. `validate_sprite_atlases.py` segue com saída 1 por 21 atlas com alpha intermediário; personagens permanecem **CORRIGIR** e terreno **CANDIDATO**.
- O runner não oferece servidor gráfico para comparação em tamanho nativo/nearest nem aparelho/SDK Android. S0/S1 continuam incompletos até revisão visual, comparação com v0.7 e teste/export Android. `main` não foi alterada e não houve push.

## 2026-10-15 — launcher local para a build Web

- Adicionado `Testar_Jogo_Web.bat` na raiz para iniciar o servidor e abrir a build exportada no navegador. O script Python em `tools/web/serve_web_build.py` valida os arquivos HTML/JS/WASM/PCK, serve somente em loopback, usa a porta 8000 ou escolhe outra se ocupada e encerra com Ctrl+C. Requer Python 3.
- Adicionado `--no-browser` para validar o servidor sem abrir janela. A build continua em `build/web/`, ignorada pelo Git; `export_presets.cfg` e as instruções de uso ficam versionados.
- A revisão gráfica no navegador segue pendente neste runner; a ferramenta abre a build para validação no computador do usuário. S0/S1 e arte mantêm os estados anteriores.

## 2026-10-16 — recorte solo, criaturas e pacotes APK/Web

- Atendido o pedido de continuar o MVP com APK/Web testáveis e delegar raposa, lobo e urso. Cinco frentes GPT-6 Luna, esforço máximo, trabalharam em worktrees detached: três criaturas, gameplay e Android. Não foram criadas branches remotas temporárias.
- Integrados candidatos SE estáticos de raposa/lobo (96×96, pivô 48,80) e urso (128×128, pivô 64,108), fontes brutas, empacotadores, relatórios e previews nativos/nearest. Revisão do orquestrador confirmou a leitura básica. Alpha parcial persiste (1.147/1.659/4.158 pixels), sete direções e ciclos finais estão pendentes. Os três continuam CORRIGIR/approved:false; o validador conjunto separa estrutura de `--strict-art`.
- O loop solo usa quatro aparências Warrior: coleta, receita/uso de curativo, alvo e autoataque, três skills, IA distinta, área protegida, XP, materiais, camp II/III e retorno solo com mochila. Save schema1 por aparência usa checksum, temporário e slot anterior. A revisão corrigiu raposa atacando sem provocação, golpe do urso dentro do refúgio, HUD bloqueando clique, deslocamento além do pivô e checksum int/float; a integração limitou gravações normais a dois slots para evitar acúmulo de arquivos.
- Import, boot 300 frames, smoke de cena e teste de estado/recovery passaram no Godot 4.5.1. O smoke usa evento de ponteiro, testa coleta, autoataque, IA, segurança do urso, quatro aparências, 2.816 células, colisão e pausa. Teste de estado confirma receita, cura 40/4s/interrupção, prêmio único, camp II/III, rotação repetida e recovery após checksum adulterado. Harness de sprites passou 240 seleções e 48 estados.
- SDK/JDK/templates foram preparados. Ativada importação ETC2/ASTC e refeita a importação. O primeiro Web falhou por ausência de `web_nothreads_*.zip`; instalados os dois templates corretos do pacote oficial 4.5.1 e a exportação passou. O APK registra visivelmente o aviso conhecido de ícone ausente; o exportador recusa outros ERROR/SCRIPT ERROR, inclusive com saída zero.
- Gerados ZIP Web portátil de 12.434.884 bytes e APK debug de 59.550.750 bytes, ambos a partir do checkpoint de código remoto `bbba04f8d278f141cef7cb431dbecd22d1c02c49`. Hashes, comandos, lista de arquivos e limites estão em `docs/gameplay/MVP_BUILD_VALIDATION.md`. Builds, SDK, engine, chaves e saves permanecem fora do Git.
- Web: CRC, compilação WASM no Node, smoke do PCK extraído em diretório sem checkout e servidor portátil HTTP/MIME/Ctrl+C passaram. APK: manifesto paisagem, min24/target35, ARMv7/ARM64, nenhuma permissão, assinatura v2/v3, CRC e dados runtime passaram. Não houve execução gráfica Web nem instalação Android: navegador local foi bloqueado, navegador remoto não acessa este localhost, e não há aparelho/emulador/KVM. Esses testes não fecham S0/S1/S2.
- Catálogos, fatia e terreno passaram estrutura; Helena passou estrutura com alertas. Validador geral de atlas continua falhando em 21 candidatos por alpha; strict-art das criaturas falha por alpha/direções/animações. Personagens continuam CORRIGIR, terreno CANDIDATO e 12 fontes antigas de Maíra seguem truncadas.
- Código/arte/exporters publicados em `feature/fabio-warrior-stage1` pela conexão GitHub autenticada, com árvores Git conferidas contra os commits locais. `main` permaneceu em `b3d3f9a0f9405dae020d04785069b55c702f6894`; o conjunto remoto contém somente main e a branch de trabalho. README, roadmap, decisões, registro do protótipo e handoff descrevem o recorte sem promover arte ou declarar o GDD completo.
- Próxima ação: testar os pacotes no navegador e em Android real, comparar HUD/mapa com v0.7 e fechar/reabrir saves; depois corrigir arte e ampliar o conteúdo conforme os gates pendentes.

## 2026-10-16 — HUD retrato e seleção/dano

Retomada a branch jogável em `d0abbb6`, preservada main. Incremento em `feature/s02-portrait-combat-hud`: retrato 720×1280, expand sem letterbox, Android imersivo e safe area apenas nos controles; entrada web solicita fullscreen por gesto quando suportado. HUD com retrato, HP/MP/EXP numéricos, retrato/HP do alvo, ações circulares e joystick. Seleção por corpo corrigida por zoom, anel/barra e botão Trocar alvo. Os controles raiz do router agora ignoram mouse, removendo bloqueio invisível de cliques. Menus, escolha 2×2, mochila e refúgio adaptados ao retrato. Joystick é liberado ao pausar e bloqueado por painéis.

Dano flutuante parte do HP efetivamente removido, em todo take_hit (básico, skills, sangramento, fatal) e dano ao jogador; efeito independente da vida do monstro, com tween/limpeza e escala compensada pelo zoom. Nenhum PNG de personagem foi modificado.

Testes: import Godot sem erros de script; smoke completo menu/aparência/sessão/mundo/movimento/IA/seleção/pausa passou; estado solo/save/recovery passou (warnings de corrupção esperados); catálogos e validador de recursos passaram. Regressão nova verifica limites de painéis/botões em 3 viewports, toque em 4 zooms, retenção/ciclo do alvo e números recebido/causado/fatal/limpeza. Render Godot OpenGL/Mesa em Xvfb passou e captura inspecionada. Teste antigo agora define tamanho real da janela em headless e posiciona a raposa no campo visível; baseline do validador atualizado ao commit de origem existente.

Export final e evidência Web/APK descritos em `docs/gameplay/PORTRAIT_BUILD_VALIDATION.md`. Não há aparelho Android conectado; aceitação de toque físico, recortes de fabricante e estabilidade de 10 minutos continua pendente.

Entrega técnica concluída: builds 0.1.1 do commit `b02cf9c`, APK assinado/manifesto portrait/CRC/runtime aprovados; ZIP Web e compile WASM aprovados. Tentativa WebGL em Chromium bloqueada por socket do ambiente. PR #10 aberta sobre a branch jogável. Hashes completos em `PORTRAIT_BUILD_VALIDATION.md`; pacote Web inclui o launcher local. Não houve teste Android físico nem validação WebGL/IndexedDB.

## 2026-10-16 — Prancha pixel HUD selecionada pelo usuário

Solicitação explícita de colocar a prancha pixel art no repositório e substituir o HUD autoriza a integração dessa referência. Fonte `assets/ui/pixel_hud_v1/source_sheet.png` preservada byte a byte; regiões AtlasTexture em `regions.json` para barras, molduras, spells, joystick e navegação. Textos/HP/MP/EXP/cooldowns continuam valores reais do jogo, não números pintados na imagem. Barras recompõem o preenchimento para esconder os valores ilustrativos da fonte. Ícones em nearest com legendas compactas. Import, regressão de retrato e render Godot/Mesa passaram. Android físico segue pendente. Prancha é referência gerada com algumas junções entre peças, registradas no manifesto, sem aprovação implícita de todo o restante da arte.

## 2026-10-16 — Visão próxima oblíqua e HUD compacta (candidata)

Referência: anexos image(20261016-162830).png (estado anterior) e image(20261016-162915).png (objetivo). Pedido explícito autoriza implementar essa direção.

Mudanças: zoom lógico 150–300%, padrão200%, normalizado pelo lado curto do viewport; smoothing5; HUD de rosto, alvo somente selecionado, sem botão Auto ON; minimapa com posição real; controles reancorados e modais escalados em paisagem/retrato. Chão contínuo com bordas orgânicas, faces de relevo decorativas, props com pivô e Y-sort. Sprites de personagens e regras de combate/save preservadas.

Limites: top-down oblíquo com profundidade visual, não transformação isométrica64x32, nem reprodução integral do lago/ruínas. Arte candidata. Checkout recuperado do GitHub (branch feature/s02-pixel-hud-assets); alterações não publicadas de sessões anteriores não estavam disponíveis. Não afirmar que esta build contém regeneração/XP10x/inventário novos de outro checkout.

Verificações: Godot4.5.1 import e smoke de fluxo/coleta/combate/movimento; test_close_view em1280x720,720x1280,1920x1080; catálogo54 IDs; diff-check. Render gráfico bloqueado pelo ambiente (Xvfb não consegue criar sockets); Android físico e WebGL pendentes. Preview terrain é composição offline, não screenshot do jogo.

## 2026-10-16 — Renascimento corrigido

Monstros renascem após15s quando o jogador está a mais de5SQMs (160px) do ponto de origem. Removido bloqueio por visibilidade da câmera; refúgio permanece protegido. Teste test_respawn_radius.gd passou: prazo, distâncias0/159/160/161px e ausência de renascimento duplicado.

## 2026-10-16 — Migração da apresentação para Camera3D

O usuário reafirmou que quer manter Camera3D ortogonal. Cena Isometric3DView: terreno renderizado como superfície no plano XZ, câmera X−30°/Y45°, size inicial16, zoom por Camera3D.size, seguimento com lerp exponencial speed5. Props, cristais, jogador, criaturas, recursos, alvo e dano têm proxies 3D; seleção usa projeção de tela; HUD/minimapa seguem no CanvasLayer. A lógica 2D, colisões e save preservam SQMs.

Verificação Godot4.5.1: import e smoke jogável, test_close_view (três proporções), test_portrait_combat (toque/ciclo/dano em quatro tamanhos ortogonais) e test_respawn_radius passaram. Render em dispositivo e inspeção WebGL seguem pendentes; sprites permanecem candidatas. Ângulo X negativo é necessário para apontar para baixo na Godot.

## 2026-10-16 — Ícone e controles mobile 0.1.2

- Gerados ícones launcher clássicos/adaptativos/monocromáticos, derivados do cristal pixel art do projeto; rótulo Android confirmado como “A Ilha do Cristal”. Preset incrementado para versionCode 3 / 0.1.2.
- Corrigido o cálculo da área segura no `CanvasLayer`: o HUD agora usa origem e tamanho positivos mapeados do safe rect físico para o viewport. Antes os offsets direito/inferior negativos podiam encolher o retângulo e deslocar controles para fora da tela.

## 2026-10-16 — Reposicionamento touch 0.1.3

- Corrigido o layout mobile após confirmação de que o joystick ainda ficava fora da tela: a raiz do HUD cobre o viewport completo e os insets do safe area são aplicados como margens dos controles.
- Joystick/curativo agora ficam no canto inferior esquerdo; skills/interação no direito, com alinhamento inferior e adaptação à safe area 9:16. O layout também reposiciona HUD superior e minimapa dentro dos recortes seguros.
- APK Android debug exportado como 0.1.3/versionCode 4; ZIP Web também reexportado para incluir o novo layout touch. Os testes simulam três proporções, verificam todos os controles visíveis e validam toque/soltura; aparelho físico não disponível.
- SHA-256: APK `672b885a864465d37c4972675dc93c7c1feebeb89d778b4d72ecaa7518d3d7af`; Web `081a44301a9d8d199ca1f5ee44ff12cabaac93c5761137591e08dc78d425d5ed`.
- Adicionado teste com recortes sintéticos em três proporções; joystick, skills, botão de interação, minimapa e retrato permanecem no safe rect/viewport. Toque de arrasto no joystick move o player e o toque de soltura interrompe o movimento.
- Verificações: import Godot 4.5.1; `test_mobile_controls_layout.gd`, `test_close_view.gd`, `test_portrait_combat.gd`, `smoke_playable_slice.gd`, catálogos e export/validação APK passaram. O aparelho físico não está conectado; notch real, multitouch e usabilidade ainda precisam de playtest.

## 2026-10-16 — Safe area Android validada 0.1.4

- Captura enviada pelo usuário mostrou joystick/spells ausentes e textos dos botões do topo sobrepostos. O mapeamento da safe area agora é limitado ao viewport e rejeitado quando largura/altura ficam abaixo de 80% da tela; nesses casos usa o viewport inteiro.
- Labels superiores encurtados para “Bolsa” e “Base”. Teste mobile expandido para quatro cenários, incluindo dimensões de safe area em orientação incompatível; todos os controles e toque/soltura do joystick passaram.
- APK 0.1.4/versionCode 5 e ZIP Web reexportados. O Android físico ainda precisa confirmar a exibição real.
- Hashes: APK `4d43316b2bd6229d78fdc44afe838aa2746575f688260c8046717b4629da06d4`; Web `06057289c6d511813e9e65ad7685120cebf2f51be8a8059b025c5a3b7d753cf5`.

## 2026-10-16 — Marcador de alvo compacto 0.1.5

- O anel de seleção que aparecia como arco grande no mobile foi trocado por uma elipse pixel art dourada, gerada em 48×48 px, desenhada horizontalmente no chão e alinhada ao ponto de apoio do sprite 3D. Continua invisível sem alvo selecionado; HUD e nome/vida do inimigo não mudaram.
- `test_close_view.gd` verifica orientação horizontal voltada para cima, tamanho e alinhamento; `test_portrait_combat.gd` garante seleção/troca em quatro zooms. Também passaram `test_mobile_controls_layout.gd`, integridade do ZIP e validação da assinatura/manifesto Android.
- APK debug 0.1.5/versionCode 6: `323a7bcc9579537f19fd2a2f7d0e86c215b1817501a2ef18803afd3e7dd94ab8`. ZIP Web: `b0754dcfdba4cd27235c76d3755b8b26567dc831842ad106725119e4a74bbc47`. WebGL no navegador e aparelho Android físico ainda precisam de playtest.

## 2026-10-16 — Joystick, atributos e regeneração no level-up

- Joystick mobile dobrado para 288×288 px lógicos e raio de movimento/touch 128; continua no canto inferior esquerdo dentro da safe area. Entrada agora converte coordenadas com a transformação completa do HUD.
- Botão `ATR` abre modal em 9:16. A janela mostra vocação/nível, FOR/AGI/INT e prévia do máximo de vida/mana; alocação é temporária até confirmar. Confirmar salva e atualiza a HUD; Resetar/Fechar descartam alterações pendentes.
- Cada level-up restaura vida e mana aos máximos atuais do personagem e concede os pontos catalogados por nível, inclusive quando um ganho de XP cruza mais de um limite.
- Testes headless passaram: joystick/layout, painel e integração de atributos, close-view, level-up/save e smoke do loop solo. Alterações ainda não foram exportadas; APK/Web 0.1.5 não as contêm, conforme fluxo acordado com o usuário.

## 2026-10-17 — APK Android atualizado para 0.1.6

- O usuário avisou que o APK entregue não tinha as últimas mudanças. A inspeção do binário confirmou manifesto 0.1.5/versionCode 6, embora o preset da branch já estivesse em 0.1.6/versionCode 7.
- QA delegada identificou expectativas de testes anteriores à expansão do mapa/câmera e uma regra de ataque básico que não permitia contato físico. Corrigidos o range projetado, nomes estáveis de colisores, sincronização de dano `Label3D` e fixtures/assertivas obsoletas sem ampliar os hitboxes.
- Passaram no Godot 4.5.1: `test_melee_contact_spacing.gd`, `test_portrait_combat.gd`, `test_close_view.gd`, `smoke_playable_slice.gd`, `test_expanded_map_population.gd`, `test_mobile_controls_layout.gd`, `test_level_up_restores_resources.gd`, `test_respawn_radius.gd`, `test_mvp_solo_loop.gd`, `test_regeneration_rules.gd`, `test_attributes_window.gd`, `test_attributes_hud_integration.gd` e `test_inventory_overlay_layout.gd`. `tools/gameplay/validate_playable_slice.py` e `git diff --check` também passaram.
- APK reexportado em `build/android/ilha-do-cristal-debug.apk`: 0.1.6/versionCode 7, 64.680.671 bytes, SHA-256 `94a3e75920b3608c870e42af0172aaef3d23e28b465243b1077dfb7cfe153517`. Manifesto portrait, ARMv7/ARM64, package ID, ícones, sem permissões, assinatura v2/v3, CRC e arquivos runtime passaram. O ZIP Web não foi reconstruído e não havia Android físico conectado.
- Build feita do worktree atual em `feature/s02-pixel-hud-assets`, HEAD/base `8140343`; alterações continuam sem stage/commit. Próximo gate: instalar o APK e validar controles, legibilidade e estabilidade no aparelho.

## 2026-10-16 — Validação do APK 0.1.6 e integração pendente

- Cópia local consolidada em `b0b7b7f188e157642fd50de0dd26e19751c29bfe`, 33 commits à frente da `origin/main`; o GitHub ainda apontava `main` para `b3d3f9a`, com PRs #10/#11 empilhadas.
- APK 0.1.6/versionCode 7: 64.680.671 bytes; SHA-256 `94a3e75920b3608c870e42af0172aaef3d23e28b465243b1077dfb7cfe153517`. Conferidos manifesto, package, versão, orientação portrait, ABIs ARMv7/ARM64, CRC e presença dos blocos APK Signature Scheme v2/v3.
- Revalidados catálogo, validação da fatia, espaçamento melee e composição estrutural do terreno. O validador da fatia inicialmente acusou PNGs candidatos de Mago fora do runtime; sua guarda foi corrigida para verificar os atlases Warrior efetivamente referenciados, e o teste passou.
- Limite desta validação: este ambiente não tem Godot, Android SDK, adb ou dispositivo. Não houve nova exportação nem instalação física. O sidecar da APK aponta para a base `8140343`; o relatório da build registra que ela foi exportada do worktree sujo que depois virou o commit `b0b7b7f`.
- Próxima ação: publicar a integração em `main` via PR, entregar a APK e solicitar playtest físico; a Web não foi reexportada e permanece 0.1.5.

## Integração e entrega — APK 0.1.6

- PR #12 mesclada na main em 84a68f891ef63f7d6949832f0a8065dc3d75e600; árvore fd8dc0ada0301d5efe62e6b1b959ba91ae3f020a conferida contra o snapshot local, incluindo todos os 211 blobs alterados desde a base HUD.
- APK 0.1.6/versionCode 7 disponibilizado para download; mesmo SHA-256 registrado na validação anterior. Comparação adicional: 89 arquivos fonte diretamente comparáveis do APK coincidem byte a byte, sem divergências. GDScript está em bytecode.
- Nenhuma nova exportação, mudança de gameplay ou validação física foi feita nesta etapa. Próximo gate continua sendo o playtest Android; Web permanece 0.1.5.

## 2026-10-17 — UI, profundidade e minimapa 0.1.7

- Referências 3/4 do usuário aplicadas à composição de inventário e atributos: metal/pergaminho, ícones, papel do personagem ampliado, duas colunas e fontes mais legíveis. 31 assets nativos gerados de fonte Pillow versionada, sem alterar personagens ou inventar economia.
- Corrigidos offset Y do Sprite3D, pivôs de props e clamp projetado da câmera; minimapa integral com monstros vivos em vermelho.
- Import, testes de UI/atributos/mobile/câmera/combate/fluxo passaram. Captura real em Xvfb TCP + Mesa 720×1280 comparada visualmente. Evidências e limitações em MOBILE_UI_017_VALIDATION.md.
- Versão 0.1.7/code 8. Exportador oferece instalação paralela .preview porque a chave debug da 0.1.6 não está presente; preserva instalação/saves anteriores e usa progresso separado. Playtest físico continua aberto.

## 2026-10-17 — Movimento alinhado à câmera 2.5D

- Causa: teclado e joystick enviavam vetor de tela diretamente para X/Y da simulação. O render mapeia Y para Z e a câmera X−30°/Y45° projetava Norte/Sul em diagonais.
- `player.gd` agora aplica a inversa da projeção da câmera no plano XZ ao input, e usa a direção da tela para selecionar facing/animação. `first_island.gd` fornece a base da câmera na inicialização.
- O smoke do fluxo agora valida oito direções pelo deslocamento real e sua projeção no viewport, velocidades iguais em cardinais/diagonais e teclado ↑/↓. Godot 4.5.1 headless: import e fluxo jogável passaram. O teste imprime a projeção antiga de N/S para evidenciar o desvio.
- Não houve mudança em colisão, regeneração, morte, HUD ou dados de jogo; teste físico Android não foi executado nesta microtarefa.

## 2026-10-17 — Regeneração fora de combate +20%

- Causa: `CombatRules.regeneration_rates_percent_per_sec` combinava base e bônus efetivo de FOR/INT, mas não aplicava o aumento solicitado ao sair de combate. O estado após 8 s e os caps já existiam.
- Incluído `out_of_combat_rate_multiplier: 1.2` no catálogo. O runtime multiplica a soma de base e bônus de atributo somente fora de combate, antes dos caps. Combate, delay, caps, clamp no máximo, pausa em personagem caído/morto e restauração ao subir de nível permanecem iguais.
- Documentados os valores efetivos no GDD, catálogo, dados de balanceamento, README e roadmap. O teste de regras verifica as seis taxas base pós-fator, as taxas com atributos nas três vocações, taxas de combate, caps, clamp e tick integrado; o teste do painel valida os bônus exibidos.
- Godot 4.5.1 headless: import (exit 0), `test_regeneration_rules.gd`, `test_attributes_window.gd` e `smoke_playable_slice.gd` passaram. O import emitiu o aviso `Unable to open Android 'build-tools' directory`; não houve exportação APK nem teste em aparelho.


## 2026-10-17 — Kit UI Crystal v2

- Branch `feature/s03-crystal-ui-kit-v2`, implementada a partir das referências visuais anexadas pelo usuário e do spritesheet `assets/ui/crystal_v2/sheet.b64`. O atlas/runtime renderer recorta molduras, botões, barras, slots, navegação, itens e estruturas; os fluxos de HUD, mochila/equipamento, fabricação/refúgio, talentos/vocações, seleção, pausa, minimapa e alertas passaram a compartilhar o kit.
- Atualizados componentes Godot e presets de exportação; adicionados `tools/gameplay/test_crystal_kit.gd` e `test_crystal_ui_flow.gd`. Limites respeitados: Guerreiro continua a única vocação jogável, talentos ainda não implementados; Arqueiro/Mago são prévias. Imagens de personagens separadas do sprite sheet não foram incorporadas ao projeto.
- Godot 4.5.1: importação/editor, checagem de `main.gd`, teste de regiões do atlas e teste integrado de fluxo passaram. Exportações Web e APK debug completadas. APK validado por integridade ZIP, manifesto/launcher/ícones/permissões e assinatura; APK e ZIP Web também entregues fora do repositório. Web ainda sem inspeção gráfica em navegador; APK não foi instalado/testado em aparelho físico. Builds são artefatos de teste, não publicação.
- Capturas locais de revisão: inventário e pausa. O diff inclui os arquivos de interface, atlas e testes no branch; arte dos personagens permanece sem promoção de status.
- Próxima ação: revisar PR, testar fluxo e safe areas/toque por 10 min em Android físico e fazer smoke gráfico Web em navegador. Resolver eventuais regressões com base nas evidências e manter vocações/talentos não implementados explicitamente indisponíveis.


## 2026-10-17 — APK de preview armazenado na branch

- A pedido do usuário, o APK foi disponibilizado pelo plugin GitHub em `artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk`, commit `28dee2d3df72dd3ba225eefd624c2859f476c2e0`, branch `feature/s03-crystal-ui-kit-v2`. [Download direto](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk).
- A variante dual-arch excedia o limite de transmissão do conector. A partir do APK de preview Godot validado, removida somente a biblioteca `armeabi-v7a`, reempacotado o arquivo e aplicada assinatura debug novamente. Resultado ARM64-only: 39.337.295 bytes; SHA-256 `9d723315cae0bfe5f4f68c88527484e618e61897ddcef0be0de8489c25b9e88a`.
- Verificados com Godot 4.5.1/helper: manifesto portrait, ID/label preview, ícones, ausência de permissões, JSON de runtime, CRC/integridade ZIP e assinatura v2/v3. `aapt` exibiu um diagnóstico de atributo `android:required` no dump de badging, mas o manifesto XML-tree do APK passou e o APK permaneceu válido; teste em aparelho ainda pendente.
- Documentos atualizados para identificar o link da branch e a limitação de 64 bits. O artefato permanece no PR #21 e não foi integrado a `main`.

## 2026-10-18 — Reconstrução e persistência da entrega perdida

Partida: remoto2a1784d; código reconstruído publicado5f14e623f6787e97e1f6b4aa58778cd132f247f8 na feature/s03-crystal-ui-kit-v2. Microtarefas independentes para HUD, minimapa, mapa fixo, vocações e LAN; integrações verificadas. HUD144/96, frustum circular, profissões locais/VFX, mapa prebaked50mil e ENet/descoberta/movimento. Corrigidos atributos Archer por AGI, pausa LAN e validador de permissões. Testes de interface/combate/save/mapa e LAN2processos passaram; smoke atualizado para50000 tiles. Comparação gráfica Godot executada via Xvfb/OpenGL. APK0.1.9 exportado da árvore limpa de5f14e62, CRC/manifesto/assinatura v2/v3/recursos/permissões verificados, metadados artifacts/preview/HUD-0.1.9.json. Nenhum teste físico Android. Não recuperar exatamente APK anterior; esta é reconstrução nova. Próxima tarefa: combate autoritativo, itens/coleta e save host; depois doisAndroids. Relatório completo em docs/gameplay/HUD_RECONSTRUCTION_019.md.

## 2026-10-18 — Proposta de mapa global e bestiário para revisão

- Worktree inspecionado, limpo no commit 6133ee6; criada a branch `feature/s04-global-map-island-content` sem alterar a branch anterior.
- Auditoria GDD/catalog/ArtDirection confirmou que o bestiário MVP contém apenas raposa, lobo e urso. Foram documentados dez conceitos candidatos, todos identificados como expansão ou variante futura, sem stats/drops nem alteração no catálogo. Prancha concept gerada com imagegen em `docs/art/candidates/bestiary-expansion-concepts-v0.1.png`.
- A auditoria do mapa confirmou 250×200=50.000 tiles, 645 transições e 15 overlays de trilha; o bake determinístico passou. Terreno usa faixas retas/áreas retangulares, sem alturas, rampas, penhascos ou Terrain Sets. Mantida a escala runtime 32×32 por ora.
- Criados protótipo navegável do mapa global sem pausa/zoom compartilhado e imagem conceitual da ilha irregular com costa/platôs/rampas; ambos em revisão explícita. O arquivo HTML do usuário foi tratado como protótipo 64×32, sem promover migração.
- Não houve alteração de gameplay, runtime UI, mapa prebaked nem assets de produção. APK0.1.9 permanece a build atual até aprovação e implementação.
- Verificações desta etapa: estado inicial limpo, bestiário e GDD/art direction lidos, auditorias read-only, `python3 tools/world/bake_first_island.py --check` passou; HTML/links locais analisados, JavaScript passou `node --check` e `git diff --check` passou. Playwright está instalado, mas o executável Chromium não está disponível neste ambiente; não houve renderização interativa em navegador. A validação visual do protótipo fica para a revisão do usuário.

## 2026-10-18 — Atualização de conteúdo no início do jogo

- Incremento iniciado na branch `feature/s07-github-content-updater`, agora baseada na reconstrução 0.1.9 de `origin/main` `e38821d`. O usuário aprovou o protótipo navegável de verificação/download/erro e recarga; aprovação e comparação estão em `Docs/Context/PROTOTYPE_LOG.md`.
- Adicionado o boot Android com consulta a Releases `content-vX.Y.Z`, oferta opcional/obrigatória, progresso, checagem de tamanho/SHA-256, montagem do PCK, recuperação do registro ativo e recarga da cena. Saves permanecem no caminho existente. Atualização de código/cena segue via APK 0.1.10/versionCode 11. O boot Web abre gameplay diretamente.
- Godot 4.5.1: importação headless, `test_content_updater.gd`, `test_update_boot_ui.gd`, `test_content_pack.gd` e `smoke_playable_slice.gd` passaram. Exportado localmente um PCK de aproximadamente 9,8 MB e testada a montagem/leitura de JSON e textura. `py_compile` e `git diff --check` passaram.
- Limites: a API pública do projeto ainda não tem Releases; o PCK de teste não foi publicado. A consulta direta ao GitHub pelo runtime headless deste ambiente falha por restrição de rede. Android SDK Platform 35/Build Tools 35.0.0 não estão disponíveis, portanto o APK 0.1.10 não foi exportado e não houve teste físico.
- Próxima ação: finalizar o PR desta branch; depois configurar SDK/templates Android, exportar e instalar o APK 0.1.10, testar conexão/offline e preservação de save em aparelho e publicar um Release de conteúdo somente quando houver conteúdo aprovado para atualizar.


## 2026-10-18 — terreno fixo persistido em TileMapLayer na Staging

- A alteração parte do HEAD `5a1d4a0a6fa6c9f451d95f0a9715a646b400aed9` da branch `Staging`. Os 50.000 tiles base, 645 transições e 15 overlays do JSON foram serializados diretamente em `game/scenes/first_island.tscn`; o TileSet de 56 tiles está em `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.tres`.
- `first_island.gd` valida as camadas e não carrega/repinta o mapa a partir do JSON no startup. `isometric_3d_view.gd` lê todas as células, inclusive a área inicial 64×44 que antes usava uma superfície legada. O minimapa também é derivado das células. Colisões, limites, água bloqueada, spawns, obstáculos e recursos continuam vindos do layout, preservando mecânicas.
- Validação estática decodificou `tile_map_data` e comparou cada coordenada e atlas tile com o JSON de origem; as contagens e as 56 entradas do TileSet coincidem. Regressões para persistência/edição manual e população expandida foram atualizadas.
- Godot 4.5.1 não está disponível neste ambiente, então importação/editor, execução dos testes headless e renderização não foram verificadas. Salvar/reabrir no editor e medir desempenho em Android permanecem pendentes. A composição continua plana; o conceito de ilha irregular não foi implementado nem aprovado por esta alteração.


## 2026-10-18 — Atlas tropical para pintura manual

- Importada a folha fornecida pelo usuário: recortados 64 slices de 128×128 em uma grade 8×8; removidos o fundo quadriculado e as linhas do contato, preservando o pixel art e alpha binário.
- Criados TileSets separados para 40 superfícies e 24 objetos, além das camadas vazias `ManualTerrain` e `ManualProps` em `first_island.tscn`. A célula de 128 px corresponde a 4×4 SQMs da simulação de 32 px.
- A apresentação 2.5D projeta as superfícies manuais no chão, os objetos como billboards e copia os tiles de superfície para o minimapa. As 50.000 células originais e as regras de colisão/spawn não foram alteradas.
- Validação estrutural do atlas, slices, TileSets e referências da cena executada com o validador específico. Godot 4.5.1 não está disponível neste ambiente; importação real, edição/salvamento/reabertura no editor e teste Android permanecem pendentes.


## 2026-10-18 — Logo no launcher e boot Android

- Partida na branch `feature/s08-logo-app-icon-splash`, baseada em `Staging` `5a1d4a0`. A imagem enviada pelo usuário foi preservada em `tools/art/source/ilha-cristal-logo.jpg` e alimenta `tools/art/generate_app_icon.py`.
- Geradas as quatro variantes de launcher: principal 512×512, adaptive background/foreground e monochrome 432×432. A Godot usa o ícone principal na splash nativa e a mesma marca no cabeçalho da tela de atualização. O foreground adaptativo mantém a wordmark dentro da área segura; o ícone monocromático usa o cristal central simplificado.
- O preset Android já referencia esses quatro caminhos; agora eles contêm a arte aprovada. A build segue em 0.1.10/versionCode 11, sem incremento, pois esta APK ainda não foi exportada.
- Godot 4.5.1: importação headless, `test_update_boot_ui.gd` e `test_content_updater.gd` passaram. A checagem de projeto confirmou os parâmetros de splash; PNGs têm 512×512 (principal) e 432×432 (variantes adaptativas/monocromática), alpha esperado, e o JPEG-fonte confere byte a byte com o anexo. `py_compile` e `git diff --check` passaram. O único aviso de import foi ADB sem daemon/dispositivo conectado.
- Limite: Android SDK Platform 35/Build Tools 35.0.0 não disponíveis; sem APK ou teste em aparelho.


## 2026-10-18 — Servidor Node.js para wiki e exportação Web sob demanda

- Adicionado `Acessar_Wiki.bat` na raiz e `tools/wiki/serve.js`, sem dependências npm. O servidor usa somente loopback, abre `/docs/wiki/`, escolhe outra porta se 8000 estiver ocupada e atende os documentos/imagens usados pelos links da wiki. `.git`, `.godot`, `build`, segredos e arquivos de save/assinatura são bloqueados.
- `Testar_Jogo_Web.bat` agora tenta gerar `build/web/` com Godot 4.5.1 quando não encontra a exportação. O servidor Web explica o comando de exportação caso a build continue ausente. Este ambiente não tem Godot/exports Web, então não foi possível produzir a build do jogo aqui.
- README e roadmap atualizados. `python3 tools/wiki/test_catalog.py` passou com Node.js 24.19.0, verificando catálogo atualizado para 75 prévias e 413 arquivos, links locais, imagens PNG, redirecionamento da raiz, HEAD e bloqueio de diretórios privados. `node --check`, `py_compile` e `git diff --check` também passaram.
- Conflitos com `Staging` `56bbc475556dd72270fccc1d4098e4eb197fedca` resolvidos preservando os registros anteriores de terreno e identidade visual. Índice da Wiki regenerado após a importação do atlas tropical. PR #25 preparado para integração em `Staging`.

## 2026-10-18 — Prefab e colisões editáveis de criaturas

- Criada a cena base `game/scenes/creatures/creature_base.tscn` com `CharacterBody2D`, cápsula corporal, `DetectionArea` e `AttackArea`. As cenas herdadas `fox.tscn`, `wolf.tscn` e `bear.tscn` têm recursos próprios, com dimensões iniciais equivalentes aos colisores atuais e raios de detecção raposa 150, lobo 190 e urso 170.
- `first_island.gd` passou a instanciar as cenas de espécie em spawns e respawns. `creature_actor.gd` deixou de criar/sobrescrever colisores e usa as formas das cenas para detecção e limite exterior de ataque; o filtro de contato visual melee existente permanece ativo.
- `test_melee_contact_spacing.gd` passou a instanciar as cenas herdadas e ganhou verificações para formas e camadas personalizadas após `_ready()`. README, arquitetura e roadmap documentam os caminhos e o fluxo de edição.
- Checagem estática do catálogo, cabeçalhos/subrecursos TSCN, referências do spawner e ausência de criação de colisores em runtime passou. O cálculo das poses/câmera registradas mostrou que o contato projetado máximo é 172,1 px (urso), dentro dos 220 px da AttackArea. `git diff --check` passou.
- Godot 4.5.1 headless importou/reimportou o projeto; passaram `test_melee_contact_spacing.gd`, `smoke_playable_slice.gd`, `test_expanded_map_population.gd` (30 spawns) e `test_respawn_radius.gd`. A configuração do editor emitiu aviso de safe-save fora do projeto, sem impedir importação nem testes.
- Revisão visual das formas e o ajuste/salvamento/reabertura manual no editor permanecem pendentes para o usuário.


## 2026-10-18 — Godot da raiz no launcher Web

- Na branch `feature/s13-web-root-godot`, `Testar_Jogo_Web.bat` agora procura primeiro o executável Godot 4.5.1 na raiz do projeto, priorizando a variante Windows 64-bit console, e passa o caminho absoluto ao exportador. Se não encontrar o binário na raiz, mantém a descoberta, o seletor e o fallback existentes.
- README e roadmap descrevem essa prioridade. A checagem estática confirmou as variantes esperadas na raiz, caminho absoluto passado ao exportador e prioridade sobre `--print-godot`; `tools/wiki/test_catalog.py` e `git diff --check` passaram. Exportação e execução do `.bat` no Windows permanecem pendentes: este ambiente não tem Windows, Godot 4.5.1 ou templates Web.

## 2026-10-18 — pranchas isométricas candidatas

- Adicionadas duas pranchas PNG RGBA 1254 x 1254 em `assets/environments/ilha_cristal_isometric_candidate_v1/`, com prompts e instruções.
- Transparência real confirmada; há pixels semitransparentes residuais. Grade visual 8 x 8 exige recorte manual, pois 1254 não é divisível por 8.
- Sem integração de cenas ou validação visual no Godot. Próxima ação: testar um terreno e uma árvore, ajustando recorte, origem, escala e halos.
- Publicação direta em Staging solicitada pelo usuário, via plugin GitHub.


## 2026-10-18 — Atualização do exportador Web para Godot 4.7.2

- Após o usuário reportar `Esperado Godot 4.5.1, encontrado 4.7.2.stable.official.ed1daf0bf`, o launcher, o exportador e o servidor Web foram alinhados para 4.7.2. O `.bat` procura os nomes 4.7.2 na raiz e passa o executável explicitamente; o Python prioriza o binário compatível da raiz, valida a versão também em `--print-godot` e deixa o caminho salvo antigo por último.
- README, roadmap, handoff e instrução de exportação Web atualizados. A exportação Android permanece validada e fixada em Godot 4.5.1, fora do escopo desta correção Web.
- Teste de CLI aceitou `4.7.2.stable.official.ed1daf0bf` e recusou 4.5.1; teste isolado confirmou que o executável 4.7.2 da raiz prevalece sobre `GODOT_BIN` e `.godot-path` antigos. `py_compile`, `python3 tools/wiki/test_catalog.py` e `git diff --check` passaram antes da sincronização; suíte e índice serão verificados novamente após preservar as pranchas isométricas recém-integradas em Staging.
- Exportação real e compatibilidade do preset dependem de Windows, Godot 4.7.2 e templates Web correspondentes.

## 2026-10-18 — Diagnóstico de executável Godot inválido no launcher Web

- O usuário reportou que o launcher encontrou `Godot_v4.7.2-stable_win64_console.exe`, mas a consulta `--version` saiu com código Windows `4294967295` e gerou traceback. O arquivo presente no projeto tinha 198.152 bytes; não se comporta como o editor completo. O ZIP oficial para Windows x64 mede 86.013.866 bytes.
- Removido o executável inválido do Git e acrescentadas regras para manter os binários locais do Godot fora do repositório. O `.bat` continua usando primeiro um Godot válido na raiz, independente do `PATH`.
- `export_web.py` agora valida cada candidato antes de usá-lo, pula binários quebrados/versões diferentes quando faz descoberta e imprime diagnóstico direto para caminho explícito inválido, timeout ou erro ao iniciar; nenhum traceback cru de `CalledProcessError` nessa etapa.
- O launcher usa a descoberta validada, procura outros locais/caminho salvo e abre o seletor quando necessário. README, roadmap e handoff explicam baixar e extrair a versão estável oficial e instalar templates Web 4.7.2.
- Testes de CLI com executáveis simulados aceitaram Godot 4.7.2 e produziram diagnóstico curto sem traceback para um executável que falha; a descoberta também ignorou o wrapper inválido e usou outro caminho 4.7.2. A validação estática do `.bat`, `py_compile`, `python3 tools/wiki/test_catalog.py` e `git diff --check` passaram. A exportação real continua pendente em Windows com os templates 4.7.2.
