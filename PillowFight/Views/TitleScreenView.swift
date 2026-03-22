import SwiftUI

struct TitleScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var pillowRotation: Double = 0
    @State private var titleScale: CGFloat = 0.5
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var feathers: [FeatherParticle] = []
    @State private var pulseButton = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.28),
                    Color(red: 0.22, green: 0.12, blue: 0.38),
                    Color(red: 0.08, green: 0.04, blue: 0.18)
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
            
            VStack(spacing: 25) {
                Spacer()
                
                // Pillow icon
                Text("🛏️")
                    .font(.system(size: 65))
                    .rotationEffect(.degrees(pillowRotation))
                    .shadow(color: .purple.opacity(0.4), radius: 15)
                
                // Title
                VStack(spacing: 6) {
                    Text("PILLOW")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.7), radius: 12)
                    
                    Text("FIGHT!")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .red.opacity(0.6), radius: 18)
                }
                .scaleEffect(titleScale)
                
                if showSubtitle {
                    Text("The Ultimate Sleepover Showdown")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .transition(.opacity)
                }
                
                Spacer()
                
                if showButton {
                    // Character avatar preview
                    HStack(spacing: 12) {
                        ForEach(GameCharacter.allCases) { character in
                            CharacterAvatar(character: character, size: 48)
                                .shadow(color: Color(character.shirtColor).opacity(0.4), radius: 6)
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
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 45)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: .orange.opacity(0.5), radius: 12)
                            .scaleEffect(pulseButton ? 1.03 : 1.0)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 45)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            titleScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pillowRotation = 15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showSubtitle = true }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring()) { showButton = true }
        }
        
        // Button pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseButton = true
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            spawnFeather()
        }
    }
    
    private func spawnFeather() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var feather = FeatherParticle(
            position: CGPoint(x: CGFloat.random(in: 0...screenWidth), y: -20),
            rotation: Double.random(in: 0...360),
            size: CGFloat.random(in: 14...24),
            opacity: Double.random(in: 0.2...0.5)
        )
        feathers.append(feather)
        
        withAnimation(.linear(duration: Double.random(in: 3.5...5.5))) {
            if let index = feathers.firstIndex(where: { $0.id == feather.id }) {
                feathers[index].position.y = screenHeight + 20
                feathers[index].position.x += CGFloat.random(in: -50...50)
                feathers[index].rotation += Double.random(in: 180...360)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
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
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
            
            Text(String(character.displayName.prefix(1)))
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            characterFeature
                .offset(x: size * 0.3, y: -size * 0.3)
        }
    }
    
    @ViewBuilder
    private var characterFeature: some View {
        switch character {
        case .theo:
            Text("🤓")
                .font(.system(size: size * 0.28))
        case .ben:
            Text("🧢")
                .font(.system(size: size * 0.28))
        case .chuck:
            Text("🟡")
                .font(.system(size: size * 0.24))
        case .stella:
            Text("💎")
                .font(.system(size: size * 0.28))
        }
    }
}
