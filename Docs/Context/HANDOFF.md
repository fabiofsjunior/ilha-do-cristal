# Handoff — validar launcher Web no Windows

**Branch do ajuste:** `feature/s12-web-godot-discovery`
**Commit:** `0c38bff95f7c7b4ef110f6401c92bbb94e796b92`
**PR:** [#27](https://github.com/fabiofsjunior/ilha-do-cristal/pull/27), destino `Staging`
**Base da PR:** `0d87452ceebf51271b121daaaec8cd0fc953a43d`

## Implementado

- `Testar_Jogo_Web.bat` tenta exportar `build/web/` quando não encontra a build. O exportador procura Godot 4.5.1 no `PATH`, em pastas comuns do Windows, em `GODOT_BIN` e no caminho local `.godot-path`.
- Se não encontrar, o launcher abre o seletor de arquivos do Windows. O caminho selecionado fica salvo localmente e a versão 4.5.1 é validada antes da exportação.
- A exportação requer Python 3, Godot 4.5.1 e templates Web dessa mesma versão. Com uma build já existente em `build/web/`, o servidor inicia sem Godot.
- `Acessar_Wiki.bat` continua iniciando a Wiki local por Node.js.

## Próxima ação exata

Em um checkout Windows atualizado pela PR deste branch, executar `Testar_Jogo_Web.bat`, selecionar `Godot_v4.5.1-stable_win64_console.exe` se solicitado, confirmar os templates Web e verificar que o jogo exporta em `build/web/` e abre no navegador.

## Pendências

- O seletor PowerShell do launcher ainda precisa de validação em Windows. Neste ambiente Linux não há Godot 4.5.1, então a exportação e abertura Web não foram testadas.
- Revisar a execução gráfica Web no navegador.
- Abrir as cenas herdadas em `game/scenes/creatures/` no editor, ajustar as formas por sprite, salvar/reabrir e revisar visualmente o contato.
- Exportar a APK 0.1.10/versionCode 11 com Android SDK Platform 35 e Build Tools 35.0.0 e testar em aparelho.
