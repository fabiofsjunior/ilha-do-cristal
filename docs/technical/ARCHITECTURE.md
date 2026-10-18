# Arquitetura pretendida — Godot 4 / Android

## Estrutura

`game/project.godot`; `game/scenes/{boot,menus,world,actors,ui}`; `game/scripts/{core,world,combat,inventory,network,save,cloud}`; `game/assets` referencia assets aprovados. `data/*.json` define conteúdo e balanceamento. Scenes são pequenas e compostas; regras puras de dano, XP, drops e inventário são testáveis sem interface. Isolar câmera, movimentação e geração de chunks por responsabilidade, integrando por contratos mínimos; não criar camadas genéricas antes de haver uma segunda necessidade real. Falhas de save, parsing ou rede devem aparecer em log e interface com causa identificável, nunca ser engolidas silenciosamente. IDs estáveis e versão de schema em cada save. Criar arquivos Godot no S0, sem marcar esta arquitetura como implementada.

## Mundo e renderização

Seed + gerador determinístico para costa, água, vegetação, recursos iniciais e regiões. Ilha até 1000×1000 células. Chunks 32×32 por camada lógica (terreno, decoração, colisão, recursos/construções). Carregar/atualizar os próximos aos jogadores, retirar os distantes, manter modificações em memória até gravação. TileMapLayer/TileSet Godot, atlas de arte validado e configurações de pixel-perfect; benchmark em Android define raio ativo. Geração deve garantir praia acessível, madeira/pedra/ervas e rota ao interior.

**Apresentação 2.5D:** first_island.tscn possui Node3D/Camera3D ortogonal. isometric_3d_view.gd apresenta o terreno num plano XZ, projeta props e sprites 2D com billboarding/profundidade, e segue o ator com interpolação. A simulação continua 2D: Vector2(x,y) → Vector3(x/32, altura, y/32). CanvasLayer permanece no viewport; câmera = −30° X, 45° Y. Essa ponte mantém saves e regras do MVP enquanto a migração não inclui malhas 3D navegáveis.

## LAN autoritativa

Host executa simulação e guarda o mundo. Clientes enviam input/intenção com IDs e sequência; host valida distância, mana, cooldown, ownership de item e atualiza eventos/snapshot. Colheita, construção e drop precisam de IDs únicos e processamento idempotente. Enviar estado dos chunks relevantes, não milhão de tiles. Descoberta automática em LAN é protótipo a validar; fallback de entrada por IP local/código. Android requer permissão de rede no export. Não transferir host no MVP. Se host sair ou rede cair, salva checkpoint, encerra sessão e exibe estado; cliente não escreve no save de mundo.

## Saves e nuvem

`user://worlds/<world_id>/` no aparelho do host: manifesto `{schema_version, seed, generator_version, world_id, timestamp}`, alterações por chunk, construções, baús, itens de mundo e mochilas. Gravar após construção/transação crítica, ao pausar/sair, e a cada 2 minutos **se houve alteração**. Serializar snapshot consistente; escrever arquivo temporário, conferir integridade/checksum, trocar para slot ativo mantendo cópia anterior; ao recuperar escolher último slot válido. Simular app encerrado e pouco espaço. Sem salvamento da ilha na nuvem no MVP; exportar/backup manual pode vir depois. Desinstalação/apagamento do host pode eliminar mundo, informar na UI.

Progresso pessoal na conta: ID de personagem, aparência, vocação permanente, nível, XP acumulado, atributo bruto, talentos, versão e revisão. Inventário/equipamento do mundo permanece no save do host para evitar transportar itens/duplicar entre mundos. Firebase Spark é decisão inicial; criar adaptador `CloudProgress` com implementação local de teste e prova de integração Auth/Firestore Godot Android antes de assumir SDK. Visitante offline pode jogar; ao vincular conta, associar uma única identidade e resolver divergência usando revisão monotônica do personagem, nunca soma ingênua de XP ou itens. Operações offline entram em fila idempotente; sincronizar em checkpoints e reconexão, jamais por frame. Regras de segurança restringem cada documento ao dono; nenhum segredo privilegiado embutido no APK.

## Atualização de conteúdo

O autoload `ContentUpdater` verifica Releases públicos do GitHub antes da cena de jogo. Releases `content-vX.Y.Z` entregam um PCK de dados e imagens permitidos pelo preset Android; cenas e scripts exigem APK novo. O cliente compara versão, compatibilidade do app, tamanho e digest SHA-256 do asset, baixa para `user://updates/`, monta com `ProjectSettings.load_resource_pack()` e recarrega a cena principal. O registro da versão ativa permite montar o mesmo PCK na inicialização seguinte; saves ficam em seus diretórios existentes. Ver detalhes do contrato em [GITHUB_CONTENT_UPDATES.md](GITHUB_CONTENT_UPDATES.md).

## Validação técnica

Testes de geração determinística, integridade do save/corrupção, cálculo XP e dano, recompensas uma vez, disconnect/rejoin, tempo de load, FPS e memória em dois aparelhos Android. Não construir conta antes de provar loop local/saves; não considerar protótipo no editor evidência de Android. Desktop reaproveita lógica de input e UI adaptativa, sem virar plataforma prioritária.

Docs oficiais: [export Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), [multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html), [dados `user://`](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html), [Firebase preços](https://firebase.google.com/pricing).

## Estado concreto da reconstrução 0.1.9

A simulação permanece Node2D e a apresentação Camera3D; a perspectiva e as regras do jogo não mudaram. A fonte visual do terreno agora é `game/scenes/first_island.tscn`: `BaseTiles` guarda 50.000 células, `Transitions` 645 e `Paths` 15. As camadas compartilham `assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.tres`, com 56 tiles do atlas. `first_island.gd` valida as camadas sem recriá-las, e `isometric_3d_view.gd` projeta todas as células dessas camadas, inclusive a área inicial 64×44. Assim uma edição salva na cena aparece na apresentação e no minimapa sem repintura ao iniciar. O atlas tropical fornecido foi importado separadamente: `ManualTerrain` usa 40 slices de superfície e `ManualProps` 24 slices de decoração, em células 128×128 px (4×4 SQMs). Ambas começam vazias, mantêm o mapa existente como referência e suas edições visuais são projetadas no renderer 2.5D/minimapa.

`first_island_layout.json` continua definindo limites, faixa de água bloqueada, spawns, obstáculos e recursos; editar o terreno na cena não altera colisões ou gameplay. `first_island_tiles.json` e `tools/world/bake_first_island.py` permanecem como referência/ferramenta de migração legada, não como fonte do mapa em runtime. A validação estática comparou a serialização das três camadas com os índices JSON de origem. A confirmação de importação, edição/salvamento no editor Godot 4.5.1 e desempenho Android continua pendente. `minimap_camera_view` fornece origem/vetores do frustum no chão para o mesmo recorte no minimapa.

As criaturas agora são instanciadas por espécie em `game/scenes/creatures/{creature_base,fox,wolf,bear}.tscn`. A cena base contém o `CharacterBody2D`, a cápsula de navegação e as áreas circulares de detecção/ataque; cada cena herdada tem recursos de colisão próprios e exibe a textura correta em `StaticCandidatePoseSE` para ajuste visual no editor. `creature_actor.gd` reutiliza a sprite serializada em runtime, consome as formas salvas e mantém seu cálculo de contato visual. `first_island.gd` usa as cenas por espécie nos spawns e respawns, sem reconstruir formas em runtime.

`LanSession` no main mantém caminho RPC estável, ENet UDP27840 e descoberta UDP27841. O código6 identifica sala descoberta no Wi-Fi. Somente movimento é validado/replicado; modelos de combate e inventário ainda rodam localmente. A arquitetura autoritativa de transações descrita acima permanece alvo, não implementação atual. Ver LAN_MOVEMENT_PREVIEW.md.
