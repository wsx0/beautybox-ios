import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Group {
            switch settings.mode {
            case .webShell:
                WebContainerView(url: settings.webEntryURL)
                    .ignoresSafeArea(edges: .bottom)
            case .bundledWeb:
                WebContainerView(bundledPath: "webapp/index.html")
                    .ignoresSafeArea(edges: .bottom)
            case .nativeCase:
                nativeTabs
            }
        }
        .accentColor(Theme.accent)
    }

    private var nativeTabs: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house.fill") }

            MessageListView()
                .tabItem { Label("消息", systemImage: "bubble.left.and.bubble.right.fill") }

            ProfileView()
                .tabItem { Label("我的", systemImage: "person.crop.circle.fill") }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(SessionStore())
            .environmentObject(AppSettings())
    }
}
