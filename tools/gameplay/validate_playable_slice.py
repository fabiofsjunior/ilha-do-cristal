#!/usr/bin/env python3
"""Validate resource wiring and source metadata for the first playable slice."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
BASE_COMMIT = "16e759350ad9a3f76ded314e0050a820939b3a5f"
DIRECTIONS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def check_scenes() -> int:
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    require('run/main_scene="res://game/scenes/main.tscn"' in project,
            "project.godot deve iniciar a cena de gameplay")
    require((ROOT / "tools/art/sprite_test/sprite_test.tscn").is_file(),
            "o harness técnico original deve continuar disponível")
    scenes = sorted((ROOT / "game/scenes").glob("*.tscn"))
    require(len(scenes) >= 7, "faltam cenas do fluxo jogável")
    for scene in scenes:
        text = scene.read_text(encoding="utf-8")
        for resource_path in re.findall(r'path="res://([^"]+)"', text):
            require((ROOT / resource_path).is_file(),
                    f"recurso referenciado por {scene.relative_to(ROOT)} ausente: {resource_path}")
    scripts = sorted((ROOT / "game/scripts").rglob("*.gd"))
    require(len(scripts) >= 8, "faltam scripts de fluxo, jogador, HUD ou mapa")
    main_script = (ROOT / "game/scripts/core/main.gd").read_text(encoding="utf-8")
    for screen in ["START_SCENE", "CHARACTER_SCENE", "SESSION_SCENE", "GAME_SCENE", "PAUSE_SCENE"]:
        require(screen in main_script, f"router sem destino de tela: {screen}")
    player_script = (ROOT / "game/scripts/actors/player.gd").read_text(encoding="utf-8")
    for input_name in ["KEY_A", "KEY_D", "KEY_W", "KEY_S", "KEY_LEFT", "KEY_RIGHT", "KEY_UP", "KEY_DOWN"]:
        require(input_name in player_script, f"controle de teclado ausente: {input_name}")
    require('metadata.get("animations", {})' in player_script,
            "player deve suportar metadata nested de animações")
    joystick_script = (ROOT / "game/scripts/ui/virtual_joystick.gd").read_text(encoding="utf-8")
    require("InputEventScreenTouch" in joystick_script and "InputEventScreenDrag" in joystick_script,
            "joystick touch/drag não está conectado")
    pause_script = (ROOT / "game/scripts/ui/pause_overlay.gd").read_text(encoding="utf-8")
    hud_script = (ROOT / "game/scripts/world/first_island.gd").read_text(encoding="utf-8")
    require("overlay_layer.layer = 10" in pause_script and "_hud.layer = 1" in hud_script,
            "pause deve sombrear mapa e HUD em CanvasLayers ordenadas")
    for setting in ["window/handheld/orientation=0", "2d/snap/snap_2d_transforms_to_pixel=true"]:
        require(setting in project, f"configuração de viewport ausente: {setting}")
    return len(scenes) + len(scripts)


def animation_config(metadata: dict, expected: str) -> tuple[int, int, bool]:
    nested = metadata.get("animations", {})
    nested_data = nested.get(expected, {}) if isinstance(nested, dict) else {}
    frames = int(metadata.get("frames", nested_data.get("frames", 0)))
    fps = int(metadata.get("fps", nested_data.get("fps", 0)))
    loop = bool(metadata.get("loop", nested_data.get("loop", False)))
    return frames, fps, loop


def check_characters() -> int:
    appearances = load_json(ROOT / "game/data/player_appearances.json")
    require(len(appearances["characters"]) == 4, "selecao deve ter quatro aparencias existentes")
    require("corrigir" in appearances.get("note", ""), "a nota deve preservar o estado das artes")
    inspected = 0
    for character in appearances["characters"]:
        for state, expected_frames, expected_fps in [("idle", 4, 6), ("walk", 6, 10)]:
            metadata_path = ROOT / character[f"{state}_metadata"].removeprefix("res://")
            metadata = load_json(metadata_path)
            animation = metadata.get("animation", state)
            frames, fps, loop = animation_config(metadata, state)
            require(animation == state or state in metadata.get("animations", {}),
                    f"{character['id']} {state}: nome animação divergente")
            require(frames == expected_frames and fps == expected_fps and loop,
                    f"{character['id']} {state}: esperado {expected_frames} frames/{expected_fps} FPS/loop")
            require(metadata.get("directions") == DIRECTIONS,
                    f"{character['id']} {state}: ordem 8-dir inesperada")
            require(metadata.get("cell") == [96, 96] and metadata.get("pivot") == [48, 80],
                    f"{character['id']} {state}: grade/pivô não correspondem à metadata atual")
            require(metadata.get("status") == "corrigir" and metadata.get("approved") is False,
                    f"{character['id']} {state}: status candidato foi alterado")
            atlas_path = metadata_path.parent / metadata["atlas"]
            require(atlas_path.is_file(), f"atlas inexistente: {atlas_path}")
            with Image.open(atlas_path) as image:
                require(image.size == (96 * expected_frames, 96 * 8),
                        f"{character['id']} {state}: dimensão atlas inesperada {image.size}")
            inspected += 1
    changed = subprocess.run(
        ["git", "diff", "--name-only", BASE_COMMIT, "--", "assets/characters"],
        cwd=ROOT, capture_output=True, text=True, check=True,
    ).stdout.splitlines()
    require(not any(path.lower().endswith(".png") for path in changed),
            "PNG de personagem foi alterado nesta fatia")
    return inspected


def check_terrain() -> tuple[int, int, int]:
    manifest_path = ROOT / "assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.json"
    manifest = load_json(manifest_path)
    require(manifest["status"] == "candidate_pending_visual_and_engine_review",
            "terreno não pode ser promovido a aprovado")
    tiles = manifest["tiles"]
    require(len(tiles) == 56 and len({tile["id"] for tile in tiles}) == 56,
            "esperados 56 IDs únicos de terreno")
    require(len({tuple(tile["atlas_xy_tiles"]) for tile in tiles}) == 56,
            "tiles precisam ocupar 56 células distintas")
    roles = {role: [tile for tile in tiles if tile["role"] == role]
             for role in ("base", "transition", "overlay")}
    require((len(roles["base"]), len(roles["transition"]), len(roles["overlay"])) == (17, 24, 15),
            "contagem esperada base/transição/overlay 17/24/15")
    atlas_path = manifest_path.parent / manifest["atlas"]["file"]
    with Image.open(atlas_path) as image:
        require(image.size == (256, 224), f"dimensão atlas terreno inesperada: {image.size}")

    layout = load_json(ROOT / "game/data/first_island_layout.json")
    width, height = layout["grid_size"]
    require(layout["tile_px_candidate"] == manifest["cell_px_candidate"] == [32, 32],
            "grade do mapa deve respeitar célula candidata de 32 px")
    coverage: set[tuple[int, int]] = set()
    for band in layout["surface_bands"]:
        for x in range(band["from_x"], band["to_x"]):
            for y in range(height):
                cell = (x, y)
                require(cell not in coverage, f"bandas de superfície sobrepostas em {cell}")
                coverage.add(cell)
    require(len(coverage) == width * height,
            "tiles base devem preencher toda a superfície sob as camadas de overlays")
    base_by_group: dict[str, list[str]] = {}
    for tile in roles["base"]:
        base_by_group.setdefault(tile["group"], []).append(tile["id"])
    used_base: set[str] = set()
    seed = layout["seed"]
    for band in layout["surface_bands"]:
        variants = base_by_group[band["group"]]
        for x in range(band["from_x"], band["to_x"]):
            for y in range(height):
                used_base.add(variants[(x * 17 + y * 31 + seed) % len(variants)])
    for area in layout["surface_areas"]:
        variants = base_by_group[area["group"]]
        for x in range(area["from_x"], area["to_x"]):
            for y in range(area["from_y"], area["to_y"]):
                used_base.add(variants[(x * 17 + y * 31 + seed) % len(variants)])
    require(used_base == {tile["id"] for tile in roles["base"]},
            "a composição do primeiro mapa deve usar os 17 tiles base")

    transition_ids = {tile["id"] for tile in roles["transition"]}
    used_transitions: set[str] = set()
    for band in layout["transition_bands"]:
        used_transitions.add(f"{band['prefix']}_edge_{band['edge']}")
    for patch in layout["transition_patches"]:
        prefix = patch["prefix"]
        used_transitions.update(f"{prefix}_{kind}" for kind in [
            "corner_nw", "edge_n", "corner_ne", "edge_w", "edge_e", "corner_sw", "edge_s", "corner_se"
        ])
    require(used_transitions == transition_ids,
            f"transições não usadas/faltantes: {sorted(transition_ids ^ used_transitions)}")

    overlays = {tile["id"] for tile in roles["overlay"]}
    with Image.open(atlas_path) as image:
        image = image.convert("RGBA")
        for tile in roles["overlay"]:
            x, y = tile["atlas_xy_tiles"]
            alpha = image.crop((x * 32, y * 32, x * 32 + 32, y * 32 + 32)).getchannel("A")
            require(alpha.getextrema() == (0, 255),
                    f"overlay deve preservar transparência sobre o tile base: {tile['id']}")
    network = layout["path_network"]
    network_ids = [item["id"] for item in network]
    cells = [tuple(item["cell"]) for item in network]
    require(len(network) == 15 and set(network_ids) == overlays,
            "a rede inicial deve usar uma vez cada overlay candidato")
    require(len(set(cells)) == len(cells), "duas overlays ocupam a mesma célula")
    by_cell = set(cells)
    start = cells[0]
    found = {start}
    queue = deque([start])
    while queue:
        x, y = queue.popleft()
        for neighbor in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
            if neighbor in by_cell and neighbor not in found:
                found.add(neighbor)
                queue.append(neighbor)
    require(found == by_cell, "rede de caminho deve formar um componente conectado")
    spawn, beacon = tuple(layout["spawn_cell"]), tuple(layout["beacon_cell"])
    blocked_cells = {tuple(item["cell"]) for item in layout["obstacles"]}
    require(spawn not in blocked_cells and beacon not in blocked_cells,
            "spawn/cristal não podem sobrepor proxies colisionáveis")
    require(layout["surface_bands"][0]["from_x"] == 0 and layout["surface_bands"][-1]["to_x"] == width,
            "a composição de superfície deve começar e terminar nas bordas do mapa")
    return len(tiles), len(network), len(coverage)


def main() -> int:
    scenes_and_scripts = check_scenes()
    animations = check_characters()
    terrain, overlays, covered_cells = check_terrain()
    print(f"PASS: {scenes_and_scripts} cenas/scripts com referências resolvidas")
    print(f"PASS: {animations} animações existentes (4 aparências × idle4/walk6; 8 direções)")
    print(f"PASS: {terrain} tiles manifest (17+24+15); mapa cobre {covered_cells} células de base, mantém overlays transparentes e usa 17 bases/24 transições/{overlays} overlays conectadas")
    print("PASS: estado artístico preservado; nenhum PNG de personagem mudou")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (AssertionError, KeyError, OSError, ValueError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
