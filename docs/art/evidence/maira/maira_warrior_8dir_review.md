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

## Importação Godot — 2026-10-15

Godot 4.5.1 confirmou `IDAT: invalid distance code` e `ERR_FILE_CORRUPT` ao importar as 12 fontes descritas acima. A auditoria comparou os blobs de `HEAD`, `origin/feature/fabio-warrior-stage1` e `main`; todos são idênticos e têm aproximadamente 786 KiB, embora o chunk IDAT declare de 1,07 a 1,38 MiB. Não foi localizada uma cópia íntegra nos worktrees locais.

Como as fontes ficam numa pasta de referências e não são carregadas pelo jogo, foi adicionado `.gdignore` apenas nesse diretório para manter o import/runtime do jogo separado desses arquivos. Isso é isolamento de importação, não reparo dos PNGs: o empacotador de Maíra continua sem fontes decodificáveis e a aprovação de oito direções permanece bloqueada. Os atlas candidatos continuam em `assets/characters/maira/warrior/` e seguem com estado **CORRIGIR**.

## Reauditoria de integridade das fontes — 2026-10-15

**Estado geral: CORRIGIR.** A inspeção em escala nativa dos 80 quadros dos atlas v2 confirma os problemas visuais já descritos: E e W mostram o olhar para o mesmo lado, NE/E/SE se confundem e as quatro diagonais não formam orientações consistentes. Em `walk`, não há alternância de passada esquerda/direita clara ao longo do ciclo. A identidade geral continua reconhecível, mas esses defeitos impedem aprovação.

### Fontes de seis direções novas

As 12 imagens de origem referenciadas pelo empacotador estão malformadas/truncadas e não são decodificáveis integralmente:

- `idle_e_source_oai_v1.png`, `idle_ne_source_oai_v1.png`, `idle_nw_source_oai_v1.png`, `idle_se_source_oai_v1.png`, `idle_sw_source_oai_v1.png`, `idle_w_source_oai_v1.png`;
- `walk_e_source_oai_v1.png`, `walk_ne_source_oai_v1.png`, `walk_nw_source_oai_v1.png`, `walk_se_source_oai_v1.png`, `walk_sw_source_oai_v1.png`, `walk_w_source_oai_v1.png`.

O teste com Pillow abriu cada arquivo, mas `Image.load()` falhou nos 12 com `OSError: broken data stream when reading image file`. Reprodução a partir da raiz do repositório:

```sh
python - <<'PY'
from pathlib import Path
from PIL import Image

folder = Path("assets/references/generated-candidates/maira_warrior")
for path in sorted(folder.glob("*_source_oai_v1.png")):
    try:
        with Image.open(path) as image:
            image.load()
        print("OK", path.name)
    except OSError as error:
        print("INVALID", path.name, repr(error))
PY
```

A leitura estrutural dos chunks PNG confirma a causa. Por exemplo, `walk_ne_source_oai_v1.png` chega ao chunk IDAT no offset 21.926; o chunk declara 1.290.536 bytes, mas restam apenas 764.517 bytes no arquivo a partir do início desse chunk (incluindo cabeçalho/CRC). ImageMagick também acusa `IDAT: invalid distance code` para essa fonte.

### Empacotamento e recuperação

`python tools/art/pack_maira_8dir_candidates.py` falha durante `Image.open(path).convert("RGBA")`, em `get_source_cells()`, com `OSError: broken data stream when reading image file`. Portanto, os atlas v2 existentes não podem ser reproduzidos com as fontes versionadas atuais.

`git log --all --follow` encontra somente o commit `774ca93` (“Add Maíra Warrior eight-direction candidates”) para as fontes, sem uma versão íntegra anterior recuperável no histórico local. Os arquivos publicados permanecem preservados; não foram reconstruídos a partir dos atlas nem substituídos por novas imagens nesta reauditoria.

### Resultado

O concept ainda confirma a identidade geral, mas as fontes quebradas impedem correção confiável dos ângulos, das passadas e do alpha. Os atlas mantêm `status: corrigir` e `approved: false`; Godot, teste de escala/SQM e Android continuam pendentes. Não houve alteração nos PNGs, atlas ou empacotador.

## Reavaliação de retoque manual seguro — 2026-10-15

**Conclusão: não há retoque manual seguro e verificável com os arquivos disponíveis.** O estado continua **CORRIGIR** e nenhum PNG, JSON ou empacotador foi alterado nesta revisão.

### Evidência examinada

- Revisei as células de 96 × 96 px dos atlas v2 na prancha existente, ampliada por nearest-neighbor, e conferi os PNGs sem reamostragem. Os defeitos estruturais persistem: NE/E/SE são próximos demais, E e W apontam para o mesmo lado, e os quadros de `walk` não demonstram alternância clara de pernas.
- Comparei a linha N e a linha S de cada atlas v2 com o respectivo candidato v1: os pixels são idênticos. Escala relativa, contato dos pés e sequência de passada já eram pendências na etapa 1; não há uma transformação objetiva que corrija isso sem redesenhar poses.
- Recarreguei as 12 fontes das seis direções novas. `Image.load()` falha em todas com `OSError: broken data stream when reading image file`. O empacotador também falha ao abrir a primeira direção nova. O histórico local mostra somente o commit que introduziu as fontes, sem versão íntegra anterior recuperável.
- Os atlas v2 têm 256 valores únicos de alpha, incluindo 254 valores intermediários. Uma troca automática de limiar mudaria contornos sem decidir quais cores de borda conservar; não foi feita binarização nem limpeza por lote.
- Não há editor de pixels instalado nesta sessão (Pixelorama, LibreSprite, GIMP, Krita e Aseprite não estão disponíveis). `convert` do ImageMagick está disponível, mas não oferece um fluxo de pintura/revisão por pixel adequado para redesenhar ângulos, pés e silhuetas. Godot também não está disponível.

Os atlas v2 são resultados empacotados, não substitutos das fontes originais. Redesenhar sobre eles ou reconstruir fontes a partir deles apagaria a proveniência e não permitiria corrigir com segurança os cortes nas partições originais. A decisão é preservar as fontes malformadas e os atlas existentes intactos até haver fontes íntegrafas e um editor visual adequado.

### Validação nesta cópia

- A rechecagem das fontes encontrou 12/12 falhas de decodificação; `python3 tools/art/pack_maira_8dir_candidates.py` falha em `get_source_cells()` ao abrir a primeira fonte.
- As linhas N/S dos dois atlas v2 são pixel-idênticas às linhas de origem do v1. As dimensões seguem 96 × 96 px por célula.
- `python3 tools/art/validate_sprite_atlases.py` retorna código 1 com 20 avisos de alpha intermediário no repositório; 2 pertencem aos atlas v2 de Maíra e 18 a candidatos de outros personagens. Para Maíra, não há falha estrutural de dimensões, regiões vazias ou bordas de célula; esses resultados não aprovam direção, passada, pivô ou acabamento.
- `python3 -m py_compile tools/art/pack_maira_8dir_candidates.py tools/art/validate_sprite_atlases.py` e `git diff --check` passam. Godot, zoom/SQM em engine e Android seguem pendentes.

### Próximo gate

Obter fontes originais completas e decodificáveis (ou aprovar uma nova fonte independente do atlas), então redesenhar as direções e passadas em editor visual gratuito, em cópia, mantendo as fontes originais. Conferir cada alteração em tamanho nativo e nearest; revisar alpha deliberadamente em claro/escuro; só depois empacotar e repetir a validação. Até esse gate, a matriz continua **CORRIGIR**, sem alegar aprovação de arte ou de plataforma.
