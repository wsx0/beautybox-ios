import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var videos: [VideoItem] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var isLoading = false
    @Published var isDemo = false
    @Published var errorText: String?

    private let service = ContentService.shared

    func load() async {
        // 先秒出内置素材，避免等网络超时后一片空白
        if videos.isEmpty {
            categories = service.categories
            selectedCategory = categories.first
            videos = MockProvider.videos
            isDemo = true
        }

        let type = Int(selectedCategory?.id ?? "2") ?? 2
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await service.feed(type: type, page: 1)
            if !page.list.isEmpty {
                videos = page.list
                isDemo = false
                errorText = nil
                return
            }
        } catch {
            if !AppConfig.allowMockFallback {
                errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                return
            }
            errorText = "后端不可达，正在使用内置素材：\((error as? LocalizedError)?.errorDescription ?? "")"
        }

        if videos.isEmpty {
            videos = MockProvider.videos
        }
        isDemo = true
    }

    func select(_ category: Category) async {
        selectedCategory = category
        await load()
    }
}
