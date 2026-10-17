# Handoff — Kit UI Crystal v2

**Branch:** `feature/s03-crystal-ui-kit-v2`. **PR:** [#21](https://github.com/fabiofsjunior/ilha-do-cristal/pull/21), ainda em revisão. **Commit do APK:** `28dee2d3df72dd3ba225eefd624c2859f476c2e0`; código do jogo exportado em `c66936c2a16a2693550ae6be0652ded6aa77ebef`.

## Entrega

Kit visual integrado aos fluxos principais: HUD, mochila/equipamento, fabricação/refúgio, talentos/vocações, seleção de personagem, pausa, minimapa e alertas. O spritesheet de runtime está em `assets/ui/crystal_v2/sheet.b64`; testes de UI em `tools/gameplay/test_crystal_kit.gd` e `test_crystal_ui_flow.gd`. Guerreiro segue como única vocação jogável; Arqueiro/Mago são prévias e talentos passivos continuam indisponíveis. Os conceitos de personagem enviados não foram adicionados como sprites jogáveis.

## APK e validação

O APK está versionado em `artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk` nesta branch. [Baixar diretamente](https://raw.githubusercontent.com/fabiofsjunior/ilha-do-cristal/feature/s03-crystal-ui-kit-v2/artifacts/preview/Ilha-do-Cristal-Android-Preview-arm64.apk). É uma variante debug de 39.337.295 bytes, ID `com.fabiofsjunior.ilhadocristal.preview`, somente `arm64-v8a`; aparelhos apenas 32 bits não são compatíveis. A variante foi derivada do APK de preview Godot dual-arch, removendo a biblioteca ARMv7, reempacotada e assinada novamente. SHA-256: `9d723315cae0bfe5f4f68c88527484e618e61897ddcef0be0de8489c25b9e88a`.

Godot 4.5.1: importação, checagem do script principal e os dois testes de UI passaram. Manifesto, ID/label, ícones, permissões, dados de runtime, integridade ZIP e assinatura v2/v3 do APK passaram. APK ainda não foi instalado nem testado em aparelho. Web foi exportado e o ZIP verificado; falta inspeção gráfica em navegador. ZIP Web e capturas seguem na pasta de entregas local.

## Próxima ação

Revisar a PR, instalar a variante ARM64 num Android compatível e conferir safe areas, toque/multitouch, save e estabilidade por 10 minutos; revisar também o Web em navegador. Manter os gates S0–S3 abertos até os aceites completos; vocações Arqueiro/Mago, talentos e os critérios físicos continuam pendentes.
