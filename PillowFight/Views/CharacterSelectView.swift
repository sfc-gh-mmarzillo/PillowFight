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
            
            VStack(spacing: 18) {
                // Header
                Text(selectingOpponent ? "CHOOSE YOUR OPPONENT" : "CHOOSE YOUR FIGHTER")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: selectingOpponent ? [.red, .orange] : [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 5)
                    .padding(.top, 35)
                
                // VS indicator
                if selectingOpponent {
                    HStack(spacing: 12) {
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
                    VStack(spacing: 6) {
                        Text(selected.displayName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(selected.description)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 4) {
                            Text("Special:")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                            Text("\(selected.specialMoveEmoji) \(selected.specialMoveName)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
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
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            withAnimation { animateIn = true }
        }
    }
}

// MARK: - Character Card with Mini Sprite Preview

struct CharacterCard: View {
    let character: GameCharacter
    let isSelected: Bool
    let isDisabled: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: character.portraitGradient.map { $0.opacity(isDisabled ? 0.3 : 1) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: isSelected ? .yellow.opacity(0.3) : .clear, radius: 10)
                
                VStack(spacing: 6) {
                    // Character mini-portrait using colored shapes
                    CharacterMiniSprite(character: character)
                        .frame(width: 60, height: 80)
                    
                    Text(character.displayName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(character.specialMoveEmoji)
                        .font(.system(size: 14))
                }
            }
        }
        .opacity(isDisabled ? 0.4 : 1.0)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Mini Character Sprite (SwiftUI)

struct CharacterMiniSprite: View {
    let character: GameCharacter
    
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(character.shirtColor))
                .frame(width: 22, height: 22)
                .offset(y: 8)
            
            // CG-rendered face (replaces manual head/eyes/nose/mouth)
            Image(uiImage: FaceRenderer.uiImage(for: character))
                .resizable()
                .interpolation(.high)
                .frame(width: 42, height: 42)
                .offset(y: -12)
            
            // Character-specific features (hair, glasses, etc.)
            characterFeature
            
            // Shoes
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(character.shoeColor))
                    .frame(width: 10, height: 5)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(character.shoeColor))
                    .frame(width: 10, height: 5)
            }
            .offset(y: 28)
        }
    }
    
    @ViewBuilder
    private var characterFeature: some View {
        switch character {
        case .theo:
            // Glasses over eyes
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 1.5)
                    .stroke(Color(red: 0.3, green: 0.2, blue: 0.7), lineWidth: 1.5)
                    .frame(width: 11, height: 8)
                RoundedRectangle(cornerRadius: 1.5)
                    .stroke(Color(red: 0.3, green: 0.2, blue: 0.7), lineWidth: 1.5)
                    .frame(width: 11, height: 8)
            }
            .offset(y: -11)
            
            // Blonde hair
            hairShape
                .fill(Color(character.hairColor))
                .frame(width: 36, height: 14)
                .offset(y: -25)
            
        case .ben:
            // Trucker cap
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.25, green: 0.25, blue: 0.5))
                .frame(width: 36, height: 12)
                .offset(y: -24)
            
            // Brim
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.25, green: 0.25, blue: 0.5))
                .frame(width: 38, height: 4)
                .offset(y: -19)
            
            // Mullet
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(character.hairColor))
                .frame(width: 30, height: 16)
                .offset(y: -4)
                .zIndex(-1)
            
            // Freckles (tiny dots)
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color(character.skinColor.darker(by: 0.18)))
                    .frame(width: 1.5, height: 1.5)
                    .offset(
                        x: CGFloat([-8, -5, 5, 8][i]),
                        y: -7
                    )
            }
            
        case .chuck:
            // Big curly hair
            ForEach(0..<9, id: \.self) { i in
                let angle = Double(i) * (360.0 / 9.0) - 90
                let rad = angle * .pi / 180
                Circle()
                    .fill(Color(character.hairColor))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: cos(rad) * 16,
                        y: sin(rad) * 13 - 14
                    )
            }
            // Extra top curls for volume
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(character.hairHighlightColor))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat([-8, 0, 8][i]),
                        y: -26
                    )
            }
            
        case .stella:
            // Long wavy hair
            hairShape
                .fill(Color(character.hairColor))
                .frame(width: 36, height: 14)
                .offset(y: -25)
            
            // Long side strands
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(character.hairColor))
                .frame(width: 5, height: 32)
                .offset(x: -16, y: 0)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(character.hairColor))
                .frame(width: 5, height: 32)
                .offset(x: 16, y: 0)
            
            // Highlight streaks
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(character.hairHighlightColor))
                .frame(width: 2, height: 18)
                .offset(x: -15, y: 2)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(character.hairHighlightColor))
                .frame(width: 2, height: 18)
                .offset(x: 15, y: 2)
            
            // Necklace
            Circle()
                .fill(Color(red: 0.9, green: 0.8, blue: 0.5))
                .frame(width: 4, height: 4)
                .offset(y: 2)
            
            // Eyelashes (tiny lines)
            ForEach(0..<2, id: \.self) { i in
                Rectangle()
                    .fill(Color(red: 0.2, green: 0.12, blue: 0.08).opacity(0.6))
                    .frame(width: 1, height: 3)
                    .offset(x: CGFloat([-9, 9][i]), y: -16)
            }
        }
    }
    
    private var hairShape: some Shape {
        RoundedRectangle(cornerRadius: 6)
    }
}
