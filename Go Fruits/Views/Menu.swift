import SwiftUI

struct Menu: View {
    var onPlay: () -> Void
    var onSettings: () -> Void
    var onInfo: () -> Void
    @State private var showSelect = false
    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.55

            ZStack {
                Image("app_bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {

                    Image("app_ic_elementsmain")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)
                        .padding(.bottom, 20)

                    Button {
                        showSelect = true
                    } label: {
                        Image("app_btn_menu03")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.12)
                    }

                    Button {
                        onSettings()
                    } label: {
                        Image("app_btn_menu02")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.1)
                    }

                    Button {
                        onInfo()
                    } label: {
                        Image("app_btn_menu01")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.1)
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
        .overlay {
            if showSelect {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)

                SelectFruit(
                    onBack: {
                        showSelect = false
                    },
                    onConfirm: {
                        showSelect = false
                        onPlay()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
