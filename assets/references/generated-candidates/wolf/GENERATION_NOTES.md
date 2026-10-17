# Lobo — fonte imagegen e correções

**Estado:** candidato para revisão, com resultado artístico **CORRIGIR**. O arquivo de uso experimental é apenas uma pose estática SE.

Os PNGs preservam a saída nativa do imagegen e cada correção, sem recorte:

- `wolf_se_source_v1.png`: geração inicial.
- `wolf_se_source_v2.png`: edição para reduzir cristais e simplificar os clusters.
- `wolf_se_source_v3.png`: edição dirigida para simplificar pixel art e tornar alpha estritamente binário; esta última condição não foi atendida, então a fonte segue em **CORRIGIR**.

## Prompt da fonte v3 selecionada

```text
Use case: precise-object-edit
Asset type: one production-stage test sprite source for a 2D game
Input image: Image 1 is the wolf artwork; preserve its identity and pose.
Primary request: make one targeted pixel-art correction: simplify this same single alert southeast-facing wolf into a genuinely compact, low-resolution game sprite. Preserve its four-legged anatomy, cool blue-gray fur, light muzzle and chest, and three or four tiny, restrained blue-violet crystal accents. Keep its full silhouette within a 96×96 logical cell; paws meet the ground at y=80 and the body is about 48–64 logical pixels tall.
Style/medium: classic RPG pixel art, orthogonal top-down slightly oblique view. Use a very small deliberate palette and large coherent square pixel clusters, with flat stepped shading and a crisp outline. Remove fine fur texture, gradients, anti-aliased edges, and tiny decorative marks. Alpha must be strictly binary: each edge pixel fully opaque or fully transparent, with no translucent fringe.
Constraints: edit only rendering simplification, crystal quantity, and clean pixel edges. Keep the same wolf, same southeast view, same pose, same scale relationships, and genuine transparent background. One subject, one still pose.
Avoid: new body parts, extra pose or animal, glossy highlights, soft shadow, glow, scenery, text, borders, grid, 3D, blur, blood, or gore.
```

A fonte v3 foi produzida com o imagegen integrado usando v2 como alvo de edição. Ela manteve uma pose reconhecível voltada a SE, pelo cinza-azulado e focinho claro. As tentativas de correção reduziram detalhes, mas o resultado ainda tem mais cristais visíveis que o desejado e alpha intermediário. O packer não mascara esses defeitos.
