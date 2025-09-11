import SwiftUI

struct GameCanvas: View {
    @ObservedObject var vm: GoGoFruitViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {

                ForEach(vm.items) { it in
                    ZStack {

                        Image(
                            it.type == .diamond
                                ? GGFruitAssets.diamondGlow
                                : GGFruitAssets.bombGlow
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: it.radius * 2.8, height: it.radius * 2.8)
                        .opacity(0.8)
                        .blendMode(.screen)
                        .allowsHitTesting(false)

                        Image(
                            it.type == .diamond
                                ? GGFruitAssets.diamond : GGFruitAssets.bomb
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: it.radius * 2, height: it.radius * 2)
                    }
                    .position(it.pos)
                }

                if let f = vm.fruit {
                    Image(vm.fruitSpriteName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: f.radius * 2, height: f.radius * 2)
                        .position(f.pos)
                }

                Image(GGFruitAssets.platform)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: vm.paddleFrame.width,
                        height: vm.paddleFrame.height
                    )
                    .clipped()
                    .position(x: vm.paddleFrame.midX, y: vm.paddleFrame.midY)
                    .shadow(radius: 4)

                ForEach(vm.explosions) { ex in
                    Image("app_anim_bang\(ex.frame)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .position(ex.pos)
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .contentShape(Rectangle())
            .onAppear {
                vm.configureField(size: geo.size)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        vm.movePaddle(to: value.location.x)
                        vm.launchIfNeeded()
                    }
            )
        }
    }
}
