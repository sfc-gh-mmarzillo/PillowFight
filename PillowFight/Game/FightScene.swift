import SpriteKit

class FightScene: SKScene {
    
    // Fighters
    var player1: FighterNode!
    var player2: FighterNode!
    
    // AI
    private var aiController = AIController()
    
    // Characters
    var player1Character: GameCharacter = .theo
    var player2Character: GameCharacter = .ben
    
    // Game state
    var isRoundActive = false
    private var lastUpdateTime: TimeInterval = 0
    
    // UI elements
    private var p1HealthBar: SKShapeNode!
    private var p1HealthFill: SKShapeNode!
    private var p1GhostFill: SKShapeNode!
    private var p2HealthBar: SKShapeNode!
    private var p2HealthFill: SKShapeNode!
    private var p2GhostFill: SKShapeNode!
    private var roundLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var timerBg: SKShapeNode!
    private var announcementLabel: SKLabelNode!
    private var p1SpecialRing: SKShapeNode!
    private var p2SpecialRing: SKShapeNode!
    private var comboLabel: SKLabelNode!
    
    // Round state
    var roundTimer: TimeInterval = 60
    var currentRound: Int = 1
    
    // Combo tracking
    private var comboCount: Int = 0
    private var lastComboTime: TimeInterval = 0
    private let comboWindow: TimeInterval = 1.5
    
    // Ghost health (for animated drain)
    private var p1GhostHealth: CGFloat = 100
    private var p2GhostHealth: CGFloat = 100
    
    // Callbacks
    var onRoundEnd: ((Bool) -> Void)?
    var onHealthUpdate: ((CGFloat, CGFloat) -> Void)?
    
    // Constants
    private let groundY: CGFloat = 80
    private let arenaMinX: CGFloat = 30
    private var arenaMaxX: CGFloat { size.width - 30 }
    private let healthBarWidth: CGFloat = 160
    private let healthBarHeight: CGFloat = 16
    
    // Background
    private var backgroundNode: SKNode!
    private var worldNode: SKNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.22, alpha: 1.0)
        
        worldNode = SKNode()
        addChild(worldNode)
        
        buildArena()
        buildUI()
        setupFighters()
        startRound()
    }
    
    // MARK: - Arena
    
    private func buildArena() {
        backgroundNode = SKNode()
        backgroundNode.zPosition = 0
        
        // Wall
        let wall = SKShapeNode(rect: CGRect(x: 0, y: groundY - 10, width: size.width, height: size.height - groundY + 10))
        wall.fillColor = SKColor(red: 0.18, green: 0.13, blue: 0.28, alpha: 1.0)
        wall.strokeColor = .clear
        backgroundNode.addChild(wall)
        
        // Wallpaper pattern (subtle diamonds)
        let patternSpacing: CGFloat = 30
        for row in 0..<Int((size.height - groundY) / patternSpacing) + 1 {
            for col in 0..<Int(size.width / patternSpacing) + 1 {
                let x = CGFloat(col) * patternSpacing + (row % 2 == 0 ? 0 : patternSpacing / 2)
                let y = groundY + CGFloat(row) * patternSpacing
                let diamond = SKShapeNode(path: {
                    let p = UIBezierPath()
                    p.move(to: CGPoint(x: 0, y: 4))
                    p.addLine(to: CGPoint(x: 3, y: 0))
                    p.addLine(to: CGPoint(x: 0, y: -4))
                    p.addLine(to: CGPoint(x: -3, y: 0))
                    p.close()
                    return p.cgPath
                }())
                diamond.position = CGPoint(x: x, y: y)
                diamond.fillColor = SKColor(white: 1.0, alpha: 0.03)
                diamond.strokeColor = .clear
                backgroundNode.addChild(diamond)
            }
        }
        
        // Baseboard molding
        let baseboard = SKShapeNode(rect: CGRect(x: 0, y: groundY - 14, width: size.width, height: 6))
        baseboard.fillColor = SKColor(red: 0.35, green: 0.25, blue: 0.18, alpha: 1.0)
        baseboard.strokeColor = SKColor(red: 0.28, green: 0.18, blue: 0.1, alpha: 1.0)
        baseboard.lineWidth = 1
        backgroundNode.addChild(baseboard)
        
        // Floor
        let floor = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: groundY - 10))
        floor.fillColor = SKColor(red: 0.28, green: 0.18, blue: 0.12, alpha: 1.0)
        floor.strokeColor = .clear
        backgroundNode.addChild(floor)
        
        // Wooden planks
        let plankW: CGFloat = 38
        for i in 0..<Int(size.width / plankW) + 1 {
            let plank = SKShapeNode(rect: CGRect(x: CGFloat(i) * plankW + 2, y: 4, width: plankW - 4, height: groundY - 18), cornerRadius: 2)
            plank.fillColor = SKColor(red: 0.42, green: 0.28, blue: 0.18, alpha: 1.0)
            plank.strokeColor = SKColor(red: 0.32, green: 0.18, blue: 0.1, alpha: 0.4)
            plank.lineWidth = 1
            backgroundNode.addChild(plank)
            
            // Plank grain line
            let grain = SKShapeNode(rect: CGRect(x: CGFloat(i) * plankW + 8, y: 10, width: 2, height: groundY - 30))
            grain.fillColor = SKColor(red: 0.38, green: 0.24, blue: 0.14, alpha: 0.3)
            grain.strokeColor = .clear
            backgroundNode.addChild(grain)
        }
        
        // Carpet/rug in center
        let rugW: CGFloat = size.width * 0.45
        let rugX = (size.width - rugW) / 2
        let rug = SKShapeNode(rect: CGRect(x: rugX, y: 2, width: rugW, height: groundY - 16), cornerRadius: 4)
        rug.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.25, alpha: 0.4)
        rug.strokeColor = SKColor(red: 0.6, green: 0.3, blue: 0.35, alpha: 0.3)
        rug.lineWidth = 2
        backgroundNode.addChild(rug)
        
        // Rug border pattern
        let rugBorder = SKShapeNode(rect: CGRect(x: rugX + 4, y: 6, width: rugW - 8, height: groundY - 24), cornerRadius: 2)
        rugBorder.fillColor = .clear
        rugBorder.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.2)
        rugBorder.lineWidth = 1
        backgroundNode.addChild(rugBorder)
        
        // Window (bigger, with curtains)
        let winW: CGFloat = 100
        let winH: CGFloat = 70
        let winX = size.width / 2 - winW / 2
        let winY = size.height - 170
        
        let windowFrame = SKShapeNode(rect: CGRect(x: winX, y: winY, width: winW, height: winH), cornerRadius: 4)
        windowFrame.fillColor = SKColor(red: 0.15, green: 0.2, blue: 0.45, alpha: 0.9)
        windowFrame.strokeColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        windowFrame.lineWidth = 5
        backgroundNode.addChild(windowFrame)
        
        // Window cross
        let crossV = SKShapeNode(rect: CGRect(x: size.width / 2 - 1.5, y: winY + 4, width: 3, height: winH - 8))
        crossV.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        crossV.strokeColor = .clear
        backgroundNode.addChild(crossV)
        
        let crossH = SKShapeNode(rect: CGRect(x: winX + 4, y: winY + winH / 2 - 1.5, width: winW - 8, height: 3))
        crossH.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        crossH.strokeColor = .clear
        backgroundNode.addChild(crossH)
        
        // Moon with glow
        let moonGlow = SKShapeNode(circleOfRadius: 22)
        moonGlow.position = CGPoint(x: size.width / 2 + 15, y: winY + winH - 20)
        moonGlow.fillColor = SKColor(red: 1, green: 1, blue: 0.8, alpha: 0.15)
        moonGlow.strokeColor = .clear
        backgroundNode.addChild(moonGlow)
        
        let moon = SKShapeNode(circleOfRadius: 14)
        moon.position = CGPoint(x: size.width / 2 + 15, y: winY + winH - 20)
        moon.fillColor = SKColor(red: 1, green: 1, blue: 0.85, alpha: 0.9)
        moon.strokeColor = .clear
        backgroundNode.addChild(moon)
        
        // Stars
        for _ in 0..<8 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            star.position = CGPoint(
                x: CGFloat.random(in: winX + 8...winX + winW - 8),
                y: CGFloat.random(in: winY + 8...winY + winH - 8)
            )
            star.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.4...0.9))
            star.strokeColor = .clear
            backgroundNode.addChild(star)
        }
        
        // Curtain left
        let curtainL = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: winX - 10, y: winY + winH + 5))
            p.addLine(to: CGPoint(x: winX - 10, y: winY - 5))
            p.addQuadCurve(to: CGPoint(x: winX + 18, y: winY - 5), controlPoint: CGPoint(x: winX + 5, y: winY + 10))
            p.addLine(to: CGPoint(x: winX + 18, y: winY + winH + 5))
            p.close()
            return p.cgPath
        }())
        curtainL.fillColor = SKColor(red: 0.5, green: 0.15, blue: 0.2, alpha: 0.7)
        curtainL.strokeColor = SKColor(red: 0.4, green: 0.1, blue: 0.15, alpha: 0.5)
        curtainL.lineWidth = 1
        backgroundNode.addChild(curtainL)
        
        // Curtain right
        let curtainR = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: winX + winW + 10, y: winY + winH + 5))
            p.addLine(to: CGPoint(x: winX + winW + 10, y: winY - 5))
            p.addQuadCurve(to: CGPoint(x: winX + winW - 18, y: winY - 5), controlPoint: CGPoint(x: winX + winW - 5, y: winY + 10))
            p.addLine(to: CGPoint(x: winX + winW - 18, y: winY + winH + 5))
            p.close()
            return p.cgPath
        }())
        curtainR.fillColor = SKColor(red: 0.5, green: 0.15, blue: 0.2, alpha: 0.7)
        curtainR.strokeColor = SKColor(red: 0.4, green: 0.1, blue: 0.15, alpha: 0.5)
        curtainR.lineWidth = 1
        backgroundNode.addChild(curtainR)
        
        // Curtain rod
        let rod = SKShapeNode(rect: CGRect(x: winX - 15, y: winY + winH + 3, width: winW + 30, height: 3), cornerRadius: 1.5)
        rod.fillColor = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 1.0)
        rod.strokeColor = .clear
        backgroundNode.addChild(rod)
        
        // Bed (left side)
        let bedFrame = SKShapeNode(rect: CGRect(x: 10, y: groundY - 10, width: 80, height: 45), cornerRadius: 4)
        bedFrame.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.18, alpha: 0.6)
        bedFrame.strokeColor = SKColor(red: 0.38, green: 0.22, blue: 0.12, alpha: 0.5)
        bedFrame.lineWidth = 2
        backgroundNode.addChild(bedFrame)
        
        // Bed headboard
        let headboard = SKShapeNode(rect: CGRect(x: 8, y: groundY + 30, width: 6, height: 30), cornerRadius: 2)
        headboard.fillColor = SKColor(red: 0.4, green: 0.24, blue: 0.14, alpha: 0.7)
        headboard.strokeColor = .clear
        backgroundNode.addChild(headboard)
        
        // Bed blanket
        let blanket = SKShapeNode(rect: CGRect(x: 14, y: groundY - 8, width: 72, height: 30), cornerRadius: 3)
        blanket.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.65, alpha: 0.5)
        blanket.strokeColor = .clear
        backgroundNode.addChild(blanket)
        
        // Bed pillow
        let bedPillow = SKShapeNode(rect: CGRect(x: 14, y: groundY + 18, width: 30, height: 14), cornerRadius: 6)
        bedPillow.fillColor = SKColor(white: 0.9, alpha: 0.4)
        bedPillow.strokeColor = .clear
        backgroundNode.addChild(bedPillow)
        
        // Nightstand with lamp (right side)
        let nightstand = SKShapeNode(rect: CGRect(x: size.width - 65, y: groundY - 10, width: 40, height: 35), cornerRadius: 3)
        nightstand.fillColor = SKColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 0.5)
        nightstand.strokeColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 0.4)
        nightstand.lineWidth = 1.5
        backgroundNode.addChild(nightstand)
        
        // Lamp base
        let lampBase = SKShapeNode(rect: CGRect(x: size.width - 52, y: groundY + 22, width: 14, height: 4), cornerRadius: 2)
        lampBase.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 0.6)
        lampBase.strokeColor = .clear
        backgroundNode.addChild(lampBase)
        
        // Lamp shade
        let lampShade = SKShapeNode(path: {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: size.width - 55, y: groundY + 26))
            p.addLine(to: CGPoint(x: size.width - 52, y: groundY + 42))
            p.addLine(to: CGPoint(x: size.width - 38, y: groundY + 42))
            p.addLine(to: CGPoint(x: size.width - 35, y: groundY + 26))
            p.close()
            return p.cgPath
        }())
        lampShade.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.4)
        lampShade.strokeColor = .clear
        backgroundNode.addChild(lampShade)
        
        // Lamp glow
        let lampGlow = SKShapeNode(circleOfRadius: 25)
        lampGlow.position = CGPoint(x: size.width - 45, y: groundY + 38)
        lampGlow.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.08)
        lampGlow.strokeColor = .clear
        backgroundNode.addChild(lampGlow)
        
        // Wall poster 1
        let poster1 = SKShapeNode(rect: CGRect(x: 50, y: size.height - 120, width: 35, height: 45), cornerRadius: 2)
        poster1.fillColor = SKColor(red: 0.6, green: 0.3, blue: 0.2, alpha: 0.4)
        poster1.strokeColor = SKColor(red: 0.5, green: 0.25, blue: 0.15, alpha: 0.3)
        poster1.lineWidth = 1
        backgroundNode.addChild(poster1)
        
        // Wall poster 2
        let poster2 = SKShapeNode(rect: CGRect(x: size.width - 85, y: size.height - 140, width: 30, height: 40), cornerRadius: 2)
        poster2.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.5, alpha: 0.4)
        poster2.strokeColor = SKColor(red: 0.15, green: 0.3, blue: 0.4, alpha: 0.3)
        poster2.lineWidth = 1
        backgroundNode.addChild(poster2)
        
        // Floor pillows
        let pillowData: [(CGFloat, CGFloat, UIColor, CGFloat)] = [
            (55, groundY - 16, .systemPink, -0.2),
            (size.width - 75, groundY - 14, .systemCyan, 0.15),
            (size.width / 2 + 45, groundY - 18, .systemYellow, -0.1)
        ]
        for pd in pillowData {
            let dp = SKShapeNode(rect: CGRect(x: -10, y: -6, width: 20, height: 12), cornerRadius: 5)
            dp.position = CGPoint(x: pd.0, y: pd.1)
            dp.fillColor = pd.2.withAlphaComponent(0.6)
            dp.strokeColor = pd.2.darker(by: 0.15).withAlphaComponent(0.4)
            dp.zRotation = pd.3
            backgroundNode.addChild(dp)
        }
        
        // Stuffed animal on nightstand
        let stuffy = SKShapeNode(circleOfRadius: 8)
        stuffy.position = CGPoint(x: size.width - 50, y: groundY + 30)
        stuffy.fillColor = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 0.5)
        stuffy.strokeColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 0.4)
        stuffy.lineWidth = 1
        backgroundNode.addChild(stuffy)
        
        // Stuffy ears
        let earL = SKShapeNode(circleOfRadius: 4)
        earL.position = CGPoint(x: size.width - 55, y: groundY + 36)
        earL.fillColor = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 0.5)
        earL.strokeColor = .clear
        backgroundNode.addChild(earL)
        let earR = SKShapeNode(circleOfRadius: 4)
        earR.position = CGPoint(x: size.width - 45, y: groundY + 36)
        earR.fillColor = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 0.5)
        earR.strokeColor = .clear
        backgroundNode.addChild(earR)
        
        worldNode.addChild(backgroundNode)
    }
    
    // MARK: - UI / HUD
    
    private func buildUI() {
        let topY = size.height - 50
        
        // P1 Health Bar
        p1HealthBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: healthBarWidth, height: healthBarHeight), cornerRadius: 4)
        p1HealthBar.position = CGPoint(x: 20, y: topY)
        p1HealthBar.fillColor = SKColor(red: 0.2, green: 0.08, blue: 0.08, alpha: 0.85)
        p1HealthBar.strokeColor = .white
        p1HealthBar.lineWidth = 2
        p1HealthBar.zPosition = 90
        addChild(p1HealthBar)
        
        // P1 ghost fill (trails behind for damage visualization)
        p1GhostFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: healthBarWidth - 4, height: healthBarHeight - 4), cornerRadius: 3)
        p1GhostFill.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
        p1GhostFill.strokeColor = .clear
        p1HealthBar.addChild(p1GhostFill)
        
        // P1 health fill
        p1HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: healthBarWidth - 4, height: healthBarHeight - 4), cornerRadius: 3)
        p1HealthFill.fillColor = .systemGreen
        p1HealthFill.strokeColor = .clear
        p1HealthBar.addChild(p1HealthFill)
        
        // P1 character face icon
        let p1Face = SKSpriteNode(texture: FaceRenderer.texture(for: player1Character, expression: .normal),
                                  size: CGSize(width: 24, height: 24))
        p1Face.position = CGPoint(x: -14, y: healthBarHeight / 2)
        p1HealthBar.addChild(p1Face)
        
        // P1 Name
        let p1Name = SKLabelNode(text: player1Character.displayName)
        p1Name.fontSize = 12
        p1Name.fontName = "AvenirNext-Bold"
        p1Name.fontColor = player1Character.shirtColor
        p1Name.position = CGPoint(x: 20, y: topY + 20)
        p1Name.horizontalAlignmentMode = .left
        p1Name.zPosition = 90
        addChild(p1Name)
        
        // P2 Health Bar
        p2HealthBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: healthBarWidth, height: healthBarHeight), cornerRadius: 4)
        p2HealthBar.position = CGPoint(x: size.width - healthBarWidth - 20, y: topY)
        p2HealthBar.fillColor = SKColor(red: 0.2, green: 0.08, blue: 0.08, alpha: 0.85)
        p2HealthBar.strokeColor = .white
        p2HealthBar.lineWidth = 2
        p2HealthBar.zPosition = 90
        addChild(p2HealthBar)
        
        // P2 ghost fill
        p2GhostFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: healthBarWidth - 4, height: healthBarHeight - 4), cornerRadius: 3)
        p2GhostFill.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
        p2GhostFill.strokeColor = .clear
        p2HealthBar.addChild(p2GhostFill)
        
        // P2 health fill
        p2HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: healthBarWidth - 4, height: healthBarHeight - 4), cornerRadius: 3)
        p2HealthFill.fillColor = .systemGreen
        p2HealthFill.strokeColor = .clear
        p2HealthBar.addChild(p2HealthFill)
        
        // P2 character face icon
        let p2Face = SKSpriteNode(texture: FaceRenderer.texture(for: player2Character, expression: .normal),
                                  size: CGSize(width: 24, height: 24))
        p2Face.position = CGPoint(x: healthBarWidth + 14, y: healthBarHeight / 2)
        p2HealthBar.addChild(p2Face)
        
        // P2 Name
        let p2Name = SKLabelNode(text: player2Character.displayName)
        p2Name.fontSize = 12
        p2Name.fontName = "AvenirNext-Bold"
        p2Name.fontColor = player2Character.shirtColor
        p2Name.position = CGPoint(x: size.width - 20, y: topY + 20)
        p2Name.horizontalAlignmentMode = .right
        p2Name.zPosition = 90
        addChild(p2Name)
        
        // Timer with circular background
        timerBg = SKShapeNode(circleOfRadius: 20)
        timerBg.position = CGPoint(x: size.width / 2, y: topY + 5)
        timerBg.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 0.85)
        timerBg.strokeColor = .yellow
        timerBg.lineWidth = 2
        timerBg.zPosition = 90
        addChild(timerBg)
        
        timerLabel = SKLabelNode(text: "60")
        timerLabel.fontSize = 18
        timerLabel.fontName = "AvenirNext-Bold"
        timerLabel.fontColor = .white
        timerLabel.verticalAlignmentMode = .center
        timerLabel.zPosition = 91
        timerBg.addChild(timerLabel)
        
        // Round label
        roundLabel = SKLabelNode(text: "Round \(currentRound)")
        roundLabel.fontSize = 11
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontColor = .yellow
        roundLabel.position = CGPoint(x: size.width / 2, y: topY + 28)
        roundLabel.zPosition = 90
        addChild(roundLabel)
        
        // Announcement label
        announcementLabel = SKLabelNode(text: "")
        announcementLabel.fontSize = 44
        announcementLabel.fontName = "AvenirNext-Heavy"
        announcementLabel.fontColor = .yellow
        announcementLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        announcementLabel.zPosition = 100
        addChild(announcementLabel)
        
        // Special move indicators (circular progress rings)
        p1SpecialRing = SKShapeNode(circleOfRadius: 12)
        p1SpecialRing.position = CGPoint(x: healthBarWidth + 40, y: topY + 8)
        p1SpecialRing.fillColor = .yellow
        p1SpecialRing.strokeColor = .orange
        p1SpecialRing.lineWidth = 2.5
        p1SpecialRing.zPosition = 90
        addChild(p1SpecialRing)
        
        let p1SLabel = SKLabelNode(text: player1Character.specialMoveEmoji)
        p1SLabel.fontSize = 10
        p1SLabel.verticalAlignmentMode = .center
        p1SpecialRing.addChild(p1SLabel)
        
        p2SpecialRing = SKShapeNode(circleOfRadius: 12)
        p2SpecialRing.position = CGPoint(x: size.width - healthBarWidth - 40, y: topY + 8)
        p2SpecialRing.fillColor = .yellow
        p2SpecialRing.strokeColor = .orange
        p2SpecialRing.lineWidth = 2.5
        p2SpecialRing.zPosition = 90
        addChild(p2SpecialRing)
        
        let p2SLabel = SKLabelNode(text: player2Character.specialMoveEmoji)
        p2SLabel.fontSize = 10
        p2SLabel.verticalAlignmentMode = .center
        p2SpecialRing.addChild(p2SLabel)
        
        // Combo label (hidden by default)
        comboLabel = SKLabelNode(text: "")
        comboLabel.fontSize = 26
        comboLabel.fontName = "AvenirNext-Heavy"
        comboLabel.fontColor = .orange
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        comboLabel.zPosition = 95
        comboLabel.alpha = 0
        addChild(comboLabel)
    }
    
    // MARK: - Setup
    
    private func setupFighters() {
        player1 = FighterNode(character: player1Character, isPlayer1: true, groundY: groundY)
        player1.position = CGPoint(x: size.width * 0.25, y: groundY)
        player1.zPosition = 10
        worldNode.addChild(player1)
        
        player2 = FighterNode(character: player2Character, isPlayer1: false, groundY: groundY)
        player2.position = CGPoint(x: size.width * 0.75, y: groundY)
        player2.zPosition = 10
        worldNode.addChild(player2)
    }
    
    // MARK: - Round Management
    
    func startRound() {
        isRoundActive = false
        roundTimer = 60
        player1.health = 100
        player2.health = 100
        p1GhostHealth = 100
        p2GhostHealth = 100
        comboCount = 0
        
        player1.position = CGPoint(x: size.width * 0.25, y: groundY)
        player2.position = CGPoint(x: size.width * 0.75, y: groundY)
        
        player1.setFacing(right: true)
        player2.setFacing(right: false)
        
        player1.setExpression(.normal)
        player2.setExpression(.normal)
        player1.alpha = 1.0
        player2.alpha = 1.0
        player1.zRotation = 0
        player2.zRotation = 0
        
        roundLabel.text = "Round \(currentRound)"
        updateHealthBars()
        
        showAnnouncement("ROUND \(currentRound)") { [weak self] in
            self?.showAnnouncement("FIGHT!") { [weak self] in
                self?.isRoundActive = true
                self?.announcementLabel.text = ""
            }
        }
    }
    
    private func showAnnouncement(_ text: String, completion: @escaping () -> Void) {
        announcementLabel.text = text
        announcementLabel.setScale(0.1)
        announcementLabel.alpha = 1.0
        
        let grow = SKAction.scale(to: 1.3, duration: 0.25)
        let shrink = SKAction.scale(to: 1.0, duration: 0.1)
        let hold = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        
        announcementLabel.run(SKAction.sequence([grow, shrink, hold, fadeOut])) {
            completion()
        }
    }
    
    // MARK: - Player Input
    
    func playerMoveLeft() {
        guard isRoundActive else { return }
        player1.velocityX = -player1.moveSpeed
        player1.setFacing(right: false)
    }
    
    func playerMoveRight() {
        guard isRoundActive else { return }
        player1.velocityX = player1.moveSpeed
        player1.setFacing(right: true)
    }
    
    func playerStopMoving() {
        player1.velocityX = 0
    }
    
    func playerJump() {
        guard isRoundActive else { return }
        player1.executeMove(.jump)
    }
    
    func playerPillowSwing() {
        guard isRoundActive else { return }
        player1.executeMove(.pillowSwing)
        checkHit(attacker: player1, defender: player2, move: .pillowSwing)
    }
    
    func playerKick() {
        guard isRoundActive else { return }
        player1.executeMove(.kick)
        checkHit(attacker: player1, defender: player2, move: .kick)
    }
    
    func playerSpecial() {
        guard isRoundActive else { return }
        player1.executeMove(.special)
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.checkHit(attacker: self.player1, defender: self.player2, move: .special)
            }
        ]))
    }
    
    func playerBlock() {
        guard isRoundActive else { return }
        player1.executeMove(.block)
    }
    
    // MARK: - Combat
    
    private func checkHit(attacker: FighterNode, defender: FighterNode, move: MoveType) {
        let distance = abs(attacker.position.x - defender.position.x)
        
        guard distance <= move.range else { return }
        
        var damage = move.damage
        
        // Block reduces damage
        if defender.isBlocking {
            damage *= 0.2
        }
        
        // Random variance
        damage += CGFloat.random(in: -2...2)
        damage = max(1, damage)
        
        // Combo bonus
        let now = CACurrentMediaTime()
        if attacker === player1 {
            if now - lastComboTime < comboWindow {
                comboCount += 1
                if comboCount >= 2 {
                    damage *= (1.0 + CGFloat(comboCount - 1) * 0.15)
                    showCombo(comboCount)
                }
            } else {
                comboCount = 1
            }
            lastComboTime = now
        }
        
        defender.health -= damage
        defender.animateHit()
        
        // Impact effects
        let hitPos = CGPoint(
            x: (attacker.position.x + defender.position.x) / 2,
            y: defender.position.y + 30
        )
        
        showDamageNumber(Int(damage), at: defender.position, isSpecial: move == .special, isCombo: comboCount >= 2)
        spawnHitEffect(at: hitPos, isSpecial: move == .special)
        attacker.spawnImpactStars(at: hitPos)
        
        // Screen shake
        if move == .special {
            screenShake(intensity: 6, duration: 0.25)
            hitFreeze(duration: 0.06)
        } else {
            screenShake(intensity: 3, duration: 0.15)
            hitFreeze(duration: 0.03)
        }
        
        // Haptic feedback
        SoundManager.shared.playHitSound()
        
        updateHealthBars()
        onHealthUpdate?(player1.health, player2.health)
        
        if defender.health <= 0 {
            defender.health = 0
            endRound(winner: attacker === player1)
        }
    }
    
    // MARK: - Visual Effects
    
    private func showDamageNumber(_ damage: Int, at position: CGPoint, isSpecial: Bool, isCombo: Bool) {
        let label = SKLabelNode(text: "-\(damage)")
        label.fontSize = isSpecial ? 28 : (isCombo ? 24 : 20)
        label.fontName = "AvenirNext-Heavy"
        label.fontColor = isSpecial ? .yellow : (isCombo ? .orange : .white)
        label.position = CGPoint(x: position.x, y: position.y + 55)
        label.zPosition = 55
        label.setScale(0.5)
        addChild(label)
        
        let pop = SKAction.scale(to: isSpecial ? 1.3 : 1.1, duration: 0.1)
        let settle = SKAction.scale(to: 1.0, duration: 0.05)
        let rise = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 35, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.4)
        
        label.run(SKAction.sequence([
            pop, settle,
            SKAction.group([rise, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnHitEffect(at position: CGPoint, isSpecial: Bool) {
        // Star burst
        let burstCount = isSpecial ? 8 : 4
        for _ in 0..<burstCount {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            star.position = position
            star.fillColor = isSpecial ? .yellow : .white
            star.strokeColor = isSpecial ? .orange : .yellow
            star.lineWidth = 1
            star.zPosition = 50
            addChild(star)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 15...40)
            let burst = SKAction.moveBy(x: cos(angle) * dist, y: sin(angle) * dist, duration: 0.25)
            let fade = SKAction.fadeOut(withDuration: 0.25)
            let shrink = SKAction.scale(to: 0.1, duration: 0.25)
            star.run(SKAction.sequence([
                SKAction.group([burst, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func showCombo(_ count: Int) {
        comboLabel.text = "\(count)x COMBO!"
        comboLabel.alpha = 1.0
        comboLabel.setScale(0.5)
        comboLabel.fontColor = count >= 4 ? .red : (count >= 3 ? .yellow : .orange)
        comboLabel.fontSize = CGFloat(22 + count * 3)
        
        let pop = SKAction.scale(to: 1.2, duration: 0.1)
        let settle = SKAction.scale(to: 1.0, duration: 0.05)
        let hold = SKAction.wait(forDuration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        
        comboLabel.run(SKAction.sequence([pop, settle, hold, fade]))
    }
    
    // MARK: - Screen Shake & Hit Freeze
    
    private func screenShake(intensity: CGFloat, duration: TimeInterval) {
        let shakeCount = Int(duration / 0.03)
        var actions: [SKAction] = []
        for _ in 0..<shakeCount {
            let dx = CGFloat.random(in: -intensity...intensity)
            let dy = CGFloat.random(in: -intensity...intensity)
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 0.03))
        }
        actions.append(SKAction.move(to: .zero, duration: 0.03))
        worldNode.run(SKAction.sequence(actions))
    }
    
    private func hitFreeze(duration: TimeInterval) {
        let currentSpeed = self.speed
        self.speed = 0.05
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in self?.speed = currentSpeed }
        ]))
    }
    
    // MARK: - Health Bars
    
    private func updateHealthBars() {
        let innerW: CGFloat = healthBarWidth - 4
        
        let p1Pct = max(player1.health / 100, 0)
        let p2Pct = max(player2.health / 100, 0)
        
        // P1 health fill
        p1HealthFill.removeFromParent()
        p1HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: innerW * p1Pct, height: healthBarHeight - 4), cornerRadius: 3)
        p1HealthFill.fillColor = healthColor(for: p1Pct)
        p1HealthFill.strokeColor = .clear
        p1HealthBar.addChild(p1HealthFill)
        
        // P1 ghost (drain animation)
        let p1GhostPct = max(p1GhostHealth / 100, 0)
        p1GhostFill.removeFromParent()
        p1GhostFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: innerW * p1GhostPct, height: healthBarHeight - 4), cornerRadius: 3)
        p1GhostFill.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
        p1GhostFill.strokeColor = .clear
        p1GhostFill.zPosition = -1
        p1HealthBar.addChild(p1GhostFill)
        
        // P2 health fill (right-aligned)
        p2HealthFill.removeFromParent()
        let p2W = innerW * p2Pct
        p2HealthFill = SKShapeNode(rect: CGRect(x: innerW - p2W + 2, y: 2, width: p2W, height: healthBarHeight - 4), cornerRadius: 3)
        p2HealthFill.fillColor = healthColor(for: p2Pct)
        p2HealthFill.strokeColor = .clear
        p2HealthBar.addChild(p2HealthFill)
        
        // P2 ghost
        let p2GhostPct = max(p2GhostHealth / 100, 0)
        let p2GW = innerW * p2GhostPct
        p2GhostFill.removeFromParent()
        p2GhostFill = SKShapeNode(rect: CGRect(x: innerW - p2GW + 2, y: 2, width: p2GW, height: healthBarHeight - 4), cornerRadius: 3)
        p2GhostFill.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.4)
        p2GhostFill.strokeColor = .clear
        p2GhostFill.zPosition = -1
        p2HealthBar.addChild(p2GhostFill)
        
        // Special indicators
        p1SpecialRing.fillColor = player1.isSpecialReady ? .yellow : SKColor(white: 0.3, alpha: 0.8)
        p1SpecialRing.strokeColor = player1.isSpecialReady ? .orange : SKColor(white: 0.5, alpha: 0.5)
        p2SpecialRing.fillColor = player2.isSpecialReady ? .yellow : SKColor(white: 0.3, alpha: 0.8)
        p2SpecialRing.strokeColor = player2.isSpecialReady ? .orange : SKColor(white: 0.5, alpha: 0.5)
        
        // Pulse special when ready
        if player1.isSpecialReady {
            if p1SpecialRing.action(forKey: "pulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.15, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                p1SpecialRing.run(SKAction.repeatForever(pulse), withKey: "pulse")
            }
        } else {
            p1SpecialRing.removeAction(forKey: "pulse")
            p1SpecialRing.setScale(1.0)
        }
    }
    
    private func healthColor(for percentage: CGFloat) -> SKColor {
        if percentage > 0.5 {
            return .systemGreen
        } else if percentage > 0.25 {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
    
    // MARK: - Round End
    
    private func endRound(winner player1Won: Bool) {
        isRoundActive = false
        
        let loser = player1Won ? player2! : player1!
        let winner = player1Won ? player1! : player2!
        loser.animateKO()
        winner.setExpression(.happy)
        
        // KO screen shake
        screenShake(intensity: 8, duration: 0.3)
        
        // Slow-mo effect
        self.speed = 0.4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { [weak self] in self?.speed = 1.0 }
        ]))
        
        SoundManager.shared.playKOSound()
        
        let winnerName = player1Won ? player1Character.displayName : player2Character.displayName
        
        showAnnouncement("KO!") { [weak self] in
            self?.showAnnouncement("\(winnerName) WINS!") { [weak self] in
                self?.onRoundEnd?(player1Won)
            }
        }
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard isRoundActive else { return }
        
        // Timer
        roundTimer -= deltaTime
        timerLabel.text = "\(max(Int(roundTimer), 0))"
        
        if roundTimer <= 0 {
            endRound(winner: player1.health >= player2.health)
            return
        }
        
        // Timer warning
        if roundTimer <= 10 {
            timerLabel.fontColor = .red
            timerBg.strokeColor = .red
            // Pulse effect
            if timerBg.action(forKey: "timerPulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.4),
                    SKAction.scale(to: 1.0, duration: 0.4)
                ])
                timerBg.run(SKAction.repeatForever(pulse), withKey: "timerPulse")
            }
        } else {
            timerLabel.fontColor = .white
            timerBg.strokeColor = .yellow
            timerBg.removeAction(forKey: "timerPulse")
            timerBg.setScale(1.0)
        }
        
        // Update fighters
        player1.update(deltaTime: deltaTime)
        player2.update(deltaTime: deltaTime)
        
        // Clamp positions
        player1.position.x = max(arenaMinX, min(arenaMaxX, player1.position.x))
        player2.position.x = max(arenaMinX, min(arenaMaxX, player2.position.x))
        
        // Auto-face each other
        if !player1.isExecutingMove {
            player1.setFacing(right: player1.position.x < player2.position.x)
        }
        if !player2.isExecutingMove {
            player2.setFacing(right: player2.position.x < player1.position.x)
        }
        
        // AI
        aiController.update(deltaTime: deltaTime, aiFighter: player2, playerFighter: player1, sceneWidth: size.width)
        
        if player2.isExecutingMove && player2.currentMove != .idle {
            checkHit(attacker: player2, defender: player1, move: player2.currentMove)
        }
        
        // Ghost health drain (smooth animation toward actual health)
        p1GhostHealth += (player1.health - p1GhostHealth) * CGFloat(deltaTime) * 3
        p2GhostHealth += (player2.health - p2GhostHealth) * CGFloat(deltaTime) * 3
        
        // Low health pulsing
        if player1.health <= 25 && player1.health > 0 {
            p1HealthBar.alpha = 0.7 + 0.3 * CGFloat(sin(currentTime * 6))
        } else {
            p1HealthBar.alpha = 1.0
        }
        if player2.health <= 25 && player2.health > 0 {
            p2HealthBar.alpha = 0.7 + 0.3 * CGFloat(sin(currentTime * 6))
        } else {
            p2HealthBar.alpha = 1.0
        }
        
        updateHealthBars()
    }
}
