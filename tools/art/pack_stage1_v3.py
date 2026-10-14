#!/usr/bin/env python3
"""Fixed-grid packaging of unified imagegen candidate; no art synthesis."""
from pathlib import Path
import json
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/characters/melissa/warrior'
SOURCE=ROOT/'assets/references/generated-candidates/melissa_warrior_unified_v3_source.png'
source=Image.open(SOURCE).convert('RGBA')
# Actual source has10columns2rows, rectangular source regions. Use ONE
# uniform scale for both axes/all frames, never stretch to square or crop alpha.
scale=.25
anchors=[(108,322),(108,306)]
for name,start,count,fps in [('idle',0,4,6),('walk',4,6,10)]:
    atlas=Image.new('RGBA',(96*count,192))
    boxes=[]
    for row in range(2):
        row_boxes=[]
        for frame in range(count):
            col=start+frame
            bounds=(round(col*source.width/10),round(row*source.height/2),round((col+1)*source.width/10),round((row+1)*source.height/2))
            tile=source.crop(bounds)
            tile=tile.resize((round(tile.width*scale),round(tile.height*scale)),Image.Resampling.NEAREST)
            cell=Image.new('RGBA',(96,96))
            position=(48-round(anchors[row][0]*scale),80-round(anchors[row][1]*scale))
            cell.alpha_composite(tile,position)
            atlas.alpha_composite(cell,(96*frame,96*row))
            row_boxes.append(bounds)
        boxes.append(row_boxes)
    identifier=f'melissa_warrior_{name}_candidate_v3'
    atlas.save(OUT/f'{identifier}.png')
    meta={'id':identifier,'atlas':identifier+'.png','status':'corrigir','approved':False,'cell':[96,96],'pivot':[48,80],'directions':['N','S'],'frames':count,'fps':fps,'loop':True,'animation':name,'animations':{name:{'frames':count,'fps':fps,'loop':True}},'source':str(SOURCE.relative_to(ROOT)),'source_regions':boxes,'source_feet_anchors':anchors,'uniform_source_scale':scale,'resampling':'nearest','alpha':'original_preserved','offsets':[0,0],'notes':['Stage1 N/S only, six directions pending','Manual source anchors estimate feet, require visual review','No frame duplication or per-frame scaling','Source alpha remains soft; not approved pixel art']}
    (OUT/f'{identifier}.json').write_text(json.dumps(meta,indent=2)+'\n')
    print(identifier,atlas.size)
