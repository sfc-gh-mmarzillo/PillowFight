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
        case .theo: return UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0) // Teal/green shirt
        case .ben: return UIColor(red: 0.9, green: 0.45, blue: 0.35, alpha: 1.0) // Coral/salmon (Cubs Hawaiian shirt base)
        case .chuck: return UIColor(red: 0.18, green: 0.42, blue: 0.22, alpha: 1.0) // Dark forest green hoodie
        case .stella: return UIColor(red: 0.75, green: 0.55, blue: 0.58, alpha: 1.0) // Dusty rose/mauve top
        }
    }
    
    var hairColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0) // Blonde/light straight hair
        case .ben: return UIColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0) // Brown mullet hair
        case .chuck: return UIColor(red: 0.95, green: 0.85, blue: 0.4, alpha: 1.0) // Blonde curly
        case .stella: return UIColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1.0) // Medium brown/auburn
        }
    }
    
    var hairHighlightColor: UIColor {
        switch self {
        case .theo: return UIColor(red: 0.95, green: 0.88, blue: 0.6, alpha: 1.0) // Lighter blonde
        case .ben: return UIColor(red: 0.55, green: 0.38, blue: 0.2, alpha: 1.0) // Lighter brown
        case .chuck: return UIColor(red: 1.0, green: 0.92, blue: 0.55, alpha: 1.0) // Bright blonde highlight
        case .stella: return UIColor(red: 0.65, green: 0.4, blue: 0.2, alpha: 1.0) // Auburn/caramel highlights
        }
    }
    
    var pantsColor: UIColor {
        switch self {
        case .theo: return UIColor.darkGray
        case .ben: return UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0) // Dark jeans
        case .chuck: return UIColor(red: 0.22, green: 0.48, blue: 0.28, alpha: 1.0) // Matching green hoodie pants
        case .stella: return UIColor(red: 0.35, green: 0.45, blue: 0.6, alpha: 1.0) // Denim blue jeans
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
        case .theo: return [.teal, .cyan]
        case .ben: return [Color(red: 0.9, green: 0.45, blue: 0.35), .orange]
        case .chuck: return [Color(red: 0.18, green: 0.42, blue: 0.22), .mint]
        case .stella: return [Color(red: 0.75, green: 0.55, blue: 0.58), .pink]
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
