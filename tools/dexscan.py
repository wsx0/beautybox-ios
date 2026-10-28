
import sys, zipfile, struct, re, collections, os, json

APK = sys.argv[1]
OUT = sys.argv[2]
z = zipfile.ZipFile(APK)

def uleb(b, o):
    r = 0; s = 0
    while True:
        x = b[o]; o += 1
        r |= (x & 0x7f) << s
        if not (x & 0x80): break
        s += 7
    return r, o

def muldz(b, o):
    # MUTF-8 terminated
    out = bytearray()
    while True:
        c = b[o]; o += 1
        if c == 0: break
        if c < 0x80: out.append(c)
        else: out.append(c)
    return out.decode('utf-8', 'replace'), o

def dex_strings(b):
    n = struct.unpack_from('<I', b, 56)[0]
    off = struct.unpack_from('<I', b, 60)[0]
    res = []
    for i in range(n):
        so = struct.unpack_from('<I', b, off + i*4)[0]
        _, p = uleb(b, so)
        s, _ = muldz(b, p)
        res.append(s)
    return res

def dex_classes(b):
    sidx = dex_strings(b)
    n_type = struct.unpack_from('<I', b, 64)[0]
    off_type = struct.unpack_from('<I', b, 68)[0]
    types = []
    for i in range(n_type):
        d = struct.unpack_from('<I', b, off_type + i*4)[0]
        types.append(sidx[d])
    n_c = struct.unpack_from('<I', b, 96)[0]
    off_c = struct.unpack_from('<I', b, 100)[0]
    out = []
    for i in range(n_c):
        base = off_c + i*32
        ci, af, si = struct.unpack_from('<III', b, base)
        out.append((types[ci], af, types[si] if si < len(types) else ''))
    return out

all_strings = []
classes = []
for name in z.namelist():
    if re.match(r'classes\d*\.dex$', name):
        b = z.read(name)
        all_strings += dex_strings(b)
        classes += dex_classes(b)

pkg = collections.Counter()
for d, af, sup in classes:
    raw = d.lstrip('L').rstrip(';')
    parts = raw.split('/')
    pkg['/'.join(parts[:2])] += 1

own = [c for c in classes if c[0].startswith('Lcom/secret/prettyhezi')]
urls = set()
for s in all_strings:
    for m in re.finditer(r'(https?://[A-Za-z0-9\.\-_:/?#\[\]@!$&\'()*+,;=%~]+)', s):
        urls.add(m.group(1))
domains = set()
for s in all_strings:
    for m in re.finditer(r'\b((?:[a-z0-9][a-z0-9\-]{1,62}\.)+(?:com|cn|net|org|io|cc|top|xyz|vip|app|me|tv|info|club|site|vip|pro|shop|fun|online|link|live|ink))\b', s, re.I):
        domains.add(m.group(1).lower())

os.makedirs(OUT, exist_ok=True)
with open(os.path.join(OUT, 'dex_classes.txt'), 'w', encoding='utf-8') as f:
    for d, af, sup in sorted(classes):
        f.write('%s  flags=0x%X  super=%s\n' % (d, af, sup))
with open(os.path.join(OUT, 'dex_strings.txt'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted(set(all_strings))))
with open(os.path.join(OUT, 'dex_urls.txt'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted(urls)))
with open(os.path.join(OUT, 'dex_domains.txt'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted(domains)))

print('STRINGS', len(all_strings), 'CLASSES', len(classes), 'OWN', len(own))
print('TOP_PKG', pkg.most_common(15))
print('URLS', len(urls))
for u in sorted(urls)[:60]: print('U ', u)
print('DOMAINS', len(domains))
print(', '.join(sorted(domains))[:2000])
print('--- OWN CLASSES (first 120) ---')
for d, af, sup in sorted(own)[:120]:
    print(d, 'super=' + sup)
