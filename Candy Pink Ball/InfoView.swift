import SwiftUI

struct InfoView: View {
    var onBack: () -> Void
    var body: some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * 0.35

            ZStack {
                Image("app_bg_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 28) {

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
                    }.padding(.horizontal)

                    Image("app_ic_info")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geo.size.height * 0.8)
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
