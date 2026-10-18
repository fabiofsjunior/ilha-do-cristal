# Handoff — pranchas isométricas candidatas

Branch de destino: Staging. Base remota: 8dbb01aa516b6cc41dcccb4e70436a1f9130b426.

## 2026-10-18 — pranchas isométricas candidatas

- Adicionadas duas pranchas PNG RGBA 1254 x 1254 em `assets/environments/ilha_cristal_isometric_candidate_v1/`, com prompts e instruções.
- Transparência real confirmada; há pixels semitransparentes residuais. Grade visual 8 x 8 exige recorte manual, pois 1254 não é divisível por 8.
- Sem integração de cenas ou validação visual no Godot. Próxima ação: testar um terreno e uma árvore, ajustando recorte, origem, escala e halos.
- Publicação direta em Staging solicitada pelo usuário, via plugin GitHub.

## Contexto anterior preservado

# Handoff — export Web usando Godot da raiz

**Branch de trabalho:** `feature/s13-web-root-godot`
**Commit da implementação e testes estáticos:** `ffedf27f6779269b1ede965f4008a0d0c8a920a8`
**Base:** `Staging` `533ff4f5cd2e2d84be3caadf2be93facfaf7aa92`

## Implementado

- `Testar_Jogo_Web.bat` procura primeiro `Godot_v4.5.1-stable_win64_console.exe` na raiz, depois outras variantes 4.5.1 console/GUI, e passa o caminho completo para `export_web.py`.
- A busca da raiz ocorre antes da descoberta por configuração, seletor de arquivos e `PATH`. Os fallbacks anteriores permanecem se nenhum executável compatível estiver na raiz.
- README, roadmap, journal e catálogo da Wiki foram atualizados.

## Próxima ação exata

No Windows, deixar o executável Godot 4.5.1 extraído ao lado de `Testar_Jogo_Web.bat` e executá-lo sem configurar `PATH`. Confirmar a exportação em `build/web/` e abertura no navegador; Godot 4.5.1 requer os templates Web instalados.

## Validação e pendências

`tools/wiki/test_catalog.py`, verificações estáticas do `.bat` e `git diff --check` passaram. Este ambiente Linux não pode executar o `.bat` nem fazer exportação real; o teste Windows permanece pendente.
