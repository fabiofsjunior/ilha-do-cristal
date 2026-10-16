# Arte gerada por script

Quando um asset simples puder ser descrito de modo determinístico, usar um script Python/Pillow versionado: dimensões, escala, paleta, pivô, alpha e parâmetros como entradas; exportar PNG e conferir o resultado no Godot Android. Exemplos: moldura de UI, grade de teste, barras e efeitos geométricos. Não converter a prancha conceitual em sprites automaticamente. A criação de um gerador concreto entra no sprint que precisar do asset; evitar scripts sem consumidor.

## Criaturas candidatas para o teste solo

Raposa, lobo e urso têm uma pose SE estática em `assets/creatures/`, com fontes geradas preservadas em `assets/references/generated-candidates/`. Os scripts `pack_fox_candidate.py`, `pack_wolf_candidate_v1.py` e `pack_bear_candidate.py` apenas empacotam por nearest; não removem alpha intermediário nem criam animações. Relatórios e previews nativos/nearest ficam em `docs/art/evidence/{fox,wolf,bear}/`.

```sh
python3 tools/art/validate_creature_candidates.py
python3 tools/art/validate_creature_candidates.py --strict-art
```

O primeiro comando verifica o contrato candidato de PNG/JSON, célula, pivô, pose e bordas. O segundo falha enquanto houver alpha intermediário ou direções/animações pendentes. Os três assets continuam **CORRIGIR**, `approved:false`; aprovação estrutural não é aprovação visual.
