
import zipfile, plistlib, os
apk = r'C:\Users\王世雄\Downloads\beautybox_5_1_52.apk'
out = r'D:\deepseek项目\软件破解\beautybox_port\extract\icons\CG.png'
z = zipfile.ZipFile(apk)
open(out,'wb').write(z.read('res/CG.png'))
print('icon', os.path.getsize(out))
