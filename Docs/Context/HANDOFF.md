# Handoff — catálogo wiki offline

Branch: `feature/s03-game-wiki`; baseline `f64c207` (main após PR #18). O commit local desta entrega está no `HEAD` da branch; confira `git rev-parse --short HEAD` no checkout desta branch.

Wiki em `docs/wiki/`: `index.html`, `wiki.css`, `app.js` e `catalog-data.json`. O gerador `tools/wiki/build_index.py` deriva dados do catálogo de planejamento, layout/aparências do recorte e previews/metadados dos PNGs. Para atualizar: `python3 tools/wiki/build_index.py`. Para validar: `python3 tools/wiki/test_catalog.py`. Execução offline: servidor simples na raiz (`python3 -m http.server 8000`) e `http://localhost:8000/docs/wiki/`.

Escopo exclusivamente de catalogação; nenhum comportamento do jogo foi alterado. O catálogo de `data/catalogs/mvp.json` continua identificado como planejamento/provisório; arte sem aprovação é marcada como candidata ou sem status declarado. O teste automatizado confirmou 4 aparências, 3 vocações, 9 habilidades, 74 previews, 368 arquivos, renderização de busca/filtros/paginação, links, sintaxe JS e respostas locais HTTP.

Próxima ação: revisar a wiki no fluxo integrado e depois continuar as validações pendentes do recorte S3 em Android físico antes de fechar a fase. Bloqueadores desta wiki: nenhum. Questões em aberto: nenhuma.
