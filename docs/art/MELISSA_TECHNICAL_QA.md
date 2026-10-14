# Teste técnico de Melissa Warrior — QA e produção

Escopo atual: **somente Melissa Warrior, S/N, idle/walk**. Etapas seguintes aguardam validação explícita do teste. Esta tabela é planejamento; pendente não significa produzido. Referências: [GDD](../../Docs/Main/GDD_MVP.md), [catálogo](../../Docs/Main/CATALOGS_MVP.md), [direção](ART_DIRECTION_AND_SPRITES.md) e [concept oficial](../../assets/references/concept-rpg-classico.png).

## Critérios do teste

- Identidade: menina de 8 anos, cabelo predominantemente castanho-escuro, uma única mecha roxa frontal, roupa lilás e proporções infantis. Não pintar mecha roxa adicional atrás para torná-la visível em N. Espada é obrigatória; acessórios devem permanecer consistentes entre quadros e vistas.
- Câmera superior levemente oblíqua, SQM ortogonal; reconstruir vistas S/N, sem recortar concept. Cabeça, volume do cabelo, roupa e comprimento da arma permanecem estáveis.
- Células 96×96 RGBA; figura alvo aproximada 48×64; pivô nos pés (48,80). Idle com 4 quadros e walk com 6 por direção. Teste usa somente duas direções e deve declarar a ordem em metadados; contrato final permanece N, NE, E, SE, S, SO, O, NO.
- Transparência verdadeira, sem fundo desenhado, halo ou suavização; margens livres e sem invasão de célula. Não recortar áreas transparentes. Movimento das pernas é intencional; nenhuma deriva do ponto de apoio de um ciclo ao seguinte.
- Walk deve alternar pernas e braços com passo reconhecível, sem saltos de identidade, arma, cabelo ou proporção. Não aceitar repetição de quadros estáticos deslocados como caminhada concluída.
- Importar em Godot 4, nearest e sem mipmaps; verificar cada quadro parado e ciclos animados sobre fundo claro, escuro e terreno. Capturar S/N em zoom 50%, 75%, 100% e 125%; registrar versão do motor, SQM, viewport, data e evidências.
- Android horizontal: registrar modelo, resolução, legibilidade de personagem/espada e comparação com SQM. Sem aparelho disponível, manter validação Android **pendente**, mesmo que importação e screenshots desktop passem.

## Gate e evidências

Aprovação visual e técnica são independentes. `aprovado`: evidência de todos os critérios aplicáveis; `corrigir`: defeito identificado com descrição; `pendente`: ausente, não testado ou aguardando usuário. Não avançar ao lote enquanto escala/identidade do teste não forem validadas.

| Teste | Estado inicial | Evidência / pendência |
|---|---|---|
| Identidade e paleta S/N | corrigir | castanho/lilás/mecha frontal reconhecíveis; cabeça/cabelo e silhueta variam entre idle/walk |
| Idle S/N, 4 frames | corrigir | grade 384×192 válida, porém alpha suave, câmera frontal e volume variável |
| Walk S/N, 6 frames | corrigir | grade 576×192 válida, porém alpha suave, volume/câmera e alinhamento dos pés requerem revisão |
| Importação Godot 4 | aprovado | execução e capturas V2 no motor; aprovação técnica somente |
| Escala no SQM e zoom 50–125% | pendente | capturas e revisão no motor |
| Android horizontal | pendente | aparelho físico e registro |
| Aprovação do usuário para ampliar | pendente | resposta após apresentação do teste |

## Matriz de personagens

Todos os estados abaixo abrangem oito direções na entrega final. Melissa Warrior idle/walk têm somente o subconjunto técnico S/N autorizado agora; isso não aprova as oito direções.

| Aparência/vocação | idle (4) | walk (6) | attack (6) | hit (3) | death (6) | cast (6) |
|---|---|---|---|---|---|---|
| Melissa Warrior | pendente | pendente | pendente | pendente | pendente | pendente |
| Melissa Archer | pendente | pendente | pendente | pendente | pendente | pendente |
| Melissa Mage | pendente | pendente | pendente | pendente | pendente | pendente |
| Helena Warrior | pendente | pendente | pendente | pendente | pendente | pendente |
| Helena Archer | pendente | pendente | pendente | pendente | pendente | pendente |
| Helena Mage | pendente | pendente | pendente | pendente | pendente | pendente |

## Matriz de monstros

Fora da etapa atual. Raposa pequena, lobo médio e urso grande; animais reconhecíveis com cristais discretos, sem gore. Célula/pivô do urso podem mudar, sempre declarados. Quantidades de frames/FPS aguardam definição após teste.

| Animal | idle | walk | attack | hit | death |
|---|---|---|---|---|---|
| Raposa | pendente | pendente | pendente | pendente | pendente |
| Lobo | pendente | pendente | pendente | pendente | pendente |
| Urso | pendente | pendente | pendente | pendente | pendente |

## Matriz de efeitos separados

Fora da etapa atual. Cada efeito terá atlas/metadados próprios; nunca será gravado nos quadros base. Quadros/FPS/pivô e área visual não definem automaticamente hitbox.

| ID / finalidade | Conteúdo visual previsto | Estado |
|---|---|---|
| war_combo | sequência de cortes de três golpes | pendente |
| war_circle | corte circular e feedback de sangramento sem gore | pendente |
| war_quake | tremor/impacto e feedback de atordoamento | pendente |
| arc_precise | invisibilidade e disparo preciso | pendente |
| arc_bounce | projétil/impactos de ricochete | pendente |
| arc_pierce | flecha perfurante e aumento de cadência | pendente |
| mag_bolt | projétil arcano e impacto | pendente |
| mag_fire | bola de fogo, impacto e queimadura | pendente |
| mag_ice | explosão de gelo | pendente |
| collect | coleta de recurso | pendente |
| heal | cura | pendente |
| downed_revive | queda, canalização e reanimação | pendente |
| damage_feedback | dano recebido sem gore | pendente |
| crystal | cristal puro / feedback cristalino | pendente |
| construction | construção/melhoria do acampamento | pendente |

Vael, exército, novos monstros e conteúdo além do MVP não fazem parte deste lote. Fotos privadas nunca são artefatos do repositório.

## Revisão independente dos candidatos — 2026-10-14

Arquivos inspecionados: `assets/characters/melissa/warrior/melissa_warrior_idle.png` (384×192, quatro colunas) e `melissa_warrior_walk.png` (576×192, seis colunas). Ambos contêm **somente N/S**, nessa ordem, em duas linhas de 96 px. São candidatos técnicos **não aprovados**; não equivalem aos atlas finais de oito direções. Esta revisão observou todos os quadros nas pranchas e mediu o alpha; não substitui reprodução animada em Godot nem aparelho Android.

| Verificação | Resultado | Evidência / correção necessária |
|---|---|---|
| Grade e contagem do teste | aprovado | células 96×96; idle 4×2 e walk 6×2 |
| Fundo transparente | aprovado | existe alpha real; nenhum fundo opaco pintado |
| Pixels nítidos / alpha binário | corrigir | idle tem 19.734 pixels com 0<alpha<255; walk tem 25.659. Sombras/contornos apresentam suavização; redesenhar bordas e sombreado em pixel art deliberada |
| Câmera | corrigir | S apresenta sobretudo frontal, sem leitura superior consistente dos ombros/cabeça; reconstruir ângulo top-down levemente oblíquo |
| Identidade básica | aprovado | cabelo castanho, mecha roxa frontal e traje lilás reconhecíveis, com espada e escudo presentes |
| Consistência entre estados | corrigir | idle tem cabeça/cabelo/silhueta maiores; walk é mais estreito e muda volume do cabelo e traje. Fixar modelo antes de ampliar |
| Pivô / escala | corrigir | caixas alpha têm base entre y=82–85 em idle, y=86–90 em walk; a base alpha inclui sombra/halo e não comprova contato dos pés. Reancorar pés manualmente no pivô (48,80), removendo os halos, e revisar ciclo no motor |
| Espaço entre células | aprovado | caixas alpha permanecem dentro de cada célula; não há conteúdo invadindo a vizinha |
| Continuidade da caminhada | pendente | poses diferem e sugerem passo, mas ritmo, deslizamento e transição idle→walk exigem reprodução no motor após correções |
| Mão da espada | pendente | inspeção da prancha não certifica empunhadura a cada frame; revisar N/S animados, especialmente os quadros N alterados por espelhamento |
| Zoom 50–125%, SQM e Android | pendente | exige execução e evidência após correção de arte |

**Decisão:** corrigir estes dois atlas; manter variantes, monstros e VFX pendentes. A aprovação estrutural de grade/transparência não libera produção em lote. Não resolver volume apenas escalando cada quadro independentemente: isso mantém deriva anatômica e pode prejudicar o padrão dos pixels.

## Revisão independente V2 — 2026-10-14 (antes da correção uniforme de âncora)

Inspecionados os 20 quadros de `melissa_warrior_idle_candidate_v2.png` e `melissa_warrior_walk_candidate_v2.png` (N/S), preservando os resultados V1 acima. A fonte conjunta permitiu avaliar idle e walk com o mesmo modelo. **V2 é o candidato preferido para correção**, sem aprovação de produção: melhora câmera e consistência, mas ainda falha no contrato de pixels e alinhamento final.

| Verificação V2 | Estado | Resultado comparado à V1 |
|---|---|---|
| Grade 96×96 / contagem | aprovado | idle 384×192 (8 quadros); walk 576×192 (12 quadros), somente N/S |
| Identidade | aprovado | castanho predominante e mecha roxa frontal única, roupa lilás/dourada, espada e escudo; sem mudança de pessoa entre idle/walk |
| Câmera superior oblíqua | corrigir | melhor que V1: topo da cabeça e ombros mais visíveis; N/S ainda precisam avaliação animada em SQM, mas a reconstrução é uma base útil |
| Volume entre estados | aprovado | cabelo, cabeça, traje e equipamento substancialmente mais consistentes nos 20 quadros; conservar esta base para a correção de pixels |
| Arma e mão | aprovado | na inspeção estática, espada à direita visual em N e à esquerda em S, mantendo mão direita; escudo no lado complementar, sem flips isolados aparentes |
| Transparência real | aprovado | fundo transparente existente |
| Pixels / antialias | corrigir | idle 17.764 e walk 26.400 pixels de alpha intermediário. Contornos/cabelo/metal continuam suaves; V2 não atende pixel art nítida sem suavização |
| Margem e alpha residual | corrigir | alpha fraco chega a y=96 em idle S, tocando a borda inferior. Remover resíduos e verificar margens em todos os canais alpha antes de integrar |
| Escala | corrigir | corpo e equipamento visíveis ficam aproximadamente 45–48×57–62 px ao considerar alpha≥128, perto da figura alvo, porém pés ainda abaixo do pivô candidato |
| Pés / pivô | corrigir | alpha≥128: bases N idle y=83–84, N walk y=85; S idle y=87–88, S walk y=88–90. São limites visuais, não prova isolada de contato: revisar pés no motor e ancorar o mesmo ponto ao (48,80) sem deformar quadro |
| Continuidade do ciclo | pendente | poses de caminhada distinguíveis; ritmo, retorno quadro6→1, deslizamento e transição idle/walk dependem de reprodução animada |
| Godot, zoom e Android | pendente | revisão estática não comprova importação, escala na grade nem leitura em aparelho |

**Decisão V2:** manter `corrigir`; preferir esta versão à V1 como base de trabalho pela câmera mais superior e volume unificado. Não substituir rejeição de pixel art por aprovação de identidade. Não avançar a oito direções/variantes/monstros/VFX enquanto o teste corrigido não passar pela apresentação e validação solicitadas.

## Revisão V2 após ajuste uniforme de âncora e execução Godot

A subseção anterior registra a medição **pré-correção**. Os atlas foram posteriormente deslocados uniformemente por direção, sem reescalar quadros: a base alpha≥128 mudou de N83–85/S87–90 para valores próximos ao pivô candidato y=80. A revisão atual examinou [os 20 quadros capturados no Godot](evidence/godot_v2/all_20_frames_3x.png), [N a 50%](evidence/godot_v2/idle_N_zoom50.png), [S a 50%](evidence/godot_v2/idle_S_zoom50.png), [N a 125%](evidence/godot_v2/walk_N_zoom125.png) e [S a 125%](evidence/godot_v2/walk_S_zoom125.png). São screenshots desktop reais do motor, não evidência de aparelho Android.

| Item após ajuste | Estado | Evidência e limite |
|---|---|---|
| Importação e exibição Godot | aprovado | atlas N/S exibidos e 20 quadros capturados; aprovação estrutural, sem aprovação da arte |
| Base dos quadros | aprovado | alpha≥128, limites inferiores exclusivos: idle N/S y=79–80; walk N y=81; walk S y=80–82. O alinhamento está substancialmente melhor, com variação coerente com passos; contato/deslizamento animado permanece pendente |
| Identidade / volume | aprovado | folha 3× mantém modelo comum entre os 20 quadros, cabelo castanho/mecha roxa, traje e armas reconhecíveis |
| Direção S | corrigir | rosto e tronco leem como frontal em três quartos voltado à direita da tela. Não é S cardinal inequívoco; reconstruir S distinguindo-o da futura SE |
| Pixel art | corrigir | bordas e sombreado suaves continuam visíveis na folha3× e a125%; nearest no motor não remove antialias embutido no PNG |
| Ciclo walk | corrigir | seis poses existem, mas predominam pequenas variações de posição de uma perna, com pouca alternância inequívoca entre pernas dianteira/traseira. Redesenhar fases de contato, passagem e contrapasso; revisar o loop6→1 animado |
| Leitura desktop a50% | pendente | silhueta/personagem visíveis; detalhes de espada, mecha e passos tornam-se muito pequenos. Captura estática sobre grade não certifica legibilidade em terreno ou celular |
| Leitura desktop a125% | corrigir | personagem legível, mas direção S ambígua e suavização são perceptíveis; corrigir arte antes de congelar escala |
| Android horizontal | pendente | sem execução física comprovada |
| Escala SQM definitiva / aprovação de usuário | pendente | screenshot usa SQM48 candidato; requer terreno, câmera e dispositivo reais e apresentação do teste |

**Resultado atual:** V2 continua preferida à V1 e **corrigir** como arte de produção. A correção de âncora e a execução Godot removem pendências estruturais específicas; não liberam outras direções, variantes ou lote completo. Faltam S cardinal claro, caminhada com alternância legível, acabamento pixel sem suavização e validação no Android.

## Revisão independente V3 — 2026-10-14 (20 quadros, fonte e evidência Godot)

Inspecionados todos os 20 quadros de `melissa_warrior_idle_candidate_v3.png` e `melissa_warrior_walk_candidate_v3.png`, além da fonte unificada `assets/references/generated-candidates/melissa_warrior_unified_v3_source.png`, em comparação direta com os atlas e a fonte V2. A grade permanece somente N/S, nessa ordem. A revisão artística inicial foi estática; a integração posterior acrescentou as capturas Godot listadas abaixo. Não houve teste em aparelho Android.

| Verificação V3 | Estado | Evidência e comparação V2 |
|---|---|---|
| Grade 96×96 / contagem | aprovado | idle 384×192 (4×2) e walk 576×192 (6×2); metadados declaram N/S, pivô (48,80) e contagem correta. Ainda são apenas duas das oito direções finais. |
| Identidade e equipamento | aprovado | criança de proporções coerentes; cabelo castanho-escuro, uma mecha roxa frontal, traje lilás, espada na mão direita e escudo à esquerda. A vista N não adiciona mecha traseira. Equipamentos permanecem nos mesmos lados entre quadros. |
| Consistência entre estados | aprovado | o modelo unificado mantém cabeça, cabelo, roupa, escudo e espada estáveis entre idle e walk. V3 preserva a principal vantagem de consistência já vista na V2. |
| Direção S | corrigir | V3 deixa rosto e peitoral um pouco mais frontais que V2, mas a cabeça e o tronco ainda giram para a direita da tela. A leitura continua em três quartos, próxima de SE; não é S cardinal inequívoco nem uma distinção segura da futura SE. |
| Alternância do walk | corrigir | revistos N e S, seis quadros cada, inclusive as fases na fonte: há pequenas mudanças de separação/altura dos pés, mas não uma troca clara entre contatos esquerdo e direito, passagem e retorno. Na sequência S, a bota dianteira à esquerda da tela continua sendo a perna baixa/dominante pela maior parte do ciclo; N também lê como pequenas variações da mesma passada. A fonte já contém essas fases, portanto o recorte/escala do atlas não as corrige. |
| Transparência e margens | aprovado | há transparência real e os pixels ficam dentro das células; caixas alpha permanecem aproximadamente entre x=21–75 e y=7–85, sem invasão da célula vizinha. |
| Pixel art / alpha | corrigir | há 17.676 pixels com alpha intermediário em idle e 26.203 em walk. A redução frente aos números V2 é marginal; contornos e sombreado ainda têm bordas suaves. `nearest` no reamostramento preserva essa suavização da fonte e não satisfaz alpha binário/pixel art nítida. |
| Escala / pivô | corrigir | caixas alpha≥128 terminam em y=80 para idle N, y=78–79 para idle S, y=82–83 para walk N e y=79–81 para walk S (limite inferior exclusivo, coordenadas da célula). Isso não certifica contato, mas mostra bases inconsistentes em torno de y=80; walk N desce 2–3 px além do pivô candidato. Rever âncoras por direção e contato dos pés no ciclo, sem redimensionamento independente dos quadros. |
| Importação/execução Godot V3 | aprovado técnico | Godot 4.5.1 stable importou os atlas e renderizou [os 20 quadros](evidence/godot_v3/all_20_frames_3x.png) via `AtlasTexture` nearest 3×, mais quatro capturas estáticas a 100% para idle/walk × N/S ([idle N](evidence/godot_v3/idle_N_zoom100.png), [idle S](evidence/godot_v3/idle_S_zoom100.png), [walk N](evidence/godot_v3/walk_N_zoom100.png), [walk S](evidence/godot_v3/walk_S_zoom100.png)). Capturas desktop comprovam importação/renderização, não o ciclo animado 6→1 nem Android. |
| SQM/zoom 50–125% e Android horizontal | pendente | quatro capturas V3 a 100% sobre grade SQM48 candidata; faixa completa de zoom, terreno e aparelho físico ainda não validados nesta versão. Registrar legibilidade e dispositivo quando testado; não inferir aprovação Android de screenshots desktop. |

**Decisão V3:** manter `corrigir`; não aprovar nem ampliar a produção. A frontalização de S é uma melhora pequena sobre V2, mas não resolve a direção cardinal; o walk continua sem alternância legível e o alpha segue suave. **V2 continua sendo a base de correção preferida** por já ter evidência de importação/escala no Godot e um baseline de âncora mais revisado. V3 serve como referência visual para tentar aproximar S de frente, sem substituir a base enquanto não demonstrar passada melhor e pivô consistente. Aprovação do usuário para ampliar o teste permanece pendente.
