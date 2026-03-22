import SwiftUI
import SpriteKit

enum GameCharacter: String, CaseIterable, Identifiable {
    case theo = "Theo"
    case ben = "Ben"
    case chuck = "Chuck"
    case stella = "Stella"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .theo: return "The brainy brawler with specs appeal!"
        case .ben: return "The hat-wearing heavyweight!"
        case .chuck: return "The curly-haired champion!"
        case .stella: return "The dazzling diva of destruction!"
        }
    }
    
    var specialMoveName: String {
        switch self {
        case .theo: return "Fart Bomb"
        case .ben: return "Bad Breath Blast"
        case .chuck: return "Booger Flick"
        case .stella: return "Pretty Look"
        }
    }
    
    var specialMoveEmoji: String {
        switch self {
        case .theo: return "💨"
        case .ben: return "🤢"
        case .chuck: return "🟢"
        case .stella: return "✨"
        }
    }
    
    // MARK: - Colors
    
    var skinColor: UIColor { UIColor(red: 1.0, green: 0.85, blue: 0.72, alpha: 1.0) }
    
    var shirtColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)
        case .ben: return UIColor(red: 0.9, green: 0.45, blue: 0.35, alpha: 1.0)
        case .chuck: return UIColor(red: 0.18, green: 0.42, blue: 0.22, alpha: 1.0)
        case .stella: return UIColor(red: 0.75, green: 0.55, blue: 0.58, alpha: 1.0)
        }
    }
    
    var hairColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        case .ben: return UIColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
        case .chuck: return UIColor(red: 0.95, green: 0.85, blue: 0.4, alpha: 1.0)
        case .stella: return UIColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1.0)
        }
    }
    
    var hairHighlightColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.95, green: 0.88, blue: 0.6, alpha: 1.0)
        case .ben: return UIColor(red: 0.55, green: 0.38, blue: 0.2, alpha: 1.0)
        case .chuck: return UIColor(red: 1.0, green: 0.92, blue: 0.55, alpha: 1.0)
        case .stella: return UIColor(red: 0.65, green: 0.4, blue: 0.2, alpha: 1.0)
        }
    }
    
    var pantsColor: UIColor {
        switch self {
        case .theo: return UIColor.darkGray
        case .ben: return UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        case .chuck: return UIColor(red: 0.22, green: 0.48, blue: 0.28, alpha: 1.0)
        case .stella: return UIColor(red: 0.35, green: 0.45, blue: 0.6, alpha: 1.0)
        }
    }
    
    var pillowColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.75, green: 0.88, blue: 1.0, alpha: 1.0)
        case .ben: return UIColor(red: 1.0, green: 0.88, blue: 0.75, alpha: 1.0)
        case .chuck: return UIColor(red: 0.75, green: 1.0, blue: 0.8, alpha: 1.0)
        case .stella: return UIColor(red: 1.0, green: 0.82, blue: 0.92, alpha: 1.0)
        }
    }
    
    var shoeColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        case .ben: return UIColor(red: 0.4, green: 0.28, blue: 0.18, alpha: 1.0)
        case .chuck: return UIColor(red: 0.2, green: 0.38, blue: 0.22, alpha: 1.0)
        case .stella: return UIColor(red: 0.55, green: 0.3, blue: 0.5, alpha: 1.0)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .theo: return .blue
        case .ben: return .red
        case .chuck: return .green
        case .stella: return .purple
        }
    }
    
    var portraitGradient: [Color] {
        switch self {
        case .theo: return [.teal, .cyan]
        case .ben: return [Color(red: 0.9, green: 0.45, blue: 0.35), .orange]
        case .chuck: return [Color(red: 0.18, green: 0.42, blue: 0.22), .mint]
        case .stella: return [Color(red: 0.75, green: 0.55, blue: 0.58), .pink]
        }
    }
}

// MARK: - Move Types

enum MoveType {
    case pillowSwing
    case kick
    case jump
    case special
    case block
    case idle
    case walkForward
    case walkBackward
    case hit
    case knockedOut
    
    var damage: CGFloat {
        switch self {
        case .pillowSwing: return 12
        case .kick: return 9
        case .jump: return 5
        case .special: return 22
        case .block: return 0
        default: return 0
        }
    }
    
    var executionTime: TimeInterval {
        switch self {
        case .pillowSwing: return 0.35
        case .kick: return 0.28
        case .jump: return 0.5
        case .special: return 1.0
        case .block: return 0.1
        default: return 0
        }
    }
    
    var cooldown: TimeInterval {
        switch self {
        case .pillowSwing: return 0.35
        case .kick: return 0.28
        case .jump: return 0.2
        case .special: return 2.5
        case .block: return 0.15
        default: return 0
        }
    }
    
    var range: CGFloat {
        switch self {
        case .pillowSwing: return 75
        case .kick: return 65
        case .jump: return 50
        case .special: return 110
        case .block: return 0
        default: return 0
        }
    }
}
