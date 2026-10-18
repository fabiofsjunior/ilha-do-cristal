# Handoff — export Web com Godot 4.7.2

**Branch de trabalho:** `feature/s14-web-godot-472`
**Base:** `Staging` `8dbb01aa516b6cc41dcccb4e70436a1f9130b426`

## Implementado

- O exportador Web agora exige a versão `4.7.2.stable.*`, correspondente ao executável relatado pelo usuário.
- O launcher prioriza o Godot 4.7.2 da raiz e passa o caminho explícito. A busca considera o executável console ou GUI; caminhos locais antigos ficam atrás da descoberta de versões 4.7.2.
- Mensagens do launcher, servidor, README, roadmap e instruções de exportação Web foram alinhados. O exportador Android continua validando Godot 4.5.1.

## Próxima ação exata

No Windows, manter `Godot_v4.7.2-stable_win64_console.exe` ao lado de `Testar_Jogo_Web.bat`, com os templates Web 4.7.2 instalados, e executar o launcher para confirmar exportação em `build/web/` e abertura no navegador.

## Validação e pendências

Checagem Python da versão, preferência pelo binário da raiz, `py_compile`, suíte da Wiki e `git diff --check` passaram. Não foi possível executar o `.bat` nem exportar neste ambiente Linux; compatibilidade do preset Web com a instalação local 4.7.2 aguarda teste no Windows.
