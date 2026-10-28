#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""校验 ipa 结构（自签前先过一遍，别拿坏包去签）

用法: python verify_ipa.py build/BeautyBox-unsigned.ipa
检查: Payload/*.app、Info.plist 关键键、可执行文件 Mach-O 架构、
      内置 webapp/index.html、体积。
"""
import plistlib
import struct
import sys
import zipfile
import os

ARCH = {
    0x0100000C: 'arm64', 0x0200000C: 'arm64e',
    0x0000000C: 'armv7', 0x00000007: 'x86', 0x01000007: 'x86_64',
}
MH_MAGIC = 0xFEEDFACE
MH_MAGIC_64 = 0xFEEDFACF
FAT_MAGIC = 0xCAFEBABE
FAT_MAGIC_64 = 0xCAFEBABF

def arch_names(blob):
    if len(blob) < 8:
        return ['too-short']
    magic = struct.unpack('>I', blob[:4])[0]
    le = struct.unpack('<I', blob[:4])[0]
    if le in (MH_MAGIC, MH_MAGIC_64):
        cpu = struct.unpack('<I', blob[4:8])[0]
        return [ARCH.get(cpu, hex(cpu))]
    if magic in (FAT_MAGIC, FAT_MAGIC_64):
        n = struct.unpack('>I', blob[4:8])[0]
        out = []
        base = 8
        step = 20 if magic == FAT_MAGIC else 32
        for i in range(min(n, 8)):
            off = base + i * step
            if off + 4 > len(blob):
                break
            cpu = struct.unpack('>I', blob[off:off + 4])[0]
            out.append(ARCH.get(cpu, hex(cpu)))
        return out or ['fat-empty']
    return ['not-macho:' + blob[:4].hex()]

def main():
    if len(sys.argv) < 2:
        print('usage: verify_ipa.py <file.ipa>')
        return 2
    path = sys.argv[1]
    if not os.path.exists(path):
        print('[FAIL] 文件不存在:', path)
        return 2
    size = os.path.getsize(path)
    print('ipa:', path)
    print('size: %.2f MB (%d bytes)' % (size / 1048576.0, size))

    fail = []
    warn = []
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        apps = sorted({n.split('/')[1] for n in names
                       if n.startswith('Payload/') and n.count('/') >= 2})
        if not apps:
            print('[FAIL] 没有 Payload/*.app')
            return 1
        app = apps[0]
        prefix = 'Payload/%s/' % app
        print('bundle:', app)

        info_name = prefix + 'Info.plist'
        if info_name not in names:
            fail.append('缺 Info.plist')
            info = {}
        else:
            info = plistlib.loads(z.read(info_name))

        exe = info.get('CFBundleExecutable', app)
        exe_path = prefix + exe
        if exe_path not in names:
            fail.append('缺可执行文件 ' + exe)
            archs = []
        else:
            archs = arch_names(z.read(exe_path)[:4096])
        print('executable:', exe, 'arch:', ','.join(archs))

        bid = info.get('CFBundleIdentifier', '')
        ver = info.get('CFBundleShortVersionString', '')
        build = info.get('CFBundleVersion', '')
        ios_min = info.get('MinimumOSVersion', '')
        print('bundle id:', bid)
        print('version: %s (%s)  min iOS: %s' % (ver, build, ios_min))
        if not bid:
            fail.append('CFBundleIdentifier 为空（自签必失败）')
        if not ios_min:
            fail.append('缺 MinimumOSVersion')

        web = [n for n in names if n.startswith(prefix + 'webapp/')]
        print('webapp files:', len(web))
        if not web:
            warn.append('包里没有 webapp/，内置页面模式不可用（网页壳模式仍可远程加载）')
        elif prefix + 'webapp/index.html' not in names:
            fail.append('webapp 里没有 index.html')

        if archs and not any(a.startswith('arm64') for a in archs):
            fail.append('可执行文件不含 arm64 架构')

    for w in warn:
        print('[WARN] ' + w)
    if fail:
        print('[FAIL] ' + '; '.join(fail))
        return 1
    print('[OK] 结构完整，可以拿去自签')
    return 0

if __name__ == '__main__':
    sys.exit(main())
