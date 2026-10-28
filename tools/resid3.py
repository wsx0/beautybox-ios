
import sys, zipfile
from androguard.core.apk import APK
apk = APK(sys.argv[1]); arsc = apk.get_android_resources()
ts = arsc.mTableStrings
for rid in (0x7F0E0000, 0x7F1000C3):
    for cfg, entry in arsc.get_res_configs(rid):
        data = entry.get_value_data()
        try:
            val = ts.get_string(data)
        except Exception as e:
            val = 'ERR ' + str(e)
        print(hex(rid), str(cfg)[:40], '->', val)
z = zipfile.ZipFile(sys.argv[1])
name = None
for cfg, entry in arsc.get_res_configs(0x7F0E0000):
    if 'xxxhdpi' in str(cfg):
        name = ts.get_string(entry.get_value_data())
print('ICON_FILE', name)
if name and name in z.namelist():
    open(sys.argv[2], 'wb').write(z.read(name))
    print('saved', sys.argv[2])
