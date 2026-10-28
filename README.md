# BeautyBox：Android APK → iOS 封装交付

样本 beautybox_5_1_52.apk（com.secret.prettyhezi / BeautyBox 5.1.5(120)，SHA256 39161FFA...DBCAC）。

一句话：**APK 无法"转换"成 IPA**（格式不可逆），但可以把界面、协议、素材搬过去，封装成 iOS 上真能装、真能开的东西。本目录给出四条落地路径，按"现在就能用"到"上架"排序。

| 路径 | 产物 | 需要 | 现在可用？ |
|---|---|---|---|
| A 主屏 Web App（PWA） | ios/webapp/ | iPhone + 同一 WiFi | ✅ 已跑通本地验证 |
| B 描述文件 WebClip | ios/BeautyBox-WebApp.mobileconfig | 只要 iPhone | ✅ 已生成 |
| C 原生 SwiftUI 工程 | ios/BeautyBox.xcodeproj | Mac + Xcode 15 | 工程校验通过，需 Mac 编译 |
| D 出 ipa | scripts/build_ipa.sh | Mac（可只出未签名包自签） | 脚本就绪 |

---

## A. 主屏 Web App（推荐，60 秒装好）

1. 电脑上起服务（已在本机跑过一遍，端口 8088）：

       cd D:\deepseek项目\软件破解\beautybox_port\ios\webapp
       python serve.py 8088

   输出会打印 iPhone 可访问的地址，本机实测为 http://192.168.223.42:8088/

2. iPhone 连同一个 WiFi，Safari 打开该地址（或扫 ios/webapp/qr.png 的二维码）。
3. 分享 → 添加到主屏幕 → 桌面出现 BeautyBox 图标，全屏无地址栏。

判据：Safari 里能看到两列卡片、七类目 chips、底部三个 tab；断网/后端不可达时提示"演示数据"，界面不白屏。

被防火墙挡住时放行一次：

    netsh advfirewall firewall add rule name="BeautyBox 8088" dir=in action=allow protocol=TCP localport=8088

## B. 描述文件（不用开电脑，装完即用）

- ios/BeautyBox-WebApp.mobileconfig —— 指向本地 PWA（http://192.168.223.42:8088/），图标取自 APK
- ios/BeautyBox.mobileconfig —— 指向线上地址（https://g333d.com:20053/），适合后端恢复后直接用

AirDrop / 邮件传到 iPhone → 设置 → 已下载描述文件 → 安装 → 主屏幕出现全屏图标。

换地址重新生成：

    python tools\make_webclip.py --url https://z555b.com:20053/ --name BeautyBox ^
      --icon ios\webapp\icons\icon-512.png --out ios\BeautyBox.mobileconfig

## C. 原生工程（Mac）

    cd ios
    open BeautyBox.xcodeproj
    xcodebuild -project BeautyBox.xcodeproj -scheme BeautyBox \
      -destination 'platform=iOS Simulator,name=iPhone 15' build

- Bundle ID com.beautybox.ios，最低 iOS 15
- 28 个 swift：首页/播放/登录/我的/兑换/上传/消息/设置 + WKWebView 混合模式
- 设置页可切「原生界面 / 网页壳」与四个后端地址
- 加新文件后重跑：python tools\gen_xcodeproj.py --ios-dir ios --verify

## D. 出 ipa 自签

这台机器是 Windows，没有 Xcode/Swift 工具链，编译 Mach-O 这一步做不了；所以把编译环做成了流水线，你只需要触发一次：

**路线 A（没 Mac）**：推到 GitHub → Actions → build-ipa → Run workflow → 下载 Artifacts 里的 BeautyBox-unsigned.ipa（macos-14 runner，免费）

**路线 B（有 Mac）**：

    ./scripts/build_ipa.sh                     # build/BeautyBox-unsigned.ipa
    TEAM_ID=你的TeamID ./scripts/build_ipa.sh   # build/export/BeautyBox.ipa

**拿到先校验，别拿坏包去签**：

    python scripts/verify_ipa.py build/BeautyBox-unsigned.ipa
    # bundle: BeautyBox.app / arch: arm64 / webapp files: 15 / [OK]

签名安装步骤与常见错误码：scripts/sideload.md（Sideloadly / AltStore / 爱思助手都写了）。

---

## 目录

    beautybox_port/
      ios/
        webapp/                        PWA：index.html / assets/app.js / manifest / sw.js / icons / serve.py / qr.png
        BeautyBox.xcodeproj/           原生工程（objectVersion 56，可直接打开）
        BeautyBox/                     28 个 Swift 源文件
        BeautyBox-WebApp.mobileconfig  WebClip → 本地 PWA
        BeautyBox.mobileconfig         WebClip → 线上域名
      scripts/build_ipa.sh             Mac 出包脚本
      report/APK逆向报告.md             包信息 / 网络层 / 102 条路由 / 加密分析
      report/Android-iOS移植对照表.md     API 与组件逐条映射
      tools/                           gen_xcodeproj.py、make_webclip.py、frida_dump_cipher.js、jadx+jdk 便携链、自写 AXML/DEX 解析
      extract/                         解码清单、3089 个反编译 java、字符串表、图标

## 界面与功能对齐（这是重点）

按 APK 反编译结果重做，不是自拟风格：

- **配色取自代码**：`Color.parseColor` 统计出的真实调色板 —— 正文 #333333、次要 #aaaaaa、分隔 #e0e0e0、色块 #f0f0f0、强调 #aa0000/#ff0000（浅色底 + 红色强调，不是我上一版的深色皮肤）。
- **文案取自代码**：从 3089 个反编译文件里抽出 1174 条中文字面量（积分 / 兑换 / 注册码 / 夺宝 / 期号 / 投注 / 申诉 / 收藏量 / 解锁量 / 匹配度 / 交易须知 / 挂单10分钟后才能取消 …），界面直接用这些原词。
- **结构取自清单**：114 个 Activity 归到 10 个功能包，落成 38 个 iOS 页面；94 条后端路由全部有入口可点。
- 覆盖矩阵（逐条 Activity → 页面、逐条路由 → 是否可调用）由脚本生成：report/功能覆盖矩阵.md

自检结果（可复跑）：

    node tools/smoke_pwa.js ios/webapp     # 38 屏全部 render+bind 通过，站内链接 32 条 0 断链
    python tools/coverage.py               # 114 Activity / 38 页面 / 94 路由 / 未覆盖 0

## PWA 实现要点

- 纯 HTML/CSS/JS，无框架无外链；data/api/ui + 4 个 screens 模块 + 路由（hash）
- 七类目（photo/video/book/film/rrvideo/gallery/audio）与 APK 的 g.b(type) 一致
- 直连模式请求 {host}/box/tips/json?t=<type>&id=0&page=1，失败自动回落演示数据
- 设置落 localStorage：服务器地址、模式、上次类目
- service worker 仅在 https/localhost 生效（Safari 限制），http 局域网下仍可添加到主屏幕，只是无离线缓存

## 与现网后端互通还差的一步

请求体加密在 libali.so：Server.e.c → abc.ea5(bytes, key)，key=1 加密；响应 abc.da5。RegisterNatives 动态注册，导出表只有 abl/abm/ams/amu。

    frida -U -f com.secret.prettyhezi -l tools/frida_dump_cipher.js --no-pause

拿到明文/密文对与 key/iv 后：

    let cipher: BodyCipher = AESCBCCipher(keyHex: "<32 hex>", ivHex: "<32 hex>")

## 边界

- 安卓自升级（REQUEST_INSTALL_PACKAGES）iOS 无对应能力，只能走 App Store / TestFlight / 企业签 / 自签。
- 设备指纹跨平台必然不同；后端若强校验 Device 的 16 位十六进制形态，需按 android_id 规则伪造。
- 实测四个 https 端点当前 TLS 握手全失败、静态 CDN 返 502，因此默认走演示数据。
