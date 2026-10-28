
import os, re, collections, sys
root = r'D:\deepseek项目\软件破解\beautybox_port\extract\jadx\sources'
out = r'D:\deepseek项目\软件破解\beautybox_port\extract\cn_literals.txt'
cn = collections.Counter()
pat = re.compile(r'"([^"\\\n]{2,44})"')
for dirpath, _, files in os.walk(root):
    for f in files:
        if not f.endswith('.java'): continue
        p = os.path.join(dirpath, f)
        try:
            s = open(p, encoding='utf-8', errors='ignore').read()
        except Exception:
            continue
        for m in pat.finditer(s):
            v = m.group(1)
            if re.search(r'[\u4e00-\u9fff]', v):
                cn[v] += 1
with open(out, 'w', encoding='utf-8') as fh:
    for v, c in cn.most_common():
        fh.write('%d\t%s\n' % (c, v))
print('wrote', out, len(cn))
