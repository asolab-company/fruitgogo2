import SwiftUI

struct GameOverOverlay: View {

    let score: Int
    let highScore: Int
    var onRetry: () -> Void
    var onHome: () -> Void

    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.65

            ZStack {
                Image("app_bg_popup")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    HStack {
                        Button {
                            onHome()
                        } label: {
                            Image("app_btn_home")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.06)
                        }

                        Spacer()

                        HStack(spacing: 6) {

                            Text("\(score)")
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

                                Text("\(highScore)")
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

                        } label: {
                            Image("app_btn_set")
                                .resizable()
                                .scaledToFit()
                                .opacity(0)
                                .frame(height: geo.size.height * 0.06)
                        }
                    }
                    .padding(.horizontal)

                    Image("app_ic_gameover")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)

                    Button {
                        onRetry()
                    } label: {
                        Image("app_btn_restart")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.12)
                    }

                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    GameOverOverlay(
        score: 120,
        highScore: 350,
        onRetry: { print("Retry tapped") },
        onHome: { print("Home tapped") }
    )
}
