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
