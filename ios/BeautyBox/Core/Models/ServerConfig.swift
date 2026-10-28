import Foundation

/// 服务端下发的全局配置（对应安卓 com.secret.prettyhezi.Server.g）。
struct ServerConfig: Codable {
    struct Ad: Codable {
        let id: Int64?
        let img: String?
        let url: String?
        let type: Int?
        let loading: Int?
    }

    struct ApiServer: Codable {
        let api_url: String?
        let type: Int?
        let sort: Int?
        let cdns: [CDN]?
    }

    struct CDN: Codable {
        let api_url: String?
        let type: Int?
    }

    struct Sys: Codable {
        let about: Int?
        let app_version: String?
        let app_apk: String?
        let share: Bool?
        let sharecode: Bool?
        let sign_in: Bool?
        let sign_up: Bool?
        let trade: Bool?
        let trade_type: String?
        let status: Bool?
        let notice: Int?
        let page: Int?
        let min_score: Int?
        let max_score: Int?
        let upload_min_score: Int?
        let version: Int?
        let systime: Int64?
        let proxy: Bool?
        let cache: String?
    }

    let ads: [Ad]?
    let apiserves: [ApiServer]?
    let sys: Sys?
}

/// 拉取并缓存配置。安卓端启动时做多域名测速（Server.i.c / Server.x），这里保留同样的语义：
/// 先打 /query 找最快节点，再拉 host/json。
final class ConfigService {
    static let shared = ConfigService()
    private let cacheKey = "bb.config.cache"

    func load() async throws -> ServerConfig {
        let cfg: ServerConfig = try await APIClient.shared.get(Endpoint.hostList, as: ServerConfig.self)
        if let data = try? JSONEncoder().encode(cfg) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        return cfg
    }

    func cached() -> ServerConfig? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(ServerConfig.self, from: data)
    }
}
