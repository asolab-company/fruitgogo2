import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

enum DeviceSize {
    case small, medium, large
}

extension UIScreen {
    static var deviceSize: DeviceSize {
        let height = UIScreen.main.bounds.height
        if height <= 667 {
            return .small
        } else if height <= 812 {
            return .medium
        } else {
            return .large
        }
    }
}
