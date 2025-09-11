import SwiftUI

struct GameOver: View {
    var score: Int
    var highScore: Int
    var onHome: () -> Void
    var onRetry: () -> Void

    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.7

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
                                .frame(height: geo.size.height * 0.055)
                        }

                        Spacer()

                        HStack(spacing: 10) {

                            Text("\(score)")
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

                                Text("\(highScore)")
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

                        } label: {
                            Image("app_btn_set")
                                .resizable()
                                .scaledToFit()
                                .opacity(0)
                                .frame(height: geo.size.height * 0.055)
                        }
                    }
                    .padding(.horizontal)

                    Image("Group 16120")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)

                    Button {
                        onRetry()
                    } label: {
                        Image("app_btn_menu04")
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
