# Handoff — Godot 4.7.2 Web e pranchas candidatas

**Branch de trabalho Web:** `feature/s14-web-godot-472`
**Commit da implementação Web:** `c0fd9d63099ea92e326f23f0b9ba301cd7c1c5b5`
**Base `Staging` atual:** `fb95bdfdcdab2f3857d1007a64102fabf808fc08`

## Próxima ação exata

No Windows, manter `Godot_v4.7.2-stable_win64_console.exe` ao lado de `Testar_Jogo_Web.bat`, com os templates Web 4.7.2 instalados, e executar o launcher. Confirmar exportação em `build/web/` e abertura no navegador.

## Correção Web preparada

- O launcher, exportador e servidor Web agora exigem Godot 4.7.2; o `.bat` prioriza o executável 4.7.2 da raiz e passa o caminho absoluto.
- A descoberta de versões 4.7.2 ocorre antes de reutilizar `.godot-path`, para não escolher um executável antigo. Android segue fixado em 4.5.1.
- CLI simulado aceitou `4.7.2.stable.official.ed1daf0bf` e recusou 4.5.1. A prioridade do binário da raiz também foi testada. Build real não foi executada neste Linux.

## Pranchas isométricas candidatas

- Duas imagens RGBA 1254×1254 e seus prompts/instruções ficam em `assets/environments/ilha_cristal_isometric_candidate_v1/`.
- Transparência real foi confirmada, mas restam pixels semitransparentes e a grade 8×8 requer recorte manual. Nenhuma cena foi integrada nem validada no Godot.
- Depois do teste Web, testar uma superfície e uma árvore no Godot, ajustando recorte, origem, escala e halos.

## Pendências

Godot 4.7.2 e templates Web ainda precisam ser testados no Windows; compatibilidade do preset Web permanece sem validação de exportação nesta sessão. As pranchas continuam candidatas, aguardando revisão na cena.
