"""Deterministic native pixel UI; original metal/parchment frames and item glyphs."""
from PIL import Image,ImageDraw
from pathlib import Path
import random
OUT=Path(__file__).resolve().parents[2]/'assets/ui/classic_v2';OUT.mkdir(parents=True,exist_ok=True)
def frame(name,fill):
 im=Image.new('RGBA',(48,48),(0,0,0,0));d=ImageDraw.Draw(im)
 for inset,c in [(0,'#14191c'),(1,'#79817b'),(3,'#343d3d'),(5,'#b2a37c'),(6,'#171f22'),(8,fill)]:d.rectangle((inset,inset,47-inset,47-inset),fill=c)
 rng=random.Random(17)
 for _ in range(0):
  x,y=rng.randrange(10,38),rng.randrange(10,38);d.point((x,y),fill='#c7b587' if name=='parchment' else '#293231')
 for x,y in [(4,4),(40,4),(4,40),(40,40)]:
  d.polygon([(x,y+2),(x+2,y),(x+4,y+2),(x+2,y+4)],fill='#d1bd84');d.point((x+2,y+2),fill='#596b68')
 im.save(OUT/(name+'.png'))
for n,c in [('panel','#232c2c'),('slot','#172021'),('parchment','#d5c398'),('button','#3c4843'),('confirm','#315936'),('danger','#6b3030')]:frame(n,c)
def icon(name):
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 if name in ['sword_basic','sword_reinforced','main_hand']:
  d.polygon([(8,23),(22,5),(26,3),(26,9),(12,26)],fill='#182329');d.polygon([(10,22),(23,6),(25,5),(24,10),(13,24)],fill='#c4d8da');d.line((12,21,24,6),fill='#eff6de',width=2);d.line((7,21,15,28),fill='#b49b54',width=3);d.line((8,26,5,29),fill='#875137',width=3)
 elif name in ['axe_basic','pickaxe_basic']:
  d.line((8,28,24,5),fill='#312920',width=5);d.line((8,27,23,6),fill='#ae8150',width=3)
  d.polygon([(11,7),(17,4),(27,6),(29,12),(22,13),(18,9)],fill='#c1d1cd' if name=='axe_basic' else '#8faba9');d.line((11,7,27,7),fill='#ebeed4',width=2)
 elif name in ['FOR','meat']:
  d.polygon([(5,21),(8,13),(12,9),(16,12),(16,17),(21,16),(23,9),(20,6),(24,3),(28,7),(28,18),(23,26),(13,28),(6,25)],fill='#663c34');d.polygon([(7,21),(10,14),(13,12),(15,17),(21,19),(25,15),(26,8),(24,6),(25,5),(27,8),(26,19),(22,24),(13,26)],fill='#ce8b63');d.line((10,21,15,19,20,22),fill='#f3bc8a',width=2)
 elif name in ['AGI','boots']:
  d.polygon([(11,4),(23,5),(21,20),(27,23),(27,28),(5,28),(6,23),(12,20)],fill='#252922');d.polygon([(13,6),(21,7),(19,21),(24,24),(24,26),(7,26),(8,24),(15,22)],fill='#927244');d.line((13,7,20,8),fill='#d7bf76',width=2);d.line((7,27,26,27),fill='#d3c4a0',width=2)
 elif name=='INT':
  d.polygon([(7,4),(26,5),(24,28),(5,26)],fill='#392c4c');d.polygon([(9,5),(24,7),(22,25),(7,24)],fill='#6979a6');d.line((10,7,8,22),fill='#c6b782',width=2);d.polygon([(17,9),(21,15),(16,20),(13,15)],fill='#9ee2df');d.point((17,13),fill='#f7efbf')
 elif name in ['wood','fiber','herb','fang','crystal_shard','stone','hide','bandage','amulet','jewel_left','jewel_right','head','chest','pants','offhand']:
  if name=='wood':
   for a,b in [(5,19),(10,24),(13,15)]:
    d.polygon([(a,b),(a+13,b-9),(a+17,b-5),(a+4,b+4)],fill='#68472e');d.line((a+3,b,a+14,b-7),fill='#bf9758',width=3);d.ellipse((a,b,a+6,b+6),fill='#d6b271',outline='#7f5b35')
  elif name in ['fiber','herb']:
   for x,y in [(8,9),(20,7),(13,18)]:
    d.line((15,28,x+4,y+3),fill='#a4b96b',width=2);d.polygon([(x,y+5),(x+3,y),(x+9,y+1),(x+6,y+7)],fill='#6ea16a');d.point((x+3,y+2),fill='#c7dba1')
   if name=='herb':d.ellipse((18,6,23,11),fill='#f1d49b')
  elif name=='stone':d.polygon([(4,22),(8,10),(22,6),(28,18),(25,26),(10,28)],fill='#667a7b');d.polygon([(8,11),(21,8),(17,19),(5,21)],fill='#bbc8be');d.line((18,20,24,24),fill='#37494e',width=2)
  elif name=='crystal_shard':
   d.polygon([(6,21),(13,5),(23,2),(27,17),(19,28)],fill='#406c90');d.polygon([(13,6),(21,5),(18,23),(8,21)],fill='#8ee4dd');d.line((22,6,24,16,19,25),fill='#dfefdc',width=2)
  elif name=='fang':d.polygon([(7,6),(24,4),(21,17),(10,28),(15,15)],fill='#e2dab4');d.line((20,8,17,18,11,26),fill='#a2ad9c',width=2)
  elif name=='hide':d.polygon([(7,5),(12,8),(21,6),(27,4),(25,13),(28,22),(23,28),(17,25),(7,28),(5,20),(8,14)],fill='#a97b4b');d.line((10,8,12,14,8,23,20,23,24,19),fill='#d0a16c',width=2)
  elif name=='bandage':
   d.polygon([(4,11),(21,6),(28,20),(11,27)],fill='#a09578');d.polygon([(6,12),(20,9),(25,20),(12,25)],fill='#e8ddbb');d.line((13,11,19,23),fill='#b4b294',width=2);d.rectangle((13,15,20,19),fill='#9e5543');d.rectangle((15,13,18,21),fill='#9e5543')
  elif name in ['amulet','jewel_left','jewel_right']:
   d.ellipse((7,5,25,27),outline='#c4ae67',width=3);d.polygon([(16,12),(22,18),(16,25),(10,18)],fill='#6eafb2');d.point((15,16),fill='#d3ead2')
  elif name=='head':d.pieslice((6,4,26,30),180,360,fill='#879e9d');d.rectangle((6,15,26,23),fill='#576d71');d.rectangle((13,18,18,25),fill='#25353b');d.line((7,13,24,13),fill='#d6c89e',width=2)
  elif name=='chest':d.polygon([(9,5),(13,8),(19,8),(23,5),(28,13),(23,16),(23,28),(9,28),(9,16),(4,13)],fill='#91a2a0');d.line((16,10,16,27),fill='#d6c89e',width=2)
  elif name=='pants':d.polygon([(8,5),(24,5),(24,28),(18,28),(16,16),(13,28),(6,28)],fill='#7e7460');d.line((9,8,22,8),fill='#c4ad7c',width=2)
  else:d.polygon([(6,6),(16,3),(27,6),(25,21),(16,29),(8,21)],fill='#9bafac');d.polygon([(9,9),(16,6),(24,9),(22,20),(16,25),(11,20)],fill='#5d756e');d.line((16,8,16,23),fill='#d8c27c',width=2)
 im.save(OUT/(name+'.png'))
for n in ['FOR','AGI','INT','wood','stone','fiber','herb','bandage','meat','hide','fang','crystal_shard','sword_basic','sword_reinforced','axe_basic','pickaxe_basic','head','chest','pants','boots','offhand','main_hand','amulet','jewel_left','jewel_right']:icon(n)
print('Classic UI: 6 nine-slice frames and 25 original pixel icons.')
