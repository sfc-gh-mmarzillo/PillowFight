import SpriteKit

class FighterNode: SKNode {
    
    let character: GameCharacter
    let isPlayer1: Bool
    
    // Visual components
    private var torsoNode: SKShapeNode!
    private var pantsNode: SKShapeNode!
    private var headNode: SKShapeNode!
    private var leftArmNode: SKShapeNode!
    private var rightArmNode: SKShapeNode!
    private var leftLegNode: SKShapeNode!
    private var rightLegNode: SKShapeNode!
    private var leftShoeNode: SKShapeNode!
    private var rightShoeNode: SKShapeNode!
    private var pillowNode: SKNode!
    private var pillowBody: SKShapeNode!
    private var nameLabel: SKLabelNode!
    
    // Face components (for expressions)
    private var leftEyeWhite: SKShapeNode!
    private var rightEyeWhite: SKShapeNode!
    private var leftPupil: SKShapeNode!
    private var rightPupil: SKShapeNode!
    private var leftBrow: SKShapeNode!
    private var rightBrow: SKShapeNode!
    private var mouthNode: SKNode!
    
    // Expression system
    enum Expression { case normal, attacking, hurt, happy, dizzy }
    private(set) var currentExpression: Expression = .normal
    private var blinkTimer: TimeInterval = 0
    private var nextBlinkTime: TimeInterval = 3.0
    private var breathTimer: TimeInterval = 0
    
    // State
    var currentMove: MoveType = .idle
    var isExecutingMove: Bool = false
    var canAct: Bool = true
    var facingRight: Bool
    var health: CGFloat = 100
    private var specialCooldownTimer: TimeInterval = 0
    var isSpecialReady: Bool { specialCooldownTimer <= 0 }
    var isBlocking: Bool = false
    
    // Combo tracking
    var comboCount: Int = 0
    var lastHitTime: TimeInterval = 0
    
    // Physics
    var velocityX: CGFloat = 0
    var velocityY: CGFloat = 0
    var isOnGround: Bool = true
    let groundY: CGFloat
    let moveSpeed: CGFloat = 260
    let jumpForce: CGFloat = 500
    let gravity: CGFloat = -800
    
    // Walk animation
    private var walkCycle: CGFloat = 0
    
    // Scale
    private let charScale: CGFloat = 1.3
    
    // Layout constants
    private let headCenterY: CGFloat = 46
    private let headRadius: CGFloat = 24
    private let eyeY: CGFloat = 49
    private let browY: CGFloat = 58
    private let mouthY: CGFloat = 37
    
    // Hit detection
    var attackHitbox: CGRect {
        let dir: CGFloat = facingRight ? 1 : -1
        let range = currentMove.range
        let x = position.x + (dir * 30)
        return CGRect(x: x - (facingRight ? 0 : range), y: position.y - 25, width: range, height: 70)
    }
    
    var bodyHitbox: CGRect {
        CGRect(x: position.x - 25, y: position.y - 35, width: 50, height: 90)
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
    
    // MARK: - Build Character
    
    private func buildCharacter() {
        buildBody()
        buildHead()
        buildFace()
        buildNormalMouth()
        buildHair()
        buildClothingDetails()
        buildPillow()
        
        nameLabel = SKLabelNode(text: character.displayName)
        nameLabel.fontSize = 11
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 76)
        nameLabel.zPosition = 10
        addChild(nameLabel)
        
        self.xScale = facingRight ? charScale : -charScale
        self.yScale = charScale
    }
    
    // MARK: - Body
    
    private func buildBody() {
        // Torso
        torsoNode = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -14, y: -6, width: 28, height: 28), cornerRadius: 5).cgPath)
        torsoNode.fillColor = character.shirtColor
        torsoNode.strokeColor = character.shirtColor.darker(by: 0.15)
        torsoNode.lineWidth = 2
        addChild(torsoNode)
        
        // Shirt highlight
        let shirtHL = SKShapeNode(rect: CGRect(x: -12, y: 0, width: 6, height: 18), cornerRadius: 3)
        shirtHL.fillColor = character.shirtColor.lighter(by: 0.1)
        shirtHL.strokeColor = .clear
        shirtHL.alpha = 0.35
        torsoNode.addChild(shirtHL)
        
        // Belt line
        let belt = SKShapeNode(rect: CGRect(x: -14, y: -7, width: 28, height: 3))
        belt.fillColor = character.pantsColor.darker(by: 0.1)
        belt.strokeColor = .clear
        addChild(belt)
        
        // Pants
        pantsNode = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(x: -14, y: -28, width: 28, height: 23), cornerRadius: 4).cgPath)
        pantsNode.fillColor = character.pantsColor
        pantsNode.strokeColor = character.pantsColor.darker(by: 0.15)
        pantsNode.lineWidth = 2
        addChild(pantsNode)
        
        // Left leg
        leftLegNode = SKShapeNode(rect: CGRect(x: -11, y: -44, width: 9, height: 18), cornerRadius: 3)
        leftLegNode.fillColor = character.pantsColor
        leftLegNode.strokeColor = character.pantsColor.darker(by: 0.15)
        leftLegNode.lineWidth = 1.5
        addChild(leftLegNode)
        
        // Right leg
        rightLegNode = SKShapeNode(rect: CGRect(x: 2, y: -44, width: 9, height: 18), cornerRadius: 3)
        rightLegNode.fillColor = character.pantsColor
        rightLegNode.strokeColor = character.pantsColor.darker(by: 0.15)
        rightLegNode.lineWidth = 1.5
        addChild(rightLegNode)
        
        // Left shoe
        leftShoeNode = SKShapeNode(rect: CGRect(x: -14, y: -50, width: 15, height: 8), cornerRadius: 4)
        leftShoeNode.fillColor = character.shoeColor
        leftShoeNode.strokeColor = character.shoeColor.darker(by: 0.15)
        leftShoeNode.lineWidth = 1.5
        addChild(leftShoeNode)
        
        // Right shoe
        rightShoeNode = SKShapeNode(rect: CGRect(x: -1, y: -50, width: 15, height: 8), cornerRadius: 4)
        rightShoeNode.fillColor = character.shoeColor
        rightShoeNode.strokeColor = character.shoeColor.darker(by: 0.15)
        rightShoeNode.lineWidth = 1.5
        addChild(rightShoeNode)
        
        // Shoe sole highlights
        let leftSole = SKShapeNode(rect: CGRect(x: -13, y: -50, width: 13, height: 2), cornerRadius: 1)
        leftSole.fillColor = .white
        leftSole.strokeColor = .clear
        leftSole.alpha = 0.25
        addChild(leftSole)
        let rightSole = SKShapeNode(rect: CGRect(x: 0, y: -50, width: 13, height: 2), cornerRadius: 1)
        rightSole.fillColor = .white
        rightSole.strokeColor = .clear
        rightSole.alpha = 0.25
        addChild(rightSole)
        
        // Arms
        leftArmNode = SKShapeNode(rect: CGRect(x: -25, y: -2, width: 10, height: 24), cornerRadius: 4)
        leftArmNode.fillColor = character.skinColor
        leftArmNode.strokeColor = character.skinColor.darker(by: 0.12)
        leftArmNode.lineWidth = 1.5
        addChild(leftArmNode)
        
        rightArmNode = SKShapeNode(rect: CGRect(x: 15, y: -2, width: 10, height: 24), cornerRadius: 4)
        rightArmNode.fillColor = character.skinColor
        rightArmNode.strokeColor = character.skinColor.darker(by: 0.12)
        rightArmNode.lineWidth = 1.5
        addChild(rightArmNode)
        
        // Hands
        let leftHand = SKShapeNode(circleOfRadius: 4)
        leftHand.position = CGPoint(x: -20, y: -4)
        leftHand.fillColor = character.skinColor
        leftHand.strokeColor = character.skinColor.darker(by: 0.12)
        leftHand.lineWidth = 1
        addChild(leftHand)
        
        let rightHand = SKShapeNode(circleOfRadius: 4)
        rightHand.position = CGPoint(x: 20, y: -4)
        rightHand.fillColor = character.skinColor
        rightHand.strokeColor = character.skinColor.darker(by: 0.12)
        rightHand.lineWidth = 1
        addChild(rightHand)
    }
    
    // MARK: - Head
    
    private func buildHead() {
        // Neck (thinner for Stella who's older, normal for others)
        let neckW: CGFloat = character == .stella ? 6 : 8
        let neck = SKShapeNode(rect: CGRect(x: -neckW / 2, y: 20, width: neckW, height: 5), cornerRadius: 2)
        neck.fillColor = character.skinColor
        neck.strokeColor = character.skinColor.darker(by: 0.1)
        neck.lineWidth = 1
        neck.zPosition = 1
        addChild(neck)
        
        // Character-specific head shapes
        switch character {
        case .theo:
            // Theo: rounder, slightly chubbier - he's the youngest
            headNode = SKShapeNode(ellipseOf: CGSize(width: 50, height: 50))
            headNode.position = CGPoint(x: 0, y: headCenterY)
        case .ben:
            // Ben: slightly wider jaw, more square-ish
            headNode = SKShapeNode(path: {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: -22, y: -4))
                p.addQuadCurve(to: CGPoint(x: -24, y: 8), controlPoint: CGPoint(x: -25, y: 2))
                p.addQuadCurve(to: CGPoint(x: 0, y: 24), controlPoint: CGPoint(x: -24, y: 24))
                p.addQuadCurve(to: CGPoint(x: 24, y: 8), controlPoint: CGPoint(x: 24, y: 24))
                p.addQuadCurve(to: CGPoint(x: 22, y: -4), controlPoint: CGPoint(x: 25, y: 2))
                p.addQuadCurve(to: CGPoint(x: -22, y: -4), controlPoint: CGPoint(x: 0, y: -14))
                p.close()
                return p.cgPath
            }())
            headNode.position = CGPoint(x: 0, y: headCenterY)
        case .chuck:
            // Chuck: big round face to match his big personality and curls
            headNode = SKShapeNode(ellipseOf: CGSize(width: 52, height: 48))
            headNode.position = CGPoint(x: 0, y: headCenterY)
        case .stella:
            // Stella: more oval, slightly narrower - she's the oldest/teen
            headNode = SKShapeNode(ellipseOf: CGSize(width: 44, height: 52))
            headNode.position = CGPoint(x: 0, y: headCenterY)
        }
        headNode.fillColor = character.skinColor
        headNode.strokeColor = character.skinColor.darker(by: 0.12)
        headNode.lineWidth = 2
        headNode.zPosition = 1
        addChild(headNode)
        
        // Ears (small, peeking out from sides)
        let earY: CGFloat = headCenterY - 2
        let earSize: CGFloat = character == .chuck ? 7 : 6
        for side: CGFloat in [-1, 1] {
            let earX: CGFloat = side * (character == .stella ? 20 : 23)
            let ear = SKShapeNode(ellipseOf: CGSize(width: earSize, height: earSize + 2))
            ear.position = CGPoint(x: earX, y: earY)
            ear.fillColor = character.skinColor
            ear.strokeColor = character.skinColor.darker(by: 0.12)
            ear.lineWidth = 1.2
            ear.zPosition = 0  // Behind head
            addChild(ear)
            // Inner ear detail
            let innerEar = SKShapeNode(ellipseOf: CGSize(width: earSize - 3, height: earSize - 2))
            innerEar.position = CGPoint(x: earX, y: earY)
            innerEar.fillColor = character.skinColor.darker(by: 0.06)
            innerEar.strokeColor = .clear
            innerEar.zPosition = 0
            addChild(innerEar)
        }
        
        // Head specular highlight
        let headHL = SKShapeNode(circleOfRadius: 6)
        headHL.position = CGPoint(x: -8, y: headCenterY + 10)
        headHL.fillColor = .white
        headHL.strokeColor = .clear
        headHL.alpha = 0.15
        headHL.zPosition = 1
        addChild(headHL)
        
        // Character-specific cheek blush
        let cheekAlpha: CGFloat
        let cheekW: CGFloat
        let cheekH: CGFloat
        switch character {
        case .theo:
            cheekAlpha = 0.25; cheekW = 9; cheekH = 6  // Rosy young kid cheeks
        case .ben:
            cheekAlpha = 0.15; cheekW = 7; cheekH = 5  // Subtle
        case .chuck:
            cheekAlpha = 0.35; cheekW = 10; cheekH = 7  // Very rosy, prominent cheeks
        case .stella:
            cheekAlpha = 0.12; cheekW = 6; cheekH = 4  // Subtle teen blush
        }
        
        for side: CGFloat in [-1, 1] {
            let cheek = SKShapeNode(ellipseOf: CGSize(width: cheekW, height: cheekH))
            cheek.position = CGPoint(x: side * 15, y: 42)
            cheek.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
            cheek.strokeColor = .clear
            cheek.alpha = cheekAlpha
            cheek.zPosition = 2
            addChild(cheek)
        }
    }
    
    // MARK: - Face
    
    private func buildFace() {
        // Character-specific eye dimensions
        let eyeW: CGFloat
        let eyeH: CGFloat
        let eyeSpacing: CGFloat
        let pupilR: CGFloat
        let pupilColor: UIColor
        let eyeOutlineW: CGFloat
        
        switch character {
        case .theo:
            // Bigger, rounder eyes (magnified behind glasses) - younger kid look
            eyeW = 14; eyeH = 16; eyeSpacing = 9; pupilR = 5
            pupilColor = UIColor(red: 0.25, green: 0.4, blue: 0.15, alpha: 1.0) // Green-hazel eyes
            eyeOutlineW = 1.5
        case .ben:
            // Slightly narrower, more mischievous eyes
            eyeW = 11; eyeH = 12; eyeSpacing = 10; pupilR = 4
            pupilColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0) // Brown eyes
            eyeOutlineW = 1.5
        case .chuck:
            // Wide open, enthusiastic round eyes
            eyeW = 13; eyeH = 15; eyeSpacing = 9; pupilR = 4.5
            pupilColor = UIColor(red: 0.2, green: 0.35, blue: 0.5, alpha: 1.0) // Blue eyes
            eyeOutlineW = 1.5
        case .stella:
            // Slightly almond-shaped, more refined - teen look
            eyeW = 12; eyeH = 13; eyeSpacing = 9; pupilR = 4
            pupilColor = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0) // Dark brown eyes
            eyeOutlineW = 1.8  // Thicker outline simulates subtle liner
        }
        
        // Left eye white
        leftEyeWhite = SKShapeNode(ellipseOf: CGSize(width: eyeW, height: eyeH))
        leftEyeWhite.position = CGPoint(x: -eyeSpacing, y: eyeY)
        leftEyeWhite.fillColor = .white
        leftEyeWhite.strokeColor = UIColor(white: 0.2, alpha: 1.0)
        leftEyeWhite.lineWidth = eyeOutlineW
        leftEyeWhite.zPosition = 3
        addChild(leftEyeWhite)
        
        // Left iris (colored ring around pupil)
        let leftIris = SKShapeNode(circleOfRadius: pupilR + 1)
        leftIris.position = CGPoint(x: 1, y: -0.5)
        leftIris.fillColor = pupilColor
        leftIris.strokeColor = pupilColor.darker(by: 0.15)
        leftIris.lineWidth = 0.8
        leftIris.zPosition = 1
        leftEyeWhite.addChild(leftIris)
        
        // Left pupil (dark center)
        leftPupil = SKShapeNode(circleOfRadius: pupilR - 1)
        leftPupil.position = .zero
        leftPupil.fillColor = UIColor(red: 0.08, green: 0.05, blue: 0.02, alpha: 1.0)
        leftPupil.strokeColor = .clear
        leftPupil.zPosition = 1
        leftIris.addChild(leftPupil)
        
        // Left pupil highlight (big)
        let leftHL = SKShapeNode(circleOfRadius: 2)
        leftHL.position = CGPoint(x: 1.5, y: 2)
        leftHL.fillColor = .white
        leftHL.strokeColor = .clear
        leftPupil.addChild(leftHL)
        
        // Left pupil highlight (small, secondary)
        let leftHL2 = SKShapeNode(circleOfRadius: 1)
        leftHL2.position = CGPoint(x: -1.5, y: -1)
        leftHL2.fillColor = .white
        leftHL2.strokeColor = .clear
        leftHL2.alpha = 0.6
        leftPupil.addChild(leftHL2)
        
        // Right eye white
        rightEyeWhite = SKShapeNode(ellipseOf: CGSize(width: eyeW, height: eyeH))
        rightEyeWhite.position = CGPoint(x: eyeSpacing, y: eyeY)
        rightEyeWhite.fillColor = .white
        rightEyeWhite.strokeColor = UIColor(white: 0.2, alpha: 1.0)
        rightEyeWhite.lineWidth = eyeOutlineW
        rightEyeWhite.zPosition = 3
        addChild(rightEyeWhite)
        
        // Right iris
        let rightIris = SKShapeNode(circleOfRadius: pupilR + 1)
        rightIris.position = CGPoint(x: 1, y: -0.5)
        rightIris.fillColor = pupilColor
        rightIris.strokeColor = pupilColor.darker(by: 0.15)
        rightIris.lineWidth = 0.8
        rightIris.zPosition = 1
        rightEyeWhite.addChild(rightIris)
        
        // Right pupil
        rightPupil = SKShapeNode(circleOfRadius: pupilR - 1)
        rightPupil.position = .zero
        rightPupil.fillColor = UIColor(red: 0.08, green: 0.05, blue: 0.02, alpha: 1.0)
        rightPupil.strokeColor = .clear
        rightPupil.zPosition = 1
        rightIris.addChild(rightPupil)
        
        // Right pupil highlight (big)
        let rightHL = SKShapeNode(circleOfRadius: 2)
        rightHL.position = CGPoint(x: 1.5, y: 2)
        rightHL.fillColor = .white
        rightHL.strokeColor = .clear
        rightPupil.addChild(rightHL)
        
        // Right pupil highlight (small)
        let rightHL2 = SKShapeNode(circleOfRadius: 1)
        rightHL2.position = CGPoint(x: -1.5, y: -1)
        rightHL2.fillColor = .white
        rightHL2.strokeColor = .clear
        rightHL2.alpha = 0.6
        rightPupil.addChild(rightHL2)
        
        // Character-specific eyebrows
        let browColor = character.hairColor.darker(by: 0.15)
        let browW: CGFloat
        let browH: CGFloat
        let browRot: CGFloat
        
        switch character {
        case .theo:
            browW = 8; browH = 2.0; browRot = 0.08  // Thin, neutral - young kid
        case .ben:
            browW = 10; browH = 2.8; browRot = -0.08  // Thicker, slightly cocky angle
        case .chuck:
            browW = 9; browH = 2.2; browRot = 0.15  // Raised, enthusiastic
        case .stella:
            browW = 10; browH = 1.8; browRot = 0.1  // Thin, arched - feminine
        }
        
        leftBrow = SKShapeNode(rect: CGRect(x: -browW / 2, y: -browH / 2, width: browW, height: browH), cornerRadius: 1)
        leftBrow.position = CGPoint(x: -eyeSpacing, y: browY)
        leftBrow.fillColor = browColor
        leftBrow.strokeColor = .clear
        leftBrow.zPosition = 4
        leftBrow.zRotation = browRot
        addChild(leftBrow)
        
        rightBrow = SKShapeNode(rect: CGRect(x: -browW / 2, y: -browH / 2, width: browW, height: browH), cornerRadius: 1)
        rightBrow.position = CGPoint(x: eyeSpacing, y: browY)
        rightBrow.fillColor = browColor
        rightBrow.strokeColor = .clear
        rightBrow.zPosition = 4
        rightBrow.zRotation = -browRot
        addChild(rightBrow)
        
        // NOSE (character-specific)
        buildNose()
        
        // Character-specific facial details
        buildFaceDetails()
    }
    
    // MARK: - Nose
    
    private func buildNose() {
        let noseY: CGFloat = 43
        
        switch character {
        case .theo:
            // Small button nose - youngest kid
            let nose = SKShapeNode(circleOfRadius: 2.5)
            nose.position = CGPoint(x: 0, y: noseY)
            nose.fillColor = character.skinColor.darker(by: 0.06)
            nose.strokeColor = character.skinColor.darker(by: 0.12)
            nose.lineWidth = 0.8
            nose.zPosition = 3
            addChild(nose)
            
        case .ben:
            // Slightly wider, rounder nose
            let nose = SKShapeNode(ellipseOf: CGSize(width: 7, height: 5))
            nose.position = CGPoint(x: 0, y: noseY)
            nose.fillColor = character.skinColor.darker(by: 0.05)
            nose.strokeColor = character.skinColor.darker(by: 0.1)
            nose.lineWidth = 0.8
            nose.zPosition = 3
            addChild(nose)
            // Nostrils
            for side: CGFloat in [-1, 1] {
                let nostril = SKShapeNode(circleOfRadius: 1)
                nostril.position = CGPoint(x: side * 2, y: noseY - 0.5)
                nostril.fillColor = character.skinColor.darker(by: 0.15)
                nostril.strokeColor = .clear
                nostril.zPosition = 3
                addChild(nostril)
            }
            
        case .chuck:
            // Small round upturned nose
            let nose = SKShapeNode(circleOfRadius: 3)
            nose.position = CGPoint(x: 0, y: noseY + 1)
            nose.fillColor = character.skinColor.darker(by: 0.05)
            nose.strokeColor = character.skinColor.darker(by: 0.1)
            nose.lineWidth = 0.8
            nose.zPosition = 3
            addChild(nose)
            // Nose highlight
            let noseHL = SKShapeNode(circleOfRadius: 1.2)
            noseHL.position = CGPoint(x: -0.5, y: noseY + 2)
            noseHL.fillColor = .white
            noseHL.strokeColor = .clear
            noseHL.alpha = 0.2
            noseHL.zPosition = 3
            addChild(noseHL)
            
        case .stella:
            // Delicate, defined nose with bridge line
            let noseBridge = SKShapeNode(path: {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: 0, y: noseY + 5))
                p.addQuadCurve(to: CGPoint(x: 1.5, y: noseY - 1), controlPoint: CGPoint(x: 1, y: noseY + 2))
                p.addQuadCurve(to: CGPoint(x: -1.5, y: noseY - 1), controlPoint: CGPoint(x: 0, y: noseY - 2.5))
                p.addQuadCurve(to: CGPoint(x: 0, y: noseY + 5), controlPoint: CGPoint(x: -1, y: noseY + 2))
                p.close()
                return p.cgPath
            }())
            noseBridge.fillColor = character.skinColor.darker(by: 0.04)
            noseBridge.strokeColor = character.skinColor.darker(by: 0.1)
            noseBridge.lineWidth = 0.6
            noseBridge.zPosition = 3
            addChild(noseBridge)
        }
    }
    
    // MARK: - Face Details (freckles, eyelashes, dimples, etc.)
    
    private func buildFaceDetails() {
        switch character {
        case .theo:
            // Theo is the youngest - no extra details needed, glasses define him
            break
            
        case .ben:
            // Freckles scattered across cheeks and nose
            let freckleColor = character.skinColor.darker(by: 0.18)
            let frecklePositions: [(CGFloat, CGFloat)] = [
                (-12, 44), (-10, 42), (-8, 45), (-14, 43),
                (8, 44), (10, 42), (12, 45), (14, 43),
                (-3, 43), (3, 43), (-1, 44), (1, 42)
            ]
            for fp in frecklePositions {
                let freckle = SKShapeNode(circleOfRadius: 0.8)
                freckle.position = CGPoint(x: fp.0, y: fp.1)
                freckle.fillColor = freckleColor
                freckle.strokeColor = .clear
                freckle.zPosition = 2
                addChild(freckle)
            }
            
        case .chuck:
            // Dimples near mouth (visible when grinning)
            for side: CGFloat in [-1, 1] {
                let dimple = SKShapeNode(path: {
                    let p = UIBezierPath()
                    p.addArc(withCenter: .zero, radius: 2, startAngle: .pi * 0.2, endAngle: .pi * 0.8, clockwise: false)
                    return p.cgPath
                }())
                dimple.position = CGPoint(x: side * 10, y: mouthY + 1)
                dimple.fillColor = .clear
                dimple.strokeColor = character.skinColor.darker(by: 0.12)
                dimple.lineWidth = 0.8
                dimple.zPosition = 2
                addChild(dimple)
            }
            
        case .stella:
            // Eyelashes (small lines above eyes)
            let lashColor = UIColor(red: 0.2, green: 0.12, blue: 0.08, alpha: 0.8)
            // Left eye lashes
            for i in 0..<3 {
                let angle = CGFloat(i - 1) * 0.35 + .pi / 2
                let lash = SKShapeNode(path: {
                    let p = UIBezierPath()
                    p.move(to: .zero)
                    p.addLine(to: CGPoint(x: cos(angle) * 3.5, y: sin(angle) * 3.5))
                    return p.cgPath
                }())
                lash.position = CGPoint(x: -9 + CGFloat(i - 1) * 4, y: eyeY + 6)
                lash.strokeColor = lashColor
                lash.lineWidth = 1.2
                lash.zPosition = 4
                addChild(lash)
            }
            // Right eye lashes
            for i in 0..<3 {
                let angle = CGFloat(i - 1) * 0.35 + .pi / 2
                let lash = SKShapeNode(path: {
                    let p = UIBezierPath()
                    p.move(to: .zero)
                    p.addLine(to: CGPoint(x: cos(angle) * 3.5, y: sin(angle) * 3.5))
                    return p.cgPath
                }())
                lash.position = CGPoint(x: 9 + CGFloat(i - 1) * 4, y: eyeY + 6)
                lash.strokeColor = lashColor
                lash.lineWidth = 1.2
                lash.zPosition = 4
                addChild(lash)
            }
            
            // Small beauty mark
            let beautyMark = SKShapeNode(circleOfRadius: 0.8)
            beautyMark.position = CGPoint(x: 12, y: 40)
            beautyMark.fillColor = character.skinColor.darker(by: 0.25)
            beautyMark.strokeColor = .clear
            beautyMark.zPosition = 2
            addChild(beautyMark)
        }
    }
    
    // MARK: - Character-Specific Mouths
    
    private func buildNormalMouth() {
        mouthNode?.removeFromParent()
        let mouth = SKNode()
        mouth.zPosition = 3
        
        let mouthColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        let mouthDark = UIColor(red: 0.4, green: 0.08, blue: 0.08, alpha: 1.0)
        
        switch character {
        case .theo:
            // Small, gentle closed-mouth smile - sweet young kid
            let smile = SKShapeNode(path: {
                let p = UIBezierPath()
                p.addArc(withCenter: CGPoint(x: 0, y: mouthY + 2), radius: 5, startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: true)
                return p.cgPath
            }())
            smile.strokeColor = mouthColor
            smile.lineWidth = 1.8
            smile.fillColor = .clear
            mouth.addChild(smile)
            
            // Slight lip color
            let lip = SKShapeNode(ellipseOf: CGSize(width: 8, height: 2.5))
            lip.position = CGPoint(x: 0, y: mouthY)
            lip.fillColor = mouthColor.withAlphaComponent(0.3)
            lip.strokeColor = .clear
            mouth.addChild(lip)
            
        case .ben:
            // BIG open grin with clearly missing front teeth
            let grinW: CGFloat = 14
            let grinH: CGFloat = 8
            let mouthBg = SKShapeNode(rect: CGRect(x: -grinW / 2, y: mouthY - 3, width: grinW, height: grinH), cornerRadius: 3)
            mouthBg.fillColor = mouthDark
            mouthBg.strokeColor = mouthColor
            mouthBg.lineWidth = 1.2
            mouth.addChild(mouthBg)
            
            // Upper gum line
            let gumLine = SKShapeNode(rect: CGRect(x: -grinW / 2 + 1, y: mouthY + 2, width: grinW - 2, height: 2))
            gumLine.fillColor = UIColor(red: 0.85, green: 0.6, blue: 0.6, alpha: 1.0)
            gumLine.strokeColor = .clear
            mouth.addChild(gumLine)
            
            // Teeth with prominent gap in front center
            // Left teeth (2 visible)
            let toothW: CGFloat = 3
            let toothH: CGFloat = 4
            let t1 = SKShapeNode(rect: CGRect(x: -6.5, y: mouthY + 0.5, width: toothW, height: toothH), cornerRadius: 0.5)
            t1.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
            t1.strokeColor = UIColor.lightGray
            t1.lineWidth = 0.4
            mouth.addChild(t1)
            
            let t2 = SKShapeNode(rect: CGRect(x: -3, y: mouthY + 0.5, width: toothW - 0.5, height: toothH - 0.5), cornerRadius: 0.5)
            t2.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
            t2.strokeColor = UIColor.lightGray
            t2.lineWidth = 0.4
            mouth.addChild(t2)
            
            // GAP - no teeth at center (missing front teeth)
            
            // Right teeth (2 visible)
            let t3 = SKShapeNode(rect: CGRect(x: 1, y: mouthY + 0.5, width: toothW - 0.5, height: toothH - 0.5), cornerRadius: 0.5)
            t3.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
            t3.strokeColor = UIColor.lightGray
            t3.lineWidth = 0.4
            mouth.addChild(t3)
            
            let t4 = SKShapeNode(rect: CGRect(x: 3.5, y: mouthY + 0.5, width: toothW, height: toothH), cornerRadius: 0.5)
            t4.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
            t4.strokeColor = UIColor.lightGray
            t4.lineWidth = 0.4
            mouth.addChild(t4)
            
            // Tongue peeking through the gap
            let tongue = SKShapeNode(ellipseOf: CGSize(width: 4, height: 3))
            tongue.position = CGPoint(x: 0, y: mouthY - 0.5)
            tongue.fillColor = UIColor(red: 0.9, green: 0.45, blue: 0.45, alpha: 0.7)
            tongue.strokeColor = .clear
            mouth.addChild(tongue)
            
        case .chuck:
            // HUGE ear-to-ear grin with missing front teeth - his signature look
            let grinW: CGFloat = 18
            let grinH: CGFloat = 9
            let mouthBg = SKShapeNode(path: {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: -grinW / 2, y: mouthY + 2))
                p.addQuadCurve(to: CGPoint(x: grinW / 2, y: mouthY + 2), controlPoint: CGPoint(x: 0, y: mouthY - grinH))
                p.addLine(to: CGPoint(x: grinW / 2, y: mouthY + 2))
                p.addLine(to: CGPoint(x: -grinW / 2, y: mouthY + 2))
                p.close()
                return p.cgPath
            }())
            mouthBg.fillColor = mouthDark
            mouthBg.strokeColor = mouthColor
            mouthBg.lineWidth = 1.2
            mouth.addChild(mouthBg)
            
            // Upper gum
            let gum = SKShapeNode(rect: CGRect(x: -grinW / 2 + 1, y: mouthY, width: grinW - 2, height: 2.5), cornerRadius: 1)
            gum.fillColor = UIColor(red: 0.85, green: 0.6, blue: 0.6, alpha: 1.0)
            gum.strokeColor = .clear
            mouth.addChild(gum)
            
            // Teeth with big gap - two front teeth missing
            let teethData: [(CGFloat, CGFloat)] = [
                (-8, 3.5), (-5.5, 3), (-3, 2.5),
                // GAP at -1 to 1 (missing front teeth)
                (3, 2.5), (5.5, 3), (8, 3.5)
            ]
            for td in teethData {
                let tooth = SKShapeNode(rect: CGRect(x: td.0 - 1.2, y: mouthY - 0.5, width: 2.5, height: td.1), cornerRadius: 0.5)
                tooth.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
                tooth.strokeColor = UIColor.lightGray
                tooth.lineWidth = 0.4
                mouth.addChild(tooth)
            }
            
            // Dark gap emphasis where front teeth should be
            let gap = SKShapeNode(rect: CGRect(x: -1.5, y: mouthY - 1, width: 3, height: 4))
            gap.fillColor = mouthDark
            gap.strokeColor = .clear
            mouth.addChild(gap)
            
            // Bottom lip curve
            let bottomLip = SKShapeNode(path: {
                let p = UIBezierPath()
                p.addArc(withCenter: CGPoint(x: 0, y: mouthY - 4), radius: 6, startAngle: -.pi * 0.2, endAngle: -.pi * 0.8, clockwise: true)
                return p.cgPath
            }())
            bottomLip.strokeColor = mouthColor.withAlphaComponent(0.4)
            bottomLip.lineWidth = 1
            bottomLip.fillColor = .clear
            mouth.addChild(bottomLip)
            
        case .stella:
            // Closed-mouth smile showing braces when she smiles
            let smileW: CGFloat = 14
            let smileH: CGFloat = 5
            let smileBg = SKShapeNode(rect: CGRect(x: -smileW / 2, y: mouthY - 1, width: smileW, height: smileH), cornerRadius: 2.5)
            smileBg.fillColor = UIColor(red: 0.85, green: 0.45, blue: 0.45, alpha: 1.0)
            smileBg.strokeColor = .clear
            mouth.addChild(smileBg)
            
            // Row of teeth
            for i in 0..<6 {
                let tx = CGFloat(i) * 2.2 - 5.5
                let tooth = SKShapeNode(rect: CGRect(x: tx, y: mouthY - 0.5, width: 2, height: 3.5), cornerRadius: 0.3)
                tooth.fillColor = UIColor(red: 0.98, green: 0.97, blue: 0.92, alpha: 1.0)
                tooth.strokeColor = UIColor(white: 0.85, alpha: 1.0)
                tooth.lineWidth = 0.3
                mouth.addChild(tooth)
            }
            
            // Braces wire (horizontal line across teeth)
            let wire = SKShapeNode(rect: CGRect(x: -smileW / 2 + 1, y: mouthY + 0.8, width: smileW - 2, height: 0.8))
            wire.fillColor = UIColor(red: 0.7, green: 0.72, blue: 0.78, alpha: 1.0)
            wire.strokeColor = .clear
            mouth.addChild(wire)
            
            // Brackets (small metallic squares on each tooth)
            for i in 0..<6 {
                let bx = CGFloat(i) * 2.2 - 5.0
                let bracket = SKShapeNode(rect: CGRect(x: bx, y: mouthY + 0.2, width: 1.5, height: 1.8), cornerRadius: 0.3)
                bracket.fillColor = UIColor(red: 0.78, green: 0.8, blue: 0.85, alpha: 1.0)
                bracket.strokeColor = UIColor(red: 0.6, green: 0.62, blue: 0.68, alpha: 0.8)
                bracket.lineWidth = 0.3
                mouth.addChild(bracket)
            }
            
            // Colored elastic bands on brackets (alternating pink/blue)
            let elasticColors = [
                UIColor(red: 0.9, green: 0.5, blue: 0.7, alpha: 0.7),
                UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.7)
            ]
            for i in 0..<6 {
                let ex = CGFloat(i) * 2.2 - 4.8
                let elastic = SKShapeNode(circleOfRadius: 0.6)
                elastic.position = CGPoint(x: ex, y: mouthY + 1.1)
                elastic.fillColor = elasticColors[i % 2]
                elastic.strokeColor = .clear
                mouth.addChild(elastic)
            }
            
            // Lip gloss highlight
            let gloss = SKShapeNode(ellipseOf: CGSize(width: 4, height: 1.5))
            gloss.position = CGPoint(x: -2, y: mouthY + 3)
            gloss.fillColor = .white
            gloss.strokeColor = .clear
            gloss.alpha = 0.2
            mouth.addChild(gloss)
        }
        
        addChild(mouth)
        mouthNode = mouth
    }
    
    // MARK: - Hair
    
    private func buildHair() {
        switch character {
        case .theo:
            buildTheoHair()
        case .ben:
            buildBenHair()
        case .chuck:
            buildChuckHair()
        case .stella:
            buildStellaHair()
        }
    }
    
    private func buildTheoHair() {
        // Blonde straight hair with side-swept bangs
        let hairCap = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -19, y: 52))
            p.addQuadCurve(to: CGPoint(x: 19, y: 52), controlPoint: CGPoint(x: 0, y: 73))
            p.addLine(to: CGPoint(x: 17, y: 48))
            p.addLine(to: CGPoint(x: -17, y: 48))
            p.close()
            return p.cgPath
        }())
        hairCap.fillColor = character.hairColor
        hairCap.strokeColor = character.hairColor.darker(by: 0.12)
        hairCap.lineWidth = 1.5
        hairCap.zPosition = 5
        addChild(hairCap)
        
        // Side-swept bangs
        let bangs = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -16, y: 54))
            p.addLine(to: CGPoint(x: -19, y: 46))
            p.addLine(to: CGPoint(x: -10, y: 48))
            p.addLine(to: CGPoint(x: 3, y: 52))
            p.addQuadCurve(to: CGPoint(x: -16, y: 54), controlPoint: CGPoint(x: -6, y: 56))
            p.close()
            return p.cgPath
        }())
        bangs.fillColor = character.hairHighlightColor
        bangs.strokeColor = .clear
        bangs.zPosition = 5
        addChild(bangs)
        
        // Side wisps
        let leftWisp = SKShapeNode(rect: CGRect(x: -19, y: 40, width: 5, height: 12), cornerRadius: 2.5)
        leftWisp.fillColor = character.hairColor
        leftWisp.strokeColor = .clear
        leftWisp.zPosition = 5
        addChild(leftWisp)
        
        let rightWisp = SKShapeNode(rect: CGRect(x: 14, y: 42, width: 5, height: 10), cornerRadius: 2.5)
        rightWisp.fillColor = character.hairColor
        rightWisp.strokeColor = .clear
        rightWisp.zPosition = 5
        addChild(rightWisp)
    }
    
    private func buildBenHair() {
        // Mullet back (behind head)
        let mulletBack = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -16, y: 52))
            p.addLine(to: CGPoint(x: -14, y: 18))
            p.addQuadCurve(to: CGPoint(x: 14, y: 18), controlPoint: CGPoint(x: 0, y: 12))
            p.addLine(to: CGPoint(x: 16, y: 52))
            p.close()
            return p.cgPath
        }())
        mulletBack.fillColor = character.hairColor
        mulletBack.strokeColor = character.hairColor.darker(by: 0.12)
        mulletBack.lineWidth = 1
        mulletBack.zPosition = -1
        addChild(mulletBack)
        
        // Mullet left side
        let mulletL = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -18, y: 50))
            p.addLine(to: CGPoint(x: -20, y: 28))
            p.addQuadCurve(to: CGPoint(x: -14, y: 24), controlPoint: CGPoint(x: -19, y: 22))
            p.addLine(to: CGPoint(x: -14, y: 50))
            p.close()
            return p.cgPath
        }())
        mulletL.fillColor = character.hairColor
        mulletL.strokeColor = character.hairColor.darker(by: 0.1)
        mulletL.zPosition = 5
        addChild(mulletL)
        
        // Mullet right side
        let mulletR = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: 18, y: 50))
            p.addLine(to: CGPoint(x: 20, y: 28))
            p.addQuadCurve(to: CGPoint(x: 14, y: 24), controlPoint: CGPoint(x: 19, y: 22))
            p.addLine(to: CGPoint(x: 14, y: 50))
            p.close()
            return p.cgPath
        }())
        mulletR.fillColor = character.hairColor
        mulletR.strokeColor = character.hairColor.darker(by: 0.1)
        mulletR.zPosition = 5
        addChild(mulletR)
        
        // Trucker cap front panel
        let capFront = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -12, y: 52))
            p.addLine(to: CGPoint(x: -12, y: 58))
            p.addQuadCurve(to: CGPoint(x: 12, y: 58), controlPoint: CGPoint(x: 0, y: 68))
            p.addLine(to: CGPoint(x: 12, y: 52))
            p.close()
            return p.cgPath
        }())
        capFront.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.5, alpha: 1.0)
        capFront.strokeColor = UIColor(red: 0.18, green: 0.18, blue: 0.4, alpha: 1.0)
        capFront.lineWidth = 1.5
        capFront.zPosition = 6
        addChild(capFront)
        
        // Cap logo (small "C" shape)
        let logo = SKLabelNode(text: "C")
        logo.fontSize = 8
        logo.fontName = "AvenirNext-Bold"
        logo.fontColor = UIColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1.0)
        logo.position = CGPoint(x: 0, y: 56)
        logo.verticalAlignmentMode = .center
        logo.horizontalAlignmentMode = .center
        logo.zPosition = 7
        addChild(logo)
        
        // Cap mesh sides
        let meshL = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -20, y: 52))
            p.addLine(to: CGPoint(x: -20, y: 56))
            p.addQuadCurve(to: CGPoint(x: -12, y: 58), controlPoint: CGPoint(x: -16, y: 62))
            p.addLine(to: CGPoint(x: -12, y: 52))
            p.close()
            return p.cgPath
        }())
        meshL.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
        meshL.strokeColor = UIColor.lightGray
        meshL.lineWidth = 1
        meshL.zPosition = 6
        addChild(meshL)
        
        let meshR = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: 12, y: 52))
            p.addLine(to: CGPoint(x: 12, y: 58))
            p.addQuadCurve(to: CGPoint(x: 20, y: 56), controlPoint: CGPoint(x: 16, y: 62))
            p.addLine(to: CGPoint(x: 20, y: 52))
            p.close()
            return p.cgPath
        }())
        meshR.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
        meshR.strokeColor = UIColor.lightGray
        meshR.lineWidth = 1
        meshR.zPosition = 6
        addChild(meshR)
        
        // Cap brim
        let brim = SKShapeNode(rect: CGRect(x: -22, y: 50, width: 44, height: 5), cornerRadius: 2)
        brim.fillColor = UIColor(red: 0.25, green: 0.25, blue: 0.5, alpha: 1.0)
        brim.strokeColor = UIColor(red: 0.18, green: 0.18, blue: 0.4, alpha: 1.0)
        brim.lineWidth = 1.5
        brim.zPosition = 7
        addChild(brim)
    }
    
    private func buildChuckHair() {
        // Massive voluminous blonde curls
        let curls = SKNode()
        curls.zPosition = 5
        
        let outerCurls: [(CGFloat, CGFloat, CGFloat)] = [
            (-18, 50, 8), (-12, 58, 8), (-5, 64, 8), (5, 64, 8), (12, 58, 8), (18, 50, 8),
            (-20, 44, 7), (-16, 42, 6), (16, 42, 6), (20, 44, 7),
            (-8, 66, 7), (0, 68, 7), (8, 66, 7),
            (-14, 62, 6), (14, 62, 6), (0, 62, 5)
        ]
        for c in outerCurls {
            let curl = SKShapeNode(circleOfRadius: c.2)
            curl.position = CGPoint(x: c.0, y: c.1)
            curl.fillColor = character.hairColor
            curl.strokeColor = character.hairColor.darker(by: 0.1)
            curl.lineWidth = 0.8
            curls.addChild(curl)
        }
        
        // Highlight curls
        let highlights: [(CGFloat, CGFloat)] = [
            (-10, 60), (6, 63), (14, 56), (-16, 48), (0, 66), (-5, 56), (10, 50)
        ]
        for h in highlights {
            let hl = SKShapeNode(circleOfRadius: 4.5)
            hl.position = CGPoint(x: h.0, y: h.1)
            hl.fillColor = character.hairHighlightColor
            hl.strokeColor = .clear
            curls.addChild(hl)
        }
        
        addChild(curls)
    }
    
    private func buildStellaHair() {
        // Hair cap
        let hairCap = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -18, y: 52))
            p.addQuadCurve(to: CGPoint(x: 18, y: 52), controlPoint: CGPoint(x: 0, y: 72))
            p.addLine(to: CGPoint(x: 16, y: 48))
            p.addLine(to: CGPoint(x: -16, y: 48))
            p.close()
            return p.cgPath
        }())
        hairCap.fillColor = character.hairColor
        hairCap.strokeColor = character.hairColor.darker(by: 0.1)
        hairCap.lineWidth = 1.5
        hairCap.zPosition = 5
        addChild(hairCap)
        
        // Long wavy left side
        let leftHair = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -18, y: 54))
            p.addQuadCurve(to: CGPoint(x: -21, y: 38), controlPoint: CGPoint(x: -22, y: 46))
            p.addQuadCurve(to: CGPoint(x: -19, y: 22), controlPoint: CGPoint(x: -17, y: 30))
            p.addQuadCurve(to: CGPoint(x: -22, y: 6), controlPoint: CGPoint(x: -23, y: 14))
            p.addLine(to: CGPoint(x: -14, y: 8))
            p.addQuadCurve(to: CGPoint(x: -15, y: 26), controlPoint: CGPoint(x: -12, y: 17))
            p.addQuadCurve(to: CGPoint(x: -14, y: 42), controlPoint: CGPoint(x: -16, y: 34))
            p.addLine(to: CGPoint(x: -16, y: 54))
            p.close()
            return p.cgPath
        }())
        leftHair.fillColor = character.hairColor
        leftHair.strokeColor = character.hairColor.darker(by: 0.1)
        leftHair.zPosition = 5
        addChild(leftHair)
        
        // Long wavy right side
        let rightHair = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: 18, y: 54))
            p.addQuadCurve(to: CGPoint(x: 21, y: 38), controlPoint: CGPoint(x: 22, y: 46))
            p.addQuadCurve(to: CGPoint(x: 19, y: 22), controlPoint: CGPoint(x: 17, y: 30))
            p.addQuadCurve(to: CGPoint(x: 22, y: 6), controlPoint: CGPoint(x: 23, y: 14))
            p.addLine(to: CGPoint(x: 14, y: 8))
            p.addQuadCurve(to: CGPoint(x: 15, y: 26), controlPoint: CGPoint(x: 12, y: 17))
            p.addQuadCurve(to: CGPoint(x: 14, y: 42), controlPoint: CGPoint(x: 16, y: 34))
            p.addLine(to: CGPoint(x: 16, y: 54))
            p.close()
            return p.cgPath
        }())
        rightHair.fillColor = character.hairColor
        rightHair.strokeColor = character.hairColor.darker(by: 0.1)
        rightHair.zPosition = 5
        addChild(rightHair)
        
        // Highlight streaks
        let lHL = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -17, y: 50))
            p.addQuadCurve(to: CGPoint(x: -19, y: 26), controlPoint: CGPoint(x: -20, y: 38))
            p.addLine(to: CGPoint(x: -16, y: 28))
            p.addQuadCurve(to: CGPoint(x: -15, y: 48), controlPoint: CGPoint(x: -17, y: 38))
            p.close()
            return p.cgPath
        }())
        lHL.fillColor = character.hairHighlightColor
        lHL.strokeColor = .clear
        lHL.zPosition = 5
        addChild(lHL)
        
        let rHL = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: 17, y: 50))
            p.addQuadCurve(to: CGPoint(x: 19, y: 26), controlPoint: CGPoint(x: 20, y: 38))
            p.addLine(to: CGPoint(x: 16, y: 28))
            p.addQuadCurve(to: CGPoint(x: 15, y: 48), controlPoint: CGPoint(x: 17, y: 38))
            p.close()
            return p.cgPath
        }())
        rHL.fillColor = character.hairHighlightColor
        rHL.strokeColor = .clear
        rHL.zPosition = 5
        addChild(rHL)
    }
    
    // MARK: - Clothing Details
    
    private func buildClothingDetails() {
        switch character {
        case .theo:
            // Blue-purple rectangular glasses
            let gc = UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1.0)
            let tintFill = UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 0.15)
            
            let leftLens = SKShapeNode(rect: CGRect(x: -16, y: 44, width: 13, height: 10), cornerRadius: 2.5)
            leftLens.fillColor = tintFill
            leftLens.strokeColor = gc
            leftLens.lineWidth = 2.2
            leftLens.zPosition = 4
            addChild(leftLens)
            
            let rightLens = SKShapeNode(rect: CGRect(x: 3, y: 44, width: 13, height: 10), cornerRadius: 2.5)
            rightLens.fillColor = tintFill
            rightLens.strokeColor = gc
            rightLens.lineWidth = 2.2
            rightLens.zPosition = 4
            addChild(rightLens)
            
            // Bridge
            let bridge = SKShapeNode(rect: CGRect(x: -3, y: 48, width: 6, height: 2.5))
            bridge.fillColor = gc
            bridge.strokeColor = .clear
            bridge.zPosition = 4
            addChild(bridge)
            
            // Temple arms
            let lTemple = SKShapeNode(rect: CGRect(x: -18, y: 48, width: 3, height: 2))
            lTemple.fillColor = gc
            lTemple.strokeColor = .clear
            lTemple.zPosition = 4
            addChild(lTemple)
            let rTemple = SKShapeNode(rect: CGRect(x: 15, y: 48, width: 3, height: 2))
            rTemple.fillColor = gc
            rTemple.strokeColor = .clear
            rTemple.zPosition = 4
            addChild(rTemple)
            
            // Lens reflection dot
            let reflect = SKShapeNode(circleOfRadius: 1.5)
            reflect.position = CGPoint(x: -11, y: 50)
            reflect.fillColor = .white
            reflect.strokeColor = .clear
            reflect.alpha = 0.4
            reflect.zPosition = 5
            addChild(reflect)
            
        case .ben:
            // Hawaiian shirt pattern - colorful stripes and flowers
            let stripe1 = SKShapeNode(rect: CGRect(x: -9, y: 5, width: 5, height: 16), cornerRadius: 1)
            stripe1.fillColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.5)
            stripe1.strokeColor = .clear
            addChild(stripe1)
            
            let stripe2 = SKShapeNode(rect: CGRect(x: 3, y: 5, width: 5, height: 16), cornerRadius: 1)
            stripe2.fillColor = UIColor(red: 0.95, green: 0.8, blue: 0.2, alpha: 0.5)
            stripe2.strokeColor = .clear
            addChild(stripe2)
            
            // Small flower shapes
            let flowerPositions: [(CGFloat, CGFloat)] = [(-5, 12), (6, 8), (-2, 16)]
            for fp in flowerPositions {
                let flower = SKShapeNode(circleOfRadius: 2)
                flower.position = CGPoint(x: fp.0, y: fp.1)
                flower.fillColor = UIColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 0.5)
                flower.strokeColor = .clear
                addChild(flower)
            }
            
        case .chuck:
            // Hoodie hood (behind head)
            let hood = SKShapeNode(path: {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: -16, y: 26))
                p.addQuadCurve(to: CGPoint(x: 16, y: 26), controlPoint: CGPoint(x: 0, y: 34))
                p.addLine(to: CGPoint(x: 14, y: 22))
                p.addLine(to: CGPoint(x: -14, y: 22))
                p.close()
                return p.cgPath
            }())
            hood.fillColor = character.shirtColor.darker(by: 0.05)
            hood.strokeColor = character.shirtColor.darker(by: 0.15)
            hood.zPosition = -1
            addChild(hood)
            
            // Hoodie strings
            let strL = SKShapeNode(rect: CGRect(x: -5, y: 12, width: 1.2, height: 9))
            strL.fillColor = .white
            strL.strokeColor = .clear
            addChild(strL)
            let strR = SKShapeNode(rect: CGRect(x: 4, y: 12, width: 1.2, height: 9))
            strR.fillColor = .white
            strR.strokeColor = .clear
            addChild(strR)
            
            // String tips
            let tipL = SKShapeNode(circleOfRadius: 1.5)
            tipL.position = CGPoint(x: -4.4, y: 11.5)
            tipL.fillColor = .white
            tipL.strokeColor = .clear
            addChild(tipL)
            let tipR = SKShapeNode(circleOfRadius: 1.5)
            tipR.position = CGPoint(x: 4.6, y: 11.5)
            tipR.fillColor = .white
            tipR.strokeColor = .clear
            addChild(tipR)
            
            // Kangaroo pocket
            let pocket = SKShapeNode(rect: CGRect(x: -8, y: -2, width: 16, height: 8), cornerRadius: 3)
            pocket.fillColor = character.shirtColor.darker(by: 0.06)
            pocket.strokeColor = character.shirtColor.darker(by: 0.12)
            pocket.lineWidth = 1
            addChild(pocket)
            
        case .stella:
            // Gold necklace chain
            let chain = SKShapeNode(path: {
                let p = UIBezierPath()
                p.addArc(withCenter: CGPoint(x: 0, y: 24), radius: 11, startAngle: CGFloat.pi * 0.15, endAngle: CGFloat.pi * 0.85, clockwise: true)
                return p.cgPath
            }())
            chain.fillColor = .clear
            chain.strokeColor = UIColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 0.9)
            chain.lineWidth = 1.2
            chain.zPosition = 1
            addChild(chain)
            
            // Pendant
            let pendant = SKShapeNode(circleOfRadius: 2.5)
            pendant.position = CGPoint(x: 0, y: 14)
            pendant.fillColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
            pendant.strokeColor = UIColor(red: 0.75, green: 0.65, blue: 0.35, alpha: 1.0)
            pendant.lineWidth = 0.8
            pendant.zPosition = 1
            addChild(pendant)
            
            // Pendant sparkle
            let sparkle = SKShapeNode(circleOfRadius: 1)
            sparkle.position = CGPoint(x: -0.5, y: 15)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.alpha = 0.6
            sparkle.zPosition = 2
            addChild(sparkle)
        }
    }
    
    // MARK: - Pillow
    
    private func buildPillow() {
        pillowNode = SKNode()
        pillowNode.position = CGPoint(x: 28, y: 8)
        pillowNode.zPosition = 2
        
        pillowBody = SKShapeNode(rect: CGRect(x: -10, y: -7, width: 20, height: 28), cornerRadius: 8)
        pillowBody.fillColor = character.pillowColor
        pillowBody.strokeColor = character.pillowColor.darker(by: 0.12)
        pillowBody.lineWidth = 2
        pillowNode.addChild(pillowBody)
        
        // Fluff lines
        let fluffPositions: [(CGFloat, CGFloat, CGFloat)] = [(-5, 2, 10), (-4, 8, 8), (-3, 14, 6)]
        for f in fluffPositions {
            let fluff = SKShapeNode(rect: CGRect(x: f.0, y: f.1, width: f.2, height: 1.5))
            fluff.fillColor = character.pillowColor.darker(by: 0.06)
            fluff.strokeColor = .clear
            pillowNode.addChild(fluff)
        }
        
        // Pillow highlight
        let pHL = SKShapeNode(rect: CGRect(x: -8, y: 10, width: 5, height: 10), cornerRadius: 2)
        pHL.fillColor = .white
        pHL.strokeColor = .clear
        pHL.alpha = 0.2
        pillowNode.addChild(pHL)
        
        addChild(pillowNode)
    }
    
    // MARK: - Expression System
    
    func setExpression(_ expr: Expression) {
        guard expr != currentExpression else { return }
        currentExpression = expr
        
        // Update eyebrows
        switch expr {
        case .normal, .happy:
            leftBrow.zRotation = 0.1
            rightBrow.zRotation = -0.1
            leftBrow.position = CGPoint(x: -9, y: browY)
            rightBrow.position = CGPoint(x: 9, y: browY)
        case .attacking:
            leftBrow.zRotation = -0.3
            rightBrow.zRotation = 0.3
            leftBrow.position = CGPoint(x: -9, y: browY - 1)
            rightBrow.position = CGPoint(x: 9, y: browY - 1)
        case .hurt, .dizzy:
            leftBrow.zRotation = 0.35
            rightBrow.zRotation = -0.35
            leftBrow.position = CGPoint(x: -9, y: browY + 2)
            rightBrow.position = CGPoint(x: 9, y: browY + 2)
        }
        
        // Update eyes
        switch expr {
        case .normal, .attacking:
            leftEyeWhite.yScale = 1.0
            rightEyeWhite.yScale = 1.0
        case .hurt:
            leftEyeWhite.yScale = 0.25
            rightEyeWhite.yScale = 0.25
        case .happy:
            leftEyeWhite.yScale = 0.45
            rightEyeWhite.yScale = 0.45
        case .dizzy:
            leftEyeWhite.yScale = 1.0
            rightEyeWhite.yScale = 1.0
            // Spin pupils for dizzy effect
            let spin = SKAction.rotate(byAngle: .pi * 4, duration: 1.0)
            leftPupil.run(SKAction.repeatForever(spin), withKey: "dizzy")
            rightPupil.run(SKAction.repeatForever(spin), withKey: "dizzy")
        }
        
        // Stop dizzy spin for non-dizzy expressions
        if expr != .dizzy {
            leftPupil.removeAction(forKey: "dizzy")
            rightPupil.removeAction(forKey: "dizzy")
            leftPupil.zRotation = 0
            rightPupil.zRotation = 0
        }
        
        // Update mouth
        updateMouth()
    }
    
    private func updateMouth() {
        mouthNode?.removeFromParent()
        let mouth = SKNode()
        mouth.zPosition = 3
        
        switch currentExpression {
        case .normal:
            buildNormalMouth()
            return
        case .attacking:
            // Open determined mouth
            let openMouth = SKShapeNode(ellipseOf: CGSize(width: 8, height: 7))
            openMouth.position = CGPoint(x: 0, y: mouthY)
            openMouth.fillColor = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1.0)
            openMouth.strokeColor = UIColor(red: 0.7, green: 0.25, blue: 0.25, alpha: 1.0)
            openMouth.lineWidth = 1
            mouth.addChild(openMouth)
        case .hurt:
            // Wavy grimace
            let grimace = SKShapeNode(path: {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: -5, y: mouthY))
                p.addQuadCurve(to: CGPoint(x: -1.5, y: mouthY), controlPoint: CGPoint(x: -3.5, y: mouthY + 2.5))
                p.addQuadCurve(to: CGPoint(x: 1.5, y: mouthY), controlPoint: CGPoint(x: 0, y: mouthY - 2.5))
                p.addQuadCurve(to: CGPoint(x: 5, y: mouthY), controlPoint: CGPoint(x: 3.5, y: mouthY + 2.5))
                return p.cgPath
            }())
            grimace.strokeColor = UIColor(red: 0.7, green: 0.25, blue: 0.25, alpha: 1.0)
            grimace.lineWidth = 2
            grimace.fillColor = .clear
            mouth.addChild(grimace)
        case .happy:
            // Big smile
            let bigSmile = SKShapeNode(path: {
                let p = UIBezierPath()
                p.addArc(withCenter: CGPoint(x: 0, y: mouthY + 2), radius: 6, startAngle: CGFloat.pi * 0.15, endAngle: CGFloat.pi * 0.85, clockwise: true)
                p.addLine(to: CGPoint(x: -5, y: mouthY + 2))
                p.close()
                return p.cgPath
            }())
            bigSmile.fillColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
            bigSmile.strokeColor = .clear
            mouth.addChild(bigSmile)
        case .dizzy:
            // Open mouth with tongue
            let openM = SKShapeNode(ellipseOf: CGSize(width: 9, height: 7))
            openM.position = CGPoint(x: 0, y: mouthY)
            openM.fillColor = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1.0)
            openM.strokeColor = UIColor(red: 0.7, green: 0.25, blue: 0.25, alpha: 1.0)
            openM.lineWidth = 1
            mouth.addChild(openM)
            
            let tongue = SKShapeNode(ellipseOf: CGSize(width: 5, height: 4))
            tongue.position = CGPoint(x: 1, y: mouthY - 3)
            tongue.fillColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
            tongue.strokeColor = .clear
            mouth.addChild(tongue)
        }
        
        addChild(mouth)
        mouthNode = mouth
    }
    
    // MARK: - Blink
    
    private func doBlink() {
        blinkTimer = 0
        nextBlinkTime = TimeInterval.random(in: 2.5...5.0)
        
        let close = SKAction.scaleY(to: 0.1, duration: 0.06)
        let open = SKAction.scaleY(to: currentExpression == .happy ? 0.45 : 1.0, duration: 0.06)
        let blink = SKAction.sequence([close, open])
        leftEyeWhite.run(blink)
        rightEyeWhite.run(blink)
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
                // Jump squat anticipation
                let squat = SKAction.scaleY(to: charScale * 0.88, duration: 0.05)
                let launch = SKAction.scaleY(to: charScale * 1.08, duration: 0.05)
                let normalize = SKAction.scaleY(to: charScale, duration: 0.1)
                run(SKAction.sequence([squat, SKAction.run { [weak self] in
                    self?.velocityY = self?.jumpForce ?? 500
                    self?.isOnGround = false
                }, launch, normalize]))
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
    
    // MARK: - Attack Animations
    
    private func animatePillowSwing() {
        setExpression(.attacking)
        
        // Wind-up
        let windUp = SKAction.group([
            SKAction.moveBy(x: -4, y: -2, duration: 0.07),
            SKAction.rotate(byAngle: -0.2, duration: 0.07)
        ])
        // Swing arc
        let swing = SKAction.group([
            SKAction.moveBy(x: 8, y: 14, duration: 0.1),
            SKAction.rotate(byAngle: 0.5, duration: 0.1),
            SKAction.scale(to: 1.25, duration: 0.1)
        ])
        // Follow-through
        let followThru = SKAction.group([
            SKAction.moveBy(x: -4, y: -12, duration: 0.12),
            SKAction.rotate(byAngle: -0.3, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])
        
        pillowNode.run(SKAction.sequence([windUp, swing, followThru]))
        
        // Body lean into swing
        torsoNode.run(SKAction.sequence([
            SKAction.moveBy(x: 3, y: 0, duration: 0.1),
            SKAction.moveBy(x: -3, y: 0, duration: 0.15)
        ]))
        
        // Feather burst at impact
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.17),
            SKAction.run { [weak self] in self?.spawnFeathers() }
        ]))
        
        // Reset expression
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { [weak self] in self?.setExpression(.normal) }
        ]))
        
        finishMove(after: MoveType.pillowSwing.executionTime)
    }
    
    private func animateKick() {
        setExpression(.attacking)
        
        let kickLeg = rightLegNode!
        let kickShoe = rightShoeNode!
        
        // Lift → extend → return
        let lift = SKAction.moveBy(x: 0, y: 5, duration: 0.05)
        let extend = SKAction.moveBy(x: 18, y: -3, duration: 0.08)
        let retract = SKAction.moveBy(x: -18, y: -2, duration: 0.1)
        
        kickLeg.run(SKAction.sequence([lift, extend, retract]))
        kickShoe.run(SKAction.sequence([lift, extend, retract]))
        
        // Body lean
        torsoNode.run(SKAction.sequence([
            SKAction.moveBy(x: 4, y: 0, duration: 0.1),
            SKAction.moveBy(x: -4, y: 0, duration: 0.12)
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.22),
            SKAction.run { [weak self] in self?.setExpression(.normal) }
        ]))
        
        finishMove(after: MoveType.kick.executionTime)
    }
    
    private func animateBlock() {
        isBlocking = true
        
        pillowNode.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: 10, y: 18), duration: 0.08),
            SKAction.wait(forDuration: 0.4),
            SKAction.move(to: CGPoint(x: 28, y: 8), duration: 0.1),
            SKAction.run { [weak self] in self?.isBlocking = false }
        ]))
        
        finishMove(after: 0.6)
    }
    
    private func animateSpecialMove() {
        setExpression(.happy)
        
        switch character {
        case .theo:
            spawnFartCloud()
        case .ben:
            spawnBreathCloud()
        case .chuck:
            spawnBoogerProjectile()
        case .stella:
            spawnPrettyLookEffect()
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run { [weak self] in self?.setExpression(.normal) }
        ]))
        
        finishMove(after: MoveType.special.executionTime)
    }
    
    // MARK: - Hit & KO Animations
    
    func animateHit() {
        setExpression(.hurt)
        
        // Red flash overlay
        let flash = SKShapeNode(rect: CGRect(x: -22, y: -52, width: 44, height: 130), cornerRadius: 5)
        flash.fillColor = UIColor.red.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.zPosition = 15
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // White flash
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.04),
            SKAction.fadeAlpha(to: 1.0, duration: 0.04)
        ])
        run(SKAction.repeat(blink, count: 2))
        
        // Knockback (scene-space, needs direction)
        let knockDir: CGFloat = facingRight ? -1 : 1
        run(SKAction.moveBy(x: knockDir * 28, y: 0, duration: 0.1))
        
        // Recover expression
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                if self?.currentExpression == .hurt {
                    self?.setExpression(.normal)
                }
            }
        ]))
    }
    
    func animateKO() {
        setExpression(.dizzy)
        
        // Stagger back
        let knockDir: CGFloat = facingRight ? -1 : 1
        let stagger = SKAction.moveBy(x: knockDir * 15, y: 0, duration: 0.2)
        
        // Collapse
        let fall = SKAction.moveBy(x: 0, y: -20, duration: 0.3)
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 0.5)
        
        run(SKAction.sequence([
            stagger,
            SKAction.group([spin, fall, fadeOut])
        ]))
        
        // Circling stars (added to scene for correct rendering)
        if let scene = self.scene {
            let starsNode = SKNode()
            let starsPos = convert(CGPoint(x: 0, y: 68), to: scene)
            starsNode.position = starsPos
            starsNode.zPosition = 60
            
            for i in 0..<3 {
                let star = SKLabelNode(text: "⭐")
                star.fontSize = 10
                let angle = CGFloat(i) * (2 * .pi / 3)
                star.position = CGPoint(x: cos(angle) * 15, y: sin(angle) * 10)
                starsNode.addChild(star)
            }
            
            scene.addChild(starsNode)
            let orbit = SKAction.rotate(byAngle: .pi * 4, duration: 2.0)
            let fade = SKAction.fadeOut(withDuration: 2.0)
            starsNode.run(SKAction.sequence([
                SKAction.group([orbit, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Special Move Effects
    
    private func spawnFartCloud() {
        guard let scene = self.scene else { return }
        let cloud = SKNode()
        let basePos = convert(CGPoint(x: -30, y: 5), to: scene)
        cloud.position = basePos
        cloud.zPosition = 50
        
        let behindDir: CGFloat = facingRight ? -1 : 1
        
        for i in 0..<6 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...16))
            puff.position = CGPoint(x: behindDir * CGFloat(i * 12), y: CGFloat.random(in: -8...8))
            puff.fillColor = UIColor(red: 0.4, green: 0.7, blue: 0.2, alpha: 0.7)
            puff.strokeColor = UIColor(red: 0.3, green: 0.5, blue: 0.1, alpha: 0.3)
            puff.lineWidth = 1
            cloud.addChild(puff)
        }
        
        scene.addChild(cloud)
        let expand = SKAction.scale(to: 2.0, duration: 0.7)
        let drift = SKAction.moveBy(x: behindDir * 30, y: 0, duration: 0.7)
        let fade = SKAction.fadeOut(withDuration: 0.7)
        cloud.run(SKAction.sequence([
            SKAction.group([expand, drift, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnBreathCloud() {
        guard let scene = self.scene else { return }
        let cloud = SKNode()
        let basePos = convert(CGPoint(x: 20, y: 42), to: scene)
        cloud.position = basePos
        cloud.zPosition = 50
        
        let fwdDir: CGFloat = facingRight ? 1 : -1
        
        for i in 0..<7 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...13))
            puff.position = CGPoint(x: fwdDir * CGFloat(i * 10), y: CGFloat.random(in: -6...6))
            puff.fillColor = UIColor(red: 0.7, green: 0.8, blue: 0.2, alpha: 0.6)
            puff.strokeColor = .clear
            cloud.addChild(puff)
        }
        
        scene.addChild(cloud)
        let move = SKAction.moveBy(x: fwdDir * 70, y: 0, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        cloud.run(SKAction.sequence([
            SKAction.group([move, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnBoogerProjectile() {
        guard let scene = self.scene else { return }
        let fwdDir: CGFloat = facingRight ? 1 : -1
        let basePos = convert(CGPoint(x: 20, y: 44), to: scene)
        
        let booger = SKShapeNode(circleOfRadius: 6)
        booger.position = basePos
        booger.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.1, alpha: 1.0)
        booger.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.0, alpha: 1.0)
        booger.lineWidth = 1.5
        booger.zPosition = 50
        scene.addChild(booger)
        
        let travel = SKAction.moveBy(x: fwdDir * 140, y: 0, duration: 0.5)
        let wobble = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.08),
            SKAction.moveBy(x: 0, y: -6, duration: 0.08)
        ])
        
        booger.run(SKAction.sequence([
            SKAction.group([travel, SKAction.repeat(wobble, count: 3)]),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnPrettyLookEffect() {
        guard let scene = self.scene else { return }
        let fwdDir: CGFloat = facingRight ? 1 : -1
        let basePos = convert(CGPoint(x: 10, y: 45), to: scene)
        
        let symbols = ["✨", "💫", "⭐", "💖", "💕", "🌟"]
        for i in 0..<10 {
            let sparkle = SKLabelNode(text: symbols[i % symbols.count])
            sparkle.fontSize = CGFloat.random(in: 14...22)
            sparkle.position = CGPoint(
                x: basePos.x + fwdDir * CGFloat.random(in: 10...90),
                y: basePos.y + CGFloat.random(in: -20...30)
            )
            sparkle.zPosition = 50
            sparkle.alpha = 0.9
            scene.addChild(sparkle)
            
            let drift = SKAction.moveBy(x: fwdDir * CGFloat.random(in: 10...40), y: CGFloat.random(in: 15...35), duration: 0.9)
            let fade = SKAction.fadeOut(withDuration: 0.9)
            let scale = SKAction.scale(to: 0.3, duration: 0.9)
            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.05),
                SKAction.group([drift, fade, scale]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Feather & Impact Effects
    
    private func spawnFeathers() {
        guard let scene = self.scene else { return }
        let basePos = convert(CGPoint(x: 28, y: 20), to: scene)
        
        for _ in 0..<6 {
            let feather = SKLabelNode(text: "🪶")
            feather.fontSize = CGFloat.random(in: 10...16)
            feather.position = CGPoint(
                x: basePos.x + CGFloat.random(in: -12...12),
                y: basePos.y + CGFloat.random(in: -5...10)
            )
            feather.zPosition = 50
            scene.addChild(feather)
            
            let drift = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 20...45), duration: 0.7)
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: 0.7)
            let fade = SKAction.fadeOut(withDuration: 0.7)
            feather.run(SKAction.sequence([
                SKAction.group([drift, spin, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func spawnImpactStars(at scenePos: CGPoint) {
        guard let scene = self.scene else { return }
        
        for _ in 0..<5 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            star.position = scenePos
            star.fillColor = .yellow
            star.strokeColor = .orange
            star.lineWidth = 1
            star.zPosition = 55
            scene.addChild(star)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 20...45)
            let burst = SKAction.moveBy(x: cos(angle) * dist, y: sin(angle) * dist, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let shrink = SKAction.scale(to: 0.2, duration: 0.3)
            star.run(SKAction.sequence([
                SKAction.group([burst, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Update Loop
    
    func update(deltaTime: TimeInterval) {
        // Gravity
        if !isOnGround {
            velocityY += gravity * CGFloat(deltaTime)
            position.y += velocityY * CGFloat(deltaTime)
            
            if position.y <= groundY {
                position.y = groundY
                velocityY = 0
                isOnGround = true
                // Land squash
                let squash = SKAction.scaleY(to: charScale * 0.9, duration: 0.05)
                let stretch = SKAction.scaleY(to: charScale, duration: 0.08)
                run(SKAction.sequence([squash, stretch]))
            }
        }
        
        // Horizontal movement
        position.x += velocityX * CGFloat(deltaTime)
        
        // Special cooldown
        if specialCooldownTimer > 0 {
            specialCooldownTimer -= deltaTime
        }
        
        // Walk cycle animation
        if abs(velocityX) > 10 && isOnGround && !isExecutingMove {
            walkCycle += CGFloat(deltaTime) * 12
            let legOff = sin(walkCycle) * 4
            leftLegNode.position.y = legOff
            rightLegNode.position.y = -legOff
            leftShoeNode.position.y = legOff
            rightShoeNode.position.y = -legOff
            leftArmNode.zRotation = sin(walkCycle + .pi) * 0.12
            rightArmNode.zRotation = sin(walkCycle) * 0.12
        } else if isOnGround {
            leftLegNode.position.y = 0
            rightLegNode.position.y = 0
            leftShoeNode.position.y = 0
            rightShoeNode.position.y = 0
            leftArmNode.zRotation = 0
            rightArmNode.zRotation = 0
            walkCycle = 0
        }
        
        // Breathing (idle only)
        if currentMove == .idle && isOnGround {
            breathTimer += deltaTime
            let breathScale = 1.0 + sin(breathTimer * 2.5) * 0.012
            torsoNode.yScale = CGFloat(breathScale)
        } else {
            torsoNode.yScale = 1.0
        }
        
        // Blink (only when not hurt/dizzy)
        if currentExpression == .normal || currentExpression == .attacking || currentExpression == .happy {
            blinkTimer += deltaTime
            if blinkTimer >= nextBlinkTime {
                doBlink()
            }
        }
        
        // Idle head bob
        if currentMove == .idle && isOnGround {
            let bob = sin(CACurrentMediaTime() * 3) * 1.5
            headNode.position.y = headCenterY + CGFloat(bob)
        }
    }
    
    // MARK: - Facing & Cooldown
    
    func setFacing(right: Bool) {
        facingRight = right
        xScale = right ? charScale : -charScale
        // Keep name label readable
        nameLabel.xScale = right ? 1.0 : -1.0
    }
    
    var specialCooldownProgress: CGFloat {
        if isSpecialReady { return 1.0 }
        return 1.0 - CGFloat(specialCooldownTimer / MoveType.special.cooldown)
    }
}

// MARK: - UIColor Extension

extension UIColor {
    func darker(by factor: CGFloat = 0.2) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(r - factor, 0), green: max(g - factor, 0), blue: max(b - factor, 0), alpha: a)
    }
    
    func lighter(by factor: CGFloat = 0.2) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(r + factor, 1), green: min(g + factor, 1), blue: min(b + factor, 1), alpha: a)
    }
}
