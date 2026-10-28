import Foundation

/// 内容服务：对齐安卓 box/* 与 {type}/* 两族接口。
struct ContentService {
    static let shared = ContentService()

    /// 分类在安卓端是固定的 7 个内容类型（g.b(type)），不是服务端下发。
    var categories: [Category] {
        Endpoint.ContentType.allCases.map { Category(id: String($0.rawValue), name: $0.title) }
    }

    func feed(type: Int, page: Int) async throws -> PageResult<VideoItem> {
        let q = ["t": String(type), "id": "0", "page": String(page)]
        return try await APIClient.shared.get(Endpoint.boxTips, query: q, as: PageResult<VideoItem>.self)
    }

    func nodeList(type: Int) async throws -> PageResult<VideoItem> {
        let slug = Endpoint.ContentType(rawValue: type)?.slug ?? "video"
        let q = ["page": String(1)]
        return try await APIClient.shared.get(Endpoint.nodeList(slug), query: q, as: PageResult<VideoItem>.self)
    }

    /// 解锁（花积分/权限）
    func unlock(type: Int, id: String) async throws {
        let slug = Endpoint.ContentType(rawValue: type)?.slug ?? "video"
        let body: [String: Any] = ["id": id]
        _ = try await APIClient.shared.postRaw(Endpoint.unlock(slug), body: body)
    }

    /// 试看地址
    func tryPlay(type: Int, id: String) async throws -> VideoItem {
        let slug = Endpoint.ContentType(rawValue: type)?.slug ?? "video"
        return try await APIClient.shared.get(Endpoint.tryPlay(slug), query: ["id": id], as: VideoItem.self)
    }
}
