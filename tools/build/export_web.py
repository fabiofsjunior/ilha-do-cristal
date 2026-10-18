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
GODOT_PATH_FILE = ROOT / ".godot-path"
GODOT_VERSION = "4.7.2"
GODOT_VERSION_PREFIX = f"{GODOT_VERSION}."


def _windows_godot_candidates() -> list[str]:
    """Look in common Godot download/install locations on Windows."""
    if os.name != "nt":
        return []

    home = Path.home()
    directories = [
        home / "Downloads",
        home / "Desktop",
        home / "Documents",
        home / "OneDrive" / "Downloads",
        home / "OneDrive" / "Desktop",
    ]
    for name in ("LOCALAPPDATA", "ProgramFiles", "ProgramFiles(x86)"):
        value = os.environ.get(name)
        if value:
            base = Path(value)
            directories.extend((base / "Godot", base / "Programs" / "Godot"))

    one_drive = os.environ.get("OneDrive")
    if one_drive:
        directories.extend((Path(one_drive) / "Downloads", Path(one_drive) / "Desktop"))

    found = []
    for directory in dict.fromkeys(directories):
        if not directory.is_dir():
            continue
        for pattern in (f"Godot_v{GODOT_VERSION}-stable*.exe", "Godot.exe"):
            matches = list(directory.glob(pattern))
            matches.extend(directory.glob(f"*/{pattern}"))
            matches = [path for path in matches if path.is_file()]
            matches.sort(
                key=lambda path: (
                    "_console.exe" not in path.name.lower(),
                    path.as_posix().lower(),
                )
            )
            found.extend(str(path) for path in matches)
    return found


def find_godot(value: str | None) -> str:
    candidates = [value]
    root_candidates = list(ROOT.glob(f"Godot_v{GODOT_VERSION}-stable*"))
    root_candidates.sort(key=lambda path: "_console" not in path.name.lower())
    candidates.extend(str(path) for path in root_candidates)
    candidates.append(str(ROOT / "Godot.exe"))
    candidates.append(os.environ.get("GODOT_BIN"))
    candidates.extend(_windows_godot_candidates())
    candidates.extend(
        [
            shutil.which(f"Godot_v{GODOT_VERSION}-stable_win64_console.exe"),
            shutil.which("godot"),
            shutil.which("godot4"),
            shutil.which(f"Godot_v{GODOT_VERSION}-stable_win64.exe"),
        ]
    )
    if GODOT_PATH_FILE.is_file():
        configured_path = GODOT_PATH_FILE.read_text(encoding="utf-8").strip()
        if configured_path:
            candidates.append(configured_path)
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate).expanduser()
        if path.is_file() and (os.name != "nt" or path.suffix.lower() == ".exe"):
            return str(path.resolve())
    raise SystemExit(
        f"Godot {GODOT_VERSION} não encontrado. Instale/extraia essa versão e selecione o "
        "executável Godot (.exe) quando o launcher pedir, ou defina GODOT_BIN. "
        'No terminal: py -3 tools/build/export_web.py --godot '
        f'"C:\\caminho\\Godot_v{GODOT_VERSION}-stable_win64.exe".'
    )


def validate_godot_version(version: str) -> None:
    if not version.startswith(GODOT_VERSION_PREFIX):
        raise SystemExit(f"Esperado Godot {GODOT_VERSION}, encontrado {version}")


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
        "source_dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip()),
        "visual_revision": "close-view-ground-target-marker-20261016",
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
    parser.add_argument("--godot", help=f"binário Godot {GODOT_VERSION}")
    parser.add_argument(
        "--print-godot",
        action="store_true",
        help="localiza o Godot e imprime o caminho para uso pelo launcher",
    )
    parser.add_argument(
        "--save-godot",
        action="store_true",
        help="salva localmente o caminho fornecido em --godot",
    )
    args = parser.parse_args()
    engine = find_godot(args.godot)
    version = subprocess.check_output([engine, "--version"], text=True).strip()
    validate_godot_version(version)
    if args.print_godot:
        print(engine)
        return 0
    if args.save_godot:
        GODOT_PATH_FILE.write_text(engine + "\n", encoding="utf-8")
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
