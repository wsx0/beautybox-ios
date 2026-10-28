
import zipfile, io, os, sys
from PIL import Image
apk = r'C:\Users\王世雄\Downloads\beautybox_5_1_52.apk'
out = r'D:\deepseek项目\软件破解\beautybox_port\media_src'
os.makedirs(out, exist_ok=True)
z = zipfile.ZipFile(apk)
rows = []
for n in z.namelist():
    if not n.lower().endswith(('.jpg', '.png')): continue
    try:
        im = Image.open(io.BytesIO(z.read(n)))
        w, h = im.size
    except Exception:
        continue
    area = w * h
    if area >= 30000 and w > 100 and h > 100:
        rows.append((area, n, w, h, len(z.read(n))))
rows.sort(reverse=True)
print('candidates', len(rows))
for r in rows[:12]:
    print('  %dx%d  %s  %d bytes' % (r[2], r[3], r[1], r[4]))
for i, r in enumerate(rows[:8]):
    ext = os.path.splitext(r[1])[1]
    p = os.path.join(out, 'img_%d%s' % (i, ext))
    open(p, 'wb').write(z.read(r[1]))
    print('saved', p)
