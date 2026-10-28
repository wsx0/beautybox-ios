
import sys, json, os, re
from androguard.core.apk import APK
apk = APK(sys.argv[1])
arsc = apk.get_android_resources()
pkgs = arsc.get_packages_names()
print('PKGS', pkgs)
out = {}
for p in pkgs:
    for loc in arsc.get_locales(p):
        try:
            res = arsc.get_string_resources(p, loc)
        except Exception as e:
            continue
        if not res: continue
        key = p + '/' + loc
        out[key] = res
        print('LOCALE', key, len(res))
# dump default locale strings
allstr = {}
for k, v in out.items():
    for rid, val in v.items():
        if isinstance(val, str) and val.strip():
            allstr.setdefault(val, []).append(rid)
zh = [v for v in allstr if re.search(r'[\u4e00-\u9fff]', v)]
print('UNIQUE_STRINGS', len(allstr), 'ZH', len(zh))
open(sys.argv[2], 'w', encoding='utf-8').write('\n'.join(sorted(allstr)))
print('--- SAMPLE ZH ---')
for x in sorted(zh)[:120]:
    print(' ', x.replace('\n', ' '))
