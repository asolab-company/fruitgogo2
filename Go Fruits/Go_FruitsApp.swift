import SwiftUI

@main
struct Go_FruitsApp: App {
    @StateObject var audio = AudioManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Root()
                .environmentObject(audio)
                .onAppear {
                    audio.startBGM()
                }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .background:
                        audio.willEnterBackground()
                    case .inactive:
                        break
                    case .active:
                        audio.didEnterForeground()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
