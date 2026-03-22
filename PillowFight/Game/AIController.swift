import SpriteKit

class AIController {
    
    enum AIState {
        case approaching
        case attacking
        case retreating
        case blocking
        case idle
        case specialSetup
    }
    
    var state: AIState = .idle
    var difficulty: CGFloat = 0.6  // 0.0 = easy, 1.0 = hard
    private var decisionTimer: TimeInterval = 0
    private var decisionInterval: TimeInterval = 0.5
    private var consecutiveAttacks: Int = 0
    private var lastPlayerAttackTime: TimeInterval = 0
    
    func update(deltaTime: TimeInterval, aiFighter: FighterNode, playerFighter: FighterNode, sceneWidth: CGFloat) {
        decisionTimer += deltaTime
        
        guard decisionTimer >= decisionInterval else { return }
        decisionTimer = 0
        
        // More natural decision timing
        decisionInterval = TimeInterval.random(in: (0.25 / Double(difficulty))...(0.7 / Double(difficulty)))
        
        let distance = abs(aiFighter.position.x - playerFighter.position.x)
        let isPlayerAttacking = playerFighter.isExecutingMove
        let healthRatio = aiFighter.health / 100
        
        // Track player attacking for reactive behavior
        if isPlayerAttacking {
            lastPlayerAttackTime = CACurrentMediaTime()
        }
        let timeSincePlayerAttack = CACurrentMediaTime() - lastPlayerAttackTime
        
        // State selection with smarter logic
        if distance > 160 {
            state = .approaching
        } else if distance < 45 {
            // Too close - decide between retreating, blocking, or counter-attacking
            if isPlayerAttacking && CGFloat.random(in: 0...1) < 0.35 * difficulty {
                state = .blocking
            } else if CGFloat.random(in: 0...1) < 0.4 {
                state = .retreating
            } else {
                state = .attacking
            }
        } else if isPlayerAttacking && timeSincePlayerAttack < 0.3 && CGFloat.random(in: 0...1) < 0.3 * difficulty {
            // React to player attacks with blocking
            state = .blocking
        } else if aiFighter.isSpecialReady && healthRatio < 0.35 && CGFloat.random(in: 0...1) < difficulty {
            state = .specialSetup
        } else if aiFighter.isSpecialReady && distance < MoveType.special.range && CGFloat.random(in: 0...1) < 0.2 * difficulty {
            state = .specialSetup
        } else {
            // Normal combat behavior - vary based on health
            let attackChance: CGFloat = healthRatio > 0.5 ? 0.55 : 0.4
            let roll = CGFloat.random(in: 0...1)
            if roll < attackChance {
                state = .attacking
            } else if roll < attackChance + 0.15 {
                state = .retreating
            } else {
                state = .idle
            }
        }
        
        // Execute state behavior
        switch state {
        case .approaching:
            moveTowardPlayer(ai: aiFighter, player: playerFighter)
            
        case .attacking:
            aiFighter.velocityX = 0
            attack(ai: aiFighter, player: playerFighter, distance: distance)
            
        case .retreating:
            moveAwayFromPlayer(ai: aiFighter, player: playerFighter)
            // Occasionally attack while retreating
            if CGFloat.random(in: 0...1) < 0.25 * difficulty {
                attack(ai: aiFighter, player: playerFighter, distance: distance)
            }
            
        case .blocking:
            aiFighter.velocityX = 0
            aiFighter.executeMove(.block)
            
        case .idle:
            aiFighter.velocityX = 0
            // Occasional feint movement
            if CGFloat.random(in: 0...1) < 0.15 {
                aiFighter.velocityX = (CGFloat.random(in: 0...1) < 0.5 ? 1 : -1) * aiFighter.moveSpeed * 0.3
            }
            // Sometimes jump
            if CGFloat.random(in: 0...1) < 0.08 {
                aiFighter.executeMove(.jump)
            }
            
        case .specialSetup:
            if distance > MoveType.special.range - 20 {
                moveTowardPlayer(ai: aiFighter, player: playerFighter)
            } else {
                aiFighter.velocityX = 0
                aiFighter.executeMove(.special)
            }
        }
    }
    
    private func moveTowardPlayer(ai: FighterNode, player: FighterNode) {
        let dir: CGFloat = player.position.x > ai.position.x ? 1 : -1
        // Vary approach speed based on distance
        let distance = abs(ai.position.x - player.position.x)
        let speedMult: CGFloat = distance > 200 ? 0.8 : 0.6
        ai.velocityX = dir * ai.moveSpeed * speedMult
        ai.setFacing(right: dir > 0)
    }
    
    private func moveAwayFromPlayer(ai: FighterNode, player: FighterNode) {
        let dir: CGFloat = player.position.x > ai.position.x ? -1 : 1
        ai.velocityX = dir * ai.moveSpeed * 0.5
    }
    
    private func attack(ai: FighterNode, player: FighterNode, distance: CGFloat) {
        guard ai.canAct else { return }
        
        let roll = CGFloat.random(in: 0...1)
        
        // Special move check
        if ai.isSpecialReady && roll < 0.12 * difficulty && distance < MoveType.special.range {
            ai.executeMove(.special)
            consecutiveAttacks = 0
            return
        }
        
        // Combo attempt: if we just attacked, try to follow up
        if consecutiveAttacks > 0 && consecutiveAttacks < 3 && CGFloat.random(in: 0...1) < 0.5 * difficulty {
            // Follow up with the other attack for variety
            if distance < MoveType.kick.range {
                ai.executeMove(roll < 0.5 ? .kick : .pillowSwing)
                consecutiveAttacks += 1
                return
            }
        }
        
        // Normal attacks
        if distance < MoveType.pillowSwing.range {
            if roll < 0.45 {
                ai.executeMove(.pillowSwing)
            } else if roll < 0.75 {
                ai.executeMove(.kick)
            } else {
                ai.executeMove(.jump)
            }
            consecutiveAttacks += 1
        } else if distance < MoveType.kick.range + 25 {
            ai.executeMove(.kick)
            consecutiveAttacks += 1
        } else {
            consecutiveAttacks = 0
        }
    }
}
