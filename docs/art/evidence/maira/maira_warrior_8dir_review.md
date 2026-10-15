# Maíra Warrior — revisão do candidato em oito direções

**Estado geral: CORRIGIR.** O incremento acrescenta `NE`, `E`, `SE`, `SW`, `W` e `NW` a `idle` e `walk`. São folhas de trabalho versionadas para revisão, ainda sem aprovação de produção. O candidato N/S anterior foi preservado, sem alteração de pixels.

## Arquivos entregues

- `assets/characters/maira/warrior/maira_warrior_idle_candidate_v2.png` e `.json`
- `assets/characters/maira/warrior/maira_warrior_walk_candidate_v2.png` e `.json`
- Fontes geradas intactas em `assets/references/generated-candidates/maira_warrior/`
- Prancha de sequência: `docs/art/evidence/maira/maira_warrior_8dir_contact.png`
- Conferência de alpha sobre fundo claro e escuro: `docs/art/evidence/maira/maira_warrior_8dir_alpha_check.png`
- Empacotador reproduzível: `tools/art/pack_maira_8dir_candidates.py`

## Método e limites

- Ordem das linhas: N, NE, E, SE, S, SW, W, NW. `idle` tem 4 quadros por direção e `walk`, 6. Células 96 × 96 px; pivô candidato (48, 80).
- N/S vieram dos atlas v1 e foram copiados sem mudança. As outras seis direções foram geradas a partir do conceito aprovado, não recortadas dele, e preservadas como PNGs de origem.
- As tiras novas foram divididas em partes iguais e reduzidas uniformemente a 11% com nearest-neighbor. Não houve trim por quadro, espelhamento, binarização nem limpeza automática de alpha. O deslocamento vertical comum por animação usa a mediana do limite inferior da silhueta, não uma identificação dos pés.
- A imagem de conferência foi examinada em xadrez, branco e fundo escuro. As direções novas mantêm bordas com alpha suave/franja em cabelo, roupas e armas; a pixel art exige alpha opaco. Não corrigi isso automaticamente. As fontes foram preservadas para um retoque manual posterior.
- Nas fontes `walk`, alguns quadros alcançam a borda da partição temporal. O empacotamento final não tem pixels alfa ≥128 tocando a borda das células, mas o contato com a partição original ainda pode indicar recorte ou vazamento entre quadros.

## Diagnóstico por animação e direção

As medidas de bbox usam pixels com alpha ≥128 e são `largura × altura` em pixels da célula final. `y inferior` é o último pixel ocupado; pode incluir arma ou cabelo e serve apenas como proxy geométrico, não como contato do pé.

| Animação | Direção | Bbox por quadro (px) | y inferior | Diagnóstico visual e técnico |
|---|---|---:|---:|---|
| idle | N | 38–40 × 57–58 | 79 | Linha v1 preservada; costas legíveis. Continua menor que S e requer validação de escala e pés. Alpha binário. |
| idle | NE | 46–50 × 61–63 | 80 | Geração nova; leitura próxima de perfil voltado à esquerda e muito semelhante a E/SE. Movimento de repouso é sutil. Alpha intermediário em 4/4 quadros. |
| idle | E | 44–46 × 62–64 | 79 | Geração nova; perfil voltado à esquerda. Não estabelece com segurança uma vista Leste oposta à vista Oeste. Alpha intermediário em 4/4. |
| idle | SE | 45–48 × 59–64 | 79–81 | Geração nova; silhueta próxima de NE/E, sem ângulo sudeste inequívoco. Alpha intermediário em 4/4. |
| idle | S | 43–44 × 61–63 | 79 | Linha v1 preservada; frente legível. É maior que N. Alpha binário. |
| idle | SW | 49–50 × 64–65 | 81 | Geração nova; ângulo frontal/lateral e espada à esquerda da tela. A direção e o contorno não combinam claramente com W/NW. Alpha intermediário em 4/4. |
| idle | W | 45–46 × 63–64 | 79 | Geração nova; perfil também voltado à esquerda, semelhante a E. A oposição Leste/Oeste não está resolvida. Alpha intermediário em 4/4. |
| idle | NW | 49–59 × 62–64 | 81 | Geração nova; variação de largura maior que nas demais linhas e silhueta toca borda de partição em 2/4 fontes. Verificar recorte e direção. Alpha intermediário em 4/4. |
| walk | N | 39–40 × 57–60 | 79–81 | Linha v1 preservada. O relatório v1 já deixa alternância e contato pendentes; não certifica a sequência de passada. Alpha binário. |
| walk | NE | 38–40 × 50–55 | 78–80 | Geração nova; as seis fontes tocam borda de partição. Os seis quadros não mostram com clareza a sequência contato esquerdo, descida, passagem, contato direito, descida, passagem. Alpha intermediário em 6/6. |
| walk | E | 35–39 × 50–52 | 78 | Geração nova; silhueta mais baixa que as outras vistas e fonte toca partição em 4/6 quadros. Passada pouco distinguível; vista ainda orientada à esquerda. Alpha intermediário em 6/6. |
| walk | SE | 38–40 × 50–55 | 79–80 | Geração nova; fonte toca partição em 6/6 quadros. A sequência não separa de modo legível as seis fases de passada; ângulo se confunde com NE/E. Alpha intermediário em 6/6. |
| walk | S | 43–44 × 63–65 | 79–80 | Linha v1 preservada; escala maior que N e quadros finais variam o limite inferior. Contato/alternância seguem pendentes no Godot. Alpha binário. |
| walk | SW | 35–40 × 51–53 | 80 | Geração nova; fonte toca partição em 6/6 quadros. Ciclo de pernas pouco legível e ângulo semelhante a W/NW. Alpha intermediário em 6/6. |
| walk | W | 36–40 × 54–56 | 79 | Geração nova; fonte toca partição em 3/6 quadros. Ciclo pouco legível; face aponta para o mesmo lado que E. Alpha intermediário em 6/6. |
| walk | NW | 37–40 × 47–52 | 77–80 | Geração nova; fonte toca partição em 6/6 quadros; limite inferior sobe até 3 px acima do pivô candidato em alguns frames. Conferir sensação de pé flutuando e recorte. Alpha intermediário em 6/6. |

## Validação executada

- `python3 tools/art/pack_maira_8dir_candidates.py`: gerou os dois atlas, JSONs e pranchas.
- `python3 -m py_compile tools/art/pack_maira_8dir_candidates.py`: passou.
- `python3 tools/art/validate_sprite_atlases.py`: geometria, dimensões, direções e não contato com a borda das células passaram para Maíra. Os dois erros associados a Maíra são alpha intermediário em `idle_candidate_v2` e `walk_candidate_v2`; ambos têm 256 valores de alpha, dos quais 254 são intermediários.
- O validador completo retorna 14 erros de alpha intermediário no repositório: 2 deste candidato Maíra e 12 já existentes nos atlas de Fábio, Helena e Melissa. Não foram alterados aqui.
- `git diff --check`: passou.

## Pendências antes de aprovar

1. Refazer ou corrigir manualmente os contornos novos para alpha somente 0/255 e rever sobre fundos claro/escuro.
2. Ajustar os vetores de olhar para que E e W apontem em sentidos opostos e as quatro diagonais sejam distinguíveis.
3. Regenerar/recompor quadros que encostam nas partições da fonte, conferir escala entre direções e demonstrar a passada completa em sequência.
4. Identificar pés, certificar pivô e importar/testar em Godot nos zooms de 50–125%, SQM e Android. Godot e aparelho Android não estavam disponíveis nesta execução.

O conceito confirma identidade geral — cabelo castanho longo, roupa dourada/creme, acessórios e espada —, mas não valida os novos ângulos nem animações. O candidato permanece **CORRIGIR**.
