# Handoff — verificar Wiki e launcher Web no Windows

**Branch de destino:** `Staging`
**PRs deste incremento:** #24 (logo/ícone Android) e #25 (servidor Node.js da Wiki e launcher Web).
**Implementação Wiki/Web:** `434054dd2b1970f341e79af454c5bd822e255d43`.

## Implementado

- `Acessar_Wiki.bat` inicia `tools/wiki/serve.js` com Node.js 18+, abre a Wiki e mantém o terminal disponível para Ctrl+C.
- O servidor usa módulos nativos, escuta somente em `127.0.0.1`, atende links e imagens locais da Wiki, redireciona `/` para `/docs/wiki/` e bloqueia áreas privadas/geradas.
- `Testar_Jogo_Web.bat` tenta exportar para `build/web/` quando a pasta não existe. A exportação requer Python 3, Godot 4.5.1 e templates Web.
- A PR #24 adiciona a logo do jogo ao ícone Android, splash e cabeçalho do boot.

## Próxima ação exata

Em um checkout Windows com Node.js 18+, executar `Acessar_Wiki.bat`, navegar por uma página e imagem da Wiki; em seguida executar `Testar_Jogo_Web.bat` com Godot 4.5.1 e templates Web instalados e confirmar que o jogo abre em `build/web/`.

## Pendências e limites

Este ambiente não tem Godot 4.5.1/templates Web, então não foi possível gerar nem abrir a build Web. A exportação da APK 0.1.10/versionCode 11 ainda requer Android SDK Platform 35/Build Tools 35.0.0 e teste em aparelho. As camadas manuais do atlas tropical também aguardam edição/salvamento/reabertura no editor Godot e medição em Android.
