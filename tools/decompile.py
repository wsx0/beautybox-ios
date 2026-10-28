
import sys, os, traceback
from androguard.misc import AnalyzeAPK
from androguard.core.dex import DEX
from androguard.decompiler.decompiler import DecompilerDAD

APK = sys.argv[1]
OUT = sys.argv[2]
os.makedirs(OUT, exist_ok=True)
a, d, dx = AnalyzeAPK(APK)
print('classes', len(dx.get_classes()), flush=True)
fails = []
done = 0
for c in dx.get_classes():
    name = c.get_name()
    if not name.startswith('Lcom/secret/prettyhezi'):
        continue
    short = name[1:-1].replace('/', '.')
    path = os.path.join(OUT, short + '.java')
    if os.path.exists(path) and os.path.getsize(path) > 0:
        done += 1
        continue
    try:
        src = DecompilerDAD(d, dx).get_source_class(c) if hasattr(DecompilerDAD(d, dx), 'get_source_class') else None
    except Exception as e:
        src = None
    try:
        if src is None:
            dec = DecompilerDAD(d, dx)
            dec.get_source() if hasattr(dec, 'get_source') else None
            src = c.get_source() if hasattr(c, 'get_source') else None
    except Exception:
        src = None
    if not src:
        try:
            src = '// RAW\n' + str(c.get_source())
        except Exception:
            src = None
    if not src:
        fails.append(short)
        try:
            src = '// FAILED\n'
        except Exception:
            pass
    try:
        open(path, 'w', encoding='utf-8').write(src or '')
    except Exception:
        fails.append(short)
    done += 1
    if done % 100 == 0:
        print('done', done, 'fails', len(fails), flush=True)
print('TOTAL', done, 'FAILS', len(fails), flush=True)
open(os.path.join(OUT, '_fails.txt'), 'w', encoding='utf-8').write('\n'.join(fails))
