#!/usr/bin/env python3
"""Pack Helena Warrior idle/walk candidates into 8-direction Godot atlases.

The generated sheets and original N/S candidate remain untouched. Frame regions
are fixed by source grids, then reduced uniformly with nearest-neighbor and
placed with one shared anchor per animation/direction. This is structural
candidate packaging, not an art approval.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "assets/references/generated-candidates"
OUTPUT = ROOT / "assets/characters/helena/warrior"
EVIDENCE = ROOT / "docs/art/evidence/helena"
CELL = (96, 96)
PIVOT = (48, 80)
CONTENT_HEIGHT = 68
DIRECTIONS = ("N", "NE", "E", "SE", "S", "SW", "W", "NW")
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_summary(image: Image.Image) -> dict:
    values = image.getchannel("A").tobytes()
    return {
        "unique_values": len(set(values)),
        "min": min(values),
        "max": max(values),
        "transparent_pixels": values.count(0),
        "intermediate_alpha_pixels": sum(0 < value < 255 for value in values),
        "opaque_pixels": values.count(255),
    }


def fixed_grid_regions(
    *, state: str, direction: str, size: tuple[int, int]
) -> tuple[Image.Image, list[tuple[int, int, int, int]], tuple[int, int], dict]:
    """Return a working source, fixed source cell regions, and provenance."""
    name = f"helena_warrior_{direction.lower()}_{state}_source_v1.png"
    version = "v1"
    if direction == "NE":
        name = f"helena_warrior_ne_{state}_source_v2.png"
        version = "v2"
    path = SOURCES / name
    raw = Image.open(path).convert("RGBA")
    raw_size = raw.size
    provenance = {
        "file": str(path.relative_to(ROOT)),
        "sha256": sha256(path),
        "source_version": version,
        "raw_dimensions": list(raw_size),
        "raw_alpha": alpha_summary(raw),
        "region_policy": "fixed grid regions only; no alpha/content trim",
    }

    if state == "walk":
        if raw_size != (1536, 1024):
            raise ValueError(f"Unexpected walk source size for {direction}: {raw_size}")
        source_cell = (512, 512)
        regions = [
            ((index % 3) * source_cell[0], (index // 3) * source_cell[1],
             (index % 3 + 1) * source_cell[0], (index // 3 + 1) * source_cell[1])
            for index in range(FRAMES[state])
        ]
        provenance.update({
            "grid": [3, 2],
            "source_cell": list(source_cell),
            "frame_regions": [list(region) for region in regions],
            "preprocessing": "none",
        })
        return raw, regions, source_cell, provenance

    if direction in ("NE", "NW"):
        if direction == "NW":
            name = "helena_warrior_nw_idle_source_v1.png"
            path = SOURCES / name
            raw = Image.open(path).convert("RGBA")
            raw_size = raw.size
            provenance = {
                "file": str(path.relative_to(ROOT)),
                "sha256": sha256(path),
                "source_version": "v1",
                "raw_dimensions": list(raw_size),
                "raw_alpha": alpha_summary(raw),
                "region_policy": "fixed grid regions only; no alpha/content trim",
            }
        if raw_size != (1774, 887):
            raise ValueError(f"Unexpected 4x2 idle sheet size for {direction}: {raw_size}")
        # The source is an exact 4x2 grid whose four poses occupy fixed inner
        # columns 1 and 2. A uniform whole-sheet nearest resample makes 443px
        # square cells; then those two columns are selected by grid position.
        working = raw.resize((1772, 886), Image.Resampling.NEAREST)
        source_cell = (443, 443)
        regions = [
            (column * source_cell[0], row * source_cell[1],
             (column + 1) * source_cell[0], (row + 1) * source_cell[1])
            for row in range(2)
            for column in (1, 2)
        ]
        provenance.update({
            "grid": [4, 2],
            "selected_grid_columns": [1, 2],
            "source_cell": list(source_cell),
            "frame_regions_after_uniform_sheet_resample": [list(region) for region in regions],
            "preprocessing": {
                "operation": "uniform nearest resample of whole sheet",
                "from": list(raw_size),
                "to": [1772, 886],
                "reason": "convert half-pixel 4x2 grid boundaries into fixed 443x443 cells",
            },
        })
        return working, regions, source_cell, provenance

    if direction == "W":
        if raw_size != (1312, 1199):
            raise ValueError(f"Unexpected W idle source size: {raw_size}")
        # Add one fully transparent row, retaining every source pixel, so the
        # two fixed source rows have equal integer height of 600px.
        working = Image.new("RGBA", (1312, 1200), (0, 0, 0, 0))
        working.paste(raw, (0, 0))
        source_cell = (656, 600)
        regions = [
            (column * source_cell[0], row * source_cell[1],
             (column + 1) * source_cell[0], (row + 1) * source_cell[1])
            for row in range(2)
            for column in range(2)
        ]
        provenance.update({
            "grid": [2, 2],
            "source_cell": list(source_cell),
            "frame_regions_after_transparent_padding": [list(region) for region in regions],
            "preprocessing": {
                "operation": "append one transparent row at bottom of working copy",
                "from": list(raw_size),
                "to": [1312, 1200],
                "reason": "equal integer 656x600 cells; source PNG remains unchanged",
            },
        })
        return working, regions, source_cell, provenance

    if raw_size != (1254, 1254):
        raise ValueError(f"Unexpected square idle source size for {direction}: {raw_size}")
    source_cell = (627, 627)
    regions = [
        (column * source_cell[0], row * source_cell[1],
         (column + 1) * source_cell[0], (row + 1) * source_cell[1])
        for row in range(2)
        for column in range(2)
    ]
    provenance.update({
        "grid": [2, 2],
        "source_cell": list(source_cell),
        "frame_regions": [list(region) for region in regions],
        "preprocessing": "none",
    })
    return raw, regions, source_cell, provenance


def copied_stage1_row(state: str, direction: str) -> tuple[Image.Image, dict]:
    source_name = f"helena_warrior_{state}_candidate_v1.png"
    source_path = OUTPUT / source_name
    row_index = 0 if direction == "N" else 1
    atlas = Image.open(source_path).convert("RGBA")
    count = FRAMES[state]
    if atlas.size != (CELL[0] * count, CELL[1] * 2):
        raise ValueError(f"Unexpected stage-1 atlas size for {state}: {atlas.size}")
    row = atlas.crop((0, row_index * CELL[1], atlas.width, (row_index + 1) * CELL[1]))
    return row, {
        "file": str(source_path.relative_to(ROOT)),
        "sha256": sha256(source_path),
        "source_row": row_index,
        "copied_pixel_exact": True,
        "note": "N/S pixels copied unchanged from the pre-existing candidate v1",
    }


def build_atlas(state: str) -> tuple[Image.Image, dict]:
    count = FRAMES[state]
    atlas = Image.new("RGBA", (CELL[0] * count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
    source_records = {}

    for row_index, direction in enumerate(DIRECTIONS):
        if direction in ("N", "S"):
            row, record = copied_stage1_row(state, direction)
            atlas.paste(row, (0, row_index * CELL[1]))
            record["frames"] = [
                {"index": index, "output_region": [index * CELL[0], row_index * CELL[1], (index + 1) * CELL[0], (row_index + 1) * CELL[1]]}
                for index in range(count)
            ]
            source_records[direction] = record
            continue

        working, regions, source_cell, provenance = fixed_grid_regions(
            state=state, direction=direction, size=(0, 0)
        )
        scale = CONTENT_HEIGHT / source_cell[1]
        content_w = round(source_cell[0] * scale)
        content_h = round(source_cell[1] * scale)
        offset = ((CELL[0] - content_w) // 2, 80 - content_h)
        frame_records = []
        for frame_index, region in enumerate(regions):
            source_frame = working.crop(region)
            scaled = source_frame.resize((content_w, content_h), Image.Resampling.NEAREST)
            packed = Image.new("RGBA", CELL, (0, 0, 0, 0))
            packed.paste(scaled, offset)
            atlas.paste(packed, (frame_index * CELL[0], row_index * CELL[1]))
            frame_records.append({
                "index": frame_index,
                "source_region_fixed": list(region),
                "source_cell": list(source_cell),
                "output_content_size": [content_w, content_h],
                "uniform_scale": f"{CONTENT_HEIGHT}/{source_cell[1]}",
                "shared_offset_for_direction": list(offset),
                "output_region": [frame_index * CELL[0], row_index * CELL[1], (frame_index + 1) * CELL[0], (row_index + 1) * CELL[1]],
            })
        source_records[direction] = {**provenance, "frames": frame_records}

    return atlas, source_records


def checkerboard(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (83, 83, 83, 255))
    draw = ImageDraw.Draw(image)
    square = 12
    for y in range(0, size[1], square):
        for x in range(0, size[0], square):
            if (x // square + y // square) % 2 == 0:
                draw.rectangle((x, y, min(x + square - 1, size[0] - 1), min(y + square - 1, size[1] - 1)), fill=(118, 118, 118, 255))
    return image


def build_contact(atlases: dict[str, Image.Image]) -> None:
    scale = 2
    label_w, gap, title_h, row_gap = 92, 18, 52, 12
    idle_w = label_w + FRAMES["idle"] * CELL[0] * scale
    walk_w = label_w + FRAMES["walk"] * CELL[0] * scale
    panel_gap = 28
    width = idle_w + walk_w + panel_gap + 24
    height = title_h + len(DIRECTIONS) * (CELL[1] * scale + row_gap) + 16
    sheet = checkerboard((width, height))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 17)
        small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 11)
    except OSError:
        font = ImageFont.load_default()
        small = ImageFont.load_default()
    draw.text((12, 10), "HELENA WARRIOR | IDLE + WALK | 8 DIRECTIONS | CANDIDATE v2 | CORRIGIR", font=font, fill=(15, 15, 15, 255))
    idle_x = 12
    walk_x = idle_x + idle_w + panel_gap
    draw.text((idle_x, 32), "IDLE · 4 frames", font=small, fill=(20, 20, 20, 255))
    draw.text((walk_x, 32), "WALK · 6 frames", font=small, fill=(20, 20, 20, 255))

    for row_index, direction in enumerate(DIRECTIONS):
        y = title_h + row_index * (CELL[1] * scale + row_gap)
        draw.text((idle_x, y + 7), direction, font=font, fill=(20, 20, 20, 255))
        draw.text((walk_x, y + 7), direction, font=font, fill=(20, 20, 20, 255))
        for state, panel_x in (("idle", idle_x), ("walk", walk_x)):
            count = FRAMES[state]
            for frame_index in range(count):
                x = panel_x + label_w + frame_index * CELL[0] * scale
                frame = atlases[state].crop((frame_index * CELL[0], row_index * CELL[1], (frame_index + 1) * CELL[0], (row_index + 1) * CELL[1]))
                enlarged = frame.resize((CELL[0] * scale, CELL[1] * scale), Image.Resampling.NEAREST)
                sheet.alpha_composite(enlarged, (x, y))
                draw.rectangle((x, y, x + CELL[0] * scale - 1, y + CELL[1] * scale - 1), outline=(45, 45, 45, 255), width=1)
                draw.text((x + 4, y + 3), str(frame_index), font=small, fill=(20, 20, 20, 255))
    sheet.save(EVIDENCE / "helena_warrior_8dir_contact.png", optimize=True)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    concept = ROOT / "assets/references/concept-rpg-classico.png"
    all_atlases = {}

    for state in ("idle", "walk"):
        atlas, source_records = build_atlas(state)
        atlas_name = f"helena_warrior_{state}_candidate_v2.png"
        metadata_name = f"helena_warrior_{state}_candidate_v2.json"
        atlas.save(OUTPUT / atlas_name, optimize=True)
        metadata = {
            "id": f"helena_warrior_{state}_candidate_v2",
            "atlas": atlas_name,
            "status": "corrigir",
            "approved": False,
            "character": "Helena",
            "vocation": "Warrior",
            "assumption": "Warrior segue como vocação candidata apenas para este exemplar; Helena não possui vocação padrão definida.",
            "cell": list(CELL),
            "pivot": list(PIVOT),
            "directions": list(DIRECTIONS),
            "animations": {state: {"frames": FRAMES[state], "fps": FPS[state], "loop": True}},
            "source_tool": "OpenAI image_gen built-in",
            "concept_reference": {
                "path": "assets/references/concept-rpg-classico.png",
                "git_blob_sha": "82a60ab282c23d0e6846a10a2d8b5e8614537ac3",
                "identity_traits_used": "cabelo castanho ondulado, tiara clara, acentos creme/rosa, espada Warrior",
                "use": "Referência visual consultada para identidade; nunca cortada ou fatiada para criar quadros.",
            },
            "source_directions": source_records,
            "alpha_policy": "Alpha original preservado; redução somente por nearest, sem binarização, remoção de halo, flood fill ou retoque.",
            "validation": {"structure": "pendente", "visual_art": "corrigir", "godot": "pendente", "android": "pendente"},
            "notes": [
                "Inclui as oito direções na ordem contratual: N, NE, E, SE, S, SW, W, NW.",
                "N/S foram copiados pixel a pixel dos atlas Helena v1; fontes e candidatos v1 permanecem intactos.",
                "E/W e as diagonais foram gerados como fontes distintas. NE usa uma segunda tentativa direcionada para ângulo intermediário; a primeira também foi preservada.",
                "Células 96x96, pivô (48,80), escala e FPS continuam candidatos, sem validação de importação em Godot ou Android.",
                "Nearest reduz resolução e pode descartar detalhe; a fonte gerada integral segue preservada.",
                "O alpha suave e os halos da geração foram preservados, embora contrariem a direção de arte de pixel nítido.",
                "A prancha registra quadros gerados, não certifica contato dos pés, ciclo, identidade entre direções ou aprovação artística.",
            ],
        }
        (OUTPUT / metadata_name).write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        all_atlases[state] = atlas

    build_contact(all_atlases)
    summary = {
        "status": "corrigir",
        "directions": list(DIRECTIONS),
        "concept_blob_sha": "82a60ab282c23d0e6846a10a2d8b5e8614537ac3",
        "concept_sha256": sha256(concept),
        "atlases": {
            state: {
                "file": f"assets/characters/helena/warrior/helena_warrior_{state}_candidate_v2.png",
                "dimensions": list(all_atlases[state].size),
                "alpha": alpha_summary(all_atlases[state]),
            }
            for state in ("idle", "walk")
        },
        "contact": "docs/art/evidence/helena/helena_warrior_8dir_contact.png",
    }
    (EVIDENCE / "helena_warrior_8dir_structure.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
