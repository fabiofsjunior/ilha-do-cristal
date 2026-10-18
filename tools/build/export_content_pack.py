#!/usr/bin/env python3
"""Export and describe a versioned PCK for a GitHub content release."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
VERSION_PATTERN = re.compile(r"^\d+\.\d+\.\d+$")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="content version, e.g. 1.0.1")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"), help="Godot 4.5.1 editor executable")
    args = parser.parse_args()

    if not VERSION_PATTERN.fullmatch(args.version):
        parser.error("--version must use MAJOR.MINOR.PATCH")

    godot = shutil.which(args.godot) or (args.godot if Path(args.godot).is_file() else None)
    if not godot:
        print("Godot editor executable not found; pass --godot or set GODOT_BIN.", file=sys.stderr)
        return 2

    asset_name = f"ilha-do-cristal-content-v{args.version}.pck"
    output = ROOT / "build" / "android" / asset_name
    output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        str(godot), "--headless", "--path", str(ROOT),
        "--export-pack", "Android Content Pack", str(output),
    ]
    print("Exporting Android content pack:", " ".join(command))
    result = subprocess.run(command, cwd=ROOT, check=False, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != 0:
        print(result.stdout, file=sys.stderr)
        return result.returncode
    godot_errors = [line for line in result.stdout.splitlines() if "ERROR:" in line]
    if godot_errors:
        print("Godot reported errors while exporting the content pack:", file=sys.stderr)
        print("\n".join(godot_errors), file=sys.stderr)
        output.unlink(missing_ok=True)
        return 1
    stored_files = re.findall(r"Storing File: (res://[^\s\x1b]+)", result.stdout)
    forbidden_extensions = (".gd", ".gdc", ".tscn", ".scn")
    forbidden_files = [path for path in stored_files if path.endswith(forbidden_extensions)]
    if forbidden_files:
        print("Content pack export included game code or scenes:", file=sys.stderr)
        print("\n".join(forbidden_files), file=sys.stderr)
        output.unlink(missing_ok=True)
        return 1
    required_files = {
        "res://data/catalogs/mvp.json",
        "res://game/data/first_island_layout.json",
        "res://game/data/first_island_tiles.json",
        "res://game/data/player_appearances.json",
        "res://assets/creatures/fox/fox_static_concept_v0_1.png.import",
        "res://assets/ui/crystal_v2/sheet.b64",
    }
    missing_files = sorted(required_files.difference(stored_files))
    if missing_files:
        print("Content pack is missing required runtime files:", file=sys.stderr)
        print("\n".join(missing_files), file=sys.stderr)
        output.unlink(missing_ok=True)
        return 1
    if not output.is_file() or output.stat().st_size == 0:
        print("Godot returned success but did not create the PCK.", file=sys.stderr)
        return 1

    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    print(json.dumps({
        "release_tag": f"content-v{args.version}",
        "asset_name": asset_name,
        "size_bytes": output.stat().st_size,
        "sha256": digest,
        "file": str(output.relative_to(ROOT)),
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

