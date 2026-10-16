#!/usr/bin/env python3
"""Pack the selected generated bear source into its documented 128 px candidate cell.

This script performs only nearest-neighbor resampling and transparent placement.
It does not draw, recolor, crop, or alter alpha values intentionally.
"""
from pathlib import Path
import shutil
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/bear/bear_se_source_v2.png"
OUTPUT = ROOT / "assets/creatures/bear/bear_se_candidate_v1.png"
CELL = (128, 128)
FIT = (112, 112)
PIVOT = (64, 108)
EVIDENCE = ROOT / "docs/art/evidence/bear"


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    source_alpha = source.getchannel("A")
    resized = source.resize(FIT, resample=Image.Resampling.NEAREST)
    resized_alpha = resized.getchannel("A")
    bbox = resized_alpha.getbbox()
    if bbox is None:
        raise SystemExit(f"source has no visible pixels: {SOURCE}")
    x = (CELL[0] - FIT[0]) // 2
    y = PIVOT[1] - (bbox[3] - 1)
    if x < 0 or y < 0 or x + FIT[0] > CELL[0] or y + FIT[1] > CELL[1]:
        raise SystemExit(f"packed image exceeds cell: position={(x, y)}")
    atlas = Image.new("RGBA", CELL, (0, 0, 0, 0))
    # No mask: copy each sampled RGBA value, including any intermediate alpha.
    atlas.paste(resized, (x, y))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUTPUT)

    EVIDENCE.mkdir(parents=True, exist_ok=True)
    shutil.copy2(OUTPUT, EVIDENCE / "bear_se_candidate_v1_native.png")
    atlas.resize((CELL[0] * 4, CELL[1] * 4), resample=Image.Resampling.NEAREST).save(
        EVIDENCE / "bear_se_candidate_v1_nearest_4x.png"
    )

    alpha = atlas.getchannel("A")
    alpha_bytes = alpha.tobytes()
    intermediate = sum(1 for value in alpha_bytes if value not in (0, 255))
    print(f"source={SOURCE.relative_to(ROOT)} size={source.size} alpha_values={len(source_alpha.getcolors(maxcolors=10_000_000) or [])}")
    print(f"output={OUTPUT.relative_to(ROOT)} size={atlas.size} packed_at={(x, y)} bbox={alpha.getbbox()} pivot={PIVOT}")
    print(f"alpha_extrema={alpha.getextrema()} intermediate_alpha_pixels={intermediate}")
    print(f"evidence={EVIDENCE.relative_to(ROOT)} (native 128x128; nearest 4x 512x512)")


if __name__ == "__main__":
    main()
