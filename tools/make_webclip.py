
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 iOS WebClip 描述文件（.mobileconfig），iPhone 上双击即可安装成桌面 App 图标。

用法:
  python make_webclip.py --url https://g333d.com:20053/ --name BeautyBox \
      --icon ..\extract\icons\launcher.png --out BeautyBox.mobileconfig
无签名即可安装（设置 -> 已下载描述文件 -> 安装）。
"""
import argparse, base64, hashlib, uuid, os

TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>FullScreen</key><true/>
      <key>IgnoreManifestScope</key><true/>
      <key>IsRemovable</key><true/>
      <key>Label</key><string>{name}</string>
      <key>PayloadDescription</key><string>{name} 网页桌面图标</string>
      <key>PayloadDisplayName</key><string>{name}</string>
      <key>PayloadIdentifier</key><string>com.beautybox.webclip.{slug}</string>
      <key>PayloadType</key><string>com.apple.webClip.managed</string>
      <key>PayloadUUID</key><string>{uuid1}</string>
      <key>PayloadVersion</key><integer>1</integer>
      <key>Precomposed</key><true/>
      <key>URL</key><string>{url}</string>
      {icon}
    </dict>
  </array>
  <key>PayloadDescription</key><string>安装 {name} 到主屏幕</string>
  <key>PayloadDisplayName</key><string>{name}</string>
  <key>PayloadIdentifier</key><string>com.beautybox.profile.{slug}</string>
  <key>PayloadOrganization</key><string>BeautyBox</string>
  <key>PayloadRemovalDisallowed</key><false/>
  <key>PayloadType</key><string>Configuration</string>
  <key>PayloadUUID</key><string>{uuid2}</string>
  <key>PayloadVersion</key><integer>1</integer>
</dict>
</plist>
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--url', required=True)
    ap.add_argument('--name', default='BeautyBox')
    ap.add_argument('--icon', default='')
    ap.add_argument('--out', default='BeautyBox.mobileconfig')
    a = ap.parse_args()

    icon_xml = ''
    if a.icon and os.path.exists(a.icon):
        b64 = base64.b64encode(open(a.icon, 'rb').read()).decode()
        icon_xml = '<key>Icon</key>\n      <data>%s</data>' % b64

    slug = hashlib.md5(a.url.encode()).hexdigest()[:8]
    body = TEMPLATE.format(
        name=a.name, url=a.url, slug=slug, icon=icon_xml,
        uuid1=str(uuid.uuid4()).upper(), uuid2=str(uuid.uuid4()).upper(),
    )
    with open(a.out, 'w', encoding='utf-8') as f:
        f.write(body)
    print('written', a.out, os.path.getsize(a.out), 'bytes')
    print('install: AirDrop / 邮件 / 本地 http 下载后，在 iPhone 设置里安装描述文件')

if __name__ == '__main__':
    main()
