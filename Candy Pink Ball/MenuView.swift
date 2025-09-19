import SwiftUI

struct MenuView: View {
    var onPlay: () -> Void
    var onSettings: () -> Void
    var onInfo: () -> Void

    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.35

            ZStack {
                Image("app_bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    Image("app_ic_up")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)
                        .overlay {
                            GeometryReader { imgGeo in
                                let w = imgGeo.size.width
                                let h = imgGeo.size.height

                                Text(
                                    "\(UserDefaults.standard.integer(forKey: "cpb_highscore_v1"))"
                                )
                                .foregroundColor(Color(hex: "FED300"))
                                .font(.system(size: 24, weight: .regular))

                                .position(
                                    x: w * 0.37,
                                    y: h * 0.38
                                )
                            }

                            .allowsHitTesting(false)
                        }

                    Button {
                        onPlay()
                    } label: {
                        Image("app_btn_menu03")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.16)
                    }

                    Button {
                        onSettings()
                    } label: {
                        Image("app_btn_menu02")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.12)
                    }

                    Button {
                        onInfo()
                    } label: {
                        Image("app_btn_menu01")
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
