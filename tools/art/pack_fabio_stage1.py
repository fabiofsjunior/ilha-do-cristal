#!/usr/bin/env python3
"""Pack the generated Fábio Warrior stage-1 grid without editing its alpha.

This script only slices the newly generated 6x4 pose sheet on its declared
256x256 source grid, uniformly downsamples each square cell to 96x96 with
nearest-neighbor sampling, and writes candidate atlases, metadata, and a
checkerboard contact sheet. It never masks, trims, redraws, or aligns frames.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/fabio_warrior_stage1_source_v1.png"
OUTPUT = ROOT / "assets/characters/fabio/warrior"
EVIDENCE = ROOT / "docs/art/evidence/fabio"
SOURCE_CELL = (256, 256)
SOURCE_GRID = (6, 4)
CELL = (96, 96)
CONTENT_CELL = (72, 72)
PIVOT = (48, 80)
DIRECTIONS = ["N", "S"]
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}
SOURCE_ROWS = {"idle": {"N": 0, "S": 1}, "walk": {"N": 2, "S": 3}}
# One fixed placement per animation/direction, shared by every frame in that row.
# These are candidate anchors; the visual foot contact remains unvalidated.
OFFSETS = {
    "idle": {"N": (10, 11), "S": (14, 9)},
    "walk": {"N": (8, 13), "S": (13, 15)},
}


def frame_diagnostics(frame: Image.Image) -> dict:
    alpha = frame.getchannel("A")
    alpha_bytes = alpha.tobytes()
    values = set(alpha_bytes)
    result = {
        "alpha_unique_values": len(values),
        "alpha_min": min(values),
        "alpha_max": max(values),
        "transparent_pixels": alpha_bytes.count(0),
        "intermediate_alpha_pixels": len(alpha_bytes) - alpha_bytes.count(0) - alpha_bytes.count(255),
        "opaque_255_pixels": alpha_bytes.count(255),
        "bbox_alpha_gt_0": list(alpha.getbbox() or (0, 0, 0, 0)),
    }
    for cutoff in (128, 240):
        mask = alpha.point(lambda value, t=cutoff: 255 if value >= t else 0)
        result[f"bbox_alpha_gte_{cutoff}"] = list(mask.getbbox() or (0, 0, 0, 0))
    return result


def make_checkerboard(size: tuple[int, int]) -> Image.Image:
    checker = Image.new("RGBA", size, (112, 112, 112, 255))
    draw = ImageDraw.Draw(checker)
    square = 12
    for y in range(0, size[1], square):
        for x in range(0, size[0], square):
            if ((x // square) + (y // square)) % 2 == 0:
                draw.rectangle(
                    (x, y, min(x + square - 1, size[0] - 1), min(y + square - 1, size[1] - 1)),
                    fill=(166, 166, 166, 255),
                )
    return checker


def build_contact_sheet(atlases: dict[str, Image.Image]) -> None:
    scale = 3
    cell_size = (CELL[0] * scale, CELL[1] * scale)
    gap = 12
    label_width = 118
    title_height = 42
    rows = [("idle N", "idle", 0), ("idle S", "idle", 1), ("walk N", "walk", 0), ("walk S", "walk", 1)]
    sheet_width = label_width + gap + 6 * cell_size[0] + gap
    sheet_height = title_height + gap + 4 * cell_size[1] + 5 * gap
    sheet = make_checkerboard((sheet_width, sheet_height))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
    except OSError:
        font = ImageFont.load_default()
    draw.text((gap, 10), "FABIO WARRIOR | STAGE 1 | CORRIGIR | NEAREST 3x | SOURCE ALPHA PRESERVED", font=font, fill=(25, 25, 25, 255))

    for row_index, (label, state, direction_row) in enumerate(rows):
        y = title_height + gap + row_index * (cell_size[1] + gap)
        draw.text((gap, y + 8), label, font=font, fill=(20, 20, 20, 255))
        atlas = atlases[state]
        count = FRAMES[state]
        for column in range(6):
            x = label_width + gap + column * cell_size[0]
            if column < count:
                frame = atlas.crop((column * CELL[0], direction_row * CELL[1], (column + 1) * CELL[0], (direction_row + 1) * CELL[1]))
                frame = frame.resize(cell_size, Image.Resampling.NEAREST)
                sheet.alpha_composite(frame, dest=(x, y))
            else:
                draw.rectangle((x, y, x + cell_size[0] - 1, y + cell_size[1] - 1), outline=(70, 70, 70, 255), width=1)
    sheet.save(EVIDENCE / "fabio_warrior_stage1_contact.png", optimize=True)


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Missing generated source sheet: {SOURCE}")
    source_bytes = SOURCE.read_bytes()
    source_hash = hashlib.sha256(source_bytes).hexdigest()
    source = Image.open(SOURCE).convert("RGBA")
    expected_size = (SOURCE_CELL[0] * SOURCE_GRID[0], SOURCE_CELL[1] * SOURCE_GRID[1])
    if source.size != expected_size:
        raise ValueError(f"Expected source sheet {expected_size}, got {source.size}; no inferred slicing permitted")

    OUTPUT.mkdir(parents=True, exist_ok=True)
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    atlases: dict[str, Image.Image] = {}
    rows_by_state: dict[str, dict[str, dict]] = {}

    for state, count in FRAMES.items():
        atlas = Image.new("RGBA", (CELL[0] * count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
        direction_info: dict[str, dict] = {}
        for output_row, direction in enumerate(DIRECTIONS):
            source_row = SOURCE_ROWS[state][direction]
            frames_info = []
            for frame_index in range(count):
                source_region = (
                    frame_index * SOURCE_CELL[0],
                    source_row * SOURCE_CELL[1],
                    (frame_index + 1) * SOURCE_CELL[0],
                    (source_row + 1) * SOURCE_CELL[1],
                )
                source_frame = source.crop(source_region)
                content = source_frame.resize(CONTENT_CELL, Image.Resampling.NEAREST)
                offset = OFFSETS[state][direction]
                frame = Image.new("RGBA", CELL, (0, 0, 0, 0))
                frame.alpha_composite(content, dest=offset)
                atlas.alpha_composite(frame, dest=(frame_index * CELL[0], output_row * CELL[1]))
                frames_info.append({
                    "frame": frame_index,
                    "source_region": list(source_region),
                    "source_cell": list(SOURCE_CELL),
                    "uniform_content_scale": f"{CONTENT_CELL[0]}/{SOURCE_CELL[0]} = {CONTENT_CELL[0] / SOURCE_CELL[0]:.5f}",
                    "fixed_offset_for_animation_direction": list(offset),
                    "output_cell": [frame_index * CELL[0], output_row * CELL[1], (frame_index + 1) * CELL[0], (output_row + 1) * CELL[1]],
                    "diagnostics_after_uniform_nearest_scale": frame_diagnostics(frame),
                })
            direction_info[direction] = {"source_row": source_row, "frames": frames_info}

        atlas_name = f"fabio_warrior_{state}_candidate_v1.png"
        json_name = f"fabio_warrior_{state}_candidate_v1.json"
        atlas.save(OUTPUT / atlas_name, optimize=True)
        source_alpha = source.getchannel("A").tobytes()
        source_alpha_values = set(source_alpha)
        metadata = {
            "id": f"fabio_warrior_{state}_candidate_v1",
            "atlas": atlas_name,
            "status": "corrigir",
            "approved": False,
            "cell": list(CELL),
            "pivot": list(PIVOT),
            "directions": DIRECTIONS,
            "frames": count,
            "fps": FPS[state],
            "loop": True,
            "animation": state,
            "animations": {state: {"frames": count, "fps": FPS[state], "loop": True}},
            "source_tool": "OpenAI image_gen built-in (Pixel Engine generation unavailable: 4 credits; minimum generation cost 6)",
            "source_reference": "assets/references/generated-candidates/fabio_vocations_concept.png",
            "style_references": [
                "assets/references/concept-rpg-classico.png",
                "docs/art/evidence/godot_v2/all_20_frames_3x.png",
                "docs/art/evidence/maira/maira_warrior_stage1_contact.png",
            ],
            "source_sheet": "assets/references/generated-candidates/fabio_warrior_stage1_source_v1.png",
            "source_sheet_dimensions": list(source.size),
            "source_sheet_sha256": source_hash,
            "source_alpha_summary": {
                "unique_values": len(source_alpha_values),
                "min": min(source_alpha_values),
                "max": max(source_alpha_values),
                "transparent_pixels": source_alpha.count(0),
                "intermediate_alpha_pixels": len(source_alpha) - source_alpha.count(0) - source_alpha.count(255),
                "opaque_255_pixels": source_alpha.count(255),
            },
            "source_grid": {"columns": SOURCE_GRID[0], "rows": SOURCE_GRID[1], "cell": list(SOURCE_CELL), "regions_fixed": True},
            "source_directions": direction_info,
            "resampling": "nearest-neighbor, one uniform 256x256 to 72x72 reduction for every fixed square source cell, then placed in a 96x96 cell using one fixed offset per animation/direction; no content crop, per-frame scale/offset, redraw, or flip",
            "alpha_policy": "source alpha preserved as sampled, including intermediate values; no matte removal, binarization, smoothing, or retouch",
            "godot_validation": "pendente",
            "android_validation": "pendente",
            "notes": [
                "Stage-1 prototype only: north/south, idle 4 and walk 6; no Archer, Mage, extra directions, effects, or production approval.",
                "The approved Fábio three-vocation concept remains an intact reference and was not sliced to create these poses.",
                "The candidate pivot (48,80) is not certified; the alpha silhouette ends at y=78-80 depending on direction/state, and alpha boxes do not identify foot contact.",
                "Generated source alpha has intermediate values and soft edge pixels; this is preserved and requires art correction/review.",
                "The fixed row offsets are candidate anchors; body scale, exact foot contact, idle/walk continuity, and N/S consistency still need Godot review.",
                "Godot import/render, zoom 50–125%, SQM, idle/walk continuity, and Android validation remain pending.",
            ],
        }
        (OUTPUT / json_name).write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        atlases[state] = atlas
        rows_by_state[state] = direction_info

    build_contact_sheet(atlases)
    print(f"source: {SOURCE.relative_to(ROOT)} {source.size} RGBA sha256={source_hash}")
    for state, count in FRAMES.items():
        print(f"{state}: {(CELL[0] * count, CELL[1] * len(DIRECTIONS))} RGBA")
        for direction in DIRECTIONS:
            frames = rows_by_state[state][direction]["frames"]
            bboxes = [frame["diagnostics_after_uniform_nearest_scale"]["bbox_alpha_gte_128"] for frame in frames]
            print(f"  {direction}: alpha>=128 boxes {bboxes}")
    print(f"contact: {EVIDENCE / 'fabio_warrior_stage1_contact.png'}")


if __name__ == "__main__":
    main()
