#!/usr/bin/env python3
"""Regenerate and verify the offline wiki, its links, data, and local HTTP serving."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urljoin


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
    assert len(catalog["monsters"]) == 30, "expected 30 bestiary records"
    assert len({entry["id"] for entry in catalog["monsters"]}) == 30, "monster IDs must be unique"
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

    node = subprocess.run(["node", "--version"], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip()
    subprocess.run(["node", "--check", str(WIKI / "app.js")], cwd=ROOT, check=True)
    subprocess.run(["node", "--check", str(ROOT / "tools/wiki/serve.js")], cwd=ROOT, check=True)
    subprocess.run(["node", str(ROOT / "tools/wiki/test_runtime.js")], cwd=ROOT, check=True)

    server = subprocess.Popen(
        ["node", str(ROOT / "tools/wiki/serve.js"), "--port", "0", "--no-browser"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    try:
        startup_line = server.stdout.readline() if server.stdout else ""
        base_url = startup_line.replace("Wiki do projeto: ", "").strip()
        if not base_url.startswith("http://127.0.0.1:") or not base_url.endswith("/docs/wiki/"):
            remainder = server.communicate(timeout=5)[0]
            raise AssertionError(f"Node wiki server failed to start: {startup_line}{remainder}")
        root_url = base_url.replace("/docs/wiki/", "/")

        with urllib.request.urlopen(root_url, timeout=5) as response:
            if response.status != 200 or not response.geturl().endswith("/docs/wiki/"):
                raise AssertionError("root URL did not redirect to the wiki")

        test_urls = [
            "index.html",
            "catalog-data.json",
            "wiki.css",
            "app.js",
            "../../README.md",
            "../../Docs/Main/GDD_MVP.md",
            payload["assets"][0]["href"],
            next(asset["href"] for asset in payload["assets"] if asset["group"] == "creatures"),
        ]
        for target in test_urls:
            request_url = urljoin(base_url, target)
            with urllib.request.urlopen(request_url, timeout=5) as response:
                body = response.read()
                if response.status != 200 or not body:
                    raise AssertionError(f"Node server failed to serve {target}")
                if target.endswith("catalog-data.json"):
                    served = json.loads(body)
                    assert len(served["catalog"]["skills"]) == 9
                if target.endswith("README.md") and not response.headers.get("Content-Type", "").startswith("text/markdown"):
                    raise AssertionError("README did not return a Markdown content type")

        png_url = urljoin(base_url, next(asset["href"] for asset in payload["assets"] if asset["group"] == "creatures"))
        with urllib.request.urlopen(png_url, timeout=5) as response:
            if not response.headers.get("Content-Type", "").startswith("image/png"):
                raise AssertionError("sprite preview did not return an image/png response")
        for private_url in (root_url + ".git/config", root_url + "build/"):
            try:
                urllib.request.urlopen(private_url, timeout=5)
            except urllib.error.HTTPError as error:
                if error.code != 403:
                    raise AssertionError(f"private path returned HTTP {error.code}, expected 403") from error
            else:
                raise AssertionError(f"private path was served: {private_url}")

        try:
            urllib.request.urlopen(urllib.request.Request(root_url + "README.md", method="POST"), timeout=5)
        except urllib.error.HTTPError as error:
            if error.code != 405:
                raise AssertionError(f"POST returned HTTP {error.code}, expected 405") from error
        else:
            raise AssertionError("server accepted an unsupported POST request")

        head_request = urllib.request.Request(urljoin(base_url, "index.html"), method="HEAD")
        with urllib.request.urlopen(head_request, timeout=5) as response:
            if response.status != 200 or not response.headers.get("Content-Type", "").startswith("text/html"):
                raise AssertionError("HEAD request failed for the wiki home page")
    finally:
        if server.poll() is None:
            server.terminate()
        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait(timeout=5)

    print(
        "PASS wiki: 4 aparências, 3 vocações, 9 skills; "
        f"{len(payload['assets'])} prévias; {len(payload['files'])} arquivos; "
        f"servidor Node.js {node} abre a wiki, serve links/imagens e bloqueia pastas privadas."
    )


if __name__ == "__main__":
    run()
