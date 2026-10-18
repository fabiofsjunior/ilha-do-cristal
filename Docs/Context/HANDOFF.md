# Handoff — templates Web Godot 4.7.2

**Branch:** `feature/s16-web-template-install`

**Base Staging:** `cd7c0c726fa7cb7800b73c47e4985cc16732cdf2`

**Commit de implementação:** `6260c52afa93238782c0d81b7c595a24fcd42306`

**PR #34:** https://github.com/fabiofsjunior/ilha-do-cristal/pull/34

## Próxima ação exata

No Windows, execute `Testar_Jogo_Web.bat` na raiz. Se o launcher encontrar templates ausentes, responda `S` para abrir o Godot 4.7.2. No editor, abra `Editor > Gerenciar modelos de exportação`, selecione somente `Web` e clique em `Instalar modelos selecionados`. Feche o editor; o launcher verificará os arquivos e continuará com a exportação e a abertura do navegador. Se responder `N`, instale os templates manualmente e execute o `.bat` novamente.

## Alterações

- `export_web.py` procura os arquivos `web_nothreads_debug.zip` e `web_nothreads_release.zip` em `4.7.2.stable`, informa os caminhos ausentes e oferece `--check-web-templates` para o launcher.
- `Testar_Jogo_Web.bat` abre o editor apenas quando os templates faltam, explica como instalar Web e aguarda o editor fechar antes de repetir a verificação.
- README, roadmap, journal e índice da wiki registram o fluxo.

## Verificações e limites

- Passaram `py_compile`, teste de CLI com executável Godot simulado para os cenários de templates ausentes/presentes, geração de `docs/wiki/catalog-data.json` e `git diff --check`.
- `python3 tools/wiki/test_catalog.py` falha no teste de runtime da Wiki introduzido em Staging depois do teste inicial: o mock de DOM em `tools/wiki/test_runtime.js` não define `document.documentElement`, usado pelo alternador de tema (`docs/wiki/app.js:37`). Isso é independente do exportador Web e fica como pendência separada.
- O `.bat`, a instalação dos templates, a exportação e a abertura no navegador ainda precisam de confirmação no Windows com Godot 4.7.2.
- Android continua fixado em Godot 4.5.1; esta correção é somente para exportação Web.

## Cenas de criaturas — prévia visual dos colisores

As cenas `game/scenes/creatures/fox.tscn`, `wolf.tscn` e `bear.tscn` agora mostram a sprite `StaticCandidatePoseSE` no editor, com atlas e pivô equivalentes ao carregador de arte. `creature_actor.gd` reutiliza esse nó em runtime para evitar uma segunda sprite. Próxima ação: ajustar as formas de colisão sobre a imagem no canvas, salvar/reabrir e revisar o encaixe visual. A importação/reimportação headless passou; a execução de uma cena e do teste de contato encerrou com falha nativa (signal 11), portanto essa execução não foi confirmada nesta atualização.
