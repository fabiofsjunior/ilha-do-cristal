#!/usr/bin/env python3
"""Deterministic pixel terrain primitives. Native 1px edges; no character changes."""
from PIL import Image, ImageDraw
from pathlib import Path
import random, math, json
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/environments/tropical_oblique_candidate'
OUT.mkdir(parents=True,exist_ok=True)
r=random.Random(20261016)
W,H=2048,1408
im=Image.new('RGBA',(W,H),'#d6ba74'); d=ImageDraw.Draw(im)
# Continuous coastline deliberately preserves the existing x=256 water collider.
d.rectangle((0,0,175,H),fill='#285f78'); d.rectangle((176,0,222,H),fill='#357f91'); d.rectangle((223,0,255,H),fill='#59a5ad')
for y in range(0,H,2):
    wet=270+int(8*math.sin(y/45)+4*math.sin(y/17))
    d.line((256,y,wet,y),fill='#b5c3a0',width=2)
    d.line((254,y,259,y),fill='#dce6c5',width=2)
# Small horizontal water marks avoid checkerboard/noisy tiling.
for _ in range(450):
    x,y=r.randrange(0,245),r.randrange(H)
    d.line((x,y,x+r.randrange(3,16),y),fill=r.choice(['#438a9c','#70b6b9','#36788e']))
# Broad irregular grass edge, not vertical biome stripes.
edge=[]
for y in range(0,H+8,8): edge.append((670+int(65*math.sin(y/140)+25*math.sin(y/53)),y))
d.polygon(edge+[(W,H),(W,0)],fill='#688152')
d.line(edge,fill='#b5b36d',width=10)
d.line([(x+7,y) for x,y in edge],fill='#8a975b',width=7)
# Natural inland shade masses and clearing patches.
for _ in range(95):
    x,y=r.randrange(760,W),r.randrange(H); rx,ry=r.randrange(30,100),r.randrange(15,50)
    pts=[(x+int(rx*math.cos(a*math.pi/6)),y+int(ry*math.sin(a*math.pi/6))) for a in range(12)]
    d.polygon(pts,fill=r.choice(['#647e50','#60794d','#718758','#73895a']))
# Curving sandy trail retains open movement across all original creature routes.
trail=[(535,750),(670,760),(820,780),(990,710),(1150,720),(1320,700),(1480,740),(1690,718),(1900,730)]
d.line(trail,fill='#8c9560',width=67,joint='curve');d.line(trail,fill='#b7ab6b',width=53,joint='curve');d.line(trail,fill='#c7b77a',width=39,joint='curve')
# Low, south-facing rock ledges: painted depth, confined to decorative clearing edges.
for x,y,length in [(740,420,170),(1120,280,220),(1400,1050,190),(1720,430,180)]:
    pts=[(x,y),(x+length-15,y-12),(x+length,y),(x+length-5,y+19),(x+15,y+30),(x,y+18)]
    d.polygon(pts,fill='#77674d');d.polygon([(x,y),(x+length-15,y-12),(x+length,y),(x+length-5,y+8),(x+12,y+18)],fill='#b4a06a')
    d.line([(x+3,y),(x+length-15,y-12),(x+length,y)],fill='#d4bd81',width=3)
    for sx in range(x+13,x+length,17): d.line((sx,y+7,sx-2,y+20),fill='#8e7953',width=2)
# Sparse clustered grains/blades: muted to preserve sprite readability.
for _ in range(14000):
    x,y=r.randrange(270,W-2),r.randrange(H-2)
    c=im.getpixel((x,y))
    if c[:3] in [(214,186,116),(199,183,122)]:
        col=r.choice(['#c8ac69','#e4cb8c','#ceb275']);d.line((x,y,x+r.randrange(1,4),y),fill=col)
    elif c[1]>c[0]:
        col=r.choice(['#81935e','#557147','#728956']); d.line((x,y,x+2,y-2),fill=col)
im.save(OUT/'ground.png')

def sprite(name,size,fn):
    a=Image.new('RGBA',size);q=ImageDraw.Draw(a);fn(q);a.save(OUT/(name+'.png'))
def palm(q):
    q.ellipse((24,108,88,125),fill='#49634c66')
    q.polygon([(43,117),(55,117),(63,71),(59,36),(50,39),(52,72)],fill='#59432e')
    q.polygon([(46,115),(51,115),(58,69),(55,43),(51,47),(54,72)],fill='#a17c48')
    for y in range(57,113,8):q.line((49,y,58,y-3),fill='#4e3c2b',width=2)
    leaves=[[(55,39),(26,24),(8,30),(0,49),(22,39),(42,44)],[(55,39),(34,8),(13,10),(4,26),(26,21)],[(55,38),(61,4),(82,2),(95,15),(72,12)],[(56,40),(85,23),(107,34),(111,51),(86,39),(66,46)],[(56,40),(80,51),(89,76),(74,66),(60,49)],[(54,39),(32,52),(19,79),(18,59),(32,40)]]
    for poly in leaves:
        q.polygon(poly,fill='#244d3c');q.line(poly[:3],fill='#60844a',width=3)
        base=poly[0]; tip=poly[-2];q.line((base,tip),fill='#7b9653',width=2)
    q.ellipse((48,37,57,46),fill='#795530');q.ellipse((57,39,64,47),fill='#a07b42')
def tree(q):
    q.ellipse((10,106,91,125),fill='#304a3866');q.polygon([(43,117),(58,117),(54,75),(43,73)],fill='#614831');q.line((47,79,47,111),fill='#97734b',width=3)
    for x,y,rx,ry in [(27,64,24,25),(69,61,28,29),(48,32,34,29),(28,38,24,24),(73,34,22,22)]:
        q.ellipse((x-rx,y-ry,x+rx,y+ry),fill='#294c36');q.ellipse((x-rx+3,y-ry+2,x+rx-5,y+ry-9),fill='#3e6742')
        q.arc((x-rx+6,y-ry+3,x+rx-5,y+ry-15),180,300,fill='#729052',width=4)
        for j in range(7):
            xx=x+r.randrange(-rx+5,rx-5);yy=y+r.randrange(-ry+5,ry-5);q.line((xx,yy,xx+4,yy-2),fill='#527c49',width=2)
def rock(q):
    q.ellipse((3,36,60,53),fill='#40534266');q.polygon([(6,34),(14,15),(31,5),(49,14),(59,34),(47,47),(16,47)],fill='#645d51');q.polygon([(6,34),(14,15),(31,5),(49,14),(39,29),(19,36)],fill='#c0ab80');q.polygon([(19,36),(39,29),(49,14),(59,34),(47,47)],fill='#958265');q.line([(14,15),(31,5),(49,14)],fill='#e0cb97',width=2);q.line((31,6,29,21),fill='#a7936f',width=2)
def crystal(q):
    q.ellipse((5,72,77,94),fill='#405b5966');q.polygon([(8,77),(31,62),(62,66),(77,82),(56,94),(23,92)],fill='#aa9165');q.line([(8,77),(29,83),(55,84),(77,82)],fill='#dec58a',width=2)
    for x,y,h,w in [(41,74,67,15),(24,79,39,11),(58,79,43,12),(14,82,21,8),(68,83,24,8)]:
        q.polygon([(x,y-h),(x+w,y-h//2),(x,y),(x-w,y-h//2)],fill='#267f9d');q.polygon([(x,y-h),(x,y),(x-w,y-h//2)],fill='#6cdae3');q.polygon([(x,y-h),(x+w,y-h//2),(x,y-h//2-4)],fill='#d3ffff');q.line((x,y-h,x,y-5),fill='#a2f4f3')
sprite('palm',(112,128),palm);sprite('tree',(104,128),tree);sprite('boulder',(64,56),rock);sprite('crystal',(84,96),crystal)
# Source contract for deterministic regeneration and runtime pivots.
(OUT/'manifest.json').write_text(json.dumps({'status':'candidate','style':'classic RPG pixel art, oblique top-down','seed':20261016,'ground_size':[W,H],'sqm_px':32,'pivots':{'palm':[56,117],'tree':[52,117],'boulder':[32,42],'crystal':[42,84]},'collision':'unchanged; decoration does not introduce walkable elevation','reference':'image(20261016-162915).png'},indent=2)+'\n')
print(OUT)
