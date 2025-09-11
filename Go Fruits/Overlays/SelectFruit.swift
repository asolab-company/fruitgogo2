import SwiftUI

struct SelectFruit: View {
    var onBack: () -> Void
    var onConfirm: () -> Void

    @State private var selected: Int? = 0

    private let fruits = [
        "app_ic_elements09",
        "app_ic_elements06",
        "app_ic_elements02",
        "app_ic_elements04",
    ]

    var body: some View {
        GeometryReader { geo in

            let cardH = geo.size.height * 0.6

            let cardW = cardH * 0.8

            let gridSize = cardH * 0.28
            ZStack {
                Image("app_bg_popup")
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
                                .frame(height: geo.size.height * 0.055)
                        }

                        Spacer()
                    }.padding(.horizontal)

                    Spacer()

                    ZStack {

                        Image("app_bg_popupsmall")
                            .resizable()
                            .scaledToFit()
                            .frame(height: cardH)

                        VStack(spacing: 16) {
                            Text("Choose the fruit\nyou will play with")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            LazyVGrid(
                                columns: Array(
                                    repeating: GridItem(
                                        .flexible(),
                                        spacing: 5
                                    ),
                                    count: 2
                                ),
                                spacing: 18
                            ) {
                                ForEach(fruits.indices, id: \.self) { i in
                                    Button {
                                        selected = i
                                    } label: {
                                        Image(fruits[i])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(
                                                width: gridSize,
                                                height: gridSize
                                            )
                                            .saturation(
                                                selected == i ? 1.0 : 0.0
                                            )
                                            .opacity(selected == i ? 1.0 : 0.65)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.white
                                                                    .opacity(
                                                                        0.8
                                                                    ),
                                                                Color.clear,
                                                            ],
                                                            startPoint:
                                                                .topLeading,
                                                            endPoint:
                                                                .bottomTrailing
                                                        ),
                                                        lineWidth: selected == i
                                                            ? 3 : 0
                                                    )
                                            )
                                            .shadow(
                                                color: .black.opacity(0.25),
                                                radius: 8,
                                                x: 0,
                                                y: 6
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 40)

                        }

                        Button {
                            if let s = selected {

                                UserDefaults.standard.set(
                                    s + 1,
                                    forKey: "ggf_selected_fruit_idx"
                                )
                                onConfirm()
                            }
                        } label: {
                            Image("app_btn_go-1")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.13)
                        }.offset(y: geo.size.height * 0.3)

                    }

                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
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
