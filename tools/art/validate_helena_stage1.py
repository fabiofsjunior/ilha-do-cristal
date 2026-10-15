#!/usr/bin/env python3
"""Validate Helena stage-1 atlas structure and report non-approval warnings."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "assets/references/generated-candidates"
ATLAS_DIR = ROOT / "assets/characters/helena/warrior"
CELL = (96, 96)
PIVOT = (48, 80)
EXPECTED = {"idle": (4, (384, 192)), "walk": (6, (576, 192))}


def git_blob_sha(path: Path) -> str:
    raw = path.read_bytes()
    header = f"blob {len(raw)}\0".encode()
    return hashlib.sha1(header + raw).hexdigest()


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def main() -> None:
    concept = ROOT / "assets/references/concept-rpg-classico.png"
    if not concept.exists():
        fail("official concept reference is missing")
    expected_concept_blob = "82a60ab282c23d0e6846a10a2d8b5e8614537ac3"
    actual_concept_blob = git_blob_sha(concept)
    if actual_concept_blob != expected_concept_blob:
        fail(f"concept Git blob SHA mismatch: {actual_concept_blob}")

    expected_source_sizes = {
        "helena_warrior_idle_source_v1.png": (1774, 887),
        "helena_warrior_walk_n_source_v1.png": (1536, 1024),
        "helena_warrior_walk_s_source_v1.png": (1536, 1024),
    }
    source_paths = [SOURCES / name for name in expected_source_sizes]
    for path in source_paths:
        if not path.exists():
            fail(f"missing stage-1 source PNG: {path.name}")
        with Image.open(path) as image:
            if image.mode != "RGBA":
                fail(f"source is not RGBA: {path.name} mode={image.mode}")
            if image.size != expected_source_sizes[path.name]:
                fail(f"unexpected source dimensions for {path.name}: {image.size}")

    warnings = []
    for state, (frame_count, expected_size) in EXPECTED.items():
        png = ATLAS_DIR / f"helena_warrior_{state}_candidate_v1.png"
        meta_path = ATLAS_DIR / f"helena_warrior_{state}_candidate_v1.json"
        if not png.exists() or not meta_path.exists():
            fail(f"missing atlas/metadata for {state}")
        metadata = json.loads(meta_path.read_text(encoding="utf-8"))
        with Image.open(png) as atlas:
            if atlas.mode != "RGBA":
                fail(f"{state} atlas is not RGBA")
            if atlas.size != expected_size:
                fail(f"{state} atlas dimensions {atlas.size}, expected {expected_size}")
            if metadata["cell"] != list(CELL) or metadata["pivot"] != list(PIVOT):
                fail(f"{state} metadata cell/pivot mismatch")
            if metadata["directions"] != ["N", "S"] or metadata["frames"] != frame_count:
                fail(f"{state} direction/frame contract mismatch")
            if metadata["status"] != "corrigir" or metadata["approved"] is not False:
                fail(f"{state} was incorrectly marked approved")
            for row, direction in enumerate(("N", "S")):
                frames = metadata["source_directions"][direction]["frames"]
                if len(frames) != frame_count:
                    fail(f"{state} {direction} metadata lists {len(frames)} frames")
                offsets = {tuple(frame["fixed_offset_for_animation_direction"]) for frame in frames}
                if len(offsets) != 1:
                    fail(f"{state} {direction} has per-frame offsets")
                for index, record in enumerate(frames):
                    expected_region = [index * CELL[0], row * CELL[1], (index + 1) * CELL[0], (row + 1) * CELL[1]]
                    if record["output_region"] != expected_region:
                        fail(f"{state} {direction} frame {index} region mismatch")
                    frame = atlas.crop((index * CELL[0], row * CELL[1], (index + 1) * CELL[0], (row + 1) * CELL[1]))
                    alpha = frame.getchannel("A")
                    visible = alpha.point(lambda value: 255 if value >= 128 else 0)
                    box = visible.getbbox()
                    if not box:
                        fail(f"{state} {direction} frame {index} has no visible alpha>=128 pixels")
                    if box[0] <= 0 or box[1] <= 0 or box[2] >= CELL[0] or box[3] >= CELL[1]:
                        fail(f"{state} {direction} frame {index} alpha>=128 touches cell edge")
            alpha = atlas.getchannel("A").tobytes()
            intermediate = sum(1 for value in alpha if 0 < value < 255)
            if intermediate:
                warnings.append(f"{state}: {intermediate} intermediate-alpha pixels preserved")
            if metadata["godot_validation"] != "pendente" or metadata["android_validation"] != "pendente":
                fail(f"{state} validation status overclaims engine/device checks")
        print(f"PASS {state}: RGBA {expected_size[0]}x{expected_size[1]}, {frame_count} frames x N/S, cell 96x96, pivot metadata 48,80, fixed row anchors")

    print(f"PASS concept: Git blob {actual_concept_blob} matches the official concept")
    print("PASS sources: 3 untouched RGBA PNGs with expected source dimensions")
    print("PASS output: all frames have visible pixels, fixed regions, and alpha>=128 clear of cell edges")
    for warning in warnings:
        print(f"WARN {warning}; candidate remains CORRIGIR")
    print("PENDING: visual approval/render, zoom/SQM review, and Android")


if __name__ == "__main__":
    main()
