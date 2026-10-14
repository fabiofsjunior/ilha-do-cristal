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
