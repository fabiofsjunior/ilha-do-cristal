#!/usr/bin/env python3
"""Generate a reproducible, hard-edged 32 px candidate terrain atlas for A Ilha do Cristal.

Art brief/prompt: RPG Clássico 2D, top-down slightly oblique on an orthogonal grid;
warm readable beach/spawn, forest and inland ground, small deliberate pixel clusters,
no antialiasing, no characters/props, no engine/gameplay claims. 32x32 is a scale
candidate only; it must be tested against an in-game SQM before it is fixed.

No source art is overwritten. Pillow draws at native 32 px with integer coordinates.
"""
from __future__ import annotations
import argparse, json, hashlib, random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

CELL = 32
COLS = 8
SEED = 20261015
OUT_ATLAS = "assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.png"
OUT_MANIFEST = "assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.json"
OUT_CONTACT = "docs/art/evidence/terrain/terrain_mvp_candidate_v1_contact.png"
OUT_SAMPLE = "docs/art/evidence/terrain/terrain_mvp_candidate_v1_sample.png"

PALETTES = {
    "water_deep": ["#244a64", "#2f6178", "#367489", "#18394f"],
    "water_shallow": ["#3e7e8b", "#4e929b", "#72a9a6", "#326b79"],
    "sand": ["#d4b46c", "#e4ca83", "#f0d999", "#b99555", "#cba961"],
    "grass": ["#587b45", "#6e914e", "#87a75c", "#3d653d", "#a3b76a"],
    "forest": ["#587b45", "#456e4b", "#628354", "#294d3b", "#79915b"],
    "soil": ["#76583f", "#8a6746", "#a17a50", "#624736", "#b18a5c"],
    "shore_foam": ["#d7e2c0", "#bfd3b3", "#f1e5b6"],
    "edge_sand_grass": ["#c9a962", "#d9bc74", "#64864a"],
    "edge_grass_soil": ["#426743", "#6b874e", "#806043"],
    "path": ["#70513c", "#8c6949", "#a27b56", "#5b4436", "#b58b60"],
}

def rgba(color):
    return tuple(bytes.fromhex(color.lstrip("#"))) + (255,)

def seeded(tile_id):
    return random.Random(SEED + sum((i + 1) * ord(ch) for i, ch in enumerate(tile_id)))

def speckles(img, tile_id, palette, count, region=(5, 5, 26, 26), sizes=(1, 2, 3)):
    d = ImageDraw.Draw(img)
    r = seeded(tile_id)
    x0, y0, x1, y1 = region
    colors = [rgba(c) for c in palette]
    for _ in range(count):
        x, y = r.randint(x0, x1), r.randint(y0, y1)
        w, h = r.choice(sizes), r.choice(sizes)
        c = r.choice(colors)
        d.rectangle((x, y, min(x + w - 1, x1), min(y + h - 1, y1)), fill=c)

def base_tile(kind, variant, tile_id):
    palettes = PALETTES[kind]
    img = Image.new("RGBA", (CELL, CELL), rgba(palettes[0]))
    d = ImageDraw.Draw(img)
    if kind.startswith("water"):
        # Low-noise, pixel-stepped ripples, kept away from all tile borders for repeat.
        r = seeded(tile_id)
        for i in range(4):
            x = r.randint(5, 22); y = r.randint(5, 24)
            w = r.choice((4, 5, 6, 7)); c = rgba(palettes[1 + (i + variant) % 2])
            d.rectangle((x, y, min(x + w, 27), y), fill=c)
            d.rectangle((x + 1, y + 1, min(x + w - 1, 27), y + 1), fill=c)
        if kind == "water_shallow":
            d.rectangle((7, 13, 11, 14), fill=rgba(palettes[2]))
            d.rectangle((21, 21, 25, 22), fill=rgba(palettes[2]))
    elif kind == "sand":
        speckles(img, tile_id, palettes[1:], 10, sizes=(1, 2, 2))
        d = ImageDraw.Draw(img)
        if variant == 1:
            d.rectangle((9, 7, 12, 7), fill=rgba(palettes[2]))
            d.rectangle((19, 22, 22, 22), fill=rgba(palettes[2]))
        elif variant == 2:
            d.rectangle((7, 20, 10, 21), fill=rgba(palettes[3]))
            d.rectangle((20, 8, 24, 9), fill=rgba(palettes[2]))
    elif kind == "grass":
        r = seeded(tile_id)
        for _ in range(7):
            x, y = r.randint(5, 24), r.randint(5, 24)
            c = rgba(palettes[r.choice((1, 2, 4))])
            d.rectangle((x, y, x + 1, y), fill=c)
            d.rectangle((x + 1, y - 1, x + 1, y - 1), fill=c)
        speckles(img, tile_id + "g", [palettes[3]], 3, sizes=(1, 2))
    elif kind == "forest":
        r = seeded(tile_id)
        for _ in range(6):
            x, y = r.randint(5, 24), r.randint(5, 24)
            c = rgba(palettes[r.choice((1, 2, 4))])
            d.rectangle((x, y, x + 2, y), fill=c)
            d.rectangle((x + 1, y + 1, x + 2, y + 1), fill=c)
        speckles(img, tile_id + "f", [palettes[3]], 4, sizes=(1, 2))
    elif kind == "soil":
        speckles(img, tile_id, palettes[1:], 10, sizes=(1, 2, 3))
        d = ImageDraw.Draw(img)
        if variant == 2:
            d.rectangle((7, 11, 11, 12), fill=rgba(palettes[2]))
            d.rectangle((20, 21, 23, 22), fill=rgba(palettes[4]))
    return img

def mirror_xy(pt, mx, my):
    x, y = pt
    return (CELL - 1 - x if mx else x, CELL - 1 - y if my else y)

def transition_edge(name, north_material, south_material, palettes, seam):
    """A one-cell connector: upper/lower halves meet in a crisp 2 px stepped boundary."""
    a = base_tile(north_material, 0, name + "_a")
    b = base_tile(south_material, 0, name + "_b")
    img = a.copy()
    # Put the upper material on its side, lower on opposite side.
    for y in range(16, CELL):
        for x in range(CELL): img.putpixel((x, y), b.getpixel((x, y)))
    d = ImageDraw.Draw(img)
    # coherent 1 px staircase band, stable across variants
    boundary = [15, 15, 16, 16, 15, 15, 16, 16] * 4
    for x, y in enumerate(boundary[:CELL]):
        c = rgba(seam[(x // 5) % len(seam)])
        d.point((x, y), fill=c)
    return img

def orient_edge(material_a, material_b, direction, edge_palette, foam=False, tile_id=""):
    # Start with material_a, then draw material_b in one half. N means B on north.
    img = base_tile(material_a, 0, tile_id + "_a")
    other = base_tile(material_b, 1, tile_id + "_b")
    mask = Image.new("1", (CELL, CELL), 0); md = ImageDraw.Draw(mask)
    if direction == "N": md.rectangle((0, 0, 31, 15), fill=1)
    elif direction == "S": md.rectangle((0, 16, 31, 31), fill=1)
    elif direction == "E": md.rectangle((16, 0, 31, 31), fill=1)
    else: md.rectangle((0, 0, 15, 31), fill=1)
    img.paste(other, (0, 0), mask)
    d = ImageDraw.Draw(img)
    # A small stepped 2-color transition line crossing the full tile width/height.
    if direction in ("N", "S"):
        y0 = 15 if direction == "N" else 16
        for x in range(CELL):
            step = ((x // 4) % 2)
            for dy in range(2):
                y = y0 + step + dy
                if 0 <= y < CELL:
                    col = edge_palette[(x // 5 + dy) % len(edge_palette)]
                    d.point((x, y), fill=rgba(col))
    else:
        x0 = 16 if direction == "E" else 15
        for y in range(CELL):
            step = ((y // 4) % 2)
            for dx in range(2):
                x = x0 + step + dx
                if 0 <= x < CELL:
                    col = edge_palette[(y // 5 + dx) % len(edge_palette)]
                    d.point((x, y), fill=rgba(col))
    if foam:
        # Foam highlights occupy same transition stripe, not softened/alpha-blended.
        if direction in ("N", "S"):
            y = 14 if direction == "N" else 17
            for x in range(3, 30, 7):
                d.rectangle((x, y, x + 2, y), fill=rgba(edge_palette[0]))
        else:
            x = 17 if direction == "E" else 14
            for y in range(3, 30, 7):
                d.rectangle((x, y, x, y + 2), fill=rgba(edge_palette[0]))
    return img

def corner_transition(material_base, material_corner, corner, edge_palette, foam=False, tile_id=""):
    img = base_tile(material_base, 0, tile_id + "_base")
    patch = base_tile(material_corner, 1, tile_id + "_corner")
    # L-shaped, stair-stepped coastline/biome boundary from the corner inward.
    # Define the corner mask at top-left, mirror for other corners.
    points = [(0,0),(13,0),(13,4),(9,4),(9,8),(5,8),(5,12),(0,12)]
    corner_masks = {
        "NW": (False, False), "NE": (True, False),
        "SW": (False, True), "SE": (True, True),
    }
    mx, my = corner_masks[corner]
    pts = [mirror_xy(p, mx, my) for p in points]
    mask = Image.new("1", (CELL,CELL), 0); ImageDraw.Draw(mask).polygon(pts, fill=1)
    img.paste(patch, (0,0), mask)
    # Crisp dashes along the stepped edge, transformed with the corner orientation.
    d = ImageDraw.Draw(img)
    for i,(x,y) in enumerate([(13,2),(11,5),(7,9),(3,12)]):
        q1=mirror_xy((x,y),mx,my); q2=mirror_xy((x+1,y),mx,my)
        d.line((q1,q2),fill=rgba(edge_palette[i % len(edge_palette)]),width=1)
    return img

def overlay_path(kind, variant, tile_id):
    img = Image.new("RGBA", (CELL,CELL), (0,0,0,0))
    d = ImageDraw.Draw(img)
    # masks built from 12 px wide cardinal arms; arms meet on cell borders for seamless joins.
    arms = {
      "h": ["W","E"], "v": ["N","S"],
      "turn_ne": ["N","E"], "turn_es": ["E","S"], "turn_sw": ["S","W"], "turn_wn": ["W","N"],
      "tee_n": ["N","E","W"], "tee_e": ["N","E","S"], "tee_s": ["E","S","W"], "tee_w": ["N","S","W"],
      "dead_n": ["N"], "dead_e": ["E"], "dead_s": ["S"], "dead_w": ["W"],
      "cross": ["N","E","S","W"],
    }[kind]
    mask = Image.new("1", (CELL,CELL), 0); m = ImageDraw.Draw(mask)
    # central hub is 12x12; each arm extends to the outer edge.
    m.rectangle((10,10,21,21), fill=1)
    for arm in arms:
        if arm == "N": m.rectangle((10,0,21,16), fill=1)
        elif arm == "S": m.rectangle((10,15,21,31), fill=1)
        elif arm == "W": m.rectangle((0,10,16,21), fill=1)
        elif arm == "E": m.rectangle((15,10,31,21), fill=1)
    r = seeded(tile_id)
    # alpha remains exactly 0/255. Fill pixels and subtle stone-colored dashes only inside mask.
    pa = PALETTES["path"]
    for y in range(CELL):
        for x in range(CELL):
            if mask.getpixel((x,y)):
                img.putpixel((x,y), rgba(pa[0]))
    d = ImageDraw.Draw(img)
    # dashes away from outer joining edges keep the join stable.
    for _ in range(3):
        x, y = r.randint(5, 26), r.randint(5, 26)
        if mask.getpixel((x,y)):
            d.rectangle((x,y,x+1,y), fill=rgba(pa[1 + r.randrange(3)]))
    # two small dry-earth specks, deterministic, clipped to mask
    return img

def build_tiles():
    tiles=[]
    for k, variants in [("water_deep",3),("water_shallow",2),("sand",3),("grass",3),("forest",3),("soil",3)]:
        for v in range(1,variants+1):
            tile_id=f"{k}_{v:02d}"
            tiles.append((tile_id,"base",k,base_tile(k,v-1,tile_id),"base surface; seamless repeat"))
    for direction in ("N","E","S","W"):
        tid=f"shore_sand_water_edge_{direction.lower()}"
        # direction denotes the water side; the other half is sand.
        tiles.append((tid,"transition","sand_water",orient_edge("sand","water_shallow",direction,PALETTES["shore_foam"],True,tid),"single-cell interface connector"))
    for corner in ("NW","NE","SE","SW"):
        tid=f"shore_sand_water_corner_{corner.lower()}"
        tiles.append((tid,"transition","sand_water",corner_transition("sand","water_shallow",corner,PALETTES["shore_foam"],True,tid),"single-cell interface corner"))
    for direction in ("N","E","S","W"):
        tid=f"beach_grass_edge_{direction.lower()}"
        tiles.append((tid,"transition","sand_grass",orient_edge("grass","sand",direction,PALETTES["edge_sand_grass"],False,tid),"single-cell beach-to-meadow interface"))
    for corner in ("NW","NE","SE","SW"):
        tid=f"beach_grass_corner_{corner.lower()}"
        tiles.append((tid,"transition","sand_grass",corner_transition("grass","sand",corner,PALETTES["edge_sand_grass"],False,tid),"single-cell beach-to-meadow corner"))
    for direction in ("N","E","S","W"):
        tid=f"grass_soil_edge_{direction.lower()}"
        tiles.append((tid,"transition","grass_soil",orient_edge("grass","soil",direction,PALETTES["edge_grass_soil"],False,tid),"single-cell meadow-to-inland-soil interface"))
    for corner in ("NW","NE","SE","SW"):
        tid=f"grass_soil_corner_{corner.lower()}"
        tiles.append((tid,"transition","grass_soil",corner_transition("grass","soil",corner,PALETTES["edge_grass_soil"],False,tid),"single-cell meadow-to-inland-soil corner"))
    for name in ("h","v","turn_ne","turn_es","turn_sw","turn_wn","tee_n","tee_e","tee_s","tee_w","dead_n","dead_e","dead_s","dead_w","cross"):
        tid=f"path_overlay_{name}"
        tiles.append((tid,"overlay","path",overlay_path(name,0,tid),"transparent ground overlay; compose over grass/soil"))
    return tiles

def checker(size):
    im=Image.new("RGBA",(size,size),(75,79,80,255)); d=ImageDraw.Draw(im)
    for y in range(0,size,8):
        for x in range(0,size,8):
            if (x//8+y//8)%2: d.rectangle((x,y,x+7,y+7),fill=(105,108,105,255))
    return im

def main():
    ap=argparse.ArgumentParser(); ap.add_argument("--output-dir",default=".")
    args=ap.parse_args(); root=Path(args.output_dir); tiles=build_tiles()
    if len(tiles)!=56: raise SystemExit(f"expected 56 tiles, got {len(tiles)}")
    atlas=Image.new("RGBA",(COLS*CELL,((len(tiles)+COLS-1)//COLS)*CELL),(0,0,0,0))
    for i,(tid,kind,group,img,note) in enumerate(tiles):
        atlas.paste(img,((i%COLS)*CELL,(i//COLS)*CELL))
    atlas_path=root/OUT_ATLAS; atlas_path.parent.mkdir(parents=True,exist_ok=True); atlas.save(atlas_path,optimize=True)
    # Contact sheet: 4x upscale, nearest only, with tile ID and local grid index.
    font=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",8)
    cellw,cellh=160,162; contact=Image.new("RGB",(COLS*cellw,7*cellh),(28,34,37)); cd=ImageDraw.Draw(contact)
    checker_bg=checker(128)
    for i,(tid,kind,group,img,note) in enumerate(tiles):
        col,row=i%COLS,i//COLS; x,y=col*cellw,row*cellh
        bg=checker_bg.resize((128,128),Image.Resampling.NEAREST)
        tile=img.resize((128,128),Image.Resampling.NEAREST)
        bg.alpha_composite(tile); contact.paste(bg.convert("RGB"),(x+16,y+2))
        words=tid.split("_"); lines=[f"{i:02d}"]
        for word in words:
            if len(lines[-1])+1+len(word)>21: lines.append(word)
            else: lines[-1]+=f"_{word}"
        for li,line in enumerate(lines[:3]):
            cd.text((x+4,y+130+li*9),line,font=font,fill=(238,235,215))
    contact_path=root/OUT_CONTACT; contact_path.parent.mkdir(parents=True,exist_ok=True); contact.save(contact_path,optimize=True)
    # A joined sample for composition review; this is a scripted mockup, not a Godot render.
    lookup={tid:img for tid,kind,group,img,note in tiles}
    cols,rows=16,10; sample=Image.new("RGBA",(cols*CELL,rows*CELL),(0,0,0,0))
    for y in range(rows):
        for x in range(cols):
            if y<2: tid=f"water_{'deep' if y==0 else 'shallow'}_{(x%3)+1:02d}" if y==0 else f"water_shallow_{(x%2)+1:02d}"
            elif y==2: tid="shore_sand_water_edge_n"
            elif y==3: tid=f"sand_{(x%3)+1:02d}"
            elif y==4: tid="beach_grass_edge_n"
            elif y in (5,6): tid=f"grass_{(x%3)+1:02d}"
            elif y==7: tid=f"forest_{(x%3)+1:02d}"
            elif y==8: tid="grass_soil_edge_n"
            else: tid=f"soil_{(x%3)+1:02d}"
            sample.paste(lookup[tid],(x*CELL,y*CELL))
    # path overlay over several surface rows, showing a continuous modular connector.
    route=[(7,5,"path_overlay_v"),(7,6,"path_overlay_v"),(7,7,"path_overlay_v"),(7,8,"path_overlay_v"),(7,9,"path_overlay_v"),
           (7,5,"path_overlay_v"),(7,6,"path_overlay_v"),(7,7,"path_overlay_v"),(7,8,"path_overlay_v"),(7,9,"path_overlay_v")]
    for x,y,tid in route:
        overlay=lookup[tid]
        sample.alpha_composite(overlay,(x*CELL,y*CELL))
    sample_path=root/OUT_SAMPLE; sample_path.parent.mkdir(parents=True,exist_ok=True)
    sample.convert("RGB").resize((cols*CELL*2,rows*CELL*2),Image.Resampling.NEAREST).save(sample_path,optimize=True)
    # Metadata and repeatability diagnostics.
    entries=[]
    for i,(tid,kind,group,img,note) in enumerate(tiles):
        entries.append({"id":tid,"group":group,"role":kind,"atlas_xy_tiles":[i%COLS,i//COLS],"rect_px":[(i%COLS)*CELL,(i//COLS)*CELL,CELL,CELL],"note":note,"alpha_policy":"binary_0_or_255"})
    def edge_pixels(im):
        return [im.getpixel((x,0)) for x in range(CELL)]+[im.getpixel((x,CELL-1)) for x in range(CELL)]+[im.getpixel((0,y)) for y in range(CELL)]+[im.getpixel((CELL-1,y)) for y in range(CELL)]
    alpha_values=sorted({value for count,value in atlas.getchannel("A").getcolors(maxcolors=256)})
    base_tiles=[(t[0],t[3]) for t in tiles if t[1]=="base"]
    repeat_fail=[]
    for tid,im in base_tiles:
        # Deliberate zero-edge border means the surface repeats without edge discontinuity.
        bg=im.getpixel((0,0))
        if any(im.getpixel((x,0))!=bg or im.getpixel((x,31))!=bg for x in range(32)) or any(im.getpixel((0,y))!=bg or im.getpixel((31,y))!=bg for y in range(32)):
            repeat_fail.append(tid)
    manifest={"id":"terrain_mvp_candidate_v1","status":"candidate_pending_visual_and_engine_review","created":"2026-10-15","cell_px_candidate":[CELL,CELL],"fixed_scale":False,"project":"A Ilha do Cristal","art_direction":"RPG Classico 2D pixel art; orthogonal grid; top-down slightly oblique; hard pixel clusters; no antialiasing","scope":["beach/spawn","forest","inland/interior ground"],"atlas":{"file":"terrain_mvp_candidate_v1.png","size_px":list(atlas.size),"columns":COLS,"rows":7,"tile_count":len(tiles),"tile_order":"row-major; see tiles[].atlas_xy_tiles"},"rendering":{"filter":"nearest","mipmaps":"disabled for candidate test","tile_layers":"surface base + optional path overlay; collision/navigation not encoded","alpha_values":alpha_values},"generation":{"script":"tools/art/generate_mvp_terrain_tileset.py","seed":SEED,"method":"Pillow integer-coordinate raster drawing at native cell resolution; no resampling of source artwork; source does not overwrite concepts or character sprites","prompt":"RPG Classico 2D top-down slightly oblique orthogonal terrain for a family-friendly island survival RPG; readable warm beach/spawn, forest and inland surfaces; compact repeat-safe pixel clusters; crisp pixel edges, no anti-aliasing, no characters, no props, no labels in atlas; 32x32 px candidate cell only."},"validation":{"png_rgba":atlas.mode=="RGBA","dimensions_multiple_of_cell":atlas.width%CELL==0 and atlas.height%CELL==0,"alpha_values":alpha_values,"alpha_binary":set(alpha_values).issubset({0,255}),"base_tiles_seam_edge_check":"all base-cell edge pixels equal that tile's corner/base color; repeats without boundary discontinuity","base_tiles_checked":len(base_tiles),"base_repeat_failures":repeat_fail,"transitions_checked":"N/E/S/W connectors plus four corners per boundary family; composition only, not auto-tile engine tested","engine_validation":"pending; no Godot render or device test","sample_render":"scripted tile composition, not a Godot screenshot"},"tiles":entries,"visual_evidence":{"contact_sheet":"docs/art/evidence/terrain/terrain_mvp_candidate_v1_contact.png","composed_sample":"docs/art/evidence/terrain/terrain_mvp_candidate_v1_sample.png"},"limitations":["32x32 px per SQM is a candidate; test at 50–125% zoom and Android sizes before fixing scale.","Top-down slightly oblique visual is a flat ground tile contract; the current sample is not gameplay or engine evidence.","Transition cells occupy a tile on the boundary; no Godot terrain-set/autotile resource or collision/navigation data is included.","No trees, rocks as props, resource nodes, buildings, characters or hazards are included; add only after separate GDD scope/review.","Review palette coherence, shore continuity, repeat seams and readability in Godot before production approval."]}
    manifest_path=root/OUT_MANIFEST; manifest_path.parent.mkdir(parents=True,exist_ok=True); manifest_path.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(json.dumps({"atlas":str(atlas_path),"manifest":str(manifest_path),"contact":str(contact_path),"sample":str(sample_path),"tile_count":len(tiles),"atlas_size":list(atlas.size),"alpha_values":alpha_values,"base_repeat_failures":repeat_fail},indent=2))

if __name__=="__main__": main()
