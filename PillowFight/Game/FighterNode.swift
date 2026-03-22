import SpriteKit

class FighterNode: SKNode {
    
    let character: GameCharacter
    let isPlayer1: Bool
    
    // Visual components
    private var bodyNode: SKShapeNode!
    private var headNode: SKShapeNode!
    private var hairNode: SKNode!
    private var leftArmNode: SKShapeNode!
    private var rightArmNode: SKShapeNode!
    private var pillowNode: SKShapeNode!
    private var leftLegNode: SKShapeNode!
    private var rightLegNode: SKShapeNode!
    private var featureNodes: [SKNode] = []
    
    // State
    var currentMove: MoveType = .idle
    var isExecutingMove: Bool = false
    var canAct: Bool = true
    var facingRight: Bool
    var health: CGFloat = 100
    private var specialCooldownTimer: TimeInterval = 0
    var isSpecialReady: Bool { specialCooldownTimer <= 0 }
    
    // Physics
    var velocityX: CGFloat = 0
    var velocityY: CGFloat = 0
    var isOnGround: Bool = true
    let groundY: CGFloat
    let moveSpeed: CGFloat = 200
    let jumpForce: CGFloat = 450
    let gravity: CGFloat = -900
    
    // Hit detection
    var attackHitbox: CGRect {
        let dir: CGFloat = facingRight ? 1 : -1
        let range = currentMove.range
        let x = position.x + (dir * 25)
        return CGRect(x: x - (facingRight ? 0 : range), y: position.y - 20, width: range, height: 60)
    }
    
    var bodyHitbox: CGRect {
        CGRect(x: position.x - 20, y: position.y - 30, width: 40, height: 80)
    }
    
    init(character: GameCharacter, isPlayer1: Bool, groundY: CGFloat) {
        self.character = character
        self.isPlayer1 = isPlayer1
        self.facingRight = isPlayer1
        self.groundY = groundY
        super.init()
        buildCharacter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildCharacter() {
        let scale: CGFloat = 1.0
        
        // Body (torso)
        let bodyPath = UIBezierPath(roundedRect: CGRect(x: -12, y: -5, width: 24, height: 30), cornerRadius: 4)
        bodyNode = SKShapeNode(path: bodyPath.cgPath)
        bodyNode.fillColor = character.shirtColor
        bodyNode.strokeColor = character.shirtColor.darker()
        bodyNode.lineWidth = 1.5
        addChild(bodyNode)
        
        // Pants
        let pantsPath = UIBezierPath(roundedRect: CGRect(x: -12, y: -25, width: 24, height: 22), cornerRadius: 3)
        let pantsNode = SKShapeNode(path: pantsPath.cgPath)
        pantsNode.fillColor = character.pantsColor
        pantsNode.strokeColor = character.pantsColor.darker()
        pantsNode.lineWidth = 1.5
        addChild(pantsNode)
        
        // Left leg
        leftLegNode = SKShapeNode(rect: CGRect(x: -10, y: -40, width: 8, height: 18), cornerRadius: 2)
        leftLegNode.fillColor = character.pantsColor
        leftLegNode.strokeColor = character.pantsColor.darker()
        addChild(leftLegNode)
        
        // Right leg
        rightLegNode = SKShapeNode(rect: CGRect(x: 2, y: -40, width: 8, height: 18), cornerRadius: 2)
        rightLegNode.fillColor = character.pantsColor
        rightLegNode.strokeColor = character.pantsColor.darker()
        addChild(rightLegNode)
        
        // Shoes
        let leftShoe = SKShapeNode(rect: CGRect(x: -12, y: -45, width: 12, height: 7), cornerRadius: 3)
        leftShoe.fillColor = .darkGray
        leftShoe.strokeColor = .black
        addChild(leftShoe)
        
        let rightShoe = SKShapeNode(rect: CGRect(x: 0, y: -45, width: 12, height: 7), cornerRadius: 3)
        rightShoe.fillColor = .darkGray
        rightShoe.strokeColor = .black
        addChild(rightShoe)
        
        // Head
        headNode = SKShapeNode(circleOfRadius: 16)
        headNode.position = CGPoint(x: 0, y: 42)
        headNode.fillColor = character.skinColor
        headNode.strokeColor = character.skinColor.darker()
        headNode.lineWidth = 1.5
        addChild(headNode)
        
        // Eyes
        let leftEye = SKShapeNode(ellipseOf: CGSize(width: 5, height: 6))
        leftEye.position = CGPoint(x: -6, y: 44)
        leftEye.fillColor = .white
        leftEye.strokeColor = .black
        leftEye.lineWidth = 1
        addChild(leftEye)
        
        let leftPupil = SKShapeNode(circleOfRadius: 2)
        leftPupil.position = CGPoint(x: -5, y: 44)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        addChild(leftPupil)
        
        let rightEye = SKShapeNode(ellipseOf: CGSize(width: 5, height: 6))
        rightEye.position = CGPoint(x: 6, y: 44)
        rightEye.fillColor = .white
        rightEye.strokeColor = .black
        rightEye.lineWidth = 1
        addChild(rightEye)
        
        let rightPupil = SKShapeNode(circleOfRadius: 2)
        rightPupil.position = CGPoint(x: 7, y: 44)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        addChild(rightPupil)
        
        // Mouth
        let mouth = SKShapeNode(rect: CGRect(x: -4, y: 36, width: 8, height: 2), cornerRadius: 1)
        mouth.fillColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1)
        mouth.strokeColor = .clear
        addChild(mouth)
        
        // Arms
        leftArmNode = SKShapeNode(rect: CGRect(x: -22, y: 0, width: 8, height: 22), cornerRadius: 3)
        leftArmNode.fillColor = character.skinColor
        leftArmNode.strokeColor = character.skinColor.darker()
        addChild(leftArmNode)
        
        rightArmNode = SKShapeNode(rect: CGRect(x: 14, y: 0, width: 8, height: 22), cornerRadius: 3)
        rightArmNode.fillColor = character.skinColor
        rightArmNode.strokeColor = character.skinColor.darker()
        addChild(rightArmNode)
        
        // Pillow (held in hand)
        pillowNode = SKShapeNode(rect: CGRect(x: -8, y: -5, width: 16, height: 22), cornerRadius: 6)
        pillowNode.fillColor = .white
        pillowNode.strokeColor = UIColor.lightGray
        pillowNode.lineWidth = 1.5
        pillowNode.position = CGPoint(x: facingRight ? 24 : -24, y: 10)
        addChild(pillowNode)
        
        // Pillow fluff lines
        let fluff1 = SKShapeNode(rect: CGRect(x: -4, y: 2, width: 8, height: 1))
        fluff1.fillColor = UIColor.lightGray
        fluff1.strokeColor = .clear
        pillowNode.addChild(fluff1)
        
        let fluff2 = SKShapeNode(rect: CGRect(x: -3, y: 7, width: 6, height: 1))
        fluff2.fillColor = UIColor.lightGray
        fluff2.strokeColor = .clear
        pillowNode.addChild(fluff2)
        
        // Character-specific features
        buildCharacterFeatures()
        
        // Hair (on top of head, after features so glasses go under hair)
        buildHair()
        
        // Name label
        let nameLabel = SKLabelNode(text: character.displayName)
        nameLabel.fontSize = 12
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 65)
        addChild(nameLabel)
        
        // Set initial facing direction
        self.xScale = facingRight ? scale : -scale
    }
    
    private func buildHair() {
        switch character {
        case .theo:
            // Short brown hair
            let hair = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -14, y: 48))
                path.addQuadCurve(to: CGPoint(x: 14, y: 48), controlPoint: CGPoint(x: 0, y: 62))
                path.addLine(to: CGPoint(x: 12, y: 44))
                path.addLine(to: CGPoint(x: -12, y: 44))
                path.close()
                return path.cgPath
            }())
            hair.fillColor = character.hairColor
            hair.strokeColor = character.hairColor.darker()
            addChild(hair)
            
        case .ben:
            // White hat/cap
            let hat = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -18, y: 48))
                path.addLine(to: CGPoint(x: -18, y: 54))
                path.addQuadCurve(to: CGPoint(x: 18, y: 54), controlPoint: CGPoint(x: 0, y: 64))
                path.addLine(to: CGPoint(x: 18, y: 48))
                path.close()
                return path.cgPath
            }())
            hat.fillColor = .white
            hat.strokeColor = UIColor.lightGray
            hat.lineWidth = 1.5
            addChild(hat)
            
            // Hat brim
            let brim = SKShapeNode(rect: CGRect(x: -20, y: 46, width: 40, height: 4), cornerRadius: 2)
            brim.fillColor = .white
            brim.strokeColor = UIColor.lightGray
            addChild(brim)
            
        case .chuck:
            // Blonde curly hair
            let curlyHair = SKNode()
            let positions: [(CGFloat, CGFloat)] = [
                (-12, 52), (-6, 56), (0, 58), (6, 56), (12, 52),
                (-14, 46), (-10, 48), (10, 48), (14, 46),
                (-8, 58), (8, 58)
            ]
            for pos in positions {
                let curl = SKShapeNode(circleOfRadius: 5)
                curl.position = CGPoint(x: pos.0, y: pos.1)
                curl.fillColor = character.hairColor
                curl.strokeColor = character.hairColor.darker()
                curl.lineWidth = 0.5
                curlyHair.addChild(curl)
            }
            addChild(curlyHair)
            
        case .stella:
            // Long hair with a bow
            let hair = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -16, y: 50))
                path.addQuadCurve(to: CGPoint(x: 16, y: 50), controlPoint: CGPoint(x: 0, y: 62))
                path.addLine(to: CGPoint(x: 14, y: 44))
                path.addLine(to: CGPoint(x: -14, y: 44))
                path.close()
                return path.cgPath
            }())
            hair.fillColor = character.hairColor
            hair.strokeColor = character.hairColor.darker()
            addChild(hair)
            
            // Side hair (long, flowing down)
            let leftHairSide = SKShapeNode(rect: CGRect(x: -18, y: 25, width: 6, height: 30), cornerRadius: 3)
            leftHairSide.fillColor = character.hairColor
            leftHairSide.strokeColor = character.hairColor.darker()
            addChild(leftHairSide)
            
            let rightHairSide = SKShapeNode(rect: CGRect(x: 12, y: 25, width: 6, height: 30), cornerRadius: 3)
            rightHairSide.fillColor = character.hairColor
            rightHairSide.strokeColor = character.hairColor.darker()
            addChild(rightHairSide)
            
            // Bow
            let bow = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -6, y: 56))
                path.addQuadCurve(to: CGPoint(x: 0, y: 56), controlPoint: CGPoint(x: -3, y: 62))
                path.addQuadCurve(to: CGPoint(x: 6, y: 56), controlPoint: CGPoint(x: 3, y: 62))
                path.addQuadCurve(to: CGPoint(x: 0, y: 56), controlPoint: CGPoint(x: 3, y: 50))
                path.addQuadCurve(to: CGPoint(x: -6, y: 56), controlPoint: CGPoint(x: -3, y: 50))
                path.close()
                return path.cgPath
            }())
            bow.fillColor = .systemPink
            bow.strokeColor = UIColor.systemPink.darker()
            bow.lineWidth = 1
            addChild(bow)
        }
    }
    
    private func buildCharacterFeatures() {
        switch character {
        case .theo:
            // Glasses
            let leftLens = SKShapeNode(circleOfRadius: 7)
            leftLens.position = CGPoint(x: -6, y: 44)
            leftLens.fillColor = .clear
            leftLens.strokeColor = .darkGray
            leftLens.lineWidth = 2
            addChild(leftLens)
            
            let rightLens = SKShapeNode(circleOfRadius: 7)
            rightLens.position = CGPoint(x: 6, y: 44)
            rightLens.fillColor = .clear
            rightLens.strokeColor = .darkGray
            rightLens.lineWidth = 2
            addChild(rightLens)
            
            // Bridge
            let bridge = SKShapeNode(rect: CGRect(x: -1, y: 43, width: 2, height: 2))
            bridge.fillColor = .darkGray
            bridge.strokeColor = .clear
            addChild(bridge)
            
        case .ben:
            break  // White hat is done in buildHair()
            
        case .chuck:
            // Freckles
            let frecklePositions: [(CGFloat, CGFloat)] = [(-8, 40), (-4, 39), (4, 39), (8, 40)]
            for pos in frecklePositions {
                let freckle = SKShapeNode(circleOfRadius: 1)
                freckle.position = CGPoint(x: pos.0, y: pos.1)
                freckle.fillColor = UIColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.6)
                freckle.strokeColor = .clear
                addChild(freckle)
            }
            
        case .stella:
            // Rosy cheeks
            let leftCheek = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
            leftCheek.position = CGPoint(x: -10, y: 40)
            leftCheek.fillColor = UIColor(red: 1, green: 0.6, blue: 0.7, alpha: 0.5)
            leftCheek.strokeColor = .clear
            addChild(leftCheek)
            
            let rightCheek = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
            rightCheek.position = CGPoint(x: 10, y: 40)
            rightCheek.fillColor = UIColor(red: 1, green: 0.6, blue: 0.7, alpha: 0.5)
            rightCheek.strokeColor = .clear
            addChild(rightCheek)
        }
    }
    
    // MARK: - Actions
    
    func executeMove(_ move: MoveType) {
        guard canAct && !isExecutingMove else { return }
        if move == .special && !isSpecialReady { return }
        
        currentMove = move
        isExecutingMove = true
        canAct = false
        
        switch move {
        case .pillowSwing:
            animatePillowSwing()
        case .kick:
            animateKick()
        case .jump:
            if isOnGround {
                velocityY = jumpForce
                isOnGround = false
            }
            finishMove(after: move.executionTime)
        case .special:
            animateSpecialMove()
            specialCooldownTimer = move.cooldown
        case .block:
            animateBlock()
        default:
            finishMove(after: 0.1)
        }
    }
    
    private func finishMove(after delay: TimeInterval) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [weak self] in
                self?.currentMove = .idle
                self?.isExecutingMove = false
                self?.canAct = true
            }
        ]))
    }
    
    private func animatePillowSwing() {
        let swingDir: CGFloat = 1.0  // always swing forward relative to facing
        let swingForward = SKAction.moveBy(x: 0, y: 15, duration: 0.1)
        let swingBack = SKAction.moveBy(x: 0, y: -15, duration: 0.1)
        let scaleUp = SKAction.scaleX(to: 1.3, y: 1.3, duration: 0.1)
        let scaleDown = SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.1)
        
        pillowNode.run(SKAction.sequence([
            SKAction.group([swingForward, scaleUp]),
            SKAction.group([swingBack, scaleDown])
        ]))
        
        // Add feather particle burst
        spawnFeathers(at: pillowNode.position)
        
        finishMove(after: MoveType.pillowSwing.executionTime)
    }
    
    private func animateKick() {
        let kickLeg = facingRight ? rightLegNode! : leftLegNode!
        let kickOut = SKAction.moveBy(x: facingRight ? 15 : -15, y: 0, duration: 0.1)
        let kickReturn = SKAction.moveBy(x: facingRight ? -15 : 15, y: 0, duration: 0.15)
        kickLeg.run(SKAction.sequence([kickOut, kickReturn]))
        finishMove(after: MoveType.kick.executionTime)
    }
    
    private func animateSpecialMove() {
        switch character {
        case .theo:
            // Fart animation - green cloud behind
            spawnFartCloud()
        case .ben:
            // Bad breath - yellow-green cloud in front
            spawnBreathCloud()
        case .chuck:
            // Booger flick - green projectile
            spawnBoogerProjectile()
        case .stella:
            // Pretty look - sparkles and hearts
            spawnPrettyLookEffect()
        }
        finishMove(after: MoveType.special.executionTime)
    }
    
    private func animateBlock() {
        pillowNode.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: 0, y: 20), duration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.move(to: CGPoint(x: facingRight ? 24 : -24, y: 10), duration: 0.1)
        ]))
        finishMove(after: 0.7)
    }
    
    func animateHit() {
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])
        run(SKAction.repeat(flash, count: 3))
        
        // Knockback
        let knockbackDir: CGFloat = facingRight ? -1 : 1
        run(SKAction.moveBy(x: knockbackDir * 20, y: 0, duration: 0.1))
    }
    
    func animateKO() {
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        let fall = SKAction.moveBy(x: 0, y: -30, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        run(SKAction.group([spin, fall, fadeOut]))
    }
    
    // MARK: - Special Move Effects
    
    private func spawnFartCloud() {
        let cloud = SKNode()
        let dir: CGFloat = facingRight ? -1 : 1  // Fart goes behind
        for i in 0..<5 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...15))
            puff.position = CGPoint(x: dir * CGFloat(i * 10) - dir * 30, y: CGFloat.random(in: -10...10))
            puff.fillColor = UIColor(red: 0.4, green: 0.7, blue: 0.2, alpha: 0.7)
            puff.strokeColor = .clear
            cloud.addChild(puff)
        }
        addChild(cloud)
        
        let expand = SKAction.scale(to: 2.0, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        cloud.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnBreathCloud() {
        let cloud = SKNode()
        let dir: CGFloat = facingRight ? 1 : -1
        for i in 0..<6 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...12))
            puff.position = CGPoint(x: dir * CGFloat(i * 8) + dir * 20, y: CGFloat(40 + Int.random(in: -5...5)))
            puff.fillColor = UIColor(red: 0.7, green: 0.8, blue: 0.2, alpha: 0.6)
            puff.strokeColor = .clear
            cloud.addChild(puff)
        }
        addChild(cloud)
        
        let move = SKAction.moveBy(x: dir * 60, y: 0, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        cloud.run(SKAction.sequence([
            SKAction.group([move, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnBoogerProjectile() {
        let dir: CGFloat = facingRight ? 1 : -1
        let booger = SKShapeNode(circleOfRadius: 5)
        booger.position = CGPoint(x: dir * 20, y: 42)
        booger.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.1, alpha: 1.0)
        booger.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.0, alpha: 1.0)
        booger.lineWidth = 1
        addChild(booger)
        
        let travel = SKAction.moveBy(x: dir * 120, y: 0, duration: 0.5)
        let wobble = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.1),
            SKAction.moveBy(x: 0, y: -5, duration: 0.1)
        ])
        
        booger.run(SKAction.sequence([
            SKAction.group([travel, SKAction.repeat(wobble, count: 3)]),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnPrettyLookEffect() {
        let dir: CGFloat = facingRight ? 1 : -1
        for i in 0..<8 {
            let symbols = ["✨", "💫", "⭐", "💖", "💕"]
            let sparkle = SKLabelNode(text: symbols[i % symbols.count])
            sparkle.fontSize = CGFloat.random(in: 12...20)
            sparkle.position = CGPoint(x: dir * CGFloat.random(in: 20...80), y: CGFloat.random(in: 20...60))
            addChild(sparkle)
            
            let float = SKAction.moveBy(x: dir * CGFloat.random(in: 10...30), y: CGFloat.random(in: 10...30), duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            let scale = SKAction.scale(to: 0.3, duration: 0.8)
            sparkle.run(SKAction.sequence([
                SKAction.group([float, fade, scale]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func spawnFeathers(at pos: CGPoint) {
        for _ in 0..<3 {
            let feather = SKLabelNode(text: "🪶")
            feather.fontSize = 10
            feather.position = CGPoint(x: pos.x + CGFloat.random(in: -10...10),
                                        y: pos.y + CGFloat.random(in: -5...15))
            addChild(feather)
            
            let drift = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: 10...30), duration: 0.6)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            feather.run(SKAction.sequence([
                SKAction.group([drift, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Update
    
    func update(deltaTime: TimeInterval) {
        // Apply gravity
        if !isOnGround {
            velocityY += gravity * CGFloat(deltaTime)
            position.y += velocityY * CGFloat(deltaTime)
            
            if position.y <= groundY {
                position.y = groundY
                velocityY = 0
                isOnGround = true
            }
        }
        
        // Apply horizontal movement
        position.x += velocityX * CGFloat(deltaTime)
        
        // Update special cooldown
        if specialCooldownTimer > 0 {
            specialCooldownTimer -= deltaTime
        }
        
        // Update facing direction based on scale
        let currentFacing = xScale > 0
        if currentFacing != facingRight {
            facingRight = currentFacing
            pillowNode.position = CGPoint(x: facingRight ? 24 : -24, y: 10)
        }
        
        // Idle animation (gentle bobbing)
        if currentMove == .idle && isOnGround {
            let bob = sin(CACurrentMediaTime() * 3) * 1.5
            headNode.position.y = 42 + CGFloat(bob)
        }
    }
    
    func setFacing(right: Bool) {
        facingRight = right
        xScale = right ? abs(xScale) : -abs(xScale)
    }
    
    var specialCooldownProgress: CGFloat {
        if isSpecialReady { return 1.0 }
        return 1.0 - CGFloat(specialCooldownTimer / MoveType.special.cooldown)
    }
}

// MARK: - UIColor extension

extension UIColor {
    func darker(by factor: CGFloat = 0.2) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(r - factor, 0), green: max(g - factor, 0), blue: max(b - factor, 0), alpha: a)
    }
}
