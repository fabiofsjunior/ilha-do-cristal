# Handoff — exportação Web com Godot 4.7.2

**Branch de correção:** `feature/s15-web-godot-launch-validation`

**Commit de implementação:** `ff6bc60283e5882dd48906375d6cea6d1d56b644`

**Base Staging da correção:** `186ef56000402936a7fd8e247eb35dc8cbdcf80c`

## Próxima ação exata

No Windows, baixe o [ZIP oficial do Godot 4.7.2 para Windows x64](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip), extraia-o e mantenha o `Godot_v4.7.2-stable_win64_console.exe` extraído na raiz ou escolha-o no seletor do `Testar_Jogo_Web.bat`. Instale os templates Web 4.7.2, execute o launcher e confirme a exportação em `build/web/` e a abertura no navegador.

## Diagnóstico e correção

- O executável versionado na raiz mede 198.152 bytes e falha em `--version` com código Windows `4294967295` (`-1`). Esse arquivo não se comporta como o editor Godot completo: o ZIP oficial para Windows x64 (`Godot_v4.7.2-stable_win64.exe.zip`) mede 86.013.866 bytes.
- O arquivo inválido foi removido do Git. `.gitignore` agora ignora executáveis Godot locais; o usuário pode extrair o binário completo na raiz sem versioná-lo.
- `export_web.py` testa cada candidato com `--version`, ignora binários que não iniciam ou não sejam 4.7.2 e continua a descoberta. Quando um caminho explícito falha, mostra uma mensagem curta com o código/causa e como obter a distribuição oficial.
- `Testar_Jogo_Web.bat` usa a descoberta validada e abre o seletor caso não encontre uma instalação executável. O caminho escolhido continua salvo localmente.

## Limites e pendências

- A validação real do `.bat`, da exportação e da abertura no navegador precisa ser feita no Windows com Godot 4.7.2 e os templates Web da mesma versão.
- Android segue fixado em Godot 4.5.1.
- As pranchas isométricas em `assets/environments/ilha_cristal_isometric_candidate_v1/` continuam candidatas, sem integração nem aprovação visual.
