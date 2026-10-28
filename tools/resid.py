
import sys, os
from androguard.core.apk import APK
apk = APK(sys.argv[1]); arsc = apk.get_android_resources()
for rid in (0x7F0E0000, 0x7F1000C3):
    try:
        confs = arsc.get_res_configs(rid)
    except Exception as e:
        print(hex(rid), 'err', e); continue
    for c in confs:
        try:
            v = c.get_value()
            print(hex(rid), c.get_config().get_density(), getattr(v, 'get_value', lambda: v)())
        except Exception as e:
            print(hex(rid), 'val err', e)
