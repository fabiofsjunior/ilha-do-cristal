#!/usr/bin/env python3
"""Serve the exported Godot Web build on loopback and opens its browser URL."""

from __future__ import annotations

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import threading
import time
import urllib.error
import urllib.request
import webbrowser


PROJECT_ROOT = Path(__file__).resolve().parents[2]
WEB_DIR = PROJECT_ROOT / "build" / "web"
REQUIRED_FILES = ("index.html", "index.js", "index.wasm", "index.pck")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="porta HTTP inicial (se ocupada, escolhe uma porta livre)",
    )
    parser.add_argument(
        "--no-browser",
        action="store_true",
        help="inicia o servidor sem abrir o navegador automaticamente",
    )
    return parser.parse_args()


def check_build() -> None:
    if not WEB_DIR.is_dir():
        raise SystemExit(
            f"Build Web não encontrada: {WEB_DIR}\n"
            "Exporte primeiro com o preset Web para build/web/."
        )

    missing = [name for name in REQUIRED_FILES if not (WEB_DIR / name).is_file()]
    if missing:
        raise SystemExit(
            "Build Web incompleta. Arquivos ausentes: " + ", ".join(missing) + "\n"
            "Exporte novamente com o preset Web para build/web/."
        )


def create_server(port: int) -> ThreadingHTTPServer:
    handler = partial(SimpleHTTPRequestHandler, directory=str(WEB_DIR))
    try:
        return ThreadingHTTPServer(("127.0.0.1", port), handler)
    except OSError as error:
        if port == 0:
            raise
        print(f"A porta {port} está ocupada; vou selecionar outra.", flush=True)
        try:
            return ThreadingHTTPServer(("127.0.0.1", 0), handler)
        except OSError:
            raise error


def wait_until_ready(url: str) -> bool:
    for _ in range(40):
        try:
            with urllib.request.urlopen(url, timeout=1) as response:
                if response.status == 200:
                    return True
        except (OSError, urllib.error.URLError):
            time.sleep(0.1)
    return False


def main() -> int:
    args = parse_args()
    check_build()

    server = create_server(args.port)
    url = f"http://127.0.0.1:{server.server_port}/"
    server_thread = threading.Thread(target=server.serve_forever, daemon=True)
    server_thread.start()

    try:
        if not wait_until_ready(url):
            print(f"O servidor iniciou, mas não respondeu em {url}", flush=True)
            return 1

        print(f"Jogo Web: {url}", flush=True)
        if not args.no_browser and not webbrowser.open(url, new=2):
            print("Não consegui abrir o navegador automaticamente.", flush=True)
            print(f"Acesse manualmente: {url}", flush=True)
        print("Servidor ativo. Pressione Ctrl+C para encerrar.", flush=True)
        server_thread.join()
        return 0
    except KeyboardInterrupt:
        print("\nServidor encerrado.", flush=True)
        return 0
    finally:
        server.shutdown()
        server.server_close()
        server_thread.join(timeout=2)


if __name__ == "__main__":
    raise SystemExit(main())
