#!/usr/bin/env python3
"""Alpha-mask regression for visual melee spacing in the 2.5D camera."""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
PROFILE_PATH = ROOT / "game/data/player_appearances.json"
FOOTPRINT_PATH = ROOT / "game/data/melee_visual_footprints.json"
CREATURES = ("fox", "wolf", "bear")
DIRECTIONS = {
    "N": (0.0, -1.0),
    "NE": (1.0, -1.0),
    "E": (1.0, 0.0),
    "SE": (1.0, 1.0),
    "S": (0.0, 1.0),
    "SW": (-1.0, 1.0),
    "W": (-1.0, 0.0),
    "NW": (-1.0, -1.0),
}
APPROACH_ANGLES = tuple(
    (math.cos(math.tau * index / 32), math.sin(math.tau * index / 32))
    for index in range(32)
)
SUPERSAMPLE = 4


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def alpha_bbox(image: Image.Image, threshold: int) -> tuple[int, int] | None:
    alpha = image.getchannel("A").point(lambda value: 255 if value >= threshold else 0)
    bounds = alpha.getbbox()
    if bounds is None:
        return None
    return bounds[2] - bounds[0], bounds[3] - bounds[1]


def metadata_frames(metadata_path: Path, direction: str) -> list[tuple[Image.Image, tuple[int, int]]]:
    metadata = read_json(metadata_path)
    atlas_name = metadata.get("atlas", "")
    if isinstance(atlas_name, dict):
        atlas_name = atlas_name.get("file", "")
    atlas = Image.open(metadata_path.parent / atlas_name).convert("RGBA")
    cell_w, cell_h = metadata["cell"]
    directions = metadata.get("directions", list(DIRECTIONS))
    if direction not in directions:
        return []
    row = directions.index(direction)
    animation_name = metadata.get("animation")
    animation_data = metadata.get("animations", {}).get(animation_name, {})
    frame_count = int(metadata.get("frames", animation_data.get("frames", 1)))
    pivot = tuple(map(int, metadata.get("pivot", [cell_w // 2, cell_h - 16])))
    result = []
    for column in range(frame_count):
        frame = atlas.crop((column * cell_w, row * cell_h, (column + 1) * cell_w, (row + 1) * cell_h))
        result.append((frame, pivot))
    return result


def player_bounds(profiles: list[dict], threshold: int) -> tuple[int, int]:
    max_width = max_height = 0
    for profile in profiles:
        for metadata_key in ("idle_metadata", "walk_metadata"):
            metadata_path = ROOT / profile[metadata_key].replace("res://", "")
            metadata = read_json(metadata_path)
            for direction in metadata.get("directions", list(DIRECTIONS)):
                for frame, _pivot in metadata_frames(metadata_path, direction):
                    bounds = alpha_bbox(frame, threshold)
                    if bounds:
                        max_width = max(max_width, bounds[0])
                        max_height = max(max_height, bounds[1])
    return max_width, max_height


def player_extents(profiles: list[dict], threshold: int) -> tuple[int, int, int, int]:
    min_x = min_up = math.inf
    max_x = max_up = -math.inf
    for profile in profiles:
        for metadata_key in ("idle_metadata", "walk_metadata"):
            metadata_path = ROOT / profile[metadata_key].replace("res://", "")
            for direction in read_json(metadata_path).get("directions", list(DIRECTIONS)):
                for frame, pivot in metadata_frames(metadata_path, direction):
                    bounds = frame.getchannel("A").point(lambda value: 255 if value >= threshold else 0).getbbox()
                    if bounds:
                        min_x = min(min_x, bounds[0] - pivot[0])
                        max_x = max(max_x, bounds[2] - pivot[0])
                        min_up = min(min_up, pivot[1] - bounds[3])
                        max_up = max(max_up, pivot[1] - bounds[1])
    return int(min_x), int(max_x), int(min_up), int(max_up)


def player_mask_for_direction(profile: dict, direction: str, threshold: int) -> tuple[set[tuple[float, float]], tuple[int, int]]:
    points: set[tuple[float, float]] = set()
    bounds = (0, 0)
    for metadata_key in ("idle_metadata", "walk_metadata"):
        metadata_path = ROOT / profile[metadata_key].replace("res://", "")
        for frame, pivot in metadata_frames(metadata_path, direction):
            alpha = frame.getchannel("A")
            px = alpha.load()
            for y in range(frame.height):
                for x in range(frame.width):
                    if px[x, y] >= threshold:
                        points.add((x + 0.5 - pivot[0], pivot[1] - y - 0.5))
            frame_bounds = alpha_bbox(frame, threshold)
            if frame_bounds:
                bounds = (max(bounds[0], frame_bounds[0]), max(bounds[1], frame_bounds[1]))
    return points, bounds


def creature_mask(species: str, threshold: int) -> tuple[set[tuple[float, float]], tuple[int, int], tuple[float, float], tuple[float, float, float, float]]:
    metadata_path = ROOT / f"assets/creatures/{species}/{species}_se_candidate_v1.json"
    metadata = read_json(metadata_path)
    cell_w, cell_h = metadata["cell"]
    pivot = tuple(map(int, metadata["pivot"]))
    image = Image.open(metadata_path.parent / metadata["atlas"]["file"]).convert("RGBA")
    frame = image.crop((0, 0, cell_w, cell_h))
    alpha = frame.getchannel("A")
    px = alpha.load()
    points = {
        (x + 0.5 - pivot[0], pivot[1] - y - 0.5)
        for y in range(frame.height)
        for x in range(frame.width)
        if px[x, y] >= threshold
    }
    bounds = alpha.point(lambda value: 255 if value >= threshold else 0).getbbox() or (0, 0, 0, 0)
    config = read_json(FOOTPRINT_PATH)["creatures"][species]
    scale = float(config["render_scale"])
    rendered_bounds = (math.ceil((bounds[2] - bounds[0]) * scale), math.ceil((bounds[3] - bounds[1]) * scale))
    extents = (
        (bounds[0] - pivot[0]) * scale,
        (bounds[2] - pivot[0]) * scale,
        (pivot[1] - bounds[3]) * scale,
        (pivot[1] - bounds[1]) * scale,
    )
    source_size = (bounds[2] - bounds[0], bounds[3] - bounds[1])
    return points, source_size, (scale, scale), extents


def projected_clearance(
    player_extents: tuple[float, float, float, float], creature_extents: tuple[float, float, float, float], direction: tuple[float, float],
    yaw_degrees: float, pitch_degrees: float, margin: float,
) -> float:
    length = math.hypot(*direction)
    dx, dy = direction[0] / length, direction[1] / length
    yaw = math.radians(yaw_degrees)
    pitch = math.radians(pitch_degrees)
    right = (math.cos(yaw), -math.sin(yaw))
    depth_up = (math.sin(yaw) * math.sin(pitch), math.cos(yaw) * math.sin(pitch))
    screen_right = dx * right[0] + dy * right[1]
    screen_up = dx * depth_up[0] + dy * depth_up[1]
    p_left, p_right, p_bottom, p_top = player_extents
    c_left, c_right, c_bottom, c_top = creature_extents
    p_bottom *= math.cos(pitch)
    p_top *= math.cos(pitch)
    c_bottom *= math.cos(pitch)
    c_top *= math.cos(pitch)
    x_needed = p_right - c_left if screen_right > 0 else c_right - p_left
    y_needed = p_top - c_bottom if screen_up > 0 else c_top - p_bottom
    lateral = max(0.0, x_needed + margin) / abs(screen_right) if abs(screen_right) > 1e-9 else math.inf
    depth = max(0.0, y_needed + margin) / abs(screen_up) if abs(screen_up) > 1e-9 else math.inf
    return min(lateral, depth)


def rasterize_projected(points: set[tuple[float, float]], scale: float, pitch_degrees: float) -> set[tuple[int, int]]:
    pitch_scale = math.cos(math.radians(pitch_degrees))
    half_width = scale * SUPERSAMPLE / 2
    half_height = scale * pitch_scale * SUPERSAMPLE / 2
    occupied: set[tuple[int, int]] = set()
    for local_x, local_up in points:
        center_x = local_x * scale * SUPERSAMPLE
        center_y = local_up * scale * pitch_scale * SUPERSAMPLE
        x0 = math.floor(center_x - half_width)
        x1 = math.ceil(center_x + half_width)
        y0 = math.floor(center_y - half_height)
        y1 = math.ceil(center_y + half_height)
        for gx in range(x0, x1):
            for gy in range(y0, y1):
                occupied.add((gx, gy))
    return occupied


def masks_overlap_at_contact(
    player_mask: set[tuple[float, float]], creature_points: set[tuple[float, float]],
    creature_scale: float, direction: tuple[float, float], distance: float,
    yaw_degrees: float, pitch_degrees: float,
) -> bool:
    yaw = math.radians(yaw_degrees)
    pitch = math.radians(pitch_degrees)
    length = math.hypot(*direction)
    dx, dy = direction[0] / length, direction[1] / length
    world_dx, world_dy = dx * distance, dy * distance
    screen_x = world_dx * math.cos(yaw) - world_dy * math.sin(yaw)
    screen_up = (world_dx * math.sin(yaw) + world_dy * math.cos(yaw)) * math.sin(pitch)
    shift = (round(screen_x * SUPERSAMPLE), round(screen_up * SUPERSAMPLE))
    player_pixels = rasterize_projected(player_mask, 1.0, pitch_degrees)
    creature_pixels = rasterize_projected(creature_points, creature_scale, pitch_degrees)
    return any((x + shift[0], y + shift[1]) in player_pixels for x, y in creature_pixels)


def projected_masks_overlap_at_contact(
    player_pixels: set[tuple[int, int]], creature_pixels: set[tuple[int, int]],
    direction: tuple[float, float], distance: float, yaw_degrees: float, pitch_degrees: float,
) -> bool:
    yaw = math.radians(yaw_degrees)
    pitch = math.radians(pitch_degrees)
    length = math.hypot(*direction)
    dx, dy = direction[0] / length, direction[1] / length
    screen_x = dx * distance * math.cos(yaw) - dy * distance * math.sin(yaw)
    screen_up = (dx * distance * math.sin(yaw) + dy * distance * math.cos(yaw)) * math.sin(pitch)
    shift_x, shift_y = round(screen_x * SUPERSAMPLE), round(screen_up * SUPERSAMPLE)
    return any((x + shift_x, y + shift_y) in player_pixels for x, y in creature_pixels)


def projected_boxes_overlap_at_contact(
    player_extents: tuple[float, float, float, float],
    creature_extents: tuple[float, float, float, float],
    direction: tuple[float, float], distance: float, yaw_degrees: float, pitch_degrees: float,
) -> bool:
    yaw = math.radians(yaw_degrees)
    pitch = math.radians(pitch_degrees)
    length = math.hypot(*direction)
    dx, dy = direction[0] / length, direction[1] / length
    shift_x = dx * distance * math.cos(yaw) - dy * distance * math.sin(yaw)
    shift_up = (dx * distance * math.sin(yaw) + dy * distance * math.cos(yaw)) * math.sin(pitch)
    p_left, p_right, p_bottom, p_top = player_extents
    c_left, c_right, c_bottom, c_top = creature_extents
    p_bottom *= math.cos(pitch)
    p_top *= math.cos(pitch)
    c_bottom *= math.cos(pitch)
    c_top *= math.cos(pitch)
    separated_x = p_right < c_left + shift_x or c_right + shift_x < p_left
    separated_y = p_top < c_bottom + shift_up or c_top + shift_up < p_bottom
    return not (separated_x or separated_y)


def contact_distances(extents: tuple[float, float, float, float], species_data: dict, config: dict) -> list[float]:
    creature_extents = species_data["rendered_alpha_extents_px"]
    margin = float(config["separation_margin_px"])
    camera = config["camera"]
    return [
        projected_clearance(extents, creature_extents, direction, camera["yaw_degrees"], camera["pitch_degrees"], margin)
        for direction in DIRECTIONS.values()
    ]


def check() -> None:
    profiles = read_json(PROFILE_PATH)["characters"]
    config = read_json(FOOTPRINT_PATH)
    threshold = int(config["alpha_threshold"])
    player_size = player_bounds(profiles, threshold)
    player_offsets = player_extents(profiles, threshold)
    assert list(player_size) == config["player_alpha_bounds_px"], (
        f"player alpha maximum changed: actual={player_size} contract={config['player_alpha_bounds_px']}"
    )
    assert list(player_offsets) == config["player_alpha_extents_px"], (
        f"player alpha pivot extents changed: actual={player_offsets} contract={config['player_alpha_extents_px']}"
    )

    species_data = {}
    creature_masks = {}
    for species in CREATURES:
        points, source_size, (scale, _scale_y), extents = creature_mask(species, threshold)
        row = config["creatures"][species]
        rendered_size = [math.ceil(source_size[0] * scale), math.ceil(source_size[1] * scale)]
        assert list(source_size) == row["source_alpha_bounds_px"], (
            f"{species} alpha bounds changed: actual={source_size} contract={row['source_alpha_bounds_px']}"
        )
        assert rendered_size == row["rendered_alpha_bounds_px"], (
            f"{species} rendered bounds changed: actual={rendered_size} contract={row['rendered_alpha_bounds_px']}"
        )
        assert all(math.isclose(actual, expected, abs_tol=0.001) for actual, expected in zip(extents, row["rendered_alpha_extents_px"])), (
            f"{species} rendered alpha pivot extents changed: actual={extents} contract={row['rendered_alpha_extents_px']}"
        )
        species_data[species] = extents
        creature_masks[species] = rasterize_projected(points, scale, config["camera"]["pitch_degrees"])

    player_masks = {}
    for profile in profiles:
        for facing in DIRECTIONS:
            player_mask, _ = player_mask_for_direction(profile, facing, threshold)
            assert player_mask, f"{profile['id']} {facing} sprite direction is empty"
            player_masks[profile["id"], facing] = rasterize_projected(
                player_mask, 1.0, config["camera"]["pitch_degrees"]
            )
            for species in CREATURES:
                creature_extent = species_data[species]
                for angle_index, vector in enumerate(APPROACH_ANGLES):
                    required = projected_clearance(
                        player_offsets, creature_extent, vector,
                        config["camera"]["yaw_degrees"], config["camera"]["pitch_degrees"],
                        config["separation_margin_px"],
                    )
                    assert not projected_boxes_overlap_at_contact(
                        player_offsets, creature_extent, vector, required,
                        config["camera"]["yaw_degrees"], config["camera"]["pitch_degrees"],
                    ), f"projected alpha bounds overlap at contact: {profile['id']} facing {facing} vs {species} at angle {angle_index}"
                for axis_name, vector in DIRECTIONS.items():
                    required = projected_clearance(
                        player_offsets, creature_extent, vector,
                        config["camera"]["yaw_degrees"], config["camera"]["pitch_degrees"],
                        config["separation_margin_px"],
                    )
                    assert not projected_masks_overlap_at_contact(
                        player_masks[profile["id"], facing], creature_masks[species], vector, required,
                        config["camera"]["yaw_degrees"], config["camera"]["pitch_degrees"],
                    ), f"alpha masks overlap at contact: {profile['id']} facing {facing} vs {species} at axis {axis_name}"

    print("PASS visual melee alpha: all 4 Warrior profiles × 8 facing rows × 3 creatures × 32 projected angles and 8 pixel-mask axes are disjoint at contact")
    for species in CREATURES:
        distances = contact_distances(player_offsets, config["creatures"][species], config)
        print(f"{species}: {min(distances):.1f}–{max(distances):.1f} logical px over 8 common axes (margin {config['separation_margin_px']} px)")


if __name__ == "__main__":
    try:
        check()
    except Exception as error:  # noqa: BLE001 - test runner prints actionable context
        print(f"FAIL visual melee alpha: {error}", file=sys.stderr)
        raise
