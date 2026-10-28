
import re, sys
html = open(sys.argv[1] + r'\index.html', encoding='utf-8').read()
js = open(sys.argv[1] + r'\assets\app.js', encoding='utf-8').read()
ids = set(re.findall(r'id="([^"]+)"', html))
used = set(re.findall(r"el\('([^']+)'\)", js))
missing = sorted(used - ids)
print('html ids:', len(ids))
print('js el() 引用:', len(used))
print('缺失:', missing if missing else 'none')
# 动态 id: el('page-' + name) 之类
dyn = sorted(x for x in used if '-' in x)
print('含连字符的引用(可能是动态拼接):', dyn)
for d in dyn:
    if d not in ids:
        print('  -> 动态，检查模板:', d)
