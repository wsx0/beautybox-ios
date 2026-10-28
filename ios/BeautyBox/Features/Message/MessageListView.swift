import SwiftUI

struct MessageListView: View {
    @State private var items: [MessageItem] = MockProvider.messages

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                List(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            Spacer()
                            Text(item.timeText).font(.caption2).foregroundColor(Theme.secondaryText)
                        }
                        Text(item.body).font(.caption).foregroundColor(Theme.secondaryText)
                    }
                    .listRowBackground(Theme.surface)
                }
                .listStyle(.plain)
            }
            .navigationTitle("消息")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}
