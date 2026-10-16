#!/usr/bin/env python3
"""Validate fox/wolf/bear candidate atlas structure; does not approve creature art."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SPECIES = ("fox", "wolf", "bear")
EXPECTED_LAYOUT = {
    "fox": {"cell": [96, 96], "pivot": [48, 80]},
    "wolf": {"cell": [96, 96], "pivot": [48, 80]},
    "bear": {"cell": [128, 128], "pivot": [64, 108]},
}
REQUIRED_DIRECTIONS = ("N", "NE", "E", "SE", "S", "SW", "W", "NW")
REQUIRED_ANIMATIONS = ("idle", "walk", "attack", "hit", "death")


def is_int_list(value: Any, length: int) -> bool:
    return (
        isinstance(value, list)
        and len(value) == length
        and all(type(item) is int for item in value)
    )


def inspect_candidate(root: Path, species: str) -> dict[str, Any]:
    base = root / "assets" / "creatures" / species
    json_path = base / f"{species}_se_candidate_v1.json"
    errors: list[str] = []
    alpha_pending: dict[str, Any] | None = None
    art_pending: list[str] = []
    result: dict[str, Any] = {
        "species": species,
        "metadata": str(json_path.relative_to(root)),
        "structural": "FAIL",
        "errors": errors,
        "alpha_pending": None,
        "art_pending": art_pending,
    }

    if not json_path.is_file():
        errors.append("candidate JSON missing")
        return result

    try:
        metadata = json.loads(json_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"cannot read JSON: {exc}")
        return result
    if not isinstance(metadata, dict):
        errors.append("candidate JSON must be an object")
        return result

    identifier = metadata.get("id")
    if not isinstance(identifier, str) or not (
        identifier == species or identifier.startswith(f"{species}_")
    ):
        errors.append(f"id must identify {species!r}, got {identifier!r}")
    if metadata.get("species") != species:
        errors.append(f"species must be {species!r}, got {metadata.get('species')!r}")

    expected = EXPECTED_LAYOUT[species]
    cell = metadata.get("cell")
    if not is_int_list(cell, 2) or any(value <= 0 for value in cell):
        errors.append(f"cell must be two positive integers, got {cell!r}")
    elif cell != expected["cell"]:
        errors.append(f"cell must be {expected['cell']!r}, got {cell!r}")

    pivot = metadata.get("pivot")
    if not is_int_list(pivot, 2):
        errors.append(f"pivot must be two integers, got {pivot!r}")
    else:
        if not is_int_list(cell, 2) or not (0 <= pivot[0] < cell[0] and 0 <= pivot[1] < cell[1]):
            errors.append(f"pivot {pivot!r} must lie inside cell {cell!r}")
        if pivot != expected["pivot"]:
            errors.append(f"pivot must be {expected['pivot']!r}, got {pivot!r}")

    directions = metadata.get("directions")
    if directions != ["SE"]:
        errors.append(f"candidate directions must be exactly ['SE'], got {directions!r}")
    art_pending.append("directions: missing " + ", ".join(
        direction for direction in REQUIRED_DIRECTIONS if not isinstance(directions, list) or direction not in directions
    ))

    animations = metadata.get("animations")
    idle = animations.get("idle") if isinstance(animations, dict) else None
    if (
        not isinstance(idle, dict)
        or type(idle.get("frames")) is not int
        or idle.get("frames") != 1
        or type(idle.get("fps")) is not int
        or idle.get("fps") != 1
        or idle.get("loop") is not True
    ):
        errors.append("candidate animation must declare idle frames=1, fps=1, loop=true")

    missing_animations = [name for name in REQUIRED_ANIMATIONS if not isinstance(animations, dict) or name not in animations]
    if missing_animations:
        art_pending.append("animations: missing " + ", ".join(missing_animations))
    if isinstance(idle, dict) and type(idle.get("frames")) is int and idle.get("frames") == 1:
        art_pending.append("idle: one static frame; no idle cycle")

    approved = metadata.get("approved")
    if approved is not False:
        errors.append(f"approved must be false, got {approved!r}")

    status = metadata.get("status")
    if not isinstance(status, str) or status not in {"corrigir", "candidate"}:
        errors.append(f"status must be 'corrigir' or 'candidate', got {status!r}")
    qa_status = metadata.get("qa_status")
    if qa_status is None:
        # Earlier fox/wolf candidate JSONs encode this same QA state in status.
        if status != "corrigir":
            errors.append("qa_status must be 'CORRIGIR' when status is not 'corrigir'")
    elif not isinstance(qa_status, str) or qa_status.strip().upper() != "CORRIGIR":
        errors.append(f"qa_status must be 'CORRIGIR', got {qa_status!r}")

    atlas = metadata.get("atlas")
    if not isinstance(atlas, dict):
        errors.append("atlas must contain file, columns and rows")
        atlas_file = None
        columns = rows = None
    else:
        atlas_file = atlas.get("file")
        columns = atlas.get("columns")
        rows = atlas.get("rows")
        if not isinstance(atlas_file, str) or not atlas_file:
            errors.append("atlas.file must be a non-empty relative path")
            atlas_file = None
        if type(columns) is not int or columns <= 0:
            errors.append(f"atlas.columns must be a positive integer, got {columns!r}")
        if type(rows) is not int or rows <= 0:
            errors.append(f"atlas.rows must be a positive integer, got {rows!r}")

    if atlas_file is not None:
        candidate_path = (json_path.parent / atlas_file).resolve()
        try:
            candidate_path.relative_to(root)
        except ValueError:
            errors.append("atlas.file resolves outside --root")
            candidate_path = None

        if candidate_path is not None and not candidate_path.is_file():
            errors.append(f"atlas PNG missing: {candidate_path.relative_to(root)}")
        elif candidate_path is not None:
            try:
                image = Image.open(candidate_path)
                image.load()
            except (OSError, ValueError) as exc:
                errors.append(f"cannot decode atlas PNG: {exc}")
                image = None

            if image is not None:
                result["atlas"] = str(candidate_path.relative_to(root))
                if image.mode != "RGBA":
                    errors.append(f"atlas must be RGBA, got {image.mode}")
                if is_int_list(cell, 2) and type(columns) is int and type(rows) is int:
                    expected_size = (cell[0] * columns, cell[1] * rows)
                    if image.size != expected_size:
                        errors.append(f"atlas dimensions must be {expected_size!r} from columns×cell, got {image.size!r}")

                if image.mode == "RGBA":
                    alpha = image.getchannel("A")
                    samples = alpha.tobytes()
                    values = set(samples)
                    if 0 not in values or not any(value > 0 for value in values):
                        errors.append("atlas must include transparent and visible pixels")
                    intermediate = values - {0, 255}
                    if intermediate:
                        alpha_pending = {
                            "distinct_intermediate_values": len(intermediate),
                            "intermediate_pixel_count": sum(value not in (0, 255) for value in samples),
                            "note": "alpha intermediário permanece pendente; não foi alterado",
                        }
                    if type(columns) is int and type(rows) is int and is_int_list(cell, 2):
                        for row in range(rows):
                            for column in range(columns):
                                bounds = (column * cell[0], row * cell[1], (column + 1) * cell[0], (row + 1) * cell[1])
                                frame_alpha = alpha.crop(bounds)
                                bbox = frame_alpha.getbbox()
                                if bbox is None:
                                    errors.append(f"empty cell at row={row}, column={column}")
                                elif bbox[0] == 0 or bbox[1] == 0 or bbox[2] == cell[0] or bbox[3] == cell[1]:
                                    errors.append(f"visible pixels touch cell edge at row={row}, column={column}: {bbox!r}")

    if alpha_pending:
        result["alpha_pending"] = alpha_pending
    result["metadata_state"] = {"id": identifier, "status": status, "qa_status": qa_status or ("CORRIGIR (from status)" if status == "corrigir" else None), "approved": approved}
    result["structural"] = "PASS" if not errors else "FAIL"
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT, help="project root (default: repository containing this script)")
    parser.add_argument("--strict-art", action="store_true", help="return 1 while alpha, direction, or animation work is pending")
    args = parser.parse_args()
    root = args.root.resolve()

    results = [inspect_candidate(root, species) for species in SPECIES]
    structural_errors = [
        {"species": item["species"], "error": error}
        for item in results
        for error in item["errors"]
    ]
    pending = [
        {"species": item["species"], "alpha": item["alpha_pending"], "art": item["art_pending"]}
        for item in results
        if item["alpha_pending"] or item["art_pending"]
    ]
    structure_ok = not structural_errors
    strict_ok = structure_ok and not pending
    report = {
        "root": str(root),
        "mode": "strict-art" if args.strict_art else "structural",
        "structural": "PASS" if structure_ok else "FAIL",
        "strict_art": "PASS" if strict_ok else "PENDING",
        "candidates": results,
        "pending_art": pending,
        "structural_errors": structural_errors,
        "note": "Structural PASS confirms candidate packaging only; it does not approve artwork or Android/Godot rendering.",
    }
    print(json.dumps(report, indent=2, ensure_ascii=False))

    if not structure_ok:
        return 1
    if args.strict_art and not strict_ok:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
