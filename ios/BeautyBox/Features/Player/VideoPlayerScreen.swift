import SwiftUI
import AVKit

struct VideoPlayerScreen: View {
    let item: VideoItem
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                if let player {
                    VideoPlayer(player: player)
                        .frame(height: 240)
                        .onAppear { player.play() }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.surface)
                        .frame(height: 240)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "play.slash")
                                    .font(.system(size: 30))
                                Text("无播放地址（演示数据）")
                                    .font(.caption)
                            }
                            .foregroundColor(Theme.secondaryText)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title).font(.headline).foregroundColor(.white)
                    Text("\(item.viewsText) 次播放 · \(item.likes) 赞")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.pagePadding)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let url = URL(string: item.playURL), !item.playURL.isEmpty {
                player = AVPlayer(url: url)
            }
        }
        .onDisappear { player?.pause() }
    }
}
