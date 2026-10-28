# BeautyBox 5.1.52 APK 逆向报告

> 样本：C:\Users\王世雄\Downloads\beautybox_5_1_52.apk
> 大小 4,710,980 字节 · SHA256 39161FFA49CB22D334E8899A2727467DE7CEE94AF74C953FCD9A1746F22DBCAC
> 分析时间 2026-10-28 · 工具：自写 AXML 解析、androguard 4.1.4、jadx 1.5.1（便携 JRE 17）

## 1. 基本信息

| 项 | 值 |
|---|---|
| 包名 | com.secret.prettyhezi |
| 名称 | BeautyBox |
| versionName / versionCode | 5.1.5 / 120 |
| minSdk / targetSdk | 21 / 29 |
| Application | com.secret.prettyhezi.MainApplication |
| 启动 Activity | com.secret.prettyhezi.OuiCrGxF |
| Activity 总数 | 114 |
| DEX | classes.dex (4.99 MB) + classes2.dex (279 KB)，共 6688 个类，其中自有类 1767 |
| 原生库 | lib/arm64-v8a/libali.so、lib/armeabi-v7a/libali.so（JNI 加解密） |
| 依赖特征 | androidx、OkHttp3、io.jsonwebtoken (JWT)、ExoPlayer（视频） |
| 危险权限 | REQUEST_INSTALL_PACKAGES（应用内自升级）、READ/WRITE_EXTERNAL_STORAGE |

应用结构（清单里的包目录）：User / Registration（含 Digital 数字注册码）/ Game / Upload / share（含 digital、digital2 积分与结算）/ ScoreExchange / Payment / Device / Video / message / Cache / Server。

## 2. 网络层（关键结论）

### 2.1 后端地址

com.secret.prettyhezi.Server.i 第 33 行：

    static String[] f7308e = {
        "https://45.61.200.158:10053",
        "https://45.61.244.69:10053",
        "https://z555b.com:20053",
        "https://g333d.com:20053"
    };

启动时逐个打 GET {host}/query?v=1.3 测速，把最快的一个换到下标 0（Server.i.c）。
当前 base 落在 SharedPreferences 的 keyLastServer4，默认值来自 abc.c(1)（native 解出）。
图片 CDN：http://static.allsexbox.com（域名仍可解析，返回 502）。

实测（2026-10-28，本机网络）：四个 https 端点全部在 TLS 握手阶段失败，服务端当前不可达；静态 CDN 返回 502。

### 2.2 请求头（j.v，每个请求都带）

| Header | 值来源 |
|---|---|
| Device | Settings.Secure.android_id |
| Os | Build 版本串 |
| Com | MANUFACTURER(MODEL) |
| Ver | 应用版本（5.1.5） |
| Res | 屏幕分辨率 |
| User-Agent | System.getProperty("http.agent") |
| Authorization | Bearer <JWT>，登录后附加 |

### 2.3 URL 规则

所有业务接口都是：

    {base}{route}

route 形如 user/status/json、box/tips/json?t=2&id=1&page=1、video/unlock/json。
内容类型前缀由 g.b(type) 给出：1 photo、2 video、3 book、4 film、5 rrvideo、6 gallery、7 audio。

共提取到 102 条 route（见 ios/BeautyBox/Core/Network/Endpoint.swift，已按模块归类）。

### 2.4 请求体加密（唯一硬骨头）

- 发请求：j.r/j.u → Server.e.c(String, key) → abc.ea5(byte[], key)，key=1 时加密；key=0 直接发 JSON。
- 收响应：j.c/j.d 回调里 → Server.e.a(byte[], key) → abc.da5(byte[], key)。
- c.abc 全是 native 方法：abe/abl/abm/ams/amu/c/da2/da5/ea2/ea5。
- libali.so 的导出表只有 Java_c_abc_abl/abm/ams/amu 与 JNI_OnLoad，ea5/da5 由 RegisterNatives 动态注册；so 内可见大量 32/64 位十六进制块（密钥/常量混淆），没有明文算法名。

结论：协议本身已经清楚（路由 + 头 + JWT + 明文 JSON 结构），差的是 key=1 时的对称加密算法与密钥。三条可行路径：

1. 运行期抓（最快）：tools/frida_dump_cipher.js，hook c.abc + Server.e + j.t/j.q，直接 dump 明文/密文对，反推算法（AES-CBC 最可能，其次 GCM）。
2. 静态还原：Ghidra 载入 libali.so，从 JNI_OnLoad 里找 RegisterNatives 的 JNINativeMethod 表，拿到 ea5/da5 的真实函数地址再逆。
3. 绕开：只对接 key=0 的接口（GET 类，例如 box/tips、box/items、user/status、node/json、unlock/json 走的是 j.o/j.m，仍是 key=1 POST；真正明文的只有 j.p 与首次 node 探测）。

## 3. 服务端配置模型（Server.g）

- ads[]：广告位（img/url/type/loading/width/height）
- apiserves[]：备用节点（api_url、type、sort、delay、cdns[]）
- sys：全局开关与限制 —— sign_in、sign_up、share、sharecode、trade、trade_type（"|" 分隔的积分交易类型）、status、notice、page、min_score、max_score、upload_min_score、version、app_version、app_apk、systime、proxy、cache

## 4. 与 iOS 端的对应关系

见 report/Android-iOS移植对照表.md。iOS 工程已按该对照表落地（ios/BeautyBox）。

## 5. 证据文件

| 文件 | 内容 |
|---|---|
| extract/AndroidManifest.decoded.txt | 解码后的清单（114 个 Activity、权限、Application） |
| extract/dex_classes.txt · dex_strings.txt | 全量类表与字符串表 |
| extract/dex_urls.txt · dex_domains.txt | 提取到的 URL 与域名 |
| extract/jadx/sources/ | 3089 个 java 反编译文件 |
| extract/zh_strings.txt | zh-rCN 资源字符串 |
| extract/icons/launcher.png | 应用图标（res/CG.png，192px） |
