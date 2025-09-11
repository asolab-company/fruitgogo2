import SwiftUI

enum SettingsSource { case menu, game }

enum AppRoute {
    case loading
    case menu
    case game
    case settings(from: SettingsSource)
    case info
}

struct Root: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            switch route {
            case .loading:
                Loading {
                    route = .menu
                }

            case .menu:
                Menu(
                    onPlay: { route = .game },
                    onSettings: { route = .settings(from: .menu) },
                    onInfo: { route = .info }
                )

            case .game:
                Game(
                    onBack: { route = .menu }
                )

            case .settings(let from):
                Settings(
                    onBack: {
                        switch from {
                        case .menu: route = .menu
                        case .game: route = .game
                        }
                    }
                )

            case .info:
                Help(
                    onBack: { route = .menu }
                )
            }
        }
    }
}
