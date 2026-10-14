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
| Importação Godot 4 | pendente | relatório de importação |
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
