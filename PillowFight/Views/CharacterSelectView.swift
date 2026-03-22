import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectingOpponent = false
    @State private var selectedCharacter: GameCharacter? = nil
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.08, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text(selectingOpponent ? "CHOOSE YOUR OPPONENT" : "CHOOSE YOUR FIGHTER")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: selectingOpponent ? [.red, .orange] : [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 5)
                    .padding(.top, 40)
                
                // VS indicator when selecting opponent
                if selectingOpponent {
                    HStack {
                        CharacterAvatar(character: gameManager.selectedPlayer, size: 40)
                        Text("VS")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                        Text("?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .transition(.opacity)
                }
                
                // Character grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    ForEach(GameCharacter.allCases) { character in
                        CharacterCard(
                            character: character,
                            isSelected: selectedCharacter == character,
                            isDisabled: selectingOpponent && character == gameManager.selectedPlayer
                        )
                        .onTapGesture {
                            guard !(selectingOpponent && character == gameManager.selectedPlayer) else { return }
                            SoundManager.shared.playButtonTap()
                            withAnimation(.spring(response: 0.3)) {
                                selectedCharacter = character
                            }
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 30)
                        .animation(
                            .spring(response: 0.5).delay(Double(GameCharacter.allCases.firstIndex(of: character) ?? 0) * 0.1),
                            value: animateIn
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Selected character info
                if let selected = selectedCharacter {
                    VStack(spacing: 8) {
                        Text(selected.displayName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(selected.description)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack {
                            Text("Special:")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                            Text("\(selected.specialMoveEmoji) \(selected.specialMoveName)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Confirm button
                if selectedCharacter != nil {
                    Button {
                        SoundManager.shared.playButtonTap()
                        if selectingOpponent {
                            gameManager.selectOpponent(selectedCharacter!)
                            withAnimation {
                                gameManager.startMatch()
                            }
                        } else {
                            gameManager.selectCharacter(selectedCharacter!)
                            withAnimation {
                                selectingOpponent = true
                                selectedCharacter = nil
                            }
                        }
                    } label: {
                        Text(selectingOpponent ? "FIGHT!" : "SELECT")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: selectingOpponent ? [.red, .orange] : [.yellow, .orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Back button
                Button {
                    SoundManager.shared.playButtonTap()
                    if selectingOpponent {
                        withAnimation {
                            selectingOpponent = false
                            selectedCharacter = nil
                        }
                    } else {
                        withAnimation {
                            gameManager.gamePhase = .title
                        }
                    }
                } label: {
                    Text(selectingOpponent ? "Back" : "Back to Title")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation { animateIn = true }
        }
    }
}

struct CharacterCard: View {
    let character: GameCharacter
    let isSelected: Bool
    let isDisabled: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Character portrait
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: character.portraitGradient.map { $0.opacity(isDisabled ? 0.3 : 1) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: isSelected ? .yellow.opacity(0.3) : .clear, radius: 10)
                
                VStack(spacing: 5) {
                    // Character emoji representation
                    Text(characterEmoji)
                        .font(.system(size: 50))
                    
                    Text(character.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(character.specialMoveEmoji)
                        .font(.system(size: 16))
                }
            }
        }
        .opacity(isDisabled ? 0.4 : 1.0)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
    
    private var characterEmoji: String {
        switch character {
        case .theo: return "🤓"
        case .ben: return "🧢"
        case .chuck: return "👦"
        case .stella: return "👧"
        }
    }
}
