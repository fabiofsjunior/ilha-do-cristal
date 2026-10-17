#!/usr/bin/env python3
"""Structural diagnostics for the one-pose fox candidate; never approves art."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
META_PATH = ROOT / "assets/creatures/fox/fox_se_candidate_v1.json"
errors: list[str] = []
warnings: list[str] = []

metadata = json.loads(META_PATH.read_text())
atlas_path = META_PATH.parent / metadata["atlas"]["file"]
if not atlas_path.is_file():
    errors.append(f"atlas missing: {atlas_path.relative_to(ROOT)}")
else:
    image = Image.open(atlas_path)
    if image.mode != "RGBA":
        errors.append(f"expected RGBA, got {image.mode}")
    if image.size != (96, 96):
        errors.append(f"expected one 96x96 cell, got {image.size}")
    alpha = image.getchannel("A")
    values = set(alpha.tobytes())
    if 0 not in values or not any(value > 0 for value in values):
        errors.append("atlas must contain both transparent and visible pixels")
    if values - {0, 255}:
        warnings.append(f"intermediate alpha values: {len(values - {0, 255})}; keep status CORRIGIR")
    bbox = alpha.getbbox()
    if bbox is None:
        errors.append("empty frame")
    elif bbox[0] == 0 or bbox[1] == 0 or bbox[2] == 96 or bbox[3] == 96:
        errors.append(f"visible pixels touch cell boundary: {bbox}")

required = {
    "id": "fox",
    "species": "fox",
    "cell": [96, 96],
    "pivot": [48, 80],
    "directions": ["SE"],
    "animations": {"idle": {"frames": 1, "fps": 1, "loop": True}},
    "approved": False,
}
for key, expected in required.items():
    if metadata.get(key) != expected:
        errors.append(f"metadata {key!r} mismatch: expected {expected!r}, got {metadata.get(key)!r}")
if metadata.get("atlas") != {"file": "fox_se_candidate_v1.png", "columns": 1, "rows": 1}:
    errors.append("atlas metadata must describe exactly one column and row")

result = {
    "structural": "PASS" if not errors else "FAIL",
    "art_status": metadata.get("status"),
    "approved": metadata.get("approved"),
    "errors": errors,
    "warnings": warnings,
    "note": "Structural checks do not approve anatomy, direction, pixel quality, motion, Godot rendering, or Android legibility.",
}
print(json.dumps(result, indent=2, ensure_ascii=False))
raise SystemExit(bool(errors))
