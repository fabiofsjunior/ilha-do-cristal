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

## Validação técnica

Testes de geração determinística, integridade do save/corrupção, cálculo XP e dano, recompensas uma vez, disconnect/rejoin, tempo de load, FPS e memória em dois aparelhos Android. Não construir conta antes de provar loop local/saves; não considerar protótipo no editor evidência de Android. Desktop reaproveita lógica de input e UI adaptativa, sem virar plataforma prioritária.

Docs oficiais: [export Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), [multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html), [dados `user://`](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html), [Firebase preços](https://firebase.google.com/pricing).

## Estado concreto da reconstrução 0.1.9

A simulação permanece Node2D e apresentação Camera3D, sem migração de perspectiva. `first_island_tiles.json` contém índices fixos de50mil tiles; `tools/world/bake_first_island.py --check` verifica determinismo. O loader pinta batches existentes, sem gerar topologia no startup. `minimap_camera_view` fornece origem/vetores do frustum no chão para o mesmo recorte no minimapa.

`LanSession` no main mantém caminho RPC estável, ENet UDP27840 e descoberta UDP27841. O código6 identifica sala descoberta no Wi-Fi. Somente movimento é validado/replicado; modelos de combate e inventário ainda rodam localmente. A arquitetura autoritativa de transações descrita acima permanece alvo, não implementação atual. Ver LAN_MOVEMENT_PREVIEW.md.
