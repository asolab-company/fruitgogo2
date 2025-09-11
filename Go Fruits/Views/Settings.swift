import SwiftUI

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

struct Settings: View {
    @EnvironmentObject var audio: AudioManager
    private enum AppConfig {
        static let appStoreID = "6752379558"
        static let supportEmail = "text@merchkz.com"
        static let privacyLink = "https://docs.google.com/document/d/e/2PACX-1vTJVkp9OFP36reLddj_woQJhcNwU-dPiel8JytbMkBj4Ma-NIVYn6OJ0ipuJ9EGM36Xh2AXHN3WdkEB/pub"

        static var appStoreURL: URL? {
            URL(string: "https://apps.apple.com/app/id6752379558")
        }
        static var privacyURL: URL? {
            URL(string: privacyLink)
        }
    }

    var onBack: () -> Void
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
                                .frame(height: geo.size.height * 0.055)
                        }

                        Spacer()
                    }.padding(.horizontal)

                    Spacer()
                    Button {
                        audio.toggleSound()
                        audio.isSoundEnabled
                            ? audio.resumeBGMIfNeeded() : audio.pauseBGM()
                    } label: {
                        ZStack(alignment: .trailing) {
                            Image("app_btn_set02")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.1)

                            Image(
                                audio.isSoundEnabled
                                    ? "app_btn_on" : "app_btn_off"
                            )
                            .resizable()
                            .scaledToFit()
                            .padding(.trailing, 25)
                            .frame(height: geo.size.height * 0.04)

                        }
                    }

                    Button {
                        shareApp()
                    } label: {
                        Image("app_btn_set03")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.1)
                    }

                    Button {
                        contactUs()
                    } label: {
                        Image("app_btn_set04")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.1)
                    }

                    Button {
                        openPolicy()
                    } label: {
                        Image("app_btn_set01")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.height * 0.1)
                    }

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

    private func shareApp() {
        guard
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
                == nil
        else {
         
            return
        }
        guard let url = AppConfig.appStoreURL else { return }
        let av = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(
            av,
            animated: true
        )
    }

    private func contactUs() {
        guard
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
                == nil
        else {
          
            return
        }
        let to = AppConfig.supportEmail
        if let url = URL(string: "mailto:\(to)") {
            UIApplication.shared.open(url)
        }
    }

    private func openPolicy() {
        guard
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
                == nil
        else {
       
            return
        }
        if let url = AppConfig.privacyURL {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    Settings(onBack: {  })
        .environmentObject(AudioManager.shared)
}
