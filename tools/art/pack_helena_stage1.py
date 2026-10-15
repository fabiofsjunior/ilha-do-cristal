#!/usr/bin/env python3
"""Pack Helena's generated Warrior stage-1 candidate without alpha cleanup.

Only fixed square source cells are sampled uniformly with nearest-neighbor
resampling, then placed on 96x96 transparent cells using one fixed offset per
animation/direction. This preserves the generated sources and records defects;
it does not approve the art or claim engine/mobile validation.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "assets/references/generated-candidates"
OUTPUT = ROOT / "assets/characters/helena/warrior"
EVIDENCE = ROOT / "docs/art/evidence/helena"
CELL = (96, 96)
CONTENT = (72, 72)
PIVOT = (48, 80)
DIRECTIONS = ("N", "S")
SOURCES_BY_STATE = {
    "idle": {
        "N": "helena_warrior_idle_source_v1.png",
        "S": "helena_warrior_idle_source_v1.png",
    },
    "walk": {
        "N": "helena_warrior_walk_n_source_v1.png",
        "S": "helena_warrior_walk_s_source_v1.png",
    },
}
FRAMES = {"idle": 4, "walk": 6}
FPS = {"idle": 6, "walk": 10}
# The idle source has a 4x2 layout with a half-pixel row height at its original
# dimensions. One uniform whole-sheet nearest resample makes eight exact 443px
# square cells while preserving the source file separately and unchanged.
IDLE_SOURCE_SIZE = (1774, 887)
IDLE_RESAMPLED_SIZE = (1772, 886)
IDLE_GRID = (4, 2)
WALK_SOURCE_SIZE = (1536, 1024)
WALK_GRID = (3, 2)
WALK_CELL = (512, 512)
# Same offset for every frame in a given animation/direction row. These are
# provisional anchors: alpha boxes do not prove foot contact or pivot accuracy.
OFFSETS = {
    "idle": {"N": (14, 9), "S": (14, 12)},
    "walk": {"N": (10, 15), "S": (13, 14)},
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def frame_diagnostics(frame: Image.Image) -> dict:
    raw = frame.getchannel("A").tobytes()
    values = set(raw)
    result = {
        "alpha_unique_values": len(values),
        "alpha_min": min(values),
        "alpha_max": max(values),
        "transparent_pixels": raw.count(0),
        "intermediate_alpha_pixels": len(raw) - raw.count(0) - raw.count(255),
        "opaque_255_pixels": raw.count(255),
    }
    for threshold in (1, 128, 240):
        mask = frame.getchannel("A").point(lambda value, t=threshold: 255 if value >= t else 0)
        box = mask.getbbox()
        result[f"bbox_alpha_gte_{threshold}"] = list(box) if box else None
    box = result["bbox_alpha_gte_128"]
    result["bbox_alpha_gte_128_bottom_minus_pivot_y"] = box[3] - PIVOT[1] if box else None
    return result


def alpha_summary(image: Image.Image) -> dict:
    raw = image.getchannel("A").tobytes()
    values = set(raw)
    return {
        "unique_values": len(values),
        "min": min(values),
        "max": max(values),
        "transparent_pixels": raw.count(0),
        "intermediate_alpha_pixels": len(raw) - raw.count(0) - raw.count(255),
        "opaque_255_pixels": raw.count(255),
    }


def checkerboard(size: tuple[int, int]) -> Image.Image:
    image = Image.new("RGBA", size, (105, 105, 105, 255))
    draw = ImageDraw.Draw(image)
    square = 12
    for y in range(0, size[1], square):
        for x in range(0, size[0], square):
            if ((x // square) + (y // square)) % 2 == 0:
                draw.rectangle((x, y, min(x + square - 1, size[0] - 1), min(y + square - 1, size[1] - 1)), fill=(165, 165, 165, 255))
    return image


def build_contact(atlases: dict[str, Image.Image]) -> None:
    scale = 3
    shown = (CELL[0] * scale, CELL[1] * scale)
    label_w, title_h, gap = 120, 40, 14
    sheet = checkerboard((label_w + gap + 6 * shown[0] + gap, title_h + gap + 4 * shown[1] + 5 * gap))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
    except OSError:
        font = ImageFont.load_default()
    draw.text((gap, 9), "HELENA WARRIOR | STAGE 1 | CORRIGIR | SOURCE ALPHA PRESERVED | NEAREST 3x", font=font, fill=(15, 15, 15, 255))
    rows = (("idle N", "idle", 0), ("idle S", "idle", 1), ("walk N", "walk", 0), ("walk S", "walk", 1))
    for row_index, (label, state, output_row) in enumerate(rows):
        y = title_h + gap + row_index * (shown[1] + gap)
        draw.text((gap, y + 8), label, font=font, fill=(20, 20, 20, 255))
        count = FRAMES[state]
        atlas = atlases[state]
        for frame_index in range(6):
            x = label_w + gap + frame_index * shown[0]
            if frame_index < count:
                frame = atlas.crop((frame_index * CELL[0], output_row * CELL[1], (frame_index + 1) * CELL[0], (output_row + 1) * CELL[1]))
                sheet.alpha_composite(frame.resize(shown, Image.Resampling.NEAREST), dest=(x, y))
            else:
                draw.rectangle((x, y, x + shown[0] - 1, y + shown[1] - 1), outline=(60, 60, 60, 255), width=1)
    sheet.save(EVIDENCE / "helena_warrior_stage1_contact.png", optimize=True)


def source_for(state: str, direction: str) -> tuple[Image.Image, dict]:
    path = SOURCES / SOURCES_BY_STATE[state][direction]
    image = Image.open(path).convert("RGBA")
    details = {"path": str(path.relative_to(ROOT)), "sha256": sha256(path), "dimensions": list(image.size)}
    if state == "idle":
        if image.size != IDLE_SOURCE_SIZE:
            raise ValueError(f"Expected idle source {IDLE_SOURCE_SIZE}, received {image.size}")
        image = image.resize(IDLE_RESAMPLED_SIZE, Image.Resampling.NEAREST)
        grid, source_cell = IDLE_GRID, (443, 443)
        source_row = 0 if direction == "N" else 1
        details.update({
            "grid": {"columns": 4, "rows": 2, "source_cell": [443, 443]},
            "source_row": source_row,
            "global_resample": {"from": list(IDLE_SOURCE_SIZE), "to": list(IDLE_RESAMPLED_SIZE), "uniform_scale": f"{IDLE_RESAMPLED_SIZE[0]}/{IDLE_SOURCE_SIZE[0]} = {IDLE_RESAMPLED_SIZE[1]}/{IDLE_SOURCE_SIZE[1]}"},
        })
    else:
        if image.size != WALK_SOURCE_SIZE:
            raise ValueError(f"Expected walk source {WALK_SOURCE_SIZE}, received {image.size}")
        grid, source_cell = WALK_GRID, WALK_CELL
        details.update({
            "grid": {"columns": 3, "rows": 2, "source_cell": list(WALK_CELL)},
            "frame_read_order": "row-major: top row frames 0-2, bottom row frames 3-5",
        })
    details["alpha_summary"] = alpha_summary(Image.open(path).convert("RGBA"))
    details["source_grid_region_policy"] = "fixed cells; no per-frame crop or source retouch"
    return image, {**details, "source_cell": list(source_cell), "grid": list(grid)}


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    concept_path = ROOT / "assets/references/concept-rpg-classico.png"
    atlas_by_state: dict[str, Image.Image] = {}
    all_metadata = {}

    for state, count in FRAMES.items():
        atlas = Image.new("RGBA", (CELL[0] * count, CELL[1] * len(DIRECTIONS)), (0, 0, 0, 0))
        direction_records = {}
        for row_index, direction in enumerate(DIRECTIONS):
            source_image, source_meta = source_for(state, direction)
            source_cell_w, source_cell_h = source_meta["source_cell"]
            if state == "idle":
                grid_cols, grid_rows = 4, 2
                source_row = source_meta["source_row"]
                # The original idle source becomes exact 4x2 square cells only
                # after a single uniform whole-sheet resample.
                x_scale = source_image.width / IDLE_SOURCE_SIZE[0]
                y_scale = source_image.height / IDLE_SOURCE_SIZE[1]
                for_frame_source = lambda frame_index: (
                    frame_index * source_cell_w, source_row * source_cell_h,
                    (frame_index + 1) * source_cell_w, (source_row + 1) * source_cell_h,
                )
                source_meta["frame_regions_after_global_resample"] = [[
                    frame_index * source_cell_w, source_row * source_cell_h,
                    (frame_index + 1) * source_cell_w, (source_row + 1) * source_cell_h,
                ] for frame_index in range(count)]
            else:
                grid_cols, grid_rows = WALK_GRID
                for_frame_source = lambda frame_index: (
                    (frame_index % grid_cols) * source_cell_w,
                    (frame_index // grid_cols) * source_cell_h,
                    (frame_index % grid_cols + 1) * source_cell_w,
                    (frame_index // grid_cols + 1) * source_cell_h,
                )
                source_meta["frame_regions"] = [list(for_frame_source(frame_index)) for frame_index in range(count)]

            frames = []
            for frame_index in range(count):
                region = for_frame_source(frame_index)
                source_frame = source_image.crop(region)
                scaled = source_frame.resize(CONTENT, Image.Resampling.NEAREST)
                offset = OFFSETS[state][direction]
                frame = Image.new("RGBA", CELL, (0, 0, 0, 0))
                frame.alpha_composite(scaled, dest=offset)
                atlas.alpha_composite(frame, dest=(frame_index * CELL[0], row_index * CELL[1]))
                diag = frame_diagnostics(frame)
                frames.append({
                    "index": frame_index,
                    "source_region": list(region),
                    "uniform_scale": f"{CONTENT[0]}/{source_cell_w} = {CONTENT[1]}/{source_cell_h}",
                    "fixed_offset_for_animation_direction": list(offset),
                    "output_region": [frame_index * CELL[0], row_index * CELL[1], (frame_index + 1) * CELL[0], (row_index + 1) * CELL[1]],
                    "diagnostics": diag,
                })
            direction_records[direction] = {"source": source_meta, "frames": frames}

        atlas_name = f"helena_warrior_{state}_candidate_v1.png"
        json_name = f"helena_warrior_{state}_candidate_v1.json"
        atlas.save(OUTPUT / atlas_name, optimize=True)
        metadata = {
            "id": f"helena_warrior_{state}_candidate_v1",
            "atlas": atlas_name,
            "status": "corrigir",
            "approved": False,
            "character": "Helena",
            "vocation": "Warrior",
            "assumption": "Warrior é apenas a vocação candidata inicial porque Helena não tem default explícito e o escopo pedido limita o exemplar inicial a uma vocação.",
            "cell": list(CELL),
            "pivot": list(PIVOT),
            "directions": list(DIRECTIONS),
            "frames": count,
            "fps": FPS[state],
            "loop": True,
            "animations": {state: {"frames": count, "fps": FPS[state], "loop": True}},
            "source_tool": "OpenAI image_gen built-in",
            "concept_reference": {
                "path": "assets/references/concept-rpg-classico.png",
                "git_blob_sha": "82a60ab282c23d0e6846a10a2d8b5e8614537ac3",
                "identity_description": "Helena: cabelo castanho ondulado, tiara clara, olhos castanhos, roupa/acento creme-rosa; para Warrior, mantém espada conforme direção de arte.",
                "use": "Referência visual; não foi cortada nem usada como quadros de animação.",
            },
            "source_directions": direction_records,
            "content_cell": list(CONTENT),
            "resampling": "nearest-neighbor uniforme por célula quadrada, sem aparar; uma âncora fixa compartilhada por toda a linha da mesma animação/direção",
            "alpha_policy": "Canal alpha amostrado e preservado; sem binarização, desfoque, matte removal, flood fill ou retouch.",
            "godot_validation": "pendente",
            "android_validation": "pendente",
            "notes": [
                "Escopo inicial apenas: Helena Warrior, N/S, idle 4 frames e walk 6 frames. Sem Archer, Mage, direções adicionais ou outros estados.",
                "96x96 e pivô (48,80) são os parâmetros candidatos da etapa técnica atual; permanecem sujeitos à revisão visual e validação no motor/aparelho.",
                "A fonte idle original 1774x887 tem linhas de 443.5 px; foi preservada intacta e um redimensionamento uniforme do quadro completo para 1772x886 criou uma grade 4x2 exata de células 443x443.",
                "Os gerados walk N/S têm fundo de brilho/halo de alpha baixo; a tentativa de correção por geração não o removeu, por isso o canal original foi mantido.",
                "As fontes de walk apresentam deriva de posicionamento entre quadros, e os limites de alpha variam em relação ao pivô candidato; âncoras fixas não corrigem essa falha. Revisar/refazer movimento antes de aprovação.",
                "Alpha intermediário e acabamento suavizado contrariam a direção de arte pixel nítida. Estrutura validada não equivale a arte aprovada.",
                "Nenhum teste de Godot, zoom/SQM ou Android foi executado nesta etapa.",
            ],
        }
        (OUTPUT / json_name).write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        atlas_by_state[state] = atlas
        all_metadata[state] = metadata

    build_contact(atlas_by_state)
    summary = {
        "concept_reference_sha256": sha256(concept_path),
        "atlases": {state: {"file": f"helena_warrior_{state}_candidate_v1.png", "dimensions": list(atlas.size), "alpha": alpha_summary(atlas)} for state, atlas in atlas_by_state.items()},
        "contact": "docs/art/evidence/helena/helena_warrior_stage1_contact.png",
        "source_hashes": {path.name: sha256(path) for path in sorted(SOURCES.glob("helena_warrior_*_source_v1.png"))},
    }
    (EVIDENCE / "helena_warrior_stage1_structure.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
