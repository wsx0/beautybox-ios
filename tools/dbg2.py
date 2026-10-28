
import struct, zipfile, sys
def u16(b,o): return struct.unpack_from('<H', b, o)[0]
def u32(b,o): return struct.unpack_from('<I', b, o)[0]
z=zipfile.ZipFile(sys.argv[1]); b=z.read('AndroidManifest.xml')
off=11560
print('type=%04X hs=%d size=%d' % (u16(b,off), u16(b,off+2), u32(b,off+4)))
print('line', u32(b,off+8), 'ns', u32(b,off+16), 'name', u32(b,off+20))
print('attrStart', u16(b,off+24), 'attrSize', u16(b,off+26), 'attrCount', u16(b,off+28))
print('hdr hex', b[off:off+40].hex(' '))
