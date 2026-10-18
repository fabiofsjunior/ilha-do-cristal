# Prévia LAN de movimento

`game/scripts/network/lan_session.gd` é componente do nó principal, com caminho RPC estável. Hospedar cria servidor ENet em UDP 27840, limitado a um cliente (dois jogadores). O cliente entra por IP ou código de seis caracteres descoberto por broadcast UDP 27841. O código identifica sala descoberta na mesma rede; não é serviço de conexão pela internet. Roteadores com isolamento entre clientes ou bloqueio de broadcast exigem desativar o isolamento; o IP é alternativa para descoberta bloqueada.

A sala anuncia protocolo e código uma vez por segundo; anúncios expiram após quatro segundos. O cliente envia a aparência e SHA-256 do layout fixo antes de entrar. Layout diferente é recusado. Não se gera mapa procedural ao conectar. O host define o ponto inicial do cliente ao seu lado.

O cliente prevê seu movimento local e propõe posições a 20 Hz. O host limita deslocamento a 165 px/s mais tolerância de 2 px por pacote, aplica `move_and_collide` no corpo remoto e devolve posições aceitas. Divergências superiores a 40 px corrigem a previsão. Não há sincronização de combate, monstros, itens, coleta ou saves nesta fatia: esses sistemas continuam locais e são a próxima integração. Portanto esta prévia serve para comprovar conexão e movimento, não uma expedição cooperativa completa.

## Verificação

Godot 4.5.1, dois processos headless locais com `tools/gameplay/test_lan_movement.gd -- host` e `-- client`: handshake de aparência/layout, movimento aceito pelo servidor, recusa de teleport de 10.000 px e posições NaN, remoção do jogador ao desconectar. Cenários adicionais `-- host mismatch` / `-- client mismatch` e `-- host hostloss` / `-- client hostloss` passaram: mapa incompatível é recusado e encerramento do servidor é detectado pelo cliente. O teste usa mundo mínimo sem biomas para isolar transporte; não prova UI Android ou broadcast em roteador físico.

Teste físico pendente: instalar o mesmo APK em dois Androids no mesmo Wi-Fi, hospedar e anotar o código, localizar a sala no segundo, entrar por código e por IP, andar em ambos, bloquear-se contra obstáculo e desconectar. Conferir que o remoto aparece no chão, com orientação e animação corretas. Validar negação de permissão/rede indisponível e saída pela pausa. Registrar aparelhos, roteador e resultados; não marcar LAN Android concluída antes disso.
