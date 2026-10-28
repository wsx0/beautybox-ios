
import sys, os, io, zipfile, re
from PIL import Image
from androguard.core.apk import APK
apk = APK(sys.argv[1]); arsc = apk.get_android_resources()
p='com.secret.prettyhezi'
try:
    res = arsc.get_string_resources(p, ' ')
    print('LABEL 0x7F1000C3 =', res.get(0x7F1000C3))
    print('APPNAME found:', [v for k,v in res.items() if k==0x7F1000C3])
except Exception as e:
    print('label err', e)
z = zipfile.ZipFile(sys.argv[1])
cands=[]
for n in z.namelist():
    if not n.lower().endswith('.png'): continue
    b=z.read(n)
    try:
        im=Image.open(io.BytesIO(b)); w,h=im.size
    except Exception: continue
    if w==h and w>=48:
        cands.append((w*h, w, n, len(b)))
cands.sort(reverse=True)
print('SQUARE_PNGS', len(cands))
for c in cands[:15]: print('  %dx%d %s (%d bytes)' % (c[1], c[1], c[2], c[3]))
os.makedirs(sys.argv[2], exist_ok=True)
for c in cands[:6]:
    open(os.path.join(sys.argv[2], 'icon_' + str(c[1]) + '.png'),'wb').write(z.read(c[2]))
print('saved to', sys.argv[2])
