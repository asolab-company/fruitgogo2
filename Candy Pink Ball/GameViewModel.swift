import Combine
import SwiftUI

enum CandyKind: CaseIterable {
    case pink, yellow, green, orange, blue, rainbow

    static var regulars: [CandyKind] {
        [.pink, .yellow, .green, .orange, .blue]
    }

    var imageName: String {
        switch self {
        case .pink: return "app_btn_ball-6"
        case .yellow: return "app_btn_ball-5"
        case .green: return "app_btn_ball-2"
        case .orange: return "app_btn_ball-3"
        case .blue: return "app_btn_ball-4"
        case .rainbow: return "app_btn_ball-1"
        }
    }

    var scoreValue: Int {
        switch self {
        case .green, .orange, .blue: return 2
        case .yellow, .pink: return 4
        case .rainbow: return 0
        }
    }
}

struct Explosion: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var frame: Int = 1
}

struct Candy: Identifiable {
    let id = UUID()
    var kind: CandyKind
    var pos: CGPoint
    var vel: CGPoint
    var radius: CGFloat
    var isPlayerShot: Bool
}

final class GameViewModel: ObservableObject {

    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var lives: Int = 3
    @Published var gameOver: Bool = false
    @Published var isPaused: Bool = false

    @Published var falling: [Candy] = []
    @Published var shots: [Candy] = []

    @Published var queuedKind: CandyKind = CandyKind.regulars.randomElement()!

    @Published var isShooting: Bool = false
    @Published var lastPoints: Int? = nil
    @Published var aimDots: [CGPoint] = []
    @Published var aimDotsVisible: Bool = false
    @Published var explosions: [Explosion] = []

    private var tickTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var lastUpdate: Date = .init()
    private var perfectStreak: Int = 0

    private(set) var fieldSize: CGSize = .zero
    private var baseFallSpeed: CGFloat = 120
    private var baseSpawn: TimeInterval = 1.2
    private var shootSpeed: CGFloat = 520
    private var candyRadius: CGFloat = 22

    private let highScoreKey = "cpb_highscore_v1"

    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        queuedKind = randomPlayerKind()
    }

    func configureField(size: CGSize) {
        fieldSize = size
        startLoop()
        startSpawn()
    }

    func pause() {
        guard !gameOver else { return }
        isPaused = true
        tickTimer?.cancel()
        spawnTimer?.cancel()
    }

    func resume() {
        guard !gameOver else { return }
        isPaused = false
        lastUpdate = Date()
        startLoop()
        startSpawn()
    }

    func reset() {
        score = 0
        lives = 3
        gameOver = false
        perfectStreak = 0
        falling.removeAll()
        shots.removeAll()
        isShooting = false
        aimDotsVisible = false
        aimDots.removeAll()
        queuedKind = randomPlayerKind()
        startLoop()
        startSpawn()
    }

    func updateAim(from origin: CGPoint, to location: CGPoint) {
        guard !gameOver, shots.isEmpty else { return }
        var dir = CGPoint(x: location.x - origin.x, y: location.y - origin.y)
        let len = max(1, hypot(dir.x, dir.y))
        dir.x /= len
        dir.y /= len

        let spacing: CGFloat = 24
        let verticalTightness: CGFloat = 0.65

        aimDots = (1...5).map { i in
            let dx = dir.x * spacing * CGFloat(i)
            let dy = dir.y * spacing * CGFloat(i) * verticalTightness
            return CGPoint(x: origin.x + dx, y: origin.y + dy)
        }
        aimDotsVisible = true
    }

    func hideAim() {
        aimDotsVisible = false
        aimDots.removeAll()
    }

    func fire(from origin: CGPoint, towards tap: CGPoint) {
        guard !gameOver, fieldSize != .zero else { return }
        guard shots.isEmpty else { return }

        var dir = CGPoint(x: tap.x - origin.x, y: tap.y - origin.y)
        let len = max(1, hypot(dir.x, dir.y))
        dir.x /= len
        dir.y /= len
        let v = CGPoint(x: dir.x * shootSpeed, y: dir.y * shootSpeed)

        let kind = queuedKind

        let shot = Candy(
            kind: kind,
            pos: origin,
            vel: v,
            radius: candyRadius,
            isPlayerShot: true
        )
        shots.append(shot)
        isShooting = true
        hideAim()

        AudioManager.shared.playShoot()

        queuedKind = randomPlayerKind()
    }

    private func randomPlayerKind() -> CandyKind {

        let rainbowChance = 1
        if Int.random(in: 0..<8) < rainbowChance {
            return .rainbow
        } else {
            return CandyKind.regulars.randomElement()!
        }
    }

    private func spawnExplosion(at pos: CGPoint) {
        var ex = Explosion(pos: pos, frame: 1)
        let id = ex.id
        explosions.append(ex)

        var current = 1
        let t = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) {
            [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            guard let idx = self.explosions.firstIndex(where: { $0.id == id })
            else {
                timer.invalidate()
                return
            }
            current += 1
            if current > 7 {
                self.explosions.remove(at: idx)
                timer.invalidate()
            } else {
                self.explosions[idx].frame = current
            }
        }
        RunLoop.main.add(t, forMode: .common)
    }

    private func startLoop() {
        lastUpdate = Date()
        tickTimer?.cancel()
        tickTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateLoop() }
    }

    private func startSpawn() {
        spawnTimer?.cancel()
        spawnTimer = Timer.publish(every: baseSpawn, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.spawnFalling() }
    }

    private func currentFallSpeed() -> CGFloat {
        let mult = 1.0 + CGFloat(score) / 120.0
        return baseFallSpeed * mult
    }

    private func currentSpawnInterval() -> TimeInterval {
        max(0.45, baseSpawn - TimeInterval(score) * 0.006)
    }

    private func spawnFalling() {
        guard !gameOver, !isPaused, fieldSize != .zero else { return }
        let x = CGFloat.random(
            in: candyRadius...(fieldSize.width - candyRadius)
        )
        let y = -candyRadius
        let kind = CandyKind.regulars.randomElement()!

        falling.append(
            Candy(
                kind: kind,
                pos: CGPoint(x: x, y: y),
                vel: CGPoint(x: 0, y: currentFallSpeed()),
                radius: candyRadius,
                isPlayerShot: false
            )
        )

        let newInterval = currentSpawnInterval()
        spawnTimer?.cancel()
        spawnTimer = Timer.publish(every: newInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.spawnFalling() }
    }

    private func updateLoop() {
        guard !gameOver, !isPaused else { return }
        let now = Date()
        let dt = CGFloat(now.timeIntervalSince(lastUpdate))
        lastUpdate = now

        for i in falling.indices { falling[i].pos.y += falling[i].vel.y * dt }
        for i in shots.indices {
            shots[i].pos.x += shots[i].vel.x * dt
            shots[i].pos.y += shots[i].vel.y * dt
        }

        falling.removeAll { $0.pos.y - $0.radius > fieldSize.height + 40 }
        shots.removeAll {
            $0.pos.y + $0.radius < -60
                || $0.pos.y - $0.radius > fieldSize.height + 60
                || $0.pos.x < -60 || $0.pos.x > fieldSize.width + 60
        }

        var rmFalling = Set<UUID>()
        var rmShots = Set<UUID>()
        for s in shots {
            for f in falling where !rmFalling.contains(f.id) {
                let dx = s.pos.x - f.pos.x
                let dy = s.pos.y - f.pos.y
                let rsum = s.radius + f.radius
                if dx * dx + dy * dy <= rsum * rsum {
                    let ok = (s.kind == f.kind) || (s.kind == .rainbow)
                    if ok {
                        let pts =
                            (s.kind == .rainbow)
                            ? f.kind.scoreValue : s.kind.scoreValue
                        goodHit(points: pts)
                    } else {
                        AudioManager.shared.playExplosion()
                        spawnExplosion(at: f.pos)
                        missHit()
                    }
                    rmFalling.insert(f.id)
                    rmShots.insert(s.id)
                }
            }
        }
        falling.removeAll { rmFalling.contains($0.id) }
        shots.removeAll { rmShots.contains($0.id) }

        if shots.isEmpty { isShooting = false }
    }

    private func goodHit(points: Int) {
        score += points
        perfectStreak += 1
        if perfectStreak >= 10, lives < 3 {
            lives += 1
            perfectStreak = 0
        }

        lastPoints = points
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.lastPoints = nil
        }
    }

    private func missHit() {

        lives -= 1
        perfectStreak = 0
        if lives <= 0 {
            lives = 0
            setGameOver()
        }
    }

    private func setGameOver() {
        AudioManager.shared.playGameOver()
        gameOver = true
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
        tickTimer?.cancel()
        spawnTimer?.cancel()
    }
}
