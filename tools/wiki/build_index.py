#!/usr/bin/env python3
"""Build the offline wiki's catalog and repository file index from source data."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
WIKI = ROOT / "docs" / "wiki"
OUTPUT = WIKI / "catalog-data.json"
SKIP_DIRS = {".git", ".godot", "build", "node_modules", "__pycache__"}
SKIP_SUFFIXES = {".import", ".uid", ".pyc"}
PREVIEW_ROOTS = ("assets/characters/", "assets/creatures/", "assets/environments/", "assets/ui/")


def read_json(path: str) -> Any:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def png_dimensions(path: Path) -> list[int] | None:
    try:
        header = path.read_bytes()[:24]
    except OSError:
        return None
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return [int.from_bytes(header[16:20], "big"), int.from_bytes(header[20:24], "big")]


def file_rows() -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(ROOT).as_posix()
        if relative == "docs/wiki/catalog-data.json":
            continue
        parts = Path(relative).parts
        if any(part in SKIP_DIRS or part.startswith(".") for part in parts):
            continue
        if path.suffix.lower() in SKIP_SUFFIXES:
            continue
        rows.append(
            {
                "path": relative,
                "href": f"../../{relative}",
                "extension": path.suffix.lower().lstrip(".") or "file",
                "size": path.stat().st_size,
            }
        )
    return rows


def asset_rows() -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for path in sorted((ROOT / "assets").rglob("*.png")):
        relative = path.relative_to(ROOT).as_posix()
        if not relative.startswith(PREVIEW_ROOTS):
            continue
        metadata_path = path.with_suffix(".json")
        metadata: dict[str, Any] = {}
        if metadata_path.is_file():
            try:
                loaded = json.loads(metadata_path.read_text(encoding="utf-8"))
                if isinstance(loaded, dict):
                    metadata = loaded
            except (OSError, json.JSONDecodeError):
                metadata = {}

        parts = Path(relative).parts
        group = parts[1] if len(parts) > 1 else "assets"
        if group == "characters":
            subgroup = parts[2].title() if len(parts) > 2 else "Personagens"
        elif group == "creatures":
            subgroup = parts[2].title() if len(parts) > 2 else "Criaturas"
        elif group == "environments":
            subgroup = "Terreno"
        elif group == "ui":
            subgroup = "Interface"
        else:
            subgroup = group.title()

        status = metadata.get("status")
        if not status and metadata.get("approved") is True:
            status = "approved"
        elif not status and metadata.get("approved") is False:
            status = "not_approved"

        rows.append(
            {
                "path": relative,
                "href": f"../../{relative}",
                "name": path.name,
                "group": group,
                "subgroup": subgroup,
                "dimensions": png_dimensions(path),
                "status": status,
                "approved": metadata.get("approved"),
                "cell": metadata.get("cell"),
                "pivot": metadata.get("pivot"),
                "frames": metadata.get("frames"),
                "directions": len(metadata.get("directions", [])) or None,
            }
        )
    return rows


def documentation_rows() -> list[dict[str, str]]:
    docs = [
        ("README.md", "Visão geral do projeto, estado atual e como testar."),
        ("Docs/Main/GDD_MVP.md", "Escopo, regras, progressão, combate e critérios de aceite."),
        ("Docs/Main/CONTENT_DATA.md", "Conversões de atributos, itens, drops, XP e árvore planejada."),
        ("Docs/Main/CATALOGS_MVP.md", "As doze listas de produção e seus limites conhecidos."),
        ("Docs/Main/ROADMAP.md", "Sprints, gates e estado dos aceites."),
        ("docs/technical/ARCHITECTURE.md", "Arquitetura pretendida para mundo, saves e rede."),
        ("docs/art/ART_DIRECTION_AND_SPRITES.md", "Contrato candidato de sprites, pivôs, atlas e escala."),
        ("Docs/Context/HANDOFF.md", "Próxima ação e estado de continuidade."),
        ("Docs/Context/JOURNAL.md", "Histórico curto de mudanças e validações."),
        ("Docs/Context/DECISIONS.md", "Decisões que afetam o escopo e a implementação."),
        ("data/catalogs/mvp.json", "Fonte numérica planejada; contém valores ainda provisórios."),
        ("game/data/first_island_layout.json", "Layout estático do recorte jogável atual."),
        ("game/data/player_appearances.json", "Seleção de atlas de aparência usada pelo recorte solo."),
        ("assets/ui/pixel_hud_v1/regions.json", "Regiões da prancha de HUD escolhida; aceite Android pendente."),
    ]
    return [{"path": path, "href": f"../../{path}", "summary": summary} for path, summary in docs]


def main() -> None:
    WIKI.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_from": [
            "data/catalogs/mvp.json",
            "game/data/first_island_layout.json",
            "game/data/player_appearances.json",
            "assets/**/*.png and adjacent metadata JSON",
        ],
        "catalog": read_json("data/catalogs/mvp.json"),
        "layout": read_json("game/data/first_island_layout.json"),
        "appearances": read_json("game/data/player_appearances.json"),
        "assets": asset_rows(),
        "files": file_rows(),
        "documentation": documentation_rows(),
    }
    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Gerado {OUTPUT.relative_to(ROOT)}: {len(payload['assets'])} prévias, {len(payload['files'])} arquivos")


if __name__ == "__main__":
    main()
