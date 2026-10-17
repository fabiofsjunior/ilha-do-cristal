#!/usr/bin/env python3
"""Regenerate and verify the offline wiki, its links, data, and local HTTP serving."""

from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
import threading
import urllib.request
from html.parser import HTMLParser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urljoin, urlsplit


ROOT = Path(__file__).resolve().parents[2]
WIKI = ROOT / "docs" / "wiki"


class MarkupProbe(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: list[str] = []
        self.local_refs: list[str] = []
        self.external_scripts: list[str] = []
        self.meta_names: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.append(values["id"] or "")
        if tag == "meta" and values.get("name"):
            self.meta_names.append(values["name"] or "")
        for attr in ("href", "src"):
            ref = values.get(attr)
            if ref and not ref.startswith(("#", "data:", "mailto:", "http://", "https://")):
                self.local_refs.append(ref)
        if tag == "script" and values.get("src", "").startswith(("http://", "https://")):
            self.external_scripts.append(values["src"] or "")


def assert_exists(relative: str) -> None:
    path = (WIKI / unquote(relative)).resolve()
    if ROOT not in path.parents and path != ROOT:
        raise AssertionError(f"link escapes repository: {relative}")
    if not path.exists():
        raise AssertionError(f"missing local link target: {relative} -> {path.relative_to(ROOT)}")


def run() -> None:
    subprocess.run([sys.executable, str(ROOT / "tools/wiki/build_index.py")], cwd=ROOT, check=True)

    generated_bytes = (WIKI / "catalog-data.json").read_bytes()
    subprocess.run([sys.executable, str(ROOT / "tools/wiki/build_index.py")], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    if generated_bytes != (WIKI / "catalog-data.json").read_bytes():
        raise AssertionError("index generation is not reproducible")
    payload = json.loads(generated_bytes)
    catalog = payload["catalog"]
    assert len(catalog["characters"]) == 4, "expected all four character records"
    assert len(catalog["vocations"]) == 3, "expected all three vocation records"
    assert len(catalog["skills"]) == 9, "expected all nine planned skills"
    assert {entry["id"] for entry in catalog["monsters"]} == {"fox", "wolf", "bear"}
    assert len(payload["assets"]) >= 25, "sprite/atlas previews were not indexed"
    assert len(payload["files"]) >= 100, "repository file index is unexpectedly small"

    # Every generated repository target must exist and remain a relative, in-repo URL.
    for entry in payload["files"] + payload["assets"] + payload["documentation"]:
        assert entry["href"].startswith("../../"), f"non-relative link for {entry['path']}"
        assert (ROOT / entry["path"]).is_file(), f"indexed path is missing: {entry['path']}"
        resolved = (WIKI / unquote(entry["href"])).resolve()
        assert ROOT in resolved.parents, f"URL escapes repository: {entry['href']}"
        assert resolved == (ROOT / entry["path"]).resolve(), f"URL points to wrong file: {entry['href']}"

    html = (WIKI / "index.html").read_text(encoding="utf-8")
    css = (WIKI / "wiki.css").read_text(encoding="utf-8")
    js = (WIKI / "app.js").read_text(encoding="utf-8")
    probe = MarkupProbe()
    probe.feed(html)
    probe.close()
    if len(probe.ids) != len(set(probe.ids)):
        raise AssertionError("duplicate HTML id attributes")
    if "viewport" not in probe.meta_names or not {"content", "section-nav", "global-search", "lightbox"}.issubset(set(probe.ids)):
        raise AssertionError("required viewport, search, navigation, or preview markup is missing")
    for ref in probe.local_refs:
        assert_exists(ref)
    if probe.external_scripts or re.search(r"https?://|@import", css, re.I) or "https://" in js:
        raise AssertionError("offline wiki includes an external dependency")
    if not re.search(r"@media\s*\(max-width:\s*780px\)", css) or not re.search(r"@media\s*\(max-width:\s*520px\)", css):
        raise AssertionError("responsive breakpoints for tablet and mobile are missing")

    node = shutil.which("node")
    if not node:
        raise AssertionError("Node.js is required for the JavaScript syntax check")
    subprocess.run([node, "--check", str(WIKI / "app.js")], cwd=ROOT, check=True)
    subprocess.run([node, str(ROOT / "tools/wiki/test_runtime.js")], cwd=ROOT, check=True)

    class QuietHandler(SimpleHTTPRequestHandler):
        def log_message(self, _format: str, *_args: object) -> None:
            return

    server = ThreadingHTTPServer(("127.0.0.1", 0), lambda *args, **kwargs: QuietHandler(*args, directory=str(ROOT), **kwargs))
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    base_url = f"http://127.0.0.1:{server.server_port}/docs/wiki/"
    try:
        test_urls = [
            "index.html",
            "catalog-data.json",
            "wiki.css",
            "app.js",
            payload["assets"][0]["href"],
            next(asset["href"] for asset in payload["assets"] if asset["group"] == "creatures"),
        ]
        for target in test_urls:
            request_url = urljoin(base_url, target)
            with urllib.request.urlopen(request_url, timeout=5) as response:
                body = response.read()
                if response.status != 200 or not body:
                    raise AssertionError(f"local server failed to serve {target}")
                if target.endswith("catalog-data.json"):
                    served = json.loads(body)
                    assert len(served["catalog"]["skills"]) == 9
        # Confirm the preview URL resolves to a PNG, not just a path that happens to exist.
        png_url = urljoin(base_url, next(asset["href"] for asset in payload["assets"] if asset["group"] == "creatures"))
        with urllib.request.urlopen(png_url, timeout=5) as response:
            if not response.headers.get("Content-Type", "").startswith("image/png"):
                raise AssertionError("sprite preview did not return an image/png response")
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=2)

    print(
        "PASS wiki: 4 aparências, 3 vocações, 9 skills; "
        f"{len(payload['assets'])} prévias; {len(payload['files'])} arquivos; "
        "links verificados, JavaScript válido e servidor HTTP local respondendo."
    )


if __name__ == "__main__":
    run()
