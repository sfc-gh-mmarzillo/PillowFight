import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            switch gameManager.gamePhase {
            case .title:
                TitleScreenView()
                    .transition(.opacity)
                
            case .characterSelect:
                CharacterSelectView()
                    .transition(.move(edge: .trailing))
                
            case .fighting:
                GameView()
                    .transition(.opacity)
                
            case .roundEnd(let winner):
                // Handled within GameView
                GameView()
                
            case .matchEnd(let winner):
                VictoryView(winnerName: winner)
                    .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gamePhase)
    }
    
    // Helper to make gamePhase equatable for animation
    private var gamePhase: String {
        switch gameManager.gamePhase {
        case .title: return "title"
        case .characterSelect: return "characterSelect"
        case .fighting: return "fighting"
        case .roundEnd: return "roundEnd"
        case .matchEnd: return "matchEnd"
        }
    }
}
