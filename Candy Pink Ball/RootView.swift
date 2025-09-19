import SwiftUI

enum SettingsSource { case menu, game }

enum AppRoute {
    case loading
    case menu
    case game
    case settings(from: SettingsSource)
    case info
}

struct RootView: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            switch route {
            case .loading:
                LoadingView {
                    withAnimation(.easeInOut) { route = .menu }
                }

            case .menu:
                MenuView(
                    onPlay: { withAnimation(.easeInOut) { route = .game } },
                    onSettings: {
                        withAnimation(.easeInOut) {
                            route = .settings(from: .menu)
                        }
                    },
                    onInfo: { withAnimation(.easeInOut) { route = .info } }
                )

            case .game:
                GameView(
                    onBack: { withAnimation(.easeInOut) { route = .menu } }

                )

            case .settings(let from):
                SettingsView(
                    onBack: {
                        withAnimation(.easeInOut) {
                            switch from {
                            case .menu: route = .menu
                            case .game: route = .game
                            }
                        }
                    }
                )

            case .info:
                InfoView(
                    onBack: { withAnimation(.easeInOut) { route = .menu } }
                )
            }
        }
    }
}
