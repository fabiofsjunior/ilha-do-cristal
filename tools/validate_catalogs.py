"""Validate cross-references in the planning catalog; run from any directory."""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / "data/catalogs/mvp.json").read_text(encoding="utf-8"))
groups = ("characters", "vocations", "weapons_and_tools", "skills", "monsters", "resources", "consumables", "recipes", "buildings", "regions")
ids = {}
for group in groups:
    entries = data[group]
    assert entries and isinstance(entries, list), group
    names = [entry["id"] for entry in entries]
    assert len(names) == len(set(names)), f"duplicate ID in {group}"
    for name in names:
        assert name not in ids, f"duplicate global ID: {name}"
        ids[name] = group

for entry in data["weapons_and_tools"] + data["skills"]:
    if "vocation" in entry:
        assert entry["vocation"] in {v["id"] for v in data["vocations"]}
for monster in data["monsters"]:
    assert monster["region"] in {r["id"] for r in data["regions"]}
    for drop in monster["drops"]:
        assert drop["item"] in ids, drop
        assert 0 <= drop["chance"] <= 1
for recipe in data["recipes"]:
    assert recipe["output"] in ids, recipe
    assert all(item in ids and quantity > 0 for item, quantity in recipe["requires"].items()), recipe
for upgrade in data["camp_upgrades"]:
    assert all(item in ids and quantity > 0 for item, quantity in upgrade["requires"].items()), upgrade
assert len(data["skills"]) == 9
assert len(data["monsters"]) == 30
assert {entry["id"] for entry in data["characters"]} == {"melissa", "helena", "maira", "fabio"}
assert len(data["animations_and_vfx"]["directions"]) == 8
assert sum(data["attributes_and_levels"]["xp_to_next_level_from_1_to_9"]) == 3202
assert data["talents"]["planned_per_vocation"] == {"small": 60, "large": 25, "special": 15}
print(f"Catalog valid: {len(groups)} groups, {len(ids)} stable IDs")

