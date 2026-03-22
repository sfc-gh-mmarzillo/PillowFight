import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var scene: FightScene?
    @State private var isMovingLeft = false
    @State private var isMovingRight = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Score display
                HStack {
                    // P1 wins
                    HStack(spacing: 4) {
                        ForEach(0..<gameManager.matchState.roundsToWin, id: \.self) { i in
                            Circle()
                                .fill(i < gameManager.matchState.player1Wins ? Color.yellow : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                    }
                    
                    Spacer()
                    
                    Text("ROUND \(gameManager.matchState.currentRound)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    // P2 wins
                    HStack(spacing: 4) {
                        ForEach(0..<gameManager.matchState.roundsToWin, id: \.self) { i in
                            Circle()
                                .fill(i < gameManager.matchState.player2Wins ? Color.yellow : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)
                
                // SpriteKit scene
                GeometryReader { geometry in
                    if let scene = scene {
                        SpriteView(scene: scene)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .onAppear {
                    setupScene()
                }
                
                // Controls
                controlsView
                    .padding(.bottom, 10)
            }
        }
    }
    
    private var controlsView: some View {
        HStack(spacing: 0) {
            // Movement controls (left side)
            HStack(spacing: 12) {
                // Left button
                ControlButton(label: "<", color: .blue) {
                    scene?.playerMoveLeft()
                } onRelease: {
                    scene?.playerStopMoving()
                }
                
                // Jump button
                ControlButton(label: "^", color: .cyan) {
                    scene?.playerJump()
                } onRelease: {}
                
                // Right button
                ControlButton(label: ">", color: .blue) {
                    scene?.playerMoveRight()
                } onRelease: {
                    scene?.playerStopMoving()
                }
            }
            .padding(.leading, 15)
            
            Spacer()
            
            // Attack controls (right side)
            HStack(spacing: 10) {
                // Pillow swing
                ControlButton(label: "🛏️", color: .white, fontSize: 20) {
                    scene?.playerPillowSwing()
                } onRelease: {}
                
                // Kick
                ControlButton(label: "🦶", color: .orange, fontSize: 20) {
                    scene?.playerKick()
                } onRelease: {}
                
                // Special
                ControlButton(
                    label: gameManager.matchState.player1Character.specialMoveEmoji,
                    color: .yellow,
                    fontSize: 20,
                    isSpecial: true
                ) {
                    scene?.playerSpecial()
                } onRelease: {}
            }
            .padding(.trailing, 15)
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.8))
    }
    
    private func setupScene() {
        let screenSize = UIScreen.main.bounds.size
        let sceneHeight = screenSize.height * 0.6
        
        let newScene = FightScene(size: CGSize(width: screenSize.width, height: sceneHeight))
        newScene.scaleMode = .aspectFill
        newScene.player1Character = gameManager.matchState.player1Character
        newScene.player2Character = gameManager.matchState.player2Character
        newScene.currentRound = gameManager.matchState.currentRound
        
        newScene.onRoundEnd = { [weak gameManager] player1Won in
            gameManager?.handleRoundEnd(player1Won: player1Won)
        }
        
        newScene.onHealthUpdate = { [weak gameManager] p1Health, p2Health in
            gameManager?.matchState.player1Health = p1Health
            gameManager?.matchState.player2Health = p2Health
        }
        
        scene = newScene
    }
}

struct ControlButton: View {
    let label: String
    let color: Color
    var fontSize: CGFloat = 16
    var isSpecial: Bool = false
    let onPress: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Text(label)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundColor(isSpecial ? .black : .white)
            .frame(width: isSpecial ? 55 : 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSpecial ?
                        AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)) :
                        AnyShapeStyle(color.opacity(isPressed ? 0.6 : 0.3))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onRelease()
                    }
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}
