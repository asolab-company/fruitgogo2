import Combine
import SwiftUI

struct GameView: View {
    var onBack: () -> Void

    @StateObject private var vm = GameViewModel()
    @State private var bottomBarHeight: CGFloat = 0
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geo in

            ZStack {
                Image("app_bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 10) {

                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image("app_btn_home")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.06)
                        }

                        Spacer()

                        HStack(spacing: 6) {

                            Text("\(vm.score)")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .frame(width: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.3))
                                )

                            HStack(spacing: 6) {
                                Image("app_ic_crown")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)

                                Text("\(vm.highScore)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(hex: "FED300"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(width: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.3))
                            )
                        }

                        Spacer()

                        Button {
                            vm.pause()
                            showSettings = true
                        } label: {
                            Image("app_btn_set")
                                .resizable()
                                .scaledToFit()

                                .frame(height: geo.size.height * 0.06)
                        }
                    }
                    .padding(.horizontal)

                    ZStack {
                        Image("app_bg_win")
                            .resizable()
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height * 0.09
                            )
                            .clipped()

                        Text(
                            vm.lastPoints != nil
                                ? "WIN        +\(vm.lastPoints!)"
                                : "WIN        ???"
                        )
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "602A02"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: vm.lastPoints
                        )

                        HStack {
                            HStack(spacing: 4) {
                                ForEach(0..<3) { i in
                                    Image("app_ic_heart")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .opacity(i < vm.lives ? 1.0 : 0.25)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }

                    GameCanvas(vm: vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(
                            .bottom,
                            UIScreen.deviceSize == .small
                                ? 200 : bottomBarHeight
                        )

                }

                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 20)

            }

        }.overlay(alignment: .bottom) {
            MeasurableBottomBar()
                .onPreferenceChange(BottomBarHeightKey.self) { h in
                    bottomBarHeight = h
                }
        }.overlay {
            if vm.gameOver {
                GameOverOverlay(
                    score: vm.score,
                    highScore: vm.highScore,
                    onRetry: { vm.reset() },
                    onHome: { onBack() }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }

        .overlay {
            if showSettings {
                SettingsView {

                    showSettings = false
                    vm.resume()
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(10)
            }

        }
    }
}

private struct BottomBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct MeasurableBottomBar: View {
    var body: some View {
        ZStack {
            Color(hex: "341A6E")
                .frame(height: 50)
                .offset(y: 80)
                .ignoresSafeArea(.container, edges: .bottom)

            Image("app_bg_down")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            Text("Shoot candies of the same color")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "6C5C9F"))
                .padding(.top, 90)
                .textCase(.uppercase)
        }

        .background(
            GeometryReader { g in
                Color.clear
                    .preference(
                        key: BottomBarHeightKey.self,
                        value: g.size.height
                    )
            }
        )
    }
}
