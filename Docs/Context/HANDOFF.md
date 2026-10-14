# Handoff — teste técnico Melissa Warrior

**Branch:** `feature/s00-melissa-sprite-test`, derivada de `docs/gdd-mvp-producao`. Consultar HEAD real; não há merge autorizado.

Ferramenta de QA em `project.godot`, Godot 4.5.1 stable. Cena e instruções em `tools/art/sprite_test/`. O projeto na raiz é desvio documentado para importar `assets/` diretamente; `game/` segue reservado ao futuro jogo.

**Próxima ação:** corrigir os candidatos V2 N/S de Melissa Warrior (idle 4/walk 6), conforme `docs/art/MELISSA_TECHNICAL_QA.md`: acabamento pixel sem suavização, direção sul e continuidade das passadas/pés. A V2 é a base preferida para correção; V1 está preservada. Não ampliar direções ou variantes até validação visual e Android. Não transformar concept em folha utilizável.

**Evidência atual:** PR [#2](https://github.com/fabiofsjunior/ilha-do-cristal/pull/2), rascunho. `docs/art/evidence/godot_v2/` contém 16 capturas reais do Godot em zoom 50/75/100/125 e `all_20_frames_3x.png`. Importação/execução e 80 seleções na V2 passaram. Diagnóstico em `stage1_asset_validation.json` continua reprovando alpha suave. Âncoras são estimativas documentadas, sem certificação dos pés. Abrir `project.godot`; seletor permite comparar V1/V2.

**Limites:** não há APK exportado/testado, gameplay ou S0 completo. Nenhuma evidência headless equivale à validação em Android. Vael/exército e sprites fora do MVP não entram neste lote. Fotos privadas não devem ser commitadas. Usar tabela de produção para estado real.

**Delegação:** nas próximas tarefas desta sessão, usar GPT-6 Luna com raciocínio máximo, conforme instrução do usuário. A V3 foi gerada antes da troca; sua revisão e integração foram transferidas para subagentes Luna. Não interpretar existência de V3 como aprovação ou liberação do lote.
