# A Ilha do Cristal

RPG 2D cooperativo de sobrevivência em pixel art. Melissa, Helena e Maíra sobrevivem ao naufrágio de um cruzeiro, despertam poderes de um cristal e constroem um refúgio numa ilha mutante. Vael é a ameaça narrativa das expansões.

**Estado:** pré-produção, sem build jogável. **Primeira plataforma:** Android em paisagem; desktop depois. **Arte aprovada:** RPG Clássico. [Prancha conceitual](assets/references/concept-rpg-classico.png) (referência, não sprites utilizáveis).

## Documentação

- [GDD do MVP](Docs/Main/GDD_MVP.md) — regras e critérios de aceite.
- [Conteúdo e balanceamento](Docs/Main/CONTENT_DATA.md) — atributos, armas, XP, drops, bestiário e árvore.
- [Doze listas de produção](Docs/Main/CATALOGS_MVP.md) e [catálogo JSON](data/catalogs/mvp.json) — conteúdo inicial versionado.
- [Roadmap](Docs/Main/ROADMAP.md) — sprints e validações.
- [Metodologia de prototipagem](Docs/Main/PROTOTYPING_METHODOLOGY.md) — protótipo e validação antes de cada fase.
- [Registro de protótipos](Docs/Context/PROTOTYPE_LOG.md) e [protótipo navegável atual das telas do MVP](docs/prototypes/mvp_ui_v0_2.html).
- [Handoff](Docs/Context/HANDOFF.md) e [Journal](Docs/Context/JOURNAL.md) — continuidade entre sessões.
- [Arquitetura](docs/technical/ARCHITECTURE.md) — Godot, rede local, saves e dados.
- [Arte e sprites](docs/art/ART_DIRECTION_AND_SPRITES.md) — identidade visual, atlas e prompts.
- [AGENTS.md](AGENTS.md) — instruções de implementação por sprint.

Estrutura prevista: `game/` (projeto Godot), `data/` (conteúdo versionado), `assets/references/` (conceitos), `assets/characters/`, `assets/environments/`, `assets/ui/`, `Docs/Main/` (referência durável), `Docs/Context/` (journal/handoff), `docs/art/` e `docs/technical/`. A ferramenta técnica de QA de sprites pode ser aberta pelo `project.godot` da raiz; instruções em [teste de sprites](tools/art/sprite_test/README.md). Não é build jogável e não conclui S0.

Não publicar fotos originais das crianças, credenciais, keystores ou saves pessoais. A prancha conceitual não substitui sprites de produção.
