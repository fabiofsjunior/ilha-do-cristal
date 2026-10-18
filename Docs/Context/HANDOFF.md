# Handoff — servidor Node.js da Wiki e launcher Web

**Branch:** `feature/s09-node-wiki-server`

**Base:** `Staging` em `9f43dad7d0d1d931914401eb8a83ac590fb4ee90`.

**Commit de implementação no PR:** `434054dd2b1970f341e79af454c5bd822e255d43`.

**PR:** [#25](https://github.com/fabiofsjunior/ilha-do-cristal/pull/25), rascunho contra `Staging`.

## Implementado

- `Acessar_Wiki.bat` na raiz inicia `tools/wiki/serve.js` com Node.js 18+, abre o navegador na wiki e mantém o terminal disponível para encerrar com Ctrl+C.
- O servidor usa somente módulos nativos, fica acessível apenas em `127.0.0.1`, usa a porta 8000 ou escolhe outra livre, e redireciona `/` para `/docs/wiki/`.
- Links da wiki continuam funcionando para documentação e previews. O servidor bloqueia diretórios ocultos/gerados, builds e arquivos privados de assinatura/save.
- `Testar_Jogo_Web.bat` tenta exportar para `build/web/` antes de servir quando não encontra a build. A exportação requer Python 3, Godot 4.5.1 e templates Web.

## Verificação e limites

- `python3 tools/wiki/test_catalog.py` passou; verifica catálogo, links e imagens, abre a Wiki pelo servidor Node, segue o redirecionamento da raiz, testa GET/HEAD e confirma que `.git` e `build` ficam bloqueados.
- `node --check`, `py_compile` e `git diff --check` passaram.
- Não foi possível exportar o jogo Web neste ambiente: Godot 4.5.1 e os templates Web não estão instalados aqui. O launcher agora tenta exportar automaticamente no checkout Windows quando essas ferramentas existem.

## Próxima ação

Revisar e integrar o PR #25. Depois, no checkout Windows, executar `Acessar_Wiki.bat` para consultar a documentação e `Testar_Jogo_Web.bat` para gerar/abrir a build Web.
