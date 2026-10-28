
import os, re, collections, sys
root = sys.argv[1]
cn = collections.Counter()
paths = collections.defaultdict(set)
pat = re.compile(r'"([^"\\\n]{2,40})"')
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
                paths[v].add(f)
print('chinese literals:', len(cn))
for v, c in cn.most_common(120):
    print('%4d  %-28s  %s' % (c, v, ','.join(sorted(paths[v])[:2])))
