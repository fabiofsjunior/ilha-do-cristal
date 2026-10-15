#!/usr/bin/env python3
"""Pack Melissa Warrior's eight-direction idle/walk candidate without synthesis."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
CHAR_DIR = ROOT / "assets/characters/melissa/warrior"
SOURCE_DIR = ROOT / "assets/references/generated-candidates"
EVIDENCE_DIR = ROOT / "docs/art/evidence/melissa"
DIRECTIONS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
NEW_SOURCE_VERSIONS = {
    "NE": 1,
    "E": 1,
    "SE": 1,
    "SW": 1,
    "W": 1,
    "NW": 2,
}
CELL = (96, 96)
PIVOT = (48, 80)  # Candidate value from the existing project contract.
SOURCE_CELL = 362
SOURCE_INSET = 8  # Fixed uniform trim to remove generated sheet edge strokes.
SOURCE_SCALE = 0.20  # Same scale for all generated directions and frames.
SOURCE_ANCHOR_IDLE = (173, 331)  # Manually estimated in trimmed source-cell space.
SOURCE_ANCHOR_WALK = (173, 314)  # Same anchor for every frame in each direction.


def source_path(direction: str) -> Path:
    version = NEW_SOURCE_VERSIONS[direction]
    return SOURCE_DIR / f"melissa_warrior_{direction}_source_8dir_v{version}.png"


def crop_candidate_frame(animation: str, direction: str, frame_index: int) -> tuple[Image.Image, dict]:
    if direction in ("N", "S"):
        atlas_name = f"melissa_warrior_{animation}_candidate_v3.png"
        source = Image.open(CHAR_DIR / atlas_name).convert("RGBA")
        row = 0 if direction == "N" else 1
        frame = source.crop((frame_index * 96, row * 96, (frame_index + 1) * 96, (row + 1) * 96))
        return frame, {
            "path": str((CHAR_DIR / atlas_name).relative_to(ROOT)),
            "region_px": [frame_index * 96, row * 96, (frame_index + 1) * 96, (row + 1) * 96],
            "operation": "copied unchanged from existing candidate_v3 cell",
        }

    source_file = source_path(direction)
    source = Image.open(source_file).convert("RGBA")
    if source.size != (2172, 724):
        raise ValueError(f"{source_file.name}: expected 2172x724, got {source.size}")
    row = 0 if animation == "idle" else 1
    x0 = frame_index * SOURCE_CELL + SOURCE_INSET
    y0 = row * SOURCE_CELL + SOURCE_INSET
    x1 = (frame_index + 1) * SOURCE_CELL - SOURCE_INSET
    y1 = (row + 1) * SOURCE_CELL - SOURCE_INSET
    tile = source.crop((x0, y0, x1, y1))
    width = round(tile.width * SOURCE_SCALE)
    height = round(tile.height * SOURCE_SCALE)
    tile = tile.resize((width, height), Image.Resampling.NEAREST)
    anchor = SOURCE_ANCHOR_IDLE if animation == "idle" else SOURCE_ANCHOR_WALK
    position = (PIVOT[0] - round(anchor[0] * SOURCE_SCALE), PIVOT[1] - round(anchor[1] * SOURCE_SCALE))
    cell = Image.new("RGBA", CELL, (0, 0, 0, 0))
    cell.alpha_composite(tile, position)
    return cell, {
        "path": str(source_file.relative_to(ROOT)),
        "region_px": [x0, y0, x1, y1],
        "operation": "fixed-grid crop, uniform 8px perimeter trim, uniform 0.20 nearest resize, common estimated anchor",
        "crop_inset_px": SOURCE_INSET,
        "uniform_scale": SOURCE_SCALE,
        "estimated_anchor_in_trimmed_cell_px": list(anchor),
        "placement_px": list(position),
    }


def build_atlas(animation: str, count: int, fps: int) -> tuple[Path, Path, list[list[dict]]]:
    identifier = f"melissa_warrior_{animation}_8dir_candidate_v1"
    atlas = Image.new("RGBA", (CELL[0] * count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
    source_regions: list[list[dict]] = []
    for row, direction in enumerate(DIRECTIONS):
        direction_sources = []
        for frame_index in range(count):
            frame, source_info = crop_candidate_frame(animation, direction, frame_index)
            atlas.alpha_composite(frame, (frame_index * CELL[0], row * CELL[1]))
            direction_sources.append(source_info)
        source_regions.append(direction_sources)

    png_path = CHAR_DIR / f"{identifier}.png"
    json_path = CHAR_DIR / f"{identifier}.json"
    atlas.save(png_path)
    metadata = {
        "id": identifier,
        "atlas": png_path.name,
        "cell": list(CELL),
        "pivot": list(PIVOT),
        "directions": DIRECTIONS,
        "animations": {animation: {"frames": count, "fps": fps, "loop": True}},
        "animation": animation,
        "frames": count,
        "fps": fps,
        "loop": True,
        "stage": "expanded_8_direction_candidate",
        "status": "corrigir",
        "approved": False,
        "source_regions_by_direction_and_frame": {
            direction: source_regions[row] for row, direction in enumerate(DIRECTIONS)
        },
        "notes": [
            "N/S rows are copied unchanged from the pre-existing Melissa Warrior candidate_v3 atlas.",
            "Other direction sources are kept intact in assets/references/generated-candidates/.",
            "No frames were mirrored, duplicated, or individually scaled.",
            "Generated-direction sources were sliced on a fixed 6x2 grid after an 8px uniform perimeter trim; the NW v1 source is preserved but v2 is used because v1 placed idle frames irregularly.",
            "Nearest resampling does not remove antialiasing. Intermediate alpha remains and the atlas is not approved.",
            "96x96 cells and pivot (48,80) are candidates; visual scale and foot contact are not approved.",
        ],
    }
    json_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    return png_path, json_path, source_regions


def create_contact_sheet(idle_path: Path, walk_path: Path) -> Path:
    idle = Image.open(idle_path).convert("RGBA")
    walk = Image.open(walk_path).convert("RGBA")
    scale = 2
    tile_size = CELL[0] * scale
    label_w = 64
    gutter = 18
    section_gap = 34
    margin = 18
    header_h = 44
    row_h = tile_size + 20
    width = margin * 2 + label_w + 4 * tile_size + 3 * gutter + section_gap + 6 * tile_size + 5 * gutter
    height = margin * 2 + header_h + len(DIRECTIONS) * (row_h + gutter)
    sheet = Image.new("RGB", (width, height), (36, 44, 51))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    draw.text((margin, margin), "Melissa Warrior · candidate v1 · CORRIGIR · not production-approved", fill=(246, 239, 220), font=font)
    y_top = margin + header_h
    x_idle = margin + label_w
    x_walk = x_idle + 4 * tile_size + 3 * gutter + section_gap
    draw.text((x_idle, margin + 22), "IDLE · 4 frames", fill=(246, 239, 220), font=font)
    draw.text((x_walk, margin + 22), "WALK · 6 frames", fill=(246, 239, 220), font=font)

    def composite_preview(cell: Image.Image) -> Image.Image:
        preview = cell.resize((tile_size, tile_size), Image.Resampling.NEAREST)
        background = Image.new("RGBA", (tile_size, tile_size), (39, 53, 66, 255))
        light = Image.new("RGBA", (tile_size // 2, tile_size), (238, 229, 207, 255))
        background.alpha_composite(light, (tile_size // 2, 0))
        background.alpha_composite(preview)
        return background.convert("RGB")

    for row, direction in enumerate(DIRECTIONS):
        y = y_top + row * (row_h + gutter)
        draw.text((margin, y + tile_size // 2 - 4), direction, fill=(246, 239, 220), font=font)
        for index in range(4):
            cell = idle.crop((index * 96, row * 96, (index + 1) * 96, (row + 1) * 96))
            sheet.paste(composite_preview(cell), (x_idle + index * (tile_size + gutter), y))
        for index in range(6):
            cell = walk.crop((index * 96, row * 96, (index + 1) * 96, (row + 1) * 96))
            sheet.paste(composite_preview(cell), (x_walk + index * (tile_size + gutter), y))
    path = EVIDENCE_DIR / "melissa_warrior_8dir_candidate_v1_contact.png"
    path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path)
    return path


def main() -> None:
    CHAR_DIR.mkdir(parents=True, exist_ok=True)
    idle_path, idle_json, _ = build_atlas("idle", 4, 6)
    walk_path, walk_json, _ = build_atlas("walk", 6, 10)
    contact_path = create_contact_sheet(idle_path, walk_path)
    print(idle_path.relative_to(ROOT))
    print(idle_json.relative_to(ROOT))
    print(walk_path.relative_to(ROOT))
    print(walk_json.relative_to(ROOT))
    print(contact_path.relative_to(ROOT))


if __name__ == "__main__":
    main()
