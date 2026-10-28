import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 内置演示素材：封面图与演示视频随包分发，断网也能显示和播放。
enum SampleMedia {
    static func imagePath(_ name: String) -> String? {
        Bundle.main.path(forResource: name, ofType: "jpg")
            ?? Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "samples")
    }

    static var videoURL: URL? {
        Bundle.main.url(forResource: "demo", withExtension: "mp4")
            ?? Bundle.main.url(forResource: "demo", withExtension: "mp4", subdirectory: "samples")
    }
}
