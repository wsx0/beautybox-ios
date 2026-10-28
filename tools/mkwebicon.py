
import sys, os, zipfile, io
from PIL import Image

apk = r'C:\Users\王世雄\Downloads\beautybox_5_1_52.apk'
outdir = sys.argv[1]
os.makedirs(outdir, exist_ok=True)
src = Image.open(io.BytesIO(zipfile.ZipFile(apk).read('res/CG.png'))).convert('RGBA')

def make(size, pad_ratio, bg):
    canvas = Image.new('RGBA', (size, size), bg)
    inner = int(size * (1 - pad_ratio * 2))
    im = src.resize((inner, inner), Image.LANCZOS)
    canvas.alpha_composite(im, (int(size * pad_ratio), int(size * pad_ratio)))
    return canvas.convert('RGB')

for size in (180, 192, 512):
    p = os.path.join(outdir, 'icon-%d.png' % size)
    make(size, 0.0 if size == 512 else 0.08, (15, 15, 20, 255)).save(p, 'PNG')
    print('icon', p, os.path.getsize(p))
