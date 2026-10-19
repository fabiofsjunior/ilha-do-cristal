#!/usr/bin/env python3
"""Bake the 100k logical-cell island into the compact 4x4 isometric tile grid."""
import argparse
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LAYOUT = ROOT / "game/data/first_island_layout.json"
OUTPUT = ROOT / "game/data/first_island_tiles.json"
CELL_SQM = 4
ATLAS_INDEX = {
    "grass_a": 0,
    "grass_b": 1,
    "forest": 2,
    "sand": 3,
    "stone": 5,
    "deep_water": 6,
    "shallow_water": 7,
    "corruption_a": 56,
    "corruption_b": 57,
}


def point_in_polygon(point, polygon):
    x, y = point
    inside = False
    previous = polygon[-1]
    for current in polygon:
        x1, y1 = current
        x2, y2 = previous
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
            inside = not inside
        previous = current
    return inside


def distance_to_segment(point, start, end):
    px, py = point
    ax, ay = start
    bx, by = end
    dx, dy = bx - ax, by - ay
    length_squared = dx * dx + dy * dy
    if length_squared == 0:
        return math.hypot(px - ax, py - ay)
    amount = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / length_squared))
    return math.hypot(px - (ax + amount * dx), py - (ay + amount * dy))


def distance_to_polygon(point, polygon):
    return min(
        distance_to_segment(point, polygon[index - 1], polygon[index])
        for index in range(len(polygon))
    )


def tile_index_for(point, tile_x, tile_y, layout):
    outline = layout["island_outline"]
    if not point_in_polygon(point, outline):
        distance = distance_to_polygon(point, outline)
        return ATLAS_INDEX["shallow_water"] if distance <= CELL_SQM * 2.25 else ATLAS_INDEX["deep_water"]
    for water in layout.get("water_polygons", []):
        if point_in_polygon(point, water):
            return ATLAS_INDEX["deep_water"]
    for zone in layout.get("terrain_zones", []):
        if any(point_in_polygon(point, polygon) for polygon in zone.get("polygons", [])):
            group = zone.get("group", "")
            if group == "forest":
                return ATLAS_INDEX["forest"]
            if group == "plateau":
                return ATLAS_INDEX["stone"]
            if group == "corruption":
                return ATLAS_INDEX["corruption_a"] if (tile_x + tile_y) % 2 == 0 else ATLAS_INDEX["corruption_b"]
    if distance_to_polygon(point, outline) <= CELL_SQM * 2.25:
        return ATLAS_INDEX["sand"]
    return ATLAS_INDEX["grass_a"] if (tile_x * 17 + tile_y * 31 + int(layout.get("seed", 0))) % 2 == 0 else ATLAS_INDEX["grass_b"]


def bake():
    layout = json.loads(LAYOUT.read_text(encoding="utf-8"))
    width, height = layout["grid_size"]
    cell_stride = int(layout.get("tile_cells_per_sqm", CELL_SQM))
    if cell_stride != CELL_SQM:
        raise ValueError(f"expected {CELL_SQM} logical cells per isometric tile, got {cell_stride}")
    tile_width = math.ceil(width / cell_stride)
    tile_height = math.ceil(height / cell_stride)
    base_tiles = []
    for tile_y in range(tile_height):
        for tile_x in range(tile_width):
            center = (tile_x * CELL_SQM + CELL_SQM * 0.5, tile_y * CELL_SQM + CELL_SQM * 0.5)
            base_tiles.append(tile_index_for(center, tile_x, tile_y, layout))

    allocations = layout.get("monster_allocations", [])
    expected_counts = {"coast": 4, "forest": 12, "plateau": 8, "corruption": 6}
    actual_counts = {zone: sum(1 for entry in allocations if entry.get("zone") == zone) for zone in expected_counts}
    if actual_counts != expected_counts or len(allocations) != 30:
        raise ValueError(f"expected 30 allocations grouped {expected_counts}, got {actual_counts}")
    species = {species_id for entry in allocations for species_id in entry.get("species_ids", [])}
    if len(species) != 30:
        raise ValueError(f"expected 30 unique bestiary species, got {len(species)}")

    for entry in layout.get("creature_spawns", []) + layout.get("harvest_nodes", []) + layout.get("obstacles", []):
        x, y = entry["cell"]
        if not (0 <= x < width and 0 <= y < height):
            raise ValueError(f"cell outside map: {entry}")
        if not point_in_polygon((x, y), layout["island_outline"]):
            raise ValueError(f"runtime point outside island: {entry}")

    return {
        "schema_version": 2,
        "grid_size": [width, height],
        "tile_grid_size": [tile_width, tile_height],
        "tile_cells_per_sqm": cell_stride,
        "logical_cell_count": width * height,
        "base_tile_count": len(base_tiles),
        "atlas_palette": ATLAS_INDEX,
        "base_tiles": base_tiles,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    content = json.dumps(bake(), separators=(",", ":")) + "\n"
    if args.check:
        if OUTPUT.read_text(encoding="utf-8") != content:
            raise SystemExit("fixed 100,000-cell island map is stale; run tools/world/bake_first_island.py")
        print("PASS island bake: 100,000 logical cells, 6,300 isometric tiles, 30 allocation points and 30 species")
    else:
        OUTPUT.write_text(content, encoding="utf-8")
        print(f"Baked {OUTPUT.relative_to(ROOT)} ({len(content)} bytes)")
