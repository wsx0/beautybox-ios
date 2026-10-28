import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct VideoCardView: View {
    let item: VideoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                coverView
                if !item.durationText.isEmpty {
                    Text(item.durationText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                        .padding(6)
                }
                if item.isVip {
                    VStack {
                        HStack {
                            Text("VIP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 1, green: 0.8, blue: 0.3))
                                .cornerRadius(4)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Text(item.viewsText + " 次播放")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.secondaryText)
            }
            .padding(8)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))
    }

    @ViewBuilder
    private var coverView: some View {
        if item.cover.hasPrefix("sample:"),
           let path = SampleMedia.imagePath(String(item.cover.dropFirst(7))),
           let ui = UIImage(contentsOfFile: path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
        } else if !item.cover.isEmpty, let url = URL(string: item.cover) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: gradient
                }
            }
        } else {
            gradient
        }
    }

    private var gradient: some View {
        LinearGradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.28), Color(red: 0.1, green: 0.1, blue: 0.16)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.25))
            )
    }
}
