# tools/gen_xcodeproj.py — 生成 BeautyBox 的 Xcode 15 工程

1. 生成：`python tools/gen_xcodeproj.py` — 扫描 `ios/BeautyBox/`，写 `ios/BeautyBox.xcodeproj/project.pbxproj` 与共享 scheme `xcshareddata/xcschemes/BeautyBox.xcscheme`。
2. 生成 + 校验：`python tools/gen_xcodeproj.py --verify`（首次会自动 `pip install pbxproj`，任一断言不过就打印原因并 exit 1）。
3. 只校验：`python tools/gen_xcodeproj.py --verify-only`；换源目录 `--ios-dir PATH`；只打统计 `--quiet`。
4. 幂等：UUID = md5(用途 + 相对路径) 前 24 位，重复运行输出字节级一致；新增/删除文件后直接重跑即可。
5. 收录：`*.swift` → Sources；`*.xcassets`/`*.xcprivacy`/`*.json`/`*.plist`(除 Info.plist)/`*.mp4`/`*.ttf` 等 → Resources；目录结构 1:1 映射 PBXGroup。
6. 前置：`ios/BeautyBox/Resources/Info.plist` 必须存在（`INFOPLIST_FILE` 指向它，`GENERATE_INFOPLIST_FILE=NO`，且它不会进 Resources）。
7. 典型输出：`[verify] OK / object 数 ... / swift 全部进入 Sources: N/N`。
