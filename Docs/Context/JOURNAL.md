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
