
import sys
try:
    from loguru import logger
    logger.remove()
except Exception:
    pass
from androguard.core.apk import APK
apk = APK(sys.argv[1])
print('APP_NAME', repr(apk.get_app_name()))
print('PKG', apk.get_package(), 'VER', apk.get_androidversion_name(), apk.get_androidversion_code())
try:
    print('ICON', repr(apk.get_app_icon()))
except Exception as e:
    print('ICON_ERR', e)
print('MAIN', apk.get_main_activity())
print('PERMS', apk.get_permissions())
print('ACTIVITIES', len(apk.get_activities()))
