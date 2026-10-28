import Foundation

struct Category: Decodable, Identifiable, Hashable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey { case id, name, title, cid }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let i = (try? c.decode(Int.self, forKey: .id)) ?? (try? c.decode(Int.self, forKey: .cid)) ?? 0
        id = (try? c.decode(String.self, forKey: .id)) ?? String(i)
        name = (try? c.decode(String.self, forKey: .name))
            ?? (try? c.decode(String.self, forKey: .title)) ?? "分类"
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct PageResult<T: Decodable>: Decodable {
    let list: [T]
    let total: Int
    let page: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case list, data, items, records
        case total, totalCount, total_count
        case page, pageNum, page_num, current
        case hasMore, has_more, more
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        let listA: [T]? = try? c.decode([T].self, forKey: .list)
        let listB: [T]? = try? c.decode([T].self, forKey: .data)
        let listC: [T]? = try? c.decode([T].self, forKey: .items)
        let listD: [T]? = try? c.decode([T].self, forKey: .records)
        let items: [T] = listA ?? listB ?? listC ?? listD ?? []

        let totalA: Int? = try? c.decode(Int.self, forKey: .total)
        let totalB: Int? = try? c.decode(Int.self, forKey: .totalCount)
        let totalC: Int? = try? c.decode(Int.self, forKey: .total_count)
        let totalValue: Int = totalA ?? totalB ?? totalC ?? 0

        let pageA: Int? = try? c.decode(Int.self, forKey: .page)
        let pageB: Int? = try? c.decode(Int.self, forKey: .pageNum)
        let pageC: Int? = try? c.decode(Int.self, forKey: .page_num)
        let pageD: Int? = try? c.decode(Int.self, forKey: .current)
        let pageValue: Int = pageA ?? pageB ?? pageC ?? pageD ?? 1

        let moreValue: Bool
        if let v = (try? c.decode(Bool.self, forKey: .hasMore)) ?? (try? c.decode(Bool.self, forKey: .has_more)) {
            moreValue = v
        } else if let n = try? c.decode(Int.self, forKey: .more) {
            moreValue = n != 0
        } else {
            moreValue = items.count >= 10
        }

        self.list = items
        self.total = totalValue
        self.page = pageValue
        self.hasMore = moreValue
    }

    init(list: [T], total: Int = 0, page: Int = 1, hasMore: Bool = false) {
        self.list = list
        self.total = total
        self.page = page
        self.hasMore = hasMore
    }
}

struct MessageItem: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let avatar: String
    let timeText: String

    enum CodingKeys: String, CodingKey {
        case id, title, nickname, name, body, content, msg
        case avatar, headImg, head_img, time, createTime, create_time, date
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let i = (try? c.decode(Int.self, forKey: .id)) ?? 0
        id = (try? c.decode(String.self, forKey: .id)) ?? String(i)
        title = (try? c.decode(String.self, forKey: .title))
            ?? (try? c.decode(String.self, forKey: .nickname))
            ?? (try? c.decode(String.self, forKey: .name)) ?? "系统消息"
        body = (try? c.decode(String.self, forKey: .body))
            ?? (try? c.decode(String.self, forKey: .content))
            ?? (try? c.decode(String.self, forKey: .msg)) ?? ""
        avatar = (try? c.decode(String.self, forKey: .avatar))
            ?? (try? c.decode(String.self, forKey: .headImg))
            ?? (try? c.decode(String.self, forKey: .head_img)) ?? ""
        timeText = (try? c.decode(String.self, forKey: .time))
            ?? (try? c.decode(String.self, forKey: .createTime))
            ?? (try? c.decode(String.self, forKey: .create_time))
            ?? (try? c.decode(String.self, forKey: .date)) ?? ""
    }

    init(id: String, title: String, body: String, avatar: String = "", timeText: String = "") {
        self.id = id
        self.title = title
        self.body = body
        self.avatar = avatar
        self.timeText = timeText
    }
}
