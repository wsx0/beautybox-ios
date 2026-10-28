
import sys, os, re

def strip(code):
    out=[]; i=0; n=len(code); mode=None
    while i<n:
        ch=code[i]; nx=code[i+1] if i+1<n else ''
        if mode is None:
            if ch=='/' and nx=='/':
                while i<n and code[i]!='\n': i+=1
                continue
            if ch=='/' and nx=='*':
                i+=2
                while i+1<n and not (code[i]=='*' and code[i+1]=='/'): i+=1
                i+=2; continue
            if ch=='"':
                if code[i:i+3]=='"""':
                    i+=3
                    while i+2<n and code[i:i+3]!='"""': i+=1
                    i+=3; continue
                i+=1
                while i<n:
                    if code[i]=='\\': i+=2; continue
                    if code[i]=='"': i+=1; break
                    i+=1
                continue
            out.append(ch); i+=1
        else:
            i+=1
    return ''.join(out)

bad=[]
for root,_,files in os.walk(sys.argv[1]):
    for f in files:
        if not f.endswith('.swift'): continue
        p=os.path.join(root,f)
        src=open(p,encoding='utf-8').read()
        s=strip(src)
        for a,b in [('{','}'),('[',']'),('(',')')]:
            if s.count(a)!=s.count(b):
                bad.append((p, a+b, s.count(a), s.count(b)))
print('files', sum(1 for r,_,fs in os.walk(sys.argv[1]) for x in fs if x.endswith('.swift')))
if bad:
    for b in bad: print('UNBALANCED', b)
else:
    print('ALL BALANCED')
