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
