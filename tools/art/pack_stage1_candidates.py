#!/usr/bin/env python3
"""Package imagegen candidates without synthesizing or duplicating artwork.

This is a technical candidate, not art approval. Source alpha is preserved.
Manual source feet anchors are estimates requiring Godot/Android review.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/characters/melissa/warrior'
OUT.mkdir(parents=True, exist_ok=True)
for name, columns, anchors in [
    ('idle', 4, [(0.5, 0.959), (0.5, 0.89)]),
    ('walk', 6, [(0.5, 0.897), (0.5, 0.81)]),
]:
    source = Image.open(ROOT / f'assets/references/generated-candidates/melissa_warrior_{name}_source.png').convert('RGBA')
    atlas = Image.new('RGBA', (96 * columns, 192))
    for row in range(2):
        for col in range(columns):
            # Fixed grid extraction, never content-aware trimming.
            bounds = (round(col * source.width / columns), round(row * source.height / 2),
                      round((col + 1) * source.width / columns), round((row + 1) * source.height / 2))
            frame = source.crop(bounds)
            # Generated N2/N4 swapped anatomical hands. Repair individual poses,
            # never duplicate a neighboring frame or manufacture a walk phase.
            if name == 'walk' and row == 0 and col in (1, 3):
                frame = frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            frame = frame.resize((75, 75), Image.Resampling.NEAREST)
            x = 48 - round(anchors[row][0] * 75)
            y = 80 - round(anchors[row][1] * 75)
            atlas.alpha_composite(frame, (96 * col + x, 96 * row + y))
    atlas.save(OUT / f'melissa_warrior_{name}.png')
