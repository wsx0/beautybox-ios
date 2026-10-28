import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 设备指纹，用于对齐安卓端上报的 device 字段。
enum UIDeviceModel {
    static var identifier: String {
        if let stored = UserDefaults.standard.string(forKey: "bb.device.id") { return stored }
        let value = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        UserDefaults.standard.set(value, forKey: "bb.device.id")
        return value
    }

    static var name: String {
        #if canImport(UIKit)
        return UIDevice.current.name
        #else
        return "iOS"
        #endif
    }
}
