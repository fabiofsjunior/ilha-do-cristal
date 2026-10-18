# Handoff — Reconstrução 0.1.9

**Branch:** `feature/s03-crystal-ui-kit-v2`. **Commit de código/APK:** `5f14e623f6787e97e1f6b4aa58778cd132f247f8`. A atualização documental subsequente fica no HEAD da mesma branch. Baseline remoto recuperado: `2a1784d`. Não fazer merge em main sem os aceites pendentes.

## Entrega persistida

HUD spells144×144/equipamentos96×96, inventário com scroll, painéis exclusivos, engrenagem e minimapa circular orientado pelo frustum/zoom. Mapa fixo250×200 prebaked e50mil tiles;24lobos/2raposas/4ursos. Três vocações com mecânicas locais/VFX e saves separados por vocação; sprites de aparência Warrior continuam compartilhados. LAN ENet para2jogadores, descoberta/código/IP e movimento com validação do host. Combate/monstros/coleta/itens/saves continuam locais.

**APK:** `build/android/ilha-do-cristal-hud-rebuilt.apk`, debug preview, versionCode10/0.1.9, ARMv7+ARM64, Godot4.5.1. Metadados/SHA em `artifacts/preview/HUD-0.1.9.json`; APK/ZIP entregues como anexos persistentes da conversa. O APK ARM64 versionado anteriormente é histórico e não deve ser anunciado como atual.

## Testes e limites

Import e catálogo/bake Python; HUD/mínimap/inventário/safe area/atributos/visão/fluxo; mapa/população; vocações/combate/cooldown/save; morte/loop/regen/smoke passaram. LAN dois processos: movimento, NaN/teleport, incompatibilidade de mapa e queda do host. Comparação gráfica Godot sob Xvfb feita, capturas no relatório `docs/gameplay/HUD_RECONSTRUCTION_019.md`. APK manifesto/recursos/CRC/assinatura/permissões passou. Não instalado nem testado em Android físico. Nova reconstrução, não APK idêntico ao binário perdido.

## Próxima ação exata

Implementar uma intenção de ataque enviada pelo cliente ao host, com sequência/ownership, validação de alvo/distância/mana/cooldown e evento autoritativo único de dano/estado/XP; testar em2processos antes de ampliar. Depois coleta/drop idempotentes e saves de mundo/inventário somente no host. Instalar o mesmo APK em dois Androids na mesma rede e validar lobby/código/IP/movimento/pausa/atributos/desconexão/UI/toque/save.

## Pendências abertas

Teste físico Android, combate/itens/saves LAN e talentos passivos. Terrain Sets64×32/elevações e atlas mais polidos precisam de assets/amostra apropriados e validação, sem trocar a perspectiva ou expandir arte silenciosamente. Protótipos de lobby/vocação/HUD já foram aprovados nesta conversa; não pedir novamente para a mesma reconstrução. Godot/SDK/chave debug/saves e build ficam fora do Git.
