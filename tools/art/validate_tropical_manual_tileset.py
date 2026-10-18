#!/usr/bin/env python3
"""Static validation for the user-provided tropical manual painting atlas."""
from __future__ import annotations

import re
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ASSET_DIR = ROOT / "assets" / "environments" / "tropical_manual_v1"
ATLAS_PATH = ASSET_DIR / "tropical_manual_v1.png"
TERRAIN_PATH = ASSET_DIR / "tropical_manual_terrain_v1.tres"
PROPS_PATH = ASSET_DIR / "tropical_manual_props_v1.tres"
SCENE_PATH = ROOT / "game" / "scenes" / "first_island.tscn"
FIRST_ISLAND_PATH = ROOT / "game" / "scripts" / "world" / "first_island.gd"
RENDERER_PATH = ROOT / "game" / "scripts" / "world" / "isometric_3d_view.gd"


def atlas_coords(resource_path: Path) -> set[tuple[int, int]]:
    text = resource_path.read_text(encoding="utf-8")
    return {(int(x), int(y)) for x, y in re.findall(r"(?m)^(\d+):(\d+)/0 = 0$", text)}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"FAIL: {message}")


image = Image.open(ATLAS_PATH)
require(image.mode == "RGBA", f"atlas mode is {image.mode}, expected RGBA")
require(image.size == (1024, 1024), f"atlas dimensions are {image.size}, expected 1024x1024")
require(image.mode == "RGBA", "atlas must be RGBA")
alpha_values = set(image.getchannel("A").get_flattened_data())
require(alpha_values <= {0, 255}, f"alpha must be binary, got {sorted(alpha_values)}")
checker_colors = {(48, 45, 55), (69, 65, 77), (122, 112, 145)}
require(
    not any(a and (r, g, b) in checker_colors for r, g, b, a in image.get_flattened_data()),
    "opaque checkerboard/grid colors remain in atlas",
)

terrain_text = TERRAIN_PATH.read_text(encoding="utf-8")
props_text = PROPS_PATH.read_text(encoding="utf-8")
for resource in (terrain_text, props_text):
    require("texture_region_size = Vector2i(128, 128)" in resource, "TileSet atlas slice size is not 128x128")
    require("tile_size = Vector2i(128, 128)" in resource, "TileSet cell size is not 128x128")
    require("tropical_manual_v1.png" in resource, "TileSet does not reference the cleaned atlas")
terrain = atlas_coords(TERRAIN_PATH)
props = atlas_coords(PROPS_PATH)
expected_terrain = {(x, y) for y in range(5) for x in range(8)}
expected_props = {(x, y) for y in range(5, 8) for x in range(8)}
require(terrain == expected_terrain, f"terrain TileSet has {len(terrain)} wrong atlas cells")
require(props == expected_props, f"props TileSet has {len(props)} wrong atlas cells")
require(not (terrain & props), "terrain and props TileSets overlap")
require(len(terrain | props) == 64, "the two TileSets must expose all 64 slices")

scene = SCENE_PATH.read_text(encoding="utf-8")
require('name="ManualTerrain" type="TileMapLayer"' in scene, "ManualTerrain layer is missing")
require('name="ManualProps" type="TileMapLayer"' in scene, "ManualProps layer is missing")
require("tropical_manual_terrain_v1.tres" in scene and "tropical_manual_props_v1.tres" in scene, "scene TileSet references are missing")
manual_scene_section = scene.split('[node name="ManualTerrain" type="TileMapLayer" parent="."]', 1)[1].split('[node name="Actors" type="Node2D" parent="."]', 1)[0]
require("tile_map_data" not in manual_scene_section, "manual layers should start empty")

first_island = FIRST_ISLAND_PATH.read_text(encoding="utf-8")
renderer = RENDERER_PATH.read_text(encoding="utf-8")
require("ManualTerrain" in first_island and "ManualProps" in first_island, "startup validation/hide list omits manual layers")
require("_build_manual_terrain_surface()" in renderer, "renderer does not consume ManualTerrain")
require("_build_manual_prop_sprites()" in renderer, "renderer does not consume ManualProps")
require("atlas_source.texture_region_size" in renderer, "renderer does not use atlas slice dimensions")
require("world_tile_size" in renderer, "renderer does not account for 128px cells")
print("PASS: 64 transparent slices, 40 terrain + 24 props, 128px TileSets and empty editable layers.")
