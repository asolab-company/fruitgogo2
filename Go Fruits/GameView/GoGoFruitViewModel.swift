import Combine
import SwiftUI

enum GGFruitAssets {
    static let fruit = "app_ic_elements09"
    static let diamond = "app_ic_diamond"
    static let bomb = "app_ic_elements13"
    static let platform = "app_ic_elements14"

    static let diamondGlow = "app_ic_light-1"
    static let bombGlow = "app_ic_light"

    static let heartFull = "app_ic_heart"
    static let heartEmpty = "app_ic_heart-1"
}

enum FruitChoice: Int {
    case blueberry = 1
    case orange = 2
    case watermelon = 3
    case lemon = 4

    var spriteName: String {
        switch self {
        case .blueberry: return "app_ic_elements09"
        case .orange: return "app_ic_elements06"
        case .watermelon: return "app_ic_elements02"
        case .lemon: return "app_ic_elements04"
        }
    }

    var backgroundName: String {
        switch self {
        case .blueberry: return "app_bg_main-4"
        case .orange: return "app_bg_main-2"
        case .watermelon: return "app_bg_main-1"
        case .lemon: return "app_bg_main-3"
        }
    }
}

enum GGItemType {
    case diamond
    case bomb
}

struct GGFallingItem: Identifiable {
    let id = UUID()
    var type: GGItemType
    var pos: CGPoint
    var vel: CGPoint
    var radius: CGFloat
}

struct GGFruit {
    var pos: CGPoint
    var vel: CGPoint
    var radius: CGFloat
}

struct GGExplosion: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var frame: Int = 1
}

final class GoGoFruitViewModel: ObservableObject {
    @Published var isPaused: Bool = false

    @Published var score: Int = 0
    @Published var highScore: Int = UserDefaults.standard.integer(
        forKey: "ggf_highscore_v1"
    )
    @Published var lives: Int = 3
    @Published var gameOver: Bool = false

    @Published var explosions: [GGExplosion] = []

    @Published var items: [GGFallingItem] = []
    @Published var fruit: GGFruit?
    @Published var paddleX: CGFloat = 0
    @Published var fieldSize: CGSize = .zero

    private let paddleWidthBase: CGFloat = 120
    private let paddleHeight: CGFloat = 16
    private let paddleYInset: CGFloat = 24

    private var paddleWidth: CGFloat {

        max(70, paddleWidthBase - CGFloat(score) * 0.15)
    }

    private let fruitSpeed: CGFloat = 360
    private let fruitRadius: CGFloat = 24
    private let diamondRadius: CGFloat = 20
    private let bombRadius: CGFloat = 20

    private let baseFallSpeed: CGFloat = 160
    private let baseSpawn: TimeInterval = 1.1

    private var diamondStreak: Int = 0

    private var tickTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var lastUpdate: Date = .init()

    private let selectedFruitKey = "ggf_selected_fruit_idx"

    private var selectedFruit: FruitChoice {
        let idx = UserDefaults.standard.integer(forKey: selectedFruitKey)
        return FruitChoice(rawValue: idx) ?? .blueberry
    }

    var fruitSpriteName: String { selectedFruit.spriteName }
    var backgroundImageName: String { selectedFruit.backgroundName }

    func configureField(size: CGSize) {
        fieldSize = size
        if fruit == nil {
            respawnFruitOnPaddle()
        }
        startLoop()
        startSpawn()
    }

    func reset() {
        score = 0
        lives = 3
        gameOver = false
        items.removeAll()
        diamondStreak = 0
        respawnFruitOnPaddle()
        startLoop()
        startSpawn()
    }

    func pauseGame() {
        guard !gameOver else { return }
        isPaused = true
        tickTimer?.cancel()
        spawnTimer?.cancel()
    }

    func resumeGame() {
        guard !gameOver else { return }
        isPaused = false

        lastUpdate = Date()
        startLoop()
        startSpawn()
    }

    func movePaddle(to x: CGFloat) {
        guard fieldSize.width > 0 else { return }
        let half = paddleWidth / 2
        paddleX = min(max(x, half), fieldSize.width - half)

        if var f = fruit, f.vel == .zero {
            f.pos.x = paddleX
            fruit = f
        }
    }

    private func respawnFruitOnPaddle() {
        guard fieldSize != .zero else { return }
        let startX = max(
            paddleWidth / 2,
            min(fieldSize.width - paddleWidth / 2, fieldSize.width / 2)
        )
        paddleX = startX

        let pY = fieldSize.height - paddleYInset - paddleHeight / 2
        fruit = GGFruit(
            pos: CGPoint(x: startX, y: pY - fruitRadius - 4),
            vel: .zero,
            radius: fruitRadius
        )
    }

    func launchIfNeeded() {
        guard var f = fruit, f.vel == .zero else { return }

        f.vel = CGPoint(x: fruitSpeed * 0.35, y: -fruitSpeed)
        fruit = f
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
        spawnTimer = Timer.publish(
            every: currentSpawnInterval(),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in self?.spawnFalling() }
    }

    private func currentSpawnInterval() -> TimeInterval {

        max(0.45, baseSpawn - TimeInterval(score) * 0.004)
    }

    private func currentFallSpeed() -> CGFloat {
        1.0 * baseFallSpeed + CGFloat(score) * 0.6
    }

    private func spawnFalling() {
        guard !gameOver, fieldSize != .zero else { return }
        let x = CGFloat.random(in: 20...(fieldSize.width - 20))
        let y: CGFloat = -24

        let isDiamond = (Int.random(in: 0..<10) < 6)
        let type: GGItemType = isDiamond ? .diamond : .bomb

        items.append(
            GGFallingItem(
                type: type,
                pos: CGPoint(x: x, y: y),
                vel: CGPoint(x: 0, y: currentFallSpeed()),
                radius: isDiamond ? diamondRadius : bombRadius
            )
        )

        spawnTimer?.cancel()
        spawnTimer = Timer.publish(
            every: currentSpawnInterval(),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in self?.spawnFalling() }
    }

    private func updateLoop() {
        guard !gameOver, !isPaused else { return }
        let now = Date()
        let dt = CGFloat(now.timeIntervalSince(lastUpdate))
        lastUpdate = now

        for i in items.indices {
            items[i].pos.y += items[i].vel.y * dt
        }

        items.removeAll { $0.pos.y - $0.radius > fieldSize.height + 40 }

        if var f = fruit {
            if f.vel != .zero {
                f.pos.x += f.vel.x * dt
                f.pos.y += f.vel.y * dt

                if f.pos.x - f.radius < 0 {
                    f.pos.x = f.radius
                    f.vel.x *= -1
                }
                if f.pos.x + f.radius > fieldSize.width {
                    f.pos.x = fieldSize.width - f.radius
                    f.vel.x *= -1
                }
                if f.pos.y - f.radius < 0 {
                    f.pos.y = f.radius
                    f.vel.y *= -1
                }

                let paddleRect = CGRect(
                    x: paddleX - paddleWidth / 2,
                    y: fieldSize.height - paddleYInset - paddleHeight,
                    width: paddleWidth,
                    height: paddleHeight
                )
                if circleIntersectsRect(
                    center: f.pos,
                    radius: f.radius,
                    rect: paddleRect
                ),
                    f.vel.y > 0
                {

                    let hitX =
                        (f.pos.x - paddleRect.midX) / (paddleRect.width / 2)
                    let clampHit = max(-1, min(1, hitX))
                    let speed = hypot(f.vel.x, f.vel.y)
                    let angle: CGFloat = .pi * (1.2 - 0.5 * clampHit)
                    f.vel = CGPoint(
                        x: speed * cos(angle),
                        y: -abs(speed * sin(angle))
                    )
                    f.pos.y = paddleRect.minY - f.radius - 0.5
                }

                if f.pos.y - f.radius > fieldSize.height {
                    loseLife()
                    respawnFruitOnPaddle()
                }
            }
            fruit = f
        }

        if var f = fruit, f.vel != .zero {
            var toRemove = Set<UUID>()
            for it in items {
                if circleIntersectsCircle(
                    c1: f.pos,
                    r1: f.radius,
                    c2: it.pos,
                    r2: it.radius
                ) {
                    switch it.type {
                    case .diamond:
                        score += 10
                        diamondStreak += 1
                        if diamondStreak >= 3, lives < 3 {
                            lives += 1
                            diamondStreak = 0
                        }
                        AudioManager.shared.playShoot()
                    case .bomb:
                        spawnExplosion(at: it.pos)
                        loseLife()
                        diamondStreak = 0
                        AudioManager.shared.playExplosion()
                    }
                    toRemove.insert(it.id)
                }
            }
            items.removeAll { toRemove.contains($0.id) }
        }

    }

    private func loseLife() {
        lives -= 1
        if lives <= 0 {
            lives = 0
            setGameOver()
        }
    }

    private func setGameOver() {
        gameOver = true
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "ggf_highscore_v1")
        }
        tickTimer?.cancel()
        spawnTimer?.cancel()
        AudioManager.shared.playGameOver()
    }

    private func circleIntersectsCircle(
        c1: CGPoint,
        r1: CGFloat,
        c2: CGPoint,
        r2: CGFloat
    ) -> Bool {
        let dx = c1.x - c2.x
        let dy = c1.y - c2.y
        return dx * dx + dy * dy <= (r1 + r2) * (r1 + r2)
    }

    private func circleIntersectsRect(
        center: CGPoint,
        radius: CGFloat,
        rect: CGRect
    ) -> Bool {
        let closestX = min(max(center.x, rect.minX), rect.maxX)
        let closestY = min(max(center.y, rect.minY), rect.maxY)
        let dx = center.x - closestX
        let dy = center.y - closestY
        return (dx * dx + dy * dy) <= radius * radius
    }

    var paddleFrame: CGRect {
        CGRect(
            x: paddleX - paddleWidth / 2,
            y: max(0, fieldSize.height - paddleYInset - paddleHeight),
            width: paddleWidth,
            height: paddleHeight
        )
    }

    private func spawnExplosion(at pos: CGPoint) {
        var ex = GGExplosion(pos: pos, frame: 1)
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
}
