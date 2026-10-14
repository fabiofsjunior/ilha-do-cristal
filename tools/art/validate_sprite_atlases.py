#!/usr/bin/env python3
"""Report sprite contract violations; never grants artistic/Android approval."""
import json
import pathlib
import sys
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
errors = []
reports = []
for metadata_path in sorted((ROOT / 'assets/characters').rglob('*.json')):
    metadata = json.loads(metadata_path.read_text())
    image_path = metadata_path.parent / metadata['atlas']
    report = {'id': metadata['id'], 'status': metadata.get('status', 'pending_visual_and_android_validation'), 'frames': []}
    if not image_path.exists():
        errors.append(f'{image_path.relative_to(ROOT)}: atlas missing')
        continue
    image = Image.open(image_path)
    cell_w, cell_h = metadata['cell']
    config = next(iter(metadata['animations'].values()))
    count = config['frames']
    expected = (cell_w * count, cell_h * len(metadata['directions']))
    if image.mode != 'RGBA':
        errors.append(f'{image_path.name}: expected RGBA, got {image.mode}')
        continue
    if image.size != expected:
        errors.append(f'{image_path.name}: expected {expected}, got {image.size}')
        continue
    alphas = set(image.getchannel('A').tobytes())
    report['alpha_value_count'] = len(alphas)
    report['intermediate_alpha_count'] = len(alphas - {0, 255})
    if 0 not in alphas or not any(a > 0 for a in alphas):
        errors.append(f'{image_path.name}: needs transparent and visible pixels')
    if alphas - {0, 255}:
        errors.append(f'{image_path.name}: intermediate alpha values; inspect antialias')
    for row, direction in enumerate(metadata['directions']):
        for column in range(count):
            frame = image.crop((column*cell_w,row*cell_h,(column+1)*cell_w,(row+1)*cell_h))
            bbox = frame.getchannel('A').getbbox()
            entry = {'direction': direction, 'frame': column, 'bbox': bbox}
            report['frames'].append(entry)
            if bbox is None:
                errors.append(f'{image_path.name} {direction}/{column}: empty frame')
            elif bbox[0] == 0 or bbox[1] == 0 or bbox[2] == cell_w or bbox[3] == cell_h:
                errors.append(f'{image_path.name} {direction}/{column}: visible pixels touch cell boundary; inspect clipping/bleed')
    reports.append(report)
print(json.dumps({'reports': reports, 'errors': errors, 'note': 'Bboxes cannot prove correct anatomy, pivot, direction or temporal identity. Review in Godot and Android.'}, indent=2))
sys.exit(bool(errors))
