
import logging
logging.disable(logging.CRITICAL)
import sys, zipfile, re, os
from androguard.core.apk import APK
apk = APK(sys.argv[1]); arsc = apk.get_android_resources()
ts = arsc.mTableStrings
def solve(rid):
    out = []
    for cfg, entry in arsc.get_res_configs(rid):
        try:
            out.append((str(cfg)[:34], ts.get_string(entry.get_value_data())))
        except Exception as e:
            out.append((str(cfg)[:34], 'ERR'))
    return out
print('LABEL', solve(0x7F1000C3))
icon = solve(0x7F0E0000)
print('ICON', icon)
z = zipfile.ZipFile(sys.argv[1])
best = None
for cfg, val in icon:
    if 'xxxhdpi' in cfg: best = val
if best is None and icon: best = icon[0][1]
print('ICON_FILE', best)
if best in z.namelist():
    open(sys.argv[2], 'wb').write(z.read(best)); print('SAVED', sys.argv[2])
res = arsc.get_string_resources('com.secret.prettyhezi', 'zh-rCN')
zh = sorted({v for v in res.values() if isinstance(v, str) and re.search(r'[\u4e00-\u9fff]', v)})
print('ZH_COUNT', len(zh))
open(sys.argv[3], 'w', encoding='utf-8').write('\n'.join(zh))
for x in zh[:80]: print(' ', x.replace('\n',' '))
