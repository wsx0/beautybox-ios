import Foundation

/// 后端不可达时用的演示数据，保证模拟器里界面完整可点。
enum MockProvider {
    static let banners: [String] = []
    static let categories: [Category] = [
        Category(id: "1", name: "推荐"),
        Category(id: "2", name: "写真"),
        Category(id: "3", name: "短视频"),
        Category(id: "4", name: "直播回放")
    ]

    static let videos: [VideoItem] = (1...24).map { i in
        VideoItem(
            id: String(i),
            title: "示例作品 \(i) - 演示数据",
            cover: "",
            playURL: "",
            duration: 45 + i * 7,
            views: i * 1370,
            likes: i * 23,
            isVip: i % 5 == 0
        )
    }

    static let messages: [MessageItem] = [
        MessageItem(id: "1", title: "系统通知", body: "欢迎使用 BeautyBox iOS 版，当前为演示数据。", timeText: "刚刚")
    ]
}
