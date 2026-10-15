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
for key in ['contact_sheet','composed_sample']:
    assert (root/manifest['visual_evidence'][key]).is_file(), f'missing evidence {key}'
print(json.dumps({'result':'PASS_STRUCTURE_AND_OVERLAY_FOOTPRINT','atlas':str(atlas_path),'dimensions_px':list(im.size),'cell_px_candidate':cell,'tiles':len(ids),'roles':{'base':17,'transition':24,'overlay':15},'alpha_values':alpha_values,'base_tile_repeat_edge_failures':repeat_fail,'overlay_footprint_failures':overlay_footprint_failures,'godot_android_visual_review':'PENDING'},ensure_ascii=False,indent=2))
