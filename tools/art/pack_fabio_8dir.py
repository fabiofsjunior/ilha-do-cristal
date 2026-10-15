#!/usr/bin/env python3
"""Package the Fábio Warrior 8-direction candidate without masking source alpha.

The N/S cells are copied unchanged from the existing v2 candidate. New cells
are sliced from declared 6x4, 256 px source grids, uniformly reduced with
nearest-neighbor sampling, and placed with one fixed offset. This diagnostic
candidate is not approved for production.
"""

from __future__ import annotations

import hashlib
import json
from collections import Counter
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
CHARACTER = ROOT / "assets/characters/fabio/warrior"
SOURCES = ROOT / "assets/references/generated-candidates"
EVIDENCE = ROOT / "docs/art/evidence/fabio"

DIRECTIONS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
CELL = (96, 96)
PIVOT = (48, 80)  # candidate from the existing contract; not foot-validated
CONTENT = (72, 72)
SOURCE_CELL = (256, 256)
SOURCE_GRID = (6, 4)
FIXED_OFFSET = (10, 10)  # one shared placement for all newly generated rows
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}

SOURCE_FILES = {
    "cardinal": SOURCES / "fabio_warrior_8dir_cardinal_edited_v1.png",
    "NE_SE": SOURCES / "fabio_warrior_8dir_NE_SE_source_v1.png",
    "SW_NW": SOURCES / "fabio_warrior_8dir_SW_NW_source_v1.png",
}

# The directions below map to fixed source rows: each sheet is 6 columns by 4
# rows. Idle sheets use the first four columns; the last two are left empty.
NEW_ROW_SOURCE = {
    "E": {"sheet": "cardinal", "idle_row": 0, "walk_row": 1},
    "W": {"sheet": "cardinal", "idle_row": 2, "walk_row": 3},
    "NE": {"sheet": "NE_SE", "idle_row": 0, "walk_row": 1},
    "SE": {"sheet": "NE_SE", "idle_row": 2, "walk_row": 3},
    "SW": {"sheet": "SW_NW", "idle_row": 0, "walk_row": 1},
    "NW": {"sheet": "SW_NW", "idle_row": 2, "walk_row": 3},
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_summary(image: Image.Image) -> dict:
    values = Counter(image.getchannel("A").tobytes())
    intermediate = sum(count for value, count in values.items() if 0 < value < 255)
    return {
        "unique_values": len(values),
        "min": min(values),
        "max": max(values),
        "transparent_pixels": values[0],
        "intermediate_pixels": intermediate,
        "opaque_255_pixels": values[255],
    }


def alpha_bbox(image: Image.Image, threshold: int) -> list[int] | None:
    mask = image.getchannel("A").point(lambda a, t=threshold: 255 if a >= t else 0)
    bbox = mask.getbbox()
    return list(bbox) if bbox else None


def source_edge_counts(image: Image.Image, threshold: int = 128) -> dict:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda a, t=threshold: 255 if a >= t else 0)
    return {
        "left": sum(mask.getpixel((0, y)) > 0 for y in range(SOURCE_CELL[1])),
        "right": sum(mask.getpixel((SOURCE_CELL[0] - 1, y)) > 0 for y in range(SOURCE_CELL[1])),
        "top": sum(mask.getpixel((x, 0)) > 0 for x in range(SOURCE_CELL[0])),
        "bottom": sum(mask.getpixel((x, SOURCE_CELL[1] - 1)) > 0 for x in range(SOURCE_CELL[0])),
    }


def fixed_source_region(source_row: int, frame: int) -> tuple[int, int, int, int]:
    return (
        frame * SOURCE_CELL[0],
        source_row * SOURCE_CELL[1],
        (frame + 1) * SOURCE_CELL[0],
        (source_row + 1) * SOURCE_CELL[1],
    )


def write_contact_sheet(atlases: dict[str, Image.Image]) -> Path:
    scale = 2
    scaled_cell = (CELL[0] * scale, CELL[1] * scale)
    margin, gap, label_width, header = 18, 8, 88, 64
    content_width = 10 * scaled_cell[0] + gap * 11
    width = margin * 2 + label_width + content_width
    height = margin + header + 8 * (scaled_cell[1] + 28 + gap) + margin
    sheet = Image.new("RGBA", (width, height), (112, 112, 112, 255))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
        small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
    except OSError:
        font = ImageFont.load_default()
        small = ImageFont.load_default()
    body_top = margin + header
    checker = 24
    for y in range(body_top, height, checker):
        for x in range(0, width, checker):
            if ((x // checker) + (y // checker)) % 2 == 0:
                draw.rectangle((x, y, min(x + checker - 1, width - 1), min(y + checker - 1, height - 1)), fill=(166, 166, 166, 255))
    draw.rectangle((0, 0, width, body_top - 1), fill=(34, 38, 45, 255))
    draw.rectangle((0, body_top, margin + label_width - 1, height), fill=(54, 59, 65, 255))
    draw.text((margin, 10), "FABIO WARRIOR | 8 DIRECTIONS | CANDIDATE v3 | CORRIGIR", font=font, fill=(245, 231, 197, 255))
    x0 = margin + label_width
    draw.text((x0 + 8, 38), "IDLE (4 frames)", font=small, fill=(221, 221, 221, 255))
    draw.text((x0 + 4 * (scaled_cell[0] + gap) + 16, 38), "WALK (6 frames)", font=small, fill=(221, 221, 221, 255))

    idle = atlases["idle"]
    walk = atlases["walk"]
    for row, direction in enumerate(DIRECTIONS):
        y = margin + header + row * (scaled_cell[1] + 28 + gap)
        draw.text((margin, y + 8), direction, font=font, fill=(245, 231, 197, 255))
        for frame_index in range(FRAMES["idle"]):
            frame = idle.crop((frame_index * CELL[0], row * CELL[1], (frame_index + 1) * CELL[0], (row + 1) * CELL[1]))
            frame = frame.resize(scaled_cell, Image.Resampling.NEAREST)
            sheet.alpha_composite(frame, (x0 + frame_index * (scaled_cell[0] + gap), y + 24))
        walk_x = x0 + 4 * (scaled_cell[0] + gap) + 14
        for frame_index in range(FRAMES["walk"]):
            frame = walk.crop((frame_index * CELL[0], row * CELL[1], (frame_index + 1) * CELL[0], (row + 1) * CELL[1]))
            frame = frame.resize(scaled_cell, Image.Resampling.NEAREST)
            sheet.alpha_composite(frame, (walk_x + frame_index * (scaled_cell[0] + gap), y + 24))
        draw.line((x0 + 4 * (scaled_cell[0] + gap) + 3, y + 20, x0 + 4 * (scaled_cell[0] + gap) + 3, y + 20 + scaled_cell[1]), fill=(204, 166, 88, 255), width=2)

    out = EVIDENCE / "fabio_warrior_8dir_candidate_v3_contact.png"
    sheet.save(out, optimize=True)
    return out


def main() -> None:
    for name, path in SOURCE_FILES.items():
        if not path.is_file():
            raise FileNotFoundError(f"Missing {name} source: {path}")

    CHARACTER.mkdir(parents=True, exist_ok=True)
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    source_images = {name: Image.open(path).convert("RGBA") for name, path in SOURCE_FILES.items()}
    for name, image in source_images.items():
        expected = (SOURCE_CELL[0] * SOURCE_GRID[0], SOURCE_CELL[1] * SOURCE_GRID[1])
        if image.size != expected:
            raise ValueError(f"{name} grid must be {expected}; got {image.size}; no inferred slicing")

    old_meta: dict[str, dict] = {}
    old_images: dict[str, Image.Image] = {}
    old_source_desc: dict[str, dict] = {}
    for state in FRAMES:
        old_json = CHARACTER / f"fabio_warrior_{state}_candidate_v2.json"
        metadata = json.loads(old_json.read_text(encoding="utf-8"))
        old_png = CHARACTER / metadata["atlas"]
        old_meta[state] = metadata
        old_images[state] = Image.open(old_png).convert("RGBA")
        old_source_desc[state] = {
            "metadata": str(old_json.relative_to(ROOT)),
            "atlas": str(old_png.relative_to(ROOT)),
            "atlas_sha256": sha256(old_png),
            "metadata_sha256": sha256(old_json),
        }

    atlases: dict[str, Image.Image] = {}
    row_descriptions: dict[str, dict] = {state: {} for state in FRAMES}

    for state, frame_count in FRAMES.items():
        atlas = Image.new("RGBA", (CELL[0] * frame_count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
        previous_meta = old_meta[state]
        previous_direction_rows = {direction: index for index, direction in enumerate(previous_meta["directions"])}

        for output_row, direction in enumerate(DIRECTIONS):
            frame_records = []
            if direction in ("N", "S"):
                old_row = previous_direction_rows[direction]
                previous = old_images[state]
                for frame_index in range(frame_count):
                    region = (
                        frame_index * CELL[0], old_row * CELL[1],
                        (frame_index + 1) * CELL[0], (old_row + 1) * CELL[1],
                    )
                    frame = previous.crop(region)
                    atlas.alpha_composite(frame, (frame_index * CELL[0], output_row * CELL[1]))
                    frame_records.append({
                        "frame": frame_index,
                        "source_region_px": list(region),
                        "source_cell_px": list(CELL),
                        "source_alpha": alpha_summary(frame),
                        "output_alpha": alpha_summary(frame),
                        "output_bbox_alpha_gte_128": alpha_bbox(frame, 128),
                        "operation": "copied unchanged from existing v2 frame; no resampling, crop, flip, or alpha edit",
                    })
                row_descriptions[state][direction] = {
                    "source": old_source_desc[state],
                    "source_row": old_row,
                    "resampling": "none; pixels copied unchanged",
                    "fixed_offset": [0, 0],
                    "frames": frame_records,
                }
                continue

            mapping = NEW_ROW_SOURCE[direction]
            source_name = mapping["sheet"]
            source_path = SOURCE_FILES[source_name]
            source = source_images[source_name]
            source_row = mapping[f"{state}_row"]
            for frame_index in range(frame_count):
                region = fixed_source_region(source_row, frame_index)
                source_frame = source.crop(region)
                content = source_frame.resize(CONTENT, Image.Resampling.NEAREST)
                frame = Image.new("RGBA", CELL, (0, 0, 0, 0))
                frame.alpha_composite(content, FIXED_OFFSET)
                atlas.alpha_composite(frame, (frame_index * CELL[0], output_row * CELL[1]))
                frame_records.append({
                    "frame": frame_index,
                    "source_region_px": list(region),
                    "source_cell_px": list(SOURCE_CELL),
                    "source_alpha": alpha_summary(source_frame),
                    "source_bbox_alpha_gte_128": alpha_bbox(source_frame, 128),
                    "source_edge_pixels_alpha_gte_128": source_edge_counts(source_frame),
                    "output_alpha": alpha_summary(frame),
                    "output_bbox_alpha_gte_128": alpha_bbox(frame, 128),
                    "fixed_offset_px": list(FIXED_OFFSET),
                    "operation": "fixed cell region, uniform nearest 256x256 to 72x72, then fixed 10,10 placement in 96x96; no per-frame trim, flip, mask, or alpha threshold",
                })
            row_descriptions[state][direction] = {
                "source": str(source_path.relative_to(ROOT)),
                "source_sha256": sha256(source_path),
                "source_dimensions": list(source.size),
                "source_grid": {"columns": SOURCE_GRID[0], "rows": SOURCE_GRID[1], "cell": list(SOURCE_CELL), "regions_fixed": True},
                "source_row": source_row,
                "resampling": "nearest 256x256 to 72x72, uniform for every cell",
                "fixed_offset": list(FIXED_OFFSET),
                "frames": frame_records,
            }

        filename = f"fabio_warrior_{state}_candidate_v3_8dir.png"
        atlas.save(CHARACTER / filename, optimize=True)
        atlases[state] = atlas

        output_rows = []
        for row, direction in enumerate(DIRECTIONS):
            diagnostics = []
            for column in range(frame_count):
                frame = atlas.crop((column * CELL[0], row * CELL[1], (column + 1) * CELL[0], (row + 1) * CELL[1]))
                diagnostics.append({
                    "frame": column,
                    "alpha": alpha_summary(frame),
                    "bbox_alpha_gte_128": alpha_bbox(frame, 128),
                    "touches_output_cell_edge": any(alpha_bbox(frame, 1)[edge] == value for edge, value in ((0, 0), (1, 0), (2, CELL[0]), (3, CELL[1]))) if alpha_bbox(frame, 1) else False,
                })
            output_rows.append({"direction": direction, "frames": diagnostics})

        metadata_out = {
            "id": f"fabio_warrior_{state}_candidate_v3_8dir",
            "atlas": filename,
            "status": "corrigir",
            "approved": False,
            "candidate_version": "v3_8dir_direction_expansion",
            "cell": list(CELL),
            "pivot": list(PIVOT),
            "directions": DIRECTIONS,
            "frames": frame_count,
            "fps": FPS[state],
            "loop": True,
            "animation": state,
            "animations": {state: {"frames": frame_count, "fps": FPS[state], "loop": True}},
            "row_sources": row_descriptions[state],
            "art_review": {
                "overall": "corrigir",
                "reasons": [
                    "Pre-existing N/S v2 source retains soft/intermediate alpha and does not prove foot contact or walk-loop quality.",
                    "Generated E/W and diagonal source sheets retain alpha values 1-254, have no alpha-255 pixels, and show background glow/soft edges; no automatic alpha masking or binarization was applied.",
                    "Some diagonal source cells contain alpha>=128 pixels on cell boundaries. A cell-fit edit did not consistently eliminate this and changed the stated SW walk row from six poses to four; that edit is preserved but excluded from this atlas.",
                    "Generated walk poses are varied, but left/right contact, impact, passing sequence and support-leg alternation are not consistently unambiguous in static inspection.",
                    "96x96 cells and pivot (48,80) are candidates; alpha bboxes cannot identify boots or prove a stable pivot.",
                ],
                "per_direction": {
                    direction: {
                        "idle": "corrigir",
                        "walk": "corrigir",
                        "findings": (
                            ["Preserved existing v2 candidate; alpha soft; body/feet scale and cardinal anatomy still need visual review."]
                            if direction in ("N", "S") else
                            ["New generated candidate; alpha/glow remains; confirm scale and foot baseline in Godot."]
                            + (["Source sheet has material on one or both vertical cell edges; completeness is not confirmed."] if direction in ("NE", "SE", "SW", "NW") else [])
                        ),
                    }
                    for direction in DIRECTIONS
                },
                "walk_phase_order_requested": ["left-foot contact", "down/impact", "passing", "right-foot contact", "down/impact", "passing"],
                "walk_phase_result": "not confirmed; several directions have ambiguous support-leg alternation and require frame-by-frame correction",
            },
            "source_tool": "OpenAI image_gen built-in; source generations and correction attempts are preserved unchanged",
            "source_files": {
                name: {"path": str(path.relative_to(ROOT)), "sha256": sha256(path), "dimensions": list(source_images[name].size), "alpha": alpha_summary(source_images[name])}
                for name, path in SOURCE_FILES.items()
            },
            "source_alpha_policy": "Alpha preserved by nearest sampling; no binarization, thresholding, matte removal, or procedural masking. The selected source sheets still contain intermediate alpha and background contamination.",
            "godot_validation": "pendente",
            "android_validation": "pendente",
            "diagnostic_rows": output_rows,
            "notes": [
                "Candidate direction expansion only for Fábio Warrior idle/walk; no Archer, Mage, new states, skills, or gameplay changes.",
                "N/S frames are byte-preserved from v2; original source sheets and v1/v2 candidates remain unchanged.",
                "Generated source sheets use the declared fixed 6x4 grid. Source cells with boundary contamination are recorded instead of silently masked.",
                "The art review is CORRIGIR. Structural atlas validation cannot approve anatomy, motion, pivot, Godot rendering, or Android readability.",
            ],
        }
        json_path = CHARACTER / f"fabio_warrior_{state}_candidate_v3_8dir.json"
        json_path.write_text(json.dumps(metadata_out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    contact = write_contact_sheet(atlases)
    print(f"candidate contact: {contact.relative_to(ROOT)}")
    for state, atlas in atlases.items():
        print(f"{state}: {atlas.size} RGBA; directions={','.join(DIRECTIONS)}; {alpha_summary(atlas)}")
        for row, direction in enumerate(DIRECTIONS):
            image = atlas.crop((0, row * CELL[1], atlas.width, (row + 1) * CELL[1]))
            print(f"  {direction}: alpha>=128 bbox={alpha_bbox(image, 128)} alpha={alpha_summary(image)}")


if __name__ == "__main__":
    main()
