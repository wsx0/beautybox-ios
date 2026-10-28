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
        isLoading = true
        defer { isLoading = false }

        if categories.isEmpty {
            categories = service.categories
            selectedCategory = categories.first
        }

        let type = Int(selectedCategory?.id ?? "2") ?? 2

        do {
            let page = try await service.feed(type: type, page: 1)
            videos = page.list
            isDemo = page.list.isEmpty
            if isDemo {
                videos = MockProvider.videos
                errorText = "服务端返回空列表，已用演示数据占位"
            } else {
                errorText = nil
            }
        } catch {
            guard AppConfig.allowMockFallback else {
                errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                return
            }
            categories = service.categories
            videos = MockProvider.videos
            isDemo = true
            errorText = "后端不可达，已切换演示数据：\((error as? LocalizedError)?.errorDescription ?? "")"
        }
    }

    func select(_ category: Category) async {
        selectedCategory = category
        await load()
    }
}
