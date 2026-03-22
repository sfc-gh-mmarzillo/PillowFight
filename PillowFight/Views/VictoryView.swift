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
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.3)
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
            
            VStack(spacing: 25) {
                Spacer()
                
                if showTitle {
                    Text("VICTORY!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange, radius: 15)
                        .transition(.scale)
                }
                
                if showCharacter {
                    VStack(spacing: 15) {
                        // Winner portrait
                        CharacterAvatar(character: winnerCharacter, size: 100)
                            .shadow(color: winnerCharacter.accentColor.opacity(0.5), radius: 20)
                        
                        Text("\(winnerName) WINS!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Round results
                        HStack(spacing: 20) {
                            ForEach(gameManager.matchState.roundResults, id: \.roundNumber) { result in
                                VStack(spacing: 4) {
                                    Text("R\(result.roundNumber)")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    CharacterAvatar(character: result.winner, size: 30)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
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
                                .padding(.horizontal, 40)
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
                        }
                        
                        Button {
                            SoundManager.shared.playButtonTap()
                            withAnimation {
                                gameManager.returnToCharacterSelect()
                            }
                        } label: {
                            Text("New Characters")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.15))
                                )
                        }
                        
                        Button {
                            SoundManager.shared.playButtonTap()
                            withAnimation {
                                gameManager.returnToTitle()
                            }
                        } label: {
                            Text("Main Menu")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 40)
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
        
        for i in 0..<60 {
            var piece = ConfettiPiece(
                position: CGPoint(x: CGFloat.random(in: 0...screenWidth), y: -20),
                rotation: Double.random(in: 0...360),
                size: CGSize(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 8...16)),
                color: colors.randomElement()!
            )
            confettiPieces.append(piece)
            
            withAnimation(
                .easeIn(duration: Double.random(in: 2...4))
                .delay(Double(i) * 0.03)
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
