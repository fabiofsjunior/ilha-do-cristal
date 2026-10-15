# Helena Warrior — oito direções, idle e walk

**Resultado visual: CORRIGIR.** Este pacote amplia o candidato Helena Warrior para N, NE, E, SE, S, SW, W e NW. Ele não está aprovado para produção: os PNGs mantêm alpha suave/halo, as fases de caminhada não podem ser confirmadas com segurança nas oito direções e há deriva do pivô em várias linhas.

## Artefatos

- `assets/characters/helena/warrior/helena_warrior_idle_candidate_v2.png` e `.json`
- `assets/characters/helena/warrior/helena_warrior_walk_candidate_v2.png` e `.json`
- `assets/references/generated-candidates/helena_warrior_*_source_*.png` — fontes geradas preservadas sem retoque; as duas tentativas de NE idle/walk e a tentativa de correção de alpha E walk também foram mantidas.
- `docs/art/evidence/helena/helena_warrior_8dir_contact.png` — prancha idle/walk sobre quadriculado, nearest-neighbor 2×.
- `docs/art/evidence/helena/helena_warrior_8dir_structure.json` e `helena_warrior_8dir_validation.json` — estrutura, hashes e medições por quadro.
- `tools/art/pack_helena_8dir.py` e `tools/art/validate_helena_8dir.py` — empacotador e validador reproduzíveis.

Os atlas usam células de 96×96, pivô candidato (48,80), idle com quatro quadros a 6 fps e walk com seis quadros a 10 fps. A ordem das linhas é N, NE, E, SE, S, SW, W, NW. A referência oficial de Helena foi conferida pelo Git blob `82a60ab282c23d0e6846a10a2d8b5e8614537ac3`; ela não foi cortada para criar sprites.

## QA estrutural

`python tools/art/validate_helena_8dir.py` passou nos contratos de tamanho, direção, pivô candidato, região de cada quadro, hash das fontes e visibilidade dentro das células. N e S foram copiados pixel a pixel dos atlas v1 e comparados de novo pelo validador; os candidatos e fontes v1 permanecem intactos. O cabeçalho do conceito também bate com o Git blob esperado.

O validador geral `tools/art/validate_sprite_atlases.py` retornou código 1 para os dois atlas v2 por valores de alpha intermediários; não encontrou erro estrutural específico nesses atlas. Alpha intermediário total: 56.696 pixels no idle e 84.048 no walk; o walk não tem pixels com alpha 255. Isso inclui o alpha do candidato legado N/S e dos quadros novos. Uma tentativa direcionada de corrigir o halo da fonte E walk foi preservada, mas continuou sem pixels opacos (alpha máximo 254); parei novas tentativas de limpeza. Nenhuma binarização ou remoção automática de halo foi aplicada.

## Revisão visual por direção

Os eixos cardinais foram revisados primeiro na prancha de caminhada ampliada; as diagonais foram avaliadas em seguida. E e W mostram perfil lateral para lados opostos. N mostra as costas e S a frente. As diagonais NE, SE, SW e NW são distinguíveis como quadrantes, mas a consistência de câmera em 45°, equipamento e silhueta requer nova revisão de arte.

| Direção | Idle | Walk: base visível relativa ao pivô Y=80 por quadro | Resultado |
|---|---|---:|---|
| N | V1 preservado; animação quase estática | `+2, +2, +2, -2, -2, -2` | CORRIGIR: desvio vertical herdado e alpha suave/halo. |
| NE | Poses quase estáticas; diferença de altura entre quadros | `-3, -7, -4, -6, -11, -7` | CORRIGIR: drift de até 8 px dentro da linha e pé chega a 11 px acima do pivô. |
| E | Perfil direito legível; mudança de idle sutil | `-2, -2, -2, -4, -4, -4` | CORRIGIR: seis poses sugerem passada alternada; a base desloca 2 px e o alpha é suave. |
| SE | Vista diagonal dianteira; idle quase estático | `-4, -4, -4, -4, -4, -4` | CORRIGIR: base fica 4 px acima do pivô; fases da passada não ficam claras o bastante para aprovação. |
| S | V1 preservado; animação quase estática | `+2, +1, +2, 0, -2, -1` | CORRIGIR: deriva vertical herdada e alpha suave/halo. |
| SW | Vista diagonal dianteira; idle quase estático | `-4, -4, -5, -6, -6, -6` | CORRIGIR: personagem flutua 4–6 px acima do pivô e passada precisa revisão. |
| W | Perfil esquerdo legível; mudança de idle sutil | `-4, -4, -4, -5, -5, -5` | CORRIGIR: seis poses sugerem passada alternada; base fica 4–5 px acima do pivô e alpha suave. |
| NW | Vista diagonal de costas; idle quase estático | `-3, -6, -3, -3, -5, -3` | CORRIGIR: variação de base de 3 px e passada diagonal ainda incerta. |

Os valores da tabela vêm do limite inferior do alpha ≥128 em cada quadro; eles não reposicionam o conteúdo. O atlas mantém um offset comum dentro de cada linha, sem compensação por quadro. Nenhuma sequência tem quadros idênticos exatos; nos idles, as pequenas diferenças parecem em grande parte ruído de textura/borda e não provam um ciclo de respiração intencional.

### Teste da passada

Revisei o ciclo na ordem esperada: **contato esquerdo → descida → passagem → contato direito → descida → passagem**. E e W mostram alternância reconhecível entre poses, mas os quatro eixos cardinais não mantêm uma base comum e as fases diagonais não são identificáveis com confiança suficiente. O teste do ciclo para o conjunto de oito direções fica **reprovado**, mantendo todos os atlas como CORRIGIR.

## Limites e próxima correção

- Alpha suave persiste em todas as fontes novas; halo/vinheta é visível em parte delas, com defeito claro na fonte E walk. A direção de arte pede contorno opaco de pixel art. A tentativa de correção de E walk não avançou. Manter as fontes como evidência e refazer/retocar contornos de forma manual e revisada sobre fundos claros e escuros antes de aprovação.
- Rever as fases da passada e alinhar os pés ao pivô sem ajustar cada quadro às cegas; o drift de NE e dos candidatos N/S precisa ser corrigido primeiro.
- Revisar ângulo, arma, cabelo e roupa em NE/SE/SW/NW contra o concept aprovado, além de diferenciar idle intencional de variação de textura.
- Godot, zoom/SQM e Android continuam pendentes; nenhuma validação de motor ou dispositivo foi executada.

**Status dos dois atlas: `corrigir`, `approved: false`.** A validação estrutural não altera esse status.
