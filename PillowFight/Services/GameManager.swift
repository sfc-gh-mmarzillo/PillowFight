import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var gamePhase: GamePhase = .title
    @Published var matchState = MatchState()
    @Published var selectedPlayer: GameCharacter = .theo
    @Published var selectedOpponent: GameCharacter = .ben
    
    func selectCharacter(_ character: GameCharacter) {
        selectedPlayer = character
    }
    
    func selectOpponent(_ character: GameCharacter) {
        selectedOpponent = character
    }
    
    func startMatch() {
        matchState.resetForNewMatch()
        matchState.player1Character = selectedPlayer
        matchState.player2Character = selectedOpponent
        gamePhase = .fighting
    }
    
    func handleRoundEnd(player1Won: Bool) {
        if player1Won {
            matchState.player1Wins += 1
        } else {
            matchState.player2Wins += 1
        }
        
        let winnerChar = player1Won ? matchState.player1Character : matchState.player2Character
        matchState.roundResults.append(RoundResult(
            roundNumber: matchState.currentRound,
            winner: winnerChar
        ))
        
        if matchState.isMatchOver {
            let winner = matchState.matchWinner!
            gamePhase = .matchEnd(winner: winner.displayName)
        } else {
            matchState.currentRound += 1
            matchState.resetForNewRound()
            // Small delay then back to fighting for next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.gamePhase = .fighting
            }
        }
    }
    
    func returnToTitle() {
        matchState.resetForNewMatch()
        gamePhase = .title
    }
    
    func returnToCharacterSelect() {
        matchState.resetForNewMatch()
        gamePhase = .characterSelect
    }
    
    func playAgain() {
        matchState.resetForNewMatch()
        gamePhase = .fighting
    }
}
