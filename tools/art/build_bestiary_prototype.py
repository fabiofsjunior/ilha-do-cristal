#!/usr/bin/env python3
"""Build the self-contained bestiary review page from the catalog."""

from __future__ import annotations

import html
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data/catalogs/mvp.json"
OUTPUT = ROOT / "docs/prototypes/bestiary_expansion_30_v0_2.html"


def region_suggestions(regions: dict[str, dict], monsters: list[dict]) -> str:
    groups = []
    for region_id, region in regions.items():
        assigned = [monster for monster in monsters if monster["region"] == region_id]
        if not assigned:
            continue
        names = "".join(f"<li>{html.escape(monster['name'])}</li>" for monster in assigned)
        groups.append(
            f'<article class="region-group"><h3>{html.escape(region["name"])}</h3>'
            f'<p>{len(assigned)} espécies sugeridas</p><ul>{names}</ul></article>'
        )
    return (
        '<section class="region-panel"><div class="region-copy"><p class="kicker">ALOCAÇÃO SUGERIDA</p>'
        '<h2>Região recomendada por espécie</h2>'
        '<p>Estas são recomendações para a integração do mapa. Coordenadas e quantidade de spawns ficam para a atualização do mapa.</p>'
        f'</div><div class="region-groups">{"".join(groups)}</div></section>'
    )


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    region_map = {entry["id"]: entry for entry in catalog["regions"]}
    card_rows = []
    region_counts = {region_id: sum(1 for monster in catalog["monsters"] if monster["region"] == region_id) for region_id in region_map}
    for index, monster in enumerate(catalog["monsters"], 1):
        region_id = monster["region"]
        region = region_map[region_id]["name"]
        image = "../../" + monster["sprite_path"]
        behavior = {
            "flee_only": "Foge · não ataca",
            "skittish": "Foge · revida se atacada",
            "aggressive": "Persegue e ataca",
        }.get(monster.get("behavior", "aggressive"), "Persegue e ataca")
        loot = "sem loot definido" if not monster["drops"] else "loot configurado"
        card_rows.append(
            f'<article class="card" data-region="{html.escape(region_id)}">'
            f'<div class="portrait"><img src="{html.escape(image)}" alt="Sprite estático de {html.escape(monster["name"])}" loading="lazy"></div>'
            f'<div class="details"><div class="card-top"><span>FICHA {index:02}</span><small>REGIÃO SUGERIDA</small></div>'
            f'<h3>{html.escape(monster["name"])}</h3><p class="region">{html.escape(region)}</p>'
            f'<div class="stats"><div><small>HP</small><b>{monster["hp"]}</b></div>'
            f'<div><small>DANO / GOLPE</small><b>{monster["attack"]}</b></div><div><small>XP</small><b>{monster["xp"]}</b></div></div>'
            f'<p class="behavior">{html.escape(behavior)} · {html.escape(loot)}</p>'
            f'<a href="{html.escape(image)}">PNG individual · pose SE</a></div></article>'
        )
    filters = ['<button class="active" data-filter="all">Todas (30)</button>']
    for region_id, region in region_map.items():
        if region_counts[region_id]:
            filters.append(
                f'<button data-filter="{html.escape(region_id)}">{html.escape(region["name"])} '
                f'({region_counts[region_id]})</button>'
            )
    region_html = region_suggestions(region_map, catalog["monsters"])

    page = f'''<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Prancha estática e distribuição regional do bestiário de A Ilha do Cristal.">
  <title>A Ilha do Cristal — Bestiário v0.2</title>
  <style>
    :root {{ color-scheme: dark; --ink:#241b14; --paper:#f1e3bf; --edge:#211914; --teal:#72d0cf; }}
    * {{ box-sizing:border-box; }}
    body {{ margin:0; min-height:100vh; background:radial-gradient(ellipse at 50% -10%,#52675b 0,#273a33 46%,#151f1d 100%); color:#f5e8c9; font:15px/1.4 "Trebuchet MS",system-ui,sans-serif; }}
    .shell {{ width:min(1320px,100%); margin:auto; padding:25px 20px 42px; }}
    .banner {{ border:4px solid var(--edge); outline:2px solid #c9a867; background:linear-gradient(#f5ebd0,#ddc99b); color:var(--ink); box-shadow:0 8px 0 #201512,0 14px 28px #0e171499; padding:22px 24px 20px; text-align:center; }}
    .eyebrow {{ text-transform:uppercase; letter-spacing:.18em; font-size:11px; color:#775839; font-weight:800; }}
    h1 {{ margin:5px 0 3px; font:700 clamp(28px,5vw,44px)/1 Georgia,serif; }}
    .subtitle {{ margin:10px 0 0; color:#59422c; }}
    .status {{ display:inline-block; margin-top:13px; padding:5px 9px; border:2px solid #634829; background:#fff3ce; color:#54391c; font-size:11px; font-weight:900; letter-spacing:.08em; text-transform:uppercase; }}
    .summary {{ display:flex; flex-wrap:wrap; justify-content:center; gap:10px; margin:21px 0 18px; }}
    .summary span {{ padding:7px 12px; background:#18251fdd; border:2px solid #93a187; box-shadow:3px 3px 0 #0d1713; font-size:13px; }}
    .region-panel {{ display:grid; grid-template-columns:minmax(210px,280px) minmax(0,1fr); gap:18px; align-items:start; margin:14px 0 22px; padding:18px; border:3px solid #171511; outline:1px solid #d5b873; background:#17241fe8; box-shadow:4px 5px 0 #101a16; }}
    .region-copy h2 {{ margin:3px 0 6px; font:700 23px Georgia,serif; color:#f2dfb1; }}
    .region-copy p {{ margin:7px 0; color:#cdd5c2; font-size:13px; }} .kicker {{ letter-spacing:.15em; font-size:10px!important; font-weight:900; color:#89cfbd!important; }}
    .region-groups {{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:9px; }}
    .region-group {{ padding:9px; border:1px solid #687963; background:#1d3029; }}
    .region-group h3 {{ margin:0; color:#f2dfb1; font:700 15px Georgia,serif; }} .region-group p {{ margin:4px 0 6px; color:#89cfbd; font-size:10px; }}
    .region-group ul {{ display:grid; gap:3px; margin:0; padding-left:15px; color:#e9e3ca; font-size:11px; }}
    .filters {{ display:flex; flex-wrap:wrap; justify-content:center; gap:8px; margin:19px 0 16px; }}
    button {{ cursor:pointer; border:3px solid var(--edge); background:#dfc998; color:var(--ink); padding:8px 12px; font:inherit; font-weight:700; font-size:12px; box-shadow:3px 3px 0 #101a16; }}
    button:hover, button.active {{ background:#9fd4c4; transform:translateY(-1px); }}
    .grid {{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:12px; }}
    .card {{ display:grid; grid-template-columns:102px 1fr; gap:13px; min-height:167px; padding:11px; border:3px solid var(--edge); outline:1px solid #d5b873; background:linear-gradient(155deg,#f7ebca,#e5d2a4); color:var(--ink); box-shadow:4px 5px 0 #101a16; }}
    .portrait {{ display:grid; place-items:center; align-self:start; min-height:102px; border:3px solid #563b2b; background-color:#d7c99e; background-image:linear-gradient(45deg,#baab7e 25%,transparent 25%,transparent 75%,#baab7e 75%),linear-gradient(45deg,#baab7e 25%,transparent 25%,transparent 75%,#baab7e 75%); background-position:0 0,8px 8px; background-size:16px 16px; image-rendering:pixelated; }}
    .portrait img {{ display:block; width:92px; height:92px; object-fit:contain; image-rendering:pixelated; }}
    .details {{ min-width:0; }} .card-top {{ display:flex; align-items:center; justify-content:space-between; gap:7px; color:#725a3e; font-size:10px; font-weight:900; }}
    .card-top small {{ padding:2px 5px; border:1px solid #876c47; background:#fff2cf; font-size:9px; }}
    h3 {{ margin:4px 0 1px; font:700 18px/1.1 Georgia,serif; }} .region {{ margin:1px 0 6px; color:#6a5237; font-size:11px; font-weight:700; }}
    .stats {{ display:grid; grid-template-columns:repeat(3,1fr); gap:5px; }} .stats div {{ padding:4px 5px; border:1px solid #9c825b; background:#f9efda; }}
    .stats small {{ display:block; color:#67553d; font-size:8px; font-weight:900; }} .stats b {{ display:block; font:700 16px Georgia,serif; color:#39251a; }}
    .behavior {{ margin:6px 0 2px; color:#54412e; font-size:10px; }} .details a {{ color:#28645f; font-size:10px; font-weight:800; }}
    .footer {{ margin-top:23px; padding:16px 18px; border:3px solid var(--edge); background:#17231fe8; color:#eee0c2; }}
    .footer h2 {{ margin:0 0 8px; color:#e7cc8d; font:700 19px Georgia,serif; }} .footer p {{ margin:8px 0; color:#d5d0bc; font-size:13px; }}
    .footer a {{ color:#90d5d3; }} .note {{ color:#aeb8a6!important; font-size:12px!important; }}
    @media (max-width:1040px) {{ .grid {{ grid-template-columns:repeat(2,minmax(0,1fr)); }} }}
    @media (max-width:1040px) {{ .region-groups {{ grid-template-columns:repeat(2,minmax(0,1fr)); }} }}
    @media (max-width:760px) {{ .region-panel {{ grid-template-columns:1fr; }} }}
    @media (max-width:580px) {{ .shell {{ padding:15px 11px 26px; }} .grid {{ grid-template-columns:1fr; }} .card {{ grid-template-columns:84px 1fr; }} .portrait {{ min-height:84px; }} .portrait img {{ width:76px;height:76px; }} .banner {{ padding:17px 12px; }} .region-panel {{ padding:12px; }} .region-groups {{ grid-template-columns:1fr; }} }}
  </style>
</head>
<body>
  <main class="shell">
    <header class="banner">
      <div class="eyebrow">A Ilha do Cristal · conteúdo integrado</div>
      <h1>Bestiário da Ilha</h1>
      <p class="subtitle">30 fichas com prévias estáticas e recomendação regional por espécie.</p>
      <span class="status">Arte conceitual · pose estática SE · valores provisórios</span>
    </header>
    <section class="summary" aria-label="Resumo">
      <span><strong>30</strong> espécies</span><span><strong>{sum(bool(count) for count in region_counts.values())}</strong> regiões sugeridas</span>
      <span>HP, dano e XP para playtest</span><span>Posições ficam para a atualização do mapa</span>
    </section>
    {region_html}
    <nav class="filters" aria-label="Filtrar fichas por região">{"".join(filters)}</nav>
    <section class="grid" id="cards" aria-live="polite">{"".join(card_rows)}</section>
    <aside class="footer">
      <h2>Sprites e estado do conteúdo</h2>
      <p>As 30 imagens são recortes individuais da prancha original do projeto, 229×229 px com canal alpha preservado. Cada criatura tem uma pose estática SE, pivô e escala em metadata; não há animações nem direções adicionais.</p>
      <p>As fontes gratuitas foram pesquisadas como referências: <a href="https://opengameart.org/content/denzis-public-domain-art">DENZI CC0</a>, <a href="https://opengameart.org/node/160872">Tiny Creatures CC0</a> e <a href="https://opengameart.org/content/crab">Crab CC0</a>. Os sprites integrados são concepts originais; esses pacotes não foram incorporados.</p>
      <p class="note">Regiões sugeridas não definem coordenadas nem quantidade de spawns; a integração das posições fica para a atualização do mapa. Lagoa, ruínas e terras corrompidas são grupos conceituais sobre o terreno atual. As fichas novas não têm drops definidos. Ver o <a href="../art/candidates/BESTIARY_EXPANSION_30_V0_2.md">índice de proposta</a> e a <a href="../../Docs/art/candidates/BESTIARY_STATIC_CONCEPTS_30_V0_1.md">ordem da prancha</a>.</p>
    </aside>
  </main>
  <script>
    document.querySelectorAll(".filters button").forEach(button => button.addEventListener("click", () => {{
      document.querySelectorAll(".filters button").forEach(item => item.classList.remove("active"));
      button.classList.add("active");
      const filter = button.dataset.filter;
      document.querySelectorAll("#cards .card").forEach(card => {{ card.hidden = filter !== "all" && card.dataset.region !== filter; }});
    }}));
  </script>
</body>
</html>
'''
    OUTPUT.write_text(page, encoding="utf-8")
    print(f"Updated {OUTPUT.relative_to(ROOT)} with {len(card_rows)} fichas and {sum(count > 0 for count in region_counts.values())} region suggestions.")


if __name__ == "__main__":
    main()

