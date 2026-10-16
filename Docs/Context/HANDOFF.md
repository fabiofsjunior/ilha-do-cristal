# Handoff — testar o recorte solo em Web e Android

**Data:** 2026-10-16 UTC

**Branch:** `feature/fabio-warrior-stage1`

**Checkpoint de código usado nas builds:** `bbba04f8d278f141cef7cb431dbecd22d1c02c49` (publicado). Commits posteriores de entrega atualizam documentação/ferramenta de export.

**Main preservada:** `b3d3f9a0f9405dae020d04785069b55c702f6894`. Somente `main` e `feature/fabio-warrior-stage1` no remoto.

## Próxima ação exata

1. Baixar/extrair `build/ilha-do-cristal-web.zip`; no Windows com Python3, executar `Testar_Jogo_Web.bat`. Em outro sistema, servir a pasta extraída com `python3 -m http.server 8000` e abrir localhost:8000.
2. Instalar `build/android/ilha-do-cristal-debug.apk` em Android ARM, API24 ou superior. Testar menu → aparência Warrior → sessão solo → coleta → craft de curativo → combate/skills → cura → cristal/refúgio → pausa → fechar/reabrir. Testar pausa/retorno do aplicativo, toque, zoom 50–125%, água/colisões, legibilidade em dois tamanhos e 10 minutos de estabilidade. Comparar com UI v0.7.
3. Registrar resultados e falhas no Journal antes de fechar S0/S1/S2. Não promover sprites ou terreno por sucesso de export.

## Entrega e testes

- Godot local na raiz: `Godot_v4.5.1-stable_linux.x86_64`, versão 4.5.1 oficial; não versionado. SDK `/opt/android-sdk`, Java17, templates 4.5.1 Android + Web nothreads; chave debug somente local.
- Exportadores: `python3 tools/build/export_web.py` e `python3 tools/build/export_android.py`. Android/export logs ficam em `build/logs`; `BUILD_INFO.json` e `build/SHA256SUMS.txt` identificam os artefatos. Scripts e versões em `docs/technical/ANDROID_BUILD.md`.
- Import/boot e os dois testes `smoke_playable_slice.gd` / `test_mvp_solo_loop.gd` passaram. Incluem clique/alvo, IA, área segura, coleta/curativo, reward idempotente, camp II/III, save/recovery e rotação limitada a dois slots. Harness de atlas: 240 seleções/48 estados.
- Pacote Web extraído passou smoke headless sem checkout, CRC, compile WASM e servidor HTTP/MIME com caminho contendo espaços. Isso não valida WebGL ou IndexedDB.
- APK passou assinatura v2/v3, manifesto paisagem, min24/target35, sem permissões, CRC e dados de runtime. Não foi instalado neste ambiente. Aviso conhecido: ícone do projeto ausente usa padrão do template debug.
- Resultados, hashes e arquivos alterados: `docs/gameplay/MVP_BUILD_VALIDATION.md`. Regras/controles: `docs/gameplay/MVP_SOLO_TEST.md`.

## Limites preservados

- Recorte solo, quatro aparências Warrior e ilha estática 64×44. Archer/Mage, árvore, chunks/seed, LAN/conta/cloud, baú compartilhado e construções funcionais continuam pendentes. Camp II/III altera custos e nível persistido.
- Raposa/lobo/urso usam uma pose SE estática cada, sem espelhamento ou animação inventada. Alpha parcial, sete direções e ciclos finais permanecem CORRIGIR, approved:false. PNGs existentes de jogadores e os 56 tiles foram preservados.
- `validate_sprite_atlases.py` falha em 21 atlas por alpha; Helena passa estrutura com alertas; strict-art de criaturas falha. Terreno passa estrutura/junções, mas permanece CANDIDATO.
- 12 PNGs fonte antigos de Maíra continuam truncados no histórico. A pasta de referência é isolada do import, sem recuperar ou aprovar a arte.
- Não há dispositivo/emulador/KVM. Chrome local foi bloqueado pelo ambiente e navegador remoto não alcançou o localhost do workspace. Revisão gráfica Godot/Web e aceite Android permanecem pendentes.
