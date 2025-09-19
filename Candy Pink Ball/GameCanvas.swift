import SwiftUI

struct GameCanvas: View {
    @ObservedObject var vm: GameViewModel

    var body: some View {
        GeometryReader { geo in
            let playerOrigin = CGPoint(
                x: geo.size.width * 0.5,
                y: geo.size.height - 40
            )

            ZStack {

                ForEach(vm.falling) { c in

                    let speed = max(1, hypot(c.vel.x, c.vel.y))
                    let length = min(200, max(70, speed * 0.25))
                    let width = max(18, c.radius * 1.6)
                    let alpha: CGFloat = 0.5

                    ZStack {

                        VerticalCandyTrail(
                            length: length,
                            baseWidth: width,
                            baseOpacity: alpha
                        )

                        Image(c.kind.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: c.radius * 2, height: c.radius * 2)
                    }
                    .position(c.pos)
                }

                ForEach(vm.shots) { c in
                    Image(c.kind.imageName)
                        .resizable().scaledToFit()
                        .frame(width: c.radius * 2, height: c.radius * 2)
                        .position(c.pos)
                }

                ForEach(vm.explosions) { ex in
                    Image("app_anim_bang\(ex.frame)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .position(ex.pos)
                }

                if vm.aimDotsVisible {
                    ForEach(Array(vm.aimDots.enumerated()), id: \.offset) {
                        idx,
                        p in
                        Circle()
                            .fill(
                                Color.white.opacity(0.85 - Double(idx) * 0.12)
                            )
                            .frame(
                                width: CGFloat(8 - idx),
                                height: CGFloat(8 - idx)
                            )
                            .position(p)
                    }
                }

                Image(vm.queuedKind.imageName)
                    .resizable().scaledToFit()
                    .frame(width: 50, height: 50)
                    .saturation(vm.isShooting ? 0.0 : 1.0)
                    .opacity(vm.isShooting ? 0.5 : 1.0)
                    .shadow(radius: 6)
                    .position(playerOrigin)
            }
            .contentShape(Rectangle())
            .onAppear {
                vm.configureField(size: geo.size)
                vm.reset()
            }

            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        vm.updateAim(from: playerOrigin, to: value.location)
                    }
                    .onEnded { value in
                        vm.fire(from: playerOrigin, towards: value.location)
                    }
            )
        }
    }
}

struct TrailTriangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.midX, y: r.minY))
        p.closeSubpath()
        return p
    }
}

struct VerticalCandyTrail: View {
    let length: CGFloat
    let baseWidth: CGFloat
    let baseOpacity: CGFloat

    var body: some View {
        TrailTriangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(baseOpacity),
                        Color.white.opacity(0.0),
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: baseWidth, height: length)
            .blur(radius: 4)
            .blendMode(.screen)
            .allowsHitTesting(false)

            .offset(y: -length * 0.5)
    }
}
