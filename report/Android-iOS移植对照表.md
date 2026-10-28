# Android → iOS 移植对照表

## 1. 平台能力映射

| Android（本 APK 实际用法） | iOS 等价实现 | 工程内位置 |
|---|---|---|
| Activity / Fragment（114 个） | SwiftUI View + NavigationStack/NavigationView | Features/** |
| AsyncTask + 回调 e.c(String) | async/await + URLSession.data(for:) | Core/Network/APIClient.swift |
| OkHttp（信任所有证书 + 自定义 DNS） | URLSession + InsecureTrustDelegate（ATS 放开） | Core/Network/APIClient.swift |
| SharedPreferences | UserDefaults（配置）/ Keychain（token） | Core/AppConfig.swift、Core/KeychainStore.swift |
| ExoPlayer（DASH/HLS） | AVPlayer / VideoPlayer（AVKit） | Features/Player/VideoPlayerScreen.swift |
| Glide / 自定义图片加载 | AsyncImage + 渐变占位 | Features/Home/VideoCardView.swift |
| RecyclerView + GridLayoutManager | LazyVGrid / List | Features/Home/HomeView.swift |
| ViewPager2 + TabLayout | TabView / 分段 Picker | App/RootView.swift、Features/Profile/SettingsView.swift |
| Toast / Snackbar | 简短 Alert 或自定义浮层 | 各 ViewModel 的 errorText |
| NotificationManager | UNUserNotificationCenter | 待接入（后端 notify/* 已列路由） |
| FileProvider + 相册选择 | PhotosPicker / UIDocumentPicker | Features/Upload/UploadView.swift |
| WebView + JS 桥 | WKWebView + WKScriptMessageHandler | Features/Web/WebContainerView.swift |
| JNI（libali.so 的 AES） | CryptoKit（AES.GCM / AES.CBC），密钥需还原 | Core/Network/BodyCipher.swift |
| 应用内自升级（REQUEST_INSTALL_PACKAGES） | 无对应能力；改走 App Store / TestFlight / 企业签 | 报告第 2.4 节 |
| 屏幕方向锁定 portrait | UISupportedInterfaceOrientations 只留 Portrait | Resources/Info.plist |

## 2. 后端接口对齐

| 业务 | route | iOS 常量 |
|---|---|---|
| 登录/注册 | auth/json | Endpoint.auth |
| 用户信息 | user/status/json?id= | Endpoint.userStatus |
| 内容列表 | box/tips/json?t=&id=&page= | Endpoint.boxTips |
| 解释锁 | {type}/unlock/json | Endpoint.unlock(_:) |
| 试看 | {type}/try/json?id= | Endpoint.tryPlay(_:) |
| 节点列表 | {type}/node/json | Endpoint.nodeList(_:) |
| 配置 | host/json | Endpoint.hostList |
| 消息 | notify/message/list/json、chat/json、chat/msgs/json | Endpoint.notifyMessageList 等 |
| 交易 | transaction/* | Endpoint.transaction* |
| 积分商城 | shop/score/* | Endpoint.shopScore* |
| 上传审核 | repeatedly/*、report/* | Endpoint.report* |

## 3. 请求头对齐

安卓：Device / Os / Com / Ver / Res / User-Agent / Authorization: Bearer <JWT>
iOS：device / os=ios / version / versionCode / device(UUID) / User-Agent / Authorization: Bearer <JWT>
（字段名以服务端实际校验为准；若后端严格校验 Device 形态，需要按 android_id 的 16 位十六进制格式伪造，见 Core/Device/UIDeviceModel.swift 注释）

## 4. 移植边界

- 能 1:1 复刻：界面结构、路由、JWT 流程、播放器、列表分页、设置项、WebClip 壳。
- 需要额外工作：请求体加密（libali.so）—— 还原后才能与现网后端互通；未还原时工程走 PlainCipher + 演示数据。
- 无法搬运：安卓自升级逻辑、APK 签名校验、部分 JNI 与设备指纹（跨平台必然不同）。
