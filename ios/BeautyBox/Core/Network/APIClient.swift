import Foundation

/// 与安卓 OkHttp 客户端对应的 URLSession 封装。
/// 关键点：自签证书放行（等价 TrustManager 全信任）、统一头、JWT 透传、超时与重试。
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let trustDelegate = InsecureTrustDelegate()

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "User-Agent": APIClient.userAgent
        ]
        session = URLSession(configuration: config, delegate: AppConfig.allowInsecureTLS ? trustDelegate : nil, delegateQueue: nil)
    }

    static var userAgent: String {
        "BeautyBox/\(AppConfig.appVersion) (iOS; \(UIDeviceModel.name))"
    }

    /// 每个请求都带上的基础头，字段名按后端习惯排列，多余的会被服务端忽略。
    static var baseHeaders: [String: String] {
        var h: [String: String] = [
            "platform": "ios",
            "os": "ios",
            "version": AppConfig.appVersion,
            "versionCode": String(AppConfig.androidVersionCode),
            "device": UIDeviceModel.identifier
        ]
        if let token = KeychainStore.load(account: "token") {
            h["token"] = token
            h["Authorization"] = "Bearer " + token
        }
        return h
    }

    func get<T: Decodable>(_ path: String, query: [String: String] = [:], as type: T.Type) async throws -> T {
        var comps = URLComponents(url: AppConfig.apiBaseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !query.isEmpty {
            comps?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = comps?.url else { throw APIError.badURL }
        return try await send(request: makeRequest(url: url, method: "GET", body: nil), as: type)
    }

    func post<T: Decodable>(_ path: String, body: [String: Any] = [:], as type: T.Type) async throws -> T {
        let url = AppConfig.apiBaseURL.appendingPathComponent(path)
        let data = (try? JSONSerialization.data(withJSONObject: body, options: [])) ?? Data("{}".utf8)
        return try await send(request: makeRequest(url: url, method: "POST", body: data), as: type)
    }

    /// 只要成功/失败、不解析响应体的调用（解锁、上报这类）。
    @discardableResult
    func postRaw(_ path: String, body: [String: Any] = [:]) async throws -> Data {
        let url = AppConfig.apiBaseURL.appendingPathComponent(path)
        let data = (try? JSONSerialization.data(withJSONObject: body, options: [])) ?? Data("{}".utf8)
        let (payload, response) = try await session.data(for: makeRequest(url: url, method: "POST", body: data))
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.http(http.statusCode)
        }
        return payload
    }

    private func makeRequest(url: URL, method: String, body: Data?) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        for (k, v) in APIClient.baseHeaders { req.setValue(v, forHTTPHeaderField: k) }
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }
        return req
    }

    private func send<T: Decodable>(request: URLRequest, as type: T.Type) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.http(http.statusCode)
        }
        do {
            let env = try JSONDecoder().decode(APIEnvelope<T>.self, from: data)
            if let value = env.data { return value }
            if env.isSuccess, let empty = EmptyPayload() as? T { return empty }
            throw APIError.business(code: env.code, message: env.message ?? "")
        } catch let e as APIError {
            throw e
        } catch {
            // 后端直接返回裸 JSON 时兜底
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        }
    }
}

struct EmptyPayload: Decodable {}

/// 放行自签证书 / 非常规端口。安卓侧对应的是默认 TrustManager + usesCleartextTraffic。
final class InsecureTrustDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
