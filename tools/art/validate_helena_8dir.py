#!/usr/bin/env python3
"""Check Helena 8-direction candidate packaging; visual approval stays manual."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "assets/characters/helena/warrior"
SOURCES = ROOT / "assets/references/generated-candidates"
EVIDENCE = ROOT / "docs/art/evidence/helena"
CELL = (96, 96)
PIVOT = (48, 80)
DIRECTIONS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
FRAMES = {"idle": 4, "walk": 6}
EXPECTED_SIZES = {"idle": (384, 768), "walk": (576, 768)}
CONCEPT_BLOB = "82a60ab282c23d0e6846a10a2d8b5e8614537ac3"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_blob_sha(path: Path) -> str:
    raw = path.read_bytes()
    return hashlib.sha1(f"blob {len(raw)}\0".encode() + raw).hexdigest()


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def frame_image(atlas: Image.Image, state: str, row: int, frame: int) -> Image.Image:
    x = frame * CELL[0]
    y = row * CELL[1]
    return atlas.crop((x, y, x + CELL[0], y + CELL[1]))


def frame_stats(frame: Image.Image) -> dict:
    alpha = frame.getchannel("A")
    mask = alpha.point(lambda value: 255 if value >= 128 else 0)
    bbox = mask.getbbox()
    raw = alpha.tobytes()
    return {
        "bbox_alpha_gte_128": list(bbox) if bbox else None,
        "alpha_min": min(raw),
        "alpha_max": max(raw),
        "intermediate_alpha_pixels": sum(0 < value < 255 for value in raw),
        "opaque_pixels": raw.count(255),
        "bbox_bottom_minus_pivot_y": (bbox[3] - 1 - (PIVOT[1] - 1)) if bbox else None,
    }


def similarity_stats(frames: list[Image.Image]) -> dict:
    pairs = []
    for index, (left, right) in enumerate(zip(frames, frames[1:])):
        diff = ImageChops.difference(left, right)
        difference_bytes = diff.tobytes()
        changed = sum(
            1
            for offset in range(0, len(difference_bytes), 4)
            if any(difference_bytes[offset : offset + 4])
        )
        total_delta = sum(difference_bytes)
        pairs.append({
            "pair": [index, index + 1],
            "exact_duplicate": changed == 0,
            "changed_rgba_pixels": changed,
            "mean_absolute_channel_delta": round(total_delta / (CELL[0] * CELL[1] * 4), 4),
        })
    hashes = [hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames]
    return {
        "exact_unique_frame_count": len(set(hashes)),
        "frame_count": len(frames),
        "adjacent_differences": pairs,
    }


def main() -> None:
    concept = ROOT / "assets/references/concept-rpg-classico.png"
    if not concept.exists() or git_blob_sha(concept) != CONCEPT_BLOB:
        fail("official concept reference is missing or its Git blob changed")

    report = {
        "status": "corrigir",
        "structural_checks": [],
        "visual_diagnostics": {},
        "manual_visual_review": {
            "order": "Cardinal axes reviewed first (N/E/S/W), then NE/SE/SW/NW, using nearest-neighbor contact sheets at 2x and a 3x cardinal walk sheet.",
            "cardinal_axes": {
                "N": "Back-facing; legacy v1 row retained byte-for-byte.",
                "E": "Right-facing side profile; distinct from the other cardinal axes.",
                "S": "Front-facing; legacy v1 row retained byte-for-byte.",
                "W": "Left-facing side profile; distinct from E and not mirrored into E.",
            },
            "diagonal_views": "NE, SE, SW and NW read as separate diagonal quadrants in the contact sheet. Exact 45-degree camera consistency and gear silhouette still need art review.",
            "walk_pass_test": {
                "expected_sequence": ["left-foot contact", "descent", "passing", "right-foot contact", "descent", "passing"],
                "observed": "E and W show a recognizable six-frame alternating gait; N/S retain their prior alternating poses. Diagonal gait phases are less legible at this scale.",
                "result": "corrigir",
                "reason": "The pass is not accepted for all eight directions: diagonal foot baselines vary by up to 8 pixels relative to the candidate pivot, and the retained N/S rows still drift vertically. The expected phase order is therefore not consistently verifiable across the full cycle.",
            },
            "idle_test": "No exact duplicate frames were found. Most rows read as nearly static poses; any pixel changes may be texture/edge jitter rather than intentional breathing, so idle motion is not approved.",
            "alpha_test": "Intermediate alpha and soft halos remain across new sources; no automated alpha cleanup was applied. Pixel-art opacity check fails, so art status remains CORRIGIR.",
        },
        "limitations": [
            "Structural validation is not visual art approval.",
            "Godot import/render, zoom/SQM review, and Android remain pending.",
        ],
    }

    for state, frame_count in FRAMES.items():
        atlas_path = ASSETS / f"helena_warrior_{state}_candidate_v2.png"
        metadata_path = ASSETS / f"helena_warrior_{state}_candidate_v2.json"
        if not atlas_path.exists() or not metadata_path.exists():
            fail(f"missing {state} atlas or JSON")
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        with Image.open(atlas_path) as opened:
            atlas = opened.convert("RGBA")
        if atlas.size != EXPECTED_SIZES[state]:
            fail(f"{state} atlas size {atlas.size}, expected {EXPECTED_SIZES[state]}")
        if metadata["cell"] != list(CELL) or metadata["pivot"] != list(PIVOT):
            fail(f"{state} cell/pivot metadata mismatch")
        if metadata["directions"] != DIRECTIONS:
            fail(f"{state} direction order mismatch")
        animation = metadata["animations"].get(state, {})
        if animation.get("frames") != frame_count or animation.get("loop") is not True:
            fail(f"{state} animation frame contract mismatch")
        if metadata["status"] != "corrigir" or metadata["approved"] is not False:
            fail(f"{state} must remain unapproved and marked corrigir")
        if metadata["validation"].get("godot") != "pendente" or metadata["validation"].get("android") != "pendente":
            fail(f"{state} overclaims engine/device validation")

        direction_diagnostics = {}
        output_frames_by_direction = {}
        for row, direction in enumerate(DIRECTIONS):
            records = metadata["source_directions"].get(direction)
            if records is None or len(records.get("frames", [])) != frame_count:
                fail(f"{state} {direction} source metadata frame count mismatch")
            source_path = ROOT / records["file"]
            if not source_path.exists():
                fail(f"{state} {direction} source file is missing: {records['file']}")
            if sha256(source_path) != records["sha256"]:
                fail(f"{state} {direction} source hash mismatch")

            frames = [frame_image(atlas, state, row, index) for index in range(frame_count)]
            output_frames_by_direction[direction] = frames
            frame_results = []
            for index, (frame, record) in enumerate(zip(frames, records["frames"])):
                expected_region = [index * CELL[0], row * CELL[1], (index + 1) * CELL[0], (row + 1) * CELL[1]]
                if record["output_region"] != expected_region:
                    fail(f"{state} {direction} frame {index} output region mismatch")
                diagnostics = frame_stats(frame)
                bbox = diagnostics["bbox_alpha_gte_128"]
                if not bbox:
                    fail(f"{state} {direction} frame {index} has no alpha>=128 pixels")
                if bbox[0] <= 0 or bbox[1] <= 0 or bbox[2] >= CELL[0] or bbox[3] >= CELL[1]:
                    fail(f"{state} {direction} frame {index} alpha>=128 touches cell edge")
                frame_results.append(diagnostics)

            if direction in ("N", "S"):
                source_row = 0 if direction == "N" else 1
                old_path = ASSETS / f"helena_warrior_{state}_candidate_v1.png"
                with Image.open(old_path) as old_opened:
                    old = old_opened.convert("RGBA")
                old_row = old.crop((0, source_row * CELL[1], old.width, (source_row + 1) * CELL[1]))
                new_row = atlas.crop((0, row * CELL[1], atlas.width, (row + 1) * CELL[1]))
                if old_row.tobytes() != new_row.tobytes():
                    fail(f"{state} {direction} legacy row is not pixel-exact")

            direction_diagnostics[direction] = {
                "frames": frame_results,
                "sequence_difference": similarity_stats(frames),
                "source_file": records["file"],
                "source_sha256": records["sha256"],
            }

        alpha_bytes = atlas.getchannel("A").tobytes()
        report["visual_diagnostics"][state] = {
            "atlas": str(atlas_path.relative_to(ROOT)),
            "dimensions": list(atlas.size),
            "directions": direction_diagnostics,
            "alpha": {
                "unique_values": len(set(alpha_bytes)),
                "transparent_pixels": alpha_bytes.count(0),
                "intermediate_alpha_pixels": sum(0 < value < 255 for value in alpha_bytes),
                "opaque_pixels": alpha_bytes.count(255),
            },
        }
        report["structural_checks"].append(
            f"PASS {state}: RGBA {atlas.width}x{atlas.height}; {frame_count} frames across N, NE, E, SE, S, SW, W, NW; cell 96x96; pivot (48,80); N/S rows match v1 pixel-for-pixel"
        )

    report["structural_checks"].append(f"PASS concept reference: Git blob {git_blob_sha(concept)} unchanged")
    report["structural_checks"].append("PASS every source hash and output frame region matches metadata; visible alpha stays inside each cell")
    report_path = EVIDENCE / "helena_warrior_8dir_validation.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    for line in report["structural_checks"]:
        print(line)
    for state in FRAMES:
        for direction in DIRECTIONS:
            diag = report["visual_diagnostics"][state]["directions"][direction]
            seq = diag["sequence_difference"]
            dupes = seq["frame_count"] - seq["exact_unique_frame_count"]
            frame_bottoms = [item["bbox_bottom_minus_pivot_y"] for item in diag["frames"]]
            print(
                f"WARN {state}/{direction}: exact_duplicate_frames={dupes}; "
                f"alpha_in_a_frame={sum(item['intermediate_alpha_pixels'] for item in diag['frames'])}; "
                f"visible_bottom_minus_pivot={frame_bottoms}"
            )
    print(f"WARN visual art remains CORRIGIR; detailed measurements: {report_path.relative_to(ROOT)}")
    print("PENDING: Godot import/render, zoom/SQM review, and Android")


if __name__ == "__main__":
    main()
