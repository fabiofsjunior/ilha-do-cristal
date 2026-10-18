#!/usr/bin/env python3
"""Bake authored layout into fixed row-major tile IDs; never called by runtime."""
import argparse
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
LAYOUT = ROOT / 'game/data/first_island_layout.json'
MANIFEST = ROOT / 'assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.json'
OUTPUT = ROOT / 'game/data/first_island_tiles.json'

def bake():
    layout = json.loads(LAYOUT.read_text())
    manifest = json.loads(MANIFEST.read_text())
    width, height = layout['grid_size']
    palette = [t['id'] for t in manifest['tiles']]
    lookup = {name: i for i, name in enumerate(palette)}
    groups = {}
    for tile in manifest['tiles']:
        if tile.get('role') == 'base':
            groups.setdefault(tile['group'], []).append(tile['id'])
    base = [-1] * (width * height)
    transitions, paths = {}, {}
    def put(layer, x, y, name):
        assert 0 <= x < width and 0 <= y < height, (x, y)
        layer[y * width + x] = lookup[name]
    for area in layout['surface_bands'] + layout['surface_areas']:
        variants = groups[area['group']]
        for y in range(area.get('from_y', 0), area.get('to_y', height)):
            for x in range(area['from_x'], area['to_x']):
                put(base, x, y, variants[(x * 17 + y * 31 + layout['seed']) % len(variants)])
    for band in layout['transition_bands']:
        for y in range(height):
            put(transitions, band['x'], y, f"{band['prefix']}_edge_{band['edge']}")
    for patch in layout['transition_patches']:
        cx, cy = patch['center']
        for dx, dy, suffix in [(-1,-1,'corner_nw'),(0,-1,'edge_n'),(1,-1,'corner_ne'),(-1,0,'edge_w'),(0,0,''),(1,0,'edge_e'),(-1,1,'corner_sw'),(0,1,'edge_s'),(1,1,'corner_se')]:
            put(transitions, cx+dx, cy+dy, f"{patch['prefix']}_{suffix}" if suffix else patch['inner_base'])
    for path in layout['path_network']:
        put(paths, *path['cell'], path['id'])
    assert len(base) == 50000 and min(base) >= 0
    occupied = set()
    for category in ['creature_spawns', 'harvest_nodes', 'obstacles']:
        ids = set()
        for entry in layout[category]:
            x, y = entry['cell']
            assert 8 <= x < width and 0 <= y < height, entry
            if 'id' in entry:
                assert entry['id'] not in ids, entry
                ids.add(entry['id'])
            assert (x,y) not in occupied, entry
            occupied.add((x,y))
    return {'schema_version':1,'grid_size':[width,height],'base_tile_count':len(base),'palette':palette,'layers':{'BaseTiles':base,'Transitions':[[i,v] for i,v in sorted(transitions.items())],'Paths':[[i,v] for i,v in sorted(paths.items())]}}

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    content = json.dumps(bake(), separators=(',', ':')) + '\n'
    if args.check:
        assert OUTPUT.read_text() == content, 'Fixed map is stale; run tools/world/bake_first_island.py'
        print('PASS fixed 50,000 tile map, deterministic bake, palette and population positions')
    else:
        OUTPUT.write_text(content)
        print(f'Baked {OUTPUT.relative_to(ROOT)} ({len(content)} bytes)')
