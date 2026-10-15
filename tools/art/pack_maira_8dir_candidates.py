#!/usr/bin/env python3
"""Pack Maíra Warrior eight-direction candidate atlases without cleanup.

The six new direction strips are preserved under assets/references. This
script divides each generated strip into equal temporal regions, scales all
new frames uniformly with nearest-neighbor, and places them in fixed 96x96
cells. It does not trim, binarize alpha, recolor, or mirror pixels.
"""
from __future__ import annotations

import json
import statistics
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/maira_warrior"
OUTPUT = ROOT / "assets/characters/maira/warrior"
EVIDENCE = ROOT / "docs/art/evidence/maira"

CELL = (96, 96)
PIVOT = (48, 80)
DIRECTIONS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
MISSING = ["NE", "E", "SE", "SW", "W", "NW"]
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}
SCALE = 0.11
CHECKER = 12


def source_name(animation: str, direction: str) -> str:
    return f"{animation}_{direction.lower()}_source_oai_v1.png"


def old_atlas(animation: str) -> Image.Image:
    path = OUTPUT / f"maira_warrior_{animation}_candidate_v1.png"
    image = Image.open(path).convert("RGBA")
    expected = (CELL[0] * FRAMES[animation], CELL[1] * 2)
    if image.size != expected:
        raise ValueError(f"{path}: expected old N/S atlas {expected}, got {image.size}")
    return image


def get_source_cells(animation: str, direction: str) -> tuple[Image.Image, list[Image.Image], list[dict], list[int]]:
    path = SOURCE / source_name(animation, direction)
    sheet = Image.open(path).convert("RGBA")
    count = FRAMES[animation]
    if sheet.width % count:
        raise ValueError(f"{path}: width {sheet.width} not divisible by {count} frames")
    frame_width = sheet.width // count
    if sheet.height != 724 or sheet.width != 2172:
        raise ValueError(f"{path}: unexpected source dimensions {sheet.size}")

    frames: list[Image.Image] = []
    regions: list[dict] = []
    bottoms: list[int] = []
    raw_cells: list[Image.Image] = []
    for index in range(count):
        region = (index * frame_width, 0, (index + 1) * frame_width, sheet.height)
        raw = sheet.crop(region)
        raw_cells.append(raw)
        bounds = raw.getchannel("A").point(lambda a: 255 if a >= 128 else 0).getbbox()
        if bounds is None:
            raise ValueError(f"{path}: frame {index} is empty")
        bottoms.append(bounds[3] - 1)
        regions.append({
            "frame": index,
            "source_region": list(region),
            "source_cell": [frame_width, sheet.height],
            "alpha128_bbox": list(bounds),
            "source_alpha_touches_partition": bool(bounds[0] == 0 or bounds[2] == frame_width),
        })

    # One fixed vertical translation per animation, derived from the median
    # silhouette bottom across every generated frame/direction. This is a
    # geometric proxy; it does not identify the feet.
    return sheet, raw_cells, regions, bottoms


def checker_cell(size: tuple[int, int], x0: int, y0: int) -> Image.Image:
    w, h = size
    cell = Image.new("RGB", size, (102, 102, 102))
    draw = ImageDraw.Draw(cell)
    for y in range(0, h, CHECKER):
        for x in range(0, w, CHECKER):
            if ((x0 + x) // CHECKER + (y0 + y) // CHECKER) % 2 == 0:
                draw.rectangle((x, y, min(x + CHECKER - 1, w - 1), min(y + CHECKER - 1, h - 1)), fill=(142, 142, 142))
    return cell


def build_contact(atlases: dict[str, Image.Image]) -> None:
    scale = 2
    label_w = 72
    row_h = CELL[1] * scale
    gap = 12
    title_h = 34
    panel_gap = 28
    idle_w = label_w + FRAMES["idle"] * row_h
    walk_w = label_w + FRAMES["walk"] * row_h
    width = max(idle_w, walk_w) + gap * 2
    height = (title_h + len(DIRECTIONS) * row_h + panel_gap
              + title_h + len(DIRECTIONS) * row_h + gap * 2)
    sheet = Image.new("RGB", (width, height), (27, 27, 30))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=16)
    small = ImageFont.load_default(size=13)
    y = gap
    draw.text((gap, y), "MAIRA WARRIOR - IDLE - 4 FRAMES", font=font, fill=(255, 238, 192))
    y += title_h
    for direction in DIRECTIONS:
        draw.text((gap, y + 8), direction, font=small, fill=(255, 238, 192))
        row = DIRECTIONS.index(direction)
        for frame in range(FRAMES["idle"]):
            x = gap + label_w + frame * row_h
            tile = checker_cell((row_h, row_h), x, y)
            sprite = atlases["idle"].crop((
                frame * CELL[0], row * CELL[1],
                (frame + 1) * CELL[0], (row + 1) * CELL[1],
            )).resize((row_h, row_h), Image.Resampling.NEAREST)
            tile.paste(sprite, (0, 0), sprite)
            sheet.paste(tile, (x, y))
        y += row_h

    y += panel_gap
    draw.text((gap, y), "MAIRA WARRIOR - WALK - 6 FRAMES", font=font, fill=(255, 238, 192))
    y += title_h
    for row, direction in enumerate(DIRECTIONS):
        draw.text((gap, y + 8), direction, font=small, fill=(255, 238, 192))
        for frame in range(FRAMES["walk"]):
            x = gap + label_w + frame * row_h
            tile = checker_cell((row_h, row_h), x, y)
            sprite = atlases["walk"].crop((
                frame * CELL[0], row * CELL[1],
                (frame + 1) * CELL[0], (row + 1) * CELL[1],
            )).resize((row_h, row_h), Image.Resampling.NEAREST)
            tile.paste(sprite, (0, 0), sprite)
            sheet.paste(tile, (x, y))
        y += row_h
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    sheet.save(EVIDENCE / "maira_warrior_8dir_contact.png", optimize=True)


def build_alpha_check(atlases: dict[str, Image.Image]) -> None:
    """Show frame 0 for every direction over light and dark solid fills."""
    scale = 2
    label_w = 72
    tile_w = CELL[0] * scale
    tile_h = CELL[1] * scale
    gap = 8
    heading_h = 24
    panel_gap = 14
    width = label_w + 2 * tile_w + 4 * gap
    height = 2 * (2 * heading_h + len(DIRECTIONS) * (tile_h + gap) + panel_gap) + gap
    sheet = Image.new("RGB", (width, height), (28, 28, 31))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=15)
    small = ImageFont.load_default(size=12)
    y = gap
    for animation in ("idle", "walk"):
        draw.text((gap, y), f"{animation.upper()} FRAME 0", font=font, fill=(255, 238, 192))
        y += heading_h
        draw.text((gap + label_w, y), "LIGHT", font=small, fill=(255, 238, 192))
        dark_x = gap + label_w + tile_w + gap
        draw.text((dark_x, y), "DARK", font=small, fill=(255, 238, 192))
        y += heading_h
        for row, direction in enumerate(DIRECTIONS):
            row_y = y + row * (tile_h + gap)
            draw.text((gap, row_y + 6), direction, font=small, fill=(255, 238, 192))
            frame = atlases[animation].crop((0, row * CELL[1], CELL[0], (row + 1) * CELL[1]))
            frame = frame.resize((tile_w, tile_h), Image.Resampling.NEAREST)
            for col, background in enumerate(((235, 235, 235), (36, 36, 40))):
                tile = Image.new("RGB", (tile_w, tile_h), background)
                tile.paste(frame, (0, 0), frame.getchannel("A"))
                x = gap + label_w + col * (tile_w + gap)
                sheet.paste(tile, (x, row_y))
        y += len(DIRECTIONS) * (tile_h + gap) + panel_gap
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    sheet.save(EVIDENCE / "maira_warrior_8dir_alpha_check.png", optimize=True)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    all_atlases: dict[str, Image.Image] = {}
    source_info: dict[str, dict] = {}

    for animation, count in FRAMES.items():
        source_info: dict[str, dict] = {}
        previous = old_atlas(animation)
        atlas = Image.new(
            "RGBA",
            (CELL[0] * count, CELL[1] * len(DIRECTIONS)),
            (0, 0, 0, 0),
        )
        # Preserve the existing N/S candidate frames byte-for-byte.
        for direction, source_row in (("N", 0), ("S", 1)):
            target_row = DIRECTIONS.index(direction)
            for frame in range(count):
                cell = previous.crop((
                    frame * CELL[0], source_row * CELL[1],
                    (frame + 1) * CELL[0], (source_row + 1) * CELL[1],
                ))
                atlas.alpha_composite(cell, (frame * CELL[0], target_row * CELL[1]))
            source_info[f"{animation}_{direction}"] = {
                "source_atlas": f"assets/characters/maira/warrior/maira_warrior_{animation}_candidate_v1.png",
                "source_row": source_row,
                "resampling": "none; prior candidate copied unchanged",
            }

        all_bottoms: list[int] = []
        raw_by_direction: dict[str, tuple[Image.Image, list[Image.Image], list[dict], list[int]]] = {}
        for direction in MISSING:
            result = get_source_cells(animation, direction)
            raw_by_direction[direction] = result
            all_bottoms.extend(result[3])
        vertical_offset = round(PIVOT[1] - statistics.median(all_bottoms) * SCALE)

        for direction in MISSING:
            sheet, raw_cells, regions, _ = raw_by_direction[direction]
            row = DIRECTIONS.index(direction)
            frame_width = sheet.width // count
            scaled_size = (round(frame_width * SCALE), round(sheet.height * SCALE))
            x_offset = (CELL[0] - scaled_size[0]) // 2
            if x_offset < 0 or x_offset + scaled_size[0] > CELL[0] or vertical_offset < 0 or vertical_offset + scaled_size[1] > CELL[1]:
                raise ValueError(f"{animation}/{direction}: fixed transform falls outside {CELL}")
            for frame, raw in enumerate(raw_cells):
                resized = raw.resize(scaled_size, Image.Resampling.NEAREST)
                cell = Image.new("RGBA", CELL, (0, 0, 0, 0))
                cell.alpha_composite(resized, (x_offset, vertical_offset))
                atlas.alpha_composite(cell, (frame * CELL[0], row * CELL[1]))
                final_alpha = cell.getchannel("A")
                final_bbox = final_alpha.point(lambda a: 255 if a >= 128 else 0).getbbox()
                if final_bbox is None:
                    raise ValueError(f"{animation}/{direction}/{frame}: empty after packing")
                regions[frame]["packed_alpha128_bbox"] = list(final_bbox)
                regions[frame]["packed_alpha128_bottom_y"] = final_bbox[3] - 1
                regions[frame]["packed_bbox_touches_cell_edge"] = bool(
                    final_bbox[0] == 0 or final_bbox[1] == 0
                    or final_bbox[2] == CELL[0] or final_bbox[3] == CELL[1]
                )
                source_alpha_values = set(raw.getchannel("A").tobytes())
                regions[frame]["source_intermediate_alpha_values"] = len(source_alpha_values - {0, 255})
            source_info[f"{animation}_{direction}"] = {
                "source_strip": f"assets/references/generated-candidates/maira_warrior/{source_name(animation, direction)}",
                "source_dimensions": list(sheet.size),
                "source_frame_regions": regions,
                "uniform_scale": SCALE,
                "resampling": "Pillow nearest-neighbor; one uniform scale and fixed translation per animation, no per-frame trim",
                "fixed_cell_translation": [x_offset, vertical_offset],
                "source_alpha_preserved": True,
                "source_alpha_policy": "unchanged; intermediate values retained and flagged by validator",
            }

        atlas_name = f"maira_warrior_{animation}_candidate_v2.png"
        json_name = f"maira_warrior_{animation}_candidate_v2.json"
        atlas.save(OUTPUT / atlas_name, optimize=True)
        metadata = {
            "id": f"maira_warrior_{animation}_candidate_v2",
            "atlas": atlas_name,
            "status": "corrigir",
            "approved": False,
            "cell": list(CELL),
            "pivot": list(PIVOT),
            "directions": DIRECTIONS,
            "frames": count,
            "fps": FPS[animation],
            "loop": True,
            "animation": animation,
            "animations": {animation: {"frames": count, "fps": FPS[animation], "loop": True}},
            "source_tool": "OpenAI image_gen for new directions; prior Maíra stage-1 atlas for N/S",
            "source_reference": "assets/references/generated-candidates/maira_vocations_concept.png",
            "source_layout": "new direction source strips are single horizontal rows; fixed equal regions split by declared frame count",
            "source_directions": source_info,
            "notes": [
                "Candidate atlas only. Concept reference was used for identity; no concept pixels were cropped.",
                "Existing N/S rows are preserved from candidate v1 and retain its documented defects.",
                "New source images contain intermediate alpha and visible edge halos; alpha was preserved without masking or binarization.",
                "All new frames were uniformly downscaled with nearest-neighbor to fit candidate cells; reduced source detail may be lost.",
                "Generated walk strips have alpha silhouettes touching some source partition edges; inspect for source-level frame bleed or clipping.",
                "Direction, sword-hand anatomy, foot contacts, walk loop, idle-to-walk continuity, Godot, SQM/zoom, and Android remain subject to review.",
                "Pivot placement uses a median alpha-bottom proxy per animation; it does not identify the character's feet.",
            ],
            "source_transform": {
                "uniform_scale": SCALE,
                "resampling": "nearest-neighbor",
                "automatic_trim": False,
                "alpha_modified": False,
                "generated_animation_vertical_translation": vertical_offset,
            },
        }
        (OUTPUT / json_name).write_text(
            json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        all_atlases[animation] = atlas

    build_contact(all_atlases)
    build_alpha_check(all_atlases)
    print("Packed candidate v2 (directions N, NE, E, SE, S, SW, W, NW):")
    for animation in FRAMES:
        path = OUTPUT / f"maira_warrior_{animation}_candidate_v2.png"
        with Image.open(path) as image:
            alpha_values = set(image.getchannel("A").tobytes())
            print(f"{animation}: {image.size}, {image.mode}, alpha_values={len(alpha_values)}, intermediate={len(alpha_values - {0, 255})}")
    print(f"contact: {EVIDENCE / 'maira_warrior_8dir_contact.png'}")


if __name__ == "__main__":
    main()
