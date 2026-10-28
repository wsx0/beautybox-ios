import Foundation

/// 后端不可达时用的演示数据。封面与视频指向包里自带素材，保证断网也能看。
enum MockProvider {
    static let categories: [Category] = [
        Category(id: "1", name: "推荐"),
        Category(id: "2", name: "写真"),
        Category(id: "3", name: "短视频"),
        Category(id: "4", name: "直播回放")
    ]

    static let videos: [VideoItem] = (1...24).map { i in
        VideoItem(
            id: String(i),
            title: "演示作品 \(i) · BeautyBox",
            cover: "sample:cover_\( (i - 1) % 8 + 1 )",
            playURL: "sample:demo",
            duration: 45 + i * 7,
            views: i * 1370,
            likes: i * 23,
            isVip: i % 5 == 0
        )
    }

    static let messages: [MessageItem] = [
        MessageItem(id: "1", title: "系统通知", body: "欢迎使用 BeautyBox iOS 版，当前为内置演示素材。", timeText: "刚刚")
    ]
}
