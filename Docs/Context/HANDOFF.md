# Handoff — correção mobile 0.1.7

Branch: feature/s02-mobile-ui-017, baseline main a1a47165d083057b45e7ee0a9235808ce244d11d. Esta entrega integra UI clássica, profundidade/pivôs, câmera e minimapa completo. O commit/árvore exatos exportados são registrados em build/android/BUILD_INFO.json; consulte o head da PR de integração para o código remoto.

A referência visual veio dos anexos 3/4 selecionados pelo usuário; capturas reais de comparação estão em docs/art/evidence/mobile_017/. Ver docs/gameplay/MOBILE_UI_017_VALIDATION.md para mudanças, testes e limites. A arte dos personagens/criaturas não foi reclassificada como aprovada.

Godot 4.5.1, SDK 35 e JDK17 foram preparados. A chave antiga da 0.1.6 não existe neste ambiente; gerar a variante --parallel-install para instalar ao lado do app antigo e preservar seus saves. Package preview e progresso separados. Não enviar chaves ao Git.

Próxima ação: instalar 0.1.7 de teste no Android do usuário; verificar ordem do terreno/atores, minimapa vermelho, ícones, legibilidade, alocação/confirmar/resetar, coleta/cura/save e estabilidade. Não declarar aceite físico nem FPS mobile com base nos testes Mesa. Web permanece na exportação anterior.
