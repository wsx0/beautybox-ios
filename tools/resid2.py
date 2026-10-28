
import sys
from androguard.core.apk import APK
apk = APK(sys.argv[1]); arsc = apk.get_android_resources()
for rid in (0x7F0E0000, 0x7F1000C3):
    confs = arsc.get_res_configs(rid)
    for item in confs:
        try:
            print(hex(rid), repr(item)[:300])
        except Exception as e:
            print(hex(rid), 'repr err', e)
