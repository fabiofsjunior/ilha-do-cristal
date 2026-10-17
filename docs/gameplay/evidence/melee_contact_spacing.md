# Diagnóstico e correção — contato melee

Branch revisada: `feature/s02-pixel-hud-assets`
Escopo: colisão, espaçamento dos atores, alcance do ataque básico e ancoragem dos sprites na apresentação 2.5D.

## Diagnóstico

- O `Player` estava na layer 1 com `collision_mask = 1`; criaturas estão na layer 2. Assim, o jogador ignorava os monstros e podia avançar através deles. Criaturas usam máscara 1 e já reconheciam o jogador.
- O jogador tinha cápsula de raio 10 px e altura 28 px. Raposa/lobo: raio 9 px e altura 22 px. Urso: raio 17 px e altura 34 px. Os centros das formas ficam 1 px acima dos pivôs. Em aproximação horizontal, o contato esperado é a 19 px entre os pivôs para raposa/lobo e 27 px para urso; a medida real também considera as partes retas das cápsulas em outros ângulos.
- O autoataque do jogador usava 42 px entre pivôs. As criaturas usavam 44/48/50 px entre pivôs (raposa/lobo/urso); não havia cálculo da folga das superfícies.
- A espada Warrior define alcance `range_tiles = 1` no catálogo, isto é, 32 px de alcance a partir da superfície das formas. O runtime anterior usava 42 px centro-a-centro. Não encontrei no GDD/catalogo desta branch a configuração de 15→20 SQMs citada em pedidos anteriores.
- Player e criaturas usam células de arte de 96×96 px, pivot declarado (48,80); urso usa 128×128 px, pivot (64,108), com escala 1,3 no proxy 3D. As caixas alpha da primeira célula idle examinada medem Melissa 51×62, Helena 70×69, Maíra 39×58, Fábio 64×65; raposa 69×48, lobo 58×57 e urso 83×75 antes da escala. As figuras têm largura visual maior que os hitboxes de pés, então a caixa alpha não deve ser usada diretamente como collider de navegação.
- O renderizador 2.5D posicionava os atores com altura e deslocamento fixos, sem aplicar o pivot configurado no sprite 2D. Isso deixava os pés visuais fora do ponto de chão usado por movimento/colisão.

## Alterações

- Máscara do Player agora inclui a layer 2 dos monstros; as camadas de mundo continuam colidindo.
- Criado `combat_geometry.gd`, que lê as `CollisionShape2D` reais e calcula a menor distância entre os eixos das cápsulas, subtraindo os raios. A folga fica negativa se houver penetração, zero no contato e positiva entre superfícies separadas. A rotina é compartilhada pelos dois lados do combate.
- O ataque básico Warrior agora usa o alcance de 1 SQM do catálogo como distância entre superfícies. Raposa, lobo e urso atacam dentro de uma tolerância projetada de 8 px; a aproximação conserva uma margem visual nominal de 4 px. O telegráfico do urso valida novamente a distância ao concluir.
- O `Sprite3D` de cada ator agora herda o `offset` do `AnimatedSprite2D` ou da pose da criatura e fica ancorado no ponto de chão do ator. Ordenação visual mantém o depth test da câmera.
- Skills, inclusive o raio atual de 112 px de `war_quake`, não foram alteradas.
- Adicionado `tools/gameplay/test_melee_contact_spacing.gd` para testar aproximação do jogador, aproximação do monstro, folgas de contato/fora de alcance, pivôs dos proxies e a skill de área a 100 px.

## Validação

- `python3 tools/gameplay/validate_playable_slice.py`: passou — 28 referências de cenas/scripts resolvidas, 8 animações detectadas e atlas/mapa validados.
- `python3 -m json.tool data/catalogs/mvp.json` e `git diff --check`: passaram.
- Godot 4.5.1: `test_melee_contact_spacing.gd`, `test_portrait_combat.gd` e `test_close_view.gd` passaram, inclusive ataque dos dois lados em contato físico, range da espada e limpeza do dano flutuante.
- APK Android 0.1.6/versionCode 7 foi reexportado e validado; o Web não foi reexportado nesta atualização.

## Estado do critério visual

Esta limitação foi corrigida pela revisão visual abaixo: o espaçamento entre atores agora usa a silhueta alpha projetada; os colliders de navegação permanecem pequenos e inalterados.

## Revisão visual por footprint alpha

- A caixa alpha simétrica inicial ignorava o deslocamento da arte em relação ao pivô. Isso deixou uma sobreposição com o urso mesmo quando o cálculo indicava contato. O teste reproduziu o problema no ângulo de aproximação 19/32.
- `game/data/melee_visual_footprints.json` agora guarda extents alpha relativos ao pivô, medidos com threshold alpha 31, para todas as animações idle/walk e direções dos quatro perfis Warrior, e para as poses atuais de raposa, lobo e urso. O envelope do jogador cobre 69×72 px (`x=[-35,34]`, `up=[-3,69]`); a maior caixa de um único frame é 65×67 px. Criaturas: raposa 51×48 px (`x=[-26,25]`, `up=[3,51]`), lobo 58×52 px (`x=[-29,29]`, `up=[4,56]`), urso 106,6×96,2 px após escala 1,3 (`x=[-52,54,6]`, `up=[0,96,2]`).
- `combat_geometry.gd` projeta esses extents através da câmera 2.5D (yaw 45°, inclinação 30°) e resolve a distância direcional que mantém 4 px de folga visual. O bloqueio adicional só afeta movimento ator-contra-ator. Cápsulas Player r10/h28, raposa/lobo r9/h22 e urso r17/h34, layers e colisões com terreno/props não foram ampliadas.
- O ataque básico da espada continua com 1 SQM de alcance, medido até 32 px além da borda alpha. Raposa, lobo e urso atacam o jogador quando o gap projetado fica em até 8 px, inclusive após o telegráfico do urso; ao encostar fisicamente os colliders originais, os dois lados também permanecem dentro do alcance. Skills e seus raios centrados não mudaram.

| Espécie | Separação dos pivôs para 4 px de folga visual, 8 eixos comuns | Ataque básico do monstro | Alcance básico da espada |
| --- | ---: | ---: | ---: |
| Raposa | 64,0–122,3 px | gap projetado ≤ 8 px | folga alpha ≤ 32 px |
| Lobo | 67,0–120,6 px | gap projetado ≤ 8 px | folga alpha ≤ 32 px |
| Urso | 90,0–179,8 px | gap projetado ≤ 8 px | folga alpha ≤ 32 px |

Os intervalos variam conforme direção, pois a câmera comprime o eixo de profundidade e cada sprite tem extents assimétricos em relação ao pivô. São distâncias dos pivôs no plano lógico, não um novo raio de colisão.

### Regressões e validação

- `python3 tools/gameplay/test_melee_visual_spacing.py`: **PASS**. A saída cobre 4 perfis Warrior × 8 direções de sprite × 3 espécies, confirma a separação das caixas alpha projetadas em 32 ângulos e compara as máscaras alpha nos 8 eixos comuns. Saída:

  ```text
  PASS visual melee alpha: all 4 Warrior profiles × 8 facing rows × 3 creatures × 32 projected angles and 8 pixel-mask axes are disjoint at contact
  fox: 64.0–122.3 logical px over 8 common axes (margin 4 px)
  wolf: 67.0–120.6 logical px over 8 common axes (margin 4 px)
  bear: 90.0–179.8 logical px over 8 common axes (margin 4 px)
  ```
- `tools/gameplay/test_melee_contact_spacing.gd` cobre a aproximação do jogador para cada espécie, aproximação de lobo/urso ao jogador, contato visual, contato das cápsulas, dano básico dos dois lados, alcance de 1 SQM da espada e preservação do raio de `war_quake` a 100 px. As cápsulas esperadas são verificadas sem alterações.
- `test_melee_contact_spacing.gd`: **PASS** com Godot 4.5.1, cobrindo as três espécies, contato alpha e físico, ataques básico do jogador/monstro e range de `war_quake`.
- APK Android 0.1.6/versionCode 7 passou manifesto, assinatura, CRC e validação dos recursos runtime. Nenhum aparelho físico estava conectado; instalação/teste real continuam pendentes.
