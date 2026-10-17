# Handoff — regeneração fora de combate +20%

Branch: `feature/s03-out-of-combat-regen`; baseline `54275e1` (main após PR #17); commit local `de80ecb`.

O catálogo define `out_of_combat_rate_multiplier: 1.2`. `CombatRules.regeneration_rates_percent_per_sec` aplica o fator à soma das bases e bônus de FOR/INT fora de combate, antes dos caps. Em combate, após 8 s de inatividade, os caps existentes, clamp e pausa quando caído/morto mantêm o comportamento anterior. GDD, catálogo de produção, dados de balanceamento, README, roadmap e journal registram as taxas efetivas.

Godot 4.5.1 headless: importação (exit 0), `test_regeneration_rules.gd`, `test_attributes_window.gd` e `smoke_playable_slice.gd` passaram. O import emitiu `Unable to open Android 'build-tools' directory`; nenhum APK foi exportado e não houve teste Android físico.

Próxima ação: revisar e integrar este commit local no fluxo autorizado; validar o ritmo da regeneração em Android físico antes de fechar S3. Bloqueador: falta playtest físico.
