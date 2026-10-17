#!/usr/bin/env python3
"""Pack the generated fox source into one fixed candidate cell without retouching alpha."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/references/generated-candidates/fox/fox_se_source_imagegen_v2.png"
ATLAS_DIR = ROOT / "assets/creatures/fox"
EVIDENCE_DIR = ROOT / "docs/art/evidence/fox"
ATLAS_PATH = ATLAS_DIR / "fox_se_candidate_v1.png"
META_PATH = ATLAS_DIR / "fox_se_candidate_v1.json"
PREVIEW_PATH = EVIDENCE_DIR / "fox_se_candidate_v1_nearest_8x.png"

CELL = (96, 96)


def alpha_summary(image: Image.Image) -> dict[str, int | list[int] | list[int | None]]:
    alpha = image.getchannel("A")
    samples = alpha.tobytes()
    values = set(samples)
    return {
        "distinct_values": len(values),
        "intermediate_values": len(values - {0, 255}),
        "intermediate_pixels": sum(1 for value in samples if value not in (0, 255)),
        "bbox": list(alpha.getbbox()) if alpha.getbbox() else [None, None, None, None],
    }


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"Missing generated source: {SOURCE}")

    source = Image.open(SOURCE)
    if source.mode != "RGBA":
        raise SystemExit(f"Source must remain RGBA; got {source.mode}")
    if source.width != source.height:
        raise SystemExit(f"Source canvas must be square for whole-canvas packing; got {source.size}")

    source_alpha = alpha_summary(source)
    atlas = source.resize(CELL, Image.Resampling.NEAREST)
    atlas.save(ATLAS_PATH, format="PNG")
    output_alpha = alpha_summary(atlas)

    # This preview changes only display scale. Its alpha is preserved exactly from the atlas.
    atlas.resize((CELL[0] * 8, CELL[1] * 8), Image.Resampling.NEAREST).save(PREVIEW_PATH, format="PNG")

    source_rel = "../../references/generated-candidates/fox/fox_se_source_imagegen_v2.png"
    has_intermediate_alpha = bool(source_alpha["intermediate_values"] or output_alpha["intermediate_values"])
    status = "corrigir" if has_intermediate_alpha else "candidate"
    metadata = {
        "id": "fox",
        "species": "fox",
        "atlas": {"file": ATLAS_PATH.name, "columns": 1, "rows": 1},
        "cell": list(CELL),
        "pivot": [48, 80],
        "directions": ["SE"],
        "animations": {"idle": {"frames": 1, "fps": 1, "loop": True}},
        "approved": False,
        "status": status,
        "candidate_stage": "single_static_pose",
        "source": {
            "file": source_rel,
            "native_size": list(source.size),
            "alpha": source_alpha,
            "generation": "built-in image_gen; source retained unchanged",
        },
        "packing": {
            "operation": f"whole square canvas scaled {source.width}x{source.height} to 96x96 using nearest neighbor",
            "alpha_operation": "none; alpha samples were preserved by nearest-neighbor resampling",
            "crop": "none",
            "trim": "none",
            "manual_pixel_edits": "none",
            "nearest_preview": "../../../docs/art/evidence/fox/fox_se_candidate_v1_nearest_8x.png",
        },
        "validation": {
            "output_alpha": output_alpha,
            "status_reason": "source or atlas contains intermediate alpha; visual art approval remains pending"
            if has_intermediate_alpha
            else "structure only; visual art and platform approval remain pending",
        },
    }
    META_PATH.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"atlas": str(ATLAS_PATH.relative_to(ROOT)), "metadata": str(META_PATH.relative_to(ROOT)),
                      "preview": str(PREVIEW_PATH.relative_to(ROOT)), "source_alpha": source_alpha,
                      "output_alpha": output_alpha, "status": status, "approved": False}, indent=2))


if __name__ == "__main__":
    main()
