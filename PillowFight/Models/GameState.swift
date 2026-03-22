import Foundation

enum GamePhase: Equatable {
    case title
    case characterSelect
    case fighting
    case roundEnd(winner: String)
    case matchEnd(winner: String)
}

struct RoundResult {
    let roundNumber: Int
    let winner: GameCharacter
}

struct MatchState {
    var player1Character: GameCharacter = .theo
    var player2Character: GameCharacter = .ben
    var player1Health: CGFloat = 100
    var player2Health: CGFloat = 100
    var currentRound: Int = 1
    var player1Wins: Int = 0
    var player2Wins: Int = 0
    var roundResults: [RoundResult] = []
    var roundsToWin: Int = 2  // Best of 3
    var isRoundActive: Bool = false
    var roundTimer: TimeInterval = 60  // 60 second rounds
    
    var matchWinner: GameCharacter? {
        if player1Wins >= roundsToWin { return player1Character }
        if player2Wins >= roundsToWin { return player2Character }
        return nil
    }
    
    var isMatchOver: Bool { matchWinner != nil }
    
    mutating func resetForNewRound() {
        player1Health = 100
        player2Health = 100
        roundTimer = 60
        isRoundActive = false
    }
    
    mutating func resetForNewMatch() {
        player1Health = 100
        player2Health = 100
        currentRound = 1
        player1Wins = 0
        player2Wins = 0
        roundResults = []
        roundTimer = 60
        isRoundActive = false
    }
}
