import SwiftUI

@main
struct BeautyBoxApp: App {
    @StateObject private var session = SessionStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }
}
