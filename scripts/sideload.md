# 自签安装指南（Windows 也能做）

目标：把 BeautyBox-unsigned.ipa 装进 iPhone，不用 688 元的开发者账号。

## 一、先拿到 ipa（三选一）

### 路线 A：GitHub Actions（没有 Mac 走这条，免费）

1. 把整个 beautybox_port 目录推进一个 GitHub 仓库（私有仓库也行）：

       cd D:\deepseek项目\软件破解\beautybox_port
       git init
       git add .
       git commit -m "BeautyBox iOS port"
       git branch -M main
       git remote add origin https://github.com/你的账号/仓库名.git
       git push -u origin main

2. 仓库页 → Actions → 左侧 build-ipa → Run workflow。
3. 等 5~10 分钟，在本次运行的 Artifacts 里下载 BeautyBox-unsigned-ipa，解压得到 BeautyBox-unsigned.ipa。

工作流在 .github/workflows/ios-ipa.yml，步骤是：同步 webapp → 生成工程 → 归档 → 组 Payload → 校验 → 上传产物。

### 路线 B：本机有 Mac

    ./scripts/build_ipa.sh
    # 产物 build/BeautyBox-unsigned.ipa

已有开发者账号、想直接出签名包：

    TEAM_ID=你的10位TeamID ./scripts/build_ipa.sh
    # 产物 build/export/BeautyBox.ipa

### 路线 C：其它 macOS CI

Codemagic / AppCircle / Bitrise 都有免费额度，把 scripts/build_ipa.sh 当构建脚本，产物路径填 build/BeautyBox-unsigned.ipa。

## 二、拿到先校验（别拿坏包去签）

    python scripts/verify_ipa.py build/BeautyBox-unsigned.ipa

正常输出形如：

    bundle: BeautyBox.app
    executable: BeautyBox arch: arm64
    bundle id: com.beautybox.ios
    version: 5.1.52 (120)  min iOS: 15.0
    webapp files: 15
    [OK] 结构完整，可以拿去自签

## 三、签名安装（Sideloadly 为例）

1. 装 iTunes（只要 Apple Mobile Device 驱动，微软商店版即可）。
2. 打开 Sideloadly，数据线连 iPhone，手机上点「信任此电脑」。
3. 把 BeautyBox-unsigned.ipa 拖进 Sideloadly 窗口。
4. Apple ID 填自己的（免费账号可用），点 Start，等进度走完。
5. iPhone：设置 → 通用 → VPN与设备管理 → 信任你的开发者证书。
6. 主屏出现 BeautyBox 图标，打开即用。

其它工具同理：AltStore / SideStore（Wi-Fi 自动续签）、爱思助手（工具箱 → IPA 签名）、
iOS App Signer（Mac，配合证书与描述文件）。

## 四、常见坑

| 现象 | 原因 | 处理 |
|---|---|---|
| 0xE8008015 | 证书/描述文件不匹配 | 重签，确认设备 UDID 在描述文件内 |
| 0xE800801C | 设备系统低于包的最低版本 | 工程最低 iOS 15，换机或改部署目标重编 |
| Unable to install | 可执行文件架构不对 | 跑 verify_ipa.py 看 arch 是否 arm64 |
| 打开即闪退 | 内置页面没进包 | 检查包里是否有 Payload/BeautyBox.app/webapp/index.html |
| 7 天后打不开 | 免费账号证书 7 天有效期 | 到期重签；AltStore 可自动续签 |
| bundle id 变了 | 自签工具会改写标识 | 正常，功能不受影响 |

## 五、包里有什么

    Payload/BeautyBox.app/
      BeautyBox                  可执行文件（arm64）
      Info.plist                 bundle id com.beautybox.ios，最低 iOS 15
      Assets.car                 图标（取自原 APK 的 res/CG.png）
      webapp/                    38 个页面（index.html + assets + icons）
      PrivacyInfo.xcprivacy

装好后进「我的 → 设置 → 运行模式」，可切「原生界面 / 内置页面 / 网页壳」。
内置页面读的就是包里这份 webapp，断网也可用。
