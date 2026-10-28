import SwiftUI

struct UploadView: View {
    @State private var title = ""
    @State private var picked = false
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: Theme.corner)
                    .strokeBorder(Theme.separator, style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 32))
                            Text(picked ? "已选择素材" : "选择视频 / 图片").font(.caption)
                        }
                        .foregroundColor(Theme.secondaryText)
                    )
                    .onTapGesture { picked = true; progress = 0 }

                TextField("标题", text: $title)
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(Theme.corner)
                    .foregroundColor(.white)

                if progress > 0 {
                    ProgressView(value: progress).tint(Theme.accent)
                }

                Button {
                    simulateUpload()
                } label: {
                    Text("提交")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.corner)
                }
                .disabled(!picked || title.isEmpty)

                Spacer()
            }
            .padding(Theme.pagePadding)
        }
        .navigationTitle("上传")
    }

    private func simulateUpload() {
        progress = 0.01
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            progress += 0.1
            if progress >= 1 {
                progress = 1
                timer.invalidate()
            }
        }
    }
}
