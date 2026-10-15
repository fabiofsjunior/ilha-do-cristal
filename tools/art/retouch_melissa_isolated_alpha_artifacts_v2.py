#!/usr/bin/env python3
"""Remove two visually isolated alpha=1 pixels from one copied Melissa frame.

This is a narrow, reviewable retouch. It does not threshold or alter any other
alpha values, and it preserves the original candidate_v1 atlas and source.
"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
CHAR_DIR = ROOT / "assets/characters/melissa/warrior"
EVIDENCE_DIR = ROOT / "docs/art/evidence/melissa"
SOURCE = CHAR_DIR / "melissa_warrior_idle_8dir_candidate_v1.png"
SOURCE_JSON = CHAR_DIR / "melissa_warrior_idle_8dir_candidate_v1.json"
OUTPUT = CHAR_DIR / "melissa_warrior_idle_8dir_candidate_v2.png"
OUTPUT_JSON = CHAR_DIR / "melissa_warrior_idle_8dir_candidate_v2.json"
PREVIEW = EVIDENCE_DIR / "melissa_idle_n_frame1_pixel_retouch_v2.png"

# Idle frame 1 (second column), N direction (first row), cell-local positions.
# Nearest 8x inspection showed both alpha=1 pixels disconnected from the sprite:
# one above the head (49, 7) and one left of the hair (21, 33).
TARGETS = [(49, 7), (21, 33)]
CELL_SIZE = 96
FRAME_X = CELL_SIZE  # column 1
FRAME_Y = 0          # N row 0
SCALE = 8


def make_preview(before: Image.Image, after: Image.Image) -> None:
    """Show source/output on light and dark backgrounds at integer nearest 8x."""
    width = CELL_SIZE * SCALE
    header = 28
    gap = 18
    height = header + width + 34
    canvas = Image.new("RGB", (2 * width + gap, 2 * height + gap), (37, 43, 49))
    draw = ImageDraw.Draw(canvas)
    panels = [
        (before, (0, 0), "Before · light", (238, 231, 210)),
        (after, (width + gap, 0), "After · light", (238, 231, 210)),
        (before, (0, height + gap), "Before · dark", (35, 48, 60)),
        (after, (width + gap, height + gap), "After · dark", (35, 48, 60)),
    ]
    for frame, (x, y), label, background_color in panels:
        draw.text((x + 8, y + 7), label, fill=(245, 241, 226))
        enlarged = frame.resize((width, width), Image.Resampling.NEAREST)
        bg = Image.new("RGBA", enlarged.size, (*background_color, 255))
        bg.alpha_composite(enlarged)
        canvas.paste(bg.convert("RGB"), (x, y + header))
        if label.startswith("Before"):
            # Magenta outlines locate the two removed source pixels. Each box
            # covers exactly one source pixel at 8x; the atlas itself is untouched.
            marker = ImageDraw.Draw(canvas)
            for px, py in TARGETS:
                x0 = x + px * SCALE
                y0 = y + header + py * SCALE
                marker.rectangle((x0, y0, x0 + SCALE - 1, y0 + SCALE - 1),
                                 outline=(255, 0, 255), width=2)
    canvas.save(PREVIEW)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (384, 768):
        raise ValueError(f"Unexpected source dimensions: {source.size}")
    before_frame = source.crop((FRAME_X, FRAME_Y, FRAME_X + CELL_SIZE,
                                FRAME_Y + CELL_SIZE))

    atlas = source.copy()
    edits = []
    for x, y in TARGETS:
        pixel = atlas.getpixel((FRAME_X + x, FRAME_Y + y))
        if pixel[3] != 1:
            raise ValueError(f"Expected isolated alpha=1 at N/frame1 ({x},{y}), got {pixel}")
        neighbors = [
            atlas.getpixel((FRAME_X + nx, FRAME_Y + ny))[3]
            for ny in range(max(0, y - 1), min(CELL_SIZE, y + 2))
            for nx in range(max(0, x - 1), min(CELL_SIZE, x + 2))
            if (nx, ny) != (x, y)
        ]
        if any(neighbors):
            raise ValueError(f"Pixel N/idle/frame1 ({x},{y}) is not detached")
        atlas.putpixel((FRAME_X + x, FRAME_Y + y), (0, 0, 0, 0))
        edits.append({
            "direction": "N",
            "animation": "idle",
            "frame_index": 1,
            "cell_pixel": [x, y],
            "atlas_pixel": [FRAME_X + x, FRAME_Y + y],
            "before_rgba": list(pixel),
            "after_rgba": [0, 0, 0, 0],
            "reason": "single alpha=1 pixel visually detached from the character at nearest 8x",
        })
    atlas.save(OUTPUT)

    source_meta = json.loads(SOURCE_JSON.read_text(encoding="utf-8"))
    meta = dict(source_meta)
    meta.update({
        "id": "melissa_warrior_idle_8dir_candidate_v2",
        "atlas": OUTPUT.name,
        "stage": "isolated_manual_pixel_retouch_candidate",
        "approved": False,
    })
    meta["retouch_log"] = edits
    meta["notes"] = list(source_meta.get("notes", [])) + [
        "candidate_v2 preserves the full candidate_v1 atlas except for two individually verified, detached alpha=1 pixels in N/idle frame 1.",
        "No global alpha thresholding, rescaling, cropping, or frame/direction changes were applied.",
        "The source candidate_v1 PNG and generated direction sources remain unchanged.",
    ]
    OUTPUT_JSON.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")

    after_frame = atlas.crop((FRAME_X, FRAME_Y, FRAME_X + CELL_SIZE,
                              FRAME_Y + CELL_SIZE))
    make_preview(before_frame, after_frame)
    print(f"Created {OUTPUT.relative_to(ROOT)}")
    print(f"Created {OUTPUT_JSON.relative_to(ROOT)}")
    print(f"Created {PREVIEW.relative_to(ROOT)}")
    print(f"Edited only {len(edits)} pixels in N/idle frame 1")


if __name__ == "__main__":
    main()
