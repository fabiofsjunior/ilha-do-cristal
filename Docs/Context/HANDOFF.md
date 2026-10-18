# Handoff — atualizador de conteúdo Android

**Branch:** `feature/s07-github-content-updater`

**Base:** `main` em `e38821d` (reconstrução 0.1.9)

**Implementação:** `9d54f6a` — atualizador de conteúdo hospedado em GitHub Releases.

## Implementado

- No Android, o jogo consulta as Releases públicas no início e oferece atualizar quando encontra `content-vX.Y.Z`. Atualização obrigatória bloqueia a entrada até concluir; opcional permite continuar offline.
- O cliente baixa o PCK, valida tamanho e SHA-256, monta o conteúdo, salva o ponteiro ativo e reinicia a cena. Ao abrir de novo, restaura o pacote ativo. Os saves continuam no armazenamento privado do jogo.
- O atualizador aceita apenas assets com o nome esperado e URLs de GitHub, com limite de 512 MB. Atualização do próprio APK fica separada e abre a página de Releases para instalação confirmada pelo usuário.
- Web segue direto para gameplay. O exportador do PCK e os testes estão em `tools/build/` e `tools/updater/`; o fluxo e o protótipo aprovado estão documentados em `docs/technical/GITHUB_CONTENT_UPDATES.md` e `docs/prototypes/content_update_v0_1.html`.
- APK planejado: versão 0.1.10, `versionCode` 11. Pacote local de teste `content-v1.0.1`: 9.832.456 bytes, SHA-256 `5fb2a510e3110a68e78008f5e9c246e33919b6205a7184a457c4949346c00f8e`.

## Verificação e limites

- Godot 4.5.1: importação headless, `test_content_updater.gd`, `test_update_boot_ui.gd`, montagem/leitura do PCK em `test_content_pack.gd`, `smoke_playable_slice.gd`, `py_compile` e `git diff --check` passaram sobre a base atual.
- A API do repositório não contém Releases públicas. O pacote de teste não foi publicado; então ainda não houve atualização remota real. A consulta do jogo a GitHub também não pôde ser validada neste runtime, cuja saída de rede é restrita.
- Android SDK Platform 35 e Build Tools 35.0.0 não estão instalados aqui. Não foi exportado ou instalado APK 0.1.10 e não houve teste em dispositivo físico.

## Próxima ação

Revisar o PR; depois configurar SDK/templates Android, exportar e instalar 0.1.10, validar fluxo online/offline e preservação de save em aparelho, e só publicar um Release de conteúdo quando houver conteúdo aprovado para atualizar. Não usar o PCK de teste como release de produção.
