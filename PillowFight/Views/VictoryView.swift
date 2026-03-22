import SwiftUI

struct VictoryView: View {
    @EnvironmentObject var gameManager: GameManager
    let winnerName: String
    
    @State private var showTitle = false
    @State private var showCharacter = false
    @State private var showButtons = false
    @State private var confettiPieces: [ConfettiPiece] = []
    
    private var winnerCharacter: GameCharacter {
        GameCharacter.allCases.first { $0.displayName == winnerName } ?? .theo
    }
    
    private var winnerQuote: String {
        switch winnerCharacter {
        case .theo: return "Brains AND brawn!"
        case .ben: return "The mullet is mightier!"
        case .chuck: return "Curls for the win!"
        case .stella: return "Dazzling victory!"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.04, blue: 0.18),
                    Color(red: 0.12, green: 0.08, blue: 0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Confetti
            ForEach(confettiPieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: piece.size.width, height: piece.size.height)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(piece.position)
            }
            
            VStack(spacing: 22) {
                Spacer()
                
                if showTitle {
                    Text("VICTORY!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange, radius: 18)
                        .transition(.scale)
                }
                
                if showCharacter {
                    VStack(spacing: 14) {
                        // Winner portrait
                        CharacterAvatar(character: winnerCharacter, size: 100)
                            .shadow(color: Color(winnerCharacter.shirtColor).opacity(0.6), radius: 25)
                        
                        Text("\(winnerName) WINS!")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(winnerQuote)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                        
                        // Round results
                        HStack(spacing: 18) {
                            ForEach(gameManager.matchState.roundResults, id: \.roundNumber) { result in
                                VStack(spacing: 4) {
                                    Text("R\(result.roundNumber)")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    CharacterAvatar(character: result.winner, size: 30)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                if showButtons {
                    VStack(spacing: 12) {
                        Button {
                            SoundManager.shared.playButtonTap()
                            withAnimation {
                                gameManager.playAgain()
                            }
                        } label: {
                            Text("REMATCH")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 45)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .shadow(color: .orange.opacity(0.4), radius: 10)
                        }
                        
                        Button {
                            SoundManager.shared.playButtonTap()
                            withAnimation {
                                gameManager.returnToCharacterSelect()
                            }
                        } label: {
                            Text("New Characters")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.12))
                                )
                        }
                        
                        Button {
                            SoundManager.shared.playButtonTap()
                            withAnimation {
                                gameManager.returnToTitle()
                            }
                        } label: {
                            Text("Main Menu")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 35)
            }
        }
        .onAppear {
            SoundManager.shared.playVictory()
            startAnimations()
            spawnConfetti()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
            showTitle = true
        }
        withAnimation(.spring().delay(0.6)) {
            showCharacter = true
        }
        withAnimation(.spring().delay(1.0)) {
            showButtons = true
        }
    }
    
    private func spawnConfetti() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple, .pink, .cyan]
        
        for i in 0..<70 {
            var piece = ConfettiPiece(
                position: CGPoint(x: CGFloat.random(in: 0...screenWidth), y: -20),
                rotation: Double.random(in: 0...360),
                size: CGSize(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 8...16)),
                color: colors.randomElement()!
            )
            confettiPieces.append(piece)
            
            withAnimation(
                .easeIn(duration: Double.random(in: 2...4))
                .delay(Double(i) * 0.025)
            ) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].position.y = UIScreen.main.bounds.height + 50
                    confettiPieces[index].position.x += CGFloat.random(in: -80...80)
                    confettiPieces[index].rotation += Double.random(in: 360...720)
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Double
    var size: CGSize
    var color: Color
}
