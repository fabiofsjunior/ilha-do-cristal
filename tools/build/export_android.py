#!/usr/bin/env python3
"""Export and validate the Android debug APK with Godot 4.5.1."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree


PROJECT_ROOT = Path(__file__).resolve().parents[2]
PRESET_NAME = "Android Debug"
PACKAGE_NAME = "com.fabiofsjunior.ilhadocristal"
APP_NAME = "A Ilha do Cristal"
GODOT_VERSION_PREFIX = "4.5.1.stable."
FORBIDDEN_EXPORTED_PATH_PREFIXES = (
    "/assets/tools/",
    "/assets/docs/",
    "/assets/Docs/",
    "/assets/assets/references/",
    "/assets/build/",
    "/assets/dist/",
)
ANDROID_XMLNS = "http://schemas.android.com/apk/res/android"
KNOWN_PROJECT_ICON_ERROR = (
    "ERROR: No project icon specified. Please specify one in the Project Settings "
    "under Application -> Config -> Icon"
)
REQUIRED_RUNTIME_FILES = (
    "/assets/data/catalogs/mvp.json",
    "/assets/game/data/first_island_layout.json",
)
REQUIRED_LAUNCHER_ICONS = (
    "res/mipmap-xxxhdpi-v4/icon.png",
    "res/mipmap-xxxhdpi-v4/icon_background.png",
    "res/mipmap-xxxhdpi-v4/icon_foreground.png",
    "res/mipmap-xxxhdpi-v4/icon_monochrome.png",
    "res/mipmap-anydpi-v26/icon.xml",
)


def fail(message: str) -> None:
    print(f"Erro: {message}", file=sys.stderr)
    raise SystemExit(2)


def classify_godot_output(output: str) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for line in output.splitlines():
        if "SCRIPT ERROR:" in line:
            errors.append(line)
        elif "ERROR:" in line:
            if line.strip() == KNOWN_PROJECT_ICON_ERROR:
                warnings.append(line)
            else:
                errors.append(line)
    return errors, warnings


def run_godot_logged(
    command: list[str], env: dict[str, str], log_path: Path, label: str
) -> str:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        errors="replace",
    )
    output = result.stdout or ""
    log_path.write_text(output, encoding="utf-8")
    errors, warnings = classify_godot_output(output)

    if warnings:
        with log_path.open("a", encoding="utf-8") as log_file:
            for warning in warnings:
                log_file.write(
                    f"\n[export_android] WARNING (allowlisted non-fatal): {warning}\n"
                )
        for warning in warnings:
            print(f"AVISO Godot (não fatal, exceção conhecida): {warning}")

    if result.returncode != 0 or errors:
        if errors:
            print(f"Falhas reportadas pelo Godot durante {label}:", file=sys.stderr)
            print("\n".join(errors), file=sys.stderr)
        if result.returncode != 0:
            print(f"Código de saída Godot: {result.returncode}", file=sys.stderr)
            if not errors:
                print("\n".join(output.splitlines()[-40:]), file=sys.stderr)
        fail(f"Godot {label} falhou; consulte o log {log_path}")

    print(f"Godot {label}: OK (log: {log_path})")
    return output


def resolve_godot(explicit: str | None) -> Path:
    candidates: list[Path] = []
    if explicit:
        candidates.append(Path(explicit).expanduser())
    elif os.environ.get("GODOT_BIN"):
        candidates.append(Path(os.environ["GODOT_BIN"]).expanduser())
    candidates.append(PROJECT_ROOT / "Godot_v4.5.1-stable_linux.x86_64")

    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate.resolve()

    in_path = shutil.which("godot")
    if in_path:
        return Path(in_path).resolve()

    fail(
        "Godot 4.5.1 não encontrado. Informe --godot /caminho/Godot_v4.5.1-stable_linux.x86_64 "
        "ou defina GODOT_BIN."
    )


def resolve_java_home(explicit: str | None) -> Path:
    value = explicit or os.environ.get("JAVA_HOME")
    if value:
        java_home = Path(value).expanduser().resolve()
        if (java_home / "bin" / "java").is_file():
            return java_home
        fail(f"JAVA_HOME não aponta para um JDK válido: {java_home}")

    java = shutil.which("java")
    if java:
        resolved = Path(java).resolve()
        if resolved.parent.name == "bin":
            return resolved.parent.parent

    fail("Java/JDK 17 não encontrado. Defina JAVA_HOME para o diretório do JDK.")


def configure_editor_settings(
    godot: Path, android_sdk: Path, java_home: Path, env: dict[str, str], logs_dir: Path
) -> None:
    config_root = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    settings_path = config_root / "godot" / "editor_settings-4.5.tres"
    if not settings_path.is_file():
        run_godot_logged(
            [str(godot), "--headless", "--editor", "--path", str(PROJECT_ROOT), "--quit"],
            env,
            logs_dir / "android-editor-settings.log",
            "EditorSettings initialization",
        )
    if not settings_path.is_file():
        fail(f"Godot não criou o arquivo de configurações esperado: {settings_path}")

    contents = settings_path.read_text(encoding="utf-8")
    values = {
        "export/android/android_sdk_path": str(android_sdk),
        "export/android/java_sdk_path": str(java_home),
    }
    for key, value in values.items():
        line = f"{key} = {json.dumps(value)}"
        pattern = re.compile(rf"(?m)^{re.escape(key)}\s*=.*$")
        if pattern.search(contents):
            contents = pattern.sub(lambda _match, line=line: line, contents, count=1)
        else:
            marker = "[resource]"
            if marker not in contents:
                fail(f"Formato desconhecido em {settings_path}; não encontrei [resource].")
            contents = contents.replace(marker, f"{marker}\n{line}", 1)

    settings_path.write_text(contents, encoding="utf-8")
    print(f"Godot EditorSettings Android SDK: {android_sdk}")
    print(f"Godot EditorSettings Java SDK: {java_home}")


def ensure_debug_keystore(path: Path, java_home: Path) -> None:
    if path.is_file():
        return
    keytool = java_home / "bin" / "keytool"
    if not keytool.is_file():
        fail(f"keytool não encontrado no JDK: {keytool}")
    path.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            str(keytool),
            "-genkeypair",
            "-v",
            "-keystore",
            str(path),
            "-storetype",
            "JKS",
            "-storepass",
            "android",
            "-keypass",
            "android",
            "-alias",
            "androiddebugkey",
            "-keyalg",
            "RSA",
            "-keysize",
            "2048",
            "-validity",
            "10000",
            "-dname",
            "CN=Android Debug,O=Android,C=US",
        ],
        check=True,
    )
    print(f"Keystore debug local criado: {path}")


def validate_apk(apk: Path, android_sdk: Path, env: dict[str, str]) -> None:
    build_tools = android_sdk / "build-tools" / "35.0.0"
    aapt = build_tools / "aapt"
    apksigner = build_tools / "apksigner"
    apkanalyzer = android_sdk / "cmdline-tools" / "latest" / "bin" / "apkanalyzer"
    if not aapt.is_file() or not apksigner.is_file() or not apkanalyzer.is_file():
        fail(f"aapt/apksigner/apkanalyzer não encontrados no SDK: {android_sdk}")

    xmltree = subprocess.run(
        [str(aapt), "dump", "xmltree", str(apk), "AndroidManifest.xml"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    if f'package="{PACKAGE_NAME}"' not in xmltree:
        fail("Package ID inesperado no AndroidManifest.xml (aapt xmltree)")
    orientation = next(
        (line.strip() for line in xmltree.splitlines() if "android:screenOrientation" in line),
        "screenOrientation não encontrado",
    )
    print(f"aapt manifest orientation: {orientation}")
    if "(type 0x10)0x1" not in orientation:
        fail("O AndroidManifest.xml deve declarar portrait (screenOrientation=1)")

    manifest_xml = subprocess.run(
        [str(apkanalyzer), "manifest", "print", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    manifest = ElementTree.fromstring(manifest_xml)
    if manifest.attrib.get("package") != PACKAGE_NAME:
        fail(f"Package ID inesperado no APK: {manifest.attrib.get('package')}")

    app_label = subprocess.run(
        [
            str(apkanalyzer),
            "resources",
            "value",
            "--type",
            "string",
            "--name",
            "godot_project_name_string",
            "--config",
            "default",
            str(apk),
        ],
        check=True,
        capture_output=True,
        text=True,
        env=env,
    ).stdout.strip()
    if app_label != APP_NAME:
        fail(f"Nome incorreto no launcher Android: {app_label!r}; esperado {APP_NAME!r}")
    print(f"Android launcher label: {app_label}")

    uses_permissions = [
        node.tag.rsplit("}", 1)[-1]
        for node in manifest
        if node.tag.rsplit("}", 1)[-1] in ("uses-permission", "uses-permission-sdk-23")
    ]
    if uses_permissions:
        fail("Permissões não aprovadas no APK: " + ", ".join(uses_permissions))
    print(f"Package ID: {PACKAGE_NAME}")
    print("Android permissions: none")

    signing = subprocess.run(
        [str(apksigner), "verify", "--verbose", "--print-certs", str(apk)],
        check=True,
        capture_output=True,
        text=True,
        env=env,
    ).stdout
    print(signing.strip())

    with zipfile.ZipFile(apk) as archive:
        bad_member = archive.testzip()
        if bad_member:
            fail(f"CRC inválido dentro do APK: {bad_member}")
        entries = archive.namelist()
    print(f"APK ZIP integrity: OK ({len(entries)} entries)")
    missing_icons = [path for path in REQUIRED_LAUNCHER_ICONS if path not in entries]
    if missing_icons:
        fail("Ícones do launcher Android ausentes: " + ", ".join(missing_icons))
    print("Android launcher icons: classic, adaptive background/foreground, monochrome")

    exported_files = subprocess.run(
        [str(apkanalyzer), "files", "list", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    leaked = [
        path
        for path in exported_files
        if any(path.startswith(prefix) for prefix in FORBIDDEN_EXPORTED_PATH_PREFIXES)
    ]
    if leaked:
        fail("Recursos excluídos encontrados no APK: " + ", ".join(leaked[:10]))
    missing_runtime_files = [path for path in REQUIRED_RUNTIME_FILES if path not in exported_files]
    if missing_runtime_files:
        fail("Dados de runtime ausentes no APK: " + ", ".join(missing_runtime_files))
    print("Excluded resource paths in APK: none (tools/docs/references/build/dist)")
    print("Runtime JSON: catalogs and first island layout present")


def write_build_info(apk: Path, engine_version: str) -> Path:
    commit = subprocess.run(
        ["git", "rev-parse", "HEAD"],
        cwd=PROJECT_ROOT,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    digest = hashlib.sha256(apk.read_bytes()).hexdigest()
    build_info = {
        "engine": engine_version,
        "source_commit": commit,
        "source_tree": subprocess.check_output(["git", "rev-parse", "HEAD^{tree}"], cwd=PROJECT_ROOT, text=True).strip(),
        "source_dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=PROJECT_ROOT, text=True).strip()),
        "built_at": datetime.now(timezone.utc).isoformat(),
        "target": "Android",
        "package_id": PACKAGE_NAME,
        "apk": apk.name,
        "sha256": digest,
        "data": {
            "status": "candidate",
            "runtime_files": list(REQUIRED_RUNTIME_FILES),
        },
        "art_approval": "candidate; visual review pending",
    }
    sidecar = apk.parent / "BUILD_INFO.json"
    sidecar.write_text(
        json.dumps(build_info, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"SHA256: {digest}")
    print(f"BUILD_INFO: {sidecar}")
    return sidecar


def main() -> None:
    global PACKAGE_NAME, APP_NAME
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        default="build/android/ilha-do-cristal-debug.apk",
        help="APK output path, relative to the repository root by default.",
    )
    parser.add_argument("--godot", help="Godot 4.5.1 executable; can also use GODOT_BIN.")
    parser.add_argument("--sdk", help="Android SDK root; defaults to ANDROID_SDK_ROOT or /opt/android-sdk.")
    parser.add_argument("--parallel-install", action="store_true", help="Export a separate .preview app, preserving existing installs and saves.")
    args = parser.parse_args()
    if args.parallel_install:
        PACKAGE_NAME += ".preview"
        APP_NAME += " — Teste"

    godot = resolve_godot(args.godot)
    version = subprocess.run(
        [str(godot), "--headless", "--version"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if not version.startswith(GODOT_VERSION_PREFIX):
        fail(f"Versão Godot incompatível: {version}; esperado 4.5.1.stable.")
    print(f"Godot: {version}")

    android_sdk = Path(
        args.sdk
        or os.environ.get("ANDROID_SDK_ROOT")
        or os.environ.get("ANDROID_HOME")
        or "/opt/android-sdk"
    ).expanduser().resolve()
    java_home = resolve_java_home(None)
    required = (
        android_sdk / "platform-tools" / "adb",
        android_sdk / "platforms" / "android-35" / "android.jar",
        android_sdk / "build-tools" / "35.0.0" / "aapt",
        android_sdk / "build-tools" / "35.0.0" / "apksigner",
    )
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        fail("Android SDK incompleto; faltam:\n  " + "\n  ".join(missing))

    templates_root = Path(
        os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share")
    ) / "godot" / "export_templates" / "4.5.1.stable"
    if not (templates_root / "android_debug.apk").is_file():
        fail(f"Template Android 4.5.1 não encontrado: {templates_root / 'android_debug.apk'}")

    env = os.environ.copy()
    env["JAVA_HOME"] = str(java_home)
    env["ANDROID_SDK_ROOT"] = str(android_sdk)
    env["ANDROID_HOME"] = str(android_sdk)
    env["PATH"] = os.pathsep.join(
        [
            str(java_home / "bin"),
            str(android_sdk / "platform-tools"),
            str(android_sdk / "build-tools" / "35.0.0"),
            env.get("PATH", ""),
        ]
    )

    keystore = Path(
        env.get(
            "GODOT_ANDROID_KEYSTORE_DEBUG_PATH",
            str(Path.home() / ".local" / "share" / "godot" / "keystores" / "debug.keystore"),
        )
    ).expanduser().resolve()
    ensure_debug_keystore(keystore, java_home)
    env.setdefault("GODOT_ANDROID_KEYSTORE_DEBUG_PATH", str(keystore))
    env.setdefault("GODOT_ANDROID_KEYSTORE_DEBUG_USER", "androiddebugkey")
    env.setdefault("GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD", "android")

    build_dir = PROJECT_ROOT / "build"
    build_dir.mkdir(parents=True, exist_ok=True)
    logs_dir = build_dir / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)
    (build_dir / ".gdignore").write_text(
        "# Local exports and logs; keep outside Godot's project scan.\n", encoding="utf-8"
    )
    configure_editor_settings(godot, android_sdk, java_home, env, logs_dir)
    run_godot_logged(
        [str(godot), "--headless", "--editor", "--path", str(PROJECT_ROOT), "--import", "--quit"],
        env=env,
        log_path=logs_dir / "android-import.log",
        label="resource import",
    )

    output = Path(args.output).expanduser()
    if not output.is_absolute():
        output = PROJECT_ROOT / output
    output = output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    preset_path = PROJECT_ROOT / "export_presets.cfg"
    original_preset = preset_path.read_text(encoding="utf-8")
    if args.parallel_install:
        preview_preset = original_preset.replace(
            'package/unique_name="com.fabiofsjunior.ilhadocristal"',
            f'package/unique_name="{PACKAGE_NAME}"',
        ).replace('package/name="A Ilha do Cristal"', f'package/name="{APP_NAME}"')
        preset_path.write_text(preview_preset, encoding="utf-8")
    try:
        run_godot_logged(
            [
                str(godot),
                "--headless",
                "--path",
                str(PROJECT_ROOT),
                "--export-debug",
                PRESET_NAME,
                str(output),
            ],
            env=env,
            log_path=logs_dir / "android-export.log",
            label="Android export",
        )
    finally:
        if args.parallel_install:
            preset_path.write_text(original_preset, encoding="utf-8")
    if not output.is_file() or output.stat().st_size == 0:
        fail(f"Godot não produziu o APK: {output}")

    print(f"APK: {output} ({output.stat().st_size:,} bytes)")
    validate_apk(output, android_sdk, env)
    write_build_info(output, version)


if __name__ == "__main__":
    main()
