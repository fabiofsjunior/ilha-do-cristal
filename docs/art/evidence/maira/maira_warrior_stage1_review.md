# Maíra Warrior — protótipo técnico da etapa 1

**Estado geral: CORRIGIR.** Esta prancha é um candidato para revisão, não um atlas de produção aprovado. O conceito aprovado foi usado apenas como referência de identidade; nenhum sprite foi recortado dele.

## Escopo do protótipo

- Duas direções: norte e sul.
- `idle`: 4 quadros por direção; `walk`: 6 quadros por direção.
- Célula 96 × 96 px; pivô candidato (48, 80).
- Atlas com linhas N/S e colunas cronológicas; nearest no visualizador.
- Teste interativo: `project.godot` continua abrindo a cena Melissa. Para abrir o teste isolado de Maíra, selecionar `tools/art/sprite_test/maira_stage1_test.tscn` no Godot.

## Resultado visual e técnico

| Animação | Direções e quadros | Estado | O que ainda precisa de revisão |
|---|---|---|---|
| `idle` | N e S, 4 cada | **corrigir** | A fonte N é menor que a fonte S (66 × 87 contra 72 × 94). Conferir a escala relativa, vista cardinal, consistência entre quadros e contato dos pés no Godot. |
| `walk` | N e S, 6 cada | **corrigir** | A escala N/S difere; alternância das pernas, contato e loop precisam de revisão quadro a quadro no Godot. |

## Verificações feitas neste ambiente

- Atlas `idle`: 384 × 192 px; atlas `walk`: 576 × 192 px.
- Todas as células são 96 × 96 px e mantêm os pixels na escala de origem, sem redimensionar nem aparar cada pose.
- PNGs RGBA com alpha somente 0 ou 255; fundo transparente, sem alpha suavizado.
- Foi retirada a contaminação magenta da borda por máscara binária; a prancha foi revista em fundo xadrez e não mostra halo magenta evidente.
- Célula, direção, quantidade de quadros e offsets estão registrados nos JSONs ao lado dos atlas.
- O contato dos pés ainda é estimado pela posição dos pixels; o pivô não foi certificado em execução.
- Revisão visual estática adicional feita por subagente GPT-6 Luna max: reconheceu norte/sul e posição da espada consistentes, sem halo magenta evidente; confirmou que movimento de idle, passada, loop e escala N/S permanecem insuficientes para aprovação.
- O validador de atlas não reporta erros para Maíra. O comando completo ainda retorna falha pelos seis erros de alpha intermediário já registrados nos atlas existentes de Melissa; isso não foi corrigido neste incremento.

Na revisão da prancha, o `idle` tem movimento corporal muito sutil. O bbox das poses fica aproximadamente em 39–40 × 57–58 px no norte e 43–44 × 61–63 px no sul. No `walk`, algumas silhuetas chegam às linhas y=81–82, enquanto outras terminam em y=80; confirmar quais pixels são o pé de apoio e acertar o pivô sem deformar a figura. Em zoom de 50%, os personagens ocupam cerca de 20–22 × 29–32 px, então detalhes e passada ainda não estão comprovados para Android.

## Validação pendente

Godot não está instalado/disponível nesta sessão. Portanto, ainda não houve importação ou captura de cena Godot, teste real nos zooms de 50–125%, teste de SQM, nem teste em Android. A cena `tools/art/sprite_test/maira_stage1_test.tscn` está preparada para inspeção interativa, mas a validação de engine e aparelho continua pendente.

## Decisão de produção

Não ampliar para oito direções, outras vocações ou outros personagens antes da revisão deste protótipo. A aprovação do conceito de Maíra não aprova a animação. Atualizar esta tabela após validação visual; só marcar como aprovado quando a escala, os pés, a direção e o ciclo estiverem legíveis no jogo.
