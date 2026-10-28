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
                        .frame(height: 260)
                        .onAppear { player.play() }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.surface)
                        .frame(height: 260)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "play.slash")
                                    .font(.system(size: 30))
                                Text("无法播放：素材缺失")
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
                    if item.playURL.hasPrefix("sample:") || item.playURL.isEmpty {
                        Text("当前播放内置演示视频（无后端时默认行为）")
                            .font(.caption2)
                            .foregroundColor(Theme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.pagePadding)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { makePlayer() }
        .onDisappear { player?.pause() }
    }

    private func makePlayer() {
        if item.playURL.hasPrefix("sample:") || item.playURL.isEmpty {
            if let url = SampleMedia.videoURL { player = AVPlayer(url: url) }
        } else if let url = URL(string: item.playURL) {
            player = AVPlayer(url: url)
        }
    }
}
