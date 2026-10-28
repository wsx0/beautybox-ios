
import os, sys, zipfile, plistlib, struct, shutil

out = sys.argv[1]
tmp = os.path.join(os.path.dirname(out), '_ipa_fixture')
shutil.rmtree(tmp, ignore_errors=True)
appdir = os.path.join(tmp, 'Payload', 'BeautyBox.app')
os.makedirs(os.path.join(appdir, 'webapp', 'assets'))
info = {
    'CFBundleIdentifier': 'com.beautybox.ios',
    'CFBundleExecutable': 'BeautyBox',
    'CFBundleShortVersionString': '5.1.52',
    'CFBundleVersion': '120',
    'MinimumOSVersion': '15.0',
    'CFBundlePackageType': 'APPL',
}
plistlib.dump(info, open(os.path.join(appdir, 'Info.plist'), 'wb'))
# 伪造 arm64 Mach-O 头
macho = struct.pack('<IiiIIII', 0xFEEDFACF, 0x0100000C, 0, 6, 0, 0, 0) + b'\x00' * 512
open(os.path.join(appdir, 'BeautyBox'), 'wb').write(macho)
open(os.path.join(appdir, 'webapp', 'index.html'), 'w', encoding='utf-8').write('<html>ok</html>')
open(os.path.join(appdir, 'webapp', 'assets', 'app.js'), 'w', encoding='utf-8').write('//x')

if os.path.exists(out):
    os.remove(out)
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for dirpath, _, files in os.walk(tmp):
        for f in files:
            full = os.path.join(dirpath, f)
            z.write(full, os.path.relpath(full, tmp))
shutil.rmtree(tmp, ignore_errors=True)
print('fixture', out, os.path.getsize(out))
