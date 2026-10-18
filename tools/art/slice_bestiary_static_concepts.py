#!/usr/bin/env python3
"""Slice the 5x6 static concept board into versioned one-pose creature sprites."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "Docs/art/candidates/bestiary-static-concepts-30-v0.1.png"
CATALOG = ROOT / "data/catalogs/mvp.json"
OUTPUT_SIZE = (229, 229)
COLUMNS = 5
ROWS = 6
ALPHA_THRESHOLD = 31


def render_height(hp: int) -> int:
    """Keep the concepts near the current 48–97 px creature footprint scale."""
    if hp < 70:
        return 54
    if hp < 150:
        return 62
    if hp < 220:
        return 70
    return 84


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    monsters = catalog["monsters"]
    if len(monsters) != COLUMNS * ROWS:
        raise ValueError(f"Expected exactly {COLUMNS * ROWS} monsters, found {len(monsters)}")

    with Image.open(SOURCE) as opened:
        sheet = opened.convert("RGBA")
    expected_size = (COLUMNS * OUTPUT_SIZE[0], ROWS * OUTPUT_SIZE[1])
    if sheet.size != expected_size:
        raise ValueError(f"Expected source board {expected_size}, found {sheet.size}")

    total_pixels = 0
    for index, monster in enumerate(monsters):
        column, row = index % COLUMNS, index // COLUMNS
        x, y = column * OUTPUT_SIZE[0], row * OUTPUT_SIZE[1]
        crop = sheet.crop((x, y, x + OUTPUT_SIZE[0], y + OUTPUT_SIZE[1]))
        alpha = crop.getchannel("A")
        thresholded = alpha.point(lambda value: 255 if value > ALPHA_THRESHOLD else 0)
        bbox = thresholded.getbbox()
        if bbox is None:
            raise ValueError(f"Empty transparent cell for {monster['id']} at ({column}, {row})")

        min_x, min_y, max_x, max_y = bbox
        pivot_x = (min_x + max_x) / 2.0
        pivot_y = float(max_y)
        scale = render_height(int(monster["hp"])) / (max_y - min_y)
        extents = [
            round(-(pivot_x - min_x) * scale, 2),
            round((max_x - pivot_x) * scale, 2),
            0.0,
            round((pivot_y - min_y) * scale, 2),
        ]

        monster_id = monster["id"]
        folder = ROOT / "assets" / "creatures" / monster_id
        folder.mkdir(parents=True, exist_ok=True)
        stem = f"{monster_id}_static_concept_v0_1"
        png_path = folder / f"{stem}.png"
        metadata_path = folder / f"{stem}.json"
        crop.save(png_path, format="PNG", optimize=True)

        histogram = alpha.histogram()
        intermediate_alpha = sum(histogram[1:255])
        metadata = {
            "id": monster_id,
            "species": monster_id,
            "atlas": {"file": png_path.name, "columns": 1, "rows": 1},
            "cell": list(OUTPUT_SIZE),
            "pivot": [round(pivot_x, 2), round(pivot_y, 2)],
            "directions": ["SE"],
            "animations": {"idle": {"frames": 1, "fps": 1, "loop": True}},
            "render_scale": round(scale, 5),
            "footprint_extents_px": extents,
            "approved": False,
            "status": "concept_static_runtime_preview",
            "candidate_stage": "single_static_pose",
            "source": {
                "file": "Docs/art/candidates/bestiary-static-concepts-30-v0.1.png",
                "sheet_size": list(sheet.size),
                "grid": [COLUMNS, ROWS],
                "cell_index": index,
                "cell": [column, row],
                "alpha_bbox_threshold_gt": ALPHA_THRESHOLD,
                "alpha_bbox": list(bbox),
                "intermediate_alpha_pixels": intermediate_alpha,
                "crop_operation": "exact 229x229 cell crop; no resampling or alpha changes",
            },
        }
        metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        total_pixels += crop.width * crop.height
        monster["sprite_path"] = png_path.relative_to(ROOT).as_posix()

    CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Sliced {len(monsters)} poses: {total_pixels:,} source pixels preserved across {len(monsters)} RGBA PNGs.")


if __name__ == "__main__":
    main()

