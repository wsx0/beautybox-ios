
import sys, zipfile, io, os
from PIL import Image
z = zipfile.ZipFile(sys.argv[1])
im = Image.open(io.BytesIO(z.read('res/CG.png'))).convert('RGBA')
canvas = Image.new('RGBA', (1024, 1024), (12, 12, 16, 255))
scaled = im.resize((1024, 1024), Image.LANCZOS)
canvas.alpha_composite(scaled)
out = sys.argv[2]
canvas.convert('RGB').save(out, 'PNG')
print('icon saved', out, os.path.getsize(out))
print('src size', im.size)
