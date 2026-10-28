
import sys, re, json
from androguard.core.apk import APK
apk = APK(sys.argv[1])
arsc = apk.get_android_resources()
p = 'com.secret.prettyhezi'
res = arsc.get_string_resources(p, 'zh-rCN')
print('zh-rCN entries', len(res))
vals = [v for v in res.values() if isinstance(v, str) and v.strip()]
zh = [v for v in vals if re.search(r'[\u4e00-\u9fff]', v)]
print('ZH', len(zh))
with open(sys.argv[2], 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted(set(zh))))
for x in sorted(set(zh))[:200]:
    print('  ' + x.replace('\n', ' '))
