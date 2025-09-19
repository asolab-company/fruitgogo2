import AVFoundation
import Combine
import Foundation

final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var pausedByApp = false

    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Self.udKeySound)
            isSoundEnabled ? resumeBGMIfNeeded() : pauseBGM()
        }
    }

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private var wasBgmPlayingBeforeBackground = false

    private static let udKeySound = "cpb_sound_enabled"

    private let bgmFile = "candy_bg.mp3"
    private let shootFx = "candy_shoot.mp3"
    private let boomFx = "candy_explo.mp3"
    private let overFx = "candy_go.mp3"

    private init() {
        let def = UserDefaults.standard.object(forKey: Self.udKeySound) as? Bool
        isSoundEnabled = def ?? true

        configureSession()
        observeInterruptions()
    }

    private func configureSession() {
        do {

            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("[Audio] Session configured: playback + mixWithOthers")
        } catch {
            print("[Audio] Session error:", error)
        }
    }

    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self else { return }
            guard let info = note.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey]
                    as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }

            if type == .began {
                self.wasBgmPlayingBeforeBackground =
                    self.bgmPlayer?.isPlaying == true
                self.pauseBGM()
                print("[Audio] interruption began")
            } else if type == .ended {
                let optValue =
                    info[AVAudioSessionInterruptionOptionKey] as? UInt
                let options = AVAudioSession.InterruptionOptions(
                    rawValue: optValue ?? 0
                )
                if options.contains(.shouldResume),
                    self.wasBgmPlayingBeforeBackground, self.isSoundEnabled
                {
                    self.resumeBGMIfNeeded()
                    print("[Audio] interruption ended, resume")
                }
            }
        }
    }

    func startBGM() {
        guard isSoundEnabled else {
            print("[Audio] BGM skipped: sound disabled")
            return
        }
        if bgmPlayer == nil {
            bgmPlayer = loadPlayer(file: bgmFile)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 1.0
        }
        guard let p = bgmPlayer else {
            print("[Audio] BGM player is nil")
            return
        }
        p.play()
        print("[Audio] BGM play, time=\(p.currentTime)")
    }

    func pauseBGM() {
        bgmPlayer?.pause()
        print("[Audio] BGM pause")
    }
    func resumeBGMIfNeeded() {
        guard isSoundEnabled else { return }
        bgmPlayer?.play()
        print("[Audio] BGM resume")
    }
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        print("[Audio] BGM stop")
    }
    func toggleSound() { isSoundEnabled.toggle() }

    func playShoot() { playSFX(named: shootFx) }
    func playExplosion() { playSFX(named: boomFx) }
    func playGameOver() { playSFX(named: overFx) }

    func willEnterBackground() {
        wasBgmPlayingBeforeBackground = bgmPlayer?.isPlaying == true
        if wasBgmPlayingBeforeBackground {
            pauseBGM()
            pausedByApp = true
        } else {
            pausedByApp = false
        }
        print(
            "[Audio] app -> background (was playing: \(wasBgmPlayingBeforeBackground))"
        )
    }

    func didEnterForeground() {

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("[Audio] session re-activated on foreground")
        } catch {
            print("[Audio] session activate error on foreground:", error)
        }

        guard isSoundEnabled else {
            print("[Audio] sound disabled, skip resume")
            return
        }

        if pausedByApp {
            pausedByApp = false
            if let p = bgmPlayer {
                p.play()
                print("[Audio] resume BGM after background")
            } else {
                startBGM()
                print("[Audio] player was nil — startBGM()")
            }
        } else {
            print("[Audio] didEnterForeground: no auto-resume needed")
        }
    }

    private func playSFX(named name: String) {
        guard isSoundEnabled else { return }
        if let p = sfxPlayers[name] {
            p.currentTime = 0
            p.play()
        } else if let p = loadPlayer(file: name) {
            sfxPlayers[name] = p
            p.play()
        }
    }

    private func loadPlayer(file: String) -> AVAudioPlayer? {
        let base = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: base, withExtension: ext)
        else {
            print("[Audio] file not found in bundle:", file)
            return nil
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            print("[Audio] loaded:", file)
            return p
        } catch {
            print("[Audio] failed to load \(file):", error)
            return nil
        }
    }
}
