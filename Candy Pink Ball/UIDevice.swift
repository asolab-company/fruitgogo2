import UIKit

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
