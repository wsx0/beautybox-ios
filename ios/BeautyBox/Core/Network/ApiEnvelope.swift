import Foundation

/// 后端统一返回外壳。字段名按常见约定做了兼容，未命中的键自动忽略。
struct APIEnvelope<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?

    enum CodingKeys: String, CodingKey {
        case code, status, ret
        case message, msg, message_text
        case data, result, payload
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let v = try? c.decode(Int.self, forKey: .code) {
            code = v
        } else if let s = try? c.decode(String.self, forKey: .code), let v = Int(s) {
            code = v
        } else if let v = try? c.decode(Int.self, forKey: .status) {
            code = v
        } else if let v = try? c.decode(Int.self, forKey: .ret) {
            code = v
        } else {
            code = 0
        }
        message = (try? c.decode(String.self, forKey: .message))
            ?? (try? c.decode(String.self, forKey: .msg))
            ?? (try? c.decode(String.self, forKey: .message_text))
        data = (try? c.decode(T.self, forKey: .data))
            ?? (try? c.decode(T.self, forKey: .result))
            ?? (try? c.decode(T.self, forKey: .payload))
    }

    var isSuccess: Bool { code == 0 || code == 200 || code == 1 }
}
