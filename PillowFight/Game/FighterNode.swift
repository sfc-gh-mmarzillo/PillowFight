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
        
        // Mouth - character specific
        buildMouth()
        
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
    
    private func buildMouth() {
        let mouthColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        
        switch character {
        case .theo:
            // Normal small smile
            let mouth = SKShapeNode(rect: CGRect(x: -4, y: 36, width: 8, height: 2), cornerRadius: 1)
            mouth.fillColor = mouthColor
            mouth.strokeColor = .clear
            addChild(mouth)
            
        case .ben:
            // Big open smile with missing front teeth
            let mouthBg = SKShapeNode(rect: CGRect(x: -5, y: 34, width: 10, height: 5), cornerRadius: 2)
            mouthBg.fillColor = UIColor(red: 0.6, green: 0.15, blue: 0.15, alpha: 1.0) // Dark mouth interior
            mouthBg.strokeColor = mouthColor
            mouthBg.lineWidth = 1
            addChild(mouthBg)
            
            // White teeth on sides (gap in the middle = missing front teeth)
            let leftTooth = SKShapeNode(rect: CGRect(x: -4, y: 36, width: 2, height: 3), cornerRadius: 0.5)
            leftTooth.fillColor = .white
            leftTooth.strokeColor = UIColor.lightGray
            leftTooth.lineWidth = 0.5
            addChild(leftTooth)
            
            let rightTooth = SKShapeNode(rect: CGRect(x: 2, y: 36, width: 2, height: 3), cornerRadius: 0.5)
            rightTooth.fillColor = .white
            rightTooth.strokeColor = UIColor.lightGray
            rightTooth.lineWidth = 0.5
            addChild(rightTooth)
            
        case .chuck:
            // Big wide grin with missing front teeth - gap-toothed smile
            let mouthBg = SKShapeNode(rect: CGRect(x: -6, y: 34, width: 12, height: 5), cornerRadius: 2)
            mouthBg.fillColor = UIColor(red: 0.6, green: 0.15, blue: 0.15, alpha: 1.0)
            mouthBg.strokeColor = mouthColor
            mouthBg.lineWidth = 1
            addChild(mouthBg)
            
            // Teeth with gap in center (missing front teeth)
            let toothPositions: [(CGFloat, CGFloat)] = [(-5, 36), (-3, 36), (3, 36), (5, 36)]
            for pos in toothPositions {
                let tooth = SKShapeNode(rect: CGRect(x: pos.0 - 1, y: pos.1, width: 2, height: 3), cornerRadius: 0.5)
                tooth.fillColor = .white
                tooth.strokeColor = UIColor.lightGray
                tooth.lineWidth = 0.5
                addChild(tooth)
            }
            // The gap in the middle (x: -1 to 1) has no teeth
            
        case .stella:
            // Smile with braces
            let mouth = SKShapeNode(rect: CGRect(x: -5, y: 35, width: 10, height: 3), cornerRadius: 1)
            mouth.fillColor = mouthColor
            mouth.strokeColor = .clear
            addChild(mouth)
            
            // Braces - thin silver/gray metallic line across teeth
            let bracesWire = SKShapeNode(rect: CGRect(x: -5, y: 36, width: 10, height: 1))
            bracesWire.fillColor = UIColor(red: 0.75, green: 0.77, blue: 0.8, alpha: 0.9) // Silver/metallic
            bracesWire.strokeColor = .clear
            addChild(bracesWire)
            
            // Small brackets on the braces
            let bracketPositions: [CGFloat] = [-4, -2, 0, 2, 4]
            for x in bracketPositions {
                let bracket = SKShapeNode(rect: CGRect(x: x - 0.5, y: 35.5, width: 1, height: 2))
                bracket.fillColor = UIColor(red: 0.7, green: 0.72, blue: 0.75, alpha: 1.0)
                bracket.strokeColor = .clear
                addChild(bracket)
            }
        }
    }
    
    private func buildHair() {
        switch character {
        case .theo:
            // Blonde straight hair with side-swept bangs
            let hair = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -15, y: 48))
                path.addQuadCurve(to: CGPoint(x: 15, y: 48), controlPoint: CGPoint(x: 0, y: 63))
                path.addLine(to: CGPoint(x: 13, y: 44))
                path.addLine(to: CGPoint(x: -13, y: 44))
                path.close()
                return path.cgPath
            }())
            hair.fillColor = character.hairColor
            hair.strokeColor = character.hairColor.darker()
            addChild(hair)
            
            // Side-swept bangs (straight hair falling to one side)
            let bangs = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -14, y: 50))
                path.addLine(to: CGPoint(x: -16, y: 44))
                path.addLine(to: CGPoint(x: -8, y: 46))
                path.addLine(to: CGPoint(x: 2, y: 48))
                path.addQuadCurve(to: CGPoint(x: -14, y: 50), controlPoint: CGPoint(x: -6, y: 52))
                path.close()
                return path.cgPath
            }())
            bangs.fillColor = character.hairHighlightColor
            bangs.strokeColor = .clear
            addChild(bangs)
            
            // Hair side wisps (straight, not curly)
            let leftWisp = SKShapeNode(rect: CGRect(x: -16, y: 40, width: 4, height: 10), cornerRadius: 2)
            leftWisp.fillColor = character.hairColor
            leftWisp.strokeColor = .clear
            addChild(leftWisp)
            
            let rightWisp = SKShapeNode(rect: CGRect(x: 12, y: 42, width: 4, height: 8), cornerRadius: 2)
            rightWisp.fillColor = character.hairColor
            rightWisp.strokeColor = .clear
            addChild(rightWisp)
            
        case .ben:
            // Brown mullet hair flowing out from under hat
            let mulletLeft = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -16, y: 46))
                path.addLine(to: CGPoint(x: -18, y: 30))
                path.addQuadCurve(to: CGPoint(x: -12, y: 28), controlPoint: CGPoint(x: -17, y: 26))
                path.addLine(to: CGPoint(x: -12, y: 46))
                path.close()
                return path.cgPath
            }())
            mulletLeft.fillColor = character.hairColor
            mulletLeft.strokeColor = character.hairColor.darker()
            addChild(mulletLeft)
            
            let mulletRight = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 16, y: 46))
                path.addLine(to: CGPoint(x: 18, y: 30))
                path.addQuadCurve(to: CGPoint(x: 12, y: 28), controlPoint: CGPoint(x: 17, y: 26))
                path.addLine(to: CGPoint(x: 12, y: 46))
                path.close()
                return path.cgPath
            }())
            mulletRight.fillColor = character.hairColor
            mulletRight.strokeColor = character.hairColor.darker()
            addChild(mulletRight)
            
            // Mullet back (longer hair hanging down the back)
            let mulletBack = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -14, y: 48))
                path.addLine(to: CGPoint(x: -12, y: 22))
                path.addQuadCurve(to: CGPoint(x: 12, y: 22), controlPoint: CGPoint(x: 0, y: 18))
                path.addLine(to: CGPoint(x: 14, y: 48))
                path.close()
                return path.cgPath
            }())
            mulletBack.fillColor = character.hairColor
            mulletBack.strokeColor = character.hairColor.darker()
            mulletBack.zPosition = -1
            addChild(mulletBack)
            
            // Trucker cap - front panel (brown/dark)
            let hatFront = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -10, y: 48))
                path.addLine(to: CGPoint(x: -10, y: 55))
                path.addQuadCurve(to: CGPoint(x: 10, y: 55), controlPoint: CGPoint(x: 0, y: 64))
                path.addLine(to: CGPoint(x: 10, y: 48))
                path.close()
                return path.cgPath
            }())
            hatFront.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0) // Dark blue front panel
            hatFront.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
            hatFront.lineWidth = 1.5
            addChild(hatFront)
            
            // Trucker cap - mesh back (white/light)
            let hatBack = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -18, y: 48))
                path.addLine(to: CGPoint(x: -18, y: 54))
                path.addQuadCurve(to: CGPoint(x: -10, y: 55), controlPoint: CGPoint(x: -14, y: 60))
                path.addLine(to: CGPoint(x: -10, y: 48))
                path.close()
                return path.cgPath
            }())
            hatBack.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0) // White mesh
            hatBack.strokeColor = UIColor.lightGray
            hatBack.lineWidth = 1
            addChild(hatBack)
            
            let hatBackR = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 10, y: 48))
                path.addLine(to: CGPoint(x: 10, y: 55))
                path.addQuadCurve(to: CGPoint(x: 18, y: 54), controlPoint: CGPoint(x: 14, y: 60))
                path.addLine(to: CGPoint(x: 18, y: 48))
                path.close()
                return path.cgPath
            }())
            hatBackR.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
            hatBackR.strokeColor = UIColor.lightGray
            hatBackR.lineWidth = 1
            addChild(hatBackR)
            
            // Hat brim
            let brim = SKShapeNode(rect: CGRect(x: -20, y: 46, width: 40, height: 4), cornerRadius: 2)
            brim.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
            brim.strokeColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
            addChild(brim)
            
        case .chuck:
            // Very voluminous blonde curly hair - big wild curls
            let curlyHair = SKNode()
            // Outer layer - big voluminous curls
            let outerPositions: [(CGFloat, CGFloat, CGFloat)] = [
                (-16, 50, 7), (-10, 56, 7), (-3, 60, 7), (3, 60, 7), (10, 56, 7), (16, 50, 7),
                (-18, 44, 6), (-14, 42, 5), (14, 42, 5), (18, 44, 6),
                (-6, 62, 6), (6, 62, 6), (0, 63, 6),
            ]
            for pos in outerPositions {
                let curl = SKShapeNode(circleOfRadius: pos.2)
                curl.position = CGPoint(x: pos.0, y: pos.1)
                curl.fillColor = character.hairColor
                curl.strokeColor = character.hairColor.darker()
                curl.lineWidth = 0.8
                curlyHair.addChild(curl)
            }
            // Inner highlights - lighter curls for depth
            let highlightPositions: [(CGFloat, CGFloat)] = [
                (-8, 58), (4, 59), (12, 54), (-14, 48), (0, 61)
            ]
            for pos in highlightPositions {
                let curl = SKShapeNode(circleOfRadius: 4)
                curl.position = CGPoint(x: pos.0, y: pos.1)
                curl.fillColor = character.hairHighlightColor
                curl.strokeColor = .clear
                curlyHair.addChild(curl)
            }
            addChild(curlyHair)
            
        case .stella:
            // Long wavy brown/auburn hair with highlights - NO bow
            // Top of head hair
            let hair = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -16, y: 50))
                path.addQuadCurve(to: CGPoint(x: 16, y: 50), controlPoint: CGPoint(x: 0, y: 63))
                path.addLine(to: CGPoint(x: 14, y: 44))
                path.addLine(to: CGPoint(x: -14, y: 44))
                path.close()
                return path.cgPath
            }())
            hair.fillColor = character.hairColor
            hair.strokeColor = character.hairColor.darker()
            addChild(hair)
            
            // Left side wavy long hair
            let leftHairSide = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -16, y: 52))
                path.addQuadCurve(to: CGPoint(x: -19, y: 38), controlPoint: CGPoint(x: -20, y: 45))
                path.addQuadCurve(to: CGPoint(x: -17, y: 24), controlPoint: CGPoint(x: -16, y: 31))
                path.addQuadCurve(to: CGPoint(x: -20, y: 12), controlPoint: CGPoint(x: -21, y: 18))
                path.addLine(to: CGPoint(x: -12, y: 14))
                path.addQuadCurve(to: CGPoint(x: -13, y: 28), controlPoint: CGPoint(x: -11, y: 21))
                path.addQuadCurve(to: CGPoint(x: -12, y: 42), controlPoint: CGPoint(x: -14, y: 35))
                path.addLine(to: CGPoint(x: -14, y: 52))
                path.close()
                return path.cgPath
            }())
            leftHairSide.fillColor = character.hairColor
            leftHairSide.strokeColor = character.hairColor.darker()
            addChild(leftHairSide)
            
            // Right side wavy long hair
            let rightHairSide = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 16, y: 52))
                path.addQuadCurve(to: CGPoint(x: 19, y: 38), controlPoint: CGPoint(x: 20, y: 45))
                path.addQuadCurve(to: CGPoint(x: 17, y: 24), controlPoint: CGPoint(x: 16, y: 31))
                path.addQuadCurve(to: CGPoint(x: 20, y: 12), controlPoint: CGPoint(x: 21, y: 18))
                path.addLine(to: CGPoint(x: 12, y: 14))
                path.addQuadCurve(to: CGPoint(x: 13, y: 28), controlPoint: CGPoint(x: 11, y: 21))
                path.addQuadCurve(to: CGPoint(x: 12, y: 42), controlPoint: CGPoint(x: 14, y: 35))
                path.addLine(to: CGPoint(x: 14, y: 52))
                path.close()
                return path.cgPath
            }())
            rightHairSide.fillColor = character.hairColor
            rightHairSide.strokeColor = character.hairColor.darker()
            addChild(rightHairSide)
            
            // Auburn/caramel highlight streaks
            let leftHighlight = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -15, y: 48))
                path.addQuadCurve(to: CGPoint(x: -17, y: 28), controlPoint: CGPoint(x: -18, y: 38))
                path.addLine(to: CGPoint(x: -14, y: 30))
                path.addQuadCurve(to: CGPoint(x: -13, y: 46), controlPoint: CGPoint(x: -15, y: 38))
                path.close()
                return path.cgPath
            }())
            leftHighlight.fillColor = character.hairHighlightColor
            leftHighlight.strokeColor = .clear
            addChild(leftHighlight)
            
            let rightHighlight = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 15, y: 48))
                path.addQuadCurve(to: CGPoint(x: 17, y: 28), controlPoint: CGPoint(x: 18, y: 38))
                path.addLine(to: CGPoint(x: 14, y: 30))
                path.addQuadCurve(to: CGPoint(x: 13, y: 46), controlPoint: CGPoint(x: 15, y: 38))
                path.close()
                return path.cgPath
            }())
            rightHighlight.fillColor = character.hairHighlightColor
            rightHighlight.strokeColor = .clear
            addChild(rightHighlight)
        }
    }
    
    private func buildCharacterFeatures() {
        switch character {
        case .theo:
            // Blue/purple rectangular glasses frames (matching his real frames)
            let glassesColor = UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1.0) // Blue-purple
            
            let leftLens = SKShapeNode(rect: CGRect(x: -12, y: 41, width: 11, height: 8), cornerRadius: 2)
            leftLens.fillColor = UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 0.15) // Slight lens tint
            leftLens.strokeColor = glassesColor
            leftLens.lineWidth = 2
            addChild(leftLens)
            
            let rightLens = SKShapeNode(rect: CGRect(x: 1, y: 41, width: 11, height: 8), cornerRadius: 2)
            rightLens.fillColor = UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 0.15)
            rightLens.strokeColor = glassesColor
            rightLens.lineWidth = 2
            addChild(rightLens)
            
            // Bridge between lenses
            let bridge = SKShapeNode(rect: CGRect(x: -1, y: 44, width: 2, height: 2))
            bridge.fillColor = glassesColor
            bridge.strokeColor = .clear
            addChild(bridge)
            
            // Temple arms (sides of glasses)
            let leftArm = SKShapeNode(rect: CGRect(x: -14, y: 44, width: 3, height: 2))
            leftArm.fillColor = glassesColor
            leftArm.strokeColor = .clear
            addChild(leftArm)
            
            let rightArm = SKShapeNode(rect: CGRect(x: 12, y: 44, width: 3, height: 2))
            rightArm.fillColor = glassesColor
            rightArm.strokeColor = .clear
            addChild(rightArm)
            
        case .ben:
            // Ben's colorful shirt detail - small stripe on the shirt to suggest Hawaiian pattern
            let stripe1 = SKShapeNode(rect: CGRect(x: -8, y: 8, width: 4, height: 18), cornerRadius: 1)
            stripe1.fillColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.6) // Blue stripe
            stripe1.strokeColor = .clear
            addChild(stripe1)
            
            let stripe2 = SKShapeNode(rect: CGRect(x: 2, y: 8, width: 4, height: 18), cornerRadius: 1)
            stripe2.fillColor = UIColor(red: 0.95, green: 0.8, blue: 0.2, alpha: 0.6) // Yellow stripe
            stripe2.strokeColor = .clear
            addChild(stripe2)
            
        case .chuck:
            // Chuck has a green hoodie - add hood detail on the back of neck/shoulders
            let hoodBack = SKShapeNode(path: {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: -14, y: 25))
                path.addQuadCurve(to: CGPoint(x: 14, y: 25), controlPoint: CGPoint(x: 0, y: 32))
                path.addLine(to: CGPoint(x: 12, y: 22))
                path.addLine(to: CGPoint(x: -12, y: 22))
                path.close()
                return path.cgPath
            }())
            hoodBack.fillColor = character.shirtColor.darker(by: 0.05)
            hoodBack.strokeColor = character.shirtColor.darker()
            hoodBack.zPosition = -1
            addChild(hoodBack)
            
            // Hoodie strings
            let stringL = SKShapeNode(rect: CGRect(x: -4, y: 14, width: 1, height: 8))
            stringL.fillColor = .white
            stringL.strokeColor = .clear
            addChild(stringL)
            
            let stringR = SKShapeNode(rect: CGRect(x: 3, y: 14, width: 1, height: 8))
            stringR.fillColor = .white
            stringR.strokeColor = .clear
            addChild(stringR)
            
        case .stella:
            // Necklace - delicate chain with small pendant
            let chain = SKShapeNode(path: {
                let path = UIBezierPath()
                path.addArc(withCenter: CGPoint(x: 0, y: 26), radius: 10, startAngle: CGFloat.pi * 0.15, endAngle: CGFloat.pi * 0.85, clockwise: true)
                return path.cgPath
            }())
            chain.fillColor = .clear
            chain.strokeColor = UIColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 0.9) // Gold chain
            chain.lineWidth = 1
            addChild(chain)
            
            // Small pendant
            let pendant = SKShapeNode(circleOfRadius: 2)
            pendant.position = CGPoint(x: 0, y: 17)
            pendant.fillColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0) // Gold pendant
            pendant.strokeColor = UIColor(red: 0.75, green: 0.65, blue: 0.35, alpha: 1.0)
            pendant.lineWidth = 0.5
            addChild(pendant)
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
