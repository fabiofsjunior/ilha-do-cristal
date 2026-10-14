# Fluxo para agentes

Ler README, GDD, roadmap, arquitetura e registro de decisões antes de editar. Uma entrega reproduzível por branch `feature/sNN-descricao` ou `docs/descricao` e PR. Não transformar visão futura em escopo do MVP. Registrar decisões alteradas em `docs/production/DECISIONS.md`.

Cada sprint entrega critério de aceite demonstrável, teste do fluxo afetado, verificação em APK Android quando houver interface/rede/save, evidência de execução e documentação atualizada. Não considerar Android validado somente pelo editor. Antes de merge: revisão de diff, verificações de importação Godot, cenas/dados, APK em pelo menos um aparelho; rede em dois aparelhos; interrupção de save e reconexão quando aplicável. Usar definições de conteúdo em `data/` em vez de números espalhados por scripts.

Nunca commitar fotos originais das crianças, saves reais, credenciais Firebase, keystores ou arte gerada ainda sem slice/validação como se fosse atlas. Prancha em `assets/references/` é apenas referência. Preferir soluções oficiais Godot e dependências mínimas. Ao concluir um sprint, listar limites reais e próximos riscos.

Capacidades pesquisadas: skill `imagegen` para conceitos e variantes; documentação oficial Godot para exportação Android, TileMapLayer, rede e `user://`; revisão de segurança antes de autenticação e cloud save. Busca de plugins encontrou `Superpowers` (planejamento/testes), não instalado nem exigido. Nenhuma skill específica Godot foi confirmada. `supabase` só se o backend mudar.
