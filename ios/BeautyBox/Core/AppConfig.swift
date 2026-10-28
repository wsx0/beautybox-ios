import Foundation

/// 运行模式。
/// - nativeCase: 原生 SwiftUI 界面，走 APIClient 请求后端。
/// - webShell: WKWebView 加载 H5，原生桥保留（这是绝大多数同类 App 的 iOS 发行方式）。
enum AppMode: String, CaseIterable, Identifiable {
    case nativeCase = "native"
    case bundledWeb = "bundled"
    case webShell = "web"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nativeCase: return "原生界面"
        case .bundledWeb: return "内置页面"
        case .webShell: return "网页壳"
        }
    }
}

/// 全局配置。发布前只改这里。
enum AppConfig {
    /// 安卓包名，用于对齐上报字段。
    static let androidPackage = "com.secret.prettyhezi"
    /// 安卓版本号 / 版本名。
    static let androidVersionCode = 120
    static let androidVersionName = "5.1.5"
    /// iOS 端版本号（Info.plist 同步）。
    static let appVersion = "5.1.52"

    /// 后端主机。APK 里出现的候选（可达性自行验证，私网 IP 与自签证书都需要放开 ATS）。
    /// 1) https://g333d.com:20053
    /// 2) https://z555b.com:20053
    /// 3) https://45.61.200.158:10053
    /// 4) https://45.61.244.69:10053
    static let apiHosts: [String] = [
        "https://g333d.com:20053",
        "https://z555b.com:20053",
        "https://45.61.200.158:10053",
        "https://45.61.244.69:10053"
    ]

    /// 当前使用的主机，可在「设置」里切换。
    static var apiBaseURL: URL {
        let stored = UserDefaults.standard.string(forKey: "bb.api.host")
        let raw = stored ?? apiHosts[0]
        return URL(string: raw) ?? URL(string: apiHosts[0])!
    }

    /// H5 入口，网页壳模式使用。
    static var webEntryURL: URL { apiBaseURL }

    /// 资源 CDN（图片/视频封面）。
    static let cdnHost = "http://static.allsexbox.com"

    /// 后端不可达时是否退回演示数据，保证模拟器里能看到完整界面。
    static let allowMockFallback = true

    /// 自签证书 / 非标准端口时使用，等价于安卓的 usesCleartextTraffic=true。
    static let allowInsecureTLS = true
}

/// 运行期开关，持久化到 UserDefaults。
final class AppSettings: ObservableObject {
    @Published var mode: AppMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "bb.mode") }
    }

    @Published var host: String {
        didSet { UserDefaults.standard.set(host, forKey: "bb.api.host") }
    }

    @Published var useMockData: Bool {
        didSet { UserDefaults.standard.set(useMockData, forKey: "bb.mock") }
    }

    @Published var webEntryURL: URL

    init() {
        let savedMode = UserDefaults.standard.string(forKey: "bb.mode") ?? AppMode.nativeCase.rawValue
        self.mode = AppMode(rawValue: savedMode) ?? .nativeCase
        let savedHost = UserDefaults.standard.string(forKey: "bb.api.host") ?? AppConfig.apiHosts[0]
        self.host = savedHost
        self.webEntryURL = URL(string: savedHost) ?? URL(string: AppConfig.apiHosts[0])!
        self.useMockData = UserDefaults.standard.object(forKey: "bb.mock") as? Bool ?? false
    }
}
