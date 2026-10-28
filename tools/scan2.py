
import re, collections, os
P = r'D:\deepseek项目\软件破解\beautybox_port\extract'
strs = open(os.path.join(P,'dex_strings.txt'), encoding='utf-8').read().split('\n')
print('total', len(strs))
paths = [x for x in strs if re.fullmatch(r'/[A-Za-z0-9_\-/{}\$\.]{2,60}', x)]
print('--- PATHS', len(paths))
for x in sorted(set(paths))[:120]: print(' ', x)
api = [x for x in strs if re.search(r'api|Api|API', x) and len(x) < 80]
print('--- API-ish', len(api))
for x in sorted(set(api))[:80]: print(' ', x)
cls = open(os.path.join(P,'dex_classes.txt'), encoding='utf-8').read().split('\n')
own = [c.split('  ')[0] for c in cls if c.startswith('Lcom/secret/prettyhezi')]
sub = collections.Counter()
for c in own:
    raw = c[1:-1]
    p = raw.split('/')
    sub['/'.join(p[1:3]) if len(p) > 2 else p[1]] += 1
print('--- SUBPKG', len(sub))
for k,v in sub.most_common(40): print(' %-28s %d' % (k,v))
print('--- key-ish strings')
for x in sorted(set(strs)):
    if re.search(r'(sign|Sign|token|Token|Bearer|aes|AES|md5|MD5|secret|Secret|User-Agent|platform)', x) and 2 < len(x) < 60:
        print(' ', repr(x))
