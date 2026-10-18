# Handoff — identidade visual do aplicativo Android

**Branch:** `feature/s08-logo-app-icon-splash`

**Base:** `Staging` em `5a1d4a0`

**Implementação:** `e0a1a2d` + `eb75383` — ícone/boot e correção do blob da fonte original.

**PR:** [#24](https://github.com/fabiofsjunior/ilha-do-cristal/pull/24), rascunho contra `Staging`.

**Versão planejada:** APK 0.1.10, `versionCode` 11.

## Implementado

- Fonte original em `tools/art/source/ilha-cristal-logo.jpg`, preservada byte a byte. As variantes são reproduzidas por `python3 tools/art/generate_app_icon.py`.
- Ícone clássico com a arte integral (512×512); camadas adaptativas Android (432×432) com a wordmark dentro da área segura; símbolo de cristal monocromático para temas Android.
- Splash nativa da Godot e cabeçalho da tela de atualização usam o ícone com a logo. O restante do fluxo e a gameplay não mudaram.
- O preset Android já referencia os quatro caminhos `assets/ui/app_icon*.png`.

## Verificações

- Godot 4.5.1: importação headless, `test_update_boot_ui.gd` e `test_content_updater.gd` passaram.
- Confirmadas dimensões e alpha das quatro variantes, igualdade da fonte com o anexo, configurações da splash, `py_compile` e `git diff --check`.
- A importação mostrou apenas o aviso de ADB sem daemon/dispositivo.

## Pendências e próximo passo

Android SDK Platform 35 e Build Tools 35.0.0 não estão disponíveis neste ambiente; não foi possível exportar ou instalar a APK, nem conferir máscaras adaptativas em aparelho. Quando o SDK estiver disponível, exportar a APK 0.1.10/versionCode 11, instalar e conferir o ícone clássico/adaptativo, splash nativa e logo no boot em retrato/safe area.
