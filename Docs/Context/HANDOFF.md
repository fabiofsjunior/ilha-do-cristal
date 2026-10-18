# Handoff — cenas editáveis de criaturas

**Branch:** `Staging`  
**Base desta integração:** `31952366dc06bc60b49b94c761a0a1fea78fa5ad`

## Implementado

- `game/scenes/creatures/creature_base.tscn` define o prefab Godot 4 com `CharacterBody2D`, cápsula corporal, `DetectionArea` e `AttackArea`.
- `fox.tscn`, `wolf.tscn` e `bear.tscn` herdam do prefab e têm recursos de forma locais, editáveis por espécie.
- `creature_actor.gd` lê a cápsula e os círculos da cena; `first_island.gd` usa a cena correta em cada spawn e respawn.
- O teste de espaçamento instancia as cenas reais e verifica dimensões, camadas e áreas personalizadas após `_ready()`.

## Próxima ação exata

No Godot 4.5.1, abrir cada cena herdada em `game/scenes/creatures/`, ajustar `CollisionShape2D` e as formas filhas de `DetectionArea` e `AttackArea` para o encaixe de cada sprite, salvar e reabrir para confirmar a persistência. Depois rodar `tools/gameplay/test_melee_contact_spacing.gd` em modo headless e revisar visualmente o combate.

## Validação desta sessão

Godot 4.5.1 importou/reimportou o projeto. Passaram `test_melee_contact_spacing.gd`, `smoke_playable_slice.gd`, `test_expanded_map_population.gd` (30 spawns), `test_respawn_radius.gd`, `git diff --check` e as checagens estáticas de catálogo/referências. O editor emitiu aviso ao salvar configurações fora do projeto, sem impedir importação ou testes. O ajuste visual manual das formas permanece pendente.

## Pendências anteriores

- Validar `Acessar_Wiki.bat` e `Testar_Jogo_Web.bat` num Windows com Node.js 18+, Godot 4.5.1 e templates Web.
- Exportar/testar o APK 0.1.10/versionCode 11 com Android SDK Platform 35 e Build Tools 35.0.0 em aparelho.
- Editar, salvar e reabrir manualmente no Godot as camadas do atlas tropical e medir o resultado em Android.
