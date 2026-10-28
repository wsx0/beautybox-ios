import Foundation

struct VideoItem: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let cover: String
    let playURL: String
    let duration: Int
    let views: Int
    let likes: Int
    let isVip: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, name, cover, coverUrl, cover_url, thumb
        case playURL, playUrl, play_url, url, videoUrl, video_url
        case duration, views, playCount, play_count, likes, likeCount, like_count
        case isVip, vip, is_vip
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let idInt = (try? c.decode(Int.self, forKey: .id)) ?? 0
        let idStr = (try? c.decode(String.self, forKey: .id)) ?? String(idInt)
        id = idStr
        title = (try? c.decode(String.self, forKey: .title))
            ?? (try? c.decode(String.self, forKey: .name)) ?? "未命名"
        cover = (try? c.decode(String.self, forKey: .cover))
            ?? (try? c.decode(String.self, forKey: .coverUrl))
            ?? (try? c.decode(String.self, forKey: .cover_url))
            ?? (try? c.decode(String.self, forKey: .thumb)) ?? ""
        playURL = (try? c.decode(String.self, forKey: .playURL))
            ?? (try? c.decode(String.self, forKey: .playUrl))
            ?? (try? c.decode(String.self, forKey: .play_url))
            ?? (try? c.decode(String.self, forKey: .url))
            ?? (try? c.decode(String.self, forKey: .videoUrl))
            ?? (try? c.decode(String.self, forKey: .video_url)) ?? ""
        duration = (try? c.decode(Int.self, forKey: .duration)) ?? 0
        views = (try? c.decode(Int.self, forKey: .views))
            ?? (try? c.decode(Int.self, forKey: .playCount))
            ?? (try? c.decode(Int.self, forKey: .play_count)) ?? 0
        likes = (try? c.decode(Int.self, forKey: .likes))
            ?? (try? c.decode(Int.self, forKey: .likeCount))
            ?? (try? c.decode(Int.self, forKey: .like_count)) ?? 0
        isVip = (try? c.decode(Bool.self, forKey: .isVip))
            ?? (try? c.decode(Bool.self, forKey: .vip))
            ?? (try? c.decode(Bool.self, forKey: .is_vip)) ?? false
    }

    init(id: String, title: String, cover: String = "", playURL: String = "",
         duration: Int = 0, views: Int = 0, likes: Int = 0, isVip: Bool = false) {
        self.id = id
        self.title = title
        self.cover = cover
        self.playURL = playURL
        self.duration = duration
        self.views = views
        self.likes = likes
        self.isVip = isVip
    }

    var durationText: String {
        guard duration > 0 else { return "" }
        let m = duration / 60
        let s = duration % 60
        return String(format: "%d:%02d", m, s)
    }

    var viewsText: String {
        if views >= 10000 { return String(format: "%.1f万", Double(views) / 10000) }
        return String(views)
    }
}
