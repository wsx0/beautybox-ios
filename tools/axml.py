
import sys, struct, zipfile, io, re, json, os, collections

APK = sys.argv[1]
OUT = sys.argv[2]

def u16(b,o): return struct.unpack_from('<H', b, o)[0]
def u32(b,o): return struct.unpack_from('<I', b, o)[0]

class StrPool:
    def __init__(self, buf, off):
        assert u16(buf,off)==0x0001, hex(u16(buf,off))
        hsize=u16(buf,off+2); size=u32(buf,off+4)
        cnt=u32(buf,off+8); scnt=u32(buf,off+12); flags=u32(buf,off+16)
        sstart=u32(buf,off+20)
        self.utf8 = bool(flags & 0x100)
        self.strings=[]
        base=off
        for i in range(cnt):
            so=u32(buf, base+28+i*4)
            p=base+sstart+so
            if self.utf8:
                # uleb-ish: two varints (utf16len, bytelen)
                n=buf[p]; p+=1
                if n & 0x80: p+=1
                ln=buf[p]; p+=1
                if ln & 0x80:
                    ln=((ln & 0x7f)<<8)|buf[p]; p+=1
                self.strings.append(buf[p:p+ln].decode('utf-8','replace'))
            else:
                ln=struct.unpack_from('<H',buf,p)[0]; p+=2
                if ln & 0x8000:
                    ln=((ln & 0x7fff)<<16)|struct.unpack_from('<H',buf,p)[0]; p+=2
                self.strings.append(buf[p:p+ln*2].decode('utf-16-le','replace'))
        self.end = base+size

def parse_axml(buf):
    assert u16(buf,0)==0x0003
    total=u32(buf,4)
    off=u16(buf,2)
    pool=None; resmap={}
    events=[]
    while off < total:
        ctype=u16(buf,off); hsize=u16(buf,off+2); csize=u32(buf,off+4)
        if csize==0: break
        if ctype==0x0001:
            pool=StrPool(buf,off)
        elif ctype==0x0180:
            n=(csize-hsize)//4
            for i in range(n): resmap[u32(buf,off+hsize+i*4)]=i
        elif ctype==0x0102:
            line=u32(buf,off+8)
            name=pool.strings[u32(buf,off+20)]
            astart=u16(buf,off+24); acount=u16(buf,off+28); abase=off+16+astart
            attrs=[]
            for i in range(acount):
                a=abase+i*20
                ns=u32(buf,a); anem=u32(buf,a+4); raw=u32(buf,a+8)
                dtype=buf[a+15]; data=u32(buf,a+16)
                an = pool.strings[anem]
                if dtype==0x03:
                    val = pool.strings[data] if data < len(pool.strings) else '?'
                elif dtype==0x01:
                    val = '0x%08X' % data
                elif dtype==0x02:
                    val = ('1' if data else '0')
                elif dtype==0x12:
                    val = 'true' if data else 'false'
                elif dtype==0x10:
                    val = str(struct.unpack('<i', struct.pack('<I', data))[0])
                elif dtype==0x11:
                    val = '0x%X' % data
                else:
                    val = '%s:%s' % (hex(dtype), data)
                attrs.append((an, val, dtype, data))
            events.append(('start', name, attrs, line))
        elif ctype==0x0103:
            events.append(('end', None, None, 0))
        off += csize
    return events, pool

z = zipfile.ZipFile(APK)
man = z.read('AndroidManifest.xml')
events, pool = parse_axml(man)
lines=[]
depth=0
for ev in events:
    if ev[0]=='start':
        attrs=' '.join('%s=%s' % (a[0], a[1]) for a in ev[2])
        lines.append('  '*depth + '<%s %s>' % (ev[1], attrs))
        depth+=1
    else:
        depth=max(0,depth-1)

os.makedirs(OUT, exist_ok=True)
with open(os.path.join(OUT,'AndroidManifest.decoded.txt'),'w',encoding='utf-8') as f:
    f.write('\n'.join(lines))
print('MANIFEST_LINES', len(lines))
print('\n'.join(lines[:40]))
