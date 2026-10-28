import Foundation

enum APIError: LocalizedError {
    case badURL
    case transport(Error)
    case http(Int)
    case business(code: Int, message: String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "地址无效"
        case .transport(let e): return "网络错误：\(e.localizedDescription)"
        case .http(let code): return "HTTP \(code)"
        case .business(let code, let msg): return msg.isEmpty ? "错误码 \(code)" : msg
        case .decoding(let e): return "数据解析失败：\(e.localizedDescription)"
        }
    }
}
