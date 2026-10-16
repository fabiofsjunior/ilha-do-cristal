# Urso — evidência do candidato SE

## Escopo

Um único candidato de aparência estática, voltado para SE, para validar identidade e escala antes de qualquer lote. O urso é fauna comum corrompida do interior: grande e pesado, dorso marrom, focinho claro e cristais azul-violeta discretos; não é boss e não tem gore. O catálogo mantém bear, HP 240, ataque 22, XP 50, com golpe forte anunciado e lento.

## Contrato entregue

- PNG: assets/creatures/bear/bear_se_candidate_v1.png, 128×128 RGBA, 1 coluna × 1 linha.
- Pivô: [64,108]; direção disponível: SE.
- JSON adjacente: assets/creatures/bear/bear_se_candidate_v1.json.
- O metadado declara approved:false, status:"candidate" e qa_status:"CORRIGIR".
- idle tem só uma pose parada, sem variação temporal. Idle final, walk, attack, hit, death e as outras sete direções permanecem pendentes. Nenhuma pose foi duplicada ou espelhada.
- As imagens em docs/art/evidence/bear/ registram o PNG nativo 128×128 e uma visualização nearest 4× (512×512). A ampliação é evidência de inspeção, não render do motor.

## Fonte e empacotamento

As fontes brutas bear_se_source_v1.png e bear_se_source_v2.png ficam em assets/references/generated-candidates/bear/. A primeira geração tinha cristais grandes; a v2 é uma edição imagegen que reduziu esses cristais. O empacotador reproduzível é tools/art/pack_bear_candidate.py.

A fonte v2 mede 1254×1254. O script reamostra o canvas inteiro para 112×112 com nearest-neighbor e coloca o resultado em [8,10] na célula 128×128 para manter o pivô declarado. A redução é lossy: detalhes da fonte são descartados. Nearest não mistura cores, mas não recupera detalhe perdido.

## Resultado da revisão

A pose SE é legível no preview nativo e na ampliação nearest; a silhueta é larga, com focinho claro e três pequenos cristais no dorso. O porte no atlas fica maior e mais largo que o sprite humano de referência. A inspeção visual foi feita fora do Godot; isso não prova importação/render no jogo nem legibilidade Android.

A validação de pixels encontrou 98 valores alfa distintos no candidato: 12.211 pixels totalmente transparentes, 4.158 com alpha intermediário e apenas 15 totalmente opacos. O alpha foi preservado por nearest sampling; não foi limiarizado nem alterado manualmente. Pelo contrato de pixel art opaca estrita, o candidato continua CORRIGIR até que a transparência seja corrigida por imagegen e revalidada.

## Limitações e próxima revisão

- Só existe uma pose SE estática; nenhum ciclo de idle foi entregue.
- N, NE, E, S, SO, O e NO estão pendentes.
- Idle final, walk, attack, hit e death estão pendentes.
- Não houve integração com loader, teste visual em Godot, render em Web, APK ou validação em aparelho.
- O status candidate descreve o estado do arquivo; qa_status CORRIGIR registra a falha conhecida de alpha intermediário.
