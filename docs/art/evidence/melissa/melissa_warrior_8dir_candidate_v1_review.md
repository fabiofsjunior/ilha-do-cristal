# Melissa Warrior — atlas candidato de oito direções v1

**Estado geral: CORRIGIR · não aprovado para produção.** Este incremento completa somente `idle` e `walk` de Melissa Warrior. Não inclui Archer, Mage, ataque, dano, morte ou conjuração.

## Entrega

| Animação | Direções na ordem do atlas | Quadros por direção | PNG | JSON |
|---|---|---:|---|---|
| Idle | N, NE, E, SE, S, SW, W, NW | 4 | `assets/characters/melissa/warrior/melissa_warrior_idle_8dir_candidate_v1.png` | `assets/characters/melissa/warrior/melissa_warrior_idle_8dir_candidate_v1.json` |
| Walk | N, NE, E, SE, S, SW, W, NW | 6 | `assets/characters/melissa/warrior/melissa_warrior_walk_8dir_candidate_v1.png` | `assets/characters/melissa/warrior/melissa_warrior_walk_8dir_candidate_v1.json` |

Prancha: [`melissa_warrior_8dir_candidate_v1_contact.png`](melissa_warrior_8dir_candidate_v1_contact.png). Resumo estrutural: [`melissa_warrior_8dir_candidate_v1_structure.json`](melissa_warrior_8dir_candidate_v1_structure.json). Fontes brutas e método: [`MELISSA_8DIR_SOURCE_V1.md`](../../../../assets/references/generated-candidates/MELISSA_8DIR_SOURCE_V1.md). Empacotador: `tools/art/pack_melissa_8dir_candidate_v1.py`.

## Resultados

| Gate | Estado | Evidência / defeito |
|---|---|---|
| Identidade | corrigir | Cabelo castanho, mecha frontal roxa, traje lilás/dourado, espada e escudo são reconhecíveis. A vista S e as poses geradas ainda precisam de revisão de câmera e consistência quadro a quadro. |
| Direções | corrigir | Há oito linhas distintas na ordem declarada. N/S vêm da V3 pré-existente; NE/E/SE/SW/W/NW são fontes geradas separadas, sem espelhamento. A direção S antiga segue próxima de uma vista de três quartos. |
| Walk / passada | corrigir | Quadros são distintos por hash, mas o contato esquerdo/direito, descida e passagem não ficam inequívocos em todas as direções. Algumas posições de espada variam bastante. Necessário rever os ciclos 6→1 animados e corrigir a passada/arma. |
| Estrutura | aprovado | Idle 384×768; walk 576×768; RGBA; células 96×96; oito direções; quatro/seis quadros por linha; nenhum quadro vazio nem alpha tocando borda de célula. Todos os quadros têm hash distinto dentro da própria direção. |
| Pixel art / alpha | corrigir | O validador relata 254 valores intermediários de alpha em ambos os atlas; 68.358 pixels no idle e 104.647 no walk têm alpha 1–254. Halo/suavização permanece visível. Não foi aplicado binarização, limpeza automática ou retoque que esconda o defeito. |
| Escala / pivô | corrigir | 96×96 e (48,80) continuam candidatos. A inspeção estrutural usa caixas de alpha, que não identificam pés; desvio em torno do pivô não prova contato nem ausência de deslize. |
| Godot / render | pendente | Godot não está disponível neste runner; os atlas novos não foram importados ou reproduzidos nele. |
| Android / SQM / zoom | pendente | Nenhum aparelho ou captura de escala em terreno foi usado nesta etapa. |

O validador canônico `python tools/art/validate_sprite_atlases.py` retornou código 1. Os dois erros específicos destes atlas são os valores intermediários de alpha; não houve erros de dimensão, modo, transparência, quadro vazio ou pixels na borda. A execução do repositório reportou 14 erros de alpha no total, incluindo 12 preexistentes em candidatos de outros incrementos.

## Decisão e correções necessárias

Manter os atlas como candidatos e preservar todos os arquivos V1/V2/V3 anteriores. Corrigir o alpha/contornos na fonte em uma tentativa revisável, reforçar fases de passada e consistência da espada, revisar o S cardinal, depois importar/reproduzir no Godot e validar zoom/SQM. O aceite da interface v0.7 não valida arte, Godot ou Android.

## Retoque isolado em cópia — 2026-10-15

Foi feita uma tentativa manual e localizada no `idle` de Melissa Warrior, sem substituir V1. A folha `melissa_idle_n_frame1_pixel_retouch_v2.png` apresenta N/idle/quadro 2 em nearest 8×, sobre fundos claro e escuro. A inspeção mostrou dois pixels alfa completamente destacados da personagem: célula local `(49,7)` acima do cabelo e `(21,33)` à esquerda do cabelo. Ambos tinham RGBA com alpha `1` e nenhum vizinho com alpha visível. Foram removidos somente esses dois pixels da cópia `melissa_warrior_idle_8dir_candidate_v2.png`.

O método versionado está em `tools/art/retouch_melissa_isolated_alpha_artifacts_v2.py`; ele verifica dimensões, alpha `1` e isolamento 8-vizinhos antes de editar. Metadados adjacentes registram os pixels e os valores RGBA antes/depois. A fonte candidate_v1 e a imagem conceitual não foram alteradas; não houve binarização global, alteração dos demais valores alfa, redimensionamento, corte ou mudança de quadros/direções.

**Resultado limitado:** o preview nearest confirma a remoção dos dois resíduos destacados e não mostra dano adjacente à silhueta nessa ampliação. O atlas continua `CORRIGIR`: a maior parte do antialias/alpha intermediário permanece, assim como os defeitos distribuídos de passada, variação da espada e direção S registrados acima. O candidato v2 é somente uma correção experimental de duas amostras, não evidência de acabamento pixel art. Não há editor raster/pixel dedicado instalado neste runner; o retoque é explícito, reproduzível e inspecionável em qualquer editor PNG gratuito. Godot e Android continuam sem validação nesta cópia.

### Validação desta tentativa

- `python -m py_compile tools/art/retouch_melissa_isolated_alpha_artifacts_v2.py` e parse JSON passaram.
- Comparação RGBA entre idle V1 e V2 confirmou exatamente duas diferenças: `(145,7)` e `(117,33)` no atlas; ambas mudaram de `(0,0,0,1)` para `(0,0,0,0)`. Grade 384×768, oito direções e quatro quadros permanecem iguais.
- Pixels alpha intermediários no idle caíram de 68.358 para 68.356; os 254 valores intermediários distintos continuam presentes. Walk permanece com 104.647 pixels intermediários.
- `python tools/validate_catalogs.py` passou (10 grupos, 54 IDs). `python tools/art/validate_sprite_atlases.py` continua retornando erro: 21 erros globais, todos de alpha intermediário; o novo idle V2 não acusa dimensão, célula vazia nem pixels na borda.
- Nenhuma cena Godot nem aparelho Android foi usado; importação, reprodução animada, zoom/SQM e legibilidade no dispositivo permanecem pendentes.
