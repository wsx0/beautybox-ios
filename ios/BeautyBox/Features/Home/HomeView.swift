import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        categoryBar
                        if vm.isDemo {
                            Text("演示模式：后端 (\(AppConfig.apiBaseURL.absoluteString)) 不可达")
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                                .padding(.horizontal, Theme.pagePadding)
                        }
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(vm.videos) { item in
                                NavigationLink(destination: VideoPlayerScreen(item: item)) {
                                    VideoCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Theme.pagePadding)
                    }
                    .padding(.bottom, 24)
                }
                .refreshable { await vm.load() }

                if vm.isLoading && vm.videos.isEmpty {
                    ProgressView().tint(Theme.accent)
                }
            }
            .navigationTitle("BeautyBox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .task { if vm.videos.isEmpty { await vm.load() } }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.categories) { cat in
                    let active = cat.id == vm.selectedCategory?.id
                    Button {
                        Task { await vm.select(cat) }
                    } label: {
                        Text(cat.name)
                            .font(.system(size: 14, weight: active ? .semibold : .regular))
                            .foregroundColor(active ? .white : Theme.secondaryText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(active ? Theme.accent : Theme.surface)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, Theme.pagePadding)
        }
    }
}
