#!/usr/bin/env python3
"""Pack the imagegen wolf source into a fixed 96x96 nearest-neighbor cell.

This performs mechanical, uniform resampling only. It never crops, retouches,
binarizes alpha, or fabricates additional poses. The enlarged image is a
display-only nearest-neighbor evidence preview.
"""
from __future__ import annotations

import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/wolf/wolf_se_source_v3.png"
OUTPUT_DIR = ROOT / "assets/creatures/wolf"
OUTPUT = OUTPUT_DIR / "wolf_se_candidate_v1.png"
METADATA = OUTPUT_DIR / "wolf_se_candidate_v1.json"
PREVIEW_DIR = ROOT / "docs/art/evidence/wolf"
PREVIEW = PREVIEW_DIR / "wolf_se_nearest_preview_v1.png"

CELL = (96, 96)
SAMPLED_CANVAS = (72, 72)
PLACEMENT = (10, 10)
PREVIEW_SCALE = 8
DIRECTION_ORDER = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
REQUIRED_ANIMATIONS = {
    "idle": 4,
    "walk": 6,
    "attack": 6,
    "hit": 3,
    "death": 6,
}


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Missing generated source: {SOURCE}")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

    with Image.open(SOURCE) as opened:
        source = opened.convert("RGBA")
    if source.width != source.height:
        raise ValueError(f"Expected square source canvas, got {source.size}")

    # Uniform nearest-neighbor resampling of the entire source canvas.
    # Paste without a mask so source alpha samples are copied unchanged.
    sampled = source.resize(SAMPLED_CANVAS, Image.Resampling.NEAREST)
    atlas = Image.new("RGBA", CELL, (0, 0, 0, 0))
    atlas.paste(sampled, PLACEMENT)
    atlas.save(OUTPUT)

    # Display-only enlargement; it does not alter the game atlas.
    atlas.resize(
        (CELL[0] * PREVIEW_SCALE, CELL[1] * PREVIEW_SCALE),
        Image.Resampling.NEAREST,
    ).save(PREVIEW)

    alpha = atlas.getchannel("A")
    alpha_values = sorted(set(alpha.tobytes()))
    intermediate_values = [value for value in alpha_values if value not in (0, 255)]
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Packed atlas contains no visible pixels")
    if bbox[0] == 0 or bbox[1] == 0 or bbox[2] == CELL[0] or bbox[3] == CELL[1]:
        raise ValueError(f"Visible pixels touch cell boundary: {bbox}")

    metadata = {
        "id": "wolf_se_candidate_v1",
        "species": "wolf",
        "catalog_id": "wolf",
        "asset_stage": "candidate",
        "hp": 90,
        "attack": 12,
        "behavior": "aggressive_short_range",
        "atlas": {
            "file": OUTPUT.name,
            "columns": 1,
            "rows": 1,
        },
        "cell": list(CELL),
        "pivot": [48, 80],
        "directions": ["SE"],
        "animations": {
            "idle": {
                "frames": 1,
                "fps": 1,
                "loop": True,
            }
        },
        "status": "corrigir" if intermediate_values else "candidate",
        "approved": False,
        "source": {
            "file": "../../references/generated-candidates/wolf/wolf_se_source_v3.png",
            "canvas": list(source.size),
            "tool": "built-in imagegen; one generation and two targeted edits",
        },
        "packing": {
            "method": "uniform nearest-neighbor",
            "source_canvas_resampled_to": list(SAMPLED_CANVAS),
            "placement_in_cell": list(PLACEMENT),
            "cropped": False,
            "alpha_binarized": False,
            "alpha_values_in_atlas": len(alpha_values),
            "intermediate_alpha_values_in_atlas": len(intermediate_values),
            "alpha_bbox": list(bbox),
            "display_only_preview": "../../../docs/art/evidence/wolf/wolf_se_nearest_preview_v1.png",
            "preview_scale": PREVIEW_SCALE,
        },
        "required_contract": {
            "status": "pending",
            "directions": DIRECTION_ORDER,
            "directions_pending": [direction for direction in DIRECTION_ORDER if direction != "SE"],
            "animations": {
                name: {"frames": frames, "status": "pending"}
                for name, frames in REQUIRED_ANIMATIONS.items()
            },
        },
    }
    METADATA.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(json.dumps({
        "source": str(SOURCE.relative_to(ROOT)),
        "source_size": list(source.size),
        "atlas": str(OUTPUT.relative_to(ROOT)),
        "atlas_size": list(atlas.size),
        "alpha_value_count": len(alpha_values),
        "intermediate_alpha_value_count": len(intermediate_values),
        "alpha_bbox": list(bbox),
        "status": metadata["status"],
        "metadata": str(METADATA.relative_to(ROOT)),
        "display_only_preview": str(PREVIEW.relative_to(ROOT)),
        "preview_size": [CELL[0] * PREVIEW_SCALE, CELL[1] * PREVIEW_SCALE],
    }, indent=2))


if __name__ == "__main__":
    main()
