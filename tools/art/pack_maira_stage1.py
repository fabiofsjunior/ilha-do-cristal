#!/usr/bin/env python3
"""Pack generated Maíra Warrior N/S strips into fixed Godot cells.

This is deterministic asset packing only: it never draws, resizes, trims, or
reorders character pixels. It clears the border-connected magenta matte and
stray magenta matte-colored pixels left on the sprite contour, then places the
source frame in a 96x96 cell at one constant offset per direction. Alpha stays
binary; no antialiasing or resampling is introduced.
"""

from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/maira_warrior"
OUTPUT = ROOT / "assets/characters/maira/warrior"
EVIDENCE = ROOT / "docs/art/evidence/maira"
CELL = (96, 96)
PIVOT = (48, 80)
DIRECTIONS = ["N", "S"]
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}
# Fixed translations derived from the generated N/S source scale and foot line.
# No per-frame offset or resampling is performed.
OFFSETS = {"N": (15, 8), "S": (12, 2)}
SOURCE_JOB_IDS = {
    "still_s": "057666a9-3e32-4a3c-a2a6-a34c67f52e93",
    "still_n": "cfd331fd-29be-40ba-84bf-d80fe0291c8b",
    "idle_s": "3479b673-0521-4036-892a-caed8c52b86c",
    "walk_s": "8912b872-6d12-4ee1-9567-1e97f7783247",
    "idle_n": "a6a7df3d-15a7-426e-9bd8-4570e1efb375",
    "walk_n": "b47874cc-4b74-4ea0-ad90-e8067e7bb1d5",
}


def transparent_matte(frame: Image.Image) -> tuple[Image.Image, str]:
    """Remove connected near-matte and magenta fringe without soft alpha."""
    rgba = frame.convert("RGBA")
    rgb = rgba.convert("RGB")
    width, height = rgba.size
    matte = rgb.getpixel((0, 0))
    pixels = rgb.load()
    alpha = rgba.getchannel("A").copy()
    alpha_pixels = alpha.load()
    queue: deque[tuple[int, int]] = deque()
    seen: set[tuple[int, int]] = set()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in seen:
            continue
        seen.add((x, y))
        color = pixels[x, y]
        if max(abs(color[i] - matte[i]) for i in range(3)) > 24:
            continue
        alpha_pixels[x, y] = 0
        if x > 0:
            queue.append((x - 1, y))
        if x + 1 < width:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y + 1 < height:
            queue.append((x, y + 1))

    rgba.putalpha(alpha)
    # The generated matte also left isolated color-spill pixels disconnected
    # from the frame border. Maíra's approved gold/brown palette has no vivid
    # magenta, so clear only those spill colors and keep every other source
    # pixel unchanged. This is a binary transparency mask, not edge smoothing.
    for y in range(height):
        for x in range(width):
            r, g, b, a = rgba.getpixel((x, y))
            if a and r >= 120 and b >= 120 and g <= 100 and abs(r - b) <= 80:
                rgba.putpixel((x, y), (r, g, b, 0))
    return rgba, "#%02x%02x%02x" % matte


def read_strip(state: str, direction: str) -> tuple[Image.Image, list[dict]]:
    path = SOURCE / f"{state}_{direction.lower()}.png"
    image = Image.open(path).convert("RGBA")
    frame_count = FRAMES[state]
    if image.width % frame_count:
        raise ValueError(f"{path} width is not divisible into {frame_count} frames")
    frame_width = image.width // frame_count
    if frame_width + OFFSETS[direction][0] > CELL[0] or image.height + OFFSETS[direction][1] > CELL[1]:
        raise ValueError(f"{path} frame does not fit 96x96 at fixed offset {OFFSETS[direction]}")

    cells: list[Image.Image] = []
    regions: list[dict] = []
    for index in range(frame_count):
        region = (index * frame_width, 0, (index + 1) * frame_width, image.height)
        source_frame = image.crop(region)
        processed, matte = transparent_matte(source_frame)
        cell = Image.new("RGBA", CELL, (0, 0, 0, 0))
        cell.alpha_composite(processed, dest=OFFSETS[direction])
        cells.append(cell)
        regions.append({
            "frame": index,
            "source_region": list(region),
            "source_cell": [frame_width, image.height],
            "offset": list(OFFSETS[direction]),
            "matte_key": matte,
            "nontransparent_bbox": list(cell.getchannel("A").getbbox() or (0, 0, 0, 0)),
        })
    return image, cells, regions


def build_contact_sheet(atlases: dict[str, Image.Image]) -> None:
    """Create a nearest-neighbor review sheet; not a Godot render capture."""
    scale = 3
    gap = 8
    labels = ["idle N", "idle S", "walk N", "walk S"]
    images = [atlases[name] for name in ["idle", "idle", "walk", "walk"]]
    direction_rows = [0, 1, 0, 1]
    widths = [im.width // 96 for im in images]
    max_width = max(widths)
    row_h = 96 * scale
    label_width = 76
    sheet = Image.new("RGBA", (max_width * 96 * scale + gap * 2 + label_width, row_h * 4 + gap * 5), (0, 0, 0, 0))
    checker = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
    pix = checker.load()
    checker_px = 12
    for y in range(0, sheet.height, checker_px):
        for x in range(0, sheet.width, checker_px):
            tone = (90, 90, 90, 255) if ((x // checker_px) + (y // checker_px)) % 2 else (130, 130, 130, 255)
            for py in range(y, min(y + checker_px, sheet.height)):
                for px in range(x, min(x + checker_px, sheet.width)):
                    pix[px, py] = tone
    sheet = checker
    draw = ImageDraw.Draw(sheet)
    for row, (label, atlas, direction_row) in enumerate(zip(labels, images, direction_rows)):
        frames = atlas.width // 96
        y0 = gap + row * (row_h + gap)
        draw.text((8, y0 + 8), label, font=ImageFont.load_default(size=20), fill=(255, 245, 210, 255))
        for column in range(frames):
            cell = atlas.crop((column * 96, direction_row * 96, (column + 1) * 96, (direction_row + 1) * 96))
            cell = cell.resize((96 * scale, 96 * scale), Image.Resampling.NEAREST)
            sheet.alpha_composite(cell, dest=(label_width + gap + column * 96 * scale, y0))
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    sheet.save(EVIDENCE / "maira_warrior_stage1_contact.png")


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    atlases: dict[str, Image.Image] = {}

    for state, count in FRAMES.items():
        atlas = Image.new("RGBA", (CELL[0] * count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
        source_info: dict[str, dict] = {}
        for row, direction in enumerate(DIRECTIONS):
            raw_sheet, cells, regions = read_strip(state, direction)
            for column, cell in enumerate(cells):
                atlas.alpha_composite(cell, dest=(column * CELL[0], row * CELL[1]))
            source_info[direction] = {
                "source_strip": f"assets/references/generated-candidates/maira_warrior/{state}_{direction.lower()}.png",
                "source_dimensions": list(raw_sheet.size),
                "source_frame_regions": regions,
                "fixed_offset": list(OFFSETS[direction]),
                "pixel_engine_job": SOURCE_JOB_IDS[f"{state}_{direction.lower()}"] ,
            }

        atlas_name = f"maira_warrior_{state}_candidate_v1.png"
        json_name = f"maira_warrior_{state}_candidate_v1.json"
        atlas.save(OUTPUT / atlas_name, optimize=True)
        config = {
            "id": f"maira_warrior_{state}_candidate_v1",
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
            "source_tool": "Pixel Engine — pixel-engine-v1.1 + oai_gpt25_low",
            "source_reference": "assets/references/generated-candidates/maira_vocations_concept.png",
            "source_layout": "two source strips, one per direction; each is a single horizontal row",
            "source_directions": source_info,
            "resampling": "none; source pixels preserved, uniform cell padding only",
            "alpha_policy": "border-connected pixels within RGB distance 24 of the corner matte and vivid magenta spill pixels (r>=120, b>=120, g<=100, |r-b|<=80) were set to alpha 0; no fractional alpha or resampling",
            "notes": [
                "Prototype only: concept approval does not approve production animation.",
                "N and S source frames differ in dimensions/visual scale; fixed offsets preserve source pixels and do not scale frames.",
                "Walk leg alternation, cardinal direction, pivot, and idle-to-walk continuity require manual review in Godot.",
                "Godot import, zoom 50-125%, SQM and Android validation are pending.",
                "Visual review found idle motion subtle; walk bottom silhouette varies from y=80 to y=82, so foot contact/loop need frame-by-frame review.",
            ],
        }
        (OUTPUT / json_name).write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        atlases[state] = atlas

    build_contact_sheet(atlases)
    print("Packed Maíra Warrior N/S candidate atlases (no scaling/cropping):")
    for state in FRAMES:
        image = Image.open(OUTPUT / f"maira_warrior_{state}_candidate_v1.png")
        print(f"{state}: {image.size} RGBA -> {OUTPUT / f'maira_warrior_{state}_candidate_v1.png'}")
    print(f"contact: {EVIDENCE / 'maira_warrior_stage1_contact.png'}")


if __name__ == "__main__":
    main()
