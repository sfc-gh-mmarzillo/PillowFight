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
    
    // Colors for character rendering
    var skinColor: UIColor { UIColor(red: 1.0, green: 0.85, blue: 0.72, alpha: 1.0) }
    
    var shirtColor: UIColor {
        switch self {
        case .theo: return UIColor.systemBlue
        case .ben: return UIColor.systemRed
        case .chuck: return UIColor.systemGreen
        case .stella: return UIColor.systemPurple
        }
    }
    
    var hairColor: UIColor {
        switch self {
        case .theo: return UIColor.brown
        case .ben: return UIColor.brown
        case .chuck: return UIColor(red: 0.95, green: 0.85, blue: 0.4, alpha: 1.0) // Blonde
        case .stella: return UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0) // Dark brown
        }
    }
    
    var pantsColor: UIColor {
        switch self {
        case .theo: return UIColor.darkGray
        case .ben: return UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        case .chuck: return UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        case .stella: return UIColor.systemPink
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
    
    // Character portrait colors for SwiftUI views
    var portraitGradient: [Color] {
        switch self {
        case .theo: return [.blue, .cyan]
        case .ben: return [.red, .orange]
        case .chuck: return [.green, .mint]
        case .stella: return [.purple, .pink]
        }
    }
}

// Move types available to all characters
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
        case .pillowSwing: return 10
        case .kick: return 8
        case .jump: return 5  // Jump itself doesn't do much; used for aerial positioning
        case .special: return 20  // 2x damage
        case .block: return 0
        default: return 0
        }
    }
    
    var executionTime: TimeInterval {
        switch self {
        case .pillowSwing: return 0.4
        case .kick: return 0.35
        case .jump: return 0.6
        case .special: return 1.2  // Takes more time
        case .block: return 0.1
        default: return 0
        }
    }
    
    var cooldown: TimeInterval {
        switch self {
        case .pillowSwing: return 0.5
        case .kick: return 0.4
        case .jump: return 0.3
        case .special: return 3.0  // Longer cooldown for special
        case .block: return 0.2
        default: return 0
        }
    }
    
    var range: CGFloat {
        switch self {
        case .pillowSwing: return 70
        case .kick: return 60
        case .jump: return 50
        case .special: return 100  // Special has more range
        case .block: return 0
        default: return 0
        }
    }
}
