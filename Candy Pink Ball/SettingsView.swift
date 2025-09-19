import SwiftUI
import UIKit

struct SettingsView: View {

    private enum AppConfig {
        static let appStoreID = "YOUR_APP_ID"
        static let supportEmail = "support@yourapp.com"
        static let privacyLink = "https://yourapp.com/privacy"

        static var appStoreURL: URL? {
            URL(string: "https://apps.apple.com/app/id\(appStoreID)")
        }
        static var privacyURL: URL? {
            URL(string: privacyLink)
        }
    }

    var onBack: () -> Void
    @EnvironmentObject var audio: AudioManager

    var body: some View {
        GeometryReader { geo in
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
                                .resizable().scaledToFit()
                                .frame(height: geo.size.height * 0.06)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button {
                        audio.toggleSound()
                        audio.isSoundEnabled
                            ? audio.resumeBGMIfNeeded() : audio.pauseBGM()
                    } label: {
                        ZStack(alignment: .bottom) {
                            Image("app_btn_menu02-2")
                                .resizable().scaledToFit()
                                .frame(height: geo.size.height * 0.12)

                            Image(
                                audio.isSoundEnabled
                                    ? "app_btn_on" : "app_btn_off"
                            )
                            .resizable().scaledToFit()
                            .offset(y: -15)
                            .frame(height: geo.size.height * 0.04)
                        }
                    }

                    Button {
                        shareApp()
                    } label: {
                        Image("app_btn_menu01-2")
                            .resizable().scaledToFit()
                            .frame(height: geo.size.height * 0.12)
                    }

                    Button {
                        contactUs()
                    } label: {
                        Image("app_btn_menu01-1")
                            .resizable().scaledToFit()
                            .frame(height: geo.size.height * 0.12)
                    }

                    Button {
                        openPolicy()
                    } label: {
                        Image("app_btn_menu02-1")
                            .resizable().scaledToFit()
                            .frame(height: geo.size.height * 0.12)
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

    private func shareApp() {
        guard
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
                == nil
        else {
            print("[Preview] Share tapped")
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
            print("[Preview] Contact tapped")
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
            print("[Preview] Policy tapped")
            return
        }
        if let url = AppConfig.privacyURL {
            UIApplication.shared.open(url)
        }
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

#Preview {
    SettingsView(onBack: { print("Back pressed in preview") })
        .environmentObject(AudioManager.shared)
}
