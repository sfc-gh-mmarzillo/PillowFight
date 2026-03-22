import SpriteKit

class AIController {
    
    enum AIState {
        case approaching
        case attacking
        case retreating
        case idle
        case specialSetup
    }
    
    var state: AIState = .idle
    var difficulty: CGFloat = 0.6  // 0.0 = easy, 1.0 = hard
    private var decisionTimer: TimeInterval = 0
    private var decisionInterval: TimeInterval = 0.5
    private var reactionDelay: TimeInterval = 0
    
    func update(deltaTime: TimeInterval, aiFighter: FighterNode, playerFighter: FighterNode, sceneWidth: CGFloat) {
        decisionTimer += deltaTime
        
        guard decisionTimer >= decisionInterval else { return }
        decisionTimer = 0
        
        // Randomize decision interval for more natural feel
        decisionInterval = TimeInterval.random(in: (0.3 / Double(difficulty))...(0.8 / Double(difficulty)))
        
        let distance = abs(aiFighter.position.x - playerFighter.position.x)
        let isPlayerAttacking = playerFighter.isExecutingMove
        
        // Determine state
        if distance > 150 {
            state = .approaching
        } else if distance < 50 {
            state = .retreating
        } else if aiFighter.isSpecialReady && aiFighter.health < 40 && CGFloat.random(in: 0...1) < difficulty {
            state = .specialSetup
        } else {
            state = CGFloat.random(in: 0...1) < 0.6 ? .attacking : .idle
        }
        
        // Execute state behavior
        switch state {
        case .approaching:
            moveTowardPlayer(ai: aiFighter, player: playerFighter, sceneWidth: sceneWidth)
            
        case .attacking:
            aiFighter.velocityX = 0
            attack(ai: aiFighter, player: playerFighter, distance: distance)
            
        case .retreating:
            moveAwayFromPlayer(ai: aiFighter, player: playerFighter, sceneWidth: sceneWidth)
            if CGFloat.random(in: 0...1) < 0.3 * difficulty {
                attack(ai: aiFighter, player: playerFighter, distance: distance)
            }
            
        case .idle:
            aiFighter.velocityX = 0
            // Sometimes jump randomly
            if CGFloat.random(in: 0...1) < 0.1 {
                aiFighter.executeMove(.jump)
            }
            
        case .specialSetup:
            // Try to get in range for special
            if distance > MoveType.special.range - 20 {
                moveTowardPlayer(ai: aiFighter, player: playerFighter, sceneWidth: sceneWidth)
            } else {
                aiFighter.velocityX = 0
                aiFighter.executeMove(.special)
            }
        }
    }
    
    private func moveTowardPlayer(ai: FighterNode, player: FighterNode, sceneWidth: CGFloat) {
        let dir: CGFloat = player.position.x > ai.position.x ? 1 : -1
        ai.velocityX = dir * ai.moveSpeed * 0.7
        ai.setFacing(right: dir > 0)
    }
    
    private func moveAwayFromPlayer(ai: FighterNode, player: FighterNode, sceneWidth: CGFloat) {
        let dir: CGFloat = player.position.x > ai.position.x ? -1 : 1
        ai.velocityX = dir * ai.moveSpeed * 0.5
    }
    
    private func attack(ai: FighterNode, player: FighterNode, distance: CGFloat) {
        guard ai.canAct else { return }
        
        let roll = CGFloat.random(in: 0...1)
        
        if ai.isSpecialReady && roll < 0.15 * difficulty && distance < MoveType.special.range {
            ai.executeMove(.special)
        } else if distance < MoveType.pillowSwing.range {
            if roll < 0.5 {
                ai.executeMove(.pillowSwing)
            } else if roll < 0.8 {
                ai.executeMove(.kick)
            } else {
                ai.executeMove(.jump)
            }
        } else if distance < MoveType.kick.range + 20 {
            ai.executeMove(.kick)
        }
    }
}
