# Handoff — Kit UI Crystal v2

**Branch:** `feature/s03-crystal-ui-kit-v2`. **Base:** `main` em `46c7a12e8bb547683634e59a3b0e38ae3fb7b30b`. **Último commit de código verificado:** `c66936c2a16a2693550ae6be0652ded6aa77ebef`. Mudanças ainda não integradas em `main`; PR será aberto para revisão.

## Entrega

Kit visual integrado aos fluxos principais da cena: HUD, mochila 24 espaços/equipamento, fabricação e evolução do refúgio, talentos/vocações, seleção de personagem, pausa/ajustes, minimapa e alertas. Atlas fonte em `assets/ui/crystal_v2/sheet.b64`; testes de UI em `tools/gameplay/test_crystal_kit.gd` e `test_crystal_ui_flow.gd`. Guerreiro é a única vocação jogável; Arqueiro/Mago são prévias e talentos passivos continuam indisponíveis. Imagens de personagem dos anexos não estão empacotadas como sprites jogáveis.

## Validação e entregáveis

- Godot 4.5.1: importação, checagem de script principal e os dois testes de UI passaram.
- APK debug: pacote, assinatura, manifesto, launcher/ícones, permissões e integridade verificados. Não instalado nem testado em Android físico.
- Web: exportação Godot 4.5.1 e integridade do ZIP verificadas. Sem inspeção gráfica em navegador.
- Entregáveis locais: `outputs/Ilha-do-Cristal-Android-Preview.apk` e `outputs/Ilha-do-Cristal-Web-Teste.zip`; capturas de inventário e pausa também em `outputs/`. APK usa ID de pacote de preview e assinatura debug, não serve para publicação.

## Próxima ação

Revisar a PR, depois instalar a variante preview num Android e verificar safe areas, toque/multitouch, save e estabilidade por 10 minutos. Rodar também o Web em navegador e revisar renderização/controles. Manter os gates de S0–S3 abertos até aceite integral; essa implementação não fecha vocações Arqueiro/Mago, talentos passivos ou os critérios físicos do roadmap.
