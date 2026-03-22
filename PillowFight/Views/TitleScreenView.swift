import SwiftUI

struct TitleScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var pillowRotation: Double = 0
    @State private var titleScale: CGFloat = 0.5
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var feathers: [FeatherParticle] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    Color(red: 0.25, green: 0.15, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Floating feathers
            ForEach(feathers) { feather in
                Text("🪶")
                    .font(.system(size: feather.size))
                    .rotationEffect(.degrees(feather.rotation))
                    .position(feather.position)
                    .opacity(feather.opacity)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Pillow icon
                Text("🛏️")
                    .font(.system(size: 60))
                    .rotationEffect(.degrees(pillowRotation))
                
                // Title
                VStack(spacing: 8) {
                    Text("PILLOW")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange, radius: 10)
                    
                    Text("FIGHT!")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .red, radius: 15)
                }
                .scaleEffect(titleScale)
                
                if showSubtitle {
                    Text("The Ultimate Sleepover Showdown")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.opacity)
                }
                
                Spacer()
                
                if showButton {
                    // Character avatars preview
                    HStack(spacing: 15) {
                        ForEach(GameCharacter.allCases) { character in
                            CharacterAvatar(character: character, size: 50)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Button {
                        SoundManager.shared.playButtonTap()
                        withAnimation {
                            gameManager.gamePhase = .characterSelect
                        }
                    } label: {
                        Text("START GAME")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: .orange.opacity(0.5), radius: 10)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Title scale in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            titleScale = 1.0
        }
        
        // Pillow wobble
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pillowRotation = 15
        }
        
        // Show subtitle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showSubtitle = true }
        }
        
        // Show button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring()) { showButton = true }
        }
        
        // Spawn feathers
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            spawnFeather()
        }
    }
    
    private func spawnFeather() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var feather = FeatherParticle(
            position: CGPoint(x: CGFloat.random(in: 0...screenWidth), y: -20),
            rotation: Double.random(in: 0...360),
            size: CGFloat.random(in: 15...25),
            opacity: Double.random(in: 0.3...0.6)
        )
        feathers.append(feather)
        
        // Animate down
        withAnimation(.linear(duration: Double.random(in: 3...5))) {
            if let index = feathers.firstIndex(where: { $0.id == feather.id }) {
                feathers[index].position.y = screenHeight + 20
                feathers[index].position.x += CGFloat.random(in: -50...50)
                feathers[index].rotation += Double.random(in: 180...360)
            }
        }
        
        // Clean up old feathers
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            feathers.removeAll { $0.position.y > screenHeight }
        }
    }
}

struct FeatherParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Double
    var size: CGFloat
    var opacity: Double
}

struct CharacterAvatar: View {
    let character: GameCharacter
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: character.portraitGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Character initial
            Text(String(character.displayName.prefix(1)))
                .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Special feature
            characterFeature
                .offset(x: size * 0.3, y: -size * 0.3)
        }
    }
    
    @ViewBuilder
    private var characterFeature: some View {
        switch character {
        case .theo:
            Text("🤓")
                .font(.system(size: size * 0.3))
        case .ben:
            Text("🧢")
                .font(.system(size: size * 0.3))
        case .chuck:
            Text("🟡")
                .font(.system(size: size * 0.25))
        case .stella:
            Text("🎀")
                .font(.system(size: size * 0.3))
        }
    }
}
