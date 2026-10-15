# Handoff — protótipos MVP e sprites

**Branch deste incremento:** `feature/maira-warrior-stage1`, baseada na PR #3 `docs/mvp-prototyping-gates`. A PR da arte deve permanecer em rascunho e aguardando revisão do usuário. Consulte o commit atual com `git rev-parse --short HEAD`.

## Próxima ação

Solicitar revisão da prancha técnica Maíra Warrior em `docs/art/evidence/maira/maira_warrior_stage1_contact.png`. Aplicar feedback e, em seguida, importar a cena `tools/art/sprite_test/maira_stage1_test.tscn` no Godot 4.5.1 para conferir os 20 quadros, pés/pivô, fundo claro/escuro, SQM 32/48 e zoom 50–125%. Não ampliar para oito direções ou outras vocações até a revisão e validação técnica.

## Estado da arte de Maíra

Maíra foi incluída como personagem jogável do MVP, irmã de Helena, com identidade visual de cabelos longos castanho-escuros e traje amarelo/dourado. O conceito das três vocações foi aprovado e está em `assets/references/generated-candidates/maira_vocations_concept.png` como referência, não como atlas.

| Animação | Escopo atual | Estado |
|---|---|---|
| `idle` | N/S, 4 quadros por direção | **corrigir** — movimento sutil e escala N/S desigual |
| `walk` | N/S, 6 quadros por direção | **corrigir** — confirmar passada, apoio dos pés, pivô e loop |

Atlas e JSON candidatos ficam em `assets/characters/maira/warrior/`. A ferramenta de empacotamento está em `tools/art/pack_maira_stage1.py`; avaliação visual e técnica: `docs/art/evidence/maira/maira_warrior_stage1_review.md`. A cena isolada usa nearest, seleção de direção/animação, pause/frame-step, SQM e zoom.

## Validação e bloqueios

- Catálogo MVP e JS do protótipo v0.3 passaram validação estrutural.
- Os dois atlas Maíra são RGBA 96×96 por célula e têm alpha somente 0/255; validador não registra erro específico para Maíra.
- A execução global do validador continua com seis erros pré-existentes de alpha intermediário nos atlas Melissa V1–V3.
- Revisão visual delegada a GPT-6 Luna max confirma que o estado deve continuar **corrigir**: N é menor que S, idle é quase estático e a passada precisa revisão quadro a quadro.
- Godot não está instalado no workspace; importação/captura na engine e validação Android estão pendentes. Não há APK nem gameplay implementado.
- O protótipo de UI atual é `docs/prototypes/mvp_ui_v0_3.html`; v0.1 e v0.2 permanecem preservadas e a aprovação das telas segue pendente.

`Vael`, exército e conteúdo fora do MVP continuam fora do lote. Não incluir fotos privadas no repositório.
