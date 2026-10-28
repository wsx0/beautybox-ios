
import struct, zipfile, sys
def u16(b,o): return struct.unpack_from('<H', b, o)[0]
def u32(b,o): return struct.unpack_from('<I', b, o)[0]
z=zipfile.ZipFile(sys.argv[1]); b=z.read('AndroidManifest.xml')
print('file size', len(b))
off=u16(b,2); total=u32(b,4); print('hdr', off, total)
while off < total:
    t=u16(b,off); hs=u16(b,off+2); cs=u32(b,off+4)
    print('chunk type=0x%04X hs=%d size=%d at %d' % (t,hs,cs,off))
    if t==1:
        cnt=u32(b,off+8); scnt=u32(b,off+12); flags=u32(b,off+16); ss=u32(b,off+20); st=u32(b,off+24)
        print('  pool cnt=%d scnt=%d flags=0x%X strStart=%d styStart=%d' % (cnt,scnt,flags,ss,st))
        print('  first offsets', [u32(b,off+hs+i*4) for i in range(min(6,cnt))])
        p=off+ss
        print('  raw head', b[p:p+40])
    if cs==0: break
    off+=cs
