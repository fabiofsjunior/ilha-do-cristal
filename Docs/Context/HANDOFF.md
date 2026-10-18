# Handoff — fechamento das frestas do terreno isométrico

**Branch:** `Staging`

**Base integrada:** `91d95e3fbc820558c74ae7aa838603250d7f5dd8`

**Commit de implementação:** `a7cb783791566409d2db3302c55af9e57cc8f65f`

## Próxima ação exata

Abra o projeto `game/project.godot` no Godot 4.5.1 e execute a cena principal. Confira o jogador na região de praia: os losangos do `BaseTiles` devem cobrir o chão sob os pés, sem frestas do fundo entre células. Depois abra `game/scenes/first_island.tscn`, selecione `BaseTiles`, pinte uma célula e execute novamente para confirmar que a edição salva aparece sem repintura no início.

## Alterações

- `game/scripts/world/isometric_3d_view.gd` mapeia o losango superior 128×64 do atlas isométrico para a célula quadrada de 4×4 SQMs e amplia o quad 10% em torno do mesmo centro para cobrir as bordas transparentes.
- `README.md`, `docs/technical/ARCHITECTURE.md`, `Docs/Main/ROADMAP.md` e `Docs/Context/JOURNAL.md` registram o comportamento e os limites de validação.
- A posição lógica do jogador, colisões, saves, spawns e regras do jogo não foram alterados.

## Verificações e limites

- Revisão estática confirmou os vértices UV do losango e a cobertura centrada 1.10; os centros lógicos permanecem inalterados.
- Não houve execução da cena Godot neste fluxo via plugin GitHub; a conferência visual em Godot 4.5.1 ainda está pendente.
- Nenhuma pergunta de escopo permanece; falta apenas a verificação visual local descrita acima.
