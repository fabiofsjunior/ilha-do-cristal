#!/usr/bin/env python3
"""Export the Godot Web preset and package a locally playable ZIP."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
from zipfile import ZipFile, ZIP_DEFLATED


ROOT = Path(__file__).resolve().parents[2]


def find_godot(value: str | None) -> str:
    candidates = [value, os.environ.get("GODOT_BIN")]
    candidates.extend(str(path) for path in ROOT.glob("Godot_v4.5.1-stable*"))
    candidates.extend([shutil.which("godot"), shutil.which("godot4")])
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return str(Path(candidate).resolve())
    raise SystemExit("Godot não encontrado. Use --godot /caminho/do/Godot-4.5.1.")


def package_web(output: Path, archive: Path, version: str) -> None:
    required = ("index.html", "index.js", "index.wasm", "index.pck")
    missing = [name for name in required if not (output / name).is_file()]
    if missing:
        raise SystemExit("Export Web incompleto: " + ", ".join(missing))
    commit = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
    ).strip()
    info = {
        "engine": version,
        "source_commit": commit,
        "built_at": datetime.now(timezone.utc).isoformat(),
        "target": "Web",
        "art_approval": "candidate; visual review pending",
    }
    (output / "BUILD_INFO.json").write_text(
        json.dumps(info, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (output / "COMO_EXECUTAR.txt").write_text(
        "A Ilha do Cristal — build Web de teste\n\n"
        "Extraia todos os arquivos da pasta ZIP. No Windows, dê dois cliques em\n"
        "Testar_Jogo_Web.bat (requer Python 3). O navegador abre automaticamente.\n"
        "Ou rode: python3 -m http.server 8000 e abra http://localhost:8000/\n"
        "Não abra index.html por file://. Para parar o servidor use Ctrl+C.\n\n"
        "WASD/setas: mover; E: interagir. Use os botões da tela para outras ações.\n"
        "Esta é uma build de teste com arte candidata, sem aprovação final.\n",
        encoding="utf-8",
    )
    extensions = {".html", ".js", ".wasm", ".pck", ".png", ".json", ".webmanifest", ".txt"}
    with ZipFile(archive, "w", compression=ZIP_DEFLATED, compresslevel=6) as bundle:
        for path in sorted(output.iterdir()):
            if path.is_file() and path.suffix.lower() in extensions:
                bundle.write(path, path.name)
        for relative in ("Testar_Jogo_Web.bat", "tools/web/serve_web_build.py"):
            bundle.write(ROOT / relative, relative)
    with ZipFile(archive) as bundle:
        bad_entry = bundle.testzip()
        if bad_entry:
            raise SystemExit(f"ZIP corrompido: {bad_entry}")
    print(f"Web: {output / 'index.html'}")
    print(f"ZIP: {archive} ({archive.stat().st_size:,} bytes)")
    print(f"SHA256: {hashlib.sha256(archive.read_bytes()).hexdigest()}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", help="binário Godot 4.5.1")
    args = parser.parse_args()
    engine = find_godot(args.godot)
    version = subprocess.check_output([engine, "--version"], text=True).strip()
    if not version.startswith("4.5.1."):
        raise SystemExit(f"Esperado Godot 4.5.1, encontrado {version}")
    build = ROOT / "build"
    output = build / "web"
    output.mkdir(parents=True, exist_ok=True)
    (build / ".gdignore").touch()
    logs = build / "logs"
    logs.mkdir(exist_ok=True)
    log = logs / "export-web.log"
    with log.open("w", encoding="utf-8") as handle:
        result = subprocess.run(
            [engine, "--headless", "--path", str(ROOT), "--export-release", "Web", str(output / "index.html")],
            cwd=ROOT, stdout=handle, stderr=subprocess.STDOUT,
        )
    messages = log.read_text(encoding="utf-8", errors="replace")
    errors = [line for line in messages.splitlines() if "ERROR:" in line]
    if result.returncode or errors:
        print("\n".join(errors[-12:]) or messages[-2000:])
        raise SystemExit(f"Export Web falhou. Consulte {log}")
    package_web(output, build / "ilha-do-cristal-web.zip", version)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
