#!/usr/bin/env python3
"""Structural checks for the scripted MVP terrain candidate. Not an art/engine approval."""
import json, sys
from pathlib import Path
from PIL import Image, ImageDraw

root=Path(sys.argv[1]) if len(sys.argv)>1 else Path('.')
base=root/'assets/environments/terrain_mvp_candidate_v1'
manifest_path=base/'terrain_mvp_candidate_v1.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
atlas_path=base/manifest['atlas']['file']
im=Image.open(atlas_path).convert('RGBA')
cell=manifest['cell_px_candidate']; cw,ch=cell
assert manifest['status']=='candidate_pending_visual_and_engine_review'
assert im.size==tuple(manifest['atlas']['size_px'])
assert im.width%cw==0 and im.height%ch==0
assert len(manifest['tiles'])==manifest['atlas']['tile_count']==56
ids=[t['id'] for t in manifest['tiles']]
assert len(ids)==len(set(ids)), 'duplicate tile IDs'
alpha_values=sorted({v for count,v in im.getchannel('A').getcolors(maxcolors=256)})
assert set(alpha_values)<= {0,255}, f'non-binary alpha: {alpha_values}'
assert alpha_values==manifest['validation']['alpha_values']
repeat_fail=[]
for tile in manifest['tiles']:
    x,y,w,h=tile['rect_px']
    assert w==cw and h==ch and x+w<=im.width and y+h<=im.height, f'invalid rect: {tile["id"]}'
    region=im.crop((x,y,x+w,y+h))
    alphas={v for count,v in region.getchannel('A').getcolors(maxcolors=256)}
    assert alphas<= {0,255}, f'non-binary tile alpha: {tile["id"]}'
    if tile['role']=='base':
        px=region.load(); edge=px[0,0]
        if any(px[i,0]!=edge or px[i,h-1]!=edge for i in range(w)) or any(px[0,j]!=edge or px[w-1,j]!=edge for j in range(h)):
            repeat_fail.append(tile['id'])
assert not repeat_fail, f'base tile edges are not repeat-safe: {repeat_fail}'
assert repeat_fail==manifest['validation']['base_repeat_failures']
assert len([t for t in manifest['tiles'] if t['role']=='base'])==17
assert len([t for t in manifest['tiles'] if t['role']=='transition'])==24
assert len([t for t in manifest['tiles'] if t['role']=='overlay'])==15
tile_regions={
    tile['id']:im.crop((tile['rect_px'][0],tile['rect_px'][1],
                        tile['rect_px'][0]+tile['rect_px'][2],
                        tile['rect_px'][1]+tile['rect_px'][3]))
    for tile in manifest['tiles']
}
def border_pixels(region,side):
    if side=='left': return [region.getpixel((0,y)) for y in range(ch)]
    if side=='right': return [region.getpixel((cw-1,y)) for y in range(ch)]
    if side=='top': return [region.getpixel((x,0)) for x in range(cw)]
    return [region.getpixel((x,ch-1)) for x in range(cw)]
transition_families=(
    ('shore_sand_water','sand_01','water_shallow_01'),
    ('beach_grass','grass_01','sand_01'),
    ('grass_soil','grass_01','soil_01'),
)
edge_material_sides={
    'n':(('top','b'),('bottom','a')),
    'e':(('right','b'),('left','a')),
    's':(('bottom','b'),('top','a')),
    'w':(('left','b'),('right','a')),
}
transition_base_join_failures=[]
transition_base_joins_checked=0
for prefix,material_a,material_b in transition_families:
    for direction,sides in edge_material_sides.items():
        edge_id=f'{prefix}_edge_{direction}'
        for side,material in sides:
            transition_base_joins_checked+=1
            base_id=material_b if material=='b' else material_a
            if border_pixels(tile_regions[edge_id],side)!=border_pixels(tile_regions[base_id],side):
                transition_base_join_failures.append({'edge':edge_id,'side':side,'base':base_id})
assert transition_base_joins_checked==manifest['validation']['transition_base_joins_checked']
assert not transition_base_join_failures, f'transition/base border mismatch: {transition_base_join_failures}'
assert transition_base_join_failures==manifest['validation']['transition_base_join_failures']
corner_edge_pairs={
    'nw':(('right','n','left'),('bottom','w','top')),
    'ne':(('left','n','right'),('bottom','e','top')),
    'se':(('left','s','right'),('top','e','bottom')),
    'sw':(('right','s','left'),('top','w','bottom')),
}
transition_prefixes=('shore_sand_water','beach_grass','grass_soil')
corner_edge_join_failures=[]
corner_edge_joins_checked=0
for prefix in transition_prefixes:
    for corner,joins in corner_edge_pairs.items():
        for corner_side,edge_direction,edge_side in joins:
            corner_edge_joins_checked+=1
            corner_id=f'{prefix}_corner_{corner}'
            edge_id=f'{prefix}_edge_{edge_direction}'
            if border_pixels(tile_regions[corner_id],corner_side)!=border_pixels(tile_regions[edge_id],edge_side):
                corner_edge_join_failures.append({
                    'corner':corner_id,'side':corner_side,
                    'edge':edge_id,'edge_side':edge_side,
                })
assert corner_edge_joins_checked==manifest['validation']['corner_edge_joins_checked']
assert not corner_edge_join_failures, f'corner/edge border mismatch: {corner_edge_join_failures}'
assert corner_edge_join_failures==manifest['validation']['corner_edge_join_failures']
corner_outer_sides={
    'nw':('top','left'),'ne':('top','right'),
    'se':('bottom','right'),'sw':('bottom','left'),
}
corner_outer_base_join_failures=[]
corner_outer_base_joins_checked=0
for prefix,material_a,material_b in transition_families:
    for corner,sides in corner_outer_sides.items():
        corner_id=f'{prefix}_corner_{corner}'
        for side in sides:
            corner_outer_base_joins_checked+=1
            if border_pixels(tile_regions[corner_id],side)!=border_pixels(tile_regions[material_b],side):
                corner_outer_base_join_failures.append({'corner':corner_id,'side':side,'base':material_b})
assert corner_outer_base_joins_checked==manifest['validation']['corner_outer_base_joins_checked']
assert not corner_outer_base_join_failures, f'corner/base border mismatch: {corner_outer_base_join_failures}'
assert corner_outer_base_join_failures==manifest['validation']['corner_outer_base_join_failures']
path_arms={
    'h':['W','E'],'v':['N','S'],
    'turn_ne':['N','E'],'turn_es':['E','S'],'turn_sw':['S','W'],'turn_wn':['W','N'],
    'tee_n':['N','E','W'],'tee_e':['N','E','S'],'tee_s':['E','S','W'],'tee_w':['N','S','W'],
    'dead_n':['N'],'dead_e':['E'],'dead_s':['S'],'dead_w':['W'],'cross':['N','E','S','W'],
}
overlay_footprint_failures=[]
for tile in manifest['tiles']:
    if tile['role']!='overlay':
        continue
    kind=tile['id'].removeprefix('path_overlay_')
    assert kind in path_arms, f'unknown path overlay: {tile["id"]}'
    x,y,w,h=tile['rect_px']
    region=im.crop((x,y,x+w,y+h))
    mask=Image.new('1',(cw,ch),0); d=ImageDraw.Draw(mask)
    d.rectangle((10,10,21,21),fill=1)
    for arm in path_arms[kind]:
        if arm=='N': d.rectangle((10,0,21,16),fill=1)
        elif arm=='S': d.rectangle((10,15,21,31),fill=1)
        elif arm=='W': d.rectangle((0,10,16,21),fill=1)
        elif arm=='E': d.rectangle((15,10,31,21),fill=1)
    for py in range(ch):
        for px in range(cw):
            if region.getpixel((px,py))[3] and not mask.getpixel((px,py)):
                overlay_footprint_failures.append({'id':tile['id'],'pixel':[px,py]})
assert not overlay_footprint_failures, f'path overlay pixels outside route footprint: {overlay_footprint_failures}'
assert len([t for t in manifest['tiles'] if t['role']=='overlay'])==manifest['validation']['overlay_tiles_checked']
assert overlay_footprint_failures==manifest['validation']['overlay_footprint_failures']
for key in ['contact_sheet','composed_sample','context_composition_review']:
    assert (root/manifest['visual_evidence'][key]).is_file(), f'missing evidence {key}'
print(json.dumps({'result':'PASS_STRUCTURE_AND_COMPOSITION_JOINS','atlas':str(atlas_path),'dimensions_px':list(im.size),'cell_px_candidate':cell,'tiles':len(ids),'roles':{'base':17,'transition':24,'overlay':15},'alpha_values':alpha_values,'base_tile_repeat_edge_failures':repeat_fail,'transition_base_joins_checked':transition_base_joins_checked,'transition_base_join_failures':transition_base_join_failures,'corner_edge_joins_checked':corner_edge_joins_checked,'corner_edge_join_failures':corner_edge_join_failures,'corner_outer_base_joins_checked':corner_outer_base_joins_checked,'corner_outer_base_join_failures':corner_outer_base_join_failures,'overlay_footprint_failures':overlay_footprint_failures,'godot_android_visual_review':'PENDING'},ensure_ascii=False,indent=2))
