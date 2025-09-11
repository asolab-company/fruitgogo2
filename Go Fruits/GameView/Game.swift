import SwiftUI

struct Game: View {
    @StateObject private var vm = GoGoFruitViewModel()
    var onBack: () -> Void
    @State private var showSettings = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geo in

            ZStack {
                Image(vm.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 5) {

                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image("app_btn_home")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.055)
                        }

                        Spacer()

                        HStack(spacing: 10) {

                            Text("\(vm.score)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .frame(width: 100)
                                .background(
                                    Image("app_bg_score")
                                        .resizable()
                                        .scaledToFill()

                                )

                            HStack(spacing: 6) {
                                Image("app_ic_crown")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)

                                Text("\(vm.highScore)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "FED300"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .frame(width: 100)
                            .background(
                                Image("app_bg_score")
                                    .resizable()
                                    .scaledToFill()

                            )
                        }

                        Spacer()

                        Button {
                            vm.pauseGame()
                            showSettings = true
                        } label: {
                            Image("app_btn_set")
                                .resizable()
                                .scaledToFit()

                                .frame(height: geo.size.height * 0.055)
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(
                                i < vm.lives
                                    ? GGFruitAssets.heartFull
                                    : GGFruitAssets.heartEmpty
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                        }
                    }

                    GameCanvas(vm: vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 0)
                        .padding(
                            .bottom,
                            UIScreen.deviceSize == .small
                                ? 150 : 100
                        )

                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 20)
            }
        }.overlay {
            if vm.gameOver {
                GameOver(
                    score: vm.score,
                    highScore: vm.highScore,
                    onHome: { onBack() },
                    onRetry: { vm.reset() }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .overlay {
            if showSettings {
                Settings {

                    showSettings = false
                    vm.resumeGame()
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(10)
            }

        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background, .inactive:
                vm.pauseGame()
            case .active:
                if !showSettings && !vm.gameOver {
                    vm.resumeGame()
                }
            @unknown default:
                break
            }
        }

        .onDisappear {
            vm.pauseGame()
        }
    }
}
